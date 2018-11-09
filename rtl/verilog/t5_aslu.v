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

module t5_aslu (/*AUTOARG*/
   // Outputs
   malu, xbpc, xbra, xdat, xopc, xfn3,
   // Inputs
   dop1, dop2, dcp1, dcp2, dopc, dfn7, dfn3, xpc, sclk, srst, sena
   );
   parameter XLEN = 32;

   output [XLEN-1:0] malu;
   output [XLEN-1:0] xbpc;
   output 	     xbra;
//, mlnk;
   
   output [XLEN-1:0] xdat;
   output [6:2]      xopc;
   output [14:12]    xfn3; 	     
   
   input [XLEN-1:0]  dop1, dop2, dcp1, dcp2;
   input [6:2] 	     dopc;
   input [31:25]     dfn7;
   input [14:12]     dfn3;
   input [XLEN-1:0]  xpc;
   
   input 	     sclk, srst, sena;

   // OPCODE PIPELINE
   reg [6:2] 	     xopc;
   reg [14:12] 	     xfn3;   
   always @(posedge sclk)
     if (srst) begin
	xopc <= 5'h0D;	
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	xfn3 <= 3'h0;
	// End of automatics
     end else if (sena) begin
	xopc <= dopc;
	xfn3 <= dfn3;	
     end
      
   // ADDER
   reg [XLEN-1:0]    xadd;
   always @(/*AUTOSENSE*/dfn7 or dop1 or dop2 or dopc)
     xadd <= (dfn7[30] & !dopc[6] & dopc[4] & !dopc[2]) ? dop1 - dop2 : // SUB
	     dop1 + dop2; // ADD

   // LOGIC
   reg [XLEN-1:0]    xlog;
   always @(/*AUTOSENSE*/dfn3 or dop1 or dop2)
     case (dfn3)
       3'b100: xlog <= dop1 ^ dop2; // XOR
       3'b110: xlog <= dop1 | dop2; // OR
       3'b111: xlog <= dop1 & dop2; // AND
       default: xlog <= 32'hX;       
     endcase // case (dfn3)

   // SHIFT
   reg [XLEN-1:0]    xshl, xshr, xsha, xshf;
   always @(/*AUTOSENSE*/dfn3 or dfn7 or dop1 or dop2) begin
      case ({dfn3[14],dfn7[30]})
	2'b00: xshf <= dop1 << dop2[4:0]; // SLL
	2'b10: xshf <= dop1 >> dop2[4:0]; // SRL
	2'b11: xshf <= {dop1[31], dop1 >> dop2[4:0]}; // SRA
	default: xshf <= 32'hX;	
      endcase // case ({dfn3[14],dfn7[30]})      
   end

   // COMPARE/SET
   reg xcmp;
   always @(/*AUTOSENSE*/dcp1 or dcp2 or dfn3 or dop1 or dop2)
     case (dfn3)
       3'b000: xcmp = (dcp1 == dcp2); // BE
       3'b001: xcmp = !(dcp1 == dcp2); // BNE
       3'b010: xcmp = (dop1 < dop2); // SLT
       3'b011: xcmp = (dop1 < dop2); // SLTU
       3'b100: xcmp = (dcp1 < dcp2); // BLT
       3'b101: xcmp = !(dcp1 < dcp2); // BGE 
       3'b110: xcmp = (dcp1 < dcp2); // BLTU
       3'b111: xcmp = !(dcp1 < dcp2); // BGEU 
       // TODO: Unsigned compare
       default: xcmp = 1'bX;       
     endcase // case (dfn3)

   reg [XLEN-1:0] xset;
   always @(/*AUTOSENSE*/xcmp) begin
     xset <= {30'd0, xcmp};
   end
      
   // BRANCH
   reg 		  xbra;
   reg [1:0] 	  xlnk;
//   assign mlnk = xlnk[1];
   
   always @(posedge sclk)
     if (srst) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	xbra <= 1'h0;
	xlnk <= 2'h0;
	// End of automatics
     end else if (sena) begin
	xbra <= dopc[6] & dopc[5] & (dopc[2] | xcmp); // BRANCH
	xlnk <= {xlnk[0], dopc[6] & dopc[5] & dopc[2]}; // LINK	
     end
   
   reg [XLEN-1:0] xbpc;
   reg [XLEN-1:0] xdat;   
   reg [XLEN-1:0] xmov;
   always @(posedge sclk)
     if (srst) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	xbpc <= {XLEN{1'b0}};
	xdat <= {XLEN{1'b0}};
	xmov <= {XLEN{1'b0}};
	// End of automatics
  end else if (sena) begin
     xbpc <= xadd;
     xmov <= dop2;     
     case (dfn3[13:12]) 
       2'o0: xdat <= {4{dcp2[7:0]}};
       2'o1: xdat <= {2{dcp2[15:0]}};
       2'o2: xdat <= dcp2;
       default: xdat <= 32'hX;       
     endcase // case (xadd[1:0])     
  end
   
   // ASLU
   reg [XLEN-1:0] xalu, malu;   
   always @(posedge sclk)
     if (srst) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	malu <= {XLEN{1'b0}};
	xalu <= {XLEN{1'b0}};
	// End of automatics
  end else if (sena) begin
     case ({xopc[5],xopc[4],xopc[2]})
       3'b111: malu <= xmov; // LUI
       3'b101: malu <= {xpc[XLEN-1:2],2'd0}; // JAL/R       
       3'b011: malu <= {xbpc[XLEN-1:2],2'd0}; // AUIPC
       3'b010,3'b110: malu <= xalu; // ALU
       default: malu <= 32'hX;       
     endcase // case (xopc[6:4])
     
     case (dfn3)
       3'o0: xalu <= xadd;
       3'o1: xalu <= xshf;
       3'o2: xalu <= xset;
       3'o3: xalu <= xset;
       3'o4: xalu <= xlog;
       3'o5: xalu <= xshf;
       3'o6: xalu <= xlog;
       3'o7: xalu <= xlog;       
     endcase // case (dfn3)
  end
   

   
endmodule // t5_aslu
