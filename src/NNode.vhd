----------------------------------------------
-- Class: Digital IC Design
-- School: Rochester Institute of Technology
-- Engineers: Alden Davidson, John Judge
-- 
-- Final Project, Fall 2018
-- Artificial Neural Network
-- Module Name: NNode - behavioral
--
-- Description: Input layer node
----------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library ieee_proposed;
use ieee_proposed.fixed_pkg.all;
use work.annGenericArrays_pkg.all;

entity NNode is
port (
    clk     : in std_logic;
    u       : in sfixed(littleM downto littleN);
    n_out    : out hQArray
);
end NNode;

architecture behavioral of NNode is

begin

mult:process(clk)
begin
    if clk'event and clk = '1' then
        for x in 0 to hQArray'length - 1 loop
            n_out(x) <= u;
        end loop;
    end if;
end process mult;

end behavioral;
