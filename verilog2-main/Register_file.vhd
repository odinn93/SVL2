    --Import librar
    library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;
    use IEEE.std_logic_signed.all;
    use work.all;

--Declare the Register File Entity
entity register_file is
    generic(
        M,N : INTEGER);    --Declare M and N as generic values (is this terminology correct?)
    port (    WD    : in std_logic_vector (N-1 downto 0);        --Write Data (N bits wide)
              WAddr : in STD_LOGIC_VECTOR (M-1 downto 0);     --Write Address (M bits wide)
              Write : in STD_LOGIC;                           --Write='1' writes register pointed to by Write Address.
              -- Registers should be written on positive flank

              RA    : in STD_LOGIC_VECTOR (M-1 downto 0);        --Read Address A (M bits wide)
              ReadA : in STD_LOGIC;                            --ReadA='1' reads register pointed to by Read Address A. 
              -- Output should be updated immediately. ReadA='0' should output a 0.
              QA    : out std_logic_vector (n-1 downto 0);         --Outputs a value from the register pointed to by RA

              RB    : in STD_LOGIC_VECTOR (M-1 downto 0);        --------------------
              ReadB : in STD_LOGIC;                            -- SAME AS WITH A --
              QB    : out std_logic_vector(N-1 downto 0);         --------------------

              rst,clk: in STD_LOGIC);                         --Reset and Clock registers         
end register_file;

architecture behavior of register_file is
    type mem is array(0 to 2**M-1) of std_logic_vector(N-1 downto 0);  --Which refers to the address and which refers to the data?
    signal memory : mem;
begin
    process (clk,rst)
    begin
        if rst='1' then -- DO RESET
            MEMORY <= (OTHERS => (OTHERS => '0')); --every bit 
        elsif rising_edge(clk) then --NORMAL OPERATION
            if (Write = '1') then
                memory(to_integer(unsigned(WAddr))) <= WD; --write value of WD to Waddr when write = 1 
            end if;
        end if;
    end process;
    QA <= memory(to_integer(unsigned(RA))) when ReadA='1' else (others => '0');
    QB <= memory(to_integer(unsigned(RB))) when ReadB='1' else (others => '0');
end behavior;
