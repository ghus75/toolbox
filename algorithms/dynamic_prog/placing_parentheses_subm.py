# Uses python3
def evalt(a, b, op):
    if op == '+':
        return a + b
    elif op == '-':
        return a - b
    elif op == '*':
        return a * b
    else:
        assert False

def get_maximum_value(dataset):
    
    digit = [int(d) for d in dataset[0:len(dataset):2]]
    op = [ops for ops in dataset[1:len(dataset):2]]
    
    n = len(digit)
    small_m = [[0 for j in range(n)] for i in range(n)]
    big_M = [[0 for j in range(n)] for i in range(n)]
    
    for i in range(n):
        small_m[i][i] = digit[i]
        big_M[i][i] = digit[i]

    def MinAndMax(i, j):
        min_, max_ = float('inf'), -1*float('inf')
        for k in range(i, j):
            a = evalt(big_M[i][k], big_M[k + 1][j], op[k])
            b = evalt(big_M[i][k], small_m[k + 1][j], op[k])
            c = evalt(small_m[i][k], big_M[k + 1][j], op[k])
            d = evalt(small_m[i][k], small_m[k + 1][j], op[k])
            min_ = min(min_, a, b, c, d)
            max_ = max(max_, a, b, c, d)
        return(min_, max_)
   
    for s in range(n - 1):
        for i in range(n - s - 1):
            j = i + s + 1
            small_m[i][j], big_M[i][j] = MinAndMax(i, j)
            
    return big_M[0][-1]


if __name__ == "__main__":
    '''
    Place parentheses in order to maximize value of given expression
    Output result
    
    ex. 5-8+7*4-8+9 --> 200 = (5 − ((8 + 7) × (4 − (8 + 9))))
    
    Good job! (Max time used: 0.07/5.00, max memory used: 9625600/536870912.)
    
    '''
    print(get_maximum_value(input()))
    #print(get_maximum_value('5-8+7*4-8+9'))
