package main

import "core:fmt"
import rl "vendor:raylib"

WIDTH :: 960
HEIGHT :: 720

Player :: struct{
    rect: rl.Rectangle,
    speed: f32,
    ver_speed: f32,
}

player_color: rl.Color = {77, 255, 109, 255}

first_color: rl.Color = {77, 255, 109, 255}
second_color: rl.Color = {255, 99, 136, 255}

is_colliding_rect_rect :: proc(r1: rl.Rectangle, r2: rl.Rectangle) -> bool{
    if r1.x + r1.width > r2.x && r1.x < r2.x + r2.width && r1.y + r1.height > r2.y && r1.y < r2.y + r2.height{
        return true 
    }
    return false 
}

is_colliding_top :: proc(r1: rl.Rectangle, r2: rl.Rectangle, epsilon: f32 = 10.0) -> bool{
    if r1.y + r1.height + epsilon > r2.y || r1.y + r1.height - epsilon < r2.y{
        if r1.x + r1.width > r2.x && r1.x < r2.x + r2.width{
            return true
        }
    }
    return false
}

is_colliding_bottom :: proc(r1: rl.Rectangle, r2: rl.Rectangle) -> bool{
    if r1.y < r2.y + r2.height && r1.y + r1.height - 20.0 > r2.y{
        if r1.x + r1.width > r2.x && r1.x < r2.x + r2.width{
            return true
        }
    }
    return false
}

main :: proc(){
    rl.InitWindow(WIDTH, HEIGHT, "ttls")
    defer rl.CloseWindow()

    rl.SetTargetFPS(60)

    /*
    //NOTES
    //f(t) = 1/2gt^2 + vot + po //next positiono

    vo = 2hvx/xh
    g = -2hvx^2/xh^2

    pos += vel * dt + 1/2acc * dt^2
    vel += acc * t

    xh = 100
    h = 120
    */
    xh: f32 = 100.0
    h: f32 = 120.0

    speed: f32 = 7.0
    ver_speed := 2 * h * speed / xh / 1.5
    g := -50 * h * (speed * speed) / (xh * xh)

    dt: f32 = 1.0 / 60.0

    player := Player{
        rect = {WIDTH / 2 - 20, HEIGHT - 160, 40, 40},
        speed = speed,
        ver_speed = ver_speed,
    }

    floor: rl.Rectangle = {0, HEIGHT - 120, WIDTH, 120}
    test_block: rl.Rectangle = {WIDTH / 2 - 20 + 200, HEIGHT - 220, 200, 100}
    test_block2: rl.Rectangle = {200, 200, 100, 100}

    active_block: rl.Rectangle

    blocks: [dynamic]rl.Rectangle
    append(&blocks, floor)
    append(&blocks, test_block)
    append(&blocks, test_block2)

    collding_with_floor := true 
    for !rl.WindowShouldClose(){
        rl.BeginDrawing()
        defer rl.EndDrawing()

        rl.ClearBackground(rl.BLACK)


        if rl.IsKeyDown(.A){
            //add collission
            next_rect := rl.Rectangle{player.rect.x - player.speed, player.rect.y, player.rect.width, player.rect.height}
            if !is_colliding_rect_rect(next_rect, test_block) && !is_colliding_rect_rect(next_rect, test_block2){
                player.rect = next_rect
            }
        }
        if rl.IsKeyDown(.D){
            //add collission
            next_rect := rl.Rectangle{player.rect.x + player.speed, player.rect.y, player.rect.width, player.rect.height}
            if !is_colliding_rect_rect(next_rect, test_block) && !is_colliding_rect_rect(next_rect, test_block2){
                player.rect = next_rect
            }
        }

        if rl.IsKeyPressed(.SPACE){
            collding_with_floor = false 
            player.ver_speed = 2 * h * speed / xh / 1.5
            player.rect.y -= 10.0
        }

        for block in blocks{
            if is_colliding_rect_rect(player.rect, block){
                if is_colliding_bottom(player.rect, block){
                    player.rect.y = block.y + block.height + 5.0
                    player.ver_speed = 0.0
                }
                else if is_colliding_top(player.rect, block){
                    player.rect.y = block.y - player.rect.height
                    active_block = block
                    collding_with_floor = true
                }
            }
        }

        if active_block.width != 0{
            if !is_colliding_top(player.rect, active_block){
                collding_with_floor = false

                active_block.x = 0
                active_block.y = 0
                active_block.height = 0
                active_block.width = 0
            }
        }

        if !collding_with_floor{
            player.rect.y -= player.ver_speed + 0.5 * g * dt * dt
            player.ver_speed += g * dt
        }

        rl.DrawRectangle(i32(floor.x), i32(floor.y), i32(floor.width), i32(floor.height), rl.WHITE)
        rl.DrawRectangle(i32(test_block.x), i32(test_block.y), i32(test_block.width), i32(test_block.height), rl.WHITE)
        rl.DrawRectangle(i32(test_block2.x), i32(test_block2.y), i32(test_block2.width), i32(test_block2.height), rl.WHITE)

        rl.DrawRectangle(i32(player.rect.x), i32(player.rect.y), i32(player.rect.width), i32(player.rect.height), player_color)
    }
}