----------------------------------------------
-- Class: Digital IC Design
-- School: Rochester Institute of Technology
-- Engineers: Alden Davidson, John Judge
-- 
-- Final Project, Fall 2018
-- Artificial Neural Network
-- Module Name: MNode - behavioral
--
-- Description: Output layer node
----------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library ieee_proposed;
use ieee_proposed.fixed_pkg.all;
use work.annGenericArrays_pkg.all;

entity MNode is
port (
    clk     : in std_logic;
    m_in    : in hQArray;
    bias    : in sfixed(littleM downto littleN);
    m_out   : out std_logic
);
end MNode;

architecture behavioral of MNode is

signal inputSum : sfixed(littleM downto littleN) := to_sfixed(0, littleM, littleN);
signal reluVal : sfixed(littleM downto littleN);

begin

sum:process(m_in, bias)
variable temp : sfixed(littleM downto littleN) := to_sfixed(0, littleM, littleN);
begin
    temp := bias;
    for val in m_in'reverse_range loop
        temp := resize(temp + m_in(val), temp);
    end loop;
    inputSum <= temp;
end process sum;

relu:process(clk)
begin
    if clk'event and clk = '1' then
        if inputSum <= to_sfixed(0, inputSum) then
            reluVal <= to_sfixed(0, reluVal);
        elsif inputSum >= to_sfixed(1, inputSum) then
            reluVal <= to_sfixed(1, reluVal);
        else
            reluVal <= resize(inputSum, reluVal);
        end if;
    end if;
end process relu;

output:process(reluVal)
begin
    if reluVal < to_sfixed(0.5, reluVal) then
        m_out <= '0';
    else
        m_out <= '1';
    end if;
end process output;

end behavioral;
