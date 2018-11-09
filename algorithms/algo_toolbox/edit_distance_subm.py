# Uses python3
def edit_distance(s, t):
    #write your code here
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
    print(edit_distance(input(), input()))
 #   print(edit_distance('short', 'ports'))
 #   print(edit_distance('editing', 'distance'))