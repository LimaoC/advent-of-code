using Pkg; Pkg.activate(".")
using AdventOfCode
using DataStructures

"""https://adventofcode.com/2022/day/1"""
function one(; input::String = "2022/day1_input.txt")
    data = intvec2(input)
    sums = map(v -> sum(v), data)
    sort!(sums)
    println(sums[end])
    println(sum(sums[end-2:end]))
end

"""https://adventofcode.com/2022/day/2"""
function two(; input::String = "2022/day2_input.txt")
    data = strvec(input)
    d1 = Dict(  # shape + outcome
        "A X" => 1 + 3, "A Y" => 2 + 6, "A Z" => 3 + 0,
        "B X" => 1 + 0, "B Y" => 2 + 3, "B Z" => 3 + 6,
        "C X" => 1 + 6, "C Y" => 2 + 0, "C Z" => 3 + 3
    )
    d2 = Dict(
        "A X" => 3 + 0, "A Y" => 1 + 3, "A Z" => 2 + 6,
        "B X" => 1 + 0, "B Y" => 2 + 3, "B Z" => 3 + 6,
        "C X" => 2 + 0, "C Y" => 3 + 3, "C Z" => 1 + 6
    )
    println(sum([d1[x] for x in data]))
    println(sum([d2[x] for x in data]))
end

"""https://adventofcode.com/2022/day/3"""
function three(; input::String = "2022/day3_input.txt")
    data = strvec(input)
    data2 = map(n -> data[n:n+2], 1:3:length(data))
    priority(chr) = isuppercase(chr) ? Int(chr) - 38 : Int(chr) - 96
    println(sum([priority(intersect(splitequal(line, 2)...)[1]) for line in data]))
    println(sum([priority(intersect(grp...)[1]) for grp in data2]))
end

"""https://adventofcode.com/2022/day/4"""
function four(; input::String = "2022/day4_input.txt")
    data = strvec(input)
    rcontains(f1, f2, s1, s2) = (f1 in s1:s2 && f2 in s1:s2) || (s1 in f1:f2 && s2 in f1:f2)
    roverlaps(f1, f2, s1, s2) = (f1 in s1:s2 || f2 in s1:s2) || (s1 in f1:f2 || s1 in f1:f2)
    println(sum([rcontains(parse.(Int64, split(line, [',', '-']))...) for line in data]))
    println(sum([roverlaps(parse.(Int64, split(line, [',', '-']))...) for line in data]))
end

"""https://adventofcode.com/2022/day/5"""
function five(; input::String = "2022/day5_input.txt")
    # parse input
    data = strvec(input)
    n = findfirst(line -> startswith(line, "move"), data)
    crate_range = 2:4:length(data[1])
    crates1 = [[] for _ in 1:length(crate_range)]
    for crate in data[1:n-2]
        for (i, chr) in enumerate(crate[crate_range])
            chr != ' ' && pushfirst!(crates1[i], chr)
        end
    end
    crates2 = deepcopy(crates1)  # for part 2

    # move crates
    for move in data[n:end]
        _, repetitions, _, src, _, dest = tryparse.(Int, split(move, " "))
        # need to push all crates at once for part 2, we'll use a temporary vector for this
        temp = []
        for _ in 1:repetitions
            push!(crates1[dest], pop!(crates1[src]))
            pushfirst!(temp, pop!(crates2[src]))
        end
        push!(crates2[dest], temp...)
    end
    println(join([stack[end] for stack in crates1]))
    println(join([stack[end] for stack in crates2]))
end

"""https://adventofcode.com/2022/day/6"""
function six(; input::String = "2022/day6_input.txt")
    data = strsingle(input)
    is_unique(s) = length(unique(s)) == length(s)
    offsets = [3, 13]  # offsets for parts 1 and 2; message length - 1
    for offset in offsets
        i = 1
        while !is_unique(data[i:i+offset]); i += 1; end
        println(i+offset)
    end
end

