library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.microcode.all;

entity FSM is
    generic (
                N: INTEGER:=16;
                M: INTEGER :=3
    );
    Port (
        clk, rst : in std_logic;
        Din : in std_logic_vector(N-1 downto 0);
        Dout, address : out std_logic_vector (n-1 downto 0);
        RW : out std_logic;
        test_alu : out std_logic_vector(15 downto 0); --TESTING
        Z_Flag_test, N_Flag_test, O_Flag_test : out std_logic

    );
end FSM;

architecture behave of FSM is
    signal uPC                  :   std_logic_vector(2 downto 0);
    signal Instruction_Register :   std_logic_vector(15 downto 0):=(others=>'0');

    --DATAPATH FILE
    signal IE,OE                        :   std_logic;
    signal OP                           :   std_logic_vector(2 downto 0 );
    signal BypassA,BypassB              :   std_logic;   
    signal ReadA, ReadB, Write          :   std_logic;
    signal Z_Flag, N_Flag, O_Flag,Flag  :   std_logic; --extra flag for what??
    signal RA,RB                        :   std_logic_vector(M-1 downto 0);
    signal WAddr                        :   std_logic_vector(M-1 downto 0);
    signal Offset                       :   std_logic_vector (11 downto 0);   
    signal Z_flag_Latch,N_flag_Latch    :   std_logic;
    signal O_Flag_Latch                 :   std_logic;
    signal ALU_Output                   :   std_logic_vector (n-1 downto 0);
    signal ALU_Enable                   :   std_logic;

