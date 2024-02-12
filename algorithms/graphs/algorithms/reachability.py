#Uses python3

import sys
import numpy as np

def reach(adj, x, y):
    #write your code here
    m = len(adj)
    visited = np.zeros(m)
    
    def explore(u):
        visited[int(u)] = True
        for v in adj[int(u)]:
            if not visited[int(v)]:
                explore(v)
    
    explore(x)
    
    if visited[int(y)]: return 1
    else: return 0       
    
if __name__ == '__main__':
    '''
    Given an undirected graph and two distinct vertices u and v, 
    check if there is a path between u and v.
    Good job! (Max time used: 0.33/5.00, max memory used: 18018304/536870912.)
    '''
    
    input = sys.stdin.read()
    data = list(map(int, input.split()))
    n, m = data[0:2] # number of vertices and edges
    data = data[2:] # ea. line is vertex vertex 
    # list of edges
    edges = list(zip(data[0:(2 * m):2], data[1:(2 * m):2]))
    x, y = data[2 * m:]
    # adjacency table
    adj = [[] for _ in range(n)]
    x, y = x - 1, y - 1
    for (a, b) in edges:
        adj[a - 1].append(b - 1)
        adj[b - 1].append(a - 1)
    print(reach(adj, x, y))
