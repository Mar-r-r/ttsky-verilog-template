`timescale 1ns / 1ps

module tb_memory_game;

    reg clk;
    reg reset;

    reg prog_mode;
    reg we;
    reg [3:0] prog_addr;
    reg [7:0] prog_data;

    reg start;
    reg [1:0] player_input;
    reg enter;

    wire [1:0] led_out;
    wire show_valid;
    wire correct;
    wire error;
    wire win;
    wire [4:0] level;
    wire [2:0] state_out;

    memory_game dut(
        .clk(clk),
        .reset(reset),
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

    // Reloj de 10 ns
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        prog_mode = 0;
        we = 0;
        prog_addr = 0;
        prog_data = 0;
        start = 0;
        player_input = 0;
        enter = 0;

        #20;
        reset = 0;

        // ==============================
        // PROGRAMACION DE LA RAM
        // Secuencia: 0, 1, 2, 3, 0, 1...
        // ==============================

        prog_mode = 1;

        prog_addr = 4'd0;  prog_data = 8'd0; we = 1; #10; we = 0; #10;
        prog_addr = 4'd1;  prog_data = 8'd1; we = 1; #10; we = 0; #10;
        prog_addr = 4'd2;  prog_data = 8'd2; we = 1; #10; we = 0; #10;
        prog_addr = 4'd3;  prog_data = 8'd3; we = 1; #10; we = 0; #10;
        prog_addr = 4'd4;  prog_data = 8'd0; we = 1; #10; we = 0; #10;
        prog_addr = 4'd5;  prog_data = 8'd1; we = 1; #10; we = 0; #10;
        prog_addr = 4'd6;  prog_data = 8'd2; we = 1; #10; we = 0; #10;
        prog_addr = 4'd7;  prog_data = 8'd3; we = 1; #10; we = 0; #10;
        prog_addr = 4'd8;  prog_data = 8'd0; we = 1; #10; we = 0; #10;
        prog_addr = 4'd9;  prog_data = 8'd1; we = 1; #10; we = 0; #10;
        prog_addr = 4'd10; prog_data = 8'd2; we = 1; #10; we = 0; #10;
        prog_addr = 4'd11; prog_data = 8'd3; we = 1; #10; we = 0; #10;
        prog_addr = 4'd12; prog_data = 8'd0; we = 1; #10; we = 0; #10;
        prog_addr = 4'd13; prog_data = 8'd1; we = 1; #10; we = 0; #10;
        prog_addr = 4'd14; prog_data = 8'd2; we = 1; #10; we = 0; #10;
        prog_addr = 4'd15; prog_data = 8'd3; we = 1; #10; we = 0; #10;

        prog_mode = 0;

        // ==============================
        // INICIO DEL JUEGO
        // Nivel 1: debe responder 0
        // ==============================

        start = 1; #10;
        start = 0;

        // Espera a que el circuito muestre la secuencia
        #30;

        // Respuesta correcta para nivel 1
        player_input = 2'd0;
        enter = 1; #10;
        enter = 0; #40;

        // ==============================
        // Nivel 2: debe responder 0, 1
        // ==============================

        player_input = 2'd0;
        enter = 1; #10;
        enter = 0; #20;

        player_input = 2'd1;
        enter = 1; #10;
        enter = 0; #40;

        // ==============================
        // Nivel 3: respuesta incorrecta
        // Secuencia real: 0, 1, 2
        // Se ingresa: 0, 1, 3
        // ==============================

        player_input = 2'd0;
        enter = 1; #10;
        enter = 0; #20;

        player_input = 2'd1;
        enter = 1; #10;
        enter = 0; #20;

        player_input = 2'd3;
        enter = 1; #10;
        enter = 0; #50;

        $finish;
    end

endmodule
