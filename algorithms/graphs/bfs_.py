# -*- coding: utf-8 -*-
"""
Created on Mon Mar 26 08:42:57 2018

@author: gael
"""

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

    #reconstruct path
#    result = []
#    while (t != s):
#        result.append(t)
#        t = prev[t]
    #distance = len(result
    
    return dist[t]
    
input = '4 4 1 2 4 1 2 3 3 1 2 4'
input = '5 4 5 2 1 3 3 4 1 4 3 5'
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