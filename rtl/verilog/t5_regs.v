// 200@207

module t5_regs (/*AUTOARG*/
   // Outputs
   rs2d, rs1d,
   // Inputs
   sena, sclk, rs2a, rs1a, rd0d, rd0a, mwre, mhart, fhart, dwb_dti,
   malu, mpc
   );
   parameter XLEN = 32;
   
   /*AUTOOUTPUT*/
   // Beginning of automatic outputs (from unused autoinst outputs)
   output [XLEN-1:0]	rs1d;			// From gprf of t5_gprf.v
   output [XLEN-1:0]	rs2d;			// From gprf of t5_gprf.v
   // End of automatics
   /*AUTOINPUT*/
   // Beginning of automatic inputs (from unused autoinst inputs)
   input [1:0]		fhart;			// To gprf of t5_gprf.v
   input [1:0]		mhart;			// To gprf of t5_gprf.v
   input		mwre;			// To gprf of t5_gprf.v
   input [4:0]		rd0a;			// To gprf of t5_gprf.v
   input [XLEN-1:0]	rd0d;			// To gprf of t5_gprf.v
   input [4:0]		rs1a;			// To gprf of t5_gprf.v
   input [4:0]		rs2a;			// To gprf of t5_gprf.v
   input		sclk;			// To gprf of t5_gprf.v
   input		sena;			// To gprf of t5_gprf.v
   // End of automatics
   /*AUTOWIRE*/

   input [XLEN-1:0] 	dwb_dti;
   input [XLEN-1:0] 	malu;
   input [XLEN-1:0] 	mpc;

   // TODO: Add special function registers
      
   t5_gprf
     #(/*AUTOINSTPARAM*/
       // Parameters
       .XLEN				(XLEN))
   gprf
     (/*AUTOINST*/
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
      .sena				(sena));

endmodule // tra5_regs

