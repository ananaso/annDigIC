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

sum:process(h_in, bias)
variable temp : sfixed(littleM downto littleN);
begin
    temp := bias;
    for val in nQArray'reverse_range loop
        temp := resize(temp + h_in(val), temp);
    end loop;
    inputSum <= temp;
end process sum;

relu:process(clk)
begin
    if clk'event and clk = '1' then
        if inputSum < to_sfixed(0, inputSum) then
            reluVal <= to_sfixed(0, reluVal);
        else
            reluVal <= to_sfixed(1, reluVal);
        end if;
    end if;
end process relu;

output:process(reluVal)
begin
    for x in mQArray'reverse_range loop
        h_out(x) <= resize(reluVal, littleM, littleN);
    end loop;
end process output;

end behavioral;
