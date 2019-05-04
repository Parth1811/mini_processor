from copy import deepcopy

output_file  = open("TRACEFILE_ALU.txt", "w")

def bindigits(n, bits):
    s = bin(n & int("1"*bits, 2))[2:]
    return ("{0:0>%s}" % (bits)).format(s)

def bit_not(str):
    output = ''
    for i in str:
        output += '1' if i == '0' else '0'
    return output

if __name__ == '__main__':
    for i in range (256):
        for j in range(256):
            out_string = bindigits(i, 16) + bindigits(j, 16) + '10 0'
            out_string += '1' if bit_not(bindigits(i & j, 16)) == bindigits(0, 16) else '0'
            out_string += bit_not(bindigits(i & j, 16))
            out_string += ' 111111111111111111\n'
            output_file.write(out_string)
