--Import library
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_signed.all;
use work.microcode.all;

-- Declare the Datapath Structural entity
entity DATAPATH_STRUCTURAL is
    
    -- Generic values, default values set for FPGA testing
    generic (
                M:INTEGER ;     --Memory Address bits
                N:INTEGER      --Data Value bits
            );               
    port    (
                IE                      : IN    STD_LOGIC;                          --Input Enable 
                Input1                  : IN    std_logic_vector (N-1 DOWNTO 0);              --Input into the MUX
                OE                      : IN    STD_LOGIC;                          --Output Enable
                RST,CLK,EN              : IN    STD_LOGIC;                          --Reset, Clock and Enable
                Output                  : OUT   std_logic_vector (N-1 DOWNTO 0);              --Output
                WAddr                   : IN    STD_LOGIC_VECTOR (M-1 DOWNTO 0);    --Address Input
                Write                   : IN    STD_LOGIC;                          --Write Signal ('1' = Write to address WAddr, '0' = Do not write)
                RA                      : IN    STD_LOGIC_VECTOR (M-1 DOWNTO 0);    --Read Address A
                ReadA                   : IN    STD_LOGIC;                          --Read A ('1' = Read, '0' = Do not read)
                RB                      : IN    STD_LOGIC_VECTOR (M-1 DOWNTO 0);    --Read Address B
                ReadB                   : IN    STD_LOGIC;                          --Read B ('1' = Read, '0' = Do not read)
                Z_flag,N_flag,O_flag    : OUT   STD_LOGIC;                          --Zero flag, Negative flag, Overflow flag
                OP                      : IN    STD_LOGIC_VECTOR (2 DOWNTO 0);       --Operand

                --mux components (L3)
                Offset                  : in std_logic_vector (11 downto 0);
                BypassA                 : in std_logic;
                BypassB                 : in std_logic

                --lab 3 Register enable ALU
                --RegEn                 :   in std_logic  --Lab3, command to update the registers
            );
end DATAPATH_STRUCTURAL;

--Description of Structure for the Datapath
architecture STRUCTURE of DATAPATH_STRUCTURAL is

    --Clock Divider (possibly not used anymore?)
    component CLOCKDIV
        port(         
                RST,CLK    :   IN   STD_LOGIC;
                CLOCK_OUT  :   OUT  STD_LOGIC
            );
    end component;

    --The Register File. Writes specified data to specified address. When ReadA and/or ReadB is enabled,
    -- it forwards one or both values at those addresses to the ALU
    component REGISTER_FILE 
    generic (
                M,N:INTEGER
            );    
    port    (      
                WD            : IN  std_logic_vector (N-1 DOWNTO 0);              --Write Data (N bits wide)
                WAddr         : IN  STD_LOGIC_VECTOR (M-1 DOWNTO 0);    --Write Address (M bits wide)
                Write         : IN  STD_LOGIC;                          --Write='1' writes register pointed to by Write Address.
                RA            : IN  STD_LOGIC_VECTOR (M-1 DOWNTO 0);    --Read Address A (M bits wide)
                ReadA         : IN  STD_LOGIC;                          --ReadA='1' reads register pointed to by Read Address A. 
                QA            : OUT std_logic_vector (N-1 DOWNTO 0);              --Outputs a value from the register pointed to by RA
                RB            : IN  STD_LOGIC_VECTOR (M-1 DOWNTO 0);    --------------------
                ReadB         : IN  STD_LOGIC;                          -- SAME AS WITH A --
                QB            : OUT std_logic_vector (N-1 DOWNTO 0);              --------------------
                RST           : IN  STD_LOGIC;
                CLK           : IN  STD_LOGIC      
            );
    end component;

    --The Arithmetic Logic Unit. Takes two sets of bits from the Register File and performs functions using those inputs.
    --OP determines what function is performed (000:Addition (A+B), 001:Subtraction(A-B), 010:AND, 011:OR, 100: XOR, 101:NOT, 110:MOV, 111:Zero)
    component ALU
    generic (
                N:INTEGER);
    port    (      
                A,B                   : IN std_logic_vector (N-1 DOWNTO 0);           --Two SIGNED inputs
                OP                    : IN STD_LOGIC_VECTOR (2 DOWNTO 0);   --Operand
                RST                   : IN STD_LOGIC;                       --Reset signal
                EN                    : IN STD_LOGIC;                       --Clock and Enable
                SUM                   : OUT std_logic_vector (N-1 DOWNTO 0);          --Output of operation             
                Z_flag,N_flag,O_flag  : OUT STD_LOGIC                      --Zero flag, Negative flag, Overflow flag
                --RegEn                 : In  STD_LOGIC 
            ); 
    end component;

