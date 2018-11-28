
`define SCREEN_WIDTH 176
`define SCREEN_HEIGHT 144

///////* DON'T CHANGE THIS PART *///////
module DE0_NANO(
	CLOCK_50,
	GPIO_0_D,
	GPIO_1_D,
	KEY
);

//=======================================================
//  PARAMETER declarations
//=======================================================
localparam RED = 8'b111_000_00;
localparam GREEN = 8'b000_111_00;
localparam BLUE = 8'b000_000_11;

//=======================================================
//  PORT declarations
//=======================================================

//////////// CLOCK - DON'T NEED TO CHANGE THIS //////////
input 		          		CLOCK_50;

//////////// GPIO_0, GPIO_0 connect to GPIO Default //////////
output 		    [33:0]		GPIO_0_D;
//////////// GPIO_0, GPIO_1 connect to GPIO Default //////////
input 		    [33:0]		GPIO_1_D;
input 		     [1:0]		KEY;

///// PIXEL DATA /////
reg [7:0]	pixel_data_RGB332 = 8'd0;

///// READ/WRITE ADDRESS /////
reg [14:0] X_ADDR;
reg [14:0] Y_ADDR;
wire [14:0] WRITE_ADDRESS;
reg [14:0] READ_ADDRESS; 

assign WRITE_ADDRESS = X_ADDR + Y_ADDR*(`SCREEN_WIDTH);
assign GPIO_0_D[31] = RESULT[1];//blue        
assign GPIO_0_D[33] = RESULT[0];//red
assign GPIO_0_D[29] = 1'b1;

///// VGA INPUTS/OUTPUTS /////
wire 			VGA_RESET;
wire [7:0]	VGA_COLOR_IN;
wire [9:0]	VGA_PIXEL_X;
wire [9:0]	VGA_PIXEL_Y;
wire [7:0]	MEM_OUTPUT;
wire			VGA_VSYNC_NEG;
wire			VGA_HSYNC_NEG;
reg			VGA_READ_MEM_EN;

assign GPIO_0_D[5] = VGA_VSYNC_NEG;
assign VGA_RESET = ~KEY[0];
assign GPIO_0_D[1] = c0_sig;

///// I/O for Img Proc /////
wire [1:0] RESULT;

/* WRITE ENABLE */
reg W_EN;

///////CAMERA INPUTS TO PINS//////
wire PCLK = GPIO_1_D[32];
wire HREF = GPIO_1_D[29];
wire VSYNC = GPIO_1_D[30];

///////* CREATE ANY LOCAL WIRES YOU NEED FOR YOUR PLL *///////
wire c0_sig      ;
wire c1_sig;
wire c2_sig;


///////* INSTANTIATE YOUR PLL HERE *///////
sweet_PLL	sweet_PLL_inst (
	.inclk0 ( CLOCK_50),//( inclk0_sig ),
	.c0 ( c0_sig ), //24
	.c1 ( c1_sig ), //25
	.c2 ( c2_sig )
	);

///////* M9K Module *///////
Dual_Port_RAM_M9K mem(
	.input_data(pixel_data_RGB332),
	.w_addr(WRITE_ADDRESS),
	.r_addr(READ_ADDRESS),
	.w_en(W_EN),
	.clk_W(c2_sig), //c2, next c1
	.clk_R(c1_sig), // DO WE NEED TO READ SLOWER THAN WRITE??
	.output_data(MEM_OUTPUT) 
);

///////* VGA Module *///////
VGA_DRIVER driver (
	.RESET(VGA_RESET),
	.CLOCK(c1_sig), //c1
	.PIXEL_COLOR_IN(VGA_READ_MEM_EN ? MEM_OUTPUT : BLUE),
	.PIXEL_X(VGA_PIXEL_X),
	.PIXEL_Y(VGA_PIXEL_Y),
	.PIXEL_COLOR_OUT({GPIO_0_D[9],GPIO_0_D[11],GPIO_0_D[13],GPIO_0_D[15],GPIO_0_D[17],GPIO_0_D[19],GPIO_0_D[21  ],GPIO_0_D[23]}),
   .H_SYNC_NEG(GPIO_0_D[7]),
   .V_SYNC_NEG(VGA_VSYNC_NEG)
);

///////* Image Processor *///////
IMAGE_PROCESSOR proc(
	.PIXEL_IN(MEM_OUTPUT),
	.CLK(c1_sig),//c1
	.VGA_PIXEL_X(VGA_PIXEL_X),
	.VGA_PIXEL_Y(VGA_PIXEL_Y),
	.VGA_VSYNC_NEG(VGA_VSYNC_NEG),
	.RESULT(RESULT)
);


///////* Update Read Address *///////
always @ (VGA_PIXEL_X, VGA_PIXEL_Y) begin
		READ_ADDRESS = (VGA_PIXEL_X + VGA_PIXEL_Y*`SCREEN_WIDTH);
		if(VGA_PIXEL_X>(`SCREEN_WIDTH-1) || VGA_PIXEL_Y>(`SCREEN_HEIGHT-1))begin
				VGA_READ_MEM_EN = 1'b0;
		end
		else begin
				VGA_READ_MEM_EN = 1'b1;
		end
