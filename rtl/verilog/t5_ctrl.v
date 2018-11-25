/*
 Copyright 2018 Aeste Works (M) Sdn Bhd.
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
*/

module t5_ctrl (/*AUTOARG*/
   // Outputs
   dfn3, dfn7, dop1, dop2, dcp1, dcp2, mpc, xpc, dopc, xepc, dexc,
   dcsr, dsub, dbra, djmp, rs1a, rs2a,
   // Inputs
   fpc, iwb_dat, rs2d, rs1d, fhart, sclk, srst, sena, sexe
   );

   parameter XLEN = 32;

   output [14:12] dfn3;
   output [31:25] dfn7;   
   output [31:0]  dop1, dop2;
   output [31:0]  dcp1, dcp2;
   output [31:2]  mpc, xpc;
   output [6:2]   dopc;
   output [31:2]  xepc;   
   output 	  dexc, dcsr, dsub, dbra, djmp;		  
   
   output [4:0]   rs1a, rs2a;   
   
   input [31:2]   fpc;
   input [31:0]   iwb_dat;
   input [31:0]   rs2d, rs1d;
   input [1:0] 	  fhart;
 	  
   input 	  sclk, srst, sena, sexe;
   
   wire [31:0] 	  ireg = iwb_dat;
   wire [6:2] 	  opc = ireg[6:2];
   
   // FORMAT DECODER - pg 104
   wire 	  rv32 = ireg[1] & ireg[0];
   wire 	  btype = opc[6] & !opc[4] & !opc[2];// (opc[6:2] == 5'b11000);
   wire 	  stype = !opc[6] & opc[5] & !opc[4]; //(opc[6:2] == 5'b01000);
   wire 	  utype = !opc[6] & !opc[3] & opc[2]; //(opc[6:2] == 5'b01101 | opc[6:2] == 5'b00101);
   wire 	  jtype = opc[6] & opc[3] & opc[2]; // 5'b11011   
   wire 	  rtype = !opc[6] & opc[5] & opc[4] & !opc[2];
   wire 	  itype = (!opc[5] & !opc[2]) | (opc == 5'b11001);
   wire 	  ctype = opc[6] & opc[4] & |ireg[13:12];
   wire 	  etype = opc[6] & opc[4] & ~|ireg[13:12];

   reg 		  dexc, dcsr, dsub, dbra, djmp;   
   always @(posedge sclk)
     if (srst) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	dbra <= 1'h0;
	dcsr <= 1'h0;
	dexc <= 1'h0;
	djmp <= 1'h0;
	dsub <= 1'h0;
	// End of automatics
     end else if (sena) begin
	dexc <= etype;
	dcsr <= ctype;
	dsub <= btype | (rtype & (ireg[13] | ireg[30])) | (itype & ireg[13]);
	dbra <= btype;
	djmp <= jtype | (itype & opc[6]);	
     end
	     
   // RS DECODER
   assign rs1a = ireg[19:15];
   assign rs2a = ireg[24:20];   
   
   // IMMEDIATE DECODER - pg 12
   reg [31:0]    imm;
   always @(/*AUTOSENSE*/btype or ireg or itype or jtype or stype
	    or utype) begin
      case ({itype,stype})
	2'b10: imm[0] = ireg[20];
	2'b01: imm[0] = ireg[7];
	2'b00: imm[0] = 1'b0;
	default: imm[0] = 1'bX;
      endcase // case ({itype,stype})
      
      case ({(itype|jtype),(stype|btype)})
	2'b10: imm[4:1] = ireg[24:21];
	2'b01: imm[4:1] = ireg[11:8];
	2'b00: imm[4:1] = 4'h0;	
	default: imm[4:1] = 4'hX;	
      endcase // case ({(itype|jtype),(stype|btype)})
      
      case (utype)
	1'b1: imm[10:5] = 6'd0;
	default: imm[10:5] = ireg[30:25];	
      endcase // case (utype)

      case ({(utype|jtype),(utype|btype)})
	2'b10: imm[11] = ireg[20]; // JAL
	2'b01: imm[11] = ireg[7]; // BCC
	2'b11: imm[11] = 1'b0;	// UI
	default: imm[11] = ireg[31]; 
      endcase // case ({(itype|jtype),(stype|btype)})      
      
      case (utype|jtype)
	1'b1: imm[19:12] = ireg[19:12];
	default: imm[19:12] = {8{ireg[31]}};	
      endcase // case (utype|jtype)

      case(utype)
	1'b1: imm[30:20] = ireg[30:20];
	default: imm[30:20] = {11{ireg[31]}};	
      endcase // case (utype)
            
      imm[31] = ireg[31];            
   end

   // DECODE OPERANDS
   reg [31:0]    dop1, dop2;
   reg [31:0] 	 dcp1, dcp2;
   always @(posedge sclk)
     if (srst) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	dcp1 <= 32'h0;
	dcp2 <= 32'h0;
	dop1 <= 32'h0;
	dop2 <= 32'h0;
	// End of automatics
     end else if (sena & rv32) begin
	dcp1 <= (stype | itype | etype) ? rs1d : {fpc,2'd0};
	dcp2 <= (ctype | etype) ? {ireg[31:15],15'hX} : imm; // RESERVED FOR SYSTEM
	
	dop1 <= (rtype | itype | btype | ctype) ? rs1d : 32'd0;	
	dop2 <= (rtype | stype | btype) ? rs2d : imm;		
     end

   // OPCODE
   reg [14:12] dfn3;
   reg [31:25] dfn7;
   reg [6:2]   dopc;
   
   always @(posedge sclk)
     if (srst) begin
	dopc <= 5'h0D;	
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	dfn3 <= 3'h0;
	dfn7 <= 7'h0;
	// End of automatics
     end else if (sena & rv32) begin
	dopc <= ireg[6:2];
	dfn3 <= ireg[14:12];
	dfn7 <= ireg[31:25];
     end
   
   // PC PIPELINE
   reg [31:2]    dpc, xpc, mpc;
   reg [31:2]    xepc;   
   wire [31:2]   npc = fpc[31:2] + 1; // PC+4
   always @(posedge sclk)
     if (srst) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	dpc <= 30'h0;
	mpc <= 30'h0;
	xepc <= 30'h0;
	xpc <= 30'h0;
	// End of automatics
     end else if (sena & rv32) begin
	mpc <= xpc;
	xpc <= dpc;
	dpc <= npc; // standard increment
	xepc <= fpc[31:2];	
     end	 
   
endmodule // t5_ctrl
