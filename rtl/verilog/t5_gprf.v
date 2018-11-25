module t5_gprf(/*AUTOARG*/
   // Outputs
   rs2d, rs1d,
   // Inputs
   sclk, rs2a, rs1a, rd0d, rd0a, mwre, mhart, fhart
   );
   parameter XLEN = 32;
   localparam AW = 7;   

   /*AUTOOUTPUT*/
   // Beginning of automatic outputs (from unused autoinst outputs)
   output [XLEN-1:0]	rs1d;			// From rs1 of dpram.v
   output [XLEN-1:0]	rs2d;			// From rs2 of dpram.v
   // End of automatics
   /*AUTOINPUT*/
   // Beginning of automatic inputs (from unused autoinst inputs)
   input [1:0]		fhart;			// To rs1 of dpram.v, ...
   input [1:0]		mhart;			// To rs1 of dpram.v, ...
   input		mwre;			// To rs1 of dpram.v, ...
   input [4:0]		rd0a;			// To rs1 of dpram.v, ...
   input [XLEN-1:0]	rd0d;			// To rs1 of dpram.v, ...
   input [4:0]		rs1a;			// To rs1 of dpram.v
   input [4:0]		rs2a;			// To rs2 of dpram.v
   input		sclk;			// To rs1 of dpram.v, ...
   // End of automatics
   
   /* dpram AUTO_TEMPLATE (
    .AW(AW), 
    .DW(XLEN),
    
    .clk_i(sclk),
    .ena_i(1'b1),
    
    .dat_i(rd0d[XLEN-1:0]),
    .adr_i({mhart[1:0],rd0a[4:0]}),
    .wre_i(mwre),
    .dat_o(),    

    .xadr_i({fhart[1:0],rs@a[4:0]}),
    .xdat_o(rs@d[XLEN-1:0]),
    ) */
   
   dpram #(/*AUTOINSTPARAM*/
	   // Parameters
	   .AW				(AW),			 // Templated
	   .DW				(XLEN))			 // Templated
   rs1 (/*AUTOINST*/
	// Outputs
	.dat_o				(),			 // Templated
	.xdat_o				(rs1d[XLEN-1:0]),	 // Templated
	// Inputs
	.adr_i				({mhart[1:0],rd0a[4:0]}), // Templated
	.dat_i				(rd0d[XLEN-1:0]),	 // Templated
	.wre_i				(mwre),			 // Templated
	.xadr_i				({fhart[1:0],rs1a[4:0]}), // Templated
	.clk_i				(sclk),			 // Templated
	.ena_i				(1'b1));			 // Templated
   
   dpram #(/*AUTOINSTPARAM*/
	   // Parameters
	   .AW				(AW),			 // Templated
	   .DW				(XLEN))			 // Templated
   rs2 (/*AUTOINST*/
	// Outputs
	.dat_o				(),			 // Templated
	.xdat_o				(rs2d[XLEN-1:0]),	 // Templated
	// Inputs
	.adr_i				({mhart[1:0],rd0a[4:0]}), // Templated
	.dat_i				(rd0d[XLEN-1:0]),	 // Templated
	.wre_i				(mwre),			 // Templated
	.xadr_i				({fhart[1:0],rs2a[4:0]}), // Templated
	.clk_i				(sclk),			 // Templated
	.ena_i				(1'b1));			 // Templated
      
endmodule // tra5_regfile
