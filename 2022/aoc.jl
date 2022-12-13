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
    priority(chr) = isuppercase(chr) ? Int(chr) - 38 : Int(chr) - 96
    total1 = 0
    for line in data
        first, second = splitequal(line, 2)
        total1 += priority(intersect(first, second)[1])
    end
    data = map(n -> (data[n], data[n+1], data[n+2]), 1:3:length(data))
    total2 = 0
    for (first, second, third) in data
        total2 += priority(intersect(first, second, third)[1])
    end
    println(total1)
    println(total2)
end

"""https://adventofcode.com/2022/day/4"""
function four(; input::String = "2022/day4_input.txt")
    data = strvec(input)
    count1 = count2 = 0
    for line in data
        first, second = split(line, ',')
        f1, f2 = parse.(Int, split(first, '-'))
        s1, s2 = parse.(Int, split(second, '-'))
        # check either range fully contains the other
        ((f1 in s1:s2 && f2 in s1:s2) || (s1 in f1:f2 && s2 in f1:f2)) && (count1 += 1)
        # check either range overlaps
        ((f1 in s1:s2 || f2 in s1:s2) || (s1 in f1:f2 || s2 in f1:f2)) && (count2 += 1)
    end
    println(count1)
    println(count2)
end

"""https://adventofcode.com/2022/day/5"""
function five(; input::String = "2022/day5_input.txt")
    # parse input
    data = strvec(input)
    n = findfirst(line -> startswith(line, "move"), data)
    crate_data = data[1:n-2]
    crate_range = 2:4:length(data[1])
    crates1 = [[] for _ in 1:length(crate_range)]
    crates2 = [[] for _ in 1:length(crate_range)]
    for crate in crate_data
        for (index, chr) in enumerate(crate[crate_range])
            chr != ' ' && (pushfirst!(crates1[index], chr); pushfirst!(crates2[index], chr))
        end
    end
    # move crates
    for move in data[n:end]
        _, repetitions, _, src, _, dest = tryparse.(Int, split(move, " "))
        # part 1
        for _ in 1:repetitions
            push!(crates1[dest], pop!(crates1[src]))
        end
        # part 2
        temp = []
        for _ in 1:repetitions
            pushfirst!(temp, pop!(crates2[src]))
        end
        push!(crates2[dest], temp...)
    end
    print(join([stack[end] for stack in crates1]))
    println()
    print(join([stack[end] for stack in crates2]))
    println()
end

"""https://adventofcode.com/2022/day/6"""
function six(; input::String = "2022/day6_input.txt")
    data = strsingle(input)
    is_unique(s) = length(unique(s)) == length(s)
    offsets = (3, 13)  # message length - 1
    for offset in offsets
        for index in 1:length(data)-offset
            if is_unique(data[index:index+offset])
                println(index + offset)
                break
            end
        end
    end
end

"""https://adventofcode.com/2022/day/7"""
function seven(; input::String = "2022/day7_input.txt")
    data = strvec(input, "\$ ")
    root = [0, Dict()]
    current_path = []
    current_dir = root
    for cmd in data
        lines = split(cmd, "\n", keepempty=false)
        if lines[1] == "ls"
            for output in lines[2:end]
                type, name = split(output, " ", keepempty=false)
                if type == "dir"  # directory
                    if !get(current_dir[2], name, false)
                        # create directory
                        current_dir[2][name] = [0, Dict()]
                    end
                else  # file
                    size = parse(Int64, type)
                    temp_dir = root
                    temp_dir[1] += size
                    for path in current_path
                        temp_dir = temp_dir[2][path]
                        temp_dir[1] += size
                    end
                end
            end
        elseif startswith(lines[1], "cd")
            dest = split(lines[1], " ")[end]
            if dest == "/"
                current_dir = root
            elseif dest == ".."
                pop!(current_path)
                current_dir = root
                for path in current_path
                    current_dir = current_dir[2][path]
                end
            else
                push!(current_path, dest)
                current_dir = current_dir[2][dest]
            end
        end
    end

    function calc_sizes(dir)
        # part 1, calculate sum of file sizes that are at most 100,000
        size = 0
        if dir[1] <= 100000
            size += dir[1]
        end
        for (_, subdir) in dir[2]
            size += calc_sizes(subdir)
        end
        return size
    end

    dirs = []  # all dirs that are eligible in part 2
    function find_dir(dir)
        # part 2, find smallest dir that can be deleted to free up
        # 30,000,000 - (70,000,000 - root[1]) space
        if dir[1] >= 30000000 - (70000000 - root[1])
            push!(dirs, dir[1])
        end
        for (_, subdir) in dir[2]
            find_dir(subdir)
        end
    end

    println(calc_sizes(root))
    find_dir(root)
    println(minimum(dirs))
end

"""https://adventofcode.com/2022/day/8"""
function eight(; input::String = "2022/day8_input.txt")
    data = intmatrix(input)

    function is_visible(row, col)  # part 1
        rowv, colv = data[row, :], data[:, col]
        dirs = (colv[begin:row-1], colv[row+1:end], rowv[begin:col-1], rowv[col+1:end])
        return any(map(dir -> all(data[row, col] .> dir), dirs))
    end

    function scenic_score(row, col)  # part 2
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

    # part 1
    visited1 = Set([(0, 0)])
    nodes1 = [(0, 0), (0, 0)]
    # part 2
    visited2 = Set([(0, 0)])
    nodes2 = [(0, 0) for _ in 1:10]
    for cmd in data
        direction, units = split(cmd, " ")
        direction = move_delta(direction)
        units = parse(Int64, units)
        for _ in 1:units
            # part 1
            nodes1[1] = nodes1[1] .+ direction
            if !is_touching(nodes1[1], nodes1[2])
                nodes1[2] = move(nodes1[1], nodes1[2])
                push!(visited1, nodes1[2])
            end

            # part 2
            nodes2[1] = nodes2[1] .+ direction
            prev = nodes2[1]
            for i in 2:10
                if !is_touching(prev, nodes2[i])
                    nodes2[i] = move(prev, nodes2[i])
                    i == 10 && push!(visited2, nodes2[i])
                end
                prev = nodes2[i]
            end
        end
    end
    println(length(visited1))
    println(length(visited2))
