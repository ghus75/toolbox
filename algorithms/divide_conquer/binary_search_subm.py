# Uses python3
import sys

def binary_search(a, x):
    left, right = 0, len(a)
    # write your code here
    if right < left:
        return left - 1
    mid = (left + right) // 2
    if x == a[mid]:
        return mid
    if (len(a) == 1) and (x != a[mid]):
        return -1
    if x < a[mid]:
        return binary_search(a[:mid], x)
    if x > a[mid]:
        return binary_search(a[mid:], x)


def linear_search(a, x):
    for i in range(len(a)):
        if a[i] == x:
            return i
    return -1

if __name__ == '__main__':
    input = sys.stdin.read()
    data = list(map(int, input.split()))
#    data = [5, 1, 5, 8, 12, 13, 5, 8, 1, 23, 1, 11]
#    data = [5, 1, 2, 3, 4, 5, 5, 1, 2, 3, 4, 5]
    n = data[0]
    m = data[n + 1]
    a = data[1 : n + 1]
    for x in data[n + 2:]:
        # replace with the call to binary_search when implemented
#        print(linear_search(a, x), end = ' ')
#        dummy = binary_search(a, x)
        print(binary_search(a, x), end = ' ')
