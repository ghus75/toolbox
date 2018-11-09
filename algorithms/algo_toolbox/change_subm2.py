# Uses python3
import sys

def get_change(m):

    ones = 0
    fives = 0
    tens = 0
    if m >= 10:
        while True:
            if 10*tens < 10 *( m//10):
                tens += 1
            else:
                #tens -= 1
                break
        #tens -= 1
        m = m - 10*tens
    
    if m >= 5:
        while True:
            if 5*fives < 5 * (m//5):
                fives += 1
            else:
                #fives -= 1
                break
        #fives -= 1
        m = m - 5*fives
    
    if m >= 1:
        while True:
            if 1*ones < m:
                ones += 1
            else:
                #ones -= 1
                break
        #ones -= 1
        m = m - 1*ones
    return tens + fives + ones 

if __name__ == '__main__':
    #m = sys.stdin.read()
    m = int(input())
    print(get_change(m))
    #res = get_change(28)
    #print(res)
