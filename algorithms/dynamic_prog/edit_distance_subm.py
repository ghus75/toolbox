# Uses python3
def edit_distance(s, t):

    D = [[j if i == 0 else 0 for j in range(len(t) + 1)]\
          for i in range(len(s) + 1)]
    for i in range(len(s) + 1):
        D[i][0] = i

    for j in range(1, len(t) + 1):
        for i in range(1, len(s) + 1):
            insertion = D[i][j - 1] + 1
            deletion = D[i - 1][j] + 1
            match = D[i - 1][j - 1]
            mismatch = D[i - 1][j - 1] + 1
            if s[i - 1] == t[j - 1]:
                D[i][j] = min(insertion, deletion, match)
            else:
                D[i][j] = min(insertion, deletion, mismatch)

    return D[-1][-1]

if __name__ == "__main__":
    '''
    Calculates edit distance between 2 strings
    ex: short , ports :
        short_
        _ports
        1 deletion (+1), 1 mismatch (+1), 3 matches (+0), 1 insertion (+1)
    
    Good job! (Max time used: 0.08/5.00, max memory used: 9662464/536870912.)
    '''

    print(edit_distance(input(), input()))
