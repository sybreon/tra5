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

module t5_back(/*AUTOARG*/
   // Outputs
   rd0d, rd0a, mwre,
   // Inputs
   iwb_dat, xopc, xfn3, xstb, dwb_dti, xsel, malu, srst, sclk, sena
   );
   parameter XLEN = 32;

   output [31:0] rd0d;
   output [4:0]      rd0a;
   output 	     mwre;
   
   input [11:7]      iwb_dat;   
   input [6:2] 	     xopc;
   input [14:12]     xfn3;   
   input [1:0] 	     xstb;
   
   input [31:0]      dwb_dti;

   input [3:0] 	     xsel;   

   input [31:0]      malu;   
   
   input 	     srst, sclk, sena;   

   // TODO: Move to D-stage
   wire 	     btype = xopc[6] & !xopc[4] & !xopc[2];// (opc[6:2] == 5'b11000);
   wire 	     stype = !xopc[6] & xopc[5] & !xopc[4]; //(opc[6:2] == 5'b01000);
   
   assign rd0a = mrd;

   // OPCODE PIPELINE
   reg [6:2] 	     mopc;
   always @(posedge sclk)
     if (srst) begin
	mopc <= 5'h0D;	
	/*AUTORESET*/
     end else if (sena) begin
	mopc <= xopc;	
     end

   // MEMORY EXTENSION
   reg [XLEN-1:0]    dext;
   always @(posedge sclk)
     if (srst) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	dext <= {XLEN{1'b0}};
	// End of automatics
     end else if (sena) begin
	case (xsel)
	  4'h1: begin
	     dext[7:0] <= dwb_dti[7:0];
	     dext[XLEN-1:8] <= (xfn3[14]) ? 24'd0 : {24{dwb_dti[7]}};	   
	  end
	  4'h2: begin
	     dext[7:0] <= dwb_dti[15:8];
	     dext[XLEN-1:8] <= (xfn3[14]) ? 24'd0 : {24{dwb_dti[15]}};	   
	  end
	  4'h4: begin
	     dext[7:0] <= dwb_dti[23:16];
	     dext[XLEN-1:8] <= (xfn3[14]) ? 24'd0 : {24{dwb_dti[23]}};	   
	  end
	  4'h8: begin
	     dext[7:0] <= dwb_dti[31:24];
	     dext[XLEN-1:8] <= (xfn3[14]) ? 24'd0 : {24{dwb_dti[31]}};	   
	  end
	  4'h3: begin
	     dext[15:0] <= dwb_dti[15:0];
	     dext[XLEN-1:16] <= (xfn3[14]) ? 16'd0 : {16{dwb_dti[15]}}; 
	  end
	  4'hC: begin
	     dext[15:0] <= dwb_dti[31:16];
	     dext[XLEN-1:16] <= (xfn3[14]) ? 16'd0 : {16{dwb_dti[31]}}; 
	  end
	  4'hF: begin
	     dext <= dwb_dti;	   
	  end
	  default: dext <= 32'hX;	
	endcase // case (xsel)      
     end

   // SELECTOR
   reg [XLEN-1:0] dmux;
   assign rd0d = dmux;   
   always @(/*AUTOSENSE*/dext or malu or mopc) begin
      dmux = (mopc == 5'd0) ? dext : malu;      
   end   
   
   // RD
   reg [4:0] 	     drd, xrd, mrd;   
   always @(posedge sclk)
     if (srst) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	drd <= 5'h0;
	mrd <= 5'h0;
	xrd <= 5'h0;
	// End of automatics
     end else if (sena) begin
	mrd <= xrd;
	xrd <= drd;
	drd <= iwb_dat[11:7];	
     end

   
   // WRE
   reg mwre;   
   always @(posedge sclk)
     if (srst) begin
	mwre <= 1'b1;	
	/*AUTORESET*/
     end else if (sena) begin
	mwre <= ~&xstb & |xrd & !stype & !btype;	
     end
   
endmodule // t5_back
