def optimal_weight_dynamic(W, w, v):
    '''
    W : capacity
    w : weight list
    v : values list
    
    Example :
    
    W = 10
    n = 4
    w = [2,6,3,4]
    v = [9,30,14,16]
    optimal_weight(W, w)
    [[ 0  0  0  0  0  0  0  0  0  0  0]
     [ 0  0  9  9  9  9  9  9  9  9  9]
     [ 0  0  9  9  9  9 30 30 39 39 39]
     [ 0  0  9 14 14 23 30 30 39 44 44]
     [ 0  0  9 14 16 23 30 30 39 44 46]]
    46
    '''
    n = len(w)
    
    all_values = np.zeros((W + 1, 1), dtype=int)
        
    for i in range(1, n + 1):
        all_values = np.append(all_values, np.zeros((W + 1, 1), dtype=int), axis=1)
        
        for weight in range(1, W + 1):
            all_values[weight][i] = all_values[weight][i - 1]
            if w[i - 1] <= weight:
                val = all_values[weight - w[i - 1]][i - 1] + v[i - 1]
                if all_values[weight][i] < val:
                    all_values[weight][i] = val
        if (all_values[W][-1] == W):
            break
    
    return all_values

def backtrace(values, weights):
    w = values.shape[0] - 1
    weights = [0] +  weights # copie locale de weights avec un 0 inséré au début
    w_opt = [False]*(values.shape[1] - 1)
    
    for i in reversed(range(1, values.shape[1])):
        
        w_i = weights[i]

        if (values[w][i] != values[w][i - 1]):
            w_opt[i - 1] = True
            w = w - w_i
    
    return w_opt
