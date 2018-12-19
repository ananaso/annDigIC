----------------------------------------------
-- Class: Digital IC Design
-- School: Rochester Institute of Technology
-- Engineers: Alden Davidson, John Judge
-- 
-- Final Project, Fall 2018
-- Artificial Neural Network
-- Module Name: tb_mlp - behavioral
-- Base edge cases
----------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
--use ieee.math_real.all;
library ieee_proposed;
use ieee_proposed.fixed_pkg.all;
use work.annGenericArrays_pkg.all;

library std;
use std.textio.all;


entity tb_mlpBaseCases is
end tb_mlpBaseCases;

architecture behavioral of tb_mlpBaseCases is

component mlp
port (
    SI      : in std_logic;
    SE      : in std_logic;
    clk     : in std_logic;
    i_valid : in std_logic;
    u       : in pixelArray;
    o_valid : out std_logic;
    yhat    : out std_logic_vector(M * 8 - 1 downto 0)
);
end component;

constant clk_period : time := 10 ns;

signal SI, SE, clk, i_valid, o_valid : std_logic := '0';
signal u : pixelArray;
signal yhat : std_logic_vector(M * 8 - 1 downto 0);
signal writeDone : std_logic := '0';

constant imgSize : integer := 3;
constant wDatSize : integer := N + H + M + 1;

begin

