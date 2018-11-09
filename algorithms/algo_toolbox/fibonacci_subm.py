# Uses python3

import numpy as np

def calc_fib(n):
    if n <= 1:
        return n
    else:
        Fib = np.zeros(n + 1)
        Fib[0] = 0
        Fib[1] = 1
        for i in range(2, n + 1):
            Fib[i] = Fib[i-1] + Fib[i-2]

    return int(Fib[-1])

n = int(input())
print(calc_fib(n))
