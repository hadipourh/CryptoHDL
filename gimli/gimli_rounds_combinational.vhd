----------------------------------------------------------------------------------
-- 
-- Create Date:    28/11/2016
-- Design Name:    Gimli_rounds_combinational
-- Module Name:    Gimli_rounds_combinational
-- Project Name:   Gimli
-- Target Devices: Any
--
-- Description: 
--
-- Performs the Gimli permutation purely combinational in a specified
-- number of rounds.
--
-- number_of_combinational_rounds :
-- 
-- Number of rounds done as combinational circuit.
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

entity gimli_rounds_combinational is
    Generic(
        number_of_combinational_rounds : integer := 1;
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
        round : in STD_LOGIC_VECTOR(4 downto 0);
        new_state : out STD_LOGIC_VECTOR((12*32 - 1) downto 0);
        new_round : out STD_LOGIC_VECTOR(4 downto 0)
    );
end gimli_rounds_combinational;

architecture RTL of gimli_rounds_combinational is

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

type state_rounds is array(integer range 0 to (number_of_combinational_rounds - 1)) of std_logic_vector((12*32-1) downto 0);
type count_rounds is array(integer range 0 to (number_of_combinational_rounds - 1)) of std_logic_vector(4 downto 0);

signal temp_state : state_rounds;
signal temp_round : count_rounds;
signal temp_state_after_non_linear : state_rounds;
signal temp_new_state : state_rounds;
signal temp_new_round : count_rounds;

begin

temp_state(0) <= state;

OPTIMIZE_FOR_MULTIPLES_4 : if (number_of_combinational_rounds mod 4 = 0) generate

temp_round(0) <= round(4 downto 2) & "00";

end generate;

OPTIMIZE_FOR_MULTIPLES_2 : if (number_of_combinational_rounds mod 4 = 2) generate

temp_round(0) <= round(4 downto 1) & "0";

end generate;

NON_MULTIPLES_4_OR_2 : if (number_of_combinational_rounds mod 4 /= 0 and number_of_combinational_rounds mod 4 /= 2) generate

temp_round(0) <= round;

end generate;

ALL_ROUNDS : for I in 0 to (number_of_combinational_rounds - 1) generate

INPUT_STATE_FROM_PREVIOUS : if I > 0 generate

temp_state(I) <= temp_new_state(I - 1);
temp_round(I) <= temp_new_round(I - 1);

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

conditional_swap_I : process(temp_state_after_non_linear(I), temp_round(I))
begin
    if(temp_round(I)(1 downto 0) = "00") then
    -- Apply small swap
        temp_new_state(I)((((1)*32) - 1) downto ((0)*32)) <= temp_state_after_non_linear(I)((((2)*32) - 1) downto ((1)*32)) xor (round_base_constant(31 downto 8)& "000" & temp_round(I));
        temp_new_state(I)((((2)*32) - 1) downto ((1)*32)) <= temp_state_after_non_linear(I)((((1)*32) - 1) downto ((0)*32));
        temp_new_state(I)((((3)*32) - 1) downto ((2)*32)) <= temp_state_after_non_linear(I)((((4)*32) - 1) downto ((3)*32));
        temp_new_state(I)((((4)*32) - 1) downto ((3)*32)) <= temp_state_after_non_linear(I)((((3)*32) - 1) downto ((2)*32));
        temp_new_state(I)((((12)*32) - 1) downto ((4)*32)) <= temp_state_after_non_linear(I)((((12)*32) - 1) downto ((4)*32));
    -- Apply big swap
    elsif(temp_round(I)(1 downto 0) = "10") then
        temp_new_state(I)((((1)*32) - 1) downto ((0)*32)) <= temp_state_after_non_linear(I)((((3)*32) - 1) downto ((2)*32));
        temp_new_state(I)((((2)*32) - 1) downto ((1)*32)) <= temp_state_after_non_linear(I)((((4)*32) - 1) downto ((3)*32));
        temp_new_state(I)((((3)*32) - 1) downto ((2)*32)) <= temp_state_after_non_linear(I)((((1)*32) - 1) downto ((0)*32));
        temp_new_state(I)((((4)*32) - 1) downto ((3)*32)) <= temp_state_after_non_linear(I)((((2)*32) - 1) downto ((1)*32));
        temp_new_state(I)((((12)*32) - 1) downto ((4)*32)) <= temp_state_after_non_linear(I)((((12)*32) - 1) downto ((4)*32));
    -- Apply no swap
    else
        temp_new_state(I) <= temp_state_after_non_linear(I);
    end if;
end process;

temp_new_round(I) <= std_logic_vector(unsigned(temp_round(I))-to_unsigned(1, 5));

end generate;

new_state <= temp_new_state(number_of_combinational_rounds - 1);
new_round <= temp_new_round(number_of_combinational_rounds - 1);

end RTL;