"""https://adventofcode.com/2022/day/7"""
function seven(; input::String = "2022/day7_input.txt")
    data = strvec(input, "\$ ")
    current_dir = root = [0, Dict()]  # size, contents
    current_path = Vector{String}()
    for cmd in data
        lines = split(cmd, "\n", keepempty=false)
        if lines[1] == "ls"
            for output in lines[2:end]
                type, name = split(output, " ", keepempty=false)
                if type == "dir"  # directory; create if it doesn't exist
                    if !get(current_dir[2], name, false)
                        current_dir[2][name] = [0, Dict()]
                    end
                else  # file; update sizes for current + all parent directories
                    size = parse(Int64, type)
                    temp_dir = root
                    temp_dir[1] += size
                    for path in current_path
                        temp_dir = temp_dir[2][path]
                        temp_dir[1] += size
                    end
                end
            end
        else  # cd
            dest = split(lines[1], " ")[end]
            if dest == "/"  # travel to root
                current_dir = root
            elseif dest == ".."  # travel from root down current path
                pop!(current_path)
                current_dir = root
                for path in current_path
                    current_dir = current_dir[2][path]
                end
            else  # directory is in current directory, travel down
                push!(current_path, dest)
                current_dir = current_dir[2][dest]
            end
        end
    end

    function calc_sizes(dir)
        # part 1, calculate sum of file sizes that are at most 100,000
        size = dir[1] <= 100_000 ? dir[1] : 0
        for (_, subdir) in dir[2]
            size += calc_sizes(subdir)
        end
        return size
    end
    function find_dirs(dir)
        # part 2, find dirs that can be deleted to free up the required space
        dirs = []
        dir[1] >= 30_000_000 - (70_000_000 - root[1]) && push!(dirs, dir[1])
        for (_, subdir) in dir[2]
            push!(dirs, find_dirs(subdir)...)
        end
        return dirs
    end

    println(calc_sizes(root))
    println(minimum(find_dirs(root)))
end

"""https://adventofcode.com/2022/day/8"""
function eight(; input::String = "2022/day8_input.txt")
    data = intmatrix(input)

    function is_visible(row::Int64, col::Int64)  # part 1
        rowv, colv = data[row, :], data[:, col]
        dirs = (colv[begin:row-1], colv[row+1:end], rowv[begin:col-1], rowv[col+1:end])
        return any(map(dir -> all(data[row, col] .> dir), dirs))
    end
    function scenic_score(row::Int64, col::Int64)  # part 2
        scores = [0, 0, 0, 0]
        rowv, colv = data[row, :], data[:, col]
        dirs = (
            reverse(colv[begin:row-1]), colv[row+1:end],
            reverse(rowv[begin:col-1]), rowv[col+1:end]
        )
        for (index, dir) in enumerate(dirs)
            for tree in dir
                scores[index] += 1
                tree >= data[row, col] && break
            end
        end
        return prod(scores)
    end

    dim = size(data)[1]
    data = view(data, 1:dim, 1:dim)  # to use Cartesian indexing instead of linear indexing
    println(sum([is_visible(i[1], i[2]) for i in eachindex(data)]))
    println(maximum([scenic_score(i[1], i[2]) for i in eachindex(data)]))
end

"""https://adventofcode.com/2022/day/9"""
function nine(; input::String = "2022/day9_input.txt")
    data = strvec(input)
    UP, DOWN, LEFT, RIGHT = (0, 1), (0, -1), (-1, 0), (1, 0)
    NE, SE, SW, NW = (1, 1), (1, -1), (-1, -1), (-1, 1)

    function is_touching(n1::Tuple{Int64, Int64}, n2::Tuple{Int64, Int64})
        dist = abs(n1[1] - n2[1]) + abs(n1[2] - n2[2])
        dist <= 1 && return true
        dist == 2 && return n1[1] != n2[1] && n1[2] != n2[2]
    end
    function move_delta(direction::SubString)
        direction == "U" && return UP
        direction == "D" && return DOWN
        direction == "L" && return LEFT
        direction == "R" && return RIGHT
    end
    function move(n1::Tuple{Int64, Int64}, n2::Tuple{Int64, Int64})
        if n1[1] == n2[1] || n1[2] == n2[2]
            directions = [UP, DOWN, LEFT, RIGHT]
        else
            directions = [NE, SE, SW, NW]
        end
        for direction in directions
            is_touching(n1, n2 .+ direction) && return n2 .+ direction
        end
    end
    function num_tiles_visited(num_nodes::Int64)
        visited = Set([(0, 0)])
        nodes = [(0, 0) for _ in 1:num_nodes]
        for cmd in data
            direction, units = split(cmd, " ")
            direction = move_delta(direction)
            units = parse(Int64, units)
            for _ in 1:units
                nodes[begin] = nodes[begin] .+ direction  # move head
                prev = nodes[begin]
                for i in 2:num_nodes
                    # move rest of rope nodes if needed
                    if !is_touching(prev, nodes[i])
                        nodes[i] = move(prev, nodes[i])
                        i == num_nodes && push!(visited, nodes[i])  # track where tail goes
                    end
                    prev = nodes[i]
                end
            end
        end
        return length(visited)
    end

    println(num_tiles_visited(2))
    println(num_tiles_visited(10))
