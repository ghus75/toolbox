# python3
import heapq

class JobQueue:
    def read_data(self):
        self.num_workers, m = map(int, input().split())
        self.jobs = list(map(int, input().split()))

        assert m == len(self.jobs)

    def write_response(self):
        for i in range(len(self.jobs)):
          print(self.assigned_workers[i], self.start_times[i]) 

    def assign_jobs_pq(self):
        self.assigned_workers = [None] * len(self.jobs)
        self.start_times = [None] * len(self.jobs)
        # all thread initially start at t = 0
        self.thread_prio = [[0, thread] for thread in range(self.num_workers)]

        heapq.heapify(self.thread_prio)

        for job_idx in range(len(self.jobs)):
            # pop highest priority item from heap, assign to thread and time
            avail_item = heapq.heappop(self.thread_prio)
            self.assigned_workers[job_idx] = avail_item[1]
            self.start_times[job_idx] = avail_item[0]
            # update item with begining time of next job and put back into heap
            avail_item[0] += self.jobs[job_idx]
            heapq.heappush(self.thread_prio, avail_item) 
          
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
    
    Implementation using python's built-in heapq

    Good job! (Max time used: 0.48/6.00, max memory used: 36274176/536870912.)    
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
