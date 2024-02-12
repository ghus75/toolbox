#Uses python3

import sys


def negative_cycle(adj, cost):
    
    infinity = 10**8#10**4 max edges, weights are integers of absolute value at most 10**3
    dist = [infinity] * len(adj)
    prev = [-1] *len(adj)
    dist[3] = 0 # start from vertex 3
        
    # Bellman-Ford |V| times
    iter_Bellman_Ford = 1
    v = -1    
    while iter_Bellman_Ford <= len(adj):
        for vertex in range(len(adj)):
            neighbor_idx = 0
            for neighbor in adj[vertex]:
                if dist[neighbor] > dist[vertex] + cost[vertex][neighbor_idx]:
                    dist[neighbor] = dist[vertex] + cost[vertex][neighbor_idx]
                    if iter_Bellman_Ford == len(adj):# last iteration
                        v = neighbor# save relaxed node
                    prev[neighbor] = vertex
                neighbor_idx += 1
        iter_Bellman_Ford += 1
    
    flag_neg_cycle = 0

    if (v != -1):
        # start from x <- v
        x = v
        for _ in range(len(adj)):
            x = prev[x]

        #save y <- x
        y = x
        for _ in range(len(adj)):
            x = prev[x]
            if (x == y):
                flag_neg_cycle = 1
                break
    

    return flag_neg_cycle


if __name__ == '__main__':
    '''
    Given an directed graph with possibly negative edge weights and with n 
    vertices and m edges, checks whether it contains a cycle of negative weight.
    
    Outputs 1 if the graph contains a cycle of negative weight and 0 otherwise.
    
    Good job! (Max time used: 3.45/10.00, max memory used: 10395648/536870912.)
    '''
    input = sys.stdin.read()
    data = list(map(int, input.split()))
    n, m = data[0:2]
    data = data[2:]
    edges = list(zip(zip(data[0:(3 * m):3], data[1:(3 * m):3]), data[2:(3 * m):3]))
    data = data[3 * m:]
    adj = [[] for _ in range(n)]
    cost = [[] for _ in range(n)]
    for ((a, b), w) in edges:
        adj[a - 1].append(b - 1)
        cost[a - 1].append(w)
    print(negative_cycle(adj, cost))
