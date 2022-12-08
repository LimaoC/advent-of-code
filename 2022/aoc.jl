function one()
    # https://adventofcode.com/2022/day/1
    lines = split(open(f -> read(f, String), "day1_input.txt"), "\n\n", keepempty=false)
    sums = map(line -> map(arr -> parse.(Int64, arr), split(line, "\n", keepempty=false)), lines)
    sums = map(arr -> sum(arr), sums)
    sort!(sums)
    println(sums[end])
    println(sum(sums[end-2:end]))
end

function two()
    # https://adventofcode.com/2022/day/2
    lines = split(open(f -> read(f, String), "day2_input.txt"), "\n", keepempty=false)
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
    score1 = sum([d1[line] for line in lines])
    score2 = sum([d2[line] for line in lines])
    println(score1)
    println(score2)
end

function three()
    # https://adventofcode.com/2022/day/3
    lines = split(open(f -> read(f, String), "day3_input.txt"), "\n", keepempty=false)
    priority(chr) = chr in "ABCDEFGHIJKLMNOPQRSTUVWXYZ" ? Int(chr) - 38 : Int(chr) - 96
    total1 = total2 = 0
    for line in lines
        first, last = line[begin:length(line)÷2], line[length(line)÷2+1:end]
        # find common item
        for chr in first
            if chr in last
                total1 += priority(chr)
                break
            end
        end
    end
    lines3 = map(n -> (lines[n], lines[n+1], lines[n+2]), 1:3:length(lines))
    for (first, second, third) in lines3
        # find common item
        for chr in first
            if chr in second && chr in third
                total2 += priority(chr)
                break
            end
        end
    end
    println(total1)
    println(total2)
end

function four()
    # https://adventofcode.com/2022/day/4
    lines = split(open(f -> read(f, String), "day4_input.txt"), "\n", keepempty=false)
    count1 = count2 = 0
    for line in lines
        first, second = split(line, ',')
        f1, f2 = parse.(Int, split(first, '-'))
        s1, s2 = parse.(Int, split(second, '-'))
        # check either range fully contains the other
        if (f1 in s1:s2 && f2 in s1:s2) || (s1 in f1:f2 && s2 in f1:f2)
            count1 += 1
        end
        # check either range overlaps
        if (f1 in s1:s2 || f2 in s1:s2) || (s1 in f1:f2 || s2 in f1:f2)
            count2 += 1
        end
    end
    println(count1)
    println(count2)
end

function five()
    # https://adventofcode.com/2022/day/5
    # parse input
    lines = split(open(f -> read(f, String), "day5_input.txt"), "\n", keepempty=true)
    n = findfirst(x -> isempty(x), lines)
    crate_lines = lines[1:n-2]
    crate_range = 2:4:length(lines[1])
    crates1 = [[] for _ in 1:length(crate_range)]
    for crate_line in crate_lines
        for (index, chr) in enumerate(crate_line[crate_range])
            chr != ' ' && pushfirst!(crates1[index], chr)
        end
    end
    crates2 = deepcopy(crates1)
    # move crates
    for move in lines[n+1:end-1]
        _, repetitions, _, src, _, dest = tryparse.(Int, split(move, " "))
        temp = []  # to reverse all moved crates in this move at once
        for _ in 1:repetitions
            push!(crates1[dest], pop!(crates1[src]))
            pushfirst!(temp, pop!(crates2[src]))
        end
        push!(crates2[dest], temp...)
    end
    print(join([stack[end] for stack in crates1]))
    println()
    print(join([stack[end] for stack in crates2]))
    println()
end

function six()
    # https://adventofcode.com/2022/day/6
    string = open(f -> read(f, String), "day6_input.txt")[begin:end-1]
    is_unique(s) = length(unique(s)) == length(s)
    offsets = (3, 13)  # message length - 1
    for offset in offsets
        for index in 1:length(string)-offset
            if is_unique(string[index:index+offset])
                println(index + offset)
                break
            end
        end
    end
end

function seven()
    # https://adventofcode.com/2022/day/7
    commands = split(open(f -> read(f, String), "day7_input.txt"), "\$ ", keepempty=false)
    root = [0, Dict()]
    current_path = []
    current_dir = root
    for command in commands
        lines = split(command, "\n", keepempty=false)
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

function eight()
    # https://adventofcode.com/2022/day/8
    lines = split(open(f -> read(f, String), "day8_input.txt"), "\n", keepempty=false)
    lines = map(line -> parse.(Int64, split(line, "", keepempty=false)), lines)
    trees = reduce(hcat, lines)'

    function is_visible(row, col)  # part 1
        rowv, colv = trees[row, :], trees[:, col]
        dirs = (colv[begin:row-1], colv[row+1:end], rowv[begin:col-1], rowv[col+1:end])
        return any(map(dir -> all(trees[row, col] .> dir), dirs))
    end

    function scenic_score(row, col)  # part 2
        scores = [0, 0, 0, 0]
        rowv, colv = trees[row, :], trees[:, col]
        dirs = (reverse(colv[begin:row-1]), colv[row+1:end], reverse(rowv[begin:col-1]), rowv[col+1:end])
        for (index, dir) in enumerate(dirs)
            for tree in dir
                scores[index] += 1
                tree >= trees[row, col] && break
            end
        end
        return prod(scores)
    end

    println(sum([is_visible(i[1], i[2]) for i in eachindex(trees)]))
    println(maximum([scenic_score(i[1], i[2]) for i in eachindex(trees)]))
end

eight()
