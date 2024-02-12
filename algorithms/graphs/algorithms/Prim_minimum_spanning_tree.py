#Uses python3
import sys
import math

import itertools
import heapq
def minimum_distance(x, y):
    result = 0.
    
    adj = [[neighbor for neighbor in range(len(x)) if neighbor != u]  \
            for u in range(len(x))]
            
    weights = [[math.sqrt((x[neighbor] - x[u])**2 + (y[neighbor] - y[u])**2)  \
        for neighbor in range(len(x)) if neighbor != u] for u in range(len(x))]
                
    # *** Prim's algorithm ***
    # Start from a given vertex
    # repeat : add a new vertex to current tree by lightest edge
    cost = [float('Inf')] * len(x)
    cost[0] = 0
    
    processed = []
    prev = [-1] * len(x)

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
    for u in range(len(x)):
        add_task(u, cost[u])

    while pq:
        u = pop_task() 
        processed.append(u)
        if pq:
            neighbor_idx = 0
            #  for all {v , z} ∈ E :
            for neighbor in adj[u]:                
                #if z ∈ PrioQ and cost[z] > w (v , z):
                if ((neighbor not in processed) and 
                    (cost[neighbor] > weights[u][neighbor_idx])):
                    #cost[z] ← w (v , z), parent[z] ← v
                    cost[neighbor] = weights[u][neighbor_idx]
                    prev[neighbor] = u
                    #ChangePriority(PrioQ, z, cost[z])              
                    add_task(neighbor, cost[neighbor])
                neighbor_idx += 1
    
    for vertex in range(len(x)):
            result += cost[vertex]
    return result

if __name__ == '__main__':
    '''
    Given n points on a plane, connect them with segments of minimum total
    length such that there is a path between p any two points. Recall that the
    length of a segment with endpoints (x 1 , y 1 ) and (x 2 , y 2 )
    is equal to sqrt((x 1 − x 2 )**2 + (y 1 − y 2 )**2)
    
    Outputs the minimum total length of segments.
    
    Uses Prim algorithm to get Minimum Spanning Tree
    
    Good job! (Max time used: 0.13/10.00, max memory used: 9113600/536870912.)
    '''
    input = sys.stdin.read()
    data = list(map(int, input.split()))
    n = data[0]
    x = data[1::2]
    y = data[2::2]
    print("{0:.9f}".format(minimum_distance(x, y)))
