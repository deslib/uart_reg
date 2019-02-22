module top(
    input clk,
    input rstb,

    input uart_rx,
    output uart_tx,

    output logic [7:0] led_out,
    output logic [3:0] led_enb
);

    localparam cnt_end = 8000;

    logic [7:0] digit_ctrl;
    logic [7:0] digit_status;
    logic digit_run;
    logic [7:0] uart_din;
    logic [7:0] uart_dout;

    logic [3:0] bus_be;
    logic [15:0] bus_addr;
    logic [31:0] bus_wdata;
    logic [31:0] bus_rdata;

    wire digit_start;
    wire digit_stop;

    logic [23:0] cnt;
    wire led_update = (cnt[15:0] == 'hffff);
    wire led_tick = (cnt[23:0] == 'hffffff);

    logic [3:0] led_en;
    assign led_enb = ~led_en;

    logic [7:0] led_loop;
    logic [7:0] led_loop_inv;

    always @(posedge clk or negedge rstb) begin
        if(~rstb) begin
            led_en <= 1;
        end else begin
            if(led_update) begin
                led_en <= {led_en[2:0],led_en[3]};
            end
        end
    end

    assign led_out = led_en == 4'b0001 ? digit_ctrl :
                     led_en == 4'b0010 ? digit_status :
                     led_en == 4'b0100 ? led_loop : led_loop_inv;

    always @(posedge clk or negedge rstb) begin
        if(~rstb) begin
            digit_run <= 0;
        end else begin
            if(digit_start) begin
                digit_run <= 1;
            end else if(digit_stop) begin
                digit_run <= 0;
            end
        end
    end

    always @(posedge clk or negedge rstb) begin
        if(~rstb) begin
            cnt <= 0;
        end else begin
            cnt <= cnt + 1;
        end
    end

   

    always @(posedge clk or negedge rstb) begin
        if(~rstb) begin
            digit_status <= 0;
        end else begin
            if(digit_run && led_tick) begin
                digit_status <= digit_status + 1;
            end
        end
    end

    always @(posedge clk or negedge rstb) begin
        if(~rstb) begin
            led_loop <= 1;
            led_loop_inv <= 'hfe;
        end else begin
            if(led_tick) begin
                led_loop <= {led_loop[6:0],led_loop[7]};
                led_loop_inv <= {led_loop_inv[6:0],led_loop_inv[7]};
            end
        end
    end

    uart_top U_UART(
        .clk(clk),
        .rstb(rstb),
        .rx(uart_rx),
        .tx(uart_tx),
        .wr_en(uart_wr_en),
        .wr_data(uart_din),
        .tx_busy(uart_tx_busy),
        .rx_valid(uart_rx_rdy),
        .rx_data(uart_dout)
    );

    uart_cmder U_UART_CMDER(
        .clk(clk),
        .rstb(rstb),
    
        .uart_wr_en(uart_wr_en),
        .uart_din(uart_din),
        .uart_tx_busy(uart_tx_busy),
        .uart_rx_rdy(uart_rx_rdy),
        .uart_rx_rdy_clr(uart_rx_rdy_clr),
        .uart_dout(uart_dout),
    
        .bus_wr_en(bus_wr_en),
        .bus_be(bus_be),
        .bus_addr(bus_addr),
        .bus_wdata(bus_wdata),
    
        .bus_rd_en(bus_rd_en),
        .bus_rdata(bus_rdata),
        .bus_rd_rdy(bus_rd_rdy)
    );

    reg_file U_REG_FILE(
        .clk(clk),
        .rstb(rstb),
    
        .wr_en(bus_wr_en),
        .addr(bus_addr),
        .be(bus_be),
        .wr_data(bus_wdata),
        .rd_en(bus_rd_en),
        .rd_rdy(bus_rd_rdy),
        .rd_data(bus_rdata),
    
        .digit_ctrl(digit_ctrl),
        .digit_start_wo(digit_start),
        .digit_stop_wo(digit_stop),
        .digit_status(digit_status)
    );

endmodule
