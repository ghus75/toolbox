# Uses python3
import sys

def optimal_sequence(n):
    #write your code here
    infinity = 1.1e3 # 1 <= m <= 1e3
    ops = [1, 2, 3] # 3 kinds of operations
    MinNumOps = [0]*(n + 1)
    MinNumOps[1] = 0
    prev = [None]*(n + 1)
    
    for m in range(2, n + 1):
        MinNumOps[m] = infinity
        for op in ops:
            if op == 1:# +1
                if m > 1:
                    NumOps = MinNumOps[m - 1] + 1
                    if NumOps < MinNumOps[m]:
                        MinNumOps[m] = NumOps
                        prev[m] = m - 1
            if op == 2:
                if not m%2:
                    NumOps = MinNumOps[m//2] + 1
                    if NumOps < MinNumOps[m]:
                        MinNumOps[m] = NumOps
                        prev[m] = m//2
            if op == 3:
                if not m%3:
                    NumOps = MinNumOps[m//3] + 1
                    if NumOps < MinNumOps[m]:
                        MinNumOps[m] = NumOps
                        prev[m] = m//3

    sequence = [n]
    x = n
    i = n
    while x > 1:
        x = prev[i]
        sequence.append(x)
        i = x
    return reversed(sequence)#MinNumOps

'''
Good job! (Max time used: 1.76/7.50, max memory used: 54292480/536870912.)
'''
input = sys.stdin.read()
n = int(input)
#n = 96234
#n = 20
sequence = list(optimal_sequence(n))
print(len(sequence) - 1)
for x in sequence:
    print(x, end=' ')
