use std::fs;

fn parse(data: &String) -> Vec<Vec<u32>> {
    let mut result: Vec<Vec<u32>> = vec![];

    for line in data.lines() {
        let nums: Vec<u32> = line
            .split_whitespace()
            .map(|s| s.parse::<u32>().unwrap())
            .collect();
        result.push(nums);
    }

    result
}

fn is_safe(nums: &Vec<u32>) -> bool {
    if !nums.is_sorted() && !nums.is_sorted_by(|a, b| a >= b) {
        return false;
    }
    nums.iter().zip(nums.iter().skip(1)).all(|(&a, &b)| {
        let dist: u32 = a.abs_diff(b);
        dist >= 1 && dist <= 3
    })
}

fn vec_without_i(vec: &Vec<u32>, i: &usize) -> Vec<u32> {
    vec.iter()
        .enumerate()
        .filter(|&(j, _)| j != *i)
        .map(|(_, elem)| *elem)
        .collect()
}

fn is_almost_safe(nums: &Vec<u32>) -> bool {
    nums.iter()
        .enumerate()
        .any(|(i, _)| is_safe(&vec_without_i(nums, &i)))
}

pub fn part_one(data: &String) -> String {
    let lines: Vec<Vec<u32>> = parse(data);
    lines
        .iter()
        .map(|line| is_safe(line) as u32)
        .sum::<u32>()
        .to_string()
}

pub fn part_two(data: &String) -> String {
    let lines: Vec<Vec<u32>> = parse(data);
    lines
        .iter()
        .map(|line| (is_safe(line) || is_almost_safe(line)) as u32)
        .sum::<u32>()
        .to_string()
}

pub fn run() {
    let data: String = fs::read_to_string("inputs/day-02/input.txt").unwrap();
    println!("{}", part_one(&data));
    println!("{}", part_two(&data));
}
