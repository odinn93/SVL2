// The mem_type should be converted into a class so that you can collect statistics of the instructions

package mem_package;
import instr_package::*;
typedef bit [15:0] uint16;
typedef uint16 mem_type;
typedef bit [3:0] nybble;
class mem_statistics;
   int instr[nybble];
   function new();
      for(int i=0;i<15;i++) instr[i]=0;
   endfunction
   function void Incr(mem_type din);
      nybble op;
      op=din[15:12];
      instr[op]++;
   endfunction
   function void Print();
      $display("ADD %x iSUB %x iAND %x iOR %x iXOR %x iNOT %x MOV %x NOP %x LD %x ST %x LDI %x NU  %x BRZ  %x BRN %x BRO %x BRA",
               instr[ADD],
               instr[iSUB],
               instr[iAND],
               instr[iOR],
               instr[iXOR],
               instr[iNOT],
               instr[MOV],
               instr[NOP],
               instr[LD],
               instr[ST],
               instr[LDI],
               instr[NU],
               instr[BRZ],
               instr[BRN],
               instr[BRO],
               instr[BRA]);
   endfunction
endclass
endpackage