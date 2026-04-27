# Simon Memory Game - Tiny Tapeout Verilog Project

Digital memory game inspired by Simon Says.

The design uses a 16x8 RAM to store a sequence. In programming mode, values are written into RAM. In game mode, the sequence is shown through `uo_out[1:0]`, and the player repeats it with `ui_in[5:4]` plus `enter`.

## Inputs

- `ui_in[0]`: programming mode
- `ui_in[1]`: write enable
- `ui_in[2]`: start
- `ui_in[3]`: enter
- `ui_in[5:4]`: player input
- `uio_in[3:0]`: RAM address during programming
- `rst_n`: active-low reset
- `clk`: clock

## Outputs

- `uo_out[1:0]`: LED output
- `uo_out[2]`: show valid
- `uo_out[3]`: correct pulse
- `uo_out[4]`: error
- `uo_out[5]`: win
- `uo_out[7:6]`: low bits of level

## Simulation

From the `test` folder:

```bash
make -B
```
