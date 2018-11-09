# Uses python3
import sys

def get_change(m):

    ones = 0
    fives = 0
    tens = 0
    if m >= 10:
        while 10*tens <= m:
            tens += 1
        tens -= 1
        m = m - 10*tens
    if m >= 5:
        while 5*fives <= m:
            fives += 1
        fives -= 1
        m = m - 5*fives
    if m >= 1:
        while 1*ones <= m:
            ones += 1
        ones -= 1
        m = m - 1*ones
    return tens + fives + ones 

if __name__ == '__main__':
    #m = sys.stdin.read()
    m = int(input())
    print(get_change(m))
    #res = get_change(89)
    #print(res)
