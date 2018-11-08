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
