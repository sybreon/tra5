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
     xadd <= (dfn7[30] & !dopc[6] & dopc[5] & dopc[4]) ? dop1 - dop2 : // SUB
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
   reg [XLEN-1:0]    xshf;
   always @(/*AUTOSENSE*/dfn3 or dfn7 or dop1 or dop2) begin
      case ({dfn3[14],dfn7[30]})
	2'b00: xshf <= dop1 << dop2[4:0]; // SLL
	2'b10: xshf <= dop1 >> dop2[4:0]; // SRL
	2'b11: case (dop2[4:0]) // SRA
		 5'd00: xshf <= dop1;
		 5'd01: xshf <= {{(1){dop1[31]}}, dop1[31:1]};
		 5'd02: xshf <= {{(2){dop1[31]}}, dop1[31:2]};
		 5'd03: xshf <= {{(3){dop1[31]}}, dop1[31:3]};
		 5'd04: xshf <= {{(4){dop1[31]}}, dop1[31:4]};
		 5'd05: xshf <= {{(5){dop1[31]}}, dop1[31:5]};
		 5'd06: xshf <= {{(6){dop1[31]}}, dop1[31:6]};
		 5'd07: xshf <= {{(7){dop1[31]}}, dop1[31:7]};
		 5'd08: xshf <= {{(8){dop1[31]}}, dop1[31:8]};
		 5'd09: xshf <= {{(9){dop1[31]}}, dop1[31:9]};
		 5'd10: xshf <= {{(10){dop1[31]}}, dop1[31:10]};
		 5'd11: xshf <= {{(11){dop1[31]}}, dop1[31:11]};
		 5'd12: xshf <= {{(12){dop1[31]}}, dop1[31:12]};
		 5'd13: xshf <= {{(13){dop1[31]}}, dop1[31:13]};
		 5'd14: xshf <= {{(14){dop1[31]}}, dop1[31:14]};
		 5'd15: xshf <= {{(15){dop1[31]}}, dop1[31:15]};
		 5'd16: xshf <= {{(16){dop1[31]}}, dop1[31:16]};
		 5'd17: xshf <= {{(17){dop1[31]}}, dop1[31:17]};
		 5'd18: xshf <= {{(18){dop1[31]}}, dop1[31:18]};
		 5'd19: xshf <= {{(19){dop1[31]}}, dop1[31:19]};
		 5'd20: xshf <= {{(20){dop1[31]}}, dop1[31:20]};
		 5'd21: xshf <= {{(21){dop1[31]}}, dop1[31:21]};
		 5'd22: xshf <= {{(22){dop1[31]}}, dop1[31:22]};
		 5'd23: xshf <= {{(23){dop1[31]}}, dop1[31:23]};
		 5'd24: xshf <= {{(24){dop1[31]}}, dop1[31:24]};
		 5'd25: xshf <= {{(25){dop1[31]}}, dop1[31:25]};
		 5'd26: xshf <= {{(26){dop1[31]}}, dop1[31:26]};
		 5'd27: xshf <= {{(27){dop1[31]}}, dop1[31:27]};
		 5'd28: xshf <= {{(28){dop1[31]}}, dop1[31:28]};
		 5'd29: xshf <= {{(29){dop1[31]}}, dop1[31:29]};
		 5'd30: xshf <= {{(30){dop1[31]}}, dop1[31:30]};
		 5'd31: xshf <= {{(31){dop1[31]}}, dop1[31]};
	       endcase // case (dop2[4:0])
	
	default: xshf <= 32'hX;	
      endcase // case ({dfn3[14],dfn7[30]})      
   end

   // COMPARE/SET
   reg xcmp;
   always @(/*AUTOSENSE*/dcp1 or dcp2 or dfn3 or dop1 or dop2)
     case (dfn3)
       3'o0: xcmp = (dcp1 == dcp2); // BE
       3'o1: xcmp = !(dcp1 == dcp2); // BNE
       3'o2: xcmp = (dop1 < dop2); // SLT
       3'o3: xcmp = (dop1 < dop2); // SLTU
       3'o4: xcmp = (dcp1 < dcp2); // BLT
       3'o5: xcmp = !(dcp1 < dcp2); // BGE 
       3'o6: xcmp = (dcp1 < dcp2); // BLTU
       3'o7: xcmp = !(dcp1 < dcp2); // BGEU
       // FIXME: Unsigned operations
       default: xcmp = 1'bX;       
     endcase // case (dfn3)

   reg [XLEN-1:0] xset;
   always @(/*AUTOSENSE*/xcmp) begin
     xset <= {{(XLEN-1){1'b0}}, xcmp};
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
