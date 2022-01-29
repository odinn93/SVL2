entity test is
    end test;

library IEEE;
use ieee.std_logic_1164.all;

architecture behave of test is

    component occ
        port(
            clk, rst : in std_logic;
            led_output : out std_logic_vector(15 downto 0);
            clk_out : out std_logic;
            Z_Flag, N_Flag, O_Flag : out std_logic --TESTING
        );
      end component;
      
      signal clk, rst : std_logic:='0';
      signal led_output :std_logic_vector(15 downto 0);
      signal clk_out : std_logic;
      signal Z_Flag, N_Flag, O_Flag : std_logic; --TESTING

      begin
        clk<=not clk after 5 ns;
        rst<='0', '1' after 10 ns, '0' after 21 ns;
        DUT:  occ port map
        (
        clk=>clk,
        rst=>rst,
        led_output=>led_output,
        clk_out=>clk_out,
        Z_flag=>Z_flag,
        N_flag=>N_flag,
        O_flag=>O_flag
        
        );
        
    end behave;
