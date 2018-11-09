module t5_sim();
   localparam XLEN =32;   
   /*AUTOREGINPUT*/
   // Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
   reg			dwb_ack;		// To uut of t5_cpu.v
   reg [XLEN-1:0]	dwb_dti;		// To uut of t5_cpu.v
   reg [XLEN-1:0]	idat;			// To uut of t5_cpu.v
   reg			sexe;			// To uut of t5_cpu.v
   reg			sys_clk;		// To uut of t5_cpu.v
   reg			sys_ena;		// To uut of t5_cpu.v
   reg			sys_rst;		// To uut of t5_cpu.v
   // End of automatics

   always #5 sys_clk <= !sys_clk;

   integer randseed; ///< Random seed
   reg[31:0] timer0; ///< Fake timer
   
   initial begin
      // Initialise Random to command-line parameter.
      //if (!$value$plusargs("randseed=%d",  randseed)) randseed=42;
      //timer0 = $random(randseed);

      if ($value$plusargs("dumpfile=%s",  randseed)) begin
	 $dumpfile ("dump.vcd");
	 $dumpvars (2,uut);
      end
     
      sys_clk = $random;
      sys_rst = 1;
      sys_ena = 1;
      sexe = 0;
            
      #50 sys_rst = 0;      
      #5000 $displayh("\n*** TIMEOUT ", $stime, " ***"); $finish;
      
   end // initial begin
   
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [XLEN-1:2]	dwb_adr;		// From uut of t5_cpu.v
   wire [XLEN-1:0]	dwb_dto;		// From uut of t5_cpu.v
   wire [3:0]		dwb_sel;		// From uut of t5_cpu.v
   wire			dwb_stb;		// From uut of t5_cpu.v
   wire			dwb_wre;		// From uut of t5_cpu.v
   wire [XLEN-1:2]	iadr;			// From uut of t5_cpu.v
   // End of automatics

   // FAKE MEMORY ////////////////////////////////////////////////////////

   reg [31:0] 		rom[0:(1<<14)-1];
   reg [31:0] 		ram[0:(1<<14)-1];   
   wire [31:0] 		dwb_dat_t = ram[dwb_adr];   
   
   
   always @(posedge sys_clk) 
     if (sys_rst) begin
	/*AUTORESET*/
	// Beginning of autoreset for uninitialized flops
	dwb_ack <= 1'h0;
	idat <= 1'h0;
	// End of automatics
     end else begin
	// Include a certain random element in acks.
	dwb_ack <= dwb_stb & !dwb_ack & $random;
	idat <= rom[iadr];	
     end // else: !if(sys_rst_i)
   
   always @(posedge sys_clk) begin
      // SPECIAL PORTS
      if (dwb_wre & dwb_stb & dwb_ack) begin
	 case (dwb_sel)
	   4'h1: ram[dwb_adr] <= {dwb_dat_t[31:8], dwb_dto[7:0]};
	   4'h2: ram[dwb_adr] <= {dwb_dat_t[31:16], dwb_dto[15:8], dwb_dat_t[7:0]};
	   4'h4: ram[dwb_adr] <= {dwb_dat_t[31:24], dwb_dto[23:16], dwb_dat_t[15:0]};
	   4'h8: ram[dwb_adr] <= {dwb_dto[31:24], dwb_dat_t[23:0]};
	   4'h3: ram[dwb_adr] <= {dwb_dat_t[31:16], dwb_dto[15:0]};
	   4'hC: ram[dwb_adr] <= {dwb_dto[31:16], dwb_dat_t[15:0]};
	   4'hF: ram[dwb_adr] <= {dwb_dto};
	   default: begin
	      $displayh("*** ERROR WRITE @",{dwb_adr, 2'd0}, " ***");
	      //$finish;	      
	   end
	 endcase // case (dwb_sel_o)
      end // if (dwb_wre_o & dwb_stb_o & dwb_ack_i)
      
      if (dwb_stb & !dwb_wre) begin
	 case (dwb_sel)
	   4'h1,4'h2,4'h4,4'h8,4'h3,4'hC,4'hF: begin
	      dwb_dti <= ram[dwb_adr];		
	   end // case: 4'h1,4'h2,4'h4,4'h8,4'h3,4'hC,4'hF
	   default: begin // Wrong Select bits
	      dwb_dti <= 32'hX;	      
	      $displayh("*** ERROR READ  @",{dwb_adr,2'd0}, " ***");	      
	      //$finish;	      
	   end	   
	 endcase // case (dwb_sel_o)	 
      end
      
   end // always @ (posedge sys_clk_i)
   
   integer i;   
   initial begin
      for (i=0;i<(1<<14)-1;i=i+1) begin
	 ram[i] <= $random;
      end
      #1 $readmemh("dump.vmem",rom);
      #1 $readmemh("dump.vmem",ram);
   end

   t5_cpu
     #(/*AUTOINSTPARAM*/
       // Parameters
       .XLEN				(XLEN))
   uut
     (/*AUTOINST*/
      // Outputs
      .dwb_adr				(dwb_adr[XLEN-1:2]),
      .dwb_dto				(dwb_dto[XLEN-1:0]),
      .dwb_sel				(dwb_sel[3:0]),
      .dwb_stb				(dwb_stb),
      .dwb_wre				(dwb_wre),
      .iadr				(iadr[XLEN-1:2]),
      // Inputs
      .dwb_ack				(dwb_ack),
      .dwb_dti				(dwb_dti[XLEN-1:0]),
      .idat				(idat[XLEN-1:0]),
      .sexe				(sexe),
      .sys_clk				(sys_clk),
      .sys_ena				(sys_ena),
      .sys_rst				(sys_rst));   

endmodule // t5_sim

// Local Variables:
// verilog-library-directories:("." "../rtl/verilog/")
// verilog-library-files:("")
// End:
