# Uses python3
import sys

def get_change(money):
    #write your code here
    infinity = 1.1e3 # 1 <= m <= 1e3
    coins = [1, 3, 4] # 3 kinds of coins
    MinNumCoins = [0]*(money + 1)
    
    for m in range(1, money + 1):
        MinNumCoins[m] = infinity
        for i in range(len(coins)):
            if m >= coins[i]:
                NumCoins = MinNumCoins[m - coins[i]] + 1
                if NumCoins < MinNumCoins[m]:
                    MinNumCoins[m] = NumCoins
    return MinNumCoins[m]

if __name__ == '__main__':
    '''
    The minimum number of coins with denominations 1, 3, 4 that changes m
    Good job! (Max time used: 0.03/5.00, max memory used: 9592832/536870912.)
    '''
    m = int(sys.stdin.read())

    print(get_change(m))
