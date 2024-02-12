package main

import rl "vendor:raylib"

import "core:math/rand"
import "core:fmt"

create_map3x3 :: proc() -> [5]rl.Rectangle{
    chosen_sectors: [5]int = {-1, -1, -1, -1, -1}
    i := 0
    for i < 5{
        num := int(rand.int31_max(9))
        for is_same_hor(num, chosen_sectors) || is_duplicate(num, chosen_sectors[:]) || is_same_ver(num, chosen_sectors[:]){
            num = int(rand.int31_max(9))
        }
        chosen_sectors[i] = num
        i += 1
    }
    block_diff_x := WIDTH / 3
    block_diff_y := 250

    blocks: [5]rl.Rectangle
    for num, j in chosen_sectors{
        hor := num % 3
        ver := int(num / 3)

        blocks[j] = rl.Rectangle{f32(block_diff_x * hor), f32(HEIGHT - block_diff_y * ver - 100.0), f32(block_diff_x - 20), 100.0}
    }
    return blocks
}

create_map3x2 :: proc() -> [4]rl.Rectangle{
    sec_len :: 4
    chosen_sectors: [sec_len]int = {-1, -1, -1, -1}
    i := 0
    for i < sec_len{
        num := int(rand.int31_max(6))
        for is_duplicate(num, chosen_sectors[:]) || is_same_ver(num, chosen_sectors[:]){
            num = int(rand.int31_max(6))
        }
        chosen_sectors[i] = num
        i += 1
    }

    block_diff_x := WIDTH / 3
    block_diff_y := 300

    blocks: [sec_len]rl.Rectangle
    for num, j in chosen_sectors{
        hor := num % 3
        ver := int(num / 3)

        blocks[j] = rl.Rectangle{f32(block_diff_x * hor), f32(HEIGHT - block_diff_y * ver - 100.0), f32(block_diff_x - 20), 100.0}
    }
    return blocks
}

create_map4x1 :: proc() -> ([4]rl.Rectangle, rl.Rectangle, int){
    chosen_sectors: [4]int = {-1, -1, -1, -1}
    i := 0
    for i < 4{
        num := int(rand.int31_max(2))
        chosen_sectors[i] = num
        i += 1
    }

    block_diff_x := WIDTH / 4

    blocks: [4]rl.Rectangle
    for num, j in chosen_sectors{
        if num == 1{
            continue
        }

        blocks[j] = rl.Rectangle{f32(block_diff_x * j), f32(HEIGHT - 100.0), f32(block_diff_x), 100.0}
    }
    return blocks, rl.Rectangle{0, HEIGHT - 50, WIDTH, 50}, 4
}

create_map4x1_no_lava :: proc() -> ([4]rl.Rectangle, rl.Rectangle, int){

    block_diff_x := WIDTH / 4
    blocks: [4]rl.Rectangle
    for i in 0..<4{
        blocks[i] = rl.Rectangle{f32(block_diff_x * i), f32(HEIGHT - 100.0), f32(block_diff_x), 100.0}
    }
    return blocks, rl.Rectangle{0, HEIGHT - 50, WIDTH, 50}, 4
}

is_duplicate :: proc(num: int, arr: []int) -> bool{
    for n in arr{
        if num == n{
            return true
        }
    }
    return false
}

is_same_hor :: proc(num: int, arr: [5]int) -> bool{
    t := 0
    //top row
    if num > 5{
        for n in arr{
            if num - 3 == n || num - 6 == n{
                t += 1
                if t == 2{
                    return true
                }
            }
        }
    }
    //mid row
    if num > 2 && num < 6{
        for n in arr{
            if num - 3 == n || num + 3 == n{
                t += 1
                if t == 2{
                    return true
                }
            }
        }
    }
    if num < 3{
        for n in arr{
            if num + 6 == n || num + 3 == n{
                t += 1
                if t == 2{
                    return true
                }
            }
        }
    }
    return false
}

is_same_ver :: proc(num: int, arr: []int) -> bool{
    t := 0
    //6 3 0
    if num % 3 == 0{
        for n in arr{
            if num + 1 == n || num + 2 == n{
                t += 1
                if t == 2{
                    return true
                }
            }
        }
    }
    //7 4 1
    if num % 3 == 1{
        for n in arr{
            if num + 1 == n || num - 1 == n{
                t += 1
                if t == 2{
                    return true
                }
            }
        }
    }
    //8 5 2
    if num % 3 == 2{
        for n in arr{
            if num - 1 == n || num - 2 == n{
                t += 1
                if t == 2{
                    return true
                }
            }
        }
    }
    return false
}
