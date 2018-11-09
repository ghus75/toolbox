# Uses python3
import sys

def get_fibonacci_huge_naive(n, m):
    if n <= 1:
        return n

    previous = 0
    current  = 1

    for _ in range(n - 1):
        previous, current = current, previous + current

    return current % m

def calc_fib(n):
    if n <= 1:
        return n
    else:
        previous = 0
        current = 1
        for _ in range(n - 1):
            current, previous = current + previous, current

    return current

def pisano_period_length(m):
    #fib_mod_m = []
    if m == 2:
        return 3
    else:
        next_to_last = 1
        last = 1
        length = 3 # Fi mod 3 = 0, 1, 1
        
        while ((next_to_last, last) != (0, 1)):
            next_to_last, last = last, (next_to_last + last) % m
            length += 1

        return length - 2 # (next_to_last, last) = (0, 1) first 2 elements of next period

def get_fibonacci_huge_fast(n, m):
    l = pisano_period_length(m)
    return calc_fib(n % l) % m

if __name__ == '__main__':
#    input = sys.stdin.read();
#1 ≤ n ≤ 10**18 , 2 ≤ m ≤ 10**5 .
    n, m = map(int, input().split())
    #print(get_fibonacci_huge_fast(2816213588, 30524))
    print(get_fibonacci_huge_fast(n, m))
