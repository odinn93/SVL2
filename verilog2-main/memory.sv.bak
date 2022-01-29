//`include "cpu_if.sv"
`include "mem_class.sv"
`include "SV_RAND_CHECK.sv"
import instr_package::*;
import mem_package::*;
//module memory(cpu_if cpuif);
program automatic memory(
   input bit clk,
   input logic reset,
   input logic RW,
   input logic [15:0]Address,
   input logic Din[15:0],
   input logic read_pc,
   output logic Dout[15:0],
   output mem_statistics statistics
);

   mem_type data[mem_type],idx=1;
   mem_type a;
   mem_type mem_content;
   Driver_cbs cbs[$];
   Driver_cbs_cover cb_cover;

   initial begin
       statistics=new();
       a <= 0;
       while(1) begin
 	     @(posedge clk)
	     a <= Address;
       end;
      //    assert (!$isunknown(Address))
	   //     a <= Address;
      //    else begin
      //       $warning("Memory Address is set to unknown");
	   //     $display("%x",Address);
	   //  end
          if (RW) begin
	       // Driver
            Dout <= {>>{data[a][15:0]}};
            // Collect statistics
            $display("a is %x",a);
            if ((a>=0)&&(a<256)) begin
               mem_content<=data[a][15:0];
               statistics.Incr(mem_content);
            end
            if (a==255) statistics.Print();
          end
          else begin
	       // Monitor
	       data[a] = {<<{Din}};
          end;
       end;
   end;
 // Load Program
   initial begin
      cb_cover = new();
      cbs.push_back(cb_cover); 
      @(posedge reset)
      @(negedge clk)
      for(int i=0;i<256;i++) begin
         instr = new();
	    `SV_RAND_CHECK(instr.randomize());
	    instr.print_instruction;
//          data[i]=instr.Compile(); // 16'h7000; //NOP
	     foreach (cbs[i]) begin
	        cbs[i].post_tx(instr);
	     end
          // data[i]=16'b0111_0000_0000_0000; //NOP
      end
   end;

endprogram
