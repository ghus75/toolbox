# Uses python3
import sys
import numpy as np

def get_majority_element(a, left, right): # right = length of array
     if left == right:
         return -1 # empty array
     if left + 1 == right:
         return a[left] # size 1 array
     #write your code here
     mid = left + (right - 1 - left)//2
     maj_left = get_majority_element(a, left, mid + 1)
     maj_right = get_majority_element(a, mid +  1, right)
     
     if maj_left == maj_right:
         return maj_left
     else:
         count_left = np.sum([1 for i in range(left, right) if a[i] == maj_left])
         count_right = np.sum([1 for i in range(left, right) if a[i] == maj_right])
         if count_left > (right - left)/2:
             return maj_left
         if count_right > (right - left)/2:
             return maj_right
     return -1

if __name__ == '__main__':
    '''
    check whether an input sequence contains a majority element 
    (strictly more than half of the elements)
    Use divide and conquer (easier and faster using dict)
    
    Good job! (Max time used: 3.09/5.00, max memory used: 30711808/536870912.)
    '''
    input = sys.stdin.read()
    n, *a = list(map(int, input.split()))

#    n = 5
#    a = [2, 3, 9, 2, 2]
#    a = [2, 3, 9, 1, 2]
#    n = 8
#    a = [2, 2, 2, 2, 2, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0]
    #2 2 2 2 1 1 1 0 1 1 1 0 1 1 1 0
    if get_majority_element(a, 0, n) != -1:
        print(1)
    else:
        print(0)
