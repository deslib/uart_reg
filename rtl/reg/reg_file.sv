module reg_file(
    input clk,
    input rstb,

    input wr_en,
    input [15:0] addr,
    input [3:0] be,
    input [31:0] wr_data,
    input rd_en,
    output logic rd_rdy,
    output logic [31:0] rd_data,

    output logic [7:0] digit_ctrl,
    output logic digit_start_wo,
    output logic digit_stop_wo,
    input [7:0] digit_status
);

    always @(posedge clk or negedge rstb) begin
        if(~rstb) begin
            digit_ctrl <= 0;
        end else begin
            if(wr_en) begin
                case(addr)
                    0: begin
                        digit_ctrl <= wr_data[7:0];
                    end
                endcase
            end
        end
    end

    always @(posedge clk or negedge rstb) begin
        if(~rstb) begin
            digit_start_wo <= 0;
        end else begin
            if(wr_en) begin
                case(addr)
                    0: begin
                        digit_start_wo <= wr_data[8];
                        digit_stop_wo <= wr_data[16];
                    end
                endcase
            end else begin
                digit_start_wo <= 0;
                digit_stop_wo <= 0;
            end
        end
    end

    always @(posedge clk or negedge rstb) begin
        if(~rstb) begin
            rd_data <= 0;
        end else begin
            if(rd_en) begin
                case(addr)
                    0: begin
                        rd_data <= {digit_status,7'h0,digit_stop_wo,7'h0,digit_start_wo,digit_ctrl};
                    end
                    default: rd_data <= 0;
                endcase
            end
        end
    end

    always @(posedge clk or negedge rstb) begin
        if(~rstb) begin
            rd_rdy <= 0;
        end else begin
            rd_rdy <= rd_en;
        end
    end

endmodule