end

"""https://adventofcode.com/2022/day/10"""
function ten(; input::String = "2022/day10_input.txt")
    data = strvec(input)
    x = cycle = 1
    signal_strengths = []  # part 1
    crt = mapreduce(permutedims, vcat, [[' ' for _ in 1:40] for _ in 1:6])  # part 2

    function update_cycle()
        # part 1:
        cycle in [20, 60, 100, 140, 180, 220] && push!(signal_strengths, x * cycle)
        # part 2:
        (cycle-1) % 40 in x-1:x+1 && (crt[(cycle ÷ 40) + 1, (cycle-1) % 40 + 1] = '#')
        cycle += 1
    end

    for cmd in data
        args = split(cmd, " ")
        if args[1] == "noop"
            update_cycle()
        elseif args[1] == "addx"
            update_cycle()
            update_cycle()
            x += parse(Int64, args[2])
        end
    end

    println(sum(signal_strengths))
    println([join(line, " ") * "\n" for line in eachrow(crt)]...)
end

"""https://adventofcode.com/2022/day/11"""
function eleven(; input::String = "2022/day11_input.txt")
    # parse input
    data = strvec(input)
    function init_state()
        items, ops, tests, modulos = [], [], [], []
        for i in 1:6:length(data)
            push!(items, parse.(Int64, split(data[i+1], [':', ','])[begin+1:end]))
            op_str = split(data[i+2], '=')[end]
            op = '*' in op_str ? (*) : (+)
            val = split(op_str)[end]
            push!(ops, x -> op(x, val == "old" ? x : parse(Int64, val)))
            divisor = parse(Int64, split(data[i+3])[end])
            true_monkey = parse(Int64, split(data[i+4])[end])
            false_monkey = parse(Int64, split(data[i+5])[end])
            push!(tests, x -> (x % divisor == 0) ? true_monkey : false_monkey)
            push!(modulos, divisor)  # part 2
        end
        return items, ops, tests, modulos
    end

    # simulate
    function simulate(items, ops, tests, num_simulations, reduce_worry_fn)
        num_mnkys = length(data) ÷ 6
        times_inspected = zeros(Int64, num_mnkys)
        for _ in 1:num_simulations
            for mnky in 1:num_mnkys
                for i in 1:length(items[mnky])
                    times_inspected[mnky] += 1
                    items[mnky][i] = ops[mnky](items[mnky][i]) |> reduce_worry_fn
                    next_mnky = tests[mnky](items[mnky][i]) + 1
                    push!(items[next_mnky], items[mnky][i])
                end
                items[mnky] = []
            end
        end
        return times_inspected
    end

    # part 1
    items, ops, tests, _ = init_state()
    times_inspected = simulate(items, ops, tests, 20, x -> x ÷ 3)
    sort!(times_inspected)
    println(times_inspected[end] * times_inspected[end-1])
    # part 2
    items, ops, tests, modulos = init_state()
    times_inspected = simulate(items, ops, tests, 10_000, x -> x % prod(modulos))
    sort!(times_inspected)
    println(times_inspected[end] * times_inspected[end-1])

end

