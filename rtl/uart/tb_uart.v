`timescale 1ns/10ps

module tb_uart();

localparam PERIOD = 20.0;
    
reg clk;
reg rstb;
reg wr_en;
reg [7:0] wr_data;

wire rx_valid;
wire [7:0] rx_data;

wire loopback;
wire tx_busy;

always #(PERIOD/2) clk = ~clk;

always @(posedge clk or negedge rstb) begin
    if(~rstb) begin
        wr_en <= 0;
        wr_data <= 0;
    end else begin
        if(~tx_busy & ~wr_en) begin
            wr_en <= 1;
            wr_data <= $urandom_range(0,'hff);
        end else begin
            wr_en <= 0;
        end
    end
end

initial begin
    clk = 0;
    rstb = 0;
    repeat(20) begin
        @(negedge clk);
    end
    rstb = 1;
end

uart_top U_UART(
    .clk(clk),
    .rstb(rstb),
    .wr_en(wr_en),
    .wr_data(wr_data),
    .tx_busy(tx_busy),
    .rx_valid(rx_valid),
    .rx_data(rx_data),
    .tx(loopback),
    .rx(loopback)
);

endmodule
