`timescale 1ns/10ps

module tb_top;
    localparam WR = 4'h0;
    localparam RD = 4'h1;
    localparam PERIOD = 20.0;

    logic clk;
    logic rstb;

    logic wr_en;
    logic [7:0] wr_data;
    wire tx_busy;
    wire rx_valid;
    wire [7:0] rx_data;

    wire [7:0] led_out;
    wire [3:0] led_enb;

    always #(PERIOD/2) clk = ~clk;

    uart_top U_UART_TESTER(
        .clk(clk),
        .rstb(rstb),
        .wr_en(wr_en),
        .wr_data(wr_data),
        .tx_busy(tx_busy),
        .rx_valid(rx_valid),
        .rx_data(rx_data),
        .tx(uart_rx),
        .rx(uart_tx)
    );

    top U_TOP(
        .clk(clk),
        .rstb(rstb),

        .uart_rx(uart_rx),
        .uart_tx(uart_tx),

        .led_enb(led_enb),
        .led_out(led_out)
    );

    task send_byte(logic [7:0] byte_data);
        forever begin
            if(tx_busy) @(negedge clk);
            else break;
        end
        @(negedge clk);
        wr_data = byte_data;
        wr_en = 1;
        @(negedge clk);
        wr_en = 0;
    endtask

    task reg_wr(logic [7:0] wr_addr, logic [7:0] val);
        send_byte(WR);
        send_byte(wr_addr);
        send_byte(val);
    endtask

    initial begin
        clk = 0;
        rstb = 0;
        repeat(20)begin @(negedge clk); end
        rstb = 1;
        repeat(20)begin @(negedge clk); end
        repeat(5) begin
            reg_wr(0,$urandom_range(0,'hff));
        end
        reg_wr(1,1);
        repeat(10)begin
            @(negedge clk);
        end
        reg_wr(2,1);
        repeat(200)begin
            @(negedge clk);
        end
    end



endmodule
