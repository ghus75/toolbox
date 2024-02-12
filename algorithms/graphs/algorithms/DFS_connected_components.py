#Uses python3

import sys
import numpy as np

def number_of_components(adj):
    '''
    DFS algorithm
    '''
    result = 0
    
    m = len(adj)
    visited = np.zeros(m)
    cc = 1
    
    def explore(u):
        visited[int(u)] = True
        for v in adj[int(u)]:
            if not visited[int(v)]:
                explore(v)
    
    for v in range(m):
        if not visited[int(v)]:
            explore(v)
            cc += 1
    
    result = cc - 1

    return result

if __name__ == '__main__':
    '''
    Given an undirected graph with n vertices and m edges, 
    computes the number of connected components in it.
    
    Uses DFS
    
    Good job! (Max time used: 0.38/5.00, max memory used: 18030592/536870912.)
    '''
    
    input = sys.stdin.read()
    data = list(map(int, input.split()))
    n, m = data[0:2]
    data = data[2:]
    edges = list(zip(data[0:(2 * m):2], data[1:(2 * m):2]))
    adj = [[] for _ in range(n)]
    for (a, b) in edges:
        adj[a - 1].append(b - 1)
        adj[b - 1].append(a - 1)
    print(number_of_components(adj))
