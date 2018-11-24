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
   fpc, iwb_adr, iwb_stb, iwb_wre, iwb_sel, fhart, mhart,
   // Inputs
   iwb_dat, xbpc, xpc, iwb_ack, xbra, sclk, sena, srst
   );

   parameter XLEN = 32;

   output [31:0] fpc;   
   output [31:2] iwb_adr;
   output 	 iwb_stb, iwb_wre;
   output [3:0]  iwb_sel;
   output [1:0]  fhart, mhart;
   
   input [31:0]  iwb_dat;
   input [31:0]  xbpc, xpc;   
   input 	 iwb_ack;   
   input 	 xbra, sclk, sena, srst;

   assign iwb_sel = 4'hF;
   assign iwb_wre = 1'b0;
   assign iwb_stb = 1'b1;   
   
   // HART SWITCHER
   reg [1:0] 	     hart;   
   assign mhart = hart;
   
   always @(posedge sclk)     
     if (srst)
       /*AUTORESET*/
       // Beginning of autoreset for uninitialized flops
       hart <= 2'h0;
       // End of automatics
     else if (sena)
       hart <= {hart[0],!hart[1]}; // johnson counter to simplify resource usage
   
   // PC PIPELINE
   reg [31:0]    fpc;   
   assign fhart = fpc[1:0];
   always @(posedge sclk)
     if (srst)
       /*AUTORESET*/
       // Beginning of autoreset for uninitialized flops
       fpc <= 32'h0;
       // End of automatics
     else if (sena)
       fpc <= {iwb_adr, hart};

   // FETCH ADDRESS
   reg [31:2]    iwb_adr;
   always @(posedge sclk)
     if (srst)
       /*AUTORESET*/
       // Beginning of autoreset for uninitialized flops
       iwb_adr <= 30'h0;
       // End of automatics
     else if (sena) begin
       case (xbra)
	 1'b1: iwb_adr <= xbpc[XLEN-1:2];
	 default: iwb_adr <= xpc[XLEN-1:2]; // PC4	 
       endcase // case (bra)
     end
   
endmodule // t5_inst
