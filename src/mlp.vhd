----------------------------------------------
-- Class: Digital IC Design
-- School: Rochester Institute of Technology
-- Engineers: Alden Davidson, John Judge
-- 
-- Final Project, Fall 2018
-- Artificial Neural Network
-- Module Name: mlp - mixed
----------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library ieee_proposed;
use ieee_proposed.fixed_pkg.all;
use work.annGenericArrays_pkg.all;

entity mlp is
GENERICIZE??
port (
    SI      : in std_logic;
    SE      : in std_logic;
    clk     : in std_logic;
    u       : in std_logic_vector(mlpN * 8 - 1 downto 0);
    yhat    : out std_logic_vector(mlpM * 8 - 1 downto 0)
);
end mlp;

architecture mixed of mlp is

-- node for input layer
component NNode
port (
    clk     : in std_logic;
    u       : in std_logic_vector(7 downto 0);
    n_out   : out hQArray
);
end component;

-- node for hidden layer
component HNode
port (
    clk     : in std_logic;
    h_in    : in nQArray;
    bias    : in sfixed(littleM downto littleN);
    h_out   : out mQArray
);
end component;

-- node for output layer
component MNode
port (
    clk     : in std_logic;
    m_in    : in hQArray;
    bias    : in sfixed(littleM downto littleN);
    m_out   : out std_logic
);
end component;

-- constants for width of weights and their array
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
type t_hmArray is array (0 to H - 1) of mQArray;
type t_whmArray is array (0 to M - 1) of hQArray;
type t_mOutArray is array (0 to M - 1) of std_logic;
signal nhArray : t_nhArray;
signal wnhArray : t_wnhArray;
signal hmArray : t_hmArray;
signal whmArray : t_whmArray;
signal mOutArray : t_mOutArray;

-- signals for storing bytes into the weights array
signal wByte, nextWByte : sfixed(littleM downto littleN);
signal storeByte, nextStoreByte : sfixed(littleM downto littleN);
signal readCnt, nextReadCnt : unsigned(2 downto 0) := (others => '0');
signal storeCnt, nextStoreCnt : integer := 0;
signal storeWidth, nextStoreWidth, storeDepth, nextStoreDepth : integer := 0;
signal arrayByte : sfixed(littleM downto littleN);

begin

---------------------------------------------------------------------------
---------------------------- LAYER GENERATION -----------------------------
---------------------------------------------------------------------------

-- N/Input Layer
gen_nlayer : for i in 0 to N - 1 generate
    nlayer : NNode port map (
        clk => clk,
        u => u((N - i) * 8 - 1 downto (N - i) * 8 - 8),
        n_out => nhArray(i)
    );
end generate gen_nlayer;

-- H/Hidden Layer
gen_hlayer : for i in 0 to H - 1 generate
    hlayer : HNode port map (
        clk => clk,
        h_in => wnhArray(i),
        bias => wArray(0)(N + 1 + i),
        h_out => hmArray(i)
    );
end generate gen_hlayer;

-- M/Output Layer
gen_mlayer : for i in 0 to M - 1 generate
    mlayer : MNode port map (
        clk => clk,
        m_in => whmArray(i),
        bias => wArray(0)(N + H + 1 + i),
        m_out => mOutArray(i)
    );
end generate gen_mlayer;

---------------------------------------------------------------------------
---------------------- LAYER INPUT/OUTPUT ALIGNMENT -----------------------
---------------------------------------------------------------------------

-- Multiply all outputs of N layer and transpose for input to H layer
-- Transposition: N-Layer outputs N H-sized Arrays
--                H-Layer inputs H N-sized Arrays
multTransposeNH:process(nhArray, wArray)
begin
    for x in nhArray'range loop
        for y in wnhArray'range loop
            wnhArray(y)(x) <= resize(wArray(x + 1)(y + N + 1) * nhArray(x)(y), littleM, littleN);
        end loop;
    end loop;
end process multTransposeNH;

-- Multiply all outputs of H layer and transpose for input to M layer
-- Transposition: H-Layer outputs H M-sized Arrays
--                M-Layer inputs M H-sized Arrays
multTransposeHM:process(hmArray, wArray)
begin
    for x in hmArray'range loop
        for y in whmArray'range loop
            whmArray(y)(x) <= resize(wArray(x + 1 + N)(y + N + H + 1) * hmArray(x)(y), littleM, littleN);
        end loop; 
    end loop;
end process multTransposeHM;

---------------------------------------------------------------------------
------------------------ WEIGHT ARRAY CONSTRUCTION ------------------------
---------------------------------------------------------------------------

-- Synchronize all variables on the clock rising edge
update:process(clk)
begin
    if clk'event and clk = '1' then
        wByte <= nextWByte;
        readCnt <= nextReadCnt;
        storeByte <= nextStoreByte;
        storeCnt <= nextStoreCnt;
        storeWidth <= nextStoreWidth;
        storeDepth <= nextStoreDepth;
        wArray(storeWidth)(storeDepth) <= nextStoreByte;
    end if;
end process update;

-- count number of bits read in
counter:process(readCnt, SE)
begin
    if SE = '1' then
        nextReadCnt <= readCnt + 1;
    else
        nextReadCnt <= readCnt;
    end if;
end process counter;

-- Read bit in from SerialIn to reconstruct fixed-point number
readW:process(SI, SE, wByte)
begin
    if SE = '1' then
        nextWByte <= SI & wByte(littleM - 1 downto littleN);
    else
        nextWByte <= wByte;
    end if;
end process readW;

-- update storeByte and storeCnt whenever 9 bits are read
storeCU:process(wByte, readCnt, SE, storeByte, storeCnt)
begin
    if SE = '1' and readCnt = 8 then
        nextStoreByte <= wByte;
        nextStoreCnt <= storeCnt + 1;
    else
        nextStoreByte <= storeByte;
        nextStoreCnt <= storeCnt;
    end if;
end process storeCU;

-- calculate the index of the weight array for the next number
arrayIndex:process(storeCnt, SE, storeWidth, storeDepth)
begin
    if SE = '1' then
        nextStoreWidth <= storeCnt rem wArrayWidth;
        nextStoreDepth <= storeCnt mod wArrayDepth;
    else
        nextStoreWidth <= storeWidth;
        nextStoreDepth <= storeDepth;
    end if; 
end process arrayIndex;

-- Store reconstructed byte into the weight array
--storeW:process(storeByte, storeWidth, storeDepth, SE, wArray)
--begin
--    if SE = '1' then
--        arrayByte <= storeByte;
--    else
--        arrayByte <= wArray(storeWidth)(storeDepth);
--    end if;
--end process storeW;

---------------------------------------------------------------------------
--------------------------- OUTPUT CALCULATION ----------------------------
---------------------------------------------------------------------------

scaleOuts:process(mOutArray)
begin
    for x in mOutArray'range loop
        if mOutArray(x) = '1' then
            yhat(x * 8 + 7 downto x * 8) <= X"FF";    -- 255, 0b11111111
        else
            yhat(x * 8 + 7 downto x * 8) <= X"00";    -- 0, 0b00000000
        end if;
    end loop;
end process scaleOuts;

end mixed;