end

reg cycle = 1'b0;
reg prevHREF;
reg prevVSYNC;

//DOWNSAMPLER////
wire [7:0] DATA;
//assign GPIO_0_D[32]  = clk_24_pll;

assign DATA[7] = GPIO_1_D[15];
assign DATA[6] = GPIO_1_D[14];
assign DATA[5] = GPIO_1_D[13];
assign DATA[4] = GPIO_1_D[10];
assign DATA[3] = GPIO_1_D[9];
assign DATA[2] = GPIO_1_D[8];
assign DATA[1] = GPIO_1_D[12];
assign DATA[0] = GPIO_1_D[11];

reg [15:0] TEMP;

//
//
//
//reg [15:0] TEMP;
//always @(posedge PCLK) begin
//	if (VSYNC & ~prevVSYNC) begin //new frame
//		X_ADDR  = 10'b0;
//		Y_ADDR  = 10'b0;
//		cycle = 1'b0;
//	end
//	else if (~HREF & prevHREF) begin //new row
//		Y_ADDR  = Y_ADDR + 10'b1;
//		X_ADDR  = 10'b0;
//		cycle = 1'b0;
//	end
//	else begin
//		Y_ADDR = Y_ADDR;
//		if (HREF) begin
//			if (cycle == 1'b0) begin
//				TEMP[7:0]= DATA[7:0];
//				W_EN      = 1'b0;
//				X_ADDR    = X_ADDR;
//				cycle   = 1'b1;
//				
//			end
//			else begin
//			    TEMP[15:8] = DATA[7:0];
//			   if(TEMP[7:4] >= 4'b0010 && TEMP[11:8] > 4'b0010 && TEMP[3:0] > 4'b0010)begin
//					pixel_data_RGB332 = 8'b11111111; end
//				else if(TEMP[11:8]>=4'b0011)begin
//					pixel_data_RGB332 = RED; end
//				else if(TEMP[3:0]>=4'b0010)begin
//					pixel_data_RGB332 = BLUE; end
//				else begin
//					pixel_data_RGB332 = 8'b00000000; end
//
//				X_ADDR = X_ADDR + 10'b1;
//				W_EN = 1'b1;
//				cycle = 1'b0;
//			end
//		end
//		else begin
//			X_ADDR = 10'b0;
//		end
//	end
//	prevVSYNC = VSYNC;
//	prevHREF  = HREF;
//end

