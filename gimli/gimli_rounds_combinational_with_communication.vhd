----------------------------------------------------------------------------------
-- 
-- Create Date:    29/11/2016
-- Design Name:    Gimli_rounds_combinational_with_communication
-- Module Name:    Gimli_rounds_combinational_with_communication
-- Project Name:   Gimli
-- Target Devices: Any
--
-- Description: 
--
-- Performs the Gimli permutation in a round based manner.
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
-- number_of_combinational_rounds :
-- 
-- Number of rounds done as combinational circuit.
-- Can only be the factors of the "number_of_total_rounds"
--
-- a, b, c, d, e, f :
--
-- Gimli rotations variables.
--
-- Dependencies:
-- VHDL-93
-- IEEE.NUMERIC_STD.ALL;
--
-- gimli_rounds_combinatorial Rev 1.0
--
-- Revision: 
-- Revision 1.0
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity gimli_rounds_combinational_with_communication is
    Generic(
        bus_size : integer := 8;
        number_of_total_rounds : integer := 24;
        number_of_combinational_rounds : integer := 8;
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
end gimli_rounds_combinational_with_communication;

architecture Behavioral of gimli_rounds_combinational_with_communication is

component gimli_rounds_combinational
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
end component;

signal permutation_state : STD_LOGIC_VECTOR((12*32 - 1) downto 0);
signal permutation_new_state : STD_LOGIC_VECTOR((12*32 - 1) downto 0);
signal permutation_round : STD_LOGIC_VECTOR(4 downto 0);
signal permutation_new_round : STD_LOGIC_VECTOR(4 downto 0);

signal internal_start : STD_LOGIC;
signal internal_data_in_ready : STD_LOGIC;
signal internal_data_out_valid : STD_LOGIC;
signal internal_core_free : STD_LOGIC;
signal internal_finish : STD_LOGIC;

signal input_output_buffer : STD_LOGIC_VECTOR((12*32 - 1) downto 0);

begin

permutation : gimli_rounds_combinational
    Generic Map (
        number_of_combinational_rounds => number_of_combinational_rounds,
        a => a,
        b => b, 
        c => c,
        d => d, 
        e => e,
        f => f,
        round_base_constant => round_base_constant
    )
    Port Map(
        state => permutation_state,
        round => permutation_round,
        new_state => permutation_new_state,
        new_round => permutation_new_round
    );

reg_control : process(clk, arstn)   
begin
    if(arstn = '0') then
        internal_start <= '0';
        internal_core_free <= '1';
        internal_finish <= '0';
        permutation_round <= "11000";
    elsif(rising_edge(clk)) then
        internal_start <= start;
        if(internal_core_free = '1') then
            internal_core_free <= not start;
            internal_finish <= '0';
            permutation_round <= "11000";
        elsif(permutation_new_round = "00000") then
            internal_core_free <= '1';
            internal_finish <= '1';
            permutation_round <= "11000";
        else
            permutation_round <= permutation_new_round;
        end if;
    end if;
end process;
    
reg_input_output_buffer : process(clk)
begin
    if(rising_edge(clk)) then
        if(internal_core_free = '0') then
            input_output_buffer <= permutation_new_state;
        elsif(data_in_valid = '1') then
            input_output_buffer <= data_in & input_output_buffer((12*32 - 1) downto bus_size);
        elsif(data_out_ready = '1' and internal_data_out_valid = '1') then
            input_output_buffer((12*32 - bus_size - 1) downto 0) <= input_output_buffer((12*32 - 1) downto bus_size);
            input_output_buffer((12*32 - 1) downto (12*32 - bus_size)) <= input_output_buffer((bus_size - 1) downto 0);
        end if;
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

permutation_state <= input_output_buffer;

data_in_ready <= internal_data_in_ready;
data_out <= input_output_buffer((bus_size - 1) downto 0);
data_out_valid <= internal_data_out_valid;
finish <= internal_finish;
core_free <= internal_core_free;

end Behavioral;