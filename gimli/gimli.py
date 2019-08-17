#!/usr/bin/env python2

"""State are seen as  a 3 x 4 x 32 array """

shift_x = 2  # a
shift_y = 1  # b
shift_z = 3  # c
rot_x = 24  # d
rot_y = 9  # e
rot_z = 0  # f


def rot(x, n):
    """Bitwise rotation (to the left) of n bits considering the \
    string of bits is 32 bits long"""
    x %= 1 << 32
    n %= 32
    # if n == 0:
    # print(hex(x), "=>", hex((x >> (32 - n)) | (x << n) % (1 << 32)))
    return (x >> (32 - n)) | (x << n) % (1 << 32)


def non_lin_perm_96(sheet, a=shift_x, b=shift_y, c=shift_z, d=rot_x, e=rot_y, f=rot_z):
    """Apply the non linear permutation on the 96 sheet of the state"""

    x = sheet[0]
    y = sheet[1]
    z = sheet[2]
    
    x = rot(x, d)
    y = rot(y, e)
    z = rot(z, f)
    sheet[2] = x ^ (z << 1) ^ ((y & z) << a)
    sheet[1] = y ^ x ^ ((x | z) << b)
    sheet[0] = z ^ y ^ ((x & y) << c)
    sheet[2] %= 1 << 32
    sheet[1] %= 1 << 32
    sheet[0] %= 1 << 32
    return sheet


def small_swap(state):
    for j in range(1):
        state[0][j], state[1][j], state[2][j], state[3][j] \
            = state[1][j], state[0][j], state[3][j], state[2][j]
    return state


def big_swap(state):
    for j in range(1):
        state[0][j], state[1][j], state[2][j], state[3][j] \
            = state[2][j], state[3][j], state[0][j], state[1][j]
    return state


def print_to_hex(x):
    for i in range(3):
        output = ""
        for j in range(4):
            output += ("{0:08x}").format(x[j][i]) + " "
        print output
    print("----------------------")

def gimli(state):
    """ Number of rounds has still to be determined """
    for outer_rounds in range(6):

        """ Apply the inner diffusion (96 bits) on the sheet """
        for inner_rounds in range(4):

            """ Apply the 96 Non linear permutation on each sheet """
            for i_sheet in range(4):
                state[i_sheet] = non_lin_perm_96(state[i_sheet], shift_x, shift_y, shift_z, rot_x, rot_y, rot_z)

            if inner_rounds == 0:
                state = small_swap(state)
            if inner_rounds == 2:
                state = big_swap(state)
            if inner_rounds == 0:
                state[0][0] ^= 0x9e377900 + (24 - (outer_rounds * 4 + inner_rounds))

            # print("round: ", outer_rounds * 4 + inner_rounds)
            # print_to_hex(state)
        
    return state


if __name__ == "__main__":    

    x = [(i * i * i + i * 0x9e3779b9) % (2 ** 32) for i in range(12)]
    
    x = [[x[4 * i + j] for i in range(3)] for j in range(4)]
    
    print_to_hex(x)
    x = gimli(x)
    print_to_hex(x)
