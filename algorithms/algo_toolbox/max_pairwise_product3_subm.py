# python3

import numpy as np
import time

def max_pairwise_product_naive(numbers):
    n = len(numbers)
    max_product = 0
    for first in range(n):
        for second in range(first + 1, n):
            max_product = max(max_product,
                              numbers[first] * numbers[second])

    return max_product

def max_pairwise_product_fast(numbers):
    numbers_sorted = sorted(numbers)
    res = numbers_sorted[-1]*numbers_sorted[-2]

    return res

def StressTest(array_size, max_value):
    while True:
    
        rand_array_size = np.random.randint(2, array_size)
        values = np.zeros(rand_array_size)
        for i in range(rand_array_size):
            values[i] = np.random.randint(0, max_value)
        print(values)
        
        result_1 = max_pairwise_product_naive(list(values))
        result_2 = max_pairwise_product_fast(list(values))
        
        if result_1 == result_2:
            print('OK')
    
        else:
            print('Wrong answer: ', result_1, result_2)
            return

if __name__ == '__main__':
    input_n = int(input()) # submitted program only
    input_numbers = [int(x) for x in input().split()]
    
#    print(max_pairwise_product_naive(input_numbers))
    print(max_pairwise_product_fast(input_numbers))
#    StressTest(1000, 100000)
