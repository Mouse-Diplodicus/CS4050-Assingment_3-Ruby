# Assign 03 - Matthew Williams

# could be useful for Dijkstra
require 'pqueue'
# use a very large number as placeholder for infinity
INF = (2**(0.size * 8 - 2) - 1)

def adj_mat_from_file(filename)
  # Create an adj/weight matrix from a file with verts, neighbors, and weights.
  f = File.open(filename)
  n_verts = f.readline.to_i
  printf(" n_verts = %d\n", n_verts)
  adjmat = Array.new(n_verts) { Array.new(n_verts, INF) }
  (0..(n_verts - 1)).each { |i| adjmat[i][i] = 0 }
  f.each do |line|
    int_list = []
    line.split.each { |num| int_list.push(num.to_i) }
    vert = int_list.shift
    raise 'error: Invalid matrix file' unless int_list.length.even?

    n_neighbors = (int_list.length / 2).to_i
    neighbors = []
    distances = []
    (0..int_list.length).step(2) { |n| neighbors.push(int_list[n]) }
    (1..int_list.length).step(2) { |n| distances.push(int_list[n]) }
    (0..(n_neighbors - 1)).each do |i|
      adjmat[vert][neighbors[i]] = distances[i]
    end
  end
  f.close
  adjmat
end

def print_adj_mat(mat, width = 3)
  # Print an adj/weight matrix padded with spaces and with vertex names.
  res_str = '       '
  (0..(mat.length - 1)).each { |v| res_str += v.to_s.rjust(width) }
  res_str += "\n      --#{'-' * (width * mat.length)}\n"
  mat.each_with_index do |row, i|
    row_str = ''
    row.each do |elem|
      row_str += elem.to_s.rjust(width)
    end
    res_str += "   #{i.to_s.rjust(2)} |#{row_str}\n"
  end
  print(res_str)
end

def floyd(graph)
  # Carry out Floyd's algorithm using W as a weight/adj matrix.
  d = Marshal.load(Marshal.dump(graph))
  (0..(graph.length - 1)).each do |i|
    (0..(graph.length - 1)).each do |j|
      (0..(graph.length - 1)).each { |k| d[j][k] = [d[j][i] + d[i][k], d[j][k]].min }
    end
  end
  d
end

def dijkstra(graph, s_vert)
  # Carry out Dijkstra's using W as a weight/adj matrix and s_vert as starting vert.
  pq = PQueue.new { |a, b| a[0] < b[0] }
  result = Array.new(graph.length, INF)
  (0..(graph.length - 1)).each do |i|
    if i == s_vert
      pq.push([0, i])
    else
      pq.push([INF, i])
    end
  end
  until pq.top.nil?
    vert = pq.pop
    result[vert[1]] = vert[0]
    pq_arr = pq.to_a
    (0..(pq_arr.length - 1)).each do |i|
      pq_arr[i] = [[pq_arr[i][0], result[vert[1]] + graph[vert[1]][pq_arr[i][1]]].min, pq_arr[i][1]]
    end
    pq.replace(pq_arr)
  end
  result
end

def test_algorithm_times
  # Function to run tests for algorithm solving times
  time = Time.new
  f_name = "results_#{time.strftime('%m-%d-%Y_%H.%M.%S')}.csv"
  # write header to file
  File.open(f_name, 'w') do |f|
    f.write("Ruby Results\n")
    f.write("Nodes in Graph, Floyd's elapsed time, Dijkstra's elapsed time,\n")
  end
  (25..5000).step(25).each do |i|
    results = "#{i}, "
    g = adj_mat_from_file("graphs/#{i}verts.txt")
    # Run Floyd's algorithm
    starting_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    res_floyd = floyd(g)
    elapsed_time_floyd = Process.clock_gettime(Process::CLOCK_MONOTONIC) - starting_time
    results += "#{elapsed_time_floyd}, "
    # Run Dijkstra's overall starting points (note this is not the intended way
    # to utilize this algorithm, however we are using it as point of comparion).
    res_dijkstra = Array.new(g.length) { Array.new(g.length, nil) }
    starting_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    (0..(g.length - 1)).each do |sv|
      res_dijkstra[sv] = dijkstra(g, sv)
    end
    elapsed_time_dijkstra = Process.clock_gettime(Process::CLOCK_MONOTONIC) - starting_time
    results += "#{elapsed_time_dijkstra},\n"
    # Double check again that the results are the same
    error_msg = "error: dijkstra result does not match output from floyd's"
    raise error_msg unless res_floyd == res_dijkstra
    # write results to file
    File.open(f_name, 'a') do |f|
      f.write("#{results}")
    end
  end
end

# Run program
test_algorithm_times
