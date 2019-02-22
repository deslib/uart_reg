module uart_top (
    input clk,
    input rstb,
    input rx,
    output tx,
    input wr_en,
    input [7:0] wr_data,
    output tx_busy,
    output rx_valid,
    output [7:0] rx_data
);

    baudrate #(
        .CLK_FREQ(50000000),
        .BAUD_RATE(115200)
    )U_BAUDRATE(
        .clk(clk),
        .rstb(rstb),
        .rx_clk_en(rx_clk_en),
        .tx_clk_en(tx_clk_en)
    );

    transmitter U_TX(
        .clk(clk),
        .clk_en(tx_clk_en),
        .rstb(rstb),
    
        .wr_en(wr_en),
        .data(wr_data),
    
        .tx(tx),
        .tx_busy(tx_busy)
    );

    receiver U_RX(
        .clk(clk),
        .clk_en(rx_clk_en),
        .rstb(rstb),
    
        .rx(rx),
    
        .rx_valid(rx_valid),
        .data(rx_data)
    );

endmodule
