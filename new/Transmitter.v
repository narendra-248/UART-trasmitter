`timescale 1ns / 1ps
module Transmitter(
    input clk,
    input [7:0] data,
    input transmit,
    input reset,
    output reg TxD = 1'b1
);
    parameter IDLE = 0;
    parameter SEND = 1;

    reg state = IDLE;
    reg [13:0] baud_counter = 0;
    reg [3:0]  bit_counter  = 0;
    reg [9:0]  tx_data      = 10'b1111111111;

    always @(posedge clk)
    begin
        if(reset)
        begin
            state       <= IDLE;
            TxD         <= 1'b1;
            baud_counter <= 0;
            bit_counter  <= 0;
            tx_data      <= 10'b1111111111;
        end
        else
        begin
            case(state)

            IDLE:
            begin
                TxD <= 1'b1;
                if(transmit)
                begin
                    tx_data      <= {1'b1, data, 1'b0};
                    state        <= SEND;
                    baud_counter <= 0;
                    bit_counter  <= 0;
                end
            end

            SEND:
            begin
                if(baud_counter < 14'd10415)
                begin
                    baud_counter <= baud_counter + 1;
                end
                else
                begin
                    baud_counter <= 0;
                    TxD          <= tx_data[0];
                    tx_data      <= tx_data >> 1;

                    if(bit_counter < 4'd9)
                        bit_counter <= bit_counter + 1;
                    else
                    begin
                        bit_counter <= 0;
                        state       <= IDLE;
                    end
                end
            end

            default:
            begin
                state <= IDLE;
                TxD   <= 1'b1;
            end

            endcase
        end
    end

endmodule