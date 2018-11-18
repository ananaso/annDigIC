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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

entity mlp is
generic (
    N : integer := 9;
    H : integer := 20;
    M : integer := 1;
    littleM : integer := 4;
    littleN : integer := 4
);
port (
    SI : in std_logic;
    SE : in std_logic;
    clk : in std_logic;
    u : in std_logic_vector(N * (littleM + littleN + 1) downto 0);
    yhat : out std_logic_vector(M * (littleM + littleN + 1) downto 0)
);
end mlp;

architecture Behavioral of mlp is

begin


end Behavioral;
