`default_nettype none

module ram(
    input wire clk,
    input wire we,
    input wire [3:0] addr,
    input wire [7:0] data_in,
    output wire [7:0] data_out
);

    reg [7:0] ram_mem [0:15];

    always @(posedge clk) begin
        if (we) begin
            ram_mem[addr] <= data_in;
        end
    end

    assign data_out = ram_mem[addr];

endmodule

`default_nettype wire
