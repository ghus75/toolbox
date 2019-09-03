# python3

import sys, threading
sys.setrecursionlimit(10**6) # max depth of recursion
threading.stack_size(2**27)  # new thread will get stack of such size

class TreeOrders:
  def read(self):
    self.n = int(sys.stdin.readline())
#    self.n = 10#5
    self.key = [0 for i in range(self.n)]
    self.left = [0 for i in range(self.n)]
    self.right = [0 for i in range(self.n)]
    for i in range(self.n):
      [a, b, c] = map(int, sys.stdin.readline().split())
      self.key[i] = a
      self.left[i] = b
      self.right[i] = c
#    self.key = [0,10,20,30,40,50,60,70,80,90]
#    self.left = [7,-1,-1,8,3,-1,1,5,-1,-1]
#    self.right = [2,-1,6,9,-1,-1,-1,4,-1,-1]
    
  def inOrder(self):
    self.result = []
    # Finish the implementation
    # You may need to add a new recursive method to do that
    def inOrderRecursive(node):
        if self.left[node] != -1:
            inOrderRecursive(self.left[node])
        self.result.append(self.key[node])
        if self.right[node] != -1:
            inOrderRecursive(self.right[node])

    inOrderRecursive(0)            
    return self.result

  def preOrder(self):
    self.result = []
    # Finish the implementation
    # You may need to add a new recursive method to do that
    def preOrderRecursive(node):
        self.result.append(self.key[node])
        if self.left[node] != -1:
            preOrderRecursive(self.left[node])
        if self.right[node] != -1:
            preOrderRecursive(self.right[node])
    
    preOrderRecursive(0)
    return self.result

  def postOrder(self):
    self.result = []
    # Finish the implementation
    # You may need to add a new recursive method to do that
    def postOrderRecursive(node):
        if self.left[node] != -1:
            postOrderRecursive(self.left[node])
        if self.right[node] != -1:
            postOrderRecursive(self.right[node])
        self.result.append(self.key[node])
    
    postOrderRecursive(0)
    return self.result
                
    return self.result

def main():
    '''
    Depth-first traversals of a binary tree
    Good job! (Max time used: 1.95/6.00, max memory used: 120836096/536870912.)
    '''
	tree = TreeOrders()
	tree.read()
	print(" ".join(str(x) for x in tree.inOrder()))
	print(" ".join(str(x) for x in tree.preOrder()))
	print(" ".join(str(x) for x in tree.postOrder()))

#main()
threading.Thread(target=main).start()
