# python3

class JobQueue:
    def read_data(self):
        self.num_workers, m = 2, 5#map(int, input().split())
        self.jobs = [1,2,3,4,5]#list(map(int, input().split()))

        assert m == len(self.jobs)

    def write_response(self):
        for i in range(len(self.jobs)):
          print(self.assigned_workers[i], self.start_times[i]) 

    def SiftDown(self, i):
        '''
        SiftDown procedure for a min-heap, which is a complete binary tree, 
        i.e. with last level filled from left to right
        '''
        minIndex = i
        n = len(self.thread_prio) # number of threads
        
        l = 2*i + 1
        # if left branch in tree
        if l <= n - 1:
            # if smaller start_time
            if self.thread_prio[l][1] < self.thread_prio[minIndex][1]:
                minIndex = l
            # if same start_time, choose smallest thread index
            elif self.thread_prio[l][1] == self.thread_prio[minIndex][1]:
                if self.thread_prio[l][0] < self.thread_prio[minIndex][0]:
                    minIndex = l
        
        r = 2*i + 2
        # if right branch in tree
        if r <= n - 1:
            # if smaller start_time in right branch compared to left branch
            if self.thread_prio[r][1] < self.thread_prio[minIndex][1]:
                minIndex = r
            # if same start_time, choose smallest thread index    
            elif self.thread_prio[r][1] == self.thread_prio[minIndex][1]:
                if self.thread_prio[r][0] < self.thread_prio[minIndex][0]:
                    minIndex = r
        
        if i != minIndex:
            self.thread_prio[i], self.thread_prio[minIndex] = \
                            self.thread_prio[minIndex], self.thread_prio[i]
            self.SiftDown(minIndex)


    def assign_jobs_pq(self):
        self.assigned_workers = [None] * len(self.jobs)
        self.start_times = [None] * len(self.jobs)
        
        # all thread initially start at t = 0
        self.thread_prio = [[thread, 0] for thread in range(self.num_workers)]
        
        for job_idx in range(len(self.jobs)):
            self.assigned_workers[job_idx] = self.thread_prio[0][0]
            self.start_times[job_idx] = self.thread_prio[0][1]
            self.thread_prio[0][1] += self.jobs[job_idx]
            self.SiftDown(0)
          
    def solve(self):
        self.read_data()
        self.assign_jobs_pq()
        self.write_response()

if __name__ == '__main__':
    '''
    Parallel processing
    Input : number of threads n, number of jobs m, 
            submission time for each of m jobs jobs[]
    Output : m lines : thread_index start_time
    
    Implementation using min heap (chooses smallest thread index in case of tie)
    
    Good job! (Max time used: 2.86/6.00, max memory used: 36257792/536870912.)
    '''
    job_queue = JobQueue()
    job_queue.solve()



#    def assign_jobs(self):
#        # TODO: replace this code with a faster algorithm.
#        self.assigned_workers = [None] * len(self.jobs)
#        self.start_times = [None] * len(self.jobs)
#        next_free_time = [0] * self.num_workers
#        for i in range(len(self.jobs)):
#          next_worker = 0
#          for j in range(self.num_workers):
#            if next_free_time[j] < next_free_time[next_worker]:
#              next_worker = j
#          self.assigned_workers[i] = next_worker
#          self.start_times[i] = next_free_time[next_worker]
#          next_free_time[next_worker] += self.jobs[i]