end

"""https://adventofcode.com/2022/day/10"""
function ten(; input::String = "2022/day10_input.txt")
    data = strvec(input)
    function update_cycle()
        # part 1:
        cycle in [20, 60, 100, 140, 180, 220] && push!(signal_strengths, x * cycle)
        # part 2:
        (cycle-1) % 40 in x-1:x+1 && (crt[(cycle ÷ 40) + 1, (cycle-1) % 40 + 1] = '#')
        cycle += 1
    end
    x = cycle = 1
    signal_strengths = []  # part 1
    crt = mapreduce(permutedims, vcat, [[' ' for _ in 1:40] for _ in 1:6])  # part 2
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
    function initial_state()
        items = []
        operations = []
        tests = []
        modulos = []
        for i in 1:6:length(data)
            itms = split(data[i+1][findfirst(':', data[i+1])+2:end], ", ")
            push!(items, parse.(Int64, itms))
            ops = data[i+2][findfirst(':', data[i+2])+2:end]
            value = ops[findlast(' ', ops)+1:end]
            push!(operations,  # absolutely cursed, but it works
                x -> ('*' in ops ? (*) : (+))(x, value == "old" ? x : parse(Int64, value))
            )
            div = parse(Int64, data[i+3][findlast(' ', data[i+3])+1:end])
            true_monkey = parse(Int64, data[i+4][findlast(' ', data[i+4])+1:end])
            false_monkey = parse(Int64, data[i+5][findlast(' ', data[i+5])+1:end])
            push!(tests, x -> (x % div == 0) ? true_monkey : false_monkey)
            push!(modulos, div)  # for part 2
        end
        return items, operations, tests, modulos
    end

    # simulate
    items, operations, tests, _ = initial_state()  # part 1
    times_inspected1 = [0 for _ in 1:8]
    for _ in 1:20
        for monkey in 1:length(data) ÷ 6
            for i in 1:length(items[monkey])
                times_inspected1[monkey] += 1
                items[monkey][i] = operations[monkey](items[monkey][i]) ÷ 3
                next_monkey = tests[monkey](items[monkey][i]) + 1
                push!(items[next_monkey], items[monkey][i])
            end
            items[monkey] = []
        end
    end
    items, operations, tests, modulos = initial_state()  # part 2
    times_inspected2 = [0 for _ in 1:8]
    modulo = prod(modulos)
    for _ in 1:10000
        for monkey in 1:length(data) ÷ 6
            for i in 1:length(items[monkey])
                times_inspected2[monkey] += 1
                items[monkey][i] = operations[monkey](items[monkey][i]) % modulo
                next_monkey = tests[monkey](items[monkey][i]) + 1
                push!(items[next_monkey], items[monkey][i])
            end
            items[monkey] = []
        end
    end
    sort!(times_inspected1)
    sort!(times_inspected2)
    println(times_inspected1[end] * times_inspected1[end-1])
    println(times_inspected2[end] * times_inspected2[end-1])
end

"""https://adventofcode.com/2022/day/12"""
function twelve(; input::String = "2022/day12_input.txt")
    data = chrmatrix(input)
    start, exit = findfirst(==('S'), data).I, findfirst(==('E'), data).I
    elevation(chr) = chr == 'S' ? 1 : (chr == 'E' ? 26 : Int(chr) - 96)
    nrow, ncol = size(data)[1], size(data)[2]

    q = Queue{Tuple{Int64, Tuple{Int64, Int64}}}()
    enqueue!(q, (0, exit))
    visited = [exit]
    least_steps1 = typemax(Int64)
    least_steps2 = []
    while !isempty(q)
        steps, x = dequeue!(q)
        steps += 1
        for dir in [(0, 1), (0, -1), (-1, 0), (1, 0)]
            p = x .+ dir
            !(p[1] in 1:nrow && p[2] in 1:ncol) && continue
            if elevation(data[x...]) - elevation(data[p...]) <= 1
                if p == start && least_steps1 > steps
                    least_steps1 = steps
                elseif elevation(data[p...]) == 1
                    push!(least_steps2, steps)
                elseif !(p in visited)
                    enqueue!(q, (steps, p))
                    push!(visited, p)
                end
            end
        end
    end
    println(least_steps1)
    println(minimum(least_steps2))
end

"""https://adventofcode.com/2022/day/13"""
function thirteen(; input::String = "2022/day13_input.txt")
    data = strvec2(input)

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

    data2 = strvec(input)
    dividers = ["[[2]]", "[[6]]"]
    push!(data2, dividers...)
    sort!(data2, by=conv, lt=comp)

    println(sum([i for (i, ln) in enumerate(data) if comp(conv(ln[1]), conv(ln[2]))]))
    println(prod([findfirst(==(d), data2) for d in dividers]))
end

thirteen()
