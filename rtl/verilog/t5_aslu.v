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
   xfn3, malu, xbpc, xbra, xdat, xopc,
   // Inputs
   dop1, dop2, dcp1, dcp2, dopc, dfn7, dfn3, xpc, sysc, sclk, srst,
   sena
   );
   parameter XLEN = 32;

   output [14:12] xfn3; 	     
   output [31:0]  malu;
   output [31:0]  xbpc;
   output 	  xbra;
   
   
   output [31:0]  xdat;
   output [6:2]   xopc;
   
   input [31:0]   dop1, dop2;
   input [31:2]   dcp1, dcp2;
   input [6:2] 	  dopc;
   input [31:25]  dfn7;
   input [14:12]  dfn3;
   input [31:0]   xpc;
   
   input 	  sysc;   
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
   reg [31:2] xadr;
   always @(/*AUTOSENSE*/dcp1 or dcp2)
     xadr = dcp1 + dcp2;   
   
   // ADD32
   reg [32:0]    xadd;
   wire [32:0] 	 wop1, wop2;
   
   assign wop1[32] = (&dfn3[14:13] | &dfn3[13:12]) ? 1'b0 : dop1[31];
   assign wop2[32] = (&dfn3[14:13] | &dfn3[13:12]) ? 1'b0 : dop2[31];
   assign wop1[31:0] = dop1;
   assign wop2[31:0] = dop2;
   
   always @(/*AUTOSENSE*/dfn3 or dfn7 or dopc or wop1 or wop2)
     if ((dfn7[30] & !dopc[6] & dopc[5] & dopc[4])| // SUB
	 (dfn3[13] & !dopc[6] & dopc[5] & dopc[4] & !dopc[2])| // SLT
	 (dfn3[13] & !dopc[6] & !dopc[5] & dopc[4] & !dopc[2])| // SLTI
	 (dopc[6] & dopc[5] & !dopc[4] & !dopc[2]) // BCC
	 )
       xadd = wop1 - wop2;
     else
       xadd = wop1 + wop2; // ADD

   // LOGIC
   reg [31:0]    xlog;
   always @(/*AUTOSENSE*/dfn3 or dop1 or dop2)
     case (dfn3[13:12])
       3'b00: xlog = dop1 ^ dop2; // XOR
       3'b10: xlog = dop1 | dop2; // OR
       3'b11: xlog = dop1 & dop2; // AND
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
     xset = {31'd0, xadd[31]};
   end

   // CSR
   localparam [11:0]
     CSR_ECALL = 12'h000,
     CSR_MSTATUS = 12'h300,
     CSR_MISA = 12'h301,
     CSR_MEDELEG = 12'h302,
     CSR_MIDELEG = 12'h303,
     CSR_MIE = 12'h304,
     CSR_MTVEC = 12'h305,
     CSR_MEPC = 12'h341,
     CSR_MVENDORID = 12'hF11,
     CSR_MARCHID = 12'hF12,
     CSR_MIMPID = 12'hF13,
     CSR_MHARTID = 12'hF14;
   
   reg [XLEN-1:0] xcsr;
   reg [XLEN-1:2] mepc;
   reg [XLEN-1:0] medeleg;   

   wire 	  csr = dfn3[13] | dfn3[12];

   always @(posedge sclk)
     if (srst) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	medeleg <= {XLEN{1'b0}};
	mepc <= {(1+(XLEN-1)-(2)){1'b0}};
	xcsr <= {XLEN{1'b0}};
	// End of automatics
     end else if (sena) begin
	if (csr)
	  case (dop2[31:20])
	    CSR_MHARTID: xcsr <= {{(XLEN-2){1'b0}},dop1[1:0]};
	    CSR_MISA: xcsr <= 32'h40000100;
	    CSR_MEDELEG: xcsr <= medeleg;
	    CSR_MEPC: xcsr <= {mepc, 2'd0};	  
	    default: xcsr <= {(XLEN){1'b0}};	  
	  endcase // case (dop2[31:20])

	if (csr)
	  case (dop2[31:20])
	    CSR_MEPC: mepc <= dcp1[XLEN-1:2];
	    default: mepc <= mepc;
	  endcase // case (dop2[31:20])
	
	if (csr)
	  case (dop2[31:20])
	    CSR_MEDELEG: medeleg <= dcp1;
	    default: medeleg <= medeleg;	  
	  endcase // case (dop2[31:20])
     end
      
   // BRANCH
   reg 		  xbra;
   reg [1:0] 	  xlnk;
//   assign mlnk = xlnk[1];
   //wire 	  call = ~|dfn3 & &dopc[6:4]; // system call
   
   always @(posedge sclk)
     if (srst) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	xbra <= 1'h0;
	xlnk <= 2'h0;
	// End of automatics
     end else if (sena) begin
	xbra <= sysc | (dopc[6] & dopc[5] & !dopc[4] & (dopc[2] | xcmp)); // BRANCH
	xlnk <= {xlnk[0], dopc[6] & dopc[5] & dopc[2]}; // LINK	
     end
   
   reg [31:0] xbpc;
   reg [31:0] xdat;   
   reg [31:0] xmov;
   always @(posedge sclk)
     if (srst) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	xbpc <= 32'h0;
	xdat <= 32'h0;
	xmov <= 32'h0;
	// End of automatics
  end else if (sena) begin

     case ({sysc,dop2[21]})
       2'b11: xbpc <= {mepc,2'd0};
       default: xbpc <= {xadr,2'd0};       
     endcase // case ({sysc,dop2[21]})
     
     xmov <= xadd;
     
     case (dfn3[13:12]) 
       2'o0: xdat <= {4{xadd[7:0]}};
       2'o1: xdat <= {2{xadd[15:0]}};
       2'o2: xdat <= xadd;
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
       4'b1101: malu <= {xpc[XLEN-1:2],2'd0}; // JAL/R       
       4'b0011: malu <= {xbpc[XLEN-1:2],2'd0}; // AUIPC
       4'b0010,4'b0110: malu <= xalu; // ALU
       4'b1110: malu <= xcsr;       
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
