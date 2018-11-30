library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library ieee_proposed;
use ieee_proposed.fixed_pkg.all;
use work.annGenericArrays_pkg.all;

entity tb_MNode is
end tb_MNode;

architecture Behavioral of tb_MNode is

component MNode is
port (
    clk     : in std_logic;
    m_in    : in hQArray;
    bias    : in sfixed(littleM downto littleN);
    m_out   : out std_logic
);
component MNode;

signal d_in : std_logic_vector(7 downto 0);
signal clk : std_logic;
signal en_in, en_reg : std_logic;
signal d_out : std_logic_vector(7 downto 0);
signal d_valid : std_logic;

constant clk_period : time := 10 ns;

begin

UUT : MNode
port map (
    clk  => clk;
    m_in => m_in;
    bias => bias;
    m_out => m_out;
);

-- Clock process definitions
process
begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
end process;


process
begin
    -- pipe in testing data
    m_in <= ("0000", "0001", "0010", "0011", "0100", "0101", "0110", "0111");
   
    assert false
        report "End of simulation"
        severity failure;
end process;

end Behavioral;
