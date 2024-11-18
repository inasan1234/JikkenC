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
    'END':    'end',
    'SETIX':  'setix'
}

def convert(f, datalist):
    global index
    global mapping
    # 出力一時保持用
    result = ''
    # ラベル一時保持用
    label_stack = []
    for i in range(len(datalist)):
        if (i==0):
            if (start_check(datalist[i]) == -1):
                return -1
        else:
            # 行を分割する
            data_arg = re.split(' |\t',datalist[i].rstrip('\n'))
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
                elif (tmp_index == -2): # ラベルを置換する
                    label_stack.append((data_arg[0], format(index, '04x')))
                    continue

            command = mapping.get(data_arg[1], '-1')
            if not (command.startswith('-1')): # 存在しない命令でない
                if (command.startswith('set')):
                    result = result + format(index, '04x') + '\t'
                    index += 1
                    id = data_arg[2]
                    if (id.startswith('#') and int(id[1:], 16)<256): # #から始まり，かつ2桁の16進数
                        result = result + data_arg[2][1:] + '\n'
                    else:
                        return -1
                elif (command.startswith(('end', 'ret'))):
                    continue
                elif (command.startswith('setix')):
                    result = result + format(index, '04x') + '\t'
                    index += 1
                else:
                    result = result + format(index, '04x') + '\t'
                    index += 1
                    result = result + command + '\n'

            if (command.startswith(('d', 'f8'))): # 1つの即値を持つ命令
                id = data_arg[2]
                if (id.startswith('#') and int(id[1:], 16)<256):
                    result = result + format(index, '04x') + '\t'
                    index += 1
                    result = result + id[1:] + '\n'
                else:
                    return -1
                
            if (command.startswith(('4', '5', '6'))): # 2つの即値を持つ命令
                id = data_arg[2]
                if (id.startswith('#') and int(id[1:], 16)<65536):
                    id_4 = id[1:]
                    result = result + format(index, '04x') + '\t'
                    index += 1
                    result = result + id_4[0:2] + '\n'
                    result = result + format(index, '04x') + '\t'
                    index += 1
                    result = result + id_4[2:4] + '\n'
                elif (id[0].isalpha()): # ラベル
                    result = result + format(index, '04x') + '\t'
                    index += 1
                    result = result + id + "_H" + '\n'
                    result = result + format(index, '04x') + '\t'
                    index += 1
                    result = result + id + "_L" + '\n'
                else:
                    return -1

            if (command.startswith('setix')): # SETIX命令
                id = data_arg[2]
                if (id.startswith('#') and int(id[1:])<65536):
                    id_4 = id[1:]
                    # SETIXH
                    result = result + format(index, '04x') + '\t'
                    index += 1
                    result = result + 'd0'
                    result = result + format(index, '04x') + '\t'
                    index += 1
                    result = result + id_4[0:2] + '\n'
                    # SETIXL
                    result = result + format(index, '04x') + '\t'
                    index += 1
                    result = result + 'd1'
                    result = result + format(index, '04x') + '\t'
                    index += 1
                    result = result + id_4[2:4] + '\n'

    while label_stack:
        label = label_stack.pop()
        result = result.replace(label[0]+'_H', label[1][0:2])
        result = result.replace(label[0]+'_L', label[1][2:4])

    f.write(result)


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
    if string.startswith("#"): # 16進数
        try:
            decimal_number = int(string[1:], 16)
            return decimal_number
        except ValueError:
            return -1
    elif (string.isdecimal()): # 10進数
        return int(string)
    elif (string[0].isalpha()): # ラベル
        return -2
    else: # エラー
        return -1


if __name__ == '__main__':
    args = sys.argv
    f = open(args[1], 'r')
    datalist = f.readlines()
    f.close()

    f = open("output.txt", 'w+')
    if (convert(f, datalist) == -1):
        f.close
        os.remove("output.txt")
        exit
    else:
        f.close
        exit
    


