`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 09/02/2024 10:10:03 AM
// Design Name:
// Module Name: i2c_transmitter
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

module i2c_transmitter
    #(
        parameter BUS_WIDTH = 8,
        parameter DATA_WIDTH = 3
    )
    (
        input wire clk,
        input wire [BUS_WIDTH - 1:0] data_in,
        input wire is_addr,
        input wire read_write,
        input wire send_en,
        output reg sda,
        output reg scl,
        output reg is_busy
    );

    reg [BUS_WIDTH - 1:0] data;
    reg [DATA_WIDTH:0] bits_sent = 0;
    reg [2:0] state;
    reg [1:0] bit_state;

    parameter IDLE = 3'b000, START = 3'b001, SENDING = 3'b010, WAIT = 3'b011, STOP = 3'b100;
    parameter BEFORE_CLK = 2'b00, AT_CLK = 2'b01, AFTER_CLK = 2'b10;

    initial
    begin
        state <= IDLE;
        bit_state <= BEFORE_CLK;
    end

    always @(posedge clk)
    begin
        if (send_en && state == IDLE)
        begin
            data <= data_in;
            if (is_addr)
            begin
                if (read_write)
                begin
                    data[0] <= read_write;
                end
            end
            state <= START;
        end
        else
        begin
            case (state)
                IDLE :
                begin
                    is_busy <= 1'b0;
                    sda <= 1'bZ;
                    scl <= 1'bZ;
                end

                START :
                begin
                    is_busy <= 1'b1;
                    case (bit_state)
                        BEFORE_CLK :
                        begin
                            sda <= 1'b0;
                            scl <= 1'b1;
                            bit_state <= AT_CLK;
                        end
                        AT_CLK :
                        begin
                            sda <= 1'b0;
                            scl <= 1'b1;
                            bit_state <= AFTER_CLK;
                        end
                        AFTER_CLK:
                        begin
                            sda <= 1'b0;
                            scl <= 1'b0;
                            bit_state <= BEFORE_CLK;
                            state <= SENDING;
                        end
                        default :
                        begin
                            sda <= 1'bZ;
                            scl <= 1'bZ;
                        end
                    endcase
                end

                SENDING :
                begin
                    is_busy <= 1'b1;

                    if (bits_sent != BUS_WIDTH)
                    begin
                        sda <= data[BUS_WIDTH - 1 - bits_sent];
                        case (bit_state)
                            BEFORE_CLK :
                            begin
                                scl <= 1'b0;
                                bit_state <= AT_CLK;
                            end
                            AT_CLK :
                            begin
                                scl <= 1'b1;
                                bit_state <= AFTER_CLK;
                            end
                            AFTER_CLK :
                            begin
                                scl <= 1'b0;
                                bit_state <= BEFORE_CLK;
                                bits_sent <= bits_sent + 4'b0001;
                            end
                            default :
                            begin
                                sda <= 1'bZ;
                                scl <= 1'bZ;
                            end
                        endcase
                    end
                    else
                        // if (is_addr)
                        // begin
                        state <= WAIT;
                    // end
                    // else
                    // begin
                    //     state <= STOP;
                    // end

                end

                WAIT:
                begin
                    case (bit_state)
                        BEFORE_CLK :
                        begin
                            sda <= 1'bZ;
                            scl <= 1'bZ;
                            bit_state <= AT_CLK;
                        end
                        AT_CLK :
                        begin
                            // sda <= 1'bZ;
                            // sda should be made inout and read whether the receiver has acknowledged.
                            // If not acknowledged, go back to start and resend the same byte.
                            scl <= 1'bZ;
                            bit_state <= AFTER_CLK;
                        end
                        AFTER_CLK :
                        begin
                            sda <= 1'bZ;
                            scl <= 1'bZ;
                            bit_state <= BEFORE_CLK;
                            state <= STOP;
                        end
                        default :
                        begin
                            sda <= 1'bZ;
                            scl <= 1'bZ;
                        end
                    endcase
                end

                STOP :
                begin
                    is_busy <= 1'b1;
                    case (bit_state)
                        BEFORE_CLK :
                        begin
                            sda <= 1'b1;
                            scl <= 1'b0;
                            bit_state <= AT_CLK;
                        end
                        AT_CLK :
                        begin
                            sda <= 1'b1;
                            scl <= 1'b1;
                            bit_state <= AFTER_CLK;
                        end
                        AFTER_CLK:
                        begin
                            sda <= 1'b1;
                            scl <= 1'b1;
                            bit_state <= BEFORE_CLK;
                            bits_sent <= 0;
                            state <= IDLE;
                        end
                        default :
                        begin
                            sda <= 1'bZ;
                            scl <= 1'bZ;
                        end
                    endcase
                end

                default :
                begin
                    is_busy <= 1'b0;
                    sda <= 1'bZ;
                    scl <= 1'bZ;
                end
            endcase
        end
    end


endmodule
