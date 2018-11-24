#include "verilated.h"
#include "verilated_vcd_c.h"
#include "Vt5_rv32i.h"
#include <iostream>
#include <cstdint>

#define RAMSIZE 1<<16 // 64k words
uint32_t * ram;

int main(int argc, char** argv, char** env) {
  Vt5_rv32i *cpu;
  uint32_t cnt = 0;

  Verilated::commandArgs(argc, argv);

  cpu = new Vt5_rv32i;
  ram = new uint32_t [RAMSIZE];

  // LOAD RAM
  
  // VCD DUMP
  Verilated::traceEverOn(true);
  VerilatedVcdC* tfp = new VerilatedVcdC;
  cpu->trace(tfp, 99);
  tfp->open("dump.vcd");

  // RESET
  std::cout << "RESET CPU" << std::endl;
  
  cpu->sys_rst = 1;
  cpu->sys_ena = 1;
  cpu->sys_clk = 1;  

  for (; cnt < 50; cnt = cnt+5) {
    cpu->eval();
    tfp->dump(cnt);
    cpu->sys_clk = !cpu->sys_clk;
  }

  cpu->sys_rst = 0;
  
  // RUN
  std::cout << "START SIM" << std::endl;
  for (; !Verilated::gotFinish(); cnt = cnt+5) {
    cpu->eval();    
    tfp->dump(cnt);
    cpu->sys_clk = !cpu->sys_clk;

    if (cpu->sys_clk) 
      {
	cpu->iwb_dat = ram[cpu->iwb_adr];	
      }    
  }

  // FREE
  tfp->close();
  delete tfp;  
  delete cpu;  
  delete ram;
  return 0;
}
