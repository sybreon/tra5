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

module t5_inst(/*AUTOARG*/
   // Outputs
   fpc, iadr,
   // Inputs
   idat, xbpc, xpc, xbra, sclk, sena, srst
   );

   parameter XLEN = 32;

   output [XLEN-1:0] fpc;   
   output [XLEN-1:2] iadr;
   
   input [XLEN-1:0]  idat;      
   input [XLEN-1:0]  xbpc, xpc;   
   
   input 	     xbra, sclk, sena, srst;
   
   // HART SWITCHER
   reg [1:0] 	     hart;      
   always @(posedge sclk)     
     if (srst)
       /*AUTORESET*/
       // Beginning of autoreset for uninitialized flops
       hart <= 2'h0;
       // End of automatics
     else if (sena)
       hart <= {hart[0],~hart[1]}; // johnson counter to simplify resource usage
   
   // PC REGISTER
   reg [XLEN-1:0]    fpc;   
   always @(posedge sclk)
     if (srst)
       /*AUTORESET*/
       // Beginning of autoreset for uninitialized flops
       fpc <= {XLEN{1'b0}};
       // End of automatics
     else if (sena)
       fpc <= {iadr, hart};

   // FETCH ADDRESS
   reg [XLEN-1:2]    iadr;
   always @(posedge sclk)
     if (srst)
       /*AUTORESET*/
       // Beginning of autoreset for uninitialized flops
       iadr <= {(1+(XLEN-1)-(2)){1'b0}};
       // End of automatics
     else if (sena) begin
       case (xbra)
	 1'b1: iadr <= xbpc[XLEN-1:2];
	 default: iadr <= xpc[XLEN-1:2];	   
       endcase // case (bra)
     end
   
endmodule // t5_inst
