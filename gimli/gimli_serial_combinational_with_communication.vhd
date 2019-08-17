----------------------------------------------------------------------------------
-- 
-- Create Date:    29/11/2016
-- Design Name:    Gimli_serial_combinational_with_communication
-- Module Name:    Gimli_serial_combinational_with_communication
-- Project Name:   Gimli
-- Target Devices: Any
--
-- Description: 
--
-- Performs the Gimli permutation in a serial based manner.
-- Therefore it only uses only one non linear permutation.
-- It is loaded with buffer shift registers.
--
-- bus_size :
--
-- The size of the input and output of the shift registers.
-- 
-- number_of_total_rounds :
-- 
-- Gimli number of total rounds.
--
--
-- a, b, c, d, e, f :
--
-- Gimli rotations variables.
--
-- Dependencies:
-- VHDL-93
-- IEEE.NUMERIC_STD.ALL;
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
use IEEE.NUMERIC_STD.ALL;

entity gimli_serial_combinational_with_communication is
    Generic(
        bus_size : integer := 8;
        number_of_total_rounds : integer := 24;
        a : integer := 2;
        b : integer := 1;
        c : integer := 3;
        d : integer := 24;
        e : integer := 9;
        f : integer := 0;
        round_base_constant : STD_LOGIC_VECTOR(31 downto 0) := X"9E377900"
    );
    Port(
        clk : in STD_LOGIC;
        arstn : in STD_LOGIC;
        start : in STD_LOGIC;
        data_in_valid : in STD_LOGIC;
        data_out_ready : in STD_LOGIC;
        data_in : in STD_LOGIC_VECTOR((bus_size - 1) downto 0);
        data_out : out STD_LOGIC_VECTOR((bus_size - 1) downto 0);
        data_out_valid : out STD_LOGIC;
        data_in_ready : out STD_LOGIC;
        finish : out STD_LOGIC;
        core_free : out STD_LOGIC
    );
end gimli_serial_combinational_with_communication;

architecture Behavioral of gimli_serial_combinational_with_communication is

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

signal permutation_state : STD_LOGIC_VECTOR((12*32 - 1) downto 0);
signal permutation_state_after_swap : STD_LOGIC_VECTOR((12*32 - 1) downto 0);
signal permutation_round : STD_LOGIC_VECTOR(4 downto 0);
signal permutation_shift : STD_LOGIC_VECTOR(2 downto 0);

signal column_before_non_linear : STD_LOGIC_VECTOR(95 downto 0);
signal column_after_non_linear : STD_LOGIC_VECTOR(95 downto 0);

signal internal_start : STD_LOGIC;
signal internal_data_in_ready : STD_LOGIC;
signal internal_data_out_valid : STD_LOGIC;
signal internal_core_free : STD_LOGIC;
signal internal_finish : STD_LOGIC;

signal start_next_round : STD_LOGIC;

begin

non_linear_transform : gimli_non_linear_permutation
    Generic Map (
        a => a,
        b => b, 
        c => c,
        d => d, 
        e => e,
        f => f
    )
    Port Map(
        x => column_before_non_linear(31 downto 0),
        y => column_before_non_linear(63 downto 32), 
        z => column_before_non_linear(95 downto 64),
        new_x => column_after_non_linear(31 downto 0),
        new_y => column_after_non_linear(63 downto 32),
        new_z => column_after_non_linear(95 downto 64)
    );

reg_control : process(clk, arstn)   
begin
    if(arstn = '0') then
        internal_start <= '0';
        internal_core_free <= '1';
        internal_finish <= '0';
    elsif(rising_edge(clk)) then
        internal_start <= start;
        if(internal_core_free = '1') then
            internal_core_free <= not start;
            internal_finish <= '0';
        elsif(permutation_round = "00001" and permutation_shift = "011") then
            internal_core_free <= '1';
            internal_finish <= '1';
        end if;
    end if;
end process;

ctr_permutation_round : process(clk, arstn)
begin
    if(arstn = '0') then
        permutation_round <= "11000";
    elsif(rising_edge(clk)) then
        if(internal_core_free = '0') then
            if(permutation_round = "00000") then
                permutation_round <= "11000";
            elsif(start_next_round = '1') then
                permutation_round <= std_logic_vector(unsigned(permutation_round) - to_unsigned(1, 5));
            end if;
        end if;
    end if;
end process;

ctr_permutation_shift : process(clk, arstn)
begin
    if(arstn = '0') then
        permutation_shift <= "000";
    elsif(rising_edge(clk)) then
        if(internal_core_free = '0') then
            if(start_next_round = '1') then
                permutation_shift <= "000";
            else
                permutation_shift <= std_logic_vector(unsigned(permutation_shift) + to_unsigned(1, 3));
            end if;
        end if;
    end if;
