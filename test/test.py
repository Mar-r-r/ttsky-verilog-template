# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


def ui_value(prog_mode, we, start, enter, player_input, prog_data):
    value = 0
    value = value | (prog_mode << 0)
    value = value | (we << 1)
    value = value | (start << 2)
    value = value | (enter << 3)
    value = value | (player_input << 4)
    value = value | (prog_data << 6)
    return value


async def write_ram(dut, address, data):
    # address va por uio_in[3:0]
    # data va por ui_in[7:6]
    dut.uio_in.value = address
    dut.ui_in.value = ui_value(1, 1, 0, 0, 0, data)
    await ClockCycles(dut.clk, 1)

    dut.ui_in.value = ui_value(1, 0, 0, 0, 0, data)
    await ClockCycles(dut.clk, 1)


async def press_button(dut, button):
    # player_input va por ui_in[5:4]
    # enter va por ui_in[3]
    dut.ui_in.value = ui_value(0, 0, 0, 1, button, 0)
    await ClockCycles(dut.clk, 1)

    dut.ui_in.value = ui_value(0, 0, 0, 0, button, 0)
    await ClockCycles(dut.clk, 1)

    dut.ui_in.value = 0
    await ClockCycles(dut.clk, 1)


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start Simon memory game test")

    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    # Reset inicial
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0

    await ClockCycles(dut.clk, 10)

    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 3)

    # ==========================================================
    # Programar RAM
    # Secuencia usada:
    # addr 0 -> 0
    # addr 1 -> 1
    # addr 2 -> 2
    # addr 3 -> 3
    # ==========================================================

    dut._log.info("Programming RAM")

    await write_ram(dut, 0, 0)
    await write_ram(dut, 1, 1)
    await write_ram(dut, 2, 2)
    await write_ram(dut, 3, 3)

    # Salir de modo programacion
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    await ClockCycles(dut.clk, 3)

    # ==========================================================
    # Iniciar juego
    # ==========================================================

    dut._log.info("Starting game")

    dut.ui_in.value = ui_value(0, 0, 1, 0, 0, 0)
    await ClockCycles(dut.clk, 1)

    dut.ui_in.value = 0
    await ClockCycles(dut.clk, 4)

    # ==========================================================
    # Nivel 1
    # Secuencia esperada: 0
    # ==========================================================

    dut._log.info("Testing level 1")

    await press_button(dut, 0)
    await ClockCycles(dut.clk, 4)

    assert (dut.uo_out.value.integer & 0b00010000) == 0, "Error should not be active after level 1"

    # ==========================================================
    # Nivel 2
    # Secuencia esperada: 0, 1
    # ==========================================================

    dut._log.info("Testing level 2")

    await press_button(dut, 0)
    await press_button(dut, 1)
    await ClockCycles(dut.clk, 5)

    assert (dut.uo_out.value.integer & 0b00010000) == 0, "Error should not be active after level 2"

    # ==========================================================
    # Nivel 3 con respuesta incorrecta
    # Secuencia real: 0, 1, 2
    # Se ingresa: 0, 1, 3
    # ==========================================================

    dut._log.info("Testing wrong answer at level 3")

    await press_button(dut, 0)
    await press_button(dut, 1)
    await press_button(dut, 3)
    await ClockCycles(dut.clk, 5)

    assert (dut.uo_out.value.integer & 0b00010000) != 0, "Error should be active after wrong answer"

    dut._log.info("Test finished successfully")