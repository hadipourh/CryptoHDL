import os
import random

import gimli

def print_state_to_VHDL(x, file):
    output = ""
    for i in range(3):
        for j in range(4):
            output =  ("{0:0"+str(32)+"b}").format(x[j][i]) + output
    file.write(output)
    file.write('\n')

def print_non_linear_permutation(number_of_tests, VHDL_file_name="gimli_all_columns_non_linear_permutation.dat"):
    tests_folder = "data_tests/"
    if(not os.path.isdir(tests_folder)):
        os.makedirs(tests_folder)
    with open(tests_folder+VHDL_file_name, 'w') as VHDL_memory_file:
        VHDL_memory_file.write((("{0:0d}").format(number_of_tests)))
        VHDL_memory_file.write('\n')
        x = [(i * i * i + i * 0x9e3779b9) % (2 ** 32) for i in range(12)]
        x = [[x[4 * i + j] for i in range(3)] for j in range(4)]
        for i in range(number_of_tests):
            print_state_to_VHDL(x, VHDL_memory_file)
            for i_sheet in range(4):
                x[i_sheet] = gimli.non_lin_perm_96(x[i_sheet])
            print_state_to_VHDL(x, VHDL_memory_file)
            for j in range(4):
                for i in range(3):
                    x[j][i] = random.randint(0, 2**32-1)

def print_gimli_permutation(number_of_tests, VHDL_file_name="gimli_permutation.dat"):
    tests_folder = "data_tests/"
    if(not os.path.isdir(tests_folder)):
        os.makedirs(tests_folder)
    with open(tests_folder+VHDL_file_name, 'w') as VHDL_memory_file:
        VHDL_memory_file.write((("{0:0d}").format(number_of_tests)))
        VHDL_memory_file.write('\n')
        x = [(i * i * i + i * 0x9e3779b9) % (2 ** 32) for i in range(12)]
        x = [[x[4 * i + j] for i in range(3)] for j in range(4)]
        for i in range(number_of_tests):
            print_state_to_VHDL(x, VHDL_memory_file)
            x = gimli.gimli(x)
            print_state_to_VHDL(x, VHDL_memory_file)
            for j in range(4):
                for i in range(3):
                    x[j][i] = random.randint(0, 2**32-1)

if __name__ == "__main__":
    print_non_linear_permutation(1000)
    print_gimli_permutation(1000)