end process;

reg_permutation_state : process(clk)
begin
    if(rising_edge(clk)) then
        if(internal_core_free = '0') then
            if(permutation_shift = "100") then
                permutation_state <= permutation_state_after_swap;
            else
                permutation_state(((4*32) - 1) downto (0*32)) <= column_after_non_linear(31 downto 0)  & permutation_state(((4*32) - 1) downto (1*32));
                permutation_state(((8*32) - 1) downto (4*32)) <= column_after_non_linear(63 downto 32) & permutation_state(((8*32) - 1) downto (5*32));
                permutation_state(((12*32) - 1) downto (8*32)) <= column_after_non_linear(95 downto 64) & permutation_state(((12*32) - 1) downto (9*32));
            end if;
        elsif(data_in_valid = '1') then
            permutation_state <= data_in & permutation_state((12*32 - 1) downto bus_size);
        elsif(data_out_ready = '1' and internal_data_out_valid = '1') then
            permutation_state((12*32 - bus_size - 1) downto 0) <= permutation_state((12*32 - 1) downto bus_size);
            permutation_state((12*32 - 1) downto (12*32 - bus_size)) <= permutation_state((bus_size - 1) downto 0);
        end if;
    end if;
end process;

conditional_swap : process(permutation_state, permutation_round)
begin
    if(permutation_round(1) =  '0') then
    -- Apply small swap
        permutation_state_after_swap((((1)*32) - 1) downto ((0)*32)) <= permutation_state((((2)*32) - 1) downto ((1)*32)) xor (round_base_constant(31 downto 8) & "000" & permutation_round);
        permutation_state_after_swap((((2)*32) - 1) downto ((1)*32)) <= permutation_state((((1)*32) - 1) downto ((0)*32));
        permutation_state_after_swap((((3)*32) - 1) downto ((2)*32)) <= permutation_state((((4)*32) - 1) downto ((3)*32));
        permutation_state_after_swap((((4)*32) - 1) downto ((3)*32)) <= permutation_state((((3)*32) - 1) downto ((2)*32));
        permutation_state_after_swap((((12)*32) - 1) downto ((4)*32)) <= permutation_state((((12)*32) - 1) downto ((4)*32));
    -- Apply big swap
    else
        permutation_state_after_swap((((1)*32) - 1) downto ((0)*32)) <= permutation_state((((3)*32) - 1) downto ((2)*32));
        permutation_state_after_swap((((2)*32) - 1) downto ((1)*32)) <= permutation_state((((4)*32) - 1) downto ((3)*32));
        permutation_state_after_swap((((3)*32) - 1) downto ((2)*32)) <= permutation_state((((1)*32) - 1) downto ((0)*32));
        permutation_state_after_swap((((4)*32) - 1) downto ((3)*32)) <= permutation_state((((2)*32) - 1) downto ((1)*32));
        permutation_state_after_swap((((12)*32) - 1) downto ((4)*32)) <= permutation_state((((12)*32) - 1) downto ((4)*32));
    end if;
end process;

reg_data_out_valid : process(clk, arstn)
begin
    if(arstn = '0') then
        internal_data_out_valid <= '0';
    elsif(rising_edge(clk)) then
        if((internal_start = '1')) then
            internal_data_out_valid <= '0';
        else
            if(data_out_ready = '1') then
                internal_data_out_valid <= '1';
            else
                internal_data_out_valid <= '0';
            end if;
        end if;
    end if;
end process;

reg_data_in_ready : process(clk, arstn)
begin
    if(arstn = '0') then
        internal_data_in_ready <= '1';
    elsif(rising_edge(clk)) then
        if(start = '1') then
            internal_data_in_ready <= '0';
        elsif(internal_finish = '1') then
            internal_data_in_ready <= '1';
        end if;
    end if;
end process;

start_next_round <= '1' when (permutation_round(0) = '0' and permutation_shift = "100") or (permutation_round(0) /= '0' and permutation_shift = "011") else '0';

column_before_non_linear(31 downto 0) <=  permutation_state(31 downto 0);
column_before_non_linear(63 downto 32) <= permutation_state(159 downto 128);
column_before_non_linear(95 downto 64) <= permutation_state(287 downto 256);

data_in_ready <= internal_data_in_ready;
data_out <= permutation_state((bus_size - 1) downto 0);
data_out_valid <= internal_data_out_valid;
finish <= internal_finish;
core_free <= internal_core_free;

end Behavioral;