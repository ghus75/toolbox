# python3
import numpy as np
def read_input():
#    in1 = 'lNoYhXmlwOscxnkTWjsyNJNhgvzMFbxFnbiWuBAGjZQlCRQHjTUX'
#    in2 = 'ZtonpqnFzlpvUKZrBbRlNoYhXmlwOscxnkTWjsyNJNhgvzMFbxFnbiWuBAGjZQlCRQHjTUXxtHmTxoLuMbRYsvSpxhtrlvABBlFYmndFzHypOmJyFxjHEPlNoYhXmlwOscxnkTWjsyNJNhgvzMFbxFnbiWuBAGjZQlCRQHjTUXbDiEAvtPlNoYhXmlwOscxnkTWjsyNJNhgvzMFbxFnbiWuBAGjZQlCRQHjTUXRRNoBCUMQVOlNoYhXmlwOscxnkTWjsyNJNhgvzMFbxFnbiWuBAGjZQlCRQHjTUXRLKlNoYhXmlwOscxnkTWjsyNJNhgvzMFbxFnbiWuBAGjZQlCRQHjTUXAYPDKWtVpShhclNoYhXmlwOscxnkTWjsyNJNhgvzMFbxFnbiWuBAGjZQlCRQHjTUXOJlUlNoYhXmlwOscxnkTWjsyNJNhgvzMFbxFnbiWuBAGjZQlCRQHjTUXglmlNoYhXmlwOscxnkTWjsyNJNhgvzMFbxFnbiWuBAGjZQlCRQHjTUXuaOibGlVrwghvNTgLfltIbEdBlgjelFjQkBeFrdEV'
#    return(in1, in2)
    return (input().rstrip(), input().rstrip())

def print_occurrences(output):
    print(' '.join(map(str, output)))

def get_occurrences(pattern, text): # naive
    return [i for i in range(len(text) - len(pattern) + 1) \
        if text[i:i + len(pattern)] == pattern]

def polyHash(S, _prime, x):
    '''
    Polynomial hash function (used for strings)
    '''
    _hash = 0
    for i in reversed(range(len(S))):
        _hash = (_hash*x + ord(S[i]))%_prime
    return _hash

def PrecomputeHashes(text, pattern_length, _prime, x):
    '''
    Precomputes hashes of all substrings of length pattern_length in text
    Characters are converted to int using their ASCII codes using ord
    Returns list of hashes for ea. location
    '''
    H = [0]*(len(text) - pattern_length + 1)
    S = text[len(text) - pattern_length : len(text)]
    H[len(text) - pattern_length] = polyHash(S, _prime, x)
    y = 1
    for i in range(1, pattern_length + 1):
        y = (y*x) % _prime
    
    # recurrence of hashes bet. one substring to the previous
    for i in reversed(range(len(text) - pattern_length)):
        H[i] = (x*H[i + 1] + ord(text[i]) - y*ord(text[i + pattern_length])) % _prime
    
    return H

def get_occurrences_RabinKarp(pattern, text):
    '''
    Rabin-Karp algorithm
    '''
    _prime = 1000000007
    x = np.random.randint(1, _prime) # max = _prime - 1
    result = []
    pHash = polyHash(pattern, _prime, x)
    H = PrecomputeHashes(text, len(pattern), _prime, x)
    for i in range(len(text) - len(pattern) + 1):
        if pHash != H[i]:
            continue
        if text[i:i+len(pattern)] == pattern:
            result.append(i)
    return result

if __name__ == '__main__':
    '''
    Finds location of a pattern within a string
    Uses Rabin-Karp algorihm
    
    Good job! (Max time used: 3.77/5.00, max memory used: 77524992/536870912.)
    '''
    print_occurrences(get_occurrences_RabinKarp(*read_input()))

