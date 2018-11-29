library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library ieee_proposed;
use ieee_proposed.fixed_pkg.all;
use work.annGenericArrays_pkg.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

entity NNode is
port (
    clk     : in std_logic;
    u       : in std_logic_vector(7 downto 0);
    W       : in hQArray;
    n_out    : out hQArray
);
end NNode;

architecture Behavioral of NNode is

signal scaledU : sfixed(littleM downto littleN);

begin

scale:process(clk)
begin
    if clk'event and clk = '1' then
        scaledU <= to_sfixed(to_integer(unsigned(u) / 255), scaledU);
    end if;
end process scale;

mult:process(scaledU, W)
begin
    for x in 0 to hQArray'length - 1 loop
        n_out(x) <= scaledU * W(x);
    end loop;
end process mult;

end Behavioral;
