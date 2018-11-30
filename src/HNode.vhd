----------------------------------------------
-- Class: Digital IC Design
-- School: Rochester Institute of Technology
-- Engineers: Alden Davidson, John Judge
-- 
-- Final Project, Fall 2018
-- Artificial Neural Network
-- Module Name: HNode - behavioral
--
-- Description: Hidden layer node
----------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library ieee_proposed;
use ieee_proposed.fixed_pkg.all;
use work.annGenericArrays_pkg.all;

entity HNode is
port (
    clk     : in std_logic;
    h_in    : in nQArray;
    bias    : in sfixed(littleM downto littleN);
    h_out   : out mQArray
);
end HNode;

architecture behavioral of HNode is

signal inputSum : sfixed(littleM downto littleN);
signal reluVal : sfixed(littleM downto littleN);

begin

sum:process(h_in)
variable temp : sfixed(littleM downto littleN) := to_sfixed(0, littleM, littleN);
begin
    temp := bias;
    for val in nQArray'reverse_range loop
        temp := resize(temp + h_in(val), inputSum);
    end loop;
    inputSum <= temp;
end process sum;

relu:process(clk)
begin
    if clk'event and clk = '1' then
        if inputSum <= 0 then
            reluVal <= to_sfixed(0, reluVal);
        elsif inputSum >= 1 then
            reluVal <= to_sfixed(1, reluVal);
        else
            reluVal <= inputSum;
        end if;
    end if;
end process relu;

output:process(reluVal)
begin
    for x in mQArray'reverse_range loop
        h_out(x) <= reluVal;
    end loop;
end process output;

end behavioral;
