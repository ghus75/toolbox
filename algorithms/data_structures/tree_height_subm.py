# python3

import sys
#import threading

def compute_height(n, parents):

    # Build parent tree using dict
    #[4 -1 4 1 1]  --> {4: [0, 2], -1: [1], 1: [3, 4]}
    parent_tree = {}
    for i in range(n):
        if parents[i] in parent_tree:
            parent_tree[parents[i]].append(i)
        else: 
            parent_tree[parents[i]] = [i]

    # Breadth First traversal
    # Queue
    if parent_tree :
        nodes = [(parent_tree[-1][0], 1)] # [(root_node, height)]
        height = 1
        
    while nodes:
        node = nodes.pop(0)
        if node[0] in parent_tree:
            for child in parent_tree[node[0]]:
                # use append instead of insert (~2 times slower)
                # append child node to queue
                nodes.append((child, node[1] + 1))
                # update height if needed
                height = max(height, node[1] + 1)

    return height

def main():
    '''
    Height of d-ary tree
    ex: n = 5 nodes
        parents = [4 -1 4 1 1], -1 is root node
    Good job! (Max time used: 1.79/3.00, max memory used: 31830016/536870912.)
    '''
    n = int(input())
    parents = list(map(int, input().split()))
    
#    with open('./Programming-Assignment-1/tree_height/tests/01', 'r') as infile:
#        lines = infile.readlines()
#    n = int(lines[0])
#    parents = list(map(int, lines[1].split()))
            
    print(compute_height(n, parents))

main()

# In Python, the default limit on recursion depth is rather low,
# so raise it here for this problem. Note that to take advantage
# of bigger stack, we have to launch the computation in a new thread.

#sys.setrecursionlimit(10**7)  # max depth of recursion
#threading.stack_size(536870912)#(2**27)   # new thread will get stack of such size
#threading.Thread(target=main).start()

# *** fonctionne mais trop lent ***
#    if parent_tree :
#        nodes = [(parent_tree[-1][0], 1)] # tuple (curr_node, curr_height)
#        height = 1
#        
#    while nodes:
#        node = nodes.pop(0)
#        if node[0] in parent_tree:
#            #height += 1
#            for child in parent_tree[node[0]]:
#                nodes.insert(0, (child, node[1] + 1))
#                height = max(height, node[1] + 1)
