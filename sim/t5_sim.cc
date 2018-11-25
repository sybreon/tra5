#include "verilated.h"
#include "verilated_vcd_c.h"
#include "Vt5_rv32i.h"
#include <iostream>
#include <fstream>
#include <cstdint>
#include <vector>
#include <cstdlib>
#include <iomanip>
#include <sstream>
#include <string>
#include <iterator>
#include <algorithm>

#define RAMSIZE 1<<20 // 64k words
#define TRACE

// Command line arguments
// 1 - BIN FILE
// 2 - OUT FILE
// 3 - BEGIN SIGNATURE
// 4 - END SIGNATURE

int main(int argc, char** argv, char** env) {
  Vt5_rv32i *cpu;
  uint32_t cnt = 0;

  if (argc < 5) exit(-1);
  
  Verilated::commandArgs(argc, argv);
  
  cpu = new Vt5_rv32i;

  // LOAD RAM
  std::cout << "BIN:" << argv[1];
  std::ifstream bin(argv[1], std::ios::binary);
  std::vector<char> buf(std::istreambuf_iterator<char>{bin}, {});
  std::cout << "(" << buf.size() << ")" << std::endl;  
  buf.resize(RAMSIZE);  
  bin.close();

  uint32_t * ram = (uint32_t*) buf.data();
    
  // VCD DUMP
#ifdef TRACE
  Verilated::traceEverOn(true);
  VerilatedVcdC* tfp = new VerilatedVcdC;
  cpu->trace(tfp, 99);
  tfp->open("dump.vcd");
#endif
  
  // RESET
  std::cout << "RESET CPU" << std::endl;
  
  cpu->sys_rst = 1;
  cpu->sys_ena = 1;
  cpu->sys_clk = 0;
  cpu->sexe = 0;
  //  cpu->iwb_ack = 1;  
  for (cnt=0; !Verilated::gotFinish() && cnt < 10; cnt++) {
    cpu->eval();
  }
#ifdef TRACE
  tfp->dump(0);
#endif
  
  // RUN
  uint32_t iadr, dadr, dat, wadr;
  std::cout << "START SIM" << std::endl;
  for (cnt = 10; !Verilated::gotFinish() && cnt < 200000; cnt += 10) {
    //    std::cerr << "PC " << std::hex << cpu->iwb_adr << std::endl;
    cpu->sys_clk = 0;
    cpu->eval();
    // Rising Edge
    if (!cpu->sys_rst) {
      if (cpu->iwb_stb)
	iadr = cpu->iwb_adr & 0x1FFFFFFF;
      if (iadr << 2 >= buf.size()) {
	std::cerr << "ERR IADR " << std::hex << iadr << std::endl;
	break;
      }

      if (cpu->dwb_stb) {
	dadr = cpu->dwb_adr & 0x1FFFFFFF;
	if (cpu->dwb_wre && cpu->dwb_ack) {
	  // RAM WRITE
	  if (dadr << 2 < buf.size()) {
	    
	    dat = ram[dadr];
	    
	    switch(cpu->dwb_sel) {
	    case 0xF: dat = cpu->dwb_dto; break;
	    case 0xC: dat = (dat & 0x0000FFFF) | (cpu->dwb_dto & 0xFFFF0000); break;
	    case 0x3: dat = (dat & 0xFFFF0000) | (cpu->dwb_dto & 0x0000FFFF); break;
	    case 0x1: dat = (dat & 0xFFFFFF00) | (cpu->dwb_dto & 0x000000FF); break;
	    case 0x2: dat = (dat & 0xFFFF00FF) | (cpu->dwb_dto & 0x0000FF00); break;
	    case 0x4: dat = (dat & 0xFF00FFFF) | (cpu->dwb_dto & 0x00FF0000); break;
	    case 0x8: dat = (dat & 0x00FFFFFF) | (cpu->dwb_dto & 0xFF000000); break;
	    }	  
	    
	    ram[dadr] = dat;
	    std::cout << "ST " << std::hex << (dadr << 2) << "<=" << std::setfill('0') << std::setw(8) << std::hex << dat << std::endl;
	  } else {
	    // IO
	    dat = cpu->dwb_dto;	    
	    
	    switch(dadr) {
	    default:	      
	      std::cout << "IO " << std::hex << (dadr << 2) << "<=" << std::setfill('0') << std::setw(8) << std::hex << dat << std::endl;
	    }
	  }
	}

	if (!cpu->dwb_wre && cpu->dwb_ack) {
	  if (dadr << 2 < buf.size()) {
	    std::cout << "LD " << std::hex << (dadr << 2) << "=>" << std::setfill('0') << std::setw(8) << std::hex << cpu->dwb_dti <<std::endl;
	  } else {
	    switch(dadr << 2)	      {
	    case 0x40000000: cpu->dwb_dti = cnt;	      
	    }
	    
	    std::cout << "IO " << std::hex << (dadr << 2) << "=>" << std::setfill('0') << std::setw(8) << std::hex << cpu->dwb_dti <<std::endl;	  }
	}
	
      }
      
      cpu->dwb_ack = cpu->dwb_stb & !cpu->dwb_ack;      
    }
    
    cpu->sys_clk = 1;
    cpu->eval();
#ifdef TRACE
    tfp->dump(cnt);
#endif
    
    cpu->sys_clk = 1;
    cpu->eval();
    // Falling Edge
    if (!cpu->sys_rst) {
	cpu->iwb_dat = ram[iadr];
	if (dadr << 2 < buf.size()) 	  {	    
	  cpu->dwb_dti = ram[dadr];
	} else 	  {
	  cpu->dwb_dti = 0;	  
	}
	
    }
    if (cnt == 50) cpu->sys_rst = 0;

    cpu->sys_clk = 0;
    cpu->eval();
#ifdef TRACE
    tfp->dump(cnt+1);
    tfp->flush();
#endif
    
    if (cpu->iwb_dat == 0x073) {
      std::cerr << "ECALL END" << std::endl;
      break;
    }
  }
  
  // DUMP SIGNATURE
  uint32_t signa, signo;
  std::stringstream ss;
  ss << std::hex << argv[3];
  ss >> signa;
  ss.clear();  
  ss << std::hex << argv[4];
  ss >> signo;
  
  std::cout << "OUT:" << argv[2] << "[" << signa << "-" << signo << "]" << std::endl;
  std::ofstream out(argv[2], std::ios::trunc);
  std::string line = "";
  
  for(uint32_t adr = signa; adr < signo; adr += 16) {
    for(uint32_t xadr = adr + 13; xadr > adr; xadr -= 4) {
      if (xadr >= buf.size()) {
	std::cerr << "ERR XADR " << std::hex << xadr << std::endl;
	break;
      }
      out << std::setfill('0') << std::setw(8) << std::hex << ram[xadr >> 2];
    }
    out << std::endl;
  }
  
  out.close();
    
  // FREE
#ifdef TRACE
    tfp->close();
    delete tfp;
#endif
  delete cpu;  
  return 0;
}
