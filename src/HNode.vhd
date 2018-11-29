library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library ieee_proposed;
use ieee_proposed.fixed_pkg.all;
use work.annGenericArrays_pkg.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

entity HNode is
port (
    clk     : in std_logic;
    h_in    : in nQArray;
    W       : in mQArray;
    h_out   : out mQArray
);
end HNode;

architecture Behavioral of HNode is

signal inputSum : sfixed(littleM downto littleN);
signal reluVal : sfixed(littleM downto littleN);

begin

sum:process(h_in)
variable temp : sfixed(littleM downto littleN) := to_sfixed(0, littleM, littleN);
begin
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
        h_out(x) <= reluVal * W(x);
    end loop;
end process output;

end Behavioral;
