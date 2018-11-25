/*
 Copyright 2018 Shawn Tan <shawn.tan@aeste.my>
 
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

module t5_inst(/*AUTOARG*/
   // Outputs
   fpc, iwb_adr, iwb_wre, iwb_stb, iwb_sel, fhart, mhart, dhart,
   // Inputs
   xbpc, xpc, xbra, xsel, xstb, sclk, sena, srst, mtvec
   );

   parameter XLEN = 32;

   output [31:0] fpc;   
   output [31:2] iwb_adr;
   output 	 iwb_wre;
   output 	 iwb_stb;   
   output [3:0]  iwb_sel;
   output [1:0]  fhart, mhart, dhart;
   
   input [31:2]  xbpc, xpc;   
   input [1:0] 	 xbra;

   input [3:0] 	 xsel;
   input [1:0]	 xstb;
   
   input 	 sclk, sena, srst;
   input [31:0]  mtvec;   

   assign iwb_sel = 4'hF;
   assign iwb_wre = 1'b0;
   
   // HART SWITCHER
   reg [1:0] 	     hart, dhart;
   wire [1:0] 	     whart = {hart[0],!hart[1]};   
   assign mhart = hart;   
   always @(posedge sclk)     
     if (srst) begin
	dhart <= 2'h3;	
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	hart <= 2'h0;
	// End of automatics
     end else if (sena) begin
	hart <= whart; // johnson counter to simplify resource usage
	dhart <= ~whart;	
     end
   // PC PIPELINE
   reg [31:0]    fpc;
   assign fhart = fpc[1:0];
   always @(posedge sclk)
     if (srst) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	fpc <= 32'h0;
	// End of automatics
     end else if (sena) begin 
	fpc <= {iwb_adr, hart};
     end

   // FETCH ADDRESS
   reg [31:2]    iwb_adr;
   assign iwb_stb = sena;   
   
   always @(posedge sclk)
     if (srst) begin
       /*AUTORESET*/
       // Beginning of autoreset for uninitialized flops
       iwb_adr <= 30'h0;
       // End of automatics
     end else if (sena) begin
	
	case ({xbra,&xstb})
	  3'b110,3'b001: iwb_adr <= mtvec[31:2]; // misaligned
	  3'b100: iwb_adr <= xbpc[31:2]; // Branch
	  default: iwb_adr <= xpc[31:2]; // PC4	 
	endcase // case (bra)
     end
   
endmodule // t5_inst
