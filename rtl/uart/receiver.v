module receiver(
    input clk,
    input clk_en,
    input rstb,

    input rx,

    output reg rx_valid,
    output [7:0] data
);

    //typedef enum {IDLE, RUNNING} state;
    localparam IDLE = 0;
    localparam RUNNING = 1;
    
    reg cur_st;
    reg nxt_st;
    reg [8:0] rx_data;

    reg [3:0] bit_sel;
    reg [3:0] sample;

    assign data = rx_data[8:1];
    
    always @(posedge clk or negedge rstb) begin
        if(~rstb) begin
            cur_st <= IDLE;
        end else begin
            cur_st <= nxt_st;
        end
    end

    always @(*) begin
        case(cur_st)
            IDLE: begin
                if(!rx) begin
                    nxt_st = RUNNING;
                end else begin
                    nxt_st = IDLE;
                end
            end
            RUNNING: begin
                if(bit_sel == 'h9 && sample == 'h9) begin
                    nxt_st = IDLE;
                end else begin
                    nxt_st = RUNNING;
                end
            end
            default: begin
                nxt_st = IDLE;
            end
        endcase
    end

    always @(posedge clk or negedge rstb) begin
        if(~rstb) begin
            bit_sel <= 0;
        end else if(clk_en) begin
            case(cur_st)
                IDLE:       bit_sel <= 0;
                RUNNING: begin
                    if(sample == 'hf)begin
                        if(bit_sel == 'h8 && sample == 'h8) begin
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
            sample <= 0;
        end else if(clk_en) begin
            case(cur_st)
                IDLE: sample <= 0;
                RUNNING: sample <= sample + 1;
            endcase
        end
    end

    always @(posedge clk or negedge rstb) begin
        if(~rstb) begin
            rx_data <= 0;
            rx_valid <= 0;
        end else begin
            if(clk_en & sample == 'h8)begin
                case(cur_st)
                    IDLE: begin
                        rx_data <= 0;
                        rx_valid <= 0;
                    end
                    RUNNING: begin
                        rx_data <= {rx,rx_data[8:1]};
                        if(bit_sel == 'h8) begin
                            rx_valid <= 1;
                        end else begin
                            rx_valid <= 0;
                        end
                    end
                endcase
            end else begin
                rx_valid <= 0;
            end
        end
    end

endmodule
