`define SCREEN_WIDTH 176
`define SCREEN_HEIGHT 144
`define NUM_BARS 3
`define BAR_HEIGHT 48

module IMAGE_PROCESSOR (
	PIXEL_IN,
	CLK,
	VGA_PIXEL_X,
	VGA_PIXEL_Y,
	VGA_VSYNC_NEG,
	RESULT
);


//=======================================================
//  PORT declarations
//=======================================================
input	[7:0]	PIXEL_IN;
input			CLK;
input [9:0]	VGA_PIXEL_X;
input	[9:0]	VGA_PIXEL_Y;
input			VGA_VSYNC_NEG;

output reg [2:0] RESULT;

reg [15:0] BLUECOUNT = 0;
reg [15:0] BLUECOUNTTEMP = 0;
reg [15:0] REDCOUNT = 0;
reg [15:0] REDCOUNTTEMP = 0;
reg [15:0] BLUECOUNTTOP = 0;
reg [15:0] REDCOUNTTOP = 0;
reg [15:0] REDCOUNTTOPMID = 0;
reg [15:0] BLUECOUNTTOPMID = 0;
reg [15:0] REDCOUNTMID = 0;
reg [15:0] BLUECOUNTMID = 0;
reg [15:0] REDCOUNTBOTMID = 0;
reg [15:0] BLUECOUNTBOTMID = 0;
reg [15:0] BLUECOUNTBOTTOM = 0;
reg [15:0] REDCOUNTBOTTOM = 0;
reg [15:0] REDCOUNTTEMPTOP = 0;
reg [15:0] BLUECOUNTTEMPTOP = 0;
reg [15:0] REDCOUNTTEMPTOPMID = 0;
reg [15:0] BLUECOUNTTEMPTOPMID = 0;
reg [15:0] REDCOUNTTEMPMID = 0;
reg [15:0] BLUECOUNTTEMPMID = 0;
reg [15:0] REDCOUNTTEMPBOTMID = 0;
reg [15:0] BLUECOUNTTEMPBOTMID = 0;
reg [15:0] REDCOUNTTEMPBOTTOM = 0;
reg [15:0] BLUECOUNTTEMPBOTTOM = 0;

