----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/18/2018 04:08:57 PM
-- Design Name: 
-- Module Name: mlp - Behavioral
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
library ieee_proposed;
use ieee_proposed.fixed_pkg.all;
use work.annGenericArrays_pkg.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

entity mlp is
port (
    SI : in std_logic;
    SE : in std_logic;
    clk : in std_logic;
    u : in std_logic_vector(N * 8 - 1 downto 0);
    yhat : out std_logic_vector(M * 8 - 1 downto 0)
);
end mlp;

architecture Behavioral of mlp is

component NNode
port (
    clk     : in std_logic;
    u       : in std_logic_vector(7 downto 0);
    n_out    : out hQArray
);
end component;

component HNode
port (
    clk     : in std_logic;
    h_in    : in nQArray;
    h_out   : out mQArray
);
end component;

component MNode
port (
    clk     : in std_logic;
    m_in    : in hQArray;
    m_out   : out std_logic
);
end component;

constant wWidth : integer := littleM + littleN + 1;
constant wArrayWidth : integer := N + H + M + 1;
constant wArrayDepth : integer := N + H + M + 1;

-- weights and bias array definitions
type t_wArrayNode is array (0 to wArrayDepth - 1) of sfixed(littleM downto littleN);
type t_wArray is array (0 to wArrayWidth - 1) of t_wArrayNode;
signal wArray : t_wArray;

-- output passing arrays
-- handles weighting of values when passing between layers
type t_nhArray is array (0 to N - 1) of hQArray;
type t_wnhArray is array (0 to H - 1) of nQArray;
type t_hmArray is array (0 to H - 1) of hQArray;
type t_whmArray is array (0 to M - 1) of hQArray;
signal nhArray : t_nhArray;
signal hmArray : t_hmArray;
signal wnhArray : t_wnhArray;
signal whmArray : t_whmArray;

-- signals for storing bytes into the weights array
signal wByte, nextWByte, storeByte : sfixed(littleM downto littleN);
signal readCnt, nextReadCnt : integer := 1;
signal storeCnt, storeWidth, storeDepth : integer := 0;

begin

-- N/Input Layer
gen_nlayer: for i in 0 to N - 1 generate
    nlayer : NNode
    port map (
        clk => clk,
        u((N - i) * (littleM + littleN) - 1 downto (N - i) * (littleM + littleN)) => u((N - i) * (littleM + littleN) - 1 downto (N - i) * (littleM + littleN)),
        n_out => nhArray(i)
    );
end generate gen_nlayer;

-- H/Hidden Layer
--TODO
--TODO
--TODO

-- Multiply all outputs of N layer and transpose for input to H layer
multTransposeNH:process(nhArray)
begin
    for x in nhArray'range loop
        for y in wnhArray'range loop
            wnhArray(y)(x) <= wArray(x + 1)(y + N) * nhArray(x)(y);
        end loop;
    end loop;
end process multTransposeNH;

-- Multiply all outputs of H layer and transpose for input to M layer
multTransposeHM:process(hmArray)
begin
    for x in hmArray'range loop
        for y in whmArray'range loop
            whmArray(y)(x) <= wArray(x + 1 + N)(y + N + H) * hmArray(x)(y);
        end loop; 
    end loop;
end process multTransposeHM;

-- Read bit in from SerialIn to reconstruct fixed-point number
readW:process(SI)
begin
    nextWByte <= SI & wByte(littleM - 1 downto littleN);
end process;

-- parallel-out each fully-constructed number
storeCU:process(wByte, readCnt)
begin
    if readCnt rem wWidth = 0 then
        storeByte <= wByte;
        storeCnt <= readCnt mod wWidth;
    end if;
end process storeCU;

-- calculate the index of the weight array for the next number
arrayIndex:process(storeCnt)
begin
    storeWidth <= storeCnt rem wArrayWidth;
    storeDepth <= storeCnt mod wArrayDepth;
end process arrayIndex;

-- Store reconstructed byte into the weight array
storeW:process(storeByte)
begin
    wArray(storeWidth)(storeDepth) <= storeByte;
end process storeW;

-- Count number of bits read in; updates each clock cycle
counter:process(readCnt)
begin
    nextReadCnt <= readCnt + 1;
end process;

-- Synchronize all variables on the clock rising edge
update:process(clk)
begin
    if clk'event and clk = '1' then
        wByte <= nextWByte;
        readCnt <= nextReadCnt;
    end if;
end process update;

end Behavioral;
