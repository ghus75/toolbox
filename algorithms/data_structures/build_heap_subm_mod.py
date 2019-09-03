# python3

class HeapBuilder:
    def __init__(self):
        self._swaps = []
        self._data = []

    def ReadData(self):
#        self.n = int(input())
#        self._data = [int(s) for s in input().split()]
        self.n = 5
        self._data = [5, 4, 3, 2, 1]
#    self._data = [1, 2, 3, 4, 5]
    
        assert self.n == len(self._data)

    def WriteResponse(self):
        print(len(self._swaps))
        for swap in self._swaps:
            print(swap[0], swap[1])

    def SiftDown(self, i):
        maxIndex = i
        l = 2*i + 1
        if l <= self.n - 1 and self._data[l] < self._data[maxIndex]:
            maxIndex = l
        r = 2*i + 2
        if r <= self.n - 1 and self._data[r] < self._data[maxIndex]:
            maxIndex = r
        if i != maxIndex:
            self._swaps.append((i, maxIndex))
            self._data[i], self._data[maxIndex] = self._data[maxIndex], self._data[i]
            self.SiftDown(maxIndex)

    def BuildHeap(self):
    #print('building heap')
    #n = len(self._data)
        for i in reversed(range((self.n - 1)//2 + 1)):
            self.SiftDown(i)
    def GenerateSwaps(self):
        self.BuildHeap()      

    def Solve(self):
        self.ReadData()
        self.GenerateSwaps()
        self.WriteResponse()

if __name__ == '__main__':
    heap_builder = HeapBuilder()
    heap_builder.Solve()


#    # The following naive implementation just sorts 
#    # the given sequence using selection sort algorithm
#    # and saves the resulting sequence of swaps.
#    # This turns the given array into a heap, 
#    # but in the worst case gives a quadratic number of swaps.
#    #
#    # TODO: replace by a more efficient implementation
#    for i in range(len(self._data)):
#      for j in range(i + 1, len(self._data)):
#        if self._data[i] > self._data[j]:
#          self._swaps.append((i, j))
#          self._data[i], self._data[j] = self._data[j], self._data[i]
#          
#          watch_swap = self._swaps
#          watch_data = self._data
