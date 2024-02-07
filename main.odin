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

    speed: f32 = 6.0
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

    jump := false
    for !rl.WindowShouldClose(){
        rl.BeginDrawing()
        defer rl.EndDrawing()

        rl.ClearBackground(rl.BLACK)


        if rl.IsKeyDown(.A){
            player.rect.x -= player.speed
        }
        if rl.IsKeyDown(.D){
            player.rect.x += player.speed
        }
        if rl.IsKeyDown(.W){
            player.rect.y -= player.speed
        }
        if rl.IsKeyDown(.S){
            player.rect.y += player.speed
        }

        if is_colliding_rect_rect(player.rect, test_block){
            player_color = second_color
        }
        else {
            player_color = first_color
        }

        /*
        if rl.IsKeyPressed(.SPACE){
            jump = true
            player.ver_speed = 2 * h * speed / xh / 1.5
            player.rect.y -= 10.0
        }
        */

        /*
        if rl.CheckCollisionRecs(player.rect, floor) || rl.CheckCollisionRecs(player.rect, test_block){
            jump = false
        }
        */

        if jump{
            player.rect.y -= player.ver_speed + 0.5 * g * dt * dt
            player.ver_speed += g * dt
        }

        //rl.DrawRectangle(i32(floor.x), i32(floor.y), i32(floor.width), i32(floor.height), rl.WHITE)
        rl.DrawRectangle(i32(test_block.x), i32(test_block.y), i32(test_block.width), i32(test_block.height), rl.WHITE)

        rl.DrawRectangle(i32(player.rect.x), i32(player.rect.y), i32(player.rect.width), i32(player.rect.height), player_color)
    }
}