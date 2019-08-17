----------------------------------------------------------------------------------
-- 
-- Create Date:    28/11/2016
-- Design Name:    Gimli_all_combinational
-- Module Name:    Gimli_all_combinational
-- Project Name:   Gimli
-- Target Devices: Any
--
-- Description: 
--
-- Performs the Gimli permutation purely combinational.
--
-- a, b, c, d, e, f :
--
-- Gimli rotations variables.
--
-- Dependencies:
-- VHDL-93
-- IEEE.NUMERIC_STD.ALL;
--
-- gimli_all_columns_non_linear_permutation Rev 1.0
--
-- Revision: 
-- Revision 1.0
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity gimli_all_combinational is
    Generic(
        number_of_rounds : integer := 24;
        a : integer := 2;
        b : integer := 1;
        c : integer := 3;
        d : integer := 24;
        e : integer := 9;
        f : integer := 0;
        round_base_constant : STD_LOGIC_VECTOR(31 downto 0) := X"9E377900"
    );
    Port(
        state : in STD_LOGIC_VECTOR((12*32 - 1) downto 0);
        new_state : out STD_LOGIC_VECTOR((12*32 - 1) downto 0)
    );
end gimli_all_combinational;

architecture RTL of gimli_all_combinational is

component gimli_all_columns_non_linear_permutation
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
end component;

type state_rounds is array(integer range 0 to (number_of_rounds - 1)) of std_logic_vector((12*32-1) downto 0);

signal temp_state : state_rounds;
signal temp_new_state : state_rounds;
signal temp_state_after_non_linear : state_rounds;

begin

temp_state(0) <= state;

ALL_ROUNDS : for I in 0 to (number_of_rounds - 1) generate

INPUT_STATE_FROM_PREVIOUS : if I > 0 generate

temp_state(I) <= temp_new_state(I - 1);

end generate;

gimli_round_I : gimli_all_columns_non_linear_permutation
    Generic Map(
        a => a,
        b => b,
        c => c,
        d => d,
        e => e,
        f => f
    )
    Port Map(
        state => temp_state(I),
        new_state => temp_state_after_non_linear(I)
    );

APPLY_SMALL_SWAP : if (I mod 4 = 0) generate

temp_new_state(I)((((1)*32) - 1) downto ((0)*32)) <= temp_state_after_non_linear(I)((((2)*32) - 1) downto ((1)*32)) xor (round_base_constant(31 downto 8) & std_logic_vector(to_unsigned(number_of_rounds-I, 8)));
temp_new_state(I)((((2)*32) - 1) downto ((1)*32)) <= temp_state_after_non_linear(I)((((1)*32) - 1) downto ((0)*32));
temp_new_state(I)((((3)*32) - 1) downto ((2)*32)) <= temp_state_after_non_linear(I)((((4)*32) - 1) downto ((3)*32));
temp_new_state(I)((((4)*32) - 1) downto ((3)*32)) <= temp_state_after_non_linear(I)((((3)*32) - 1) downto ((2)*32));
temp_new_state(I)((((12)*32) - 1) downto ((4)*32)) <= temp_state_after_non_linear(I)((((12)*32) - 1) downto ((4)*32));

end generate;

APPLY_BIG_SWAP : if (I mod 4 = 2) generate

temp_new_state(I)((((1)*32) - 1) downto ((0)*32)) <= temp_state_after_non_linear(I)((((3)*32) - 1) downto ((2)*32));
temp_new_state(I)((((2)*32) - 1) downto ((1)*32)) <= temp_state_after_non_linear(I)((((4)*32) - 1) downto ((3)*32));
temp_new_state(I)((((3)*32) - 1) downto ((2)*32)) <= temp_state_after_non_linear(I)((((1)*32) - 1) downto ((0)*32));
temp_new_state(I)((((4)*32) - 1) downto ((3)*32)) <= temp_state_after_non_linear(I)((((2)*32) - 1) downto ((1)*32));
temp_new_state(I)((((12)*32) - 1) downto ((4)*32)) <= temp_state_after_non_linear(I)((((12)*32) - 1) downto ((4)*32));

end generate;


APPLY_NO_SWAP : if ((I mod 4 = 1) or (I mod 4 = 3)) generate

temp_new_state(I) <= temp_state_after_non_linear(I);

end generate;


end generate;

new_state <= temp_new_state(number_of_rounds - 1);

end RTL;