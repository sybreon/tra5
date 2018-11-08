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
   pc, iadr,
   // Inputs
   idat, alu, npc, bra, clk, ena, rst
   );

   parameter XLEN = 32;

   output [XLEN-1:0] pc;   
   output [XLEN-1:2] iadr;
   input [XLEN-1:0]  idat;   

   input [XLEN-1:2] alu,
		    npc;   
   
   input 	     bra,
		     clk, 
		     ena, 
		     rst;
        
   reg [XLEN-1:2]    iadr;
   reg [1:0] 	     hart;   
   reg [XLEN-1:0]    pc;   

   // HART SWITCHER
   always @(posedge clk)
     if (rst)
       /*AUTORESET*/
       // Beginning of autoreset for uninitialized flops
       hart <= 2'h0;
       // End of automatics
     else if (ena)
       hart <= {hart[0],~hart[1]};   
   
   // PC REGISTER
   always @(posedge clk)
     if (rst)
       /*AUTORESET*/
       // Beginning of autoreset for uninitialized flops
       pc <= {XLEN{1'b0}};
       // End of automatics
     else if (ena)
       pc <= {iadr, hart};   
   
   // FETCH ADDRESS
   always @(posedge clk)
     if (rst)
       /*AUTORESET*/
       // Beginning of autoreset for uninitialized flops
       iadr <= {(1+(XLEN-1)-(2)){1'b0}};
       // End of automatics
     else if (ena)
       case (bra)
	 1'b1: iadr <= alu;
	 default: iadr <= npc;	   
       endcase // case (bra)     
   
endmodule // t5_inst
