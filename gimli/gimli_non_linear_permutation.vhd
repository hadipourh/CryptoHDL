----------------------------------------------------------------------------------
-- 
-- Create Date:    28/11/2016
-- Design Name:    Gimli_non_linear_permutation
-- Module Name:    Gimli_non_linear_permutation
-- Project Name:   Gimli
-- Target Devices: Any
--
-- Description: 
--
-- Performs the non linear operation of Gimli in only just one column.
--
-- a, b, c, d, e, f :
--
-- Gimli rotations variables.
--
-- Dependencies:
-- VHDL-93
--
-- gimli_non_linear_permutation Rev 1.0
--
-- Revision: 
-- Revision 1.0
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity gimli_non_linear_permutation is
    Generic(
        a : integer := 2;
        b : integer := 1;
        c : integer := 3;
        d : integer := 24;
        e : integer := 9;
        f : integer := 0
    );
    Port(
        x : in STD_LOGIC_VECTOR(31 downto 0);
        y : in STD_LOGIC_VECTOR(31 downto 0);
        z : in STD_LOGIC_VECTOR(31 downto 0);
        new_x : out STD_LOGIC_VECTOR(31 downto 0);
        new_y : out STD_LOGIC_VECTOR(31 downto 0);
        new_z : out STD_LOGIC_VECTOR(31 downto 0)
    );
end gimli_non_linear_permutation;

architecture RTL of gimli_non_linear_permutation is

signal temp_x1 : STD_LOGIC_VECTOR(31 downto 0);
signal temp_x2 : STD_LOGIC_VECTOR(31 downto 0);

signal temp_y1 : STD_LOGIC_VECTOR(31 downto 0);
signal temp_y2 : STD_LOGIC_VECTOR(31 downto 0);

signal temp_z1 : STD_LOGIC_VECTOR(31 downto 0);
signal temp_z2 : STD_LOGIC_VECTOR(31 downto 0);

begin

temp_x1(31 downto d) <= x((31 - d) downto 0);
CASE_D_ZERO : if d /= 0 generate
temp_x1((d - 1) downto 0) <= x(31 downto (32 - d));
end generate;

temp_y1(31 downto e) <= y((31 - e) downto 0);
CASE_E_ZERO : if e /= 0 generate
temp_y1((e - 1) downto 0) <= y(31 downto (32 - e));
end generate;

temp_z1(31 downto f) <= z((31 - f) downto 0);
CASE_F_ZERO : if f /= 0 generate
temp_z1((f - 1) downto 0) <= z(31 downto (32 - f));
end generate;

temp_x2(31 downto a) <= temp_y1((31 - a) downto 0) and temp_z1((31 - a) downto 0);
CASE_A_ZERO : if a /= 0 generate
temp_x2((a - 1) downto 0) <= (others => '0');
end generate;

new_z <= temp_x1 xor (temp_z1(30 downto 0) & "0") xor temp_x2;

temp_y2(31 downto b) <= temp_x1((31 - b) downto 0) or temp_z1((31 - b) downto 0);
CASE_B_ZERO : if b /= 0 generate
temp_y2((b - 1) downto 0) <= (others => '0');
end generate;

new_y <= temp_y1 xor temp_x1 xor temp_y2;

temp_z2(31 downto c) <= temp_x1((31 - c) downto 0) and temp_y1((31 - c) downto 0);
CASE_C_ZERO : if c /= 0 generate
temp_z2((c - 1) downto 0) <= (others => '0');
end generate;

new_x <= temp_z1 xor temp_y1 xor temp_z2;

end RTL;