"""https://adventofcode.com/2022/day/12"""
function twelve(; input::String = "2022/day12_input.txt")
    data = chrmatrix(input)
    start, exit = findfirst(==('S'), data).I, findfirst(==('E'), data).I
    elevation(chr) = chr == 'S' ? 1 : (chr == 'E' ? 26 : Int(chr) - 96)
    nrow, ncol = size(data)[1], size(data)[2]
    # bfs to search through whole map
    q = Queue{Tuple{Int64, Tuple{Int64, Int64}}}()
    enqueue!(q, (0, exit))
    visited = [exit]
    least_steps_to_start = typemax(Int64)  # part 1
    least_steps_to_a = []  # part 2
    while !isempty(q)
        steps, x = dequeue!(q)
        steps += 1
        for p in [x .+ (0, 1), x .+ (0, -1), x .+ (-1, 0), x .+ (1, 0)]
            !(p[1] in 1:nrow && p[2] in 1:ncol) && continue
            if elevation(data[x...]) - elevation(data[p...]) <= 1
                if p == start && least_steps_to_start > steps
                    least_steps_to_start = steps
                elseif !(p in visited)
                    enqueue!(q, (steps, p))
                    push!(visited, p)
                end
                elevation(data[p...]) == 1 && push!(least_steps_to_a, steps)
            end
        end
    end
    println(least_steps_to_start)
    println(minimum(least_steps_to_a))
end

"""https://adventofcode.com/2022/day/13"""
function thirteen(; input::String = "2022/day13_input.txt")
    function conv(str)  # convert string -> list
        splits = [1, length(str)]
        elements = []
        lvl = 0
        for (i, chr) in enumerate(str)
            chr == '[' && (lvl += 1)
            chr == ']' && (lvl -= 1)
            chr == ',' && lvl == 1 && insert!(splits, length(splits), i)
        end
        if length(splits) == 2
            str == "[]" && return Vector{Int64}()
            startswith(str, '[') && return [conv(str[begin+1:end-1])]
            return parse(Int64, str)
        end
        for i in 1:length(splits)-1
            substr = str[splits[i]+1:splits[i+1]-1]
            if startswith(substr, '[')
                push!(elements, conv(substr))
            elseif length(substr) > 0
                push!(elements, parse(Int64, substr))
            end
        end
        return elements
    end
    function comp(arr1, arr2)
        for (i, e1) in enumerate(arr1)
            length(arr2) < i && return false  # arr2 ran out
            e2 = arr2[i]
            if e1 isa Int64 && e2 isa Int64
                e1 < e2 && return true
                e1 > e2 && return false
            elseif e1 isa Int64 || e2 isa Int64
                e1 isa Int64 && (e1 = [e1])
                e2 isa Int64 && (e2 = [e2])
            end
            if e1 isa Vector && e2 isa Vector
                e1 == e2 && continue
                return comp(e1, e2)
            end
        end
        return true
    end

    data = strvec2(input)
    data2 = strvec(input)
    dividers = ["[[2]]", "[[6]]"]
    push!(data2, dividers...)
    sort!(data2, by=conv, lt=comp)

    println(sum([i for (i, ln) in enumerate(data) if comp(conv(ln[1]), conv(ln[2]))]))
    println(prod([findfirst(==(d), data2) for d in dividers]))
end

"""https://adventofcode.com/2022/day/14"""
function fourteen(; input::String = "2022/day14_input.txt")
    data = strvec(input)
    rockpaths = []
    for ln in data
        push!(rockpaths, map(e -> parse.(Int64, e), split.(split(ln, " -> "), ",")))
    end
    # make x range (xmax - xmin) larger for part 2; x range > 2 * y range should be enough
    ymax = maximum(map(rp -> maximum(map(e -> e[2], rp)), rockpaths))  # ymin = 0
    xmin = minimum(map(rp -> minimum(map(e -> e[1], rp)), rockpaths)) - ymax
    xmax = maximum(map(rp -> maximum(map(e -> e[1], rp)), rockpaths)) + ymax
    num_sand = 0
    in_range(p) = p[1] in 1:ymax+1 && p[2] in 1:xmax-xmin+1

    function place_rockpath(cave, rockpath::Vector{Vector{Int64}})
        # index cave with cave[y, x]
        for i in 1:length(rockpath)-1
            first, second = rockpath[i:i+1]
            fx, fy = first[1]-xmin+1, first[2]+1
            sx, sy = second[1]-xmin+1, second[2]+1
            fx == sx && (cave[fy < sy ? (fy:sy) : (sy:fy), fx] .= '#')
            fy == fy && (cave[fy, fx < sx ? (fx:sx) : (sx:fx)] .= '#')
        end
    end
    function place_sand(cave, p::Tuple{Int64, Int64})
        below, dleft, dright = map(delta -> p .+ delta, [(1, 0), (1, -1), (1, 1)])
        b_valid, dl_valid, dr_valid = in_range.((below, dleft, dright))
        if (!b_valid || (!b_valid && !dl_valid) || (!b_valid && !dl_valid && !dr_valid))
            return false
        end
        cave[below...] == '.' && return place_sand(cave, below)
        cave[dleft...] == '.' && return place_sand(cave, dleft)
        cave[dright...] == '.' && return place_sand(cave, dright)
        cave[p...] = 'o'
        num_sand += 1
        return true
    end

    top = (1, 500-xmin+1)
    # part 1
    cave = ['.' for _ in 1:ymax+1, _ in 1:xmax-xmin+1]
    for rockpath in rockpaths
        place_rockpath(cave, rockpath)
    end
    while place_sand(cave, top) end
    println(num_sand)
    # part 2
    ymax += 2
    num_sand = 0
    cave = ['.' for _ in 1:ymax+1, _ in 1:xmax-xmin+1]
    for rockpath in rockpaths
        place_rockpath(cave, rockpath)
    end
    place_rockpath(cave, [[xmin, ymax], [xmax, ymax]])
    while cave[top...] != 'o'
        place_sand(cave, top)
    end
    println(num_sand)
