/*
    2010(C) Tun-Kai Yao | http://www.csie.ncu.edu.tw/~tkyao/
    Modified log:
        20100501
            1. change adder path
*/


module reset_delay(
    rstd_i_clock,
    rstd_i_reset_n,
    rstd_o_reset10u_n
);

input  rstd_i_clock;
input  rstd_i_reset_n;

output rstd_o_reset10u_n;

parameter DT10u = 500000;

reg     r_reset;
reg     [31:0] r_counter; 
wire    [31:0] w_counter_adder;

// Adder for Counter
assign w_counter_adder = r_counter + 1'b1;

// output buffer
assign rstd_o_reset10u_n = r_reset;

// counter process block
always@(posedge rstd_i_clock or negedge rstd_i_reset_n)
begin
    if(!rstd_i_reset_n) begin
        r_reset <= 1'b0;
        r_counter <= 32'b0;
    end
    else begin
        if(r_counter != DT10u) begin
             r_counter <= w_counter_adder;
             r_reset <= 1'b0;
        end
        else begin
             r_reset <= 1'b1;
        end
    end
end



endmodule
