`timescale 1ns / 1ps
module Top_module(
    input [7:0] data,
    input clk,
    input btn,
    output TxD
);
    wire transmit_out;

    Debounce_Signals #(.threshold(100000)) DB1(
        .clk(clk),
        .btn(btn),
        .transmit(transmit_out)
    );

    Transmitter T1(
        .clk(clk),
        .data(data),
        .transmit(transmit_out),
        .reset(1'b0),
        .TxD(TxD)
    );

endmodule