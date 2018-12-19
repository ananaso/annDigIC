library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.annGenericArrays_pkg.all;
library ieee_proposed;
use ieee_proposed.fixed_pkg.all;

entity tb_NNode is
end tb_NNode;

architecture behavioral of tb_NNode is

component NNode is
port (
    clk     : in std_logic;
    u       : in sfixed(littleM downto littleN);
    n_out   : out hQArray
);
end component NNode;

signal clk : std_logic;
signal u : sfixed(littleM downto littleN);
signal n_out : hQArray;

signal clk_period : time := 10 ns;

begin

NNode0:NNode
port map (
    clk => clk,
    u => u,
    n_out => n_out
);

-- Clock process definitions
clock:process
begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
end process clock;

-- Stimulus process
main:process
variable temp : std_logic_vector(8 downto 0);
begin
    temp := '1' & X"ff";
    u <= to_sfixed(temp, littleM, littleN);
    wait for clk_period;
    
    u <= to_sfixed(0.0, littleM, littleN);
    wait for clk_period;
    
    u <= to_sfixed(1.0, littleM, littleN);
    wait for clk_period;
    
    u <= to_sfixed(-1.0, littleM, littleN);
    wait for clk_period;
    
    u <= to_sfixed(0.675, littleM, littleN);
    wait for clk_period;
    
    wait for clk_period * 10;
    assert false report "End of Simulation" severity failure;
    
end process main;

end behavioral;
