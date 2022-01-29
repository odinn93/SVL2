
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

LIBRARY altera_mf;
USE altera_mf.all;

USE work.microcode.all;

ENTITY fake_memory IS
	--PORT
	--(
	--	address		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
	--	clock		: IN STD_LOGIC  := '1';
	--	data		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
	--	wren		: IN STD_LOGIC ;
	--	q			: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
	--);
END fake_memory;


ARCHITECTURE fake OF fake_memory IS

	signal RAM:program(0 to 255):=(
		(iLDI & R5 & B"1_0000_0000"), --0
		(iADD & R5 & R5 & R5 & NU),   --1
		(iADD & R5 & R5 & R5 & NU),   --2
		(iADD & R5 & R5 & R5 & NU),   --3
		(iADD & R5 & R5 & R5 & NU),   --4
		(iLDI & R6 & B"0_0010_0000"), --5, H'20
		(iLDI & R3 & B"0_0000_0011"), --6, D'3
		(iST  & R6 & R3 & NU & NU),	  --7
		(iLDI & R1 & B"0_0000_0001"), --8
		(iLDI & R0 & B"0_0000_1110"), --9
		(iMOV & R2 & R0 & NU & NU),	  --A
 		(iADD & R2 & R2 & R1 & NU),	  --B
		(iSUB & R0 & R0 & R1 & NU),	  --C
		(iBRZ & X"003"),			  --D (X"003" because we need 12 bits)
		(iNOP & NU & NU & NU & NU),	  --E
		(iBRA & X"FFC"),			  --F (X"FFC" because we need 12 bits)
		(iST & R6 & R2 & NU & NU),    --10
		(iST & R5 & R2 & NU & NU),	  --11
		(iBRA & X"000"),			  --12 (12 bits again)
		(iNOP & NU & NU & NU & NU),   --13
		(iNOP & NU & NU & NU & NU),   --14

		others=>(iNOP & R0 & R0 & R0 & NU));

		signal address, Din, Dout : std_logic_vector(15 downto 0);
		signal clk, reset : std_logic := '0';
		signal RW : std_logic;
		signal led_output : std_logic_vector(15 downto 0);

		--Test
		signal RW_tmp : std_logic;
  		signal Din_tmp, Dout_tmp, address_tmp: std_logic_vector(15 downto 0);
  		signal ie_activator, oe_activator, wren_activator: std_logic;
		--

		--File variable
		--file memory_hex_output : text;
		--signal initialized : std_logic := '0';
	begin
		clk <= not clk after 1 ns;	
	
	
		-- process(clk)
		-- begin
		--     if rising_edge(clk)
		-- end process;
	
	
		-- print_hex : process(clk)
		--     variable instruction_line : line;
		-- begin
		--     if rising_edge(clk) then
		--         if (initialized = '0') then
		--             file_open(memory_hex_output, "output.txt", write_mode);
		--             initialized <= '1';
		--         end if;
		--         if (address = "11111111") then
		--             file_close(memory_hex_output);
		--             assert(false) report "DONE" severity failure;
		--         end if;
		--         write(instruction_line, RAM(to_integer(unsigned(address(7 downto 0)))), right, 16);
		--         writeline(memory_hex_output, instruction_line);
		--         address <= address + 1;
		--     end if;
		-- end process;
	
		cpu_inst: entity work.FSM
		port map (
		  clk     => clk,
		  rst   => reset,
		  Din     => Din_tmp,
		  address => address_tmp,
		  Dout    => Dout_tmp,
		  RW      => RW_tmp
		  --test_alu => led_output,
		  --Z_Flag_test => Z_Flag,
		  --N_Flag_test => N_Flag,
		  --O_Flag_test => O_Flag
		);

		--test
		gpio_inst: entity work.gpio(behave)
  		generic map (
      	N => 16
  		)
  		port map (
      		clk   => clk,
      		rst => reset,
      		ie    => ie_activator,
      		oe    => oe_activator,
      		Din   => Dout_tmp,
      		Dout  => led_output
  		);
		--

	
		PROC : process
			variable I : integer := 0;
		begin
			wait until rising_edge(clk);
			reset <= '1';
			wait until rising_edge(clk);
			reset <= '0';
			oe_activator <= '1';
			while (I < 255) loop
			    Din_tmp <= RAM(I);
				wait for 1 ns;
				ie_activator <= '1';
				wait for 1 ns;
			    I := I + 1;
			    wait until rising_edge(clk);
				wren_activator <= (not RW_tmp);
			    wait until rising_edge(clk);
			    wait until rising_edge(clk);
			    wait until rising_edge(clk);
			end loop;
    	end process;
END fake;
