# Uses python3
import sys
import random

def partition3(a, l, r):
    '''
    Dijkstra's 3-way
    '''

    v = a[l] # pivot = 1st element of sub-array
    lt = l # less_than pointer
    gt = r # greater_than pointer

    i = l + 1
    while i <= gt:
        if a[i] < v:
            a[lt], a[i] = a[i], a[lt]
            lt = lt + 1
            i = i + 1
        elif a[i] > v:
            a[gt], a[i] = a[i], a[gt]
            gt = gt - 1
        elif a[i] == v:
            i = i + 1
    return lt, gt

def partition2(a, l, r):
    x = a[l]
    j = l;
    for i in range(l + 1, r + 1):
        if a[i] <= x:
            j += 1
            a[i], a[j] = a[j], a[i]
    a[l], a[j] = a[j], a[l]
    return j

def randomized_quick_sort(a, l, r):
    if l >= r:
        return
    k = random.randint(l, r) # random pivot
    a[l], a[k] = a[k], a[l]

    m1, m2 = partition3(a, l, r)
    randomized_quick_sort(a, l, m1 - 1)
    randomized_quick_sort(a, m2 + 1, r)

if __name__ == '__main__':
    '''
    quick sort algorithm so that it works fast even on sequences containing
    many equal elements
    
    uses Dijkstra's 3-way algorithm
    
    Good job! (Max time used: 0.48/5.00, max memory used: 19361792/536870912.)
    '''
    input = sys.stdin.read()
    n, *a = list(map(int, input.split()))

    randomized_quick_sort(a, 0, n - 1)
    for x in a:
        print(x, end=' ')
