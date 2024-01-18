module paddle #( 

parameter HRES = 1280,
parameter VRES = 720,


parameter PADDLE_W = 200,
parameter PADDLE_H = 20,
parameter COLOR = 24'h EFE62E
)




    (
        input pixel_clk,
        input rst,
        input fsync, 
        
        input signed [11:0] hpos, 
        input signed [11:0] vpos, 
        
        
        input right, 
        input left, 
        output [7:0] pixel [0:2] , 
        
        output active 
        
        
    );
    
    localparam VEL = 16; 
    
    localparam PUT = 2'h00;
    localparam LEFT = 2'h01;
    localparam RIGHT = 2'h10;
    
    
    reg [0 : 2] right_ff  , left_ff ; 
    
    reg signed [ 11 : 0 ] lhpos; 
    reg signed [ 11 : 0 ] rhpos; 
    reg signed [ 11 : 0 ] tvpos; 
    reg signed [ 11 : 0 ] bvpos; 
    
    
    reg [ 1 : 0 ] dir; 
    
    reg register_right, register_left ; 
    
    
    always @(posedge pixel_clk) 
    
    begin 
        if(rst) begin 
            dir <= PUT ; 
            register_right <= 1'b0; 
            register_left <= 1'b0;
        end else begin 
            if (fsync) begin 
                if (register_right) begin 
                    dir <= RIGHT ; 
                end else if (register_left) begin 
                    dir <= LEFT ; 
                end else begin 
                    dir <= PUT ; 
                end 
                
                register_right <= 1'b0;
                register_left  <= 1'b0 ;
            end else begin 
                if (( ~register_right ) && (~register_left)) begin 
                
                    if (right_ff [2] ) begin 
                        register_right <= 1'b1; 
                    end else if (left_ff [ 2 ] ) begin 
                        register_left <= 1'b1; 
                    end 
               end 
           end 
       end 
       
       right_ff <= {right, right_ff [ 0 : 1 ] } ; 
       left_ff <= {left, left_ff [ 0 : 1 ] } ; 
       
end                     


always @ (posedge pixel_clk) 
begin 


    if (rst) begin 
        lhpos <= 0 ;
        rhpos <= PADDLE_W - 1; 
        tvpos <= VRES - PADDLE_H; 
        bvpos <= VRES - 1 ; 
        
    end else begin 
        if (fsync) begin
            if (dir == RIGHT) begin 
                // Move right x pixel 
                if (( rhpos + VEL) <= HRES - 1 ) begin 
                    lhpos <= lhpos + VEL ; 
                    rhpos <= rhpos + VEL ; 
                end else begin 
                // Right Bound 
                    lhpos <= HRES - PADDLE_W;
                    rhpos <= HRES - 1; 
                end 
           end else if ( dir == LEFT) begin 
                if (( lhpos - VEL) >= 0 ) begin 
                    lhpos <= lhpos - VEL ; 
                    rhpos <= rhpos - VEL; 
                end else begin 
                    lhpos <= 0 ; 
                    rhpos  <= PADDLE_W - 1; 
                end 
           end 
       end 
   end 
end 


   assign active = (hpos >= lhpos && hpos <= rhpos && vpos >= tvpos && vpos <= bvpos ) ? 1'b1 : 1'b0 ; 
    
    assign pixel [ 2 ] = (active) ? COLOR [ 23 : 16 ] : 8 'h00; //red 
    assign pixel [ 1 ] = (active) ? COLOR [ 15 : 8 ] : 8 'h00; //green 
    assign pixel [ 0 ] = (active) ? COLOR [ 7 : 0 ] : 8 'h00; //blue 
    
    
                         
            
endmodule