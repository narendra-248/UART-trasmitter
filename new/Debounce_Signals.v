`timescale 1ns / 1ps
module Debounce_Signals
#(parameter threshold = 100000)
(
    input  clk,
    input  btn,
    output reg transmit = 0
);
    reg button_ff1 = 0;
    reg button_ff2 = 0;
    reg [16:0] count      = 0;
    reg        pulse_sent = 0;

    // Two-FF Synchronizer (metastability protection)
    always @(posedge clk)
    begin
        button_ff1 <= btn;
        button_ff2 <= button_ff1;
    end

    // Debounce + One-Pulse Generator
    always @(posedge clk)
    begin
        transmit <= 0;

        if(button_ff2)
        begin
            if(count < threshold)
                count <= count + 1;

            if(count == threshold - 1 && !pulse_sent)
            begin
                transmit   <= 1;
                pulse_sent <= 1;
            end
        end
        else
        begin
            count      <= 0;
            pulse_sent <= 0;
        end
    end

endmodule