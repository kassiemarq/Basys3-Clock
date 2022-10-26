//clock----------------------------------------------------------------------------------------------------
`timescale 1ns / 1ps

module clock(

input clk,

//REGULAR CLOCK push button
input rst, //regular clock mode -> PUSH BUTTON

///push buttons to set alarm clocks
input btnC, btnU, btnD, btnR, btnL,

input [3:0] sw,

output [6:0] seg, 
output [3:0] an,
output reg [3:0] led //1b
    );

//**************MEMORY REGS*******************

//1second counter, Basys3 - 100MHz
reg[31:0] count = 0;
parameter max_count = 1000000; //1562500; 

//count clock logic
reg [5:0] mins, secs = 0; 
reg [5:0] hours = 12;
//count alarm clock logic 
reg [5:0] a_mins, a_secs, a_hours = 0;
//og clock vals before alarm setting mode
reg [5:0] og_hours, og_secs, og_mins = 0;

//CLK regs - set to 7 seg displays 
reg [3:0] c_hourten, c_hour, c_minten, c_min = 0; 

reg [0:0] current_bit = 0; //when setting clock, this chooses between setting hr or min



//inst seven seg display mod
sev_seg display(.clk(clk), .s_hourten(c_hourten), .s_hour(c_hour), .s_minten(c_minten), .s_min(c_min) ,.an(an), .seg(seg)) ;

//Clock Modes
parameter normal_mode = 2'b00; 
parameter set_alarm_clock = 2'b01;
parameter alarm_mode = 2'b10;
reg [1:0] current_mode = normal_mode; //default


always @(posedge clk) begin
    //**mode states 
    led = 4'b0000;
    
    case(current_mode)
        normal_mode:
            begin
            if(a_hours == hours && a_mins == mins)
                                    begin
                                        led = 4'b1111;
                                    end
           else
                                    begin
                                        led = 4'b0000;
                                    end
                if(btnC) //middle button 
                    begin
                        count <= 0;
                        secs <= 0;
                        current_bit <= 0; 
                        current_mode <= set_alarm_clock;
                    end     
                if (count < max_count)
                    begin
                        count <= count + 1;
                    end
                else
                    begin
                        count <= 0;
                        secs <= secs + 1;
                        
                        //save og time
                        og_secs = secs;
                        og_mins = mins;
                        og_hours = hours;
                    end
            end//normal mode
            
        set_alarm_clock:
            begin
                count <= 0;
                secs <= 0;
                current_bit <= 0; 
                a_mins <= mins;
                a_hours <= hours;
                
                if(btnC) //if middle button pressed again, go back to normal mode 
                    begin
                        current_mode = normal_mode;
                    end
                
                
                if(count < 25000000)
                    begin
                        count <= count + 1;
                    end
                    
                else
                    begin
                        if(btnU) //up button -> inc minutes
                            begin
                                mins <= mins + 1;
                            end
                       if(btnD) //down button -> dec minutes
                           begin
                                 if(mins > 0)
                                    mins <= mins - 1;
                                    
                         end
                         
                      if(btnL)
                            begin
                                 hours <= hours + 1;
                            end
                      if(btnR)
                            begin
                                   if(hours > 1)
                                                begin
                                                    hours <= hours - 1;
                                                    
                                                end
                            end
                      
                     
                      
                      
                    end//end else
               
               //trigger FSM
               if(sw == 4'b0001)
                begin
                    //alarm_mode is on
                    current_mode = alarm_mode;
                end
               
               else
                begin
                    //stay in set_alarm_clk
                    current_mode = set_alarm_clock;
                end
                
            end//set alarm clock
        
        
        alarm_mode: //switch is ON! need LED
            begin
                if(sw == 4'b0000)
                    begin
                        current_mode = normal_mode;
                    end
               
               if(sw == 4'b0001)
                    begin
                                secs = og_secs;
                                mins = og_mins;
                                hours = og_hours;
                                
                                
                    end  //end else
            end//alarm mode
        
    endcase

    //**REGULAR clock count logic
    if(secs >= 60)
        begin
            secs <= 0;
            mins <= mins + 1;
        end
    if(mins >= 60)
        begin
            mins <= 0;
            hours <= hours + 1;
        end
    
    if(hours == 13) 
        begin
            hours <= 1; //rst hours
        end    
        
    //**set outputs to display**
    c_min <= mins % 10; //take remainder / 10 since LSB of min
    c_minten <= mins / 10; //take int math /10 since MSB of min
    if(hours < 10) //0-9
        begin
            c_hourten <= 0;
            c_hour <= hours % 10; 
        end
    else //10-12
        begin
            c_hourten <= hours / 10;
            c_hour <= hours % 10; 
        end


    
end//end posedge clk
endmodule//clk mod

//***************************************************************************
