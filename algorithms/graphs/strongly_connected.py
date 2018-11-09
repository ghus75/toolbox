#Uses python3

import sys

sys.setrecursionlimit(200000)

def number_of_strongly_connected_components(adj, adj_reverse):
    result = 0
    #write your code here
    order = []
    visited = [0] * len(adj)
    
    # Explore reverse graph to get reverse post order
    def explore_rev(u):
        visited[u] = True
        for neighbor in adj_reverse[u]:
            if not visited[neighbor]:
                explore_rev(neighbor)
#        order.append(u)
        order.insert(0,u)
    
    for v in range(len(adj_reverse)):
        if not visited[v]:
            explore_rev(v)
    
    #reset visited vertices
    visited = [0] * len(adj)    
    # Explore vertices of original graph. Use reverse post order given by order list.
    scc = [[] for _ in range(len(adj))]   
    scc_num = 0    
    def explore(u):
        nonlocal scc_num
        visited[u] = True
        scc[scc_num].append(u)        
        for neighbor in adj[u]:
            if not visited[neighbor]:
                explore(neighbor)

    for v in order:
        if not visited[v]:
            explore(v)
            scc_num += 1
            
    result = len([x for x in scc if len(x) != 0])

    return result

if __name__ == '__main__':
    input = sys.stdin.read()
    data = list(map(int, input.split()))
    n, m = data[0:2]
    data = data[2:]
    
    edges = list(zip(data[0:(2 * m):2], data[1:(2 * m):2]))
    rev_edges = [(b,a) for (a,b) in edges]

    adj = [[] for _ in range(n)]
    adj_reverse = [[] for _ in range(n)]
    
	#for (a, b) in edges:
    for (a, b) in edges:
        adj[a - 1].append(b - 1)
        
    for (a,b) in rev_edges:
    	adj_reverse[a - 1].append(b - 1)
    	
    print(number_of_strongly_connected_components(adj, adj_reverse))
