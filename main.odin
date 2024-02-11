package main

import "core:fmt"
import math "core:math/linalg"

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


bullet_radius: f32 = 7.0
is_colliding_rect_circle :: proc(b: Bullet, r: rl.Rectangle) -> bool{
    min := rl.Vector2{r.x, r.y}
    max := rl.Vector2{r.x + r.width, r.y + r.height}

    closest := b.pos

    if closest.x < min.x{
        closest.x = min.x
    }
    if closest.x > max.x{
        closest.x = max.x
    }

    if closest.y < min.y{
        closest.y = min.y
    }
    if closest.y > max.y{
        closest.y = max.y
    }

    rect_center := rl.Vector2{r.x + r.width / 2, r.y + r.height / 2}
    rect_to_circle := rl.Vector2{b.pos.x - closest.x, b.pos.y - closest.y}
    length := vec_len(rect_to_circle.x, rect_to_circle.y)

    return length * length <= bullet_radius * bullet_radius
}

vec_len :: proc(x: f32, y: f32) -> f32{
    return math.sqrt(x * x + y * y)
}

vec_norm :: proc(x: f32, y: f32, len: f32) -> rl.Vector2{
    return rl.Vector2{x / len, y / len}
}

Bullet :: struct{
    pos: rl.Vector2,
    dir: rl.Vector2,
}

main :: proc(){
    rl.InitWindow(WIDTH, HEIGHT, "ttls")
    defer rl.CloseWindow()

    rl.SetTargetFPS(60)

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

    active_block: rl.Rectangle

    gun_rect: rl.Rectangle = {player.rect.x + 20, player.rect.y + 20, 20, 10}

    bullets: [dynamic]Bullet
    bullet_speed: f32 = 15.0

    blocks, lava_rect := create_map4x1()

    collding_with_floor := false 
    for !rl.WindowShouldClose(){
        rl.BeginDrawing()
        defer rl.EndDrawing()

        rl.ClearBackground(rl.BLACK)


        if rl.IsKeyDown(.A){
            next_rect := rl.Rectangle{player.rect.x - player.speed, player.rect.y, player.rect.width, player.rect.height}

            can_move := true
            for block in blocks{
                if is_colliding_rect_rect(next_rect, block){
                    can_move = false
                }
            }
            if can_move{
                player.rect = next_rect
            }
        }
        if rl.IsKeyDown(.D){
            next_rect := rl.Rectangle{player.rect.x + player.speed, player.rect.y, player.rect.width, player.rect.height}
            can_move := true
            for block in blocks{
                if is_colliding_rect_rect(next_rect, block){
                    can_move = false
                }
            }
            if can_move{
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
        if is_colliding_rect_rect(player.rect, lava_rect){
            fmt.println("your ided")
            break
        }

        for b, i in bullets{
            for block in blocks{
                if is_colliding_rect_circle(b, block){
                    fmt.println("hi")
                    unordered_remove(&bullets, i)
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

        mouse_pos := rl.GetMousePosition()
        dx := mouse_pos.x - player.rect.x
        dy := mouse_pos.y - player.rect.y
        deg := math.atan2(dy, dx) * (180 / 3.14)

        length := vec_len(dx, dy)
        norm_vec := vec_norm(dx, dy, length)
        //fmt.println(norm_vec)

        if rl.IsMouseButtonPressed(.LEFT){
            append(&bullets, Bullet{rl.Vector2{gun_rect.x, gun_rect.y}, norm_vec})
        }

        rl.DrawRectangleRec(lava_rect, rl.Color{255, 117, 79, 255})
        for block in blocks{
            rl.DrawRectangle(i32(block.x), i32(block.y), i32(block.width), i32(block.height), rl.WHITE)
        }

        rl.DrawRectangle(i32(player.rect.x), i32(player.rect.y), i32(player.rect.width), i32(player.rect.height), player_color)

        gun_rect = {player.rect.x + 20, player.rect.y + 20, 20, 10}
        rl.DrawRectanglePro(gun_rect, {0.0, 0.0}, deg, rl.BROWN)

        for i in 0..<len(bullets){
           b := bullets[i] 
           defer bullets[i] = b

            rl.DrawCircle(i32(b.pos.x), i32(b.pos.y), bullet_radius, rl.YELLOW)
            b.pos.x += b.dir.x * bullet_speed
            b.pos.y += b.dir.y * bullet_speed
        }
    }
}