signal First_Output   : std_logic_vector (N-1 DOWNTO 0); --Output of ALU. OE determines whether it is the final output or fed back to Input
signal Final_Input    : std_logic_vector (N-1 DOWNTO 0); --The "final" input signal. IE Determines whether or not it is a new input or the last result from the ALU.
signal ALU_A          : std_logic_vector (N-1 DOWNTO 0); --Signal to transfer value of QA to the A Input of the ALU
signal ALU_B          : std_logic_vector (N-1 DOWNTO 0); --Signal to transfer value of QB to the B Input of the ALU
signal Clock_Out      : STD_LOGIC;             --The Clock Signal output from the Clock Divider component

--lab 3
signal Muxout_A       : std_logic_vector (N-1 DOWNTO 0);
signal Muxout_B       : std_logic_vector (N-1 DOWNTO 0);
signal PCOP           : STD_LOGIC_VECTOR (2 DOWNTO 0) := "111";
signal inc            : std_logic;

signal ra_mux : std_logic_vector(M-1 downto 0);
signal readA_activator : std_logic;

begin
    
    --This process simulates the MUX in the provided diagram as well as the Output component.
    --If IE is '1', then it feeds a new input into the Register File, otherwise it uses the output from ALU as an input.
    --If OE is '1', then the last result from the ALU is displayed, otherwise it returns 'Z' (not implemented yet!) 
    process (IE,OE,Input1,First_Output)
    begin 
        if IE='1' then
            Final_Input (N-1 DOWNTO 0) <= Input1(N-1 DOWNTO 0);
        else
            Final_Input (N-1 DOWNTO 0) <= First_Output (N-1 DOWNTO 0);
        end if;
        if OE='1' then
            Output (N-1 DOWNTO 0) <= First_Output(N-1 DOWNTO 0);
        else
            Output (N-1 DOWNTO 0) <= (others=>'0'); 
        end if;
    end process;
    
    
    --lab 3 process for MUX
    process (BypassA, BypassB, Muxout_A, Muxout_B, Offset)
    begin
        if BypassA = '0' then
            Alu_A (N-1 DOWNTO 0) <= Muxout_A (n-1 downto 0);
        else
            
            ALU_A (N-1 DOWNTO 0) <= std_logic_vector(resize(signed(Offset),Alu_A'length));
        end if; 

        
        if BypassB = '0' then
            Alu_B (N-1 DOWNTO 0) <= Muxout_B (n-1 downto 0);
        else 
            ALU_B (N-1 DOWNTO 0) <= std_logic_vector(resize(signed(Offset),Alu_B'length));
        end if; 
    end process;
    
    ra_mux <= (others => '1') when BypassB = '1' else RA;
    readA_activator <= ReadA or BypassB;
   
    --Do we even need this anymore?
    FILE3: CLOCKDIV
            port map (
                        CLK         => CLK,
                        RST         => RST,
                        Clock_Out   => Clock_Out
                    );

    FILE2: ALU
            generic map(
                        N => N)
            port map (
                        A       =>  ALU_A(N-1 DOWNTO 0),
                        B       =>  ALU_B(N-1 DOWNTO 0),
                        EN      =>  EN,
                        RST     =>  RST,
                        OP      =>  OP,
--                        CLK     =>  Clock_Out,
                        SUM     =>  First_Output(N-1 DOWNTO 0),
                        Z_Flag  =>  Z_flag,
                        N_flag  =>  N_flag,
                        O_flag  =>  O_flag
                        --RegEn   =>  RegEn
                    );   

    FILE1: Register_File
            generic map(
                        M=>M,
                        N=>N)
            port map ( 
                        WD      =>  Final_input(N-1 DOWNTO 0),
                        WAddr   =>  WAddr(M-1 DOWNTO 0),  
                        Write   =>  Write,
                        RA      =>  ra_mux,
                        ReadA   =>  readA_activator,
                        RB      =>  RB(M-1 DOWNTO 0),
                        ReadB   =>  ReadB,
                        QA      =>  Muxout_A(N-1 DOWNTO 0),
                        QB      =>  Muxout_B(N-1 DOWNTO 0),
                        RST     =>  RST,
                        CLK     =>  CLK
                    );  
end structure;