#Uses python3

import sys

def dfs(adj, used, order, x):
    #write your code here
    def explore(u):
        used[u] = True
        for v in adj[u]:
            if not used[v]:
                explore(v)
        order.insert(0,u)
    
    for v in range(len(adj)):
        if not used[v]:
            explore(v)

def toposort(adj):
    used = [0] * len(adj)
    order = []
    #write your code here
    
    dfs(adj, used, order, 0)
    
    return order
    
if __name__ == '__main__':
    input = sys.stdin.read()
    data = list(map(int, input.split()))
    n, m = data[0:2]
    data = data[2:]
    edges = list(zip(data[0:(2 * m):2], data[1:(2 * m):2]))
    adj = [[] for _ in range(n)]
    for (a, b) in edges:
        adj[a - 1].append(b - 1)
    order = toposort(adj)
    for x in order:
        print(x + 1, end=' ')

