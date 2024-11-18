import sys
import re
import os

index = 0
program_name = ''
mapping = {
    'SETIXH': 'd0', 'SETIXL': 'd1',
    'LDIA':   'd8', 'LDIB':   'd9', 'LDDA':   'e0', 'LDDB':   'e1',
    'STDA':   'f0', 'STDB':   'f4', 'STDI':   'f8',
    'ADDA':   '80', 'SUBA':   '81', 'ANDA':   '82', 'ORA':    '83', 'NOTA':   '84', 'INCA':   '85', 'DECA':   '86',
    'ADDB':   '90', 'SUBB':   '91', 'ANDB':   '92', 'ORB':    '93', 'NOTB':   '98', 'INCB':   '99', 'DECB':   '9a',
    'CMP':    'a1',
    'NOP':    '00', 'JP':     '60', 'JPC':    '40', 'JPZ':    '50',
    'DC':     'set',
    'RET':    'ret',
    'END':    'end'
}

def convert(f, datalist):
    global index
    global mapping
    # 行を分割する
    data_arg = re.split(' |\t',datalist.rstrip('\n'))
    # 出力一時保持用
    result = ''
    # アドレス指定(第一引数の有無)
    if (data_arg[0] != ''):
        tmp_index = convert_to_decimal(data_arg[0])
        if (tmp_index > index):
            if (tmp_index < 32768): # #8000以降の場合は埋めなくてよい
                while (index < tmp_index):
                    result = result + format(index, '04x') + '\t00\n'
                    index += 1
            index = tmp_index
        elif (tmp_index == -1):
            return -1
        # elif (tmp_index == -2):
    
    result = result + format(index, '04x') + '\t'
    index += 1

    command = mapping.get(data_arg[1], '-1')
    if not (command.startswith('-1')): # 存在しない命令
        if (command.startswith('set')):
            id = data_arg[2]
            if (id.startswith('#') and int(id[1:])<256): # #から始まり，かつ2桁の16進数
                result = result + data_arg[2][1:] + '\n'
            else:
                return -1
        elif (command.startswith(('end', 'ret'))):
            return 0
        else:
            result = result + command + '\n'

    if (command.startswith(('d', 'f8'))): # 1つの即値を持つ命令
        id = data_arg[2]
        if (id.startswith('#') and int(id[1:])<256):
            result = result + format(index, '04x') + '\t'
            index += 1
            result = result + id[1:] + '\n'
        else:
            return -1
        
    if (command.startswith(('4', '5', '6'))): # 2つの即値を持つ命令
        id = data_arg[2]
        if (id.startswith('#') and int(id[1:])<65536):
            id_4 = format(int(id[1:]), '04x')
            result = result + format(index, '04x') + '\t'
            index += 1
            result = result + id_4[0:2] + '\n'
            result = result + format(index, '04x') + '\t'
            index += 1
            result = result + id_4[2:4] + '\n'
        else:
            result = result + format(index, '04x') + '\t'
            index += 1
            result = result + id + "_H" + '\n'
            result = result + format(index, '04x') + '\t'
            index += 1
            result = result + id + "_L" + '\n'

    f.write(result)
    return 0

def start_check(datalist):
    data_arg = re.split(' |\t', datalist.rstrip('\n'))
    if (data_arg[0] != ''):
        global program_name
        program_name = data_arg[0]
        if (data_arg[1] == 'START'):
            return 0
        else:
            return -1
    else:
        return -1

def convert_to_decimal(string):
    if string.startswith("#"):
        try:
            decimal_number = int(string[1:], 16)
            return decimal_number
        except ValueError:
            return -1
    elif (string.isdecimal()):
        return int(string)
    else:
        return -2


if __name__ == '__main__':
    args = sys.argv
    f = open(args[1], 'r')
    datalist = f.readlines()
    f.close()

    f = open("output.txt", 'w')
    for i in range(len(datalist)):
        print(re.split(' |\t',datalist[i].rstrip('\n')))
        if (i==0):
            if (start_check(datalist[i]) == -1):
                f.close
                os.remove("output.txt")
                exit
        else:
            if (convert(f, datalist[i]) == -1):
                f.close
                # os.remove("output.txt")
                exit
    


