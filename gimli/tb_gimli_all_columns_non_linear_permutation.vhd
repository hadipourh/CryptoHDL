----------------------------------------------------------------------------------
-- 
-- Create Date:    28/11/2016
-- Design Name:    TestBench_Gimli_all_columns_non_linear_permutation
-- Module Name:    TestBench_Gimli_all_columns_non_linear_permutation
-- Project Name:   Gimli
-- Target Devices: Any
--
-- Description: 
--
-- Test bench for the most non linear part of Gimli permutation.
--
-- Parameters:
--
-- PERIOD : 
--
-- Input clock period to be applied on the test. 
--
-- gimli_a, gimli_b, gimli_c, gimli_d, gimli_e, gimli_f :
--
-- Gimli rotations variables.
--
-- maximum_number_of_tests :
--
-- Maximum number of tests to be performed, if this value is 0 then all tests will be performed.
--
-- test_memory_file_gimli_all_columns_non_linear_permutation :
--
-- The name and location of the file with the tests to be performed.
-- The file has the number of tests, then each test followed by the expected response.
--
-- Dependencies:
-- VHDL-93
-- IEEE.NUMERIC_STD.ALL;
-- IEEE.STD_LOGIC_TEXTIO.ALL;
-- STD.TEXTIO.ALL;
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
use IEEE.STD_LOGIC_TEXTIO.ALL;

library STD;
use STD.TEXTIO.ALL;

entity tb_gimli_all_columns_non_linear_permutation is
Generic(
        PERIOD : time := 10 ns;
        
        gimli_a : integer := 2;
        gimli_b : integer := 1;
        gimli_c : integer := 3;
        gimli_d : integer := 24;
        gimli_e : integer := 9;
        gimli_f : integer := 0;
        
        maximum_number_of_tests : integer := 100;
    
        test_memory_file_gimli_all_columns_non_linear_permutation : string := "../data_tests/gimli_all_columns_non_linear_permutation.dat"
);
end tb_gimli_all_columns_non_linear_permutation;

architecture Behavioral of tb_gimli_all_columns_non_linear_permutation is

component gimli_all_columns_non_linear_permutation is
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

signal test_state : STD_LOGIC_VECTOR((12*32 - 1) downto 0);
signal test_new_state : STD_LOGIC_VECTOR((12*32 - 1) downto 0);
signal true_new_state : STD_LOGIC_VECTOR((12*32 - 1) downto 0);

signal test_error : STD_LOGIC := '0';
signal clk : STD_LOGIC := '1';
signal test_bench_finish : BOOLEAN := false;

begin

test : gimli_all_columns_non_linear_permutation
    Generic Map(
        a => gimli_a,
        b => gimli_b,
        c => gimli_c,
        d => gimli_d,
        e => gimli_e,
        f => gimli_f
    )
    Port Map(
        state => test_state,
        new_state  => test_new_state
    );
    
clock : process
begin
while (not test_bench_finish ) loop
    clk <= not clk;
    wait for PERIOD/2;
end loop;
wait;
end process;

                        
process
    FILE ram_file : text;
    variable line_n : line;                                 
    variable number_of_tests : integer;
    variable read_a : STD_LOGIC_VECTOR((12*32 - 1) downto 0);
    variable read_o : STD_LOGIC_VECTOR((12*32 - 1) downto 0);
    begin                
        file_open(ram_file, test_memory_file_gimli_all_columns_non_linear_permutation, READ_MODE);
        readline (ram_file, line_n);                             
        read (line_n, number_of_tests); 
        wait for PERIOD;
        if((number_of_tests > maximum_number_of_tests) and (maximum_number_of_tests /= 0)) then
            number_of_tests := maximum_number_of_tests;
        end if;
        for I in 1 to number_of_tests loop
            test_error <= '0';
            readline (ram_file, line_n);                             
            read (line_n, read_a); 
            readline (ram_file, line_n);                             
            read (line_n, read_o);
            test_state <= read_a;
            true_new_state <= read_o;
            wait for PERIOD;
            if (true_new_state = test_new_state) then
                test_error <= '0';
            else
                test_error <= '1';
                report "Computed values do not match expected ones" severity error;
            end if;
            wait for PERIOD;
            test_error <= '0';
            wait for PERIOD;
        end loop;
        report "End of the test." severity note;
        test_bench_finish <= true;
        wait;
end process;

end Behavioral;