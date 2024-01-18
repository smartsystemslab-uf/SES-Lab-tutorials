 // HDMIT Transmit + clock video timing 
 
 
 
 module    hdmi_transmit ( 
    
        input                  clk125,          
        input [7 : 0 ] pixel [ 0 : 2],           
        
        
        // Shared video interface to the rest of the system 
        
        output pixel_clk      , 
        output rst            ,
        output active         ,
        output fsync          ,
        
        
        
        
        
        output reg signed [11:0] hpos, 
        output reg signed [11:0] vpos, 
        
        output tmds_tx_clk_p  ,  
        output tmds_tx_clk_n  ,
    
        output [2 : 0] tmds_tx_data_p , 
        output [2 : 0] tmds_tx_data_n 
        
     ); 
     
     
     
     wire serdes_clk ; 
     
     reg [ 7 : 0 ] rstcnt ; 
     
     wire locked ; 
     
     reg active_ff; 
     
     wire hsync, hblank, vsync, vblank ; 
     
     wire [1:0] ctl [0 : 2] ;
     wire [9 : 0 ] tmds_data [0 : 2] ;
     
     
     mmcm_0 mmcm_0_inst ( 
            .clk_in1        (clk125), 
            .clk_out1       (pixel_clk),
            .clk_out2       (serdes_clk),
            .locked         (locked) 
            
            ); 
     
     always @(posedge pixel_clk or negedge locked) 
     begin 
        if(~locked) begin  
            rstcnt <= 0 ;
        end else begin 
            if (rstcnt != 8'hff) begin 
                rstcnt <= rstcnt + 1 ; 
            end 
        end 
     end 
     assign rst = (rstcnt  == 8'hff) ? 1'b0 : 1'b1 ;
     
     
     video_timing video_timing_inst ( 
     
        .clk        (pixel_clk),
        .clken      (1'b1),
        .gen_clken  (1'b1),
        .sof_state  (1'b0),
        .hsync_out  (hsync),
        .hblank_out (hblank),
        .vsync_out  (vsync),
        .vblank_out (vblank),
        .active_video_out   (active), 
        .resetn ( ~rst),
        .fsync_out (fsync) 
     
     );
     
     
     
     always @(posedge pixel_clk) 
    
    
     begin 
        active_ff <= active; 
        
        if (rst || ~active) begin 
        
            hpos <= 0; 
        end else begin 
        
            hpos <= hpos + 1; 
        end 
        
        
        if (rst || fsync) begin 
            vpos <= 0 ; 
            
        end else if (~active && active_ff) begin 
            vpos <= vpos + 1; 
        end 
     end 
    
    
    assign ctl [0] = {vsync, hsync};
    assign ctl [1] = 2'b00; 
    assign ctl [2] = 2'b00; 
    
    
    generate 
        genvar i ; 
        
        for (i = 0; i < 3 ; i = i + 1) begin 
        
            tmds_encode tmds_encode_inst ( 
                .pixel_clk  (pixel_clk),
                .rst        (rst),
                .ctl        (ctl [i]), 
                .active     (active), 
                .pdata      (pixel [i]), 
                .tmds_data  (tmds_data[i])
            
            
            
            );
            
            tmds_oserdes tmds_oserdes_inst ( 
                .pixel_clk      (pixel_clk),
                .serdes_clk     (serdes_clk),
                .rst            (rst),
                .tmds_data      (tmds_data[i]),
                .tmds_serdes_p  (tmds_tx_data_p [ i]), 
                .tmds_serdes_n  (tmds_tx_data_n[i])
                );
            
         end 
         
      endgenerate 
      
      
      tmds_oserdes tmds_oserdes_clock ( 
                .pixel_clk      (pixel_clk),
                .serdes_clk     (serdes_clk),
                .rst            (rst),
                .tmds_data      (10'b1111100000),
                .tmds_serdes_p  (tmds_tx_clk_p ), 
                .tmds_serdes_n  (tmds_tx_clk_n)
                );    
    
    
    
    
    
  endmodule 
     
     