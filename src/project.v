`default_nettype none

module tt_um_isalopez9_memory_game (
`ifdef USE_POWER_PINS
    inout wire VPWR,
    inout wire VGND,
`endif

    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire ena,
    input  wire clk,
    input  wire rst_n
);

    wire prog_mode;
    wire we;
    wire start;
    wire enter;
    wire [1:0] player_input;
    wire [3:0] prog_addr;
    wire [7:0] prog_data;

    wire [1:0] led_out;
    wire show_valid;
    wire correct;
    wire error;
    wire win;
    wire [4:0] level;
    wire [2:0] state_out;

    assign prog_mode    = ui_in[0];
    assign we           = ui_in[1];
    assign start        = ui_in[2];
    assign enter        = ui_in[3];
    assign player_input = ui_in[5:4];

    // uio_in[3:0] controla la direccion de memoria
    assign prog_addr = uio_in[3:0];

    // ui_in[7:6] controla el dato que se guarda en RAM
    assign prog_data = {6'b000000, ui_in[7:6]};

    memory_game game_inst (
        .clk(clk),
        .reset(~rst_n),
        .prog_mode(prog_mode),
        .we(we),
        .prog_addr(prog_addr),
        .prog_data(prog_data),
        .start(start),
        .player_input(player_input),
        .enter(enter),
        .led_out(led_out),
        .show_valid(show_valid),
        .correct(correct),
        .error(error),
        .win(win),
        .level(level),
        .state_out(state_out)
    );

    assign uo_out[1:0] = led_out;
    assign uo_out[2]   = show_valid;
    assign uo_out[3]   = correct;
    assign uo_out[4]   = error;
    assign uo_out[5]   = win;
    assign uo_out[7:6] = level[1:0];

    // Todos los pines bidireccionales quedan como entradas
    assign uio_out = 8'b00000000;
    assign uio_oe  = 8'b00000000;

    // Senales no usadas para evitar warnings
    wire unused;
    assign unused = ena |
                    state_out[0] | state_out[1] | state_out[2] |
                    level[2] | level[3] | level[4] |
                    uio_in[4] | uio_in[5] | uio_in[6] | uio_in[7];

endmodule

`default_nettype wire