/**************************************************
* protocal:
    * Write (3 cycles) and Read (2 cycles)
    * cycle 0: command; 0: write, 1: read
    * cycle 1: addr
    * cycle 2: wdata if write.
***************************************************/
module uart_cmder (
    input clk,
    input rstb,

    output logic uart_wr_en,
    output logic [7:0] uart_din,
    input uart_tx_busy,
    input uart_rx_rdy,
    output logic uart_rx_rdy_clr,
    input [7:0] uart_dout,

    output logic bus_wr_en,
    output logic [3:0] bus_be,
    output logic [15:0] bus_addr,
    output logic [31:0] bus_wdata,

    output logic bus_rd_en,
    input [31:0] bus_rdata,
    input bus_rd_rdy
);

parameter WR = 4'h0;
parameter RD = 4'h1;
parameter INVALID = 4'hF;

typedef enum bit [1:0] {IDLE=2'b00, ADDR=2'b01, WDATA=2'b10,RDATA=2'b11} enum_st;

enum_st cur_state;
enum_st next_state;

logic [3:0] bus_cmd;

wire uart_got_byte = uart_rx_rdy & ~uart_rx_rdy_clr;


always @(posedge clk or negedge rstb) begin
    if(~rstb) begin
        cur_state <= IDLE;
    end else begin
        cur_state <= next_state;
    end
end

always @(*) begin
    if(~rstb) begin
        next_state = IDLE;
    end else if(cur_state == IDLE || cur_state == ADDR || cur_state == WDATA) begin
        if(uart_got_byte) begin
            if(cur_state == IDLE) begin
                if(uart_dout == 0 || uart_dout == 1) begin
                    next_state = ADDR;
                end else begin
                    next_state = IDLE;
                end
            end else if(cur_state == ADDR) begin
                if(bus_cmd == WR) next_state = WDATA;
                else next_state = RDATA;
            end else if(cur_state == WDATA) begin
                next_state = IDLE;
            end else begin
                next_state = IDLE;
            end
        end else begin
            next_state = cur_state;
        end
    end else begin //RDATA
        if(bus_rd_rdy) next_state = IDLE;
        else next_state = RDATA;
    end
end

always @(posedge clk or negedge rstb) begin
    if(~rstb) begin
        bus_cmd <= INVALID;
    end else if(uart_got_byte && cur_state == IDLE) begin
        if(uart_dout == 0)      bus_cmd <= WR;
        else if(uart_dout == 1) bus_cmd <= RD;
        else                    bus_cmd <= INVALID;
    end
end

always @(posedge clk or negedge rstb) begin
    if(~rstb) begin
        bus_addr <= 0;
        bus_be <= 0;
    end else if(uart_got_byte && cur_state == ADDR) begin
        bus_addr <= {8'h0,uart_dout[7:2],2'h0};
        bus_be <= uart_dout[1:0] == 0 ? 1 : uart_dout[1:0] == 1 ? 2: uart_dout[1:0] == 2 ? 4 : 8;
    end
end

always @(posedge clk or negedge rstb) begin
    if(~rstb) begin
        bus_wr_en <= 0;
        bus_wdata <= 0;
    end else if(uart_got_byte && cur_state == WDATA) begin
        bus_wr_en <= 1;
        bus_wdata <= bus_be[0] ? {24'h0,uart_dout} : bus_be[1] ? {16'h0,uart_dout,8'h0} : 
                     bus_be[2] ? {8'h0,uart_dout,16'h0} : {uart_dout,24'h0};
    end else begin
        bus_wr_en <= 0;
    end
end

always @(posedge clk or negedge rstb) begin
    if(~rstb) begin
        bus_rd_en <= 0;
    end else if(uart_got_byte && cur_state == ADDR && bus_cmd == RD) begin
        bus_rd_en <= 1;
    end else begin
        bus_rd_en <= 0;
    end
end

always @(posedge clk or negedge rstb) begin
    if(~rstb) begin
        uart_rx_rdy_clr <= 0;
    end else if(uart_rx_rdy)begin
        uart_rx_rdy_clr <= 1;
    end else begin
        uart_rx_rdy_clr <= 0;
    end
end

always @(posedge clk or negedge rstb) begin
    if(~rstb) begin
        uart_wr_en <= 0;
        uart_din <= 0;
    end else if(bus_rd_rdy && cur_state == RDATA)begin
        uart_wr_en <= 1;
        uart_din <= bus_be[0] ? bus_rdata[7:0] : bus_be[1] ? bus_rdata[15:8] :
                    bus_be[2] ? bus_rdata[23:16] : bus_rdata[31:24];
    end else begin
        uart_wr_en <= 0;
    end
end


//`ifndef SIM
//ila_uart U_ILA_UART(
//    .clk(clk),
//    .probe0(uart_wr_en),
//    .probe1(uart_din),
//    .probe2(uart_rx_rdy),
//    .probe3(uart_rx_rdy_clr),
//    .probe4(uart_dout),
//    .probe5(bus_wr_en),
//    .probe6(bus_rd_en),
//    .probe7(bus_addr),
//    .probe8(bus_wdata),
//    .probe9(bus_rdata),
//    .probe10(bus_rd_rdy)
//);
//`endif

endmodule
