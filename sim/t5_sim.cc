#include "Vt5_rv32i.h"
#include "sc_clock.h"
#include "verilated.h"
Vt5_rv32i *top;
int main(int argc, char** argv, char** env) {
  Verilated::commandArgs(argc, argv);
  sc_clock sclk ("sys_clk",10);
  top = new Vt5_rv32i;
  top->sys_rst = 1;
  top->sys_ena = 1;
  top->sexe = 0;
  top->sys_clk(sclk);
  while (!Verilated::gotFinish()) {
    top->eval();
  }
  top->final();
  delete top;
  exit(0);
}