always @ (posedge CLK, negedge VGA_VSYNC_NEG) begin
		if (!VGA_VSYNC_NEG) begin
			if ((BLUECOUNTTEMP) > (REDCOUNTTEMP) && (BLUECOUNTTEMP) > 16'd17000) begin
				if (BLUECOUNTTEMPTOPMID>BLUECOUNTTEMPTOP && BLUECOUNTTEMPMID>BLUECOUNTTEMPTOPMID && 
				BLUECOUNTTEMPBOTMID>BLUECOUNTTEMPMID && BLUECOUNTTEMPBOTTOM>BLUECOUNTTEMPBOTMID) begin //&& BLUECOUNTTEMPTOP<BLUECOUNTTEMPBOTTOM 
					RESULT = 3'b001; //blue triangle
				end
				else if (BLUECOUNTTEMPTOP<BLUECOUNTTEMPTOPMID && BLUECOUNTTEMPTOP<BLUECOUNTTEMPMID && 
				BLUECOUNTTEMPBOTTOM<BLUECOUNTTEMPMID && BLUECOUNTTEMPBOTTOM<BLUECOUNTTEMPBOTMID) begin
					RESULT = 3'b010; //blue diamond
				end
				else begin
					RESULT = 3'b011; //blue square
				end
			end
			else if ((REDCOUNTTEMP) > (BLUECOUNTTEMP) && (REDCOUNTTEMP) > 16'd17000) begin
				if (REDCOUNTTEMPTOPMID>REDCOUNTTEMPTOP && REDCOUNTTEMPMID>REDCOUNTTEMPTOPMID && 
				REDCOUNTTEMPBOTMID>REDCOUNTTEMPMID && REDCOUNTTEMPBOTTOM>REDCOUNTTEMPBOTMID) begin //&& REDCOUNTTEMPTOP<REDCOUNTTEMPBOTTOM 
					RESULT = 3'b100; //red triangle
				end
				else if (REDCOUNTTEMPTOP<REDCOUNTTEMPTOPMID && REDCOUNTTEMPTOP<REDCOUNTTEMPMID && 
				REDCOUNTTEMPBOTTOM<REDCOUNTTEMPMID && REDCOUNTTEMPBOTTOM<REDCOUNTTEMPBOTMID) begin
					RESULT = 3'b101; //red diamond
				end
				else begin
					RESULT = 3'b110; //red square
				end
			end
			else begin
				RESULT = 3'b000; //no color detected
			end
			BLUECOUNT = 0;
			REDCOUNT = 0;
			BLUECOUNTTOP = 0;
			REDCOUNTTOP = 0;
			REDCOUNTTOPMID = 0;
			BLUECOUNTTOPMID = 0;
			BLUECOUNTMID = 0;
			REDCOUNTMID = 0;
			BLUECOUNTBOTMID = 0;
			REDCOUNTBOTMID = 0;
			BLUECOUNTBOTTOM = 0;
			REDCOUNTBOTTOM = 0;
		end
		else begin
			RESULT = RESULT;
			if (PIXEL_IN[7:6] > PIXEL_IN[1:0] && PIXEL_IN[7:6] > PIXEL_IN[4:3]) begin
				REDCOUNT = REDCOUNT + 1'b1;
			end
			else if (PIXEL_IN[1:0] > PIXEL_IN[7:6] && PIXEL_IN[1:0] > PIXEL_IN[4:3]) begin
				BLUECOUNT = BLUECOUNT + 1'b1;
			end
			REDCOUNTTEMP = REDCOUNT;
			BLUECOUNTTEMP = BLUECOUNT;
			if (VGA_PIXEL_Y == 10'd42 && (VGA_PIXEL_X>=10'd48 && VGA_PIXEL_X<=10'd128))begin
				if (PIXEL_IN[7:6] > PIXEL_IN[1:0] && PIXEL_IN[7:6] > PIXEL_IN[4:3]) begin
					REDCOUNTTOP = REDCOUNTTOP + 1'b1;
				end
				else if (PIXEL_IN[1:0] > PIXEL_IN[7:6] && PIXEL_IN[1:0] > PIXEL_IN[4:3]) begin
					BLUECOUNTTOP = BLUECOUNTTOP + 1'b1;
				end
				REDCOUNTTEMPTOP = REDCOUNTTOP;
				BLUECOUNTTEMPTOP = BLUECOUNTTOP;
			end
			else if (VGA_PIXEL_Y == 10'd57 && (VGA_PIXEL_X>=10'd48 && VGA_PIXEL_X<=10'd128))begin
				if (PIXEL_IN[7:6] > PIXEL_IN[1:0] && PIXEL_IN[7:6] > PIXEL_IN[4:3]) begin
					REDCOUNTTOPMID = REDCOUNTTOPMID + 1'b1;
				end
				else if (PIXEL_IN[1:0] > PIXEL_IN[7:6] && PIXEL_IN[1:0] > PIXEL_IN[4:3]) begin
					BLUECOUNTTOPMID = BLUECOUNTTOPMID + 1'b1;
				end
				REDCOUNTTEMPTOPMID = REDCOUNTTOPMID;
				BLUECOUNTTEMPTOPMID = BLUECOUNTTOPMID;
			end
			else if (VGA_PIXEL_Y == 10'd72 && (VGA_PIXEL_X>=10'd48 && VGA_PIXEL_X<=10'd128)) begin
				if (PIXEL_IN[7:6] > PIXEL_IN[1:0] && PIXEL_IN[7:6] > PIXEL_IN[4:3]) begin
					REDCOUNTMID = REDCOUNTMID + 1'b1;
				end
				else if (PIXEL_IN[1:0] > PIXEL_IN[7:6] && PIXEL_IN[1:0] > PIXEL_IN[4:3]) begin
					BLUECOUNTMID = BLUECOUNTMID + 1'b1;
				end
				REDCOUNTTEMPMID = REDCOUNTMID;
				BLUECOUNTTEMPMID = BLUECOUNTMID;
			end
			else if (VGA_PIXEL_Y == 10'd87 && (VGA_PIXEL_X>=10'd48 && VGA_PIXEL_X<=10'd128)) begin
				if (PIXEL_IN[7:6] > PIXEL_IN[1:0] && PIXEL_IN[7:6] > PIXEL_IN[4:3]) begin
					REDCOUNTBOTMID = REDCOUNTBOTMID + 1'b1;
				end
				else if (PIXEL_IN[1:0] > PIXEL_IN[7:6] && PIXEL_IN[1:0] > PIXEL_IN[4:3]) begin
					BLUECOUNTBOTMID = BLUECOUNTBOTMID + 1'b1;
				end
				REDCOUNTTEMPBOTMID = REDCOUNTBOTMID;
				BLUECOUNTTEMPBOTMID = BLUECOUNTBOTMID;
			end
			else if (VGA_PIXEL_Y == 10'd102 && (VGA_PIXEL_X>=10'd48 && VGA_PIXEL_X<=10'd128)) begin
				if (PIXEL_IN[7:6] > PIXEL_IN[1:0] && PIXEL_IN[7:6] > PIXEL_IN[4:3]) begin
					REDCOUNTBOTTOM = REDCOUNTBOTTOM + 1'b1;
				end
				else if (PIXEL_IN[1:0] > PIXEL_IN[7:6] && PIXEL_IN[1:0] > PIXEL_IN[4:3]) begin
					BLUECOUNTBOTTOM = BLUECOUNTBOTTOM + 1'b1;
				end
				REDCOUNTTEMPBOTTOM = REDCOUNTBOTTOM;
				BLUECOUNTTEMPBOTTOM = BLUECOUNTBOTTOM;
			end
		end
end


endmodule

//`define SCREEN_WIDTH 176
//`define SCREEN_HEIGHT 144
//`define NUM_BARS 3
//`define BAR_HEIGHT 48
//
//module IMAGE_PROCESSOR (
//	PIXEL_IN,
//	CLK,
//	VGA_PIXEL_X,
//	VGA_PIXEL_Y,
//	VGA_VSYNC_NEG,
//	RESULT,
//);
//
//
////=======================================================
////  PORT declarations
////=======================================================
//input	[7:0]	PIXEL_IN;
//input 		CLK;
//
//input [9:0] VGA_PIXEL_X;
//input [9:0] VGA_PIXEL_Y;
//input			VGA_VSYNC_NEG;
//
//output reg [3:0] RESULT;
//
//reg [15:0] REDCOUNT;
//reg [15:0] BLUECOUNT;
//reg lastSYNC;
//
//reg [15:0] lastRowCount;
//reg [15:0] rowCount;
//reg [1:0] TEMP_SHAPE;
////output reg [1:0] SHAPE; //11 triangle. 10 square, 01 diamond
//
//reg [15:0] row1;
//reg [15:0] row2;
//reg [15:0] row3;
//
//reg[2:0] count;
//
//always @ (posedge CLK) begin 
//
//	if (!VGA_VSYNC_NEG && lastSYNC) begin //each frame 
//		 //RESULT = 2'b11;
//		if (BLUECOUNT >REDCOUNT && BLUECOUNT >16'd25000)begin 
//			RESULT[1:0] = 2'b10;
//			RESULT[3:2] = TEMP_SHAPE;
//		end
//		else if (REDCOUNT > BLUECOUNT && REDCOUNT > 16'd25000) begin 
//			RESULT[1:0] = 2'b01;
//			RESULT[3:2] = TEMP_SHAPE;
//		end
//		else begin 
//			RESULT[1:0] = 2'b00;
//			RESULT[3:2] = 2'b00;
//		end
//		TEMP_SHAPE = 2'b00;
//		BLUECOUNT = 16'd0;
//		REDCOUNT = 16'd0;
//		rowCount = 16'd0;
//		lastRowCount = 16'd0;
//		count = 3'b101;
//	end
//	
//	
//	/*if (!VGA_VSYNC_NEG && lastSYNC) begin //each frame 
//		 //RESULT = 2'b11;
//		if (BLUECOUNT >REDCOUNT && BLUECOUNT >16'd17000)begin 
//			RESULT = 2'b10;
//			if (row1<row2 && row2<row3) TEMP_SHAPE = 2'b11;
//			else if (row1<row2 && row3<row2) TEMP_SHAPE = 2'b01;
//			else if (row2-16'd5< row1 < row2+16'd5 && row2-16'd5< row3 < row2+16'd5) TEMP_SHAPE = 2'b10;
//			else TEMP_SHAPE = 2'b00;
//			SHAPE = TEMP_SHAPE;
//		end
//		else if (REDCOUNT > BLUECOUNT && REDCOUNT > 16'd17000) begin 
//			RESULT = 2'b01;
//			if (row1<row2 && row2<row3) TEMP_SHAPE = 2'b11;
//			else if (row1<row2 && row3<row2) TEMP_SHAPE = 2'b01;
//			else if (row2-16'd5< row1 < row2+16'd5 && row2-16'd5< row3 < row2+16'd5) TEMP_SHAPE = 2'b10;
//			else TEMP_SHAPE = 2'b00;
//			SHAPE = TEMP_SHAPE;
//		end
//		else begin 
//			RESULT = 2'b00;
//			SHAPE = 2'b00;
//		end
//		TEMP_SHAPE = 2'b00;
//		BLUECOUNT = 16'd0;
//		REDCOUNT = 16'd0;
//		rowCount = 16'd0;
//		lastRowCount = 16'd0;
//		row1 = 16'd0;
//		row2= 16'd0; 
//		row3 = 16'd0;
//	end */
//	
//	else begin 
/////////* EDGE DETECTION *//////////////////////////////////
//		
//		if (VGA_PIXEL_X == 10'b0  && rowCount > 15'd50) begin //new row
//			count = count - 3'b001;
//			if (count == 3'b0) begin
//				if (lastRowCount+16'd10 < rowCount) begin
//					TEMP_SHAPE = 2'b11; // triangle
//				end
//				else if (lastRowCount-16'd15 > rowCount) begin
//					TEMP_SHAPE = 2'b01; // diamond
//				end
//				else begin
//					TEMP_SHAPE = 2'b10; // square
//				end
//				count = 3'b101;
//			lastRowCount = rowCount;
//			end
//			rowCount  = 16'd0;
//		end 
//		
//		/*
//		if (VGA_PIXEL_X == 10'b0) begin
//			if (10'd50<VGA_PIXEL_Y < 10'd65 && rowCount > 16'd70) begin //new row	
//				row1 = row1+rowCount;
//			end
//			else if (10'd65<=VGA_PIXEL_Y < 10'd80 && rowCount > 16'd70) begin //new row	
//				row2 = row2+rowCount;
//			end
//			else if (10'd80<=VGA_PIXEL_Y <10'd95 && rowCount > 16'd70) begin //new row	
//				row3 = row3+rowCount;
//			end
//			else rowCount = 0;
//		end
//		*/
/////////* COLOR DETECTION *//////////////////////////////////
//		if (PIXEL_IN[7:6] > PIXEL_IN[1:0] && PIXEL_IN[7:6] > PIXEL_IN[4:3]) begin
//			REDCOUNT = REDCOUNT +16'd1;
//			rowCount = rowCount +16'd1;
//			//RESULT = 2'b11;
//		end
//		else if (PIXEL_IN[7:6] < PIXEL_IN[1:0] && PIXEL_IN[1:0] > PIXEL_IN[4:3]) begin
//			BLUECOUNT = BLUECOUNT +16'd1;
//			rowCount = rowCount +16'd1;
//			//RESULT = 2'b11;
//		end
//		else begin
//			BLUECOUNT = BLUECOUNT;
//			REDCOUNT = REDCOUNT;
//			rowCount = rowCount;
//		end
//	end
//	
//	lastSYNC = VGA_VSYNC_NEG;
//	
//	/*if (REDCOUNT > BLUECOUNT) begin
//		RESULT = 2'b00;
//	end
//	else begin
//		RESULT = 2'b00;
//	end
//	*/
//	//We can do edge detection by counting number of pixels of color along row
//	
//	
//end
//
//endmodule
//
//
////`define SCREEN_WIDTH 176
////`define SCREEN_HEIGHT 144
////`define NUM_BARS 3
////`define BAR_HEIGHT 48
////
////module IMAGE_PROCESSOR (
////	PIXEL_IN,
////	CLK,
////	VGA_PIXEL_X,
////	VGA_PIXEL_Y,
////	VGA_VSYNC_NEG,
////	RESULT
////);
////
////
//////=======================================================
//////  PORT declarations
//////=======================================================
////input	[7:0]	PIXEL_IN;
////input			CLK;
////input [9:0]	VGA_PIXEL_X;
////input	[9:0]	VGA_PIXEL_Y;
////input			VGA_VSYNC_NEG;
////
////output reg [2:0] RESULT;
////
////reg [15:0] BLUECOUNT = 0;
////reg [15:0] BLUECOUNTTEMP = 0;
////reg [15:0] REDCOUNT = 0;
////reg [15:0] REDCOUNTTEMP = 0;
////reg [15:0] BLUECOUNTTOP = 0;
////reg [15:0] REDCOUNTTOP = 0;
////reg [15:0] REDCOUNTTOPMID = 0;
////reg [15:0] BLUECOUNTTOPMID = 0;
////reg [15:0] REDCOUNTMID = 0;
////reg [15:0] BLUECOUNTMID = 0;
////reg [15:0] REDCOUNTBOTMID = 0;
////reg [15:0] BLUECOUNTBOTMID = 0;
////reg [15:0] BLUECOUNTBOTTOM = 0;
////reg [15:0] REDCOUNTBOTTOM = 0;
////reg [15:0] REDCOUNTTEMPTOP = 0;
////reg [15:0] BLUECOUNTTEMPTOP = 0;
////reg [15:0] REDCOUNTTEMPTOPMID = 0;
////reg [15:0] BLUECOUNTTEMPTOPMID = 0;
////reg [15:0] REDCOUNTTEMPMID = 0;
////reg [15:0] BLUECOUNTTEMPMID = 0;
////reg [15:0] REDCOUNTTEMPBOTMID = 0;
////reg [15:0] BLUECOUNTTEMPBOTMID = 0;
////reg [15:0] REDCOUNTTEMPBOTTOM = 0;
////reg [15:0] BLUECOUNTTEMPBOTTOM = 0;
////
////always @ (posedge CLK, negedge VGA_VSYNC_NEG) begin
////		if (!VGA_VSYNC_NEG) begin
////			if ((BLUECOUNTTEMP) > (REDCOUNTTEMP) && (BLUECOUNTTEMP) > 16'd17000) begin //17000 is arbitrary, can change
////				if (BLUECOUNTTEMPTOPMID>BLUECOUNTTEMPTOP && BLUECOUNTTEMPMID>BLUECOUNTTEMPTOPMID && BLUECOUNTTEMPBOTMID>BLUECOUNTTEMPMID && BLUECOUNTTEMPBOTTOM>BLUECOUNTTEMPBOTMID) begin //&& BLUECOUNTTEMPTOP<BLUECOUNTTEMPBOTTOM 
////					RESULT = 3'b001; //blue triangle
////				end
////				else if (BLUECOUNTTEMPTOP<BLUECOUNTTEMPTOPMID && BLUECOUNTTEMPTOP<BLUECOUNTTEMPMID && BLUECOUNTTEMPBOTTOM<BLUECOUNTTEMPMID && BLUECOUNTTEMPBOTTOM<BLUECOUNTTEMPBOTMID) begin
////					RESULT = 3'b010; //blue diamond
////				end
////				else begin
////					RESULT = 3'b011; //blue square
////				end
////			end
////			else if ((REDCOUNTTEMP) > (BLUECOUNTTEMP) && (REDCOUNTTEMP) > 16'd17000) begin //17000 is arbitrary, can change
////				if (REDCOUNTTEMPTOPMID>REDCOUNTTEMPTOP && REDCOUNTTEMPMID>REDCOUNTTEMPTOPMID && REDCOUNTTEMPBOTMID>REDCOUNTTEMPMID && REDCOUNTTEMPBOTTOM>REDCOUNTTEMPBOTMID) begin //&& REDCOUNTTEMPTOP<REDCOUNTTEMPBOTTOM 
////					RESULT = 3'b100; //red triangle
////				end
////				else if (REDCOUNTTEMPTOP<REDCOUNTTEMPTOPMID && REDCOUNTTEMPTOP<REDCOUNTTEMPMID && REDCOUNTTEMPBOTTOM<REDCOUNTTEMPMID && REDCOUNTTEMPBOTTOM<REDCOUNTTEMPBOTMID) begin
////					RESULT = 3'b101; //red diamond
////				end
////				else begin
////					RESULT = 3'b110; //red square
////				end
////			end
////			else begin
////				RESULT = 3'b000; //no color detected
////			end
////			BLUECOUNT = 0;
////			REDCOUNT = 0;
////			BLUECOUNTTOP = 0;
////			REDCOUNTTOP = 0;
////			REDCOUNTTOPMID = 0;
////			BLUECOUNTTOPMID = 0;
////			BLUECOUNTMID = 0;
////			REDCOUNTMID = 0;
////			BLUECOUNTBOTMID = 0;
////			REDCOUNTBOTMID = 0;
////			BLUECOUNTBOTTOM = 0;
////			REDCOUNTBOTTOM = 0;
////		end
////		else begin
////			RESULT = RESULT;
////			if (PIXEL_IN[7:6] > PIXEL_IN[1:0] && PIXEL_IN[7:6] > PIXEL_IN[4:3]) begin
////				REDCOUNT = REDCOUNT + 1'b1;
////			end
////			else if (PIXEL_IN[1:0] > PIXEL_IN[7:6] && PIXEL_IN[1:0] > PIXEL_IN[4:3]) begin
////				BLUECOUNT = BLUECOUNT + 1'b1;
////			end
////			REDCOUNTTEMP = REDCOUNT;
////			BLUECOUNTTEMP = BLUECOUNT;
////			if (VGA_PIXEL_Y == 10'd42 && (VGA_PIXEL_X>=10'd48 && VGA_PIXEL_X<=10'd128))begin
////				if (PIXEL_IN[7:6] > PIXEL_IN[1:0] && PIXEL_IN[7:6] > PIXEL_IN[4:3]) begin
////					REDCOUNTTOP = REDCOUNTTOP + 1'b1;
////				end
////				else if (PIXEL_IN[1:0] > PIXEL_IN[7:6] && PIXEL_IN[1:0] > PIXEL_IN[4:3]) begin
////					BLUECOUNTTOP = BLUECOUNTTOP + 1'b1;
////				end
////				REDCOUNTTEMPTOP = REDCOUNTTOP;
////				BLUECOUNTTEMPTOP = BLUECOUNTTOP;
////			end
////			else if (VGA_PIXEL_Y == 10'd57 && (VGA_PIXEL_X>=10'd48 && VGA_PIXEL_X<=10'd128))begin
////				if (PIXEL_IN[7:6] > PIXEL_IN[1:0] && PIXEL_IN[7:6] > PIXEL_IN[4:3]) begin
////					REDCOUNTTOPMID = REDCOUNTTOPMID + 1'b1;
////				end
////				else if (PIXEL_IN[1:0] > PIXEL_IN[7:6] && PIXEL_IN[1:0] > PIXEL_IN[4:3]) begin
////					BLUECOUNTTOPMID = BLUECOUNTTOPMID + 1'b1;
////				end
////				REDCOUNTTEMPTOPMID = REDCOUNTTOPMID;
////				BLUECOUNTTEMPTOPMID = BLUECOUNTTOPMID;
////			end
////			else if (VGA_PIXEL_Y == 10'd72 && (VGA_PIXEL_X>=10'd48 && VGA_PIXEL_X<=10'd128)) begin
////				if (PIXEL_IN[7:6] > PIXEL_IN[1:0] && PIXEL_IN[7:6] > PIXEL_IN[4:3]) begin
////					REDCOUNTMID = REDCOUNTMID + 1'b1;
////				end
////				else if (PIXEL_IN[1:0] > PIXEL_IN[7:6] && PIXEL_IN[1:0] > PIXEL_IN[4:3]) begin
////					BLUECOUNTMID = BLUECOUNTMID + 1'b1;
////				end
////				REDCOUNTTEMPMID = REDCOUNTMID;
////				BLUECOUNTTEMPMID = BLUECOUNTMID;
////			end
////			else if (VGA_PIXEL_Y == 10'd87 && (VGA_PIXEL_X>=10'd48 && VGA_PIXEL_X<=10'd128)) begin
////				if (PIXEL_IN[7:6] > PIXEL_IN[1:0] && PIXEL_IN[7:6] > PIXEL_IN[4:3]) begin
////					REDCOUNTBOTMID = REDCOUNTBOTMID + 1'b1;
////				end
////				else if (PIXEL_IN[1:0] > PIXEL_IN[7:6] && PIXEL_IN[1:0] > PIXEL_IN[4:3]) begin
////					BLUECOUNTBOTMID = BLUECOUNTBOTMID + 1'b1;
////				end
////				REDCOUNTTEMPBOTMID = REDCOUNTBOTMID;
////				BLUECOUNTTEMPBOTMID = BLUECOUNTBOTMID;
////			end
////			else if (VGA_PIXEL_Y == 10'd102 && (VGA_PIXEL_X>=10'd48 && VGA_PIXEL_X<=10'd128)) begin
////				if (PIXEL_IN[7:6] > PIXEL_IN[1:0] && PIXEL_IN[7:6] > PIXEL_IN[4:3]) begin
////					REDCOUNTBOTTOM = REDCOUNTBOTTOM + 1'b1;
////				end
////				else if (PIXEL_IN[1:0] > PIXEL_IN[7:6] && PIXEL_IN[1:0] > PIXEL_IN[4:3]) begin
////					BLUECOUNTBOTTOM = BLUECOUNTBOTTOM + 1'b1;
////				end
////				REDCOUNTTEMPBOTTOM = REDCOUNTBOTTOM;
////				BLUECOUNTTEMPBOTTOM = BLUECOUNTBOTTOM;
////			end
////		end
////end
////
////
////endmodule