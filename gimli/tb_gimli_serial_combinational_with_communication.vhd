----------------------------------------------------------------------------------
-- 
-- Create Date:    28/11/2016
-- Design Name:    TestBench_Gimli_serial_combinational_with_communication
-- Module Name:    TestBench_Gimli_serial_combinational_with_communication
-- Project Name:   Gimli
-- Target Devices: Any
--
-- Description: 
--
-- Test bench for the Gimli rounds combinational.
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
-- gimli_number_of_rounds :
--
-- The number of rounds Gimli is performed
--
-- maximum_number_of_tests :
--
-- Maximum number of tests to be performed, if this value is 0 then all tests will be performed.
--
-- test_memory_file_gimli_permutation :
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

entity tb_gimli_serial_combinational_with_communication is
Generic(
        PERIOD : time := 100 ns;
        
        bus_size : integer := 8;
        
        gimli_number_of_total_rounds : integer := 24;
        gimli_number_of_combinatorial_rounds : integer := 1;
        
        gimli_a : integer := 2;
        gimli_b : integer := 1;
        gimli_c : integer := 3;
        gimli_d : integer := 24;
        gimli_e : integer := 9;
        gimli_f : integer := 0;
        gimli_round_base_constant : STD_LOGIC_VECTOR(31 downto 0) := X"9E377900";
        
        maximum_number_of_tests : integer := 100;
        
        test_memory_file_gimli_permutation : string := "../data_tests/gimli_permutation.dat"
);
end tb_gimli_serial_combinational_with_communication;

architecture Behavioral of tb_gimli_serial_combinational_with_communication is

component gimli_serial_combinational_with_communication is
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
end component;

signal test_state : STD_LOGIC_VECTOR((12*32 - 1) downto 0);
signal test_new_state : STD_LOGIC_VECTOR((12*32 - 1) downto 0);
signal true_new_state : STD_LOGIC_VECTOR((12*32 - 1) downto 0);

signal test_arstn : STD_LOGIC;
signal test_start : STD_LOGIC;
signal test_data_in_valid : STD_LOGIC;
signal test_data_out_ready : STD_LOGIC;
signal test_data_in : STD_LOGIC_VECTOR((bus_size - 1) downto 0);
signal test_data_out : STD_LOGIC_VECTOR((bus_size - 1) downto 0);
signal test_data_out_valid : STD_LOGIC;
signal test_data_in_ready : STD_LOGIC;
signal test_finish : STD_LOGIC;
signal test_core_free : STD_LOGIC;

signal test_error : STD_LOGIC := '0';
signal clk : STD_LOGIC := '1';
signal test_bench_finish : BOOLEAN := false;

constant tb_delay : TIME := (PERIOD/2);

procedure load_value(
    signal test_state : in STD_LOGIC_VECTOR((12*32 - 1) downto 0);
    signal test_data_in_valid : out STD_LOGIC;
    signal test_data_in : out STD_LOGIC_VECTOR((bus_size - 1) downto 0)) is
variable i : integer;
variable j : integer;
begin
    test_data_in <= (others => '0');
    test_data_in_valid <= '0';
    j := 0;
    i := bus_size - 1;
    wait for PERIOD;
    while (j < (12*32)) loop
        test_data_in <= test_state(i downto j);
        test_data_in_valid <= '1';
        wait for PERIOD;
        j := i + 1;
        i := i + bus_size;
    end loop;
    test_data_in_valid <= '0';
    wait for PERIOD;
end load_value;

procedure retrieve_value(
    signal test_new_state : out STD_LOGIC_VECTOR((12*32 - 1) downto 0);
    signal test_data_out_valid : in STD_LOGIC;
    signal test_data_out_ready : out STD_LOGIC;
    signal test_data_out : in STD_LOGIC_VECTOR((bus_size - 1) downto 0)) is
variable i : integer;
variable j : integer;
begin
    test_data_out_ready <= '1';
    j := 0;
    i := bus_size - 1;
    wait for PERIOD;
    while (j < (12*32)) loop
        if(test_data_out_valid = '1') then
            test_new_state(i downto j) <= test_data_out;
            j := i + 1;
            i := i + bus_size;
        end if;
        wait for PERIOD;
    end loop;
    test_data_out_ready <= '0';
    wait for PERIOD;
end retrieve_value;

begin

test : gimli_serial_combinational_with_communication
    Generic Map(
        bus_size => bus_size,
        number_of_total_rounds => gimli_number_of_total_rounds,
        a => gimli_a,
        b => gimli_b,
        c => gimli_c,
        d => gimli_d,
        e => gimli_e,
        f => gimli_f,
        round_base_constant => gimli_round_base_constant
    )
    Port Map(
        clk => clk,
        arstn => test_arstn,
        start => test_start,
        data_in_valid => test_data_in_valid,
        data_out_ready => test_data_out_ready,
        data_in => test_data_in,
        data_out => test_data_out,
        data_out_valid => test_data_out_valid,
        data_in_ready => test_data_in_ready,
        finish => test_finish,
        core_free => test_core_free
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
    variable before_time : time;
    variable after_time : time;
    begin       
        test_arstn <= '0';
        test_start <= '0';
        test_data_in_valid <= '0';
        test_data_out_ready <= '0';
        test_data_in <= (others => '0');
        wait for PERIOD*2;
        test_arstn <= '1';
        wait for PERIOD;
        wait for tb_delay;
        file_open(ram_file, test_memory_file_gimli_permutation, READ_MODE);
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
            while(test_data_in_ready = '0') loop
                wait for PERIOD;
            end loop;
            load_value(test_state, test_data_in_valid, test_data_in);
            wait for PERIOD;
            test_start <= '1';
            before_time := now;
            wait for PERIOD;
            test_start <= '0';
            wait for PERIOD;
            wait until test_finish = '1';
            wait for tb_delay;
            after_time := now;
            if(I = 1) then
                report "Operation time = " & integer'image((after_time - before_time)/(PERIOD)) & " cycles" severity note;
            end if;
            retrieve_value(test_new_state, test_data_out_valid, test_data_out_ready, test_data_out);
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