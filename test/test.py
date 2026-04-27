# SPDX-FileCopyrightText: 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


def ui_value(prog_mode, we, start, enter, player_input):
    value = 0
    value |= (prog_mode & 1) << 0
    value |= (we & 1) << 1
    value |= (start & 1) << 2
    value |= (enter & 1) << 3
    value |= (player_input & 3) << 4
    return value


async def write_ram(dut, address, data):
    dut.uio_in.value = address & 0x0F
    dut.ui_in.value = ui_value(1, 1, 0, 0, data)
    await ClockCycles(dut.clk, 1)
    dut.ui_in.value = ui_value(1, 0, 0, 0, data)
    await ClockCycles(dut.clk, 1)


async def press_button(dut, button):
    dut.ui_in.value = ui_value(0, 0, 0, 1, button)
    await ClockCycles(dut.clk, 1)
    dut.ui_in.value = ui_value(0, 0, 0, 0, button)
    await ClockCycles(dut.clk, 1)


async def wait_show_done(dut, cycles):
    await ClockCycles(dut.clk, cycles)


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start Simon memory game test")

    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 5)

    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 2)

    dut._log.info("Programming RAM")
    await write_ram(dut, 0, 0)
    await write_ram(dut, 1, 1)
    await write_ram(dut, 2, 2)
    await write_ram(dut, 3, 3)

    dut.ui_in.value = 0
    dut.uio_in.value = 0
    await ClockCycles(dut.clk, 2)

    dut._log.info("Starting game")
    dut.ui_in.value = ui_value(0, 0, 1, 0, 0)
    await ClockCycles(dut.clk, 1)
    dut.ui_in.value = 0

    dut._log.info("Level 1")
    await wait_show_done(dut, 2)
    await press_button(dut, 0)
    await ClockCycles(dut.clk, 3)
    assert (dut.uo_out.value.integer & 0b00010000) == 0, "Error should not be active after level 1"

    dut._log.info("Level 2")
    await wait_show_done(dut, 3)
    await press_button(dut, 0)
    await press_button(dut, 1)
    await ClockCycles(dut.clk, 3)
    assert (dut.uo_out.value.integer & 0b00010000) == 0, "Error should not be active after level 2"

    dut._log.info("Level 3 with wrong answer")
    await wait_show_done(dut, 4)
    await press_button(dut, 0)
    await press_button(dut, 1)
    await press_button(dut, 3)
    await ClockCycles(dut.clk, 3)
    assert (dut.uo_out.value.integer & 0b00010000) != 0, "Error should be active after wrong answer"

    dut._log.info("Test finished successfully")
