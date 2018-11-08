
module t5_ctrl (/*AUTOARG*/
   // Outputs
   op1, op2, cp1, cp2, pcn, npc, pc4, aslc, fun3, fun7,
   // Inputs
   pc, idat, rs2d, rs1d, clk, rst, ena, exe
   );

   parameter XLEN = 32;

   output [XLEN-1:0] op1, op2, cp1, cp2;

   output [XLEN-1:0] pcn, npc, pc4;   

   output [6:2]      aslc;
   output [14:12]    fun3;
   output [31:25]    fun7;    
   
   input [XLEN-1:0]  pc;
   input [XLEN-1:0]  idat;
   input [XLEN-1:0]  rs2d, rs1d;   
   
   input 	     clk, rst, ena, exe;

   wire [1:0] 	     hart = pc[1:0];
   wire [31:0] 	     ireg = idat;
   wire [6:2] 	     opc = ireg[6:2];
   
   // FORMAT DECODER - pg 104
   wire 	     btype = (opc[6] & !opc[4] & !opc[2]);// (opc[6:2] == 5'b11000);
   wire 	     stype = (opc[6:4] == 3'b010); //(opc[6:2] == 5'b01000);
   wire 	     utype = (opc[4] & opc[2]); //(opc[6:2] == 5'b01101 | opc[6:2] == 5'b00101);
   wire 	     jtype = (opc[6:2] == 5'b11011);
   wire 	     itype = (opc[6:2] == 5'b11001 | (!opc[6] & !opc[5] & !opc[2]));   
   wire 	     rtype = (opc[6:4] == 3'b011);
 	     
   // IMMEDIATE DECODER - pg 12
   reg [XLEN-1:0]    imm;
   always @(/*AUTOSENSE*/btype or ireg or itype or jtype or stype
	    or utype) begin
      case ({itype,stype})
	2'b10: imm[0] <= ireg[20];
	2'b01: imm[0] <= ireg[7];
	2'b00: imm[0] <= 1'b0;
	default: imm[0] <= 1'bX;
      endcase // case ({itype,stype})
      
      case ({(itype|jtype),(stype|btype)})
	2'b10: imm[4:1] <= ireg[24:21];
	2'b01: imm[4:1] <= ireg[11:8];
	2'b00: imm[4:1] <= 4'h0;	
	default: imm[4:1] <= 4'hX;	
      endcase // case ({(itype|jtype),(stype|btype)})
      
      case (utype)
	1'b1: imm[10:5] <= 6'd0;
	default: imm[10:5] <= ireg[30:25];	
      endcase // case (utype)

      case ({(utype|jtype),(utype|btype)})
	2'b10: imm[11] <= ireg[20]; // JAL
	2'b01: imm[11] <= ireg[7]; // BCC
	2'b11: imm[11] <= 1'b0;	// UI
	default: imm[11] <= ireg[31]; 
      endcase // case ({(itype|jtype),(stype|btype)})      
      
      case (utype|jtype)
	1'b1: imm[19:12] <= ireg[19:12];
	default: imm[19:12] <= {8{ireg[31]}};	
      endcase // case (utype|jtype)

      case(utype)
	1'b1: imm[30:20] <= ireg[30:20];
	default: imm[30:20] <= {11{ireg[31]}};	
      endcase // case (utype)
            
      imm[31] <= ireg[31];            
   end

   // OPCODE
   reg [14:12] fun3;
   reg [31:25] fun7;
   reg [6:2]   aslc;
   always @(posedge clk)
     if (rst) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	aslc <= 5'h0;
	fun3 <= 3'h0;
	fun7 <= 7'h0;
	// End of automatics
     end else if (ena) begin
	aslc <= ireg[6:2];
	fun3 <= ireg[14:12];
	fun7 <= ireg[31:25];	
     end
   
   // OPERANDS
   reg [XLEN-1:0]    op1, op2;
   always @(posedge clk)
     if (rst) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	cp1 <= {XLEN{1'b0}};
	cp2 <= {XLEN{1'b0}};
	op1 <= {XLEN{1'b0}};
	op2 <= {XLEN{1'b0}};
	// End of automatics
     end else if (ena) begin
	cp1 <= rs1d; // Btype
	cp2 <= rs2d; // Btype & Stype	
	op1 <= (utype | btype | jtype) ? pc : rs1d;	
	op2 <= (rtype) ? rs2d : imm;		
     end

   // PC PIPELINE
   reg [XLEN-1:0]    pcn, npc, pc4;   
   always @(posedge clk)
     if (rst) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	npc <= {XLEN{1'b0}};
	pc4 <= {XLEN{1'b0}};
	pcn <= {XLEN{1'b0}};
	// End of automatics
     end else if (ena) begin
	pc4 <= npc;
	npc <= pcn;
	pcn <= {pc[XLEN-1:2] + 1,pc[1:0]}; // standard increment
     end	 
   
endmodule // t5_ctrl
