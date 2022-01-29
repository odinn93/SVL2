library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;

--Declare the Clock Divider Entitiy
entity clockdiv is
    port(   clk,rst    :   IN   STD_LOGIC;
            clock_out  :   OUT  STD_LOGIC);
end clockdiv;

--Architecture, description of behaviour
architecture behavior of clockdiv is 
    signal count: INTEGER   := 1;
    signal tmp:   STD_LOGIC := '0';
begin
    process(clk,rst)
    begin
        if (rst = '1') then
            count <= 1;
            tmp   <= '0';
        elsif (clk'event and clk = '1') then
            count <= count+1;
            if (count = 200e4) then
                tmp <= NOT tmp;
                count <= 1;
            end if;
        end if;
    clock_out <= tmp;
    end process;
end behavior;

