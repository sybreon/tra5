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

module t5_rv32i (/*AUTOARG*/
   // Outputs
   mpc, iwb_wre, iwb_stb, iwb_sel, iwb_adr, dwb_wre, dwb_stb, dwb_sel,
   dwb_dto, dwb_adr,
   // Inputs
   sys_rst, sys_ena, sys_clk, sexe, iwb_dat, dwb_dti, dwb_ack
   );
   parameter XLEN = 32;   
   /*AUTOOUTPUT*/
   // Beginning of automatic outputs (from unused autoinst outputs)
   output [31:2]	dwb_adr;		// From data of t5_data.v
   output [31:0]	dwb_dto;		// From data of t5_data.v
   output [3:0]		dwb_sel;		// From data of t5_data.v
   output		dwb_stb;		// From data of t5_data.v
   output		dwb_wre;		// From data of t5_data.v
   output [31:2]	iwb_adr;		// From inst of t5_inst.v
   output [3:0]		iwb_sel;		// From inst of t5_inst.v
   output		iwb_stb;		// From inst of t5_inst.v
   output		iwb_wre;		// From inst of t5_inst.v
   output [31:2]	mpc;			// From ctrl of t5_ctrl.v
   // End of automatics
   /*AUTOINPUT*/
   // Beginning of automatic inputs (from unused autoinst inputs)
   input		dwb_ack;		// To csys of t5_sysc.v
   input [31:0]		dwb_dti;		// To back of t5_back.v
   input [31:0]		iwb_dat;		// To back of t5_back.v, ...
   input		sexe;			// To ctrl of t5_ctrl.v
   input		sys_clk;		// To csys of t5_sysc.v
   input		sys_ena;		// To csys of t5_sysc.v
   input		sys_rst;		// To csys of t5_sysc.v, ...
   // End of automatics
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			dbra;			// From ctrl of t5_ctrl.v
   wire [31:0]		dcp1;			// From ctrl of t5_ctrl.v
   wire [31:0]		dcp2;			// From ctrl of t5_ctrl.v
   wire			dcsr;			// From ctrl of t5_ctrl.v
   wire			dexc;			// From ctrl of t5_ctrl.v
   wire [14:12]		dfn3;			// From ctrl of t5_ctrl.v
   wire [31:25]		dfn7;			// From ctrl of t5_ctrl.v
   wire [1:0]		dhart;			// From inst of t5_inst.v
   wire			djmp;			// From ctrl of t5_ctrl.v
   wire [31:0]		dop1;			// From ctrl of t5_ctrl.v
   wire [31:0]		dop2;			// From ctrl of t5_ctrl.v
   wire [6:2]		dopc;			// From ctrl of t5_ctrl.v
   wire			dsub;			// From ctrl of t5_ctrl.v
   wire [1:0]		fhart;			// From inst of t5_inst.v
   wire [31:0]		fpc;			// From inst of t5_inst.v
   wire [31:0]		malu;			// From aslu of t5_aslu.v
   wire [31:0]		mepc;			// From aslu of t5_aslu.v
   wire [1:0]		mhart;			// From inst of t5_inst.v
   wire [31:0]		mtvec;			// From aslu of t5_aslu.v
   wire			mwre;			// From back of t5_back.v
   wire [4:0]		rd0a;			// From back of t5_back.v
   wire [31:0]		rd0d;			// From back of t5_back.v
   wire [4:0]		rs1a;			// From ctrl of t5_ctrl.v
   wire [XLEN-1:0]	rs1d;			// From regs of t5_regs.v
   wire [4:0]		rs2a;			// From ctrl of t5_ctrl.v
   wire [XLEN-1:0]	rs2d;			// From regs of t5_regs.v
   wire			sclk;			// From csys of t5_sysc.v
   wire			sena;			// From csys of t5_sysc.v
   wire			srst;			// From csys of t5_sysc.v
   wire [31:2]		xbpc;			// From aslu of t5_aslu.v
   wire [1:0]		xbra;			// From aslu of t5_aslu.v
   wire [31:0]		xdat;			// From aslu of t5_aslu.v
   wire [31:2]		xepc;			// From ctrl of t5_ctrl.v
   wire [14:12]		xfn3;			// From aslu of t5_aslu.v
   wire [6:2]		xopc;			// From aslu of t5_aslu.v
   wire [31:2]		xpc;			// From ctrl of t5_ctrl.v
   wire [3:0]		xsel;			// From data of t5_data.v
   wire [1:0]		xstb;			// From data of t5_data.v, ...
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
	 .xstb				(xstb[1:0]),
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
	 .sclk				(sclk));
   
   t5_back #(/*AUTOINSTPARAM*/
	     // Parameters
	     .XLEN			(XLEN))
   back (/*AUTOINST*/
	 // Outputs
	 .rd0d				(rd0d[31:0]),
	 .rd0a				(rd0a[4:0]),
	 .mwre				(mwre),
	 // Inputs
	 .iwb_dat			(iwb_dat[11:7]),
	 .xopc				(xopc[6:2]),
	 .xfn3				(xfn3[14:12]),
	 .xstb				(xstb[1:0]),
	 .dwb_dti			(dwb_dti[31:0]),
	 .xsel				(xsel[3:0]),
	 .malu				(malu[31:0]),
	 .srst				(srst),
	 .sclk				(sclk),
	 .sena				(sena));
      
   t5_inst #(/*AUTOINSTPARAM*/
	     // Parameters
	     .XLEN			(XLEN))
   inst (/*AUTOINST*/
	 // Outputs
	 .fpc				(fpc[31:0]),
	 .iwb_adr			(iwb_adr[31:2]),
	 .iwb_wre			(iwb_wre),
	 .iwb_stb			(iwb_stb),
	 .iwb_sel			(iwb_sel[3:0]),
	 .fhart				(fhart[1:0]),
	 .mhart				(mhart[1:0]),
	 .dhart				(dhart[1:0]),
	 // Inputs
	 .xbpc				(xbpc[31:2]),
	 .xpc				(xpc[31:2]),
	 .xbra				(xbra[1:0]),
	 .xsel				(xsel[3:0]),
	 .xstb				(xstb[1:0]),
	 .sclk				(sclk),
	 .sena				(sena),
	 .srst				(srst),
	 .sys_rst			(sys_rst),
	 .mtvec				(mtvec[31:0]),
	 .mepc				(mepc[31:0]));

   t5_data #(/*AUTOINSTPARAM*/
	     // Parameters
	     .XLEN			(XLEN))
   data (/*AUTOINST*/
	 // Outputs
	 .dwb_adr			(dwb_adr[31:2]),
	 .dwb_dto			(dwb_dto[31:0]),
	 .dwb_sel			(dwb_sel[3:0]),
	 .dwb_wre			(dwb_wre),
	 .dwb_stb			(dwb_stb),
	 .xsel				(xsel[3:0]),
	 .xstb				(xstb[1:0]),
	 .xwre				(xwre),
	 // Inputs
	 .xbpc				(xbpc[31:2]),
	 .xdat				(xdat[31:0]),
	 .dopc				(dopc[6:2]),
	 .dfn3				(dfn3[14:12]),
	 .dcp1				(dcp1[1:0]),
	 .dcp2				(dcp2[1:0]),
	 .sclk				(sclk),
	 .srst				(srst),
	 .sena				(sena));
   
   t5_aslu #(/*AUTOINSTPARAM*/
	     // Parameters
	     .XLEN			(XLEN))
   aslu (/*AUTOINST*/
	 // Outputs
	 .xfn3				(xfn3[14:12]),
	 .malu				(malu[31:0]),
	 .xbpc				(xbpc[31:2]),
	 .xbra				(xbra[1:0]),
	 .xstb				(xstb[1:0]),
	 .xdat				(xdat[31:0]),
	 .xopc				(xopc[6:2]),
	 .mtvec				(mtvec[31:0]),
	 .mepc				(mepc[31:0]),
	 // Inputs
	 .xepc				(xepc[31:2]),
	 .dop1				(dop1[31:0]),
	 .dop2				(dop2[31:0]),
	 .dcp1				(dcp1[31:0]),
	 .dcp2				(dcp2[31:0]),
	 .dopc				(dopc[6:2]),
	 .dfn7				(dfn7[31:25]),
	 .dfn3				(dfn3[14:12]),
	 .xpc				(xpc[31:2]),
	 .dhart				(dhart[1:0]),
	 .xwre				(xwre),
	 .dexc				(dexc),
	 .dcsr				(dcsr),
	 .dsub				(dsub),
	 .dbra				(dbra),
	 .djmp				(djmp),
	 .sclk				(sclk),
	 .srst				(srst),
	 .sena				(sena));
      
   t5_ctrl #(/*AUTOINSTPARAM*/
	     // Parameters
	     .XLEN			(XLEN))
   ctrl (/*AUTOINST*/
	 // Outputs
	 .dfn3				(dfn3[14:12]),
	 .dfn7				(dfn7[31:25]),
	 .dop1				(dop1[31:0]),
	 .dop2				(dop2[31:0]),
	 .dcp1				(dcp1[31:0]),
	 .dcp2				(dcp2[31:0]),
	 .mpc				(mpc[31:2]),
	 .xpc				(xpc[31:2]),
	 .dopc				(dopc[6:2]),
	 .xepc				(xepc[31:2]),
	 .dexc				(dexc),
	 .dcsr				(dcsr),
	 .dsub				(dsub),
	 .dbra				(dbra),
	 .djmp				(djmp),
	 .rs1a				(rs1a[4:0]),
	 .rs2a				(rs2a[4:0]),
	 // Inputs
	 .fpc				(fpc[31:2]),
	 .iwb_dat			(iwb_dat[31:0]),
	 .rs2d				(rs2d[31:0]),
	 .rs1d				(rs1d[31:0]),
	 .fhart				(fhart[1:0]),
	 .sclk				(sclk),
	 .srst				(srst),
	 .sena				(sena),
	 .sexe				(sexe));
   
endmodule // tra5_cpu

