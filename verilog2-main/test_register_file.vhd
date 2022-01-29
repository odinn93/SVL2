--Import library ???m&n are switched somewhere???
library IEEE;
    use IEEE.std_logic_1164.all;
    use ieee.std_logic_signed.all;
    use IEEE.numeric_std.all;
    use work.all;

--Declare the Test Bench entity
entity RFtestbench is
end RFtestbench;

architecture test_register_file of RFtestbench is
    
    constant ClockFreq : integer := 100e6; --100MHz
    constant ClockPeriod : time := 1000 ms / Clockfreq;
    constant M: integer:=4;
    constant N: integer:=4; --same as ALU bits
    
    component register_file is
        generic(M: POSITIVE := M;
                N: POSITIVE := N);
        port ( WD : in Signed(N-1 downto 0);        --Write Data (N bits wide)
               WAddr : in STD_LOGIC_VECTOR (M-1 downto 0);     --Write Address (M bits wide)
               Write : in STD_LOGIC;                           --Write='1' writes register pointed to by Write Address.
               -- Registers should be written on positive flank

               RA : in STD_LOGIC_VECTOR (M-1 downto 0);        --Read Address A (M bits wide)
               ReadA: in STD_LOGIC;                            --ReadA='1' reads register pointed to by Read Address A. 
               -- Output should be updated immediately. ReadA='0' should output a 0.
               QA : out Signed (N-1 downto 0);         --Outputs a value from the register pointed to by RA

               RB : in STD_LOGIC_VECTOR (M-1 downto 0);        --------------------
               ReadB: in STD_LOGIC;                            -- SAME AS WITH A --
               QB : out signed (N-1 downto 0);         --------------------

               rst,clk: in STD_LOGIC);                         --Reset and Clock registers              --one 'cout' output port 
    end component;
    --Inputs
    signal WD : signed (N-1 downto 0) := (others => '0');
    signal WAddr : STD_LOGIC_VECTOR (M-1 downto 0) := (others => '0');
    signal Write : STD_LOGIC := '1';
    signal RA :  STD_LOGIC_VECTOR (M-1 downto 0) := (others => '0');
    signal RB :  STD_LOGIC_VECTOR (M-1 downto 0) := (others => '0');
    signal ReadA : STD_LOGIC := '1';
    signal ReadB : STD_LOGIC := '1';
    signal clk : std_logic:='1';
    signal rst: std_logic:='1';
    --Outputs
    signal QA : signed (N-1 downto 0);
    signal QB : signed (N-1 downto 0);
begin
    -- Instantiate the Unit Under Test (UUT)
    uut: register_file port map (WD=>WD,WAddr=>WAddr,Write=>Write,RA=>RA,RB=>RB,ReadA=>ReadA,ReadB=>ReadB,QA=>QA,QB=>QB,clk=>clk,rst=>rst);    
    clk <= not clk after ClockPeriod/2; 
    -- Stimulus process
    stim_proc: process
    begin
        -- hold reset state for 10 ns.
        RST<='1';
        wait for 10 ns;
        RST<='0';
        wait until rising_edge(clk);
        wait for 1 ns;
        WAddr <= "1110"; 
        WD <= "1110";  
        wait until rising_edge(clk);
        wait for 1 ns; 
        WAddr <= "1101"; 
        WD <= "1011";         
        wait until rising_edge(clk);
        wait for 1 ns;     
        RA <= "1110"; 
        RB <= "1101"; 
        wait;
    end process;
end;
