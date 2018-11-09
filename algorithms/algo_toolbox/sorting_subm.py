# Uses python3
import sys
import random

def partition3(a, l, r):
    #write your code here
    v = a[l]
    lt = l
    gt = r
    #for i in range(l + 1, r + 1):
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
    k = random.randint(l, r)
    a[l], a[k] = a[k], a[l]

    #use partition3
#    m = partition2(a, l, r)
#    randomized_quick_sort(a, l, m - 1);
#    randomized_quick_sort(a, m + 1, r);
    m1, m2 = partition3(a, l, r)
    randomized_quick_sort(a, l, m1 - 1)
    randomized_quick_sort(a, m2 + 1, r)

if __name__ == '__main__':
#    input = sys.stdin.read()
#    n, *a = list(map(int, input.split()))

#    a = [7,34,2,2,2,6,1,0,8,5]
#    a = [6,4,2,3,9,8,9,4,7,6,1]
#    a = [4,2,3,5,3,1,6,0,7,3]
#    a = [2, 3, 9, 2, 9]
    a = [10, 9, 8, 7, 6, 5, 4, 3, 2, 1]
    a = [5,6,3,4,4,2]
    n = len(a)

    randomized_quick_sort(a, 0, n - 1)
    for x in a:
        print(x, end=' ')