//
//
//always @(posedge PCLK) begin
//	if (VSYNC && !prevVSYNC) begin
//		X_ADDR = 0;
//		Y_ADDR = 0;
//		cycle = 0;
//		W_EN = 0;
//		pixel_data_RGB332[7:0] = 0;
//	end
//	else if (!HREF && prevHREF) begin  
//		X_ADDR = 0;
//		Y_ADDR = Y_ADDR+1;
//		cycle = 0;
//		W_EN = 0;
//		pixel_data_RGB332[7:0] = 0;
//	end
//	else begin
//		Y_ADDR = Y_ADDR;
//		if (!cycle && HREF) begin
//			cycle = 1'b1;
//			X_ADDR = X_ADDR;
//			TEMP[7:0] = DATA[7:0];
//			W_EN = 0;
//		end
//		else if (cycle && HREF) begin
//			TEMP[15:8] = DATA[7:0];
//			if (TEMP[15:13] >= 3'b100) begin
//				pixel_data_RGB332 = RED;
//			end
//			
//			else if (TEMP[4:3] >= 2'b10) begin
//				pixel_data_RGB332 = BLUE;
//			end
//			else if (TEMP[10:8] >=3'b100) begin
//				pixel_data_RGB332 = 8'b00000000;
//			end
//			else begin
//				pixel_data_RGB332 = 8'b11111111;
//			end
//			cycle = 1'b0;
//			X_ADDR = X_ADDR+1;
//			W_EN = 1;
//			
//		end
//		else begin
//			X_ADDR = 0; 
//		end
//	end
//	prevHREF = HREF;
//	prevVSYNC = VSYNC;
//end


always @(posedge PCLK) begin
	if (VSYNC && !prevVSYNC) begin
		X_ADDR = 0;
		Y_ADDR = 0;
		cycle = 0;
		W_EN = 0;
		pixel_data_RGB332[7:0] = 0;
	end
	else if (!HREF && prevHREF) begin  
		X_ADDR = 0;
		Y_ADDR = Y_ADDR+1;
		cycle = 0;
		W_EN = 0;
		pixel_data_RGB332[7:0] = 0;
	end
	else begin
		Y_ADDR = Y_ADDR;
		if (!cycle && HREF) begin
			cycle = 1'b1;
			X_ADDR = X_ADDR;
			pixel_data_RGB332[1:0] = {GPIO_1_D[10], GPIO_1_D[9]};
			W_EN = 1;
		end
		else if (cycle && HREF) begin
			pixel_data_RGB332[7:5] = {GPIO_1_D[15],GPIO_1_D[14],GPIO_1_D[13]};
			pixel_data_RGB332[4:2] = {GPIO_1_D[8],GPIO_1_D[12],GPIO_1_D[11]};
			cycle = 1'b0;
			X_ADDR = X_ADDR + 1'b1;
			W_EN = 0;
			
		end
		else begin
			X_ADDR = 0; 
		end
	end
	prevHREF = HREF;
	prevVSYNC = VSYNC;
end

//always @ (posedge c2_sig) begin
//		
//		if (X_ADDR <= 88) begin //If X is less than half
//				if (Y_ADDR<=72)begin // And if Y is also less than half
//					Y_ADDR = Y_ADDR+15'd1; // Increment by 1 and color.
//					pixel_data_RGB332 = RED;
//					W_EN = 1'b1;
//				end
//				else begin //If Y is not less than half
//					Y_ADDR = 15'd0; //Then go back to the top
//					W_EN = 1'b0;
//				end
//				X_ADDR = X_ADDR+15'd1; //Increment X
//		end
//		else begin //If X is greater thanhalf.
//				X_ADDR = 15'd0; //Reset X
//				W_EN = 1'b0;
//		end
//		
//end
//
//always @ (posedge c2_sig) begin
//		
//		if (X_ADDR <= 60) begin 
//				X_ADDR = X_ADDR+15'd1;	
//				pixel_data_RGB332 = BLUE;
//				W_EN = 1'b1;
//				
//		end
//		else if ((X_ADDR >= 61) && (X_ADDR <= 120)) begin
//				X_ADDR = X_ADDR+15'd1;	
//				pixel_data_RGB332 = GREEN;
//				W_EN = 1'b1;
//		end
//		else begin
//			if (X_ADDR > 176) begin
//				Y_ADDR = Y_ADDR + 15'd1;
//				X_ADDR = 1'b0;
//			end
//			X_ADDR = X_ADDR+15'd1;	
//			pixel_data_RGB332 = RED;
//			W_EN = 1'b1;
//		end
//		if (Y_ADDR > 144) begin
//			Y_ADDR = 15'd0;
//			W_EN = 1'b0;
//		end
//		
//		
//end

endmodule 