#include "Vt5_sim.h"
#include "verilated.h"
Vt5_sim *top;
int main(int argc, char** argv, char** env) {
  Verilated::commandArgs(argc, argv);
  top = new Vt5_sim;
  while (!Verilated::gotFinish()) {
    top->eval();
  }
  delete top;
  return 0;
}
