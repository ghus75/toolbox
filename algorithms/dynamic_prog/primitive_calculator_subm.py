# Uses python3
import sys

def optimal_sequence(n):
    #write your code here
    infinity = 1.1e6 # 1 <= n<= 1e6
    ops = [1, 2, 3] # 3 kinds of operations
    MinNumOps = [0]*(n + 1)
    MinNumOps[1] = 0
    prev = [None]*(n + 1)
    
    # for ea. amount
    for m in range(2, n + 1):
        MinNumOps[m] = infinity
        # check for ea type of operation
        for op in ops:
            if op == 1:# +1 operation
                if m > 1: # if applicable
                    # use previous optimal value, add this operation
                    NumOps = MinNumOps[m - 1] + 1
                    # if smaller number of operations is found, update
                    if NumOps < MinNumOps[m]:
                        MinNumOps[m] = NumOps
                        # save previous value, for displaying sequence afterwards
                        prev[m] = m - 1
            if op == 2: # *2 operation
                if not m%2:
                    NumOps = MinNumOps[m//2] + 1
                    if NumOps < MinNumOps[m]:
                        MinNumOps[m] = NumOps
                        prev[m] = m//2
            if op == 3: # *3 operation
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
Find minimum number of +1, *2, *3 operation to get from 1 to given n

Good job! (Max time used: 1.76/7.50, max memory used: 54292480/536870912.)
'''
input = sys.stdin.read()
n = int(input)

sequence = list(optimal_sequence(n))
print(len(sequence) - 1)
for x in sequence:
    print(x, end=' ')
