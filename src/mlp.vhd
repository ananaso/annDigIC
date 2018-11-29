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
    u : in std_logic_vector(N * (littleM + littleN) - 1 downto 0);
    yhat : out std_logic_vector(M * (littleM + littleN) - 1 downto 0)
);
end mlp;

architecture Behavioral of mlp is

component NNode
port (
    clk     : in std_logic;
    u       : in std_logic_vector(7 downto 0);
    W       : in hQArray;
    n_out    : out hQArray
);
end component;

component HNode
port (
    clk     : in std_logic;
    h_in    : in nQArray;
    W       : in mQArray;
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

type t_wArray is array (wArrayWidth - 1 downto 0, wArrayDepth - 1 downto 0) of sfixed(littleM downto littleN);
signal wArray : t_wArray;

signal wByte, nextWByte, storeByte : sfixed(littleM downto littleN);
signal readCnt, nextReadCnt : integer := 1;
signal storeCnt, storeWidth, storeDepth : integer := 0;

begin

gen_nlayer: for i in N - 1 downto 0 generate
    nlayer : NNode
    port map (
        clk => clk,
        u((N - i) * (littleM + littleN) - 1 downto (N - i) * (littleM + littleN)) => u((N - i) * (littleM + littleN) - 1 downto (N - i) * (littleM + littleN)),
        W() =>  ,
        n_out => 
    );
end generate gen_nlayer;

readW:process(SI)
begin
    nextWByte <= SI & wByte(littleM - 1 downto littleN);
end process;

counter:process(readCnt)
begin
    nextReadCnt <= readCnt + 1;
end process;

storeCU:process(wByte, readCnt)
begin
    if readCnt rem wWidth = 0 then
        storeByte <= wByte;
        storeCnt <= readCnt mod wWidth;
    end if;
end process storeCU;

arrayIndex:process(storeCnt)
begin
    storeWidth <= storeCnt rem wArrayWidth;
    storeDepth <= storeCnt mod wArrayDepth;
end process arrayIndex;

storeW:process(storeByte)
begin
    wArray(storeWidth, storeDepth) <= storeByte;
end process storeW;

update:process(clk)
begin
    if clk'event and clk = '1' then
        wByte <= nextWByte;
        readCnt <= nextReadCnt;
    end if;
end process update;

end Behavioral;
