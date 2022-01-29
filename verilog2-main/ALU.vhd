    --Import library
library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;
    --use IEEE.std_logic_signed.all;
    --use IEEE.std_logic_arith.all;
    use IEEE.std_logic_unsigned.all;

--Declare the ALU Entity
entity ALU is
    generic (N    : integer);
    port (a,b                   :   in std_logic_vector (N-1 downto 0);          --Two signed inputs
          op                    :   in std_logic_vector (2 downto 0);  --One std_logic operator vector
          sum                   :   out std_logic_vector (N-1 downto 0);       --The output sum has to be defined as INOUT because we have to be able to check its value.
          en,rst                :   in std_logic; --NEW REGISTERS      
          Z_flag,N_flag,O_flag  :   out std_logic); --The flags are simple std_logic outputs
          
end ALU;

--Architecture, description of behaviour
-- For Lab 3, the tmp signals act as registers
architecture behavior of ALU is 
signal sum_tmp: std_logic_vector(N-1 downto 0) := (others => '0');
signal Z_tmp: std_logic := '0';
signal N_tmp: std_logic := '0';
signal O_tmp: std_logic := '0';

constant all_zeros : std_logic_vector(N-1 downto 0) := (others => '0');

begin
    --We begin a process where we check a,b,op and sum
    process (rst,A,B,sum_tmp, Z_tmp, N_tmp, O_tmp) -- we are adding a,b,sum_tmp,n_tmp becuase there is no clock anymore 
    begin
       -- if rst='1' then -- DO RESET
           -- sum <= (others => '0');
           -- sum_tmp <= (others => '0');
          --  z_flag<='0';
          --  n_flag<='0';
          --  o_flag<='0';
        --elsif (rising_edge(clk) and en='1')then --NORMAL OPERATION
        --elsif (en='1')then --NORMAL OPERATION 
                case op is
                    when "000"=>sum_tmp<= std_logic_vector(signed(a)+signed(b));     --Addition
                    -- If the first bits of a and b are the same but the first bit of sum
                    --  is the opposite, then we have an overflow and O_flag is set to '1'
                        --if a(N-1)=b(N-1) and sum_tmp(N-1)/=a(N-1) then O_tmp<='1';
                        --    else O_tmp<='0';
                        --end if;
                    when "001"=>sum_tmp<= std_logic_vector(signed(a)-signed(b));     --Subtraction       
                    -- If the first bits of a and b are different, then overflow will occur
                    --  if the result has the same sign (first bit) as b
                        --if a(N-1)/=b(N-1) and sum_tmp(N-1)/=b(N-1) then O_tmp<='1';
                        --    else O_tmp<='0';
                        --end if;
                    when "010"=>sum_tmp<= a AND b; --AND gate
                    when "011"=>sum_tmp<=a or b;  --OR gate
                    when "100"=>sum_tmp<=a xor b; --XOR gate
                    when "101"=>sum_tmp<= not a;  --NOT gate
                    when "110"=>sum_tmp<=a;       --sum equal to a

                    --!!!!!!! Change for any number of 0
                    when "111"=>sum_tmp<=a+1;  --sum equal to 0 / for lab 2 change to increment
                    when others=> null;         
                end case;
              
             --   if ((op = "000") AND (a(N-1)=b(N-1) and sum_tmp(N-1)/=a(N-1))) then O_tmp<='1';
              --      else O_tmp<='0';
              --  end if;

              --  if ((op = "001") AND (a(N-1)/=b(N-1) and sum_tmp(N-1)/=b(N-1))) then O_tmp<='1';
              --      else O_tmp<='0';
               -- end if;

                -- If the first bit of sum is "1", then it is a negative number and N_flag is set to '1'
                if sum_tmp(N-1)='1' then N_tmp<='1';
                    else N_tmp<='0';
                end if;
                -- We check to see if all the bits in sum are "0", and if so, set Z_flag to '1'
                
                --!!!!!!! Change for any number of 0xz
                if sum_tmp=all_zeros then Z_tmp<='1';
                   else Z_tmp<='0';
                end if; 
        
            sum <= sum_tmp;
            Z_flag <= Z_tmp;
            O_flag <= O_tmp;
            N_flag <= N_tmp;
       -- end if;
        --Update the register when RegEn = 1. Used to be inside the previous if-loop and clocked
        --if RegEn = '1' then
            
        --end if;
    end process;
    O_tmp <= '1' when ((en = '1') AND (Op = "000") AND (std_logic_vector'(A(N-1) & B(N-1) & Sum_tmp(N-1)) = "001")) else
    '1' when ((en = '1') AND (Op = "000") AND (std_logic_vector'(A(N-1) & B(N-1) & Sum_tmp(N-1)) = "110")) else
    '1' when ((en = '1') AND (Op = "001") AND (std_logic_vector'(A(N-1) & B(N-1) & Sum_tmp(N-1)) = "011")) else
    '1' when ((en = '1') AND (Op = "001") AND (std_logic_vector'(A(N-1) & B(N-1) & Sum_tmp(N-1)) = "100")) else
    '0';
end architecture; 



