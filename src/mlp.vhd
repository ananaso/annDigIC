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
port (
    SI      : in std_logic;
    SE      : in std_logic;
    clk     : in std_logic;
    i_valid : in std_logic;
    u       : in pixelArray;
    o_valid : out std_logic;
    yhat    : out std_logic_vector(M * 8 - 1 downto 0)
);
end mlp;

architecture mixed of mlp is

-- node for input layer
component NNode
port (
    clk     : in std_logic;
    u       : in sfixed(littleM downto littleN);
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
    m_out   : out mQArray
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
type t_moArray is array (0 to M - 1) of mQArray;
signal nhArray : t_nhArray;
signal wnhArray : t_wnhArray;
signal hmArray : t_hmArray;
signal whmArray : t_whmArray;
signal mOutArray : t_moArray;

-- signals for storing bytes into the weights array
signal wByte, nextWByte : sfixed(littleM downto littleN);
signal storeByte, nextStoreByte : sfixed(littleM downto littleN);
signal readCnt, nextReadCnt : integer := -1;
signal storeWidth, nextStoreWidth, storeDepth, nextStoreDepth : integer := 0;

-- output signalling stuff
signal compCounter, next_compCounter : integer := -1;
signal next_ovalid : std_logic;

begin

---------------------------------------------------------------------------
---------------------------- LAYER GENERATION -----------------------------
---------------------------------------------------------------------------

-- N/Input Layer
gen_nlayer : for i in 0 to N - 1 generate
    nlayer : NNode port map (
        clk => clk,
        u => u(i),
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
            wnhArray(y)(x) <= resize(wArray(y + N + 1)(x + 1) * nhArray(x)(y), littleM, littleN);
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
            whmArray(y)(x) <= resize(wArray(y + N + H + 1)(x + 1 + N) * hmArray(x)(y), littleM, littleN);
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
        storeWidth <= nextStoreWidth;
        storeDepth <= nextStoreDepth;
        wArray(storeDepth)(storeWidth) <= nextStoreByte;
        compCounter <= next_compCounter;
        o_valid <= next_ovalid;
    end if;
end process update;

-- count number of bits read in
counter:process(readCnt, SE)
begin
    if SE = '1' then
        if readCnt > 7 then
            nextReadCnt <= 0;
        else
            nextReadCnt <= readCnt + 1;
        end if;
    else
        nextReadCnt <= -1;
    end if;
end process counter;

-- Read bit in from SerialIn to reconstruct fixed-point number
readW:process(SI, wByte)
begin
    nextWByte <= wByte(littleM - 1 downto littleN) & SI;
end process readW;

-- update storeByte 9 bits are read
storeCU:process(wByte, readCnt, storeByte)
begin
    if readCnt > 7 then
        nextStoreByte <= wByte;
    else
        nextStoreByte <= storeByte;
    end if;
end process storeCU;

-- counter for the "width" index of the weights array
weightWidth:process(readCnt, storeWidth, SE)
begin
    if SE = '1' and readCnt > 7 then
        if storeWidth < wArrayWidth - 1 then
            nextStoreWidth <= storeWidth + 1;
        else
            nextStoreWidth <= 0;
        end if;
    else
        nextStoreWidth <= storeWidth;
    end if;
end process weightWidth;

-- counter for the "depth" index of the weights array
arrayIndex:process(storeWidth)
begin
    if storeWidth > wArrayWidth - 2 and SE = '1' then
        if storeDepth < wArrayDepth - 1 then
            nextStoreDepth <= storeDepth + 1;
        else
            nextStoreDepth <= storeDepth;
        end if;
    else
        nextStoreDepth <= storeDepth;
    end if;
end process arrayIndex;

---------------------------------------------------------------------------
--------------------------- OUTPUT CALCULATION ----------------------------
---------------------------------------------------------------------------

outCount:process(i_valid, compCounter)
begin
    if i_valid = '1' then
        next_compCounter <= compCounter + 1;
    elsif compCounter > -1 then
        next_compCounter <= compCounter + 1;
    else
        next_compCounter <= compCounter;
    end if;
end process outCount;

oValid:process(compCounter)
begin
    if compCounter > 10 then
        next_ovalid <= '1';
    else
        next_ovalid <= '0';
    end if;
end process oValid;

scaleOuts:process(mOutArray)
variable temp : sfixed(littleM - 1 downto littleN);
begin
    for x in mOutArray'range loop
        for m in mQArray'range loop
            temp := resize(mOutArray(x)(m), temp);
            if temp > to_sfixed(0, temp) then
                yhat <= (others => '0');
            else
                yhat <= (others => '1');
            end if;
        end loop;
    end loop;
end process scaleOuts;

end mixed;
