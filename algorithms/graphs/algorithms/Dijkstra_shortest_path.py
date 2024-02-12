#Uses python3

import sys
import queue

import heapq
import itertools

def distance(adj, cost, s, t):
    
    infinity = 10**8 + 1 #10**5 max edges, edge weights are non-negative integers not exceeding 10**3
    dist = [infinity] * len(adj)
    prev = [-1] *len(adj)
    dist[s] = 0
    
    # priority queue from python doc
    pq = []                         # list of entries arranged in a heap
    entry_finder = {}               # mapping of tasks to entries
    REMOVED = '<removed-task>'      # placeholder for a removed task
    counter = itertools.count()     # unique sequence count
    
    def add_task(task, priority=0):
        'Add a new task or update the priority of an existing task'
        if task in entry_finder:
            remove_task(task)
        count = next(counter)
        entry = [priority, count, task]
        entry_finder[task] = entry
        heapq.heappush(pq, entry)

    def remove_task(task):
        'Mark an existing task as REMOVED.  Raise KeyError if not found.'
        entry = entry_finder.pop(task)
        entry[-1] = REMOVED

    def pop_task():
        'Remove and return the lowest priority task. Raise KeyError if empty.'
        while pq:
            priority, count, task = heapq.heappop(pq)
            if task is not REMOVED:
                del entry_finder[task]
                return task
        #raise KeyError('pop from an empty priority queue')
    
    #initial priority queue
    for u in range(len(adj)):
        add_task(u, dist[u])
    
    while pq:
        u = pop_task() # extract min from prio queue, put it in known region
        if pq:
            neighbor_idx = 0
            for neighbor in adj[u]:
                # relax all edges to neighbors
                if dist[neighbor] > dist[u] + cost[u][neighbor_idx]:
                    dist[neighbor] = dist[u] + cost[u][neighbor_idx]
                    prev[neighbor] = u
                    # update priority of each neighbor in prio queue
                    add_task(neighbor, dist[neighbor])
                neighbor_idx += 1

    if dist[t] == infinity:
        dist[t] = -1
    return dist[t]

if __name__ == '__main__':
    '''
    Given an directed graph with positive edge weights and with n vertices and 
    m edges as well as two vertices u and v, compute the weight of a shortest
    path between u and v (that is, the minimum total weight of a path from 
    u to v).
    
    Outputs the minimum weight of a path from u to v, or −1 if there is no path.
    
    Uses Dijkstra's algorithm
    
    Good job! (Max time used: 0.39/10.00, max memory used: 43376640/536870912.)
    '''
    input = sys.stdin.read()
    data = list(map(int, input.split()))
    n, m = data[0:2] # number of vertices, number of edges
    data = data[2:] # ea line is vertex vertes weight
    edges = list(zip(zip(data[0:(3 * m):3], data[1:(3 * m):3]), data[2:(3 * m):3]))
    data = data[3 * m:]
    adj = [[] for _ in range(n)]
    cost = [[] for _ in range(n)]
    for ((a, b), w) in edges:
        adj[a - 1].append(b - 1)
        cost[a - 1].append(w)
    s, t = data[0] - 1, data[1] - 1
    print(distance(adj, cost, s, t))
