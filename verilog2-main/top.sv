//`include "cpu_if.sv"
import instr_package::*;
module top;
   bit clk;
   always #5 clk = ~clk;

   logic Din[15:0];
   logic Dout[15:0];
   logic [15:0]Address;
   logic RW;
   logic reset;

   bit [7:0] ST_Count=0;
   logic read_pc;
   logic [2:0] upc;

/*
   cpu_if cpuif(clk);
   memory mem (cpuif);

  memory mem (.clk(cpuif.clk),
	.reset(cpuif.reset),
	.Din(cpuif.cb.Din),
	.Dout(cpuif.cb.Dout),
	.Address(cpuif.cb.Address),
	.RW(cpuif.cb.RW));

   initial begin
      cpuif.reset = 1'b0;
      @(posedge clk);
      cpuif.reset=1'b1;
      @(posedge clk);
      cpuif.reset=1'b0;
   end;      
*/

   logic [15:0] register [0:7];


   FSM #(.N(16),.M(3)) dut 
	(.clk(clk),
           .rst(reset),
           .Din(Din),
           .Dout(Dout),
           .Address(Address),
           .RW(RW));

  //test test(cpu_bus);   

  memory mem (.clk(clk),
	.reset(reset),
	.Din(Dout),
	.Dout(Din),
	.Address(Address),
	.RW(RW),
   .read_pc(read_pc)
  );

  assign register = dut.datapath_file.FILE1.memory; // DOUBLE CHECK THE FILE NAME IS COORECT
  
  initial begin
      $init_signal_spy("/top/dut/upc", "/top/upc", 1, 1);
      reset = 1'b0;
      @(posedge clk);
      reset=1'b1;
      @(posedge clk);
      reset=1'b0;
   end;      

   // Instruction properties
/*
   assert property (
      @(posedge clk) ((dut.Instr[15:12]==ST) && (dut.uPC==1)) |-> ##2 !(RW)
   );
*/

//ADD,iSUB,iAND,iOR,iXOR,iNOT,MOV,NOP,LD,ST,LDI, NU, BRZ,BRN,BRO,BRA
always @(posedge clk)
begin
   $display("%0t: Test", $time);
   case (dut.Instruction_Register[15:12])
   ADD : if(dut.uPC==3) assert (register[dut.Instruction_Register[11:9]] == register[dut.Instruction_Register[8:6]] + register[dut.Instruction_Register[5:3]]) 
   begin
         $display("%0t: ADD works ok", $time);
      end
      else
         $display("%0t: ADD instruction has an error", $time);
      iSUB : if(dut.uPC==3) assert (register[dut.Instruction_Register[11:9]] == register[dut.Instruction_Register[8:6]] - register[dut.Instruction_Register[5:3]]) 
      begin
         $display("%0t: SUB works ok", $time);
      end
      else
         $display("%0t: SUB instruction has an error", $time);
      iAND : if(dut.uPC==3) assert (register[dut.Instruction_Register[11:9]] == register[dut.Instruction_Register[8:6]] & register[dut.Instruction_Register[5:3]]) 
      begin
         $display("%0t: AND works ok", $time);
      end
      else
         $display("%0t: AND instruction has an error", $time);
      iOR : if(dut.uPC==3) assert (register[dut.Instruction_Register[11:9]] == register[dut.Instruction_Register[8:6]] | register[dut.Instruction_Register[5:3]]) 
      begin
         $display("%0t: OR works ok", $time);
      end
      else
         $display("%0t: OR instruction has an error", $time);
      iXOR : if(dut.uPC==3) assert (register[dut.Instruction_Register[11:9]] == register[dut.Instruction_Register[8:6]] ^ register[dut.Instruction_Register[5:3]]) 
      begin
         $display("%0t: XOR works ok", $time);
      end
      else
         $display("%0t: XOR instruction has an error", $time);
      iNOT : if(dut.uPC==3) assert (register[dut.Instruction_Register[11:9]] == ~register[dut.Instruction_Register[8:6]]) 
      begin
         $display("%0t: NOT works ok", $time);
      end
      else
         $display("%0t: NOT instruction has an error", $time);
      MOV : if(dut.uPC==3) assert (register[dut.Instruction_Register[11:9]] == register[dut.Instruction_Register[8:6]]) 
      begin
         $display("%0t: MOV works ok", $time);
      end
      else
         $display("%0t: MOV instruction has an error", $time);
      NOP : if(dut.uPC==3) assert (register[7] == Address + 1)
       begin
         $display("%0t: NOP works ok", $time);
      end
      else
         $display("%0t: NOP instruction has an error", $time);
      LD : if(dut.uPC==3) assert (dut.address == register[dut.Instruction_Register[8:6]]) 
      begin
         $display("%0t: LD works ok", $time);
      end
      else
         $display("%0t: LD instruction has an error", $time);
      LDI : if(dut.uPC==3) assert (register[dut.Instruction_Register[11:9]] == 16'(signed'(dut.Instruction_Register[8:0]))) 
      begin
         $display("%0t: LDI works ok", $time);
      end
      else
         $display("%0t: LDI instruction has an error", $time);
      NU : if(dut.uPC==3) assert (register[7] == Address) 
      begin
         $display("%0t: NU works ok", $time);
      end
      else
         $display("%0t: NU instruction has an error", $time);
      BRZ : if(dut.uPC==3) assert ((register[7] == Address + 16'(signed'(dut.Instruction_Register[11:0])) && dut.Z_Flag_Latch == 1) || ((register[7] == Address + 1) && dut.Z_Flag_Latch == 0)) 
      begin
         $display("%0t: BRZ works ok", $time);
      end
      else
         $display("%0t: BRZ instruction has an error", $time);
      BRN : if(dut.uPC==3) assert ((register[7] == Address + 16'(signed'(dut.Instruction_Register[11:0])) && dut.N_Flag_Latch == 1) || ((register[7] == Address + 1) && dut.N_Flag_Latch == 0)) 
      begin
         $display("%0t: BRN works ok", $time);
      end
      else
         $display("%0t: BRN instruction has an error", $time);
      BRO : if(dut.uPC==3) assert ((register[7] == Address + 16'(signed'(dut.Instruction_Register[11:0])) && dut.O_Flag_Latch == 1) || ((register[7] == Address + 1) && dut.O_Flag_Latch == 0)) 
      begin
         $display("%0t: BRO works ok", $time);
      end
      else
         $display("%0t: BRO instruction has an error", $time);
      BRA : if(dut.uPC==3) assert (register[7] == Address + 16'(signed'(dut.Instruction_Register[11:0])))
      begin
         $display("%0t: BRA works ok", $time);
      end
      else
         $display("%0t: BRA instruction has an error", $time);




      ST:
      #5ns
       if (dut.uPC==3) assert (!(RW)) 
       begin
		   $display("%0t: ST works ok",$time);
		   ST_Count++;
	        end
		else
		   $display("%0t: ST instruction has an error",$time);
      default:$display("%0t: Not a ST instruction",$time);
   endcase
end 

assign read_pc = (dut.upc==3'b011) ? 1'b1 : 1'b0;
//assign read_pc = dut.upc;

endmodule

