/*
 Copyright 2018 Shawn Tan <shawn.tan@aeste.my>.
 
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
   xfn3, malu, xbpc, xbra, xstb, xdat, xopc,
   // Inputs
   dop1, dop2, dcp1, dcp2, dopc, dfn7, dfn3, xpc, dhart, dexc, dcsr,
   dsub, dbra, djmp, sclk, srst, sena
   );
   parameter XLEN = 32;

   output [14:12] xfn3; 	     
   output [31:0]  malu;
   output [31:2]  xbpc;
   output [1:0]	  xbra, xstb;
      
   output [31:0]  xdat;
   output [6:2]   xopc;
   
   input [31:0]   dop1, dop2;
   input [31:0]   dcp1, dcp2;
   input [6:2] 	  dopc;
   input [31:25]  dfn7;
   input [14:12]  dfn3;
   input [31:2]   xpc;
   input [1:0] 	  dhart;
 	  
   input 	  dexc, dcsr, dsub, dbra, djmp;
   input 	  sclk, srst, sena;
   
   // OPCODE PIPELINE
   reg [6:2] 	  xopc;
   reg [14:12] 	  xfn3;

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

   // ADD30
   reg [31:0] xadr;
   always @(/*AUTOSENSE*/dcp1 or dcp2)
     xadr = dcp1 + dcp2;   
   
   // ADD32
   reg [32:0]    xadd;
   wire [32:0] 	 wop1, wop2;
   
   assign wop1[32] = (&dfn3[14:13] | &dfn3[13:12]) ? 1'b0 : dop1[31];
   assign wop2[32] = (&dfn3[14:13] | &dfn3[13:12]) ? 1'b0 : dop2[31];
   assign wop1[31:0] = dop1;
   assign wop2[31:0] = dop2;
   
   always @(/*AUTOSENSE*/dsub or wop1 or wop2)     
       xadd = (dsub) ? wop1 - wop2 : // SUB
	      wop1 + wop2; // ADD

   // LOGIC
   reg [31:0]    xlog;
   always @(/*AUTOSENSE*/dfn3 or dop1 or dop2)
     case (dfn3[13:12])
       2'b00: xlog = dop1 ^ dop2; // XOR
       2'b10: xlog = dop1 | dop2; // OR
       2'b11: xlog = dop1 & dop2; // AND
       default: xlog = 32'hX;       
     endcase // case (dfn3)

   // SHIFT
   reg [31:0]    xshf;
   always @(/*AUTOSENSE*/dfn3 or dfn7 or dop1 or dop2) begin
      case ({dfn3[14],dfn7[30]})
	2'b00: xshf = dop1 << dop2[4:0]; // SLL
	2'b10: xshf = dop1 >> dop2[4:0]; // SRL
	2'b11: case (dop2[4:0]) // SRA
		 5'd00: xshf = dop1;		 
		 5'd01: xshf = {{(1){dop1[31]}}, dop1[31:1]};
		 5'd02: xshf = {{(2){dop1[31]}}, dop1[31:2]};
		 5'd03: xshf = {{(3){dop1[31]}}, dop1[31:3]};
		 5'd04: xshf = {{(4){dop1[31]}}, dop1[31:4]};
		 5'd05: xshf = {{(5){dop1[31]}}, dop1[31:5]};
		 5'd06: xshf = {{(6){dop1[31]}}, dop1[31:6]};
		 5'd07: xshf = {{(7){dop1[31]}}, dop1[31:7]};
		 5'd08: xshf = {{(8){dop1[31]}}, dop1[31:8]};
		 5'd09: xshf = {{(9){dop1[31]}}, dop1[31:9]};
		 5'd10: xshf = {{(10){dop1[31]}}, dop1[31:10]};
		 5'd11: xshf = {{(11){dop1[31]}}, dop1[31:11]};
		 5'd12: xshf = {{(12){dop1[31]}}, dop1[31:12]};
		 5'd13: xshf = {{(13){dop1[31]}}, dop1[31:13]};
		 5'd14: xshf = {{(14){dop1[31]}}, dop1[31:14]};
		 5'd15: xshf = {{(15){dop1[31]}}, dop1[31:15]};
		 5'd16: xshf = {{(16){dop1[31]}}, dop1[31:16]};
		 5'd17: xshf = {{(17){dop1[31]}}, dop1[31:17]};
		 5'd18: xshf = {{(18){dop1[31]}}, dop1[31:18]};
		 5'd19: xshf = {{(19){dop1[31]}}, dop1[31:19]};
		 5'd20: xshf = {{(20){dop1[31]}}, dop1[31:20]};
		 5'd21: xshf = {{(21){dop1[31]}}, dop1[31:21]};
		 5'd22: xshf = {{(22){dop1[31]}}, dop1[31:22]};
		 5'd23: xshf = {{(23){dop1[31]}}, dop1[31:23]};
		 5'd24: xshf = {{(24){dop1[31]}}, dop1[31:24]};
		 5'd25: xshf = {{(25){dop1[31]}}, dop1[31:25]};
		 5'd26: xshf = {{(26){dop1[31]}}, dop1[31:26]};
		 5'd27: xshf = {{(27){dop1[31]}}, dop1[31:27]};
		 5'd28: xshf = {{(28){dop1[31]}}, dop1[31:28]};
		 5'd29: xshf = {{(29){dop1[31]}}, dop1[31:29]};
		 5'd30: xshf = {{(30){dop1[31]}}, dop1[31:30]};
		 5'd31: xshf = {{(31){dop1[31]}}, dop1[31]};
	       endcase // cas (dop2[4:0])	
	default: xshf = 32'hX;	
      endcase // case ({dfn3[14],dfn7[30]})      
   end

   // COMPARE/SET
   wire xneq = |xadd[31:0];   
   reg xcmp;
   always @(/*AUTOSENSE*/dfn3 or xadd or xneq)
     case (dfn3)
       3'o0: xcmp = !xneq; // BE
       3'o1: xcmp = xneq; // BNE       
       3'o2: xcmp = xadd[32]; // SLT cp1<cp2
       3'o3: xcmp = xadd[32]; // SLTU       
       3'o4: xcmp = xadd[32]; // BLT cp1<cp2
       3'o5: xcmp = !xadd[32]; // BGE       
       3'o6: xcmp = xadd[32]; // BLTU cp1<cp2
       3'o7: xcmp = !xadd[32]; // BGEU
     endcase // case (dfn3)

   reg [31:0] xset;
   always @(/*AUTOSENSE*/xadd) begin
     xset = {31'd0, xadd[32]};
   end

   // CSR
   reg [XLEN-1:0] xcsr;
   reg [31:0] 	  rcsr, wcsr;   
   
   wire [31:0] 	  mask = (dfn3[14]) ? {27'd0,dcp2[19:15]} : dop1;   
   wire 	  wecsr = dcsr;

   always @(/*AUTOSENSE*/dfn3 or mask or rcsr)
     case(dfn3[13:12])
       default: wcsr = 32'hX;       
       2'd1: wcsr = mask; // move bits
       2'd2: wcsr = rcsr | mask; // set bits
       2'd3: wcsr = rcsr & ~mask; // clear bits
     endcase // case (dfn3[13:12])
   
   localparam [11:0]
     CSR_ECALL = 12'h000,
     CSR_MSTATUS = 12'h300,
     CSR_MISA = 12'h301,
     CSR_MEDELEG = 12'h302,
     CSR_MIDELEG = 12'h303,
     CSR_MIE = 12'h304,
     CSR_MTVEC = 12'h305,
     CSR_MTVAL = 12'h343,
     CSR_MCAUSE = 12'h342,
     CSR_MSCRATCH = 12'h340,
     CSR_MEPC = 12'h341,
     CSR_MHARTID = 12'hF14;
   
   reg [31:0] mepc;
   reg [31:0] medeleg, mtvec, mtval;
   reg [31:0] mscratch;  // FIXME: hart-local
   
   // WRITE CSR
   always @(posedge sclk)
     if (srst)  begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	medeleg <= 32'h0;
	mscratch <= 32'h0;
	mtvec <= 32'h0;
	// End of automatics
     end else if (sena & wecsr) begin
	if (dcp2[31:20] == CSR_MEDELEG) medeleg <= wcsr;
	if (dcp2[31:20] == CSR_MSCRATCH) mscratch <= wcsr;
	if (dcp2[31:20] == CSR_MTVEC) mtvec <= wcsr;
     end
   
   // READ CSR
   always @(/*AUTOSENSE*/dcp2 or dhart or medeleg or mepc or mscratch
	    or mtval or mtvec)
     case (dcp2[31:20])
       CSR_MHARTID: rcsr = {30'd0,dhart};
       CSR_MISA: rcsr = 32'h40000100;
       CSR_MSCRATCH: rcsr = mscratch;       
       CSR_MEDELEG: rcsr = medeleg;
       CSR_MEPC: rcsr = {mepc[31:2], 2'd0};
       CSR_MTVAL: rcsr = mtval;
       CSR_MTVEC: rcsr = mtvec;       
       default: rcsr = {(XLEN){1'b0}};	  
     endcase // case (dop2[31:20])

   always @(posedge sclk)
     if (srst) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	xcsr <= {XLEN{1'b0}};
	// End of automatics
     end else if (sena) begin
	xcsr <= rcsr;	
     end
   
      
   // BRANCH
   wire 	  wbra = dexc | (dopc[6] & dopc[5] & !dopc[4] & (dopc[2] | xcmp)); // BRANCH
   wire 	  balign = (|xadr[1:0] & dbra) | (djmp & xadr[1]); // misaligned
   always @(posedge sclk)
     if (srst) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	xbra <= 2'h0;
	// End of automatics
     end else if (sena) begin
	xbra <= {wbra,balign};	
     end
   
   reg [31:0] xbpc;
   reg [31:0] xdat;   
   reg [31:0] xmov;
   always @(posedge sclk)
     if (srst) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	xbpc <= 30'h0;
	xdat <= 32'h0;
	xmov <= 32'h0;
	// End of automatics
     end else if (sena) begin
	// ADDRESS CALC
	case ({dexc,dcp2[21]})
	  2'b11: xbpc <= mepc[31:2]; // RET
	  2'b10: xbpc <= 30'hX; // ECALL FIXME:
	  default: xbpc <= {xadr[31:2]};
	endcase // case ({dexc,dcp2[21]})
	
	// OPERAND CALC
	xmov <= xadd[31:0];

	// DATA BUS
	case (dfn3[13:12]) 
	  2'o0: xdat <= {4{xadd[7:0]}};
	  2'o1: xdat <= {2{xadd[15:0]}};
	  2'o2: xdat <= xadd[31:0];
	  default: xdat <= 32'hX;       
	endcase // case (xadd[1:0])     
     end
   
   // ASLU
   reg [XLEN-1:0] xalu, malu;   
   always @(posedge sclk)
     if (srst) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	malu <= 32'h0;
	xalu <= {XLEN{1'b0}};
	// End of automatics
     end else if (sena) begin
	case ({xopc[6],xopc[5],xopc[4],xopc[2]})
	  4'b0111: malu <= xmov; // LUI
	  4'b1101: malu <= {xpc[31:2],2'd0}; // JAL/R       
	  4'b0011: malu <= {xbpc[31:2],2'd0}; // AUIPC
	  4'b0010,4'b0110: malu <= xalu; // ALU
	  4'b1110: malu <= xcsr;       
	  default: malu <= 32'hX;       
	endcase // case (xopc[6:4])
	
	case (dfn3)
	  3'o0: xalu <= xadd[31:0];
	  3'o1: xalu <= xshf;
	  3'o2: xalu <= xset;
	  3'o3: xalu <= xset;
	  3'o4: xalu <= xlog;
	  3'o5: xalu <= xshf;
	  3'o6: xalu <= xlog;
	  3'o7: xalu <= xlog;       
	endcase // case (dfn3)
     end
   

   // misalign
   reg [1:0]	  xbra;
   reg [1:0] 	  xoff;
   wire 	  wtval = (dcp2[31:20] == CSR_MTVAL) & wecsr;   
   wire 	  wepc = (dcp2[31:20] == CSR_MEPC) & wecsr;
   
   always @(posedge sclk)
     if (srst) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	mepc <= 32'h0;
	mtval <= 32'h0;
	xoff <= 2'h0;
	// End of automatics
     end else if (sena) begin
	if (wepc) mepc <= wcsr; // FIXME: ECALL

	case({&xbra|wtval,&xstb|wtval})
	  2'b11: mtval <= wcsr;	  
	  2'b10, 2'b01: mtval <= {xbpc, xoff};
	  default: mtval <= mtval;	  
	endcase // case (xbra)

	xoff <= (djmp) ? {xadr[1],1'b0} : xadr[1:0];	
     end
   
endmodule // t5_aslu
