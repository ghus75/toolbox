# Uses python3
import sys
import operator
def get_optimal_value(capacity, weights, values):
    value = 0.
    # write your code here
    ratio  = [(i, values[i]/weights[i]) for i in range(len(weights))]
    ratio = sorted(ratio, key=operator.itemgetter(1), reverse = True)
    
    #for i in [tuple_[0] for tuple_ in ratio]:
    for tuple_ in ratio:
        if capacity == 0:
            return value
        a = min(weights[tuple_[0]], capacity)
        value = value + a*tuple_[1]
        weights[tuple_[0]] = weights[tuple_[0]] - a
        capacity = capacity - a    

    return value


if __name__ == "__main__":

    data = list(map(int, sys.stdin.read().split()))
    #data = list(map(int, input().split()))  
    n, capacity = data[0:2]
    values = data[2:(2 * n + 2):2]
    weights = data[3:(2 * n + 2):2]
    opt_value = get_optimal_value(capacity, weights, values)
#    opt_value = get_optimal_value(50, [20, 50, 30], [60, 100, 120])
#    opt_value = get_optimal_value(10, [30], [500])
    print("{:.10f}".format(opt_value))