begin
    datapath_file :  entity work.datapath_structural
        generic map (
                    N => N,
                    M => M
                    )
        port    map (
                    ie          => ie,
                    oe          => oe,
                    clk         => clk,
                    rst         => rst,
                    offset      => offset,
                    bypassA     => bypassA,
                    bypassB     => bypassB,
                    write       => write,
                    readA       => readA,
                    readB       => readB,
                    Z_Flag      => Z_Flag,
                    N_Flag      => N_Flag,
                    O_Flag      => O_Flag,
                    Op          => Op,
                    WAddr       => WAddr,
                    RA          => RA,
                    RB          => RB,
                    input1      => Din,
                    output      => ALU_output,
                    en          => ALU_Enable  
                );

    test_alu <= alu_output;
    Z_Flag_test <= Z_Flag_Latch;
    N_Flag_test <= N_Flag_Latch;
    O_Flag_test <= O_Flag_Latch;
    
    process (clk, rst)
    begin
        if (rst='1') then
            upc<="100";
            address<=(others=>'0');
            Dout <= (others=>'0');
            instruction_register<=(others=>'0');
            Z_flag_latch<='0';
            N_flag_latch<='0';
            O_flag_latch<='0';
            bypassA<='0';
            bypassB<='0';
            offset<=(others=>'0');
            rw<='1'; 
            ie <= '0';
            oe <= '0';
            readA <= '0';
            readB <= '0';
            write <= '1';
            WAddr <= (others => '0');
            ra <= (others => '0');
            rb <= (others => '0');
            alu_enable <= '0';
            Op <= "000";
        elsif rising_edge(clk) then
                RW<='1';
                oe <= '1';
                upc<= upc+1;
                case upc is
                    when "000" =>
                        Instruction_Register <= Din;
                        case Din(15 downto 12) is
                            when iADD =>
                                Write <= '1';               --Disable Write
                                ALU_Enable <= '1';          --Enable ALU
                                readA <= '1';               --Enable ReadA
                                readB <= '1';               --Enable ReadB
                                RA <=Din(8 downto 6);       --Load RA
                                RB <=Din(5 downto 3);       --Load RB
                                Waddr <=Din(11 downto 9);   --Load WA
                                op <= "000";                --Load operant value
                                IE <= '0';                  --Input Enable
                                BypassA <= '0';             --Disable BypassA
                                BypassB <= '0';             --Disable BypassB

                            when iSUB =>
                                Write <= '1';               --Disable Write
                                ALU_Enable <= '1';          --Enable ALU
                                readA <= '1';               --Enable ReadA
                                readB <= '1';               --Enable ReadB
                                RA <=Din(8 downto 6);    --Load RA
                                RB <=Din(5 downto 3);    --Load RB
                                Waddr <=Din(11 downto 9);   --Load WA
                                op <= "001";                --Load operant value
                                IE <= '0';                  --Input Enable
                                BypassA <= '0';             --Disable BypassA
                                BypassB <= '0';             --Disable BypassB

                            when iAND =>
                                Write <= '1';               --Disable Write
                                ALU_Enable <= '1';          --Enable ALU
                                readA <= '1';               --Enable ReadA
                                readB <= '1';               --Enable ReadB
                                RA <=Din(8 downto 6);    --Load RA
                                RB <=Din(5 downto 3);    --Load RB
                                Waddr <=Din(11 downto 9);   --Load WA
                                op <= "010";                --Load operant value
                                IE <= '0';                  --Input Enable
                                BypassA <= '0';             --Disable BypassA
                                BypassB <= '0';             --Disable BypassB

                            when iOR =>
                                Write <= '1';               --Disable Write
                                ALU_Enable <= '1';          --Enable ALU
                                readA <= '1';               --Enable ReadA
                                readB <= '1';               --Enable ReadB
                                RA <=Din(8 downto 6);    --Load RA
                                RB <=Din(5 downto 3);    --Load RB
                                Waddr <=Din(11 downto 9);   --Load WA
                                op <= "011";                --Load operant value
                                IE <= '0';                  --Input Enable
                                BypassA <= '0';             --Disable BypassA
                                BypassB <= '0';             --Disable BypassB

                            when iXOR =>
                                Write <= '1';               --Disable Write
                                ALU_Enable <= '1';          --Enable ALU
                                readA <= '1';               --Enable ReadA
                                readB <= '1';               --Enable ReadB
                                RA <=Din(8 downto 6);    --Load RA
                                RB <=Din(5 downto 3);    --Load RB
                                Waddr <=Din(11 downto 9);   --Load WA
                                op <= "100";                --Load operant value
                                IE <= '0';                  --Input Enable
                                BypassA <= '0';             --Disable BypassA
                                BypassB <= '0';             --Disable BypassB

                            when iNOT =>
                                Write <= '1';               --Disable Write
                                Waddr <=Din(11 downto 9);   --Load WA
                                ALU_Enable <= '1';          --Enable ALU
                                readA <= '1';               --Enable ReadA
                                readB <= '0';               --Disable ReadB
                                RA <=Din(8 downto 6);    --Load RA
                                op <= "101";                --Load operant value
                                IE <= '0';                  --Input Enable
                                BypassA <= '0';             --Disable BypassA
                                BypassB <= '0';             --Disable BypassB

                            when iMOV =>
                                Write <= '1';               --enable Write
                                Waddr <=Din(11 downto 9);   --Load WA
                                ALU_Enable <= '1';          --Enable ALU
                                readA <= '1';               --Enable ReadA
                                readB <= '0';               --Disable ReadB
                                RA <=Din(8 downto  6);    --Load RA
                                
                                op <= "110";                --Load operant value
                                IE <= '0';                  --Input Enable
                                BypassA <= '0';             --Disable BypassA
                                BypassB <= '0';             --Disable BypassB

                            when iNOP =>
                                Write <= '1';               --Disable Write
                                ALU_Enable <= '1';           --Enable ALU
                                ie <= '0';                  --Input Enable
                                bypassB <= '1';              --Enable BypassB
                                bypassA <= '0';             --Disable BypassA
                                op <= "111";                --set operant value
                                WAddr <= R7;                --set write address to pc register

                            when iLD =>
                                Write <= '0';               --Disable Write
                                ALU_Enable <= '1';          --Enable ALU
                                OE <= '1';                  --Output Enable
                                readA <= '1';               --Enable ReadA
                                readB <= '0';               --Disable ReadB
                                RA <=Din(8 downto  6);    --Load RA
                                WAddr <=Din(11 downto  9);    --Load Waddr
                                op <= "110";                   --Load operant value
                                BypassA <= '0';             --Disable BypassA
                                BypassB <= '0';             --Disable BypassB

                            when iST =>
                                Write <= '0';               --Disable Write
                                ALU_Enable <= '1';          --Enable ALU
                                OE <= '1';                  --Output Enable
                                readA <= '1';               --Enable ReadA
                                readB <= '0';               --Disable ReadB
                                Ra <=Din(8 downto  6);    --Load RB
                                WAddr <=Din(11 downto  9);    --Load Waddr
                                op <= "110";                   --Load operant value
                                BypassA <= '0';             --Disable BypassA
                                BypassB <= '0';             --Disable BypassB

                            when iLDI =>
                                Write <= '1';               --ENable Write
                                Waddr <= Din(11 downto 9);  --Set write address
                                ALU_Enable <= '1';          --Enaable ALU
                                readA <= '0';               --Disable ReadA
                                readB <= '0';               --Disable ReadB
                                op <= "110";                --Load operant value
                                ie <= '0';                  -- Input Enable
                                BypassA <= '1';             --Enable BypassA 
                                BypassB <= '0';             --Disable BypassB
                                offset<= std_logic_vector(resize(signed (Din(8 downto 0)),offset'length));

                            when iBRZ =>
                                ALU_Enable <= '1';          --Enable ALU
                                Write <= '1';               --Enable Write
                                IE <= '0';                  --Input Enable
                                Waddr <= R7;                --??set write address to pc register
                                if (Z_Flag_Latch = '1') then
                                    bypassB <= '1';         --Enable bypassB
                                    bypassA <= '0';         --Disable bypassA
                                    op <= "000";             --set opcode
                                    offset <= std_logic_vector(resize(signed(Din(11 downto 0)), offset'length));                       --set offset
                                else        --increment PC                      
                                    bypassA <= '0';         
                                    bypassB <= '1';
                                    Op <= "111";
                                end if;

                            when iBRN =>
                                ALU_Enable <= '1';          --Enable ALU
                                Write <= '1';               --Enable Write
                                IE <= '0';                  --Input Enable
                                Waddr <= R7;                --??set write address to pc register
                                if (N_Flag_Latch = '1') then
                                    bypassB <= '1';         --Enable bypassB
                                    bypassA <= '0';         --Disable bypassA
                                    op <= "000";             --set opcode
                                    offset <= std_logic_vector(resize(signed(Din(11 downto 0)), offset'length));                       --set offset
                                else        --increment PC                      
                                    bypassA <= '0';         
                                    bypassB <= '1';
                                    Op <= "111";
                                end if;

                            when iBRO =>
                                ALU_Enable <= '1';          --Enable ALU
                                Write <= '1';               --Enable Write
                                IE <= '0';                  --Input Enable
                                Waddr <= R7;                --??set write address to pc register
                                if (O_Flag_Latch = '1') then
                                    bypassB <= '1';         --Enable bypassB
                                    bypassA <= '0';         --Disable bypassA
                                    op <= "000"  ;           --set opcode
                                    offset <= std_logic_vector(resize(signed(Din(11 downto 0)), offset'length));                       --set offset
                                else        --increment PC                      
                                    bypassA <= '0';         
                                    bypassB <= '1';
                                    Op <= "111";
                                end if;

                            when iBRA =>
                                    ALU_enable <='1';       --Enable ALU
                                    Write <= '1';           --Enable Write
                                    Waddr <= R7;            --Set write address to pc register
                                    BypassA <= '0';         --Disable BypassA
                                    BypassB <= '1';         --Enable BypassB
                                    op <="000";             --set op code
                                    offset <= std_logic_vector(resize(signed(Din(11 downto 0)), offset'length));    --set offset    

                            when others =>                  --DISABLE ALL
                                Write <= '0';               --Disable Write
                                ALU_Enable <= '0';          --Disable ALU
                                readA <= '0';               --Disable ReadA
                                readB <= '0';               --Disable ReadB
                                op <= "000";                --Load operant value
                                IE <= '0';                  --Disable Enable
                                BypassA <= '0';             --Disable BypassA
                                BypassB <= '0';             --Disable BypassB   
                                ie <= '0';
                                WAddr <= rx;
                                oe <= '0';

                        end case;

                    when "001" =>
                        case Instruction_Register(15 downto 12) is
                            when iADD =>
                                Z_flag_Latch <= Z_flag;         --Latch flags
                                N_flag_Latch <= N_flag;         --Latch flags
                                O_flag_Latch <= O_flag;         --Latch flags
                                bypassB <= '1';                 --Enable bypassB - increment PC
                                bypassA <= '0';                 --Disable bypassA
                                op <= "111";
                                Waddr <= R7;               --set write address to the register


                            when iSUB =>
                                Z_flag_Latch <= Z_flag;         --Latch flags
                                N_flag_Latch <= N_flag;         --Latch flags
                                O_flag_Latch <= O_flag;         --Latch flags
                                bypassB <= '1';                 --Enable bypassB - increment PC
                                bypassA <= '0';                 --Disable bypassA
                                op <= "111";
                                Waddr <= R7;                 --set write address to the register

                            when iAND =>
                                Z_flag_Latch <= Z_flag;         --Latch flags
                                N_flag_Latch <= N_flag;         --Latch flags
                                O_flag_Latch <= O_flag;         --Latch flags
                                bypassB <= '1';                 --Enable bypassB - increment PC
                                bypassA <= '0';                 --Disable bypassA
                                Waddr <= R7; 
                                op <= "111";
                                
                            when iOR =>
                                Z_flag_Latch <= Z_flag;         --Latch flags
                                N_flag_Latch <= N_flag;         --Latch flags
                                O_flag_Latch <= O_flag;         --Latch flags
                                bypassB <= '1';                 --Enable bypassB - increment PC
                                bypassA <= '0';                 --Disable bypassA
                                Waddr <= R7; 
                                op <= "111";

                            when iXOR =>
                                Z_flag_Latch <= Z_flag;         --Latch flags
                                N_flag_Latch <= N_flag;         --Latch flags
                                O_flag_Latch <= O_flag;         --Latch flags
                                bypassB <= '1';                 --Enable bypassB - increment PC
                                bypassA <= '0';                 --Disable bypassA
                                Waddr <= R7; 
                                op <= "111";

                            when iNOT =>
                                Z_flag_Latch <= Z_flag;         --Latch flags
                                N_flag_Latch <= N_flag;         --Latch flags
                                O_flag_Latch <= O_flag;         --Latch flags
                                bypassB <= '1';                 --Enable bypassB - increment PC
                                bypassA <= '0';                 --Disable bypassA
                                Waddr <= R7; 
                                op <= "111";

                            when iMOV =>
                                Z_flag_Latch <= Z_flag;         --Latch flags
                                N_flag_Latch <= N_flag;         --Latch flags
                                O_flag_Latch <= O_flag;         --Latch flags
                                bypassB <= '1';                 --Enable bypassB - increment PC
                                bypassA <= '0';                 --Disable bypassA
                                Waddr <= R7;
                                op <= "111";

                            when iNOP =>
                                address <= alu_output;          --Set address register to new pc
                                --set everything to 0
                                readA <= '0';               --Disable ReadA
                                readB <= '0';               --Disable ReadB
                                ALU_Enable <= '0';          --Disable ALU
                                Write <= '0';               --Disable Write
                                WAddr <= Rx; 
                                BypassA <= '0';             --Disable BypassA
                                BypassB <= '0';             --Disable BypassB
                                IE <= '0';                  --Disable Enable
                                oe <= '0';
                                RA <= Rx;
                                RB <= Rx;
                                op <= "111";

                            when iLD =>        
                                --ADDRESS = R2, READ
                                address <=ALU_output;
                                --increment pc ???
                                WAddr <= R7;
                                Write <= '1';
                                ie <= '0';
                                bypassB<= '1';
                                bypassA<= '0';
                                op <= "111";
                                
                            when iST =>
                                --Write R2 to Dout
                                Dout <= alu_output;
                                --increment pc
                                WAddr <= R7;
                                write <= '1';
                                ie <= '0';
                                bypassB <= '1';
                                bypassA <= '0';
                                op <= "111";

                            when iLDI =>
                                --Increment PC
                                Waddr <= R7;
                                bypassB <= '1';
                                bypassA <= '0';
                                op <= "111";

                            when iBRZ | iBRN | iBRO | iBRA =>
                             --set address register to new pc
                                address <= alu_output;
                                --disable all
                                readA <= '0';
                                readB <= '0';
                                alu_enable <= '0';
                                write <= '0';
                                WAddr <= Rx;
                                bypassA <= '0';
                                bypassB <= '0';
                                ie <= '0';
                                oe <= '0';
                                
                            when others =>
                                --disable all
                                readA <= '0';
                                readB <= '0';
                                alu_enable <= '0';
                                write <= '0';
                                Waddr <= Rx;
                                bypassA <= '0';
                                bypassB <= '0';
                                ie <= '0';
                                oe <= '0';
                        end case;
                    when "010" =>
                            case instruction_Register (15 downto 12) is
                                when iADD | iSUB | iAND | iOR | iXOR | iNOT | iLDI | iMOV =>
                                    address <= ALU_output;   --Set address register to new pc
                                    --disable all
                                    readA <= '0';
                                    readB <= '0';
                                    ALU_enable <= '0';
                                    write <= '0';
                                    WAddr <= rx;
                                    bypassA <= '0';
                                    bypassB <= '0';
                                    ie <= '0';
                                    oe <= '0';
                                    ra<= rx;
                                    rb<= rx;
                                                                   
                                when iLD => 
                                    --Latch data
                                    ie <= '1';
                                    WAddr <= instruction_register (11 downto 9);
                                    write <= '1';
                                    address <= ALU_output;
                                    --disable all. keep write on to register
                                    readA <= '0';
                                    readB <= '0';
                                    ALU_Enable <= '0';
                                    bypassA <='0';
                                    bypassB <='0';
                                    oe<= '0';
                                    RA <= Rx;
                                    RB <= Rx;  

                                when iST =>
                                    write <= '0';           --disable wrote
                                    address <= ALU_output;  --latch pc to address
                                    ra<=instruction_register(11 downto 9); --RA register
                                    op <= "110";            --set opcode
                                    bypassA <= '0';         --disable bypassA
                                    bypassB <= '0';         --disable bypassB

                                when others =>
                                    --disable all
                                    readA <= '0';
                                    readB <= '0';
                                    ALU_enable <= '0';
                                    write <= '0';
                                    WAddr <= rx;
                                    bypassA <= '0';
                                    bypassB <= '0';
                                    ie <= '0';
                                    oe <= '0';
                                    RA <= Rx;
                                    RB <= Rx;
                            end case;
                        
                    when "011" =>
                        case instruction_register (15 downto 12) is
                            when iST =>
                            RW<='0';
                                --ADdress = R1
                                address <= ALU_output;
                                --Disable all;
                                readA <= '0';
                                readB <= '0';
                                ALU_enable <= '0';
                                write <= '0';
                                WAddr <= rx;
                                bypassA <= '0';
                                bypassB <= '0';
                                ie <= '0';
                                oe <= '0';
                                ra<=rx;
                                rb<=rx;

                            when others=>
                                --Disable all;
                                readA <= '0';
                                readB <= '0';
                                ALU_enable <= '0';
                                write <= '0';
                                WAddr <= rx;
                                bypassA <= '0';
                                bypassB <= '0';
                                ie <= '0';
                                oe <= '0';
                                ra<=rx;
                                rb<=rx;
                        end case;
                        upc <= "000";
                    when "100" =>
                        upc <= "000";
                when others=>
                    upc<= "000";
            end case;
        end if;               
    end process;
end architecture;