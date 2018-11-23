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

module t5_cpu (/*AUTOARG*/
   // Outputs
   iadr, dwb_wre, dwb_stb, dwb_sel, dwb_dto, dwb_adr,
   // Inputs
   sys_rst, sys_ena, sys_clk, sexe, idat, dwb_dti, dwb_ack
   );
   parameter XLEN = 32;   
   /*AUTOOUTPUT*/
   // Beginning of automatic outputs (from unused autoinst outputs)
   output [XLEN-1:2]	dwb_adr;		// From data of t5_data.v
   output [XLEN-1:0]	dwb_dto;		// From data of t5_data.v
   output [3:0]		dwb_sel;		// From data of t5_data.v
   output		dwb_stb;		// From data of t5_data.v
   output		dwb_wre;		// From data of t5_data.v
   output [XLEN-1:2]	iadr;			// From inst of t5_inst.v
   // End of automatics
   /*AUTOINPUT*/
   // Beginning of automatic inputs (from unused autoinst inputs)
   input		dwb_ack;		// To csys of t5_sysc.v, ...
   input [XLEN-1:0]	dwb_dti;		// To regs of t5_regs.v, ...
   input [XLEN-1:0]	idat;			// To back of t5_back.v, ...
   input		sexe;			// To ctrl of t5_ctrl.v
   input		sys_clk;		// To csys of t5_sysc.v
   input		sys_ena;		// To csys of t5_sysc.v
   input		sys_rst;		// To csys of t5_sysc.v
   // End of automatics
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [XLEN-1:0]	dcp1;			// From ctrl of t5_ctrl.v
   wire [XLEN-1:0]	dcp2;			// From ctrl of t5_ctrl.v
   wire [14:12]		dfn3;			// From ctrl of t5_ctrl.v
   wire [31:25]		dfn7;			// From ctrl of t5_ctrl.v
   wire [XLEN-1:0]	dop1;			// From ctrl of t5_ctrl.v
   wire [XLEN-1:0]	dop2;			// From ctrl of t5_ctrl.v
   wire [6:2]		dopc;			// From ctrl of t5_ctrl.v
   wire [1:0]		fhart;			// From ctrl of t5_ctrl.v
   wire [XLEN-1:0]	fpc;			// From inst of t5_inst.v
   wire [XLEN-1:0]	malu;			// From aslu of t5_aslu.v
   wire [1:0]		mhart;			// From back of t5_back.v
   wire [XLEN-1:0]	mpc;			// From ctrl of t5_ctrl.v
   wire			mwre;			// From back of t5_back.v
   wire [4:0]		rd0a;			// From back of t5_back.v
   wire [XLEN-1:0]	rd0d;			// From back of t5_back.v
   wire [4:0]		rs1a;			// From ctrl of t5_ctrl.v
   wire [XLEN-1:0]	rs1d;			// From regs of t5_regs.v
   wire [4:0]		rs2a;			// From ctrl of t5_ctrl.v
   wire [XLEN-1:0]	rs2d;			// From regs of t5_regs.v
   wire			sclk;			// From csys of t5_sysc.v
   wire			sena;			// From csys of t5_sysc.v
   wire			srst;			// From csys of t5_sysc.v
   wire			sysc;			// From ctrl of t5_ctrl.v
   wire [XLEN-1:0]	xbpc;			// From aslu of t5_aslu.v
   wire			xbra;			// From aslu of t5_aslu.v
   wire [XLEN-1:0]	xdat;			// From aslu of t5_aslu.v
   wire [XLEN-1:2]	xepc;			// From ctrl of t5_ctrl.v
   wire [14:12]		xfn3;			// From aslu of t5_aslu.v
   wire [6:2]		xopc;			// From aslu of t5_aslu.v
   wire [XLEN-1:0]	xpc;			// From ctrl of t5_ctrl.v
   wire [3:0]		xsel;			// From data of t5_data.v
   wire			xstb;			// From data of t5_data.v
   wire			xwre;			// From data of t5_data.v
   // End of automatics
   /*AUTOREG*/

   t5_sysc #(/*AUTOINSTPARAM*/
	     // Parameters
	     .XLEN			(XLEN))
   csys (/*AUTOINST*/
	 // Outputs
	 .sclk				(sclk),
	 .srst				(srst),
	 .sena				(sena),
	 // Inputs
	 .sys_clk			(sys_clk),
	 .sys_rst			(sys_rst),
	 .sys_ena			(sys_ena),
	 .xstb				(xstb),
	 .dwb_ack			(dwb_ack));
   
   
   t5_regs #(/*AUTOINSTPARAM*/
	     // Parameters
	     .XLEN			(XLEN))
   regs (/*AUTOINST*/
	 // Outputs
	 .rs1d				(rs1d[XLEN-1:0]),
	 .rs2d				(rs2d[XLEN-1:0]),
	 // Inputs
	 .fhart				(fhart[1:0]),
	 .mhart				(mhart[1:0]),
	 .mwre				(mwre),
	 .rd0a				(rd0a[4:0]),
	 .rd0d				(rd0d[XLEN-1:0]),
	 .rs1a				(rs1a[4:0]),
	 .rs2a				(rs2a[4:0]),
	 .sclk				(sclk),
	 .sena				(sena),
	 .dwb_dti			(dwb_dti[XLEN-1:0]),
	 .malu				(malu[XLEN-1:0]),
	 .mpc				(mpc[XLEN-1:0]));
   
   t5_back #(/*AUTOINSTPARAM*/
	     // Parameters
	     .XLEN			(XLEN))
   back (/*AUTOINST*/
	 // Outputs
	 .rd0d				(rd0d[XLEN-1:0]),
	 .rd0a				(rd0a[4:0]),
	 .mhart				(mhart[1:0]),
	 .mwre				(mwre),
	 // Inputs
	 .idat				(idat[31:0]),
	 .xopc				(xopc[6:2]),
	 .xfn3				(xfn3[14:12]),
	 .dwb_dti			(dwb_dti[XLEN-1:0]),
	 .xsel				(xsel[3:0]),
	 .dwb_ack			(dwb_ack),
	 .xstb				(xstb),
	 .xwre				(xwre),
	 .mpc				(mpc[XLEN-1:0]),
	 .malu				(malu[XLEN-1:0]),
	 .srst				(srst),
	 .sclk				(sclk),
	 .sena				(sena));
      
   t5_inst #(/*AUTOINSTPARAM*/
	     // Parameters
	     .XLEN			(XLEN))
   inst (/*AUTOINST*/
	 // Outputs
	 .fpc				(fpc[XLEN-1:0]),
	 .iadr				(iadr[XLEN-1:2]),
	 // Inputs
	 .idat				(idat[XLEN-1:0]),
	 .xbpc				(xbpc[XLEN-1:0]),
	 .xpc				(xpc[XLEN-1:0]),
	 .xbra				(xbra),
	 .sclk				(sclk),
	 .sena				(sena),
	 .srst				(srst));

   t5_data #(/*AUTOINSTPARAM*/
	     // Parameters
	     .XLEN			(XLEN))
   data (/*AUTOINST*/
	 // Outputs
	 .dwb_adr			(dwb_adr[XLEN-1:2]),
	 .dwb_dto			(dwb_dto[XLEN-1:0]),
	 .dwb_sel			(dwb_sel[3:0]),
	 .dwb_wre			(dwb_wre),
	 .dwb_stb			(dwb_stb),
	 .xsel				(xsel[3:0]),
	 .xstb				(xstb),
	 .xwre				(xwre),
	 // Inputs
	 .dwb_dti			(dwb_dti[XLEN-1:0]),
	 .dwb_ack			(dwb_ack),
	 .xbpc				(xbpc[XLEN-1:0]),
	 .xdat				(xdat[XLEN-1:0]),
	 .dopc				(dopc[6:2]),
	 .dfn3				(dfn3[14:12]),
	 .dop1				(dop1[1:0]),
	 .dop2				(dop2[1:0]),
	 .sclk				(sclk),
	 .srst				(srst),
	 .sena				(sena));
   
   t5_aslu #(/*AUTOINSTPARAM*/
	     // Parameters
	     .XLEN			(XLEN))
   aslu (/*AUTOINST*/
	 // Outputs
	 .malu				(malu[XLEN-1:0]),
	 .xbpc				(xbpc[XLEN-1:0]),
	 .xbra				(xbra),
	 .xdat				(xdat[XLEN-1:0]),
	 .xopc				(xopc[6:2]),
	 .xfn3				(xfn3[14:12]),
	 // Inputs
	 .dop1				(dop1[XLEN-1:0]),
	 .dop2				(dop2[XLEN-1:0]),
	 .dcp1				(dcp1[XLEN-1:0]),
	 .dcp2				(dcp2[XLEN-1:0]),
	 .dopc				(dopc[6:2]),
	 .dfn7				(dfn7[31:25]),
	 .dfn3				(dfn3[14:12]),
	 .xpc				(xpc[XLEN-1:0]),
	 .xepc				(xepc[XLEN-1:2]),
	 .sysc				(sysc),
	 .sclk				(sclk),
	 .srst				(srst),
	 .sena				(sena));
      
   t5_ctrl #(/*AUTOINSTPARAM*/
	     // Parameters
	     .XLEN			(XLEN))
   ctrl (/*AUTOINST*/
	 // Outputs
	 .dop1				(dop1[XLEN-1:0]),
	 .dop2				(dop2[XLEN-1:0]),
	 .dcp1				(dcp1[XLEN-1:0]),
	 .dcp2				(dcp2[XLEN-1:0]),
	 .mpc				(mpc[XLEN-1:0]),
	 .xpc				(xpc[XLEN-1:0]),
	 .xepc				(xepc[XLEN-1:2]),
	 .dopc				(dopc[6:2]),
	 .dfn3				(dfn3[14:12]),
	 .dfn7				(dfn7[31:25]),
	 .sysc				(sysc),
	 .rs1a				(rs1a[4:0]),
	 .rs2a				(rs2a[4:0]),
	 .fhart				(fhart[1:0]),
	 // Inputs
	 .fpc				(fpc[XLEN-1:0]),
	 .idat				(idat[XLEN-1:0]),
	 .rs2d				(rs2d[XLEN-1:0]),
	 .rs1d				(rs1d[XLEN-1:0]),
	 .sclk				(sclk),
	 .srst				(srst),
	 .sena				(sena),
	 .sexe				(sexe));
   
endmodule // tra5_cpu

