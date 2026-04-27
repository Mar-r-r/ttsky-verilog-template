`default_nettype none

module memory_game(
    input wire clk,
    input wire reset,

    input wire prog_mode,
    input wire we,
    input wire [3:0] prog_addr,
    input wire [7:0] prog_data,

    input wire start,
    input wire [1:0] player_input,
    input wire enter,

    output reg [1:0] led_out,
    output reg show_valid,
    output reg correct,
    output reg error,
    output reg win,
    output reg [4:0] level,
    output wire [2:0] state_out
);

    localparam IDLE       = 3'd0;
    localparam SHOW       = 3'd1;
    localparam WAIT_INPUT = 3'd2;
    localparam CHECK      = 3'd3;
    localparam ERROR_ST   = 3'd4;
    localparam WIN_ST     = 3'd5;

    reg [2:0] state;
    reg [3:0] index;

    wire [3:0] ram_addr;
    wire [7:0] ram_data;

    assign ram_addr = (prog_mode) ? prog_addr : index;
    assign state_out = state;

    ram sequence_ram(
        .clk(clk),
        .we(prog_mode ? we : 1'b0),
        .addr(ram_addr),
        .data_in(prog_data),
        .data_out(ram_data)
    );

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            index <= 4'd0;
            level <= 5'd1;
            led_out <= 2'd0;
            show_valid <= 1'b0;
            correct <= 1'b0;
            error <= 1'b0;
            win <= 1'b0;
        end else begin
            correct <= 1'b0;
            show_valid <= 1'b0;

            if (prog_mode) begin
                state <= IDLE;
                index <= 4'd0;
                level <= 5'd1;
                led_out <= 2'd0;
                error <= 1'b0;
                win <= 1'b0;
            end else begin
                case (state)
                    IDLE: begin
                        led_out <= 2'd0;
                        error <= 1'b0;
                        win <= 1'b0;
                        index <= 4'd0;

                        if (start) begin
                            level <= 5'd1;
                            state <= SHOW;
                        end
                    end

                    SHOW: begin
                        led_out <= ram_data[1:0];
                        show_valid <= 1'b1;

                        if ({1'b0, index} == (level - 5'd1)) begin
                            index <= 4'd0;
                            state <= WAIT_INPUT;
                        end else begin
                            index <= index + 4'd1;
                        end
                    end

                    WAIT_INPUT: begin
                        led_out <= 2'd0;
                        if (enter) begin
                            state <= CHECK;
                        end
                    end

                    CHECK: begin
                        if (player_input == ram_data[1:0]) begin
                            correct <= 1'b1;

                            if ({1'b0, index} == (level - 5'd1)) begin
                                if (level == 5'd16) begin
                                    state <= WIN_ST;
                                end else begin
                                    level <= level + 5'd1;
                                    index <= 4'd0;
                                    state <= SHOW;
                                end
                            end else begin
                                index <= index + 4'd1;
                                state <= WAIT_INPUT;
                            end
                        end else begin
                            state <= ERROR_ST;
                        end
                    end

                    ERROR_ST: begin
                        error <= 1'b1;
                        led_out <= 2'd0;
                    end

                    WIN_ST: begin
                        win <= 1'b1;
                        led_out <= 2'd0;
                    end

                    default: begin
                        state <= IDLE;
                    end
                endcase
            end
        end
    end

endmodule

`default_nettype wire
