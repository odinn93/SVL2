library ieee;
use ieee.std_logic_1164.all;

entity gpio is
    generic (N:integer);
    port (clk, rst, ie, oe : in std_logic;
        Din: in std_logic_vector(N-1 downto 0);
        Dout: out std_logic_vector(N-1 downto 0)        
    );
end gpio;

architecture behave of gpio is
    signal data : std_logic_vector(N-1 downto 0);
begin
    process(clk, rst)
    begin
        if(rst = '1') then
            data <= (others => '0');
        elsif rising_edge(clk) then
            if ie = '1' then
                data <= Din;
            end if;
        end if;
    end process;
    --Dout <= "1111111111111111" when (oe = '1') else (others => '0'); to show it works when we force it

    Dout <= data when (oe = '1') else (others => '0');
end architecture;