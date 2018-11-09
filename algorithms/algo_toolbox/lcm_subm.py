# Uses python3
import sys
import numpy as np

def lcm_naive(a, b):
    for l in range(1, a*b + 1):
        if l % a == 0 and l % b == 0:
            return l

    return a*b


def gcd_euclid(a, b):
    if b == 0:
        return a
    else:
        a_prime = a % b
        return gcd_euclid(b, a_prime)

def lcm_fast(a,b):
    return (a*b)//gcd_euclid(a,b) #force la division a retourner un entier

def StressTest(max_value):
    while True:
    
        a = np.random.randint(1, max_value)
        b = np.random.randint(1, max_value)
                
        result_1 = lcm_naive(a, b)
        result_2 = lcm_fast(a, b)
        
        if result_1 == result_2:
            print('OK', a, b, result_1, result_2)
    
        else:
            print('Wrong answer: ', a, b, result_1, result_2)
            return


if __name__ == '__main__':

    a, b = map(int, input().split())
#
#    print(lcm_naive(a, b))
    print(lcm_fast(a, b))
#    StressTest(1e4)