mlp0 : mlp port map (
    SI => SI,
    SE => SE,
    clk => clk,
    i_valid => i_valid,
    u => u,
    o_valid => o_valid,
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
constant filenameE0_in  : string(1 to 6) := "e0.txt";
constant filenameE1_in  : string(1 to 6) := "e1.txt";
constant filenameE2_in  : string(1 to 6) := "e2.txt";
constant filenameE3_in  : string(1 to 6) := "e3.txt";
constant filenameE4_in  : string(1 to 6) := "e4.txt";
constant filenameE5_in  : string(1 to 6) := "e5.txt";
constant filenameE6_in  : string(1 to 6) := "e6.txt";
constant filenameE7_in  : string(1 to 6) := "e7.txt";
constant filenameNE0_in : string(1 to 7) := "ne0.txt";
constant filenameNE1_in : string(1 to 7) := "ne1.txt";
constant filenameNE2_in : string(1 to 7) := "ne2.txt";
constant filenameNE3_in : string(1 to 7) := "ne3.txt";
constant filenameNE4_in : string(1 to 7) := "ne4.txt";
constant filenameNE5_in : string(1 to 7) := "ne5.txt";
constant filenameNE6_in : string(1 to 7) := "ne6.txt";
constant filenameNE7_in : string(1 to 7) := "ne7.txt";
constant filenameNE8_in : string(1 to 7) := "ne8.txt";
constant filename_wdat  : string(1 to 5) := "w.txt";

-- file data
type timgDataIn is array(1 to imgSize, 1 to imgSize) of sfixed(littleM downto littleN);
type twDat is array(0 to wDatSize - 1, 0 to wDatSize - 1) of sfixed(littleM downto littleN);
variable imgData_in : timgDataIn;
variable wDat : twDat;
variable pixel : real;
variable weight : real;

-- file I/O
constant space : string(1 to 1) := " ";
variable status : boolean := false;
file img_in : text;
file img_out : text;
variable line_in : line;
variable row, col : integer := 1;

procedure read_img (
    filename_in : in string(1 to 6)
) is
variable divide : real;
begin
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
                divide := real(pixel) / real(255);
                imgData_in(row, col) := to_sfixed(divide, littleM, littleN);
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
            read(line_in, weight, status);
            if status = true then
                wDat(row, col) := to_sfixed(weight, littleM, littleN);
                if (col = wDatSize - 1) then
                    col := 0;
                    row := row + 1;
                else
                    col := col + 1;
                end if;
            end if;
        end loop;
    end loop;
    file_close(img_in);
end read_wdat;

procedure send_sfixed (
    val : in sfixed(littleM downto littleN)
) is
begin
    for i in littleM downto littleN loop
        SI <= val(i);
        wait for clk_period;
    end loop;
end send_sfixed;

procedure send_serial_wdat is
begin
    SE <= '1';
    for r in 0 to wDatSize - 1 loop
        for c in 0 to wDatSize - 1 loop
            send_sfixed(wDat(r, c));
        end loop;
    end loop;
    SE <= '0';
    wait for clk_period;
end send_serial_wdat;
    
procedure send_img is
variable pixelGrid : pixelArray;
begin
    i_valid <= '1';
    for r in 2 to imgSize - 1 loop
        for c in 2 to imgSize - 1 loop
            pixelGrid(0) := imgData_in(r - 1, c - 1);
            pixelGrid(1) := imgData_in(r - 1, c);
            pixelGrid(2) := imgData_in(r - 1, c + 1);
            pixelGrid(3) := imgData_in(r, c - 1);
            pixelGrid(4) := imgData_in(r, c);
            pixelGrid(5) := imgData_in(r, c + 1);
            pixelGrid(6) := imgData_in(r + 1, c - 1);
            pixelGrid(7) := imgData_in(r + 1, c);
            pixelGrid(8) := imgData_in(r + 1, c + 1); 
            u <= pixelGrid;
            wait for clk_period;
        end loop;
    end loop;
    i_valid <= '0';
    wait for clk_period;
end send_img;

begin

read_wdat;

send_serial_wdat;

read_img(filenameE1_in);

send_img;

wait until writeDone = '1';
assert false report "End of Simulation" severity failure;

end process main;

get_img:process

file pgm_out : text;
constant filenameE0_out     : string(1 to 9)    := "e0Out.pgm";
constant filenameE1_out     : string(1 to 9)    := "e1Out.pgm";
constant filenameE2_out     : string(1 to 9)    := "e2Out.pgm";
constant filenameE3_out     : string(1 to 9)    := "e3Out.pgm";
constant filenameE4_out     : string(1 to 9)    := "e4Out.pgm";
constant filenameE5_out     : string(1 to 9)    := "e5Out.pgm";
constant filenameE6_out     : string(1 to 9)    := "e6Out.pgm";
constant filenameE7_out     : string(1 to 9)    := "e7Out.pgm";
constant filenameNE0_out    : string(1 to 10)   := "ne0Out.pgm";
constant filenameNE1_out    : string(1 to 10)   := "ne1Out.pgm";
constant filenameNE2_out    : string(1 to 10)   := "ne2Out.pgm";
constant filenameNE3_out    : string(1 to 10)   := "ne3Out.pgm";
constant filenameNE4_out    : string(1 to 10)   := "ne4Out.pgm";
constant filenameNE5_out    : string(1 to 10)   := "ne5Out.pgm";
constant filenameNE6_out    : string(1 to 10)   := "ne6Out.pgm";
constant filenameNE7_out    : string(1 to 10)   := "ne7Out.pgm";
constant filenameNE8_out    : string(1 to 10)   := "ne8Out.pgm";
constant imgType            : string(1 to 2)    := "P2";
constant space              : string(1 to 1)    := " ";
constant maxPVal            : string(1 to 3)    := "255";
variable line_out : line;

type timgDataOut is array(0 to imgSize - 3, 0 to imgSize - 3) of integer;
variable imgData_out : timgDataOut;

procedure save_pgm (
    target_filename : in string
) is
begin
    file_open(pgm_out, target_filename, write_mode);
    -- write file type at top of header
    write(line_out, imgType);
    writeline(pgm_out, line_out);
    -- write columns and rows as second line in header
    write(line_out, imgSize);
    write(line_out, space);
    write(line_out, imgSize);
    writeline(pgm_out, line_out);
    -- write maximum pixel value as third line in header
    write(line_out, maxPVal);
    writeline(pgm_out, line_out);
    -- write data into file
    for row in 0 to imgSize - 3 loop
        for col in 0 to imgSize - 3 loop
            write(line_out, imgData_out(row, col));
            write(line_out, space);
        end loop;
        writeline(pgm_out, line_out);
    end loop;
    file_close(pgm_out);
end save_pgm;

begin
    writeDone <= '0';
    wait until o_valid = '1';
    for r in 0 to imgSize - 3 loop
        for c in 0 to imgSize - 3 loop
            imgData_out(r,c) := to_integer(unsigned(yhat));
            wait for clk_period;
        end loop;
    end loop;
    
    save_pgm(filenameE1_out);
    writeDone <= '1';
    wait for clk_period;
end process get_img;

end behavioral;
