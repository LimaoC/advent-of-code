function one()
    lines = split(open(f -> read(f, String), "day1_input.txt"), "\n\n", keepempty=false)
    sums = map(line -> map(arr -> parse.(Int64, arr), split(line, "\n", keepempty=false)), lines)
    sums = map(arr -> sum(arr), sums)
    sort!(sums)
    println(sums[end])
    println(sum(sums[end-2:end]))
end

function two()
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
    lines = split(open(f -> read(f, String), "day3_input.txt"), "\n", keepempty=false)
    priority(chr) = chr in "ABCDEFGHIJKLMNOPQRSTUVWXYZ" ? Int(chr) - 38 : Int(chr) - 96
    total1 = total2 = 0
    for line in lines
        first, last = line[begin:length(line)÷2], line[length(line)÷2+1:end]
        for chr in first
            if chr in last
                total1 += priority(chr)
                break
            end
        end
    end
    lines3 = map(n -> (lines[n], lines[n+1], lines[n+2]), 1:3:length(lines))
    for (first, second, third) in lines3
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
    lines = split(open(f -> read(f, String), "day4_input.txt"), "\n", keepempty=false)
    count1 = count2 = 0
    for line in lines
        first, second = split(line, ',')
        f1, f2 = parse.(Int, split(first, '-'))
        s1, s2 = parse.(Int, split(second, '-'))
        if (f1 in s1:s2 && f2 in s1:s2) || (s1 in f1:f2 && s2 in f1:f2)
            count1 += 1
        end
        if (f1 in s1:s2 || f2 in s1:s2) || (s1 in f1:f2 || s2 in f1:f2)
            count2 += 1
        end
    end
    println(count1)
    println(count2)
end

four()
