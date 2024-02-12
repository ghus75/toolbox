#Uses python3

import sys
import queue
from collections import deque

def distance(adj, s, t):
    #write your code here
    
    # bfs algortihm
    # number of vertices
    n = len(adj)
    infinity = -1 #n + 1
    
    dist = [infinity] * len(adj)
    prev = [-1] * len(adj)
    
    dist[s] = 0
    Q = deque([s])
    
    while Q:
        u = Q.popleft()
        for neighbor in adj[u]:
            if dist[neighbor] == infinity:
                Q.append(neighbor)
                dist[neighbor] = dist[u] + 1
                prev[neighbor] = u
    return dist[t]

if __name__ == '__main__':
    '''
    Given an undirected graph with n vertices and m edges and two vertices
    u and v, computes the length of a shortest path between u and v (that is,
    the minimum number of edges in a path from u to v).
    
    Good job! (Max time used: 0.54/10.00, max memory used: 46530560/536870912.)
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
    s, t = data[2 * m] - 1, data[2 * m + 1] - 1
    print(distance(adj, s, t))
