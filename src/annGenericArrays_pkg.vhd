library ieee;
use IEEE.NUMERIC_STD.ALL;
library ieee_proposed;
use ieee_proposed.fixed_pkg.all;

package annGenericArrays_pkg is
    constant N : integer := 9;
    constant H : integer := 20;
    constant M : integer := 1;
    constant littleM : integer := 4;
    constant littleN : integer := -4;
    type pixelArray is array (0 to N - 1) of sfixed(littleM downto littleN);
    type nQArray is array (N - 1 downto 0) of sfixed(littleM downto littleN);
    type hQArray is array (H - 1 downto 0) of sfixed(littleM downto littleN);
    type mQArray is array (M - 1 downto 0) of sfixed(littleM downto littleN);
end package;