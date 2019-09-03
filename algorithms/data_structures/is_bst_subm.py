#!/usr/bin/python3

import sys, threading

sys.setrecursionlimit(10**7) # max depth of recursion
threading.stack_size(2**30)  # new thread will get stack of such size

def IsBinarySearchTree(tree):
  # Implement correct algorithm here
    n = len(tree)
    if n == 0:
        return True
#    self.n = 10#5
    key = [0 for i in range(n)]
    left = [0 for i in range(n)]
    right = [0 for i in range(n)]
    for i in range(n):
          [a, b, c] = tree[i]#map(int, sys.stdin.readline().split())
          key[i] = a
          left[i] = b
          right[i] = c

    result = []
  
    def inOrderRecursive(node):
        if left[node] != -1:
            inOrderRecursive(left[node])
        result.append(key[node])
        if right[node] != -1:
            inOrderRecursive(right[node])

    inOrderRecursive(0)            
    
    return True if (result == sorted(key) and bst_flag) else False

def main():
    '''
    Check if binary search tree
    Good job! (Max time used: 0.73/10.00, max memory used: 139227136/536870912.)
    ''''
    nodes = int(sys.stdin.readline().strip())
    tree = []
    for i in range(nodes):
        tree.append(list(map(int, sys.stdin.readline().strip().split())))

#    tree = [[2,1,2], [1,-1,-1], [3,-1,-1]] #[[key, left, right], ...]
#    tree = [[1,1,2], [2, -1, -1], [3, -1, -1]]
#    tree = [[4,1,2],[2,3,4],[6,5,6],[1, -1, -1],[3, -1, -1],[5, -1, -1],[7, -1, -1]]
    if IsBinarySearchTree(tree):
        print("CORRECT")
    else:
        print("INCORRECT")

#main()
threading.Thread(target=main).start()

