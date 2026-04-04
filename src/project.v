/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module project (
    input [7:0] ui_in,
    output [7:0] uo_out
);

assign uo_out[0] = ui_in[0] ^ ui_in[1]; // SUM
assign uo_out[1] = ui_in[0] & ui_in[1]; // CARRY

endmodule