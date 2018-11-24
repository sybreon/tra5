#include "verilated.h"
#include "verilated_vcd_c.h"
#include "Vt5_rv32i.h"
#include <iostream>
#include <fstream>
#include <cstdint>
#include <vector>
#include <cstdlib>
#include <iomanip>

#define RAMSIZE 1<<16 // 64k words
std::vector<char> buf(RAMSIZE);

int main(int argc, char** argv, char** env) {
  Vt5_rv32i *cpu;
  uint32_t cnt = 0;

  Verilated::commandArgs(argc, argv);

  cpu = new Vt5_rv32i;
  //buf = new char [RAMSIZE];

  // LOAD RAM
  std::ifstream bin("elf.bin", std::ios::binary);
  bin.read(buf.data(), RAMSIZE);
  bin.close();

  uint32_t * ram = (uint32_t*) buf.data();
    
  // VCD DUMP
  Verilated::traceEverOn(true);
  VerilatedVcdC* tfp = new VerilatedVcdC;
  cpu->trace(tfp, 99);
  tfp->open("dump.vcd");

  // RESET
  std::cout << "RESET CPU" << std::endl;
  
  cpu->sys_rst = 1;
  cpu->sys_ena = 1;
  cpu->sys_clk = 0;  
  cpu->eval();
  tfp->dump(0);

  
  // RUN
  uint32_t iadr, dadr, dat, wadr;
  std::cout << "START SIM" << std::endl;
  for (cnt = 10; !Verilated::gotFinish() && cnt < 10000; cnt += 10) {
    // Rising Edge
    if (!cpu->sys_rst) {
      iadr = cpu->iwb_adr;

      if (cpu->dwb_stb) {
	dadr = cpu->dwb_adr;
	// RAM WRITE
	if (cpu->dwb_wre && cpu->dwb_ack) {
	  dat = ram[dadr];
	  
	  switch(cpu->dwb_sel) {
	  case 0xF: dat = cpu->dwb_dto; break;
	  case 0xC: dat = (dat & 0x0000FFFF) | (cpu->dwb_dto & 0xFFFF0000); break;
	  case 0x3: dat = (dat & 0xFFFF0000) | (cpu->dwb_dto & 0x0000FFFF); break;
	  case 0x1: dat = (dat & 0xFFFFFF00) | (cpu->dwb_dto & 0x000000FF); break;
	  case 0x2: dat = (dat & 0xFFFF00FF) | (cpu->dwb_dto & 0x0000FF00); break;
	  case 0x4: dat = (dat & 0xFF00FFFF) | (cpu->dwb_dto & 0x00FF0000); break;
	  case 0x8: dat = (dat & 0x00FFFFFF) | (cpu->dwb_dto & 0xFF000000); break;
	  default: dat = std::rand(); // replace with random
	  }	  

	  ram[dadr] = dat;
	  std::cerr << "W " << std::hex << (dadr << 2) << "<=" << std::setfill('0') << std::setw(8) << std::hex << dat << std::endl;

	}

	    if (!cpu->dwb_wre && cpu->dwb_ack) 
	      std::cout << "R " << std::hex << (dadr << 2) << "=>" << std::setfill('0') << std::setw(8) << std::hex << cpu->dwb_dti <<std::endl;
	
      }
      
      cpu->dwb_ack = cpu->dwb_stb & !cpu->dwb_ack;      
    }
    
    cpu->sys_clk = 1;
    cpu->eval();
    tfp->dump(cnt);

    // Falling Edge
    if (!cpu->sys_rst) {
      if (iadr << 2 > buf.size()) break;      
      cpu->iwb_dat = ram[iadr];

      if (cpu->dwb_stb) {
	cpu->dwb_dti = ram[dadr];
      }
    }
    if (cnt == 50) cpu->sys_rst = 0;

    cpu->sys_clk = 0;
    cpu->eval();    
    tfp->dump(cnt+1);
    tfp->flush();

    if (cpu->iwb_dat == 0x073) {
      break;
    }
  }

  // FREE
  tfp->close();
  delete tfp;  
  delete cpu;  
  return 0;
}
