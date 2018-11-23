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

module t5_data (/*AUTOARG*/
   // Outputs
   dwb_adr, dwb_dto, dwb_sel, dwb_wre, dwb_stb, xsel, xstb, xwre,
   // Inputs
   dwb_dti, dwb_ack, xbpc, xdat, dopc, dfn3, dcp1, dcp2, sclk, srst,
   sena
   );
   parameter XLEN = 32;
   
   output [31:2] dwb_adr;
   output [31:0] dwb_dto;
   output [3:0]  dwb_sel;   
   output 	 dwb_wre,
		 dwb_stb;
   
   output [3:0]  xsel;
   output 	 xstb, xwre;   
   
   input [31:0]  dwb_dti;
   input 	 dwb_ack;
   
   input [31:0]  xbpc, xdat;
   
   input [6:2] 	 dopc;
   input [14:12] dfn3;
   input [1:0] 	 dcp1, dcp2;		    
   
   input 	 sclk,
		 srst,
		 sena;   
   
   // BYTE SELECT
   reg [3:0] 	 xsel;
   wire [1:0] 	 xoff = dcp1 + dcp2;   
   assign dwb_sel = xsel;
   
   always @(posedge sclk)
     if (srst) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	xsel <= 4'h0;
	// End of automatics
     end else if (sena) begin
	case ({dfn3[13:12],xoff[1:0]})
	  4'h0: xsel <= 4'h1;// B0
	  4'h1: xsel <= 4'h2;// B1
	  4'h2: xsel <= 4'h4;// B2
	  4'h3: xsel <= 4'h8;// B3
	  4'h4: xsel <= 4'h3;// H0
	  4'h6: xsel <= 4'hC;// H2
	  4'h8: xsel <= 4'hF;// W0
	  default: xsel <= 4'hX;	  
	endcase // case ({dfn3[1:0],xadd[1:0]})	
     end

   // BUS CONTROL
   reg 			    xstb;
   reg 			    xwre;
   assign dwb_stb = xstb;
   assign dwb_wre = xwre;
   always @(posedge sclk)
     if (srst) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	xstb <= 1'h0;
	xwre <= 1'h0;
	// End of automatics
     end else if (sena) begin
	xstb <= !dopc[6] & !dopc[4] & !dopc[2];	
	xwre <= dopc[5];
     end

   assign dwb_adr = xbpc[31:2];
   assign dwb_dto = xdat[31:0];   
   
   
endmodule // t5_data
