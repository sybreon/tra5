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

module t5_sysc(/*AUTOARG*/
   // Outputs
   sclk, srst, sena,
   // Inputs
   sys_clk, sys_rst, sys_ena, xstb, dwb_ack
   );
   parameter XLEN = 32;

   output sclk;
   output srst;
   output sena;
   
   input  sys_clk;
   input  sys_rst;
   input  sys_ena;
   
   input [1:0] xstb;
   input  dwb_ack;   

   assign sclk = sys_clk;
   assign sena = sys_ena & !(xstb[1] ^ dwb_ack);

   reg [3:0] rst;
   assign srst = rst[3];
   
   always @(posedge sys_clk)
     if (sys_rst) begin
	rst <= 4'hF;	
	/*AUTORESET*/
     end else begin
	rst <= {rst[2:0],sys_rst};	
     end
   
endmodule // t5_sysc
