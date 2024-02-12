Common algorithms in python for traversing and generating graphs


data is input as follows:

      input = sys.stdin.read()
      data = list(map(int, input.split()))
      n, m = data[0:2] # number of vertices, number of edges
      data = data[2:]  # each line contains: vertex1 vertex2 [weight]

All algorithms are from Coursera's Algorithms on graphs course (UC San Diego) and their time and space complexities were tested using the grader
