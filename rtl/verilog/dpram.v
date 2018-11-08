// 32x64 = 77
// 64x32 = 146

module dpram (/*AUTOARG*/
   // Outputs
   dat_o, xdat_o,
   // Inputs
   adr_i, dat_i, wre_i, xadr_i, xdat_i, xwre_i, clk_i, ena_i
   ) ;
   parameter AW = 5; // 32
   parameter DW = 2; // x2

   // PORT A - READ/WRITE
   output [DW-1:0] dat_o;  
   input [AW-1:0]  adr_i;
   input [DW-1:0]  dat_i;
   input 	   wre_i;
   
   // PORT X - READ ONLY
   output [DW-1:0] xdat_o;  
   input [AW-1:0]  xadr_i;
   input [DW-1:0]  xdat_i;
   input 	   xwre_i;
   
   // SYSCON
   input 	   clk_i, 
		   ena_i;

   /*AUTOREG*/   
   reg [DW-1:0]    rRAM [(1<<AW)-1:0];
   
   always @(posedge clk_i)
     if (wre_i & ena_i) rRAM[adr_i] <= dat_i;	
   
   assign 	   dat_o = rRAM[adr_i];
   assign 	   xdat_o = rRAM[xadr_i];   
   
   // --- SIMULATION ONLY ------------------------------------
   // synopsys translate_off
   integer 	   i;
   initial begin
      for (i=0; i<(1<<AW); i=i+1) 
	begin
	   rRAM[i] <= {(DW){1'b0}};
	end
   end
   // synopsys translate_on
   
endmodule // dpram

