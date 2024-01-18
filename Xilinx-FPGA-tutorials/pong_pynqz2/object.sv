`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/07/2024 12:00:57 PM
// Design Name: 
// Module Name: object
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module object #( 

parameter HRES = 1280,
parameter VRES = 720,
parameter COLOR = 24'h 00FF90,
parameter PADDLE_H = 20
)




    (
        input pixel_clk,
        input rst,
        input fsync, 
        
        input signed [11:0] hpos, 
        input signed [11:0] vpos, 
        
        output [7:0] pixel [0:2] , 
        
        output active 
        
        
    );
    
    
    
    
    localparam OBJ_SIZE = 50; 
    localparam [1:0] DOWN_RIGHT = 2'b00; 
    localparam [1:0] DOWN_LEFT  = 2'b01; 
    localparam [1:0] UP_RIGHT   = 2'b10; 
    localparam [1:0] UP_LEFT    = 2'b11;
    
    localparam VEL = 12; 
    
    
    reg signed [11 : 0  ] lhpos; // left horizontal position 
    reg signed [11 : 0  ] rhpos; //right horizonat position 
    reg signed [11 : 0  ] tvpos; // top vertical position 
    reg signed [11 : 0  ] bvpos; // bottom vertical position
    
    
    reg [1 : 0 ] dir ; // direction of object 
    
    // Calculate the direction when the object hits the four walls 
    
    
    always @(posedge pixel_clk) 
    
    
    begin 
        if(rst) begin 
            dir <= DOWN_RIGHT; 
        end else if (fsync) begin 
            
            if(dir == DOWN_RIGHT) begin 
                if (bvpos == VRES - PADDLE_H) begin 
                    dir <= UP_RIGHT; 
                end else if (rhpos == HRES - 1) begin 
                    dir <= DOWN_LEFT;
                end 
             end else if (dir == UP_RIGHT) begin 
             
                if(tvpos == 0 ) begin 
                    dir <= DOWN_RIGHT; 
                end else if (rhpos == HRES - 1) begin 
                
                    dir <= UP_LEFT; 
                end 
                
               end else if (dir == UP_LEFT) begin 
             
                if(tvpos == 0 ) begin 
                    dir <= DOWN_LEFT; 
                end else if (lhpos == 0) begin 
                
                    dir <= UP_RIGHT; 
                end 
                
                
                
                end else if (dir == DOWN_LEFT) begin 
                    if( bvpos == VRES - PADDLE_H) begin 
                        dir <= UP_LEFT; 
                        
                    end else if (lhpos == 0) begin 
                        dir <= DOWN_RIGHT;
                    end 
                end 
          end 
          
   end 
   
   
   
   
    always @(posedge pixel_clk) 
    
    
    begin 
        if(rst) begin 
            lhpos <= 0 ;
            rhpos <= OBJ_SIZE  - 1; 
            tvpos <= 0; 
            bvpos <= OBJ_SIZE - 1 ;
            
        end else if (fsync) begin 
        
        
            if  (dir == DOWN_RIGHT) begin 
            
                // Still within bound 
                
                if ( ( rhpos + VEL) <= HRES  - 1 && (bvpos + VEL) <= VRES - PADDLE_H) begin 
                    lhpos <= lhpos + VEL ; 
                    rhpos <= rhpos + VEL ; 
                    tvpos <= tvpos + VEL ; 
                    bvpos <= bvpos + VEL ; 
                
                end else if ((rhpos + VEL) > HRES - 1) begin 
                    lhpos <= HRES -  OBJ_SIZE ; 
                    rhpos <= HRES - 1  ; 
                    tvpos <= tvpos + VEL ; 
                    bvpos <= bvpos + VEL ;
                    
               end else if ((bvpos + VEL ) > VRES - PADDLE_H ) begin 
                    tvpos <= VRES - PADDLE_H - OBJ_SIZE + 1; 
                    bvpos <= VRES - PADDLE_H;
                    lhpos <= lhpos + VEL ; 
                    rhpos <= rhpos + VEL ; 
                    
               end  
               
            
            
            
             end  else  if  (dir == UP_RIGHT) begin 
            
                // Still within bound 
                
                if ( ( rhpos + VEL) <= HRES  - 1 && (tvpos - VEL) >= 0 ) begin 
                    lhpos <= lhpos + VEL ; 
                    rhpos <= rhpos + VEL ; 
                    tvpos <= tvpos - VEL ; 
                    bvpos <= bvpos - VEL ; 
                
                end else if ((rhpos + VEL) > HRES - 1) begin 
                    lhpos <= HRES -  OBJ_SIZE ; 
                    rhpos <= HRES - 1  ; 
                    tvpos <= tvpos -  VEL ; 
                    bvpos <= bvpos - VEL ;
                    
               end else if ((tvpos - VEL  ) < 0 )  begin 
                    tvpos <= 0; 
                    bvpos <= OBJ_SIZE - 1 ;
                    lhpos <= lhpos + VEL ; 
                    rhpos <= rhpos + VEL ; 
                    
               end  
               
         
          
          
             end  else  if  (dir == UP_LEFT) begin 
            
                // Still within bound 
                
                if ( ( lhpos - VEL) >= 0   && (tvpos - VEL) >= 0 ) begin 
                    lhpos <= lhpos - VEL ; 
                    rhpos <= rhpos - VEL ; 
                    tvpos <= tvpos - VEL ; 
                    bvpos <= bvpos - VEL ; 
                
                end else if ((lhpos - VEL) < 0 ) begin 
                    lhpos <= 0; 
                    rhpos <= OBJ_SIZE - 1   ; 
                    tvpos <= tvpos - VEL ; 
                    bvpos <= bvpos - VEL ;
                    
               end else if ((tvpos - VEL ) < 0  ) begin 
                    tvpos <= 0; 
                    bvpos <= OBJ_SIZE - 1 ;
                    lhpos <= lhpos - VEL ; 
                    rhpos <= rhpos - VEL ; 
                    
               end           
   
                      
            
              end else if  (dir == DOWN_LEFT) begin 
            
                // Still within bound 
                
                if ( ( lhpos - VEL) >= 00   && (bvpos + VEL) <= VRES - PADDLE_H) begin 
                    lhpos <= lhpos - VEL ; 
                    rhpos <= rhpos - VEL ; 
                    tvpos <= tvpos + VEL ; 
                    bvpos <= bvpos + VEL ; 
                
                end else if ((lhpos - VEL) < 0 ) begin 
                    lhpos <= 0 ; 
                    rhpos <= OBJ_SIZE - 1  ; 
                    tvpos <= tvpos + VEL ; 
                    bvpos <= bvpos + VEL ;
                    
               end else if ((bvpos + VEL ) > VRES - PADDLE_H ) begin 
                    tvpos <= VRES - PADDLE_H - OBJ_SIZE + 1; 
                    bvpos <= VRES - PADDLE_H;
                    lhpos <= lhpos - VEL ; 
                    rhpos <= rhpos - VEL ; 
                    
               end  
            end 
        end 
    end 
    
                                    
            
    assign active = (hpos >= lhpos && hpos <= rhpos && vpos >= tvpos && vpos <= bvpos ) ? 1'b1 : 1'b0 ; 
    
    assign pixel [ 2 ] = (active) ? COLOR [ 23 : 16 ] : 8 'h00; //red 
    assign pixel [ 1 ] = (active) ? COLOR [ 15 : 8 ] : 8 'h00; //green 
    assign pixel [ 0 ] = (active) ? COLOR [ 7 : 0 ] : 8 'h00; //blue 
    
     
    
endmodule
