# python3

class Query:

    def __init__(self, query):
        self.type = query[0]
        if self.type == 'check':
            self.ind = int(query[1])
        else:
            self.s = query[1]


class QueryProcessor:
    _multiplier = 263
    _prime = 1000000007

    def __init__(self, bucket_count):
        self.bucket_count = bucket_count
        # store all strings in one list
        self.elems = [[]]*bucket_count

    def _hash_func(self, s):
        ans = 0
        for c in reversed(s):
            ans = (ans * self._multiplier + ord(c)) % self._prime
        return ans % self.bucket_count

    def write_search_result(self, was_found):
        print('yes' if was_found else 'no')

    def write_chain(self, chain):
        print(' '.join(chain))

    def read_query(self):
        return Query(input().split())

    def process_query(self, query):
        if query.type == "check":
            # use reverse order, because we append strings to the end
            if self.elems[query.ind]:
                print(' '.join(c for c in reversed(self.elems[query.ind])))
            else:
                print()
        
        else:
            h = self._hash_func(query.s)
            
            if query.type == "add":
                if not self.elems[h]: #if empty list
                    self.elems[h] = [query.s]
                elif query.s not in self.elems[h]:
                    self.elems[h].append(query.s)
            
            elif query.type == "del":
                if query.s in self.elems[h]:
                    self.elems[h].pop(self.elems[h].index(query.s))
            
            else: # query_type == "find"
                was_found = 1 if query.s in self.elems[h] else 0
                self.write_search_result(was_found)
        

    def process_queries(self):
#        n = 12
#        query_list = ['add world', 'add HellO', 'check 4', 'find World', \
#                      'find world', 'del world', 'check 4', 'del HellO', \
#                      'add luck', 'add GooD', 'check 2', 'del good']

        n = int(input()) # 2nd line number of queries
        for i in range(n):
            self.process_query(self.read_query())

if __name__ == '__main__':

    '''
    Implements chaining scheme : list of hash_numbers
    elems[hash_number] = ['string1', 'string2', ...]
    
    Good job! (Max time used: 2.32/7.00, max memory used: 26480640/536870912.)
    '''
    bucket_count = int(input()) #5
    proc = QueryProcessor(bucket_count)
    proc.process_queries()

