# Uses python3
import sys
import numpy as np

def gcd_naive(a, b):
    current_gcd = 1
    for d in range(2, min(a, b) + 1):
        if a % d == 0 and b % d == 0:
            if d > current_gcd:
                current_gcd = d

    return current_gcd

def gcd_euclid(a, b):
    if b == 0:
        return a
    else:
        a_prime = a % b
        return gcd_euclid(b, a_prime)


def StressTest(max_value):
    while True:
    
        a = np.random.randint(1, max_value)
        b = np.random.randint(1, max_value)
                
        result_1 = gcd_naive(a, b)
        result_2 = gcd_euclid(a, b)
        
        if result_1 == result_2:
            print('OK', a, b, result_1, result_2)
    
        else:
            print('Wrong answer: ', a, b, result_1, result_2)
            return

if __name__ == "__main__":
# 1 <= a,b >= 2e9
    #input = sys.stdin.read()
    #a, b = map(int, input.split()) 
    a, b = map(int, input().split())
#    print(gcd_naive(a, b))
    print(gcd_euclid(a, b))
#    StressTest(max_value = 1e8)
