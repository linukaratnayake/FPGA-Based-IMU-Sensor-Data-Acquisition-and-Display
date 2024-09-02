`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/02/2024 10:13:11 AM
// Design Name: 
// Module Name: i2c_transmitter_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module i2c_transmitter_tb
#(
    parameter BUS_WIDTH = 8,
    parameter DATA_WIDTH = 3
);

    // Inputs
    reg clk_50m;
    reg [BUS_WIDTH - 1:0] data_in;
    reg is_addr;
    reg send_en;

    // Outputs
    wire sda;
    wire scl;
    wire is_busy;

    // Instantiate transmitter
    transmitter
    #(
        .BUS_WIDTH(BUS_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    )
    transmitter_instance
    (
        .clk(clk_50m),
        .data_in(data_in),
        .is_addr(is_addr),
        .send_en(send_en),
        .sda(sda),
        .scl(scl),
        .is_busy(is_busy)
    );

    // Clock generation
    always #10 clk_50m = ~clk_50m; // Period = 20ns

    // Stimulus
    initial
    begin
        clk_50m = 0;

        #40;
        data_in = 8'h68;
        is_addr = 1'b1;

        #40;
        send_en = 1'b1;

        #60;
        send_en = 1'b0;

        #1000;
        data_in = 8'h6B;
        is_addr = 1'b0;
        send_en = 1'b1;

        #20;
        send_en = 1'b0;

    end


endmodule