end

function fifteen(; input::String = "2022/day15_input.txt")
    # parse input
    data = strvec(input)
    sensors = Vector{Tuple{Int64, Int64}}()
    beacons = Vector{Tuple{Int64, Int64}}()
    for line in data
        sstr, bstr = split(line, ": ")
        sx = parse(Int64, split(sstr, [',', ' '], keepempty=false)[end-1][begin+2:end])
        sy = parse(Int64, split(sstr, [',', ' '], keepempty=false)[end][begin+2:end])
        bx = parse(Int64, split(bstr, [',', ' '], keepempty=false)[end-1][begin+2:end])
        by = parse(Int64, split(bstr, [',', ' '], keepempty=false)[end][begin+2:end])
        push!(sensors, (sy, sx))
        push!(beacons, (by, bx))
    end

    dist(p1, p2) = abs(p1[1] - p2[1]) + abs(p1[2] - p2[2])
    function pts_within_dist(pt::Tuple{Int64, Int64}, d::Int64, filter_y)
        # get all pts within distance `d` away from `pt` at y level `filter_y`
        pts = Vector{Tuple{Int64, Int64}}()
        for x in -d:d
            new_pt = (filter_y, x)
            dist(pt, new_pt) <= d && push!(pts, new_pt)
        end
        return pts
    end
    function pts_at_dist(pt::Tuple{Int64, Int64}, d::Int64)
        # get all pts at distance `d` away from `pt`
        pts = Vector{Tuple{Int64, Int64}}()
        x, y = 0, d
        while x <= d
            push!(pts, pt .+ (y, x), pt .- (y, x))
            x += 1
            y -= 1
        end
        return pts
    end

    # part 1
    invalid_pts = Vector{Tuple{Int64, Int64}}()
    # part 2; for each beacon, get all pts 1 dist away from distance to closest sensor
    candidate_pts = Vector{Tuple{Int64, Int64}}()
    in_range(pt) = pt[1] in 0:4_000_000 && pt[2] in 0:4_000_000
    # main loop
    occupied_pts = [sensors; beacons]
    for i in 1:length(sensors)
        sensor, beacon = sensors[i], beacons[i]
        d = dist(sensor, beacon)
        # part 1
        pts = pts_within_dist(sensor, d, 2_000_000)
        push!(invalid_pts, filter(pt -> !(pt in occupied_pts), pts)...)
        # part 2
        pts = pts_at_dist(sensor, d+1)
        push!(candidate_pts, filter(pt -> !(pt in occupied_pts) && in_range(pt), pts)...)
    end
    println(length(unique(invalid_pts)))  # part 1
    for pt in unique(candidate_pts)  # part 2
        num_sensors = length(sensors)
        if all([dist(sensors[i], pt) > dist(sensors[i], beacons[i]) for i in 1:num_sensors])
            println(pt[2] * 4_000_000 + pt[1])
            break  # there should only be one soln
        end
    end
end

fifteen()
