module transmitter
#(
    parameter BUS_WIDTH = 8,
    parameter DATA_WIDTH = 3
)
(
    input wire clk,
    input wire [BUS_WIDTH - 1:0] data_in,
    input wire is_addr,
    input wire send_en,
    output reg sda,
    output reg scl,
    output reg is_busy
);

    reg [BUS_WIDTH - 1:0] data;
    reg [DATA_WIDTH - 1:0] bits_sent;
    reg [2:0] state;
    reg [1:0] bit_state;

    initial
    begin
        state <= IDLE;
        bit_state <= BEFORE_CLK;
    end

    parameter IDLE = 3'b000, START = 3'b001, SENDING = 3'b010, WAIT = 3'b011, STOP = 3'b100;
    parameter BEFORE_CLK = 2'b00, AT_CLK = 2'b01, AFTER_CLK = 2'b10;

    always @(posedge clk)
    begin
        if (send_en && state == IDLE)
            begin
                data <= data_in;
                if (is_addr)
                    begin
                        bits_sent <= 3'b001;
                    end
                else
                    begin
                        bits_sent <= 3'b000;
                    end
                state = START;
            end
        else
            begin
                case (state)
                    IDLE :
                    begin
                        is_busy = 1'b0;
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
                                scl <= 1'b0;
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
                                        bits_sent <= bits_sent + 3'b001;
                                    end
                                    default :
                                    begin
                                        sda <= 1'bZ;
                                        scl <= 1'bZ;
                                    end
                                endcase
                            end
                        else
                            if (is_addr)
                                begin
                                    state <= WAIT;

                                end
                            else
                                begin
                                    state <= STOP;
                                end

                    end

                    WAIT:
                    begin
                        sda <= 1'bZ;
                        scl <= 1'bZ;
                        state <= STOP;
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
                                scl <= 1'b0;
                                bit_state <= BEFORE_CLK;
                                state <= IDLE;
                            end
                            default :
                            begin
                                sda <= 1'bZ;
                                scl <= 1'bZ;
                            end
                        endcase
                        state <= IDLE;
                    end

                    default :
                    begin
                        is_busy = 1'b0;
                        sda <= 1'bZ;
                        scl <= 1'bZ;
                    end
                endcase
            end
    end


endmodule