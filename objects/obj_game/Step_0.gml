// ============================================
// INPUT
// ============================================

var start_pressed =
    keyboard_check_pressed(vk_enter) ||
    keyboard_check_pressed(vk_space);

if (game_state == STATE_READY && start_pressed)
{
    game_state = STATE_PLAYING;
    move_timer = 0;
}

if (game_state == STATE_GAME_OVER && start_pressed)
{
    game_reset();
}


// ============================================
// DIRECTION INPUT
// ============================================

if (keyboard_check_pressed(vk_right) ||
    keyboard_check_pressed(ord("D")))
{
    queue_turn(1, 0);
}
else if (keyboard_check_pressed(vk_left) ||
         keyboard_check_pressed(ord("A")))
{
    queue_turn(-1, 0);
}
else if (keyboard_check_pressed(vk_up) ||
         keyboard_check_pressed(ord("W")))
{
    queue_turn(0, -1);
}
else if (keyboard_check_pressed(vk_down) ||
         keyboard_check_pressed(ord("S")))
{
    queue_turn(0, 1);
}


// ============================================
// MOVEMENT TIMER
// ============================================

if (game_state == STATE_PLAYING)
{
    move_timer += delta_time / 1000000;

    while (move_timer >= move_delay &&
           game_state == STATE_PLAYING)
    {
        move_timer -= move_delay;
        snake_step();
    }
}

//============================================
// PowerDown managment
//============================================
if (game_state == STATE_PLAYING)
{
    var dt = delta_time / 1000000;

    // additional powerdown manage
    if (powerdown_visible)
    {
        powerdown_spawn_timer -= dt;

        if (powerdown_spawn_timer <= 0)
        {
            powerdown_visible = false;
            powerdown_x = -1;
            powerdown_y = -1;

            powerdown_spawn_timer = random_range(
                powerdown_spawn_min,
                powerdown_spawn_max
            );
        }
    }
    else if (!powerdown_active)
    {
        powerdown_spawn_timer -= dt;

        if (powerdown_spawn_timer <= 0)
        {
            powerdown_spawn();
        }
    }

    if (powerdown_active)
    {
        powerdown_timer -= dt;

        if (powerdown_timer <= 0)
        {
            powerdown_timer = 0;
            powerdown_active = false;
            turn_queue = [];

            // revert to normal speed
            move_delay = max(
                move_delay_min,
                start_move_delay - floor(score / 50) * 0.01
            );
        }
    }
}

// Stop music on gameover
if (game_state == STATE_GAME_OVER && music_handle != -1)
{
    audio_stop_sound(music_handle);
    music_handle = -1;
	powerdown_active = false;
}

if (powerdown_active && game_state == STATE_PLAYING)
{
    powerdown_timer -= delta_time / 1000000;

    if (powerdown_timer <= 0)
    {
        powerdown_timer = 0;
        powerdown_active = false;
        turn_queue = [];
    }
}