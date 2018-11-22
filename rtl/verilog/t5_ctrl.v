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
   dop1, dop2, dcp1, dcp2, mpc, xpc, dopc, dfn3, dfn7, rs1a, rs2a,
   fhart,
   // Inputs
   fpc, idat, rs2d, rs1d, sclk, srst, sena, sexe
   );

   parameter XLEN = 32;

   output [XLEN-1:0] dop1, dop2, dcp1, dcp2;
   output [XLEN-1:0] mpc, xpc;   
   output [6:2]      dopc;
   output [14:12]    dfn3;
   output [31:25]    dfn7;

   output [4:0]      rs1a, rs2a;   
   output [1:0]      fhart;
   
   input [XLEN-1:0]  fpc;
   input [XLEN-1:0]  idat;
   input [XLEN-1:0]  rs2d, rs1d;
 
   input 	     sclk, srst, sena, sexe;

   wire [1:0] 	     hart = fpc[1:0];
   wire [31:0] 	     ireg = idat;
   wire [6:2] 	     opc = ireg[6:2];

   // FORMAT DECODER - pg 104
   wire 	     btype = (opc[6] & !opc[4] & !opc[2]);// (opc[6:2] == 5'b11000);
   wire 	     stype = (opc[6:4] == 3'b010); //(opc[6:2] == 5'b01000);
   wire 	     utype = (opc[4] & opc[2]); //(opc[6:2] == 5'b01101 | opc[6:2] == 5'b00101);
   wire 	     jtype = (opc[6:2] == 5'b11011);
   wire 	     itype = (opc[6:2] == 5'b11001 | (!opc[6] & !opc[5] & !opc[2]));   
   wire 	     rtype = !opc[6] & opc[5] & opc[4] & !opc[2];
   wire 	     rv32 = ireg[1] & ireg[0];
	     
   // RS DECODER
   assign rs1a = ireg[19:15];
   assign rs2a = ireg[24:20];   
   assign fhart = fpc[1:0];
   
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

   // DECODE OPERANDS
   reg [XLEN-1:0]    dop1, dop2, dcp1, dcp2;
   always @(posedge sclk)
     if (srst) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	dcp1 <= {XLEN{1'b0}};
	dcp2 <= {XLEN{1'b0}};
	dop1 <= {XLEN{1'b0}};
	dop2 <= {XLEN{1'b0}};
	// End of automatics
     end else if (sena & rv32) begin
	dcp1 <= rs1d; // Btype
	dcp2 <= rs2d; // Btype & Stype	
	dop1 <= (utype | btype | jtype) ? fpc : rs1d;	
	dop2 <= (rtype) ? rs2d : imm;		
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
   reg [XLEN-1:0]    dpc, xpc, mpc;
   wire [XLEN-1:2]   npc = fpc[XLEN-1:2] + 1;   
   always @(posedge sclk)
     if (srst) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	dpc <= {XLEN{1'b0}};
	mpc <= {XLEN{1'b0}};
	xpc <= {XLEN{1'b0}};
	// End of automatics
     end else if (sena & rv32) begin
	mpc <= xpc;
	xpc <= dpc;
	dpc <= {npc,fpc[1:0]}; // standard increment
     end	 
   
endmodule // t5_ctrl
