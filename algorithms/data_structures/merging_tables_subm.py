# python3

'''
Good job! (Max time used: 1.10/6.00, max memory used: 158945280/536870912.)
'''
import sys

#n, m = 5, 5
#lines = [1, 1, 1, 1, 1]
#n, m = 6, 4
#lines = [10, 0, 5, 0, 3, 3]

n, m = map(int, sys.stdin.readline().split())
lines = list(map(int, sys.stdin.readline().split()))

rank = [1] * n

parent = list(range(0, n))
ans = max(lines)

def getParent(table):
    # find parent and compress path
    if table != parent[table]:
        parent[table] = getParent(parent[table])
    return parent[table]

def merge(destination, source):
    global ans
    realDestination, realSource = getParent(destination), getParent(source)

    if realDestination == realSource:
        return False

    lines_at_root = 0
    # use union by rank heuristic
    if rank[realDestination] > rank[realSource]:
        parent[realSource] = realDestination
        lines[realDestination] += lines[realSource]
        lines_at_root = lines[realDestination]
        lines[realSource] = 0
    elif rank[realDestination] == rank[realSource]:
        parent[realSource] = realDestination
        lines[realDestination] += lines[realSource]
        lines_at_root = lines[realDestination]
        lines[realSource] = 0
        rank[realDestination] += 1
    else:
        parent[realDestination] = realSource
        lines[realSource] += lines[realDestination]
        lines_at_root = lines[realSource]
        lines[realDestination] = 0
        # update ans with the new maximum table size
    
    ans = max(ans, lines_at_root)
    
    return True


#dest_test = [3, 2, 1, 5, 5]
#source_test = [5, 4, 4, 4, 3]

#dest_test = [6, 6, 5, 4]
#source_test = [6, 5, 4, 3]

for i in range(m):
    destination, source = map(int, sys.stdin.readline().split())
#    destination, source = dest_test[i], source_test[i]
    
    merge(destination - 1, source - 1)
    print(ans)
    
    
    
