//7 SEG DISPLAY------------------------------------------------------------------------------------------
`timescale 1ns / 1ps

module sev_seg(

input clk,
input [3:0] s_hourten, s_hour, s_minten, s_min,
output reg[3:0] an, //4 places display , or 7seg selector! 'an' from const.
output reg[6:0] seg //7 segment display # 'seg' from const.

    );
    
//**************MEMORY REGS*******************
reg[1:0] current_place = 0; //are we in hourten,hr,mint, min? (0-3)
reg[6:0] seg_out [3:0]; //we will use 'curr_place' for 3-0 

reg [18:0] count = 0; //timer for illusion
parameter max_count = 500000; //500,000/100Mhz -> 5ms

//***CONNECT 7seg to CLK module*************
wire [3:0] four_b_data [3:0]; //size 4b will array 0-4 ea rep hourten,hr,mtn,min..
assign four_b_data[0] = s_min;
assign four_b_data[1] = s_minten;
assign four_b_data[2] = s_hour; 
assign four_b_data[3] = s_hourten;

always @(posedge clk) begin
    if(count <= max_count) 
        begin
            count <= count + 1;
        end
    else     
        begin
            current_place <= current_place + 1;
            count <= 0;
        
        end

    case(four_b_data[current_place])
        4'b0000: seg_out[current_place] <= 7'b1000000;
        4'b0001: seg_out[current_place] <= 7'b1111001;
        4'b0010: seg_out[current_place] <= 7'b0100100;
        4'b0011: seg_out[current_place] <= 7'b0110000;
        4'b0100: seg_out[current_place] <= 7'b0011001;
        4'b0101: seg_out[current_place] <= 7'b0010010;
        4'b0110: seg_out[current_place] <= 7'b0000010;
        4'b0111: seg_out[current_place] <= 7'b1111000;
        4'b1000: seg_out[current_place] <= 7'b0000000;
        4'b1001: seg_out[current_place] <= 7'b0011000;
        default:seg_out[current_place] <= 7'b0000000;
    endcase    

case(current_place)
    0:
        begin
            an<= 4'b1110;
            seg <= seg_out[0];
        end
    
    1:
        begin
            an<= 4'b1101;
            seg <= seg_out[1];
        end
    2:
        begin
            an<= 4'b1011;
            seg <= seg_out[2];
        end
    3:
        begin
            an<= 4'b0111;
            seg <= seg_out[3];
        end
endcase
end //end always    
endmodule

//***************************************************************************
