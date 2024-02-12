# Uses python3
import sys

#def optimal_weight(W, w):
#    # write your code here
#    result = 0
#    for x in w:
#        if result + x <= W:
#            result = result + x
#    return result

def optimal_weight(W, w):
    
    n = len(w)
    value = [[0 for i in range(n + 1)] for weight in range(W + 1)]
        
    for i in range(1, n + 1):
        for weight in range(1, W + 1):
            value[weight][i] = value[weight][i - 1]
            if w[i - 1] <= weight:
                val = value[weight - w[i - 1]][i - 1] + w[i - 1]# v_i = w_i
                if value[weight][i] < val:
                    value[weight][i] = val
    return value[W][n]
    

if __name__ == '__main__':
    '''
    Knapsack w/o duplicates
    Good job! (Max time used: 1.17/10.00, max memory used: 33738752/536870912.)
    '''


    input = sys.stdin.read()
    W, n, *w = list(map(int, input.split()))
    
#    W = 10
#    n = 3
#    w = [1,4,8]
    print(optimal_weight(W, w))
