module transmitter(
    input clk,
    input clk_en,
    input rstb,

    input wr_en,
    input [7:0] data,

    output reg tx,
    output reg tx_busy
);

    reg [3:0] bit_sel;
    //typedef enum {IDLE, RUNNING} state;
    localparam IDLE = 0;
    localparam RUNNING = 1;
    
    //state cur_st,nxt_st;
    reg cur_st;
    reg nxt_st;

    reg [9:0] tx_data;

    always @(posedge clk or negedge rstb) begin
        if(~rstb) begin
            cur_st <= IDLE;
        end else begin
            cur_st <= nxt_st;
        end
    end

    always @(posedge clk or negedge rstb) begin
        if(~rstb) begin
            tx_data <= 0;
        end else begin
            case(cur_st) 
                IDLE: begin
                    if(wr_en) begin
                        tx_data <= {1'b1,data,1'b0}; //1'b1: stop bit, 1'b0: start bit
                    end
                end 
                RUNNING: begin
                    if(clk_en) begin
                        tx_data <= {1'b1,tx_data[9:1]};
                    end
                end
            endcase
        end
    end
    

    always @(*) begin
        case(cur_st)
            IDLE: begin
                if(wr_en) begin
                    nxt_st = RUNNING;
                end else begin
                    nxt_st = IDLE;
                end
            end
            RUNNING: begin
                if(bit_sel == 'h9 && clk_en) begin
                    nxt_st = IDLE;
                end else begin
                    nxt_st = RUNNING;
                end
            end
        endcase
    end

    always @(posedge clk or negedge rstb) begin
        if(~rstb) begin
            bit_sel <= 0;
        end else begin
            case(cur_st)
                IDLE:       bit_sel <= 0;
                RUNNING:    begin
                    if(clk_en) begin
                        if(bit_sel == 'h9)begin
                            bit_sel <= 0;
                        end else begin
                            bit_sel <= bit_sel + 1;
                        end
                    end
                end
            endcase
        end
    end

    always @(posedge clk or negedge rstb) begin
        if(~rstb) begin
            tx <= 1;
        end else if(clk_en)begin
            case(cur_st)
                IDLE: begin
                    tx <= 1;
                end
                RUNNING: begin
                    tx <= tx_data[0];
                end
            endcase
        end
    end

    always @(posedge clk or negedge rstb) begin
        if(~rstb) begin
            tx_busy <= 0;
        end else begin
            if(wr_en) begin
                tx_busy <= 1;
            end else if(bit_sel == 9 && clk_en) begin
                tx_busy <= 0;
            end
        end
    end

endmodule
