----------------------------------------------
-- Class: Digital IC Design
-- School: Rochester Institute of Technology
-- Engineers: Alden Davidson, John Judge
-- 
-- Final Project, Fall 2018
-- Artificial Neural Network
-- Module Name: tb_mlp - behavioral
----------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;
--use ieee.math_real.all;
library ieee_proposed;
use ieee_proposed.fixed_pkg.all;
use work.annGenericArrays_pkg.all;

library std;
use std.textio.all;


entity tb_mlp is
end tb_mlp;

architecture behavioral of tb_mlp is

component mlp
port (
    SI      : in std_logic;
    SE      : in std_logic;
    clk     : in std_logic;
    u       : in std_logic_vector(N * 8 - 1 downto 0);
    yhat    : out std_logic_vector(M * 8 - 1 downto 0)
);
end component;

constant clk_period : time := 10 ns;

signal SI, SE, clk : std_logic;
signal u : std_logic_vector(N * 8 - 1 downto 0);
signal yhat : std_logic_vector(M * 8 - 1 downto 0);

begin

mlp0 : mlp port map (
    SI => SI,
    SE => SE,
    clk => clk,
    u => u,
    yhat => yhat
);

-- Clock process definitions
clock:process
begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
end process clock;

-- Stimulus process
main:process

-- file definitions
constant imgSize : integer := 256;
constant wDatSize : integer := N + H + M + 1;
constant filename1_in : string(1 to 9) := "test1.txt";
constant filename2_in : string(1 to 9) := "test2.txt";
constant filename3_in : string(1 to 9) := "test3.txt";
constant filename4_in : string(1 to 9) := "test4.txt";
constant filename_wdat : string(1 to 5) := "W.dat";

-- file data
type twDat is array(0 to wDatSize - 1, 0 to wDatSize - 1) of sfixed(littleM downto littleN); 
type timgData is array(1 to ImgSize, 1 to imgSize) of integer range 0 to 255;
variable imgData_in : timgData;
variable wDat : twDat;
variable pixel : integer;

-- file I/O
constant space : string(1 to 1) := " ";
variable status : boolean := false;
file img_in : text;
file img_out : text;
variable line_in : line;
variable row, col : integer := 1;

procedure read_img (
    filename_in : in string(1 to 9)
) is begin
    row := 1;
    col := 1;
    file_open(img_in, filename_in, read_mode);
    -- read rest of file, i.e. image data
    while not endfile(img_in) loop
        readline(img_in, line_in);
        status := true;
        -- loop until end of line
        while status = true loop
            -- read pixels from line
            read(line_in, pixel, status);
            if status = true then
                imgData_in(row, col) := pixel;
                if (col = imgSize) then
                    col := 1;
                    row := row + 1;
                else
                    col := col + 1;
                end if;
            end if;
        end loop;
    end loop;
    file_close(img_in);
end read_img;

procedure read_wdat is
begin
    row := 0;
    col := 0;
    file_open(img_in, filename_wdat, read_mode);
    -- read rest of file, i.e. image data
    while not endfile(img_in) loop
        readline(img_in, line_in);
        status := true;
        -- loop until end of line
        while status = true loop
            -- read pixels from line
            read(line_in, pixel, status);
            if status = true then
                wDat(row, col) := to_sfixed(pixel, littleM, littleN);
                if (col = imgSize) then
                    col := 1;
                    row := row + 1;
                else
                    col := col + 1;
                end if;
            end if;
        end loop;
    end loop;
    file_close(img_in);
end read_wdat;

procedure is
begin
end procedure;

procedure send_sfixed (
    val : in sfixed(littleM downto littleN)
) is
begin
    for i in 0 to val'high loop
        SI <= val(i);
        wait for clk_period;
    end loop;
end procedure;

procedure send_serial_wdat is
begin
    for r in 1 to wDatSize loop
        for c in 1 to wDatSize loop
            send_sfixed(wDat(r, c));
        end loop;
    end loop;
end procedure;

begin

wait for 200 ns;

read_wdat;

SE <= '1';
wait for clk_period;
send_serial_wdat;

SE <= '0';
wait for clk_period;

read_img(filename1_in);



wait for clk_period * 10;
assert false report "End of Simulation" severity failure;

end process main;

end behavioral;
