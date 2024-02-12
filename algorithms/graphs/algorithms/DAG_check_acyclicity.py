#Uses python3

import sys
import numpy as np

def acyclic(adj):

    n = len(adj)
    visited = np.zeros(n)
    stack = np.zeros(n)
    
    def isCyclic(vertex):

        visited[vertex] = 1
        stack[vertex] = 1
        for neighbor in adj[vertex]:
            if not visited[neighbor]:
                if isCyclic(neighbor): return 1
            elif stack[neighbor]: return 1 # if neighbor already in stack
        stack[vertex] = 0 # if no cycle, put stack value back to 0
        return 0
 
    for v in range(n):
        if not visited[int(v)]:
            if isCyclic(v): return 1
    return 0
    
if __name__ == '__main__':
    '''
    Check whether a given directed graph with n vertices and m edges
    contains a cycle.

    Good job! (Max time used: 0.21/5.00, max memory used: 17739776/536870912.)
    '''
    input = sys.stdin.read()
    data = list(map(int, input.split()))
    n, m = data[0:2]
    data = data[2:]
    edges = list(zip(data[0:(2 * m):2], data[1:(2 * m):2]))
    adj = [[] for _ in range(n)]
    for (a, b) in edges:
        adj[a - 1].append(b - 1)
    print(acyclic(adj))
