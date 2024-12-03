use std::collections::HashMap;
use std::fs;

fn parse(data: &String) -> (Vec<u32>, Vec<u32>) {
    let mut left: Vec<u32> = vec![];
    let mut right: Vec<u32> = vec![];

    for line in data.lines() {
        let nums: Vec<&str> = line.split_whitespace().collect();
        left.push(nums[0].parse::<u32>().unwrap());
        right.push(nums[1].parse::<u32>().unwrap());
    }

    (left, right)
}

pub fn part_one(data: &String) -> String {
    let (mut left, mut right): (Vec<u32>, Vec<u32>) = parse(data);

    left.sort();
    right.sort();

    let mut dist: u32 = 0;
    for (&left_num, &right_num) in left.iter().zip(right.iter()) {
        dist += left_num.abs_diff(right_num);
    }

    dist.to_string()
}

pub fn part_two(data: &String) -> String {
    let (left, right): (Vec<u32>, Vec<u32>) = parse(data);

    let mut freq: HashMap<u32, u32> = HashMap::new();

    for right_num in &right {
        *freq.entry(*right_num).or_insert(0) += 1;
    }

    let mut score: u32 = 0;
    for left_num in left {
        let mult: u32 = *freq.entry(left_num).or_default();
        score += left_num * mult;
    }

    score.to_string()
}

pub fn run() {
    let data: String = fs::read_to_string("inputs/day-01/input.txt").unwrap();
    println!("{}", part_one(&data));
    println!("{}", part_two(&data));
}
