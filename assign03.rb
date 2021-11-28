"""
Assign 03 - Matthew Williams

Directions:
    * Complete the graph algorithm functions given below. Note that it may be
      helpful to define auxiliary/helper functions that are called from the
      functions below.  Refer to the README.md file for additional info.

    * NOTE: As with other assignments, please feel free to share ideas with
      others and to reference sources from textbooks or online. However, do your
      best to attain a reasonable grasp of the algorithm that you are
      implementing as there will very likely be questions related to it on
      quizzes/exams.

    * NOTE: Remember to add a docstring for each function, and that a reasonable
      coding style is followed (e.g. blank lines between functions).
      Your program will not pass the tests if this is not done!
"""
# could be useful for Dijkstra
require 'pqueue'

# for copying arrays

# for timing checks

# use a very large number as placeholder for infinity
INF = (2**(0.size * 8 -2) -1)


def adjMatFromFile(filename)
  """ Create an adj/weight matrix from a file with verts, neighbors, and weights. """
  f = open(filename)
  n_verts = f.readline().to_i
  printf(" n_verts = %d\n", n_verts)
  adjmat = Array.new(n_verts){Array.new(n_verts, INF)}
  (0..(n_verts - 1)).each { |i| adjmat[i][i] = 0 }
  f.each do |line|
    int_list = Array.new
    line.split().each { |num| int_list.push(num.to_i) }
    vert = int_list.shift()
    raise "error: Invalid matrix file" unless int_list.length % 2 == 0
    n_neighbors = (int_list.length / 2).to_i
    neighbors = Array.new()
    distances = Array.new()
    (0..int_list.length).step(2) { |n| neighbors.push(int_list[n]) }
    (1..int_list.length).step(2) { |n| distances.push(int_list[n]) }
    (0..(n_neighbors - 1)).each do |i|
      adjmat[vert][neighbors[i]] = distances[i]
    end
  end
  f.close()
  return adjmat
end

def printAdjMat(mat, width=3)
  """ Print an adj/weight matrix padded with spaces and with vertex names. """
  res_str = '       '
  (0..(mat.length - 1)).each { |v| res_str += v.to_s.rjust(width) }
  res_str += "\n" + '      --' + '-' * (width * mat.length) + "\n"
  mat.each_with_index do |row, i|
    row_str = ''
    row.each do |elem|
      row_str += elem.to_s.rjust(width)
    end
    res_str += '   ' + i.to_s.rjust(2) + ' |' + row_str + "\n"
  end
  print(res_str)
end

def floyd(w)
  """ Carry out Floyd's algorithm using W as a weight/adj matrix. """
  d = Marshal.load(Marshal.dump(w))
  (0..(w.length-1)).each do |i|
    (0..(w.length-1)).each do |j|
      (0..(w.length-1)).each { |k| d[j][k] = [d[j][i] + d[i][k], d[j][k]].min }
    end
  end
  return d
end


def dijkstra(w, sv)
  """ Carry out Dijkstra's using W as a weight/adj matrix and sv as starting vert. """
  pq = PQueue.new(){ |a,b| a[0] < b[0] }
  result = Array.new(w.length, INF)
  (0..(w.length - 1)).each do |i|
    if i == sv
      pq.push([0, i])
    elsif
      pq.push([INF, i])
    end
  end
  while pq.top() != nil
    vert = pq.pop
    result[vert[1]] = vert[0]
    pq_arr = pq.to_a()
    (0..(pq_arr.length - 1)).each do |i|
      pq_arr[i] = [[pq_arr[i][0], result[vert[1]] + w[vert[1]][pq_arr[i][1]]].min, pq_arr[i][1]]
    end
    pq.replace(pq_arr)
  end
  return result
end

def test_algorithm_times
  """ Function to run tests for algorithm solving times """

  results = ''
  (25..1000).step(25).each do |i|
    results += i.to_s + ', '
    g = adjMatFromFile("graphs/" + i.to_s + "verts.txt")

    # Run Floyd's algorithm
    starting_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    res_floyd = floyd(g)
    elapsed_time_floyd = Process.clock_gettime(Process::CLOCK_MONOTONIC) - starting_time
    results += elapsed_time_floyd.to_s + ', '

    # Run Dijkstra's overall starting points (note this is not the intended way
    # to utilize this algorithm, however we are using it as point of comparion).
    res_dijkstra = Array.new(g.length) { Array.new(g.length, nil) }
    starting_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    (0..(g.length - 1)).each do |sv|
      res_dijkstra[sv] = dijkstra(g, sv)
    end
    elapsed_time_dijkstra = Process.clock_gettime(Process::CLOCK_MONOTONIC) - starting_time
    results += elapsed_time_dijkstra.to_s + ', '

    # Double check again that the results are the same
    error_msg = "error: dijkstra result does not match output from floyd's"
    raise error_msg unless res_floyd == res_dijkstra
  end
  # write results to file
  f_name = 'results_' + date.today().strftime("%b-%d-%Y") + '.csv'
  File.open(f_name, "w") do |f|
    f.write("Ruby Results" + '\n')
    f.write("Nodes in Graph, Floyd's elapsed time, Dijkstra's elapsed time" + '\n')
    f.write(results + '\n')
  end
end

# Run program
test_algorithm_times