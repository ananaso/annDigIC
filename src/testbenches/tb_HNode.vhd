----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/17/2018 04:39:51 PM
-- Design Name: 
-- Module Name: tb_HNode - behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;
library ieee_proposed;
use ieee_proposed.fixed_pkg.all;
use work.annGenericArrays_pkg.all;

entity tb_HNode is
end tb_HNode;

architecture behavioral of tb_HNode is

component HNode is
port (
    clk     : in std_logic;
    h_in    : in nQArray;
    bias    : in sfixed(littleM downto littleN);
    h_out   : out mQArray
);
end component HNode;

signal clk : std_logic;
signal h_in : nQArray;
signal bias : sfixed(littleM downto littleN);
signal h_out : mQArray;

signal clk_period : time := 10 ns;

begin

HNode0:HNode port map (
    clk => clk,
    h_in => h_in,
    bias => bias,
    h_out => h_out
);

-- Clock process definitions
clock:process
begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
end process clock;

-- Main stimulus Process
main:process
begin
    bias <= to_sfixed(0.1, littleM, littleN);
    for x in 0 to nQArray'length - 1 loop
        h_in(x) <= to_sfixed(-0.5, littleM, littleN);
    end loop;
    wait for clk_period;
    
    
    bias <= to_sfixed(20, littleM, littleN);
    for x in 0 to nQArray'length - 1 loop
        h_in(x) <= to_sfixed(-0.5, littleM, littleN);
    end loop;
    wait for clk_period;
    
    bias <= to_sfixed(0.1, littleM, littleN);
    for x in 0 to nQArray'length - 1 loop
        h_in(x) <= to_sfixed(0.5, littleM, littleN);
    end loop;
    wait for clk_period;
    
    bias <= to_sfixed(-20, littleM, littleN);
    for x in 0 to nQArray'length - 1 loop
        h_in(x) <= to_sfixed(0.5, littleM, littleN);
    end loop;
    wait for clk_period;
    
    wait for clk_period * 10;
    assert false report "End of Simulation" severity failure;
    
end process main;

end behavioral;
