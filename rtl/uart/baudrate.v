module baudrate #(
    parameter CLK_FREQ = 50000000,
    parameter BAUD_RATE = 9600
)(
    input clk,
    input rstb,
    output tx_clk_en,
    output rx_clk_en
);

    localparam cnt_end = CLK_FREQ / BAUD_RATE / 16;
    reg [15:0] cnt;
    reg [3:0] tx_cnt;
    always @(posedge clk or negedge rstb) begin
        if(~rstb) begin
            cnt <= 0;
        end else begin
            if(cnt == cnt_end) begin
                cnt <= 0;
            end else begin
                cnt <= cnt + 1;
            end
        end
    end

    assign rx_clk_en = cnt == cnt_end;

    always @(posedge clk or negedge rstb) begin
        if(~rstb) begin
            tx_cnt <= 0;
        end else begin
            if(rx_clk_en) begin
                tx_cnt <= tx_cnt + 1;
            end
        end
    end

    assign tx_clk_en = tx_cnt == 'hF & rx_clk_en;

endmodule
