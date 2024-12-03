use regex::Regex;
use std::fs;

fn part_one(data: &String) -> String {
    let re: Regex = Regex::new(r"mul\((\d+),(\d+)\)").unwrap();
    re.captures_iter(data)
        .map(|c| c[1].parse::<u32>().unwrap() * c[2].parse::<u32>().unwrap())
        .sum::<u32>()
        .to_string()
}

fn part_two(data: &String) -> String {
    let re: Regex = Regex::new(r"(mul\((\d+),(\d+)\)|do\(\)|don't\(\))").unwrap();
    let mut do_sum: bool = true;
    let mut sum: u32 = 0;
    for cap in re.captures_iter(data) {
        if &cap[1] == "do()" {
            do_sum = true;
        } else if &cap[1] == "don't()" {
            do_sum = false;
        } else if do_sum {
            sum += cap[2].parse::<u32>().unwrap() * cap[3].parse::<u32>().unwrap();
        }
    }
    sum.to_string()
}

pub fn run() {
    let data: String = fs::read_to_string("inputs/day-03/input.txt").unwrap();
    println!("{}", part_one(&data));
    println!("{}", part_two(&data));
}
