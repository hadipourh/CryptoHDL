----------------------------------------------------------------------------------
-- 
-- Create Date:    28/11/2016
-- Design Name:    Gimli_all_columns_non_linear_permutation
-- Module Name:    Gimli_all_columns_non_linear_permutation
-- Project Name:   Gimli
-- Target Devices: Any
--
-- Description: 
--
-- Performs the non linear operation of Gimli in all columns of the state.
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

entity gimli_all_columns_non_linear_permutation is
    Generic(
        a : integer := 2;
        b : integer := 1;
        c : integer := 3;
        d : integer := 24;
        e : integer := 9;
        f : integer := 0
    );
    Port(
        state : in STD_LOGIC_VECTOR((12*32 - 1) downto 0);
        new_state : out STD_LOGIC_VECTOR((12*32 - 1) downto 0)
    );
end gimli_all_columns_non_linear_permutation;

architecture RTL of gimli_all_columns_non_linear_permutation is

component gimli_non_linear_permutation
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
end component;

begin

ALL_GIMLIs : for I in 0 to 3 generate

gimli_X : gimli_non_linear_permutation
    Generic Map(
        a => a,
        b => b,
        c => c,
        d => d,
        e => e,
        f => f
    )
    Port Map(
        x => state((((I + 1)*32) - 1) downto ((I + 0)*32)),
        y => state((((I + 5)*32) - 1) downto ((I + 4)*32)),
        z => state((((I + 9)*32) - 1) downto ((I + 8)*32)),
        new_x => new_state((((I + 1)*32) - 1) downto ((I + 0)*32)),
        new_y => new_state((((I + 5)*32) - 1) downto ((I + 4)*32)),
        new_z => new_state((((I + 9)*32) - 1) downto ((I + 8)*32))
    );

end generate;

end RTL;