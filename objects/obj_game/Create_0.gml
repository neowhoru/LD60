// ============================================
// DISPLAY / LCD
// ============================================
gpu_set_texfilter(false);
display_set_gui_size(256, 240);

display_x = 48;
display_y = 48;
display_w = 160;
display_h = 144;

cell_size = 8;

grid_w = display_w div cell_size; // 20
grid_h = (display_h - 16) div cell_size; // 16

board_x = display_x;
board_y = display_y + 16;

col_lcd_light = make_color_rgb(155, 188, 15);
col_lcd_mid   = make_color_rgb(139, 172, 15);
col_lcd_dark  = make_color_rgb(48, 98, 48);
col_lcd_deep  = make_color_rgb(15, 56, 15);

// Music 
music_handle = -1;

// ============================================
// GAME STATES
// ============================================

STATE_READY = 0;
STATE_PLAYING = 1;
STATE_GAME_OVER = 2;

game_state = STATE_READY;


// ============================================
// SNAKE SETTINGS
// ============================================

start_move_delay = 0.18;
move_delay = 0.18;
move_delay_min = 0.075;
move_timer = 0;

score = 0;
highscore = 0;

dir_x = 1;
dir_y = 0;

// queue snake segments max 2
turn_queue = [];
queue_max = 2;

snake = [];
food_x = 0;
food_y = 0;


//============================================
// POWER-DOWN
//============================================

enum PowerdownEffect
{
    INVERT_HORIZONTAL, 
    SLOW_SNAKE,
    FAST_SNAKE,
	BLIND_SPOT
}

// Powerdown-Food
powerdown_visible = false;
powerdown_x = -1;
powerdown_y = -1;

powerdown_lifetime = 5.0;
powerdown_spawn_timer = 0;
powerdown_spawn_min = 5.0;
powerdown_spawn_max = 10.0;

// Active powerdown fx
powerdown_active = false;
powerdown_timer = 0;
powerdown_duration = 4.0;
powerdown_effect = PowerdownEffect.INVERT_HORIZONTAL;

normal_move_delay = start_move_delay;

blind_spot_segments = 6;
blind_spot_flicker_speed = 100;

// music pitching
music_base_pitch = 1.0;
music_max_pitch = 1.25;
music_pitch_step = 0.05;


// ============================================
// HIGH SCORE
// ============================================

if (file_exists("snake_save.ini"))
{
    ini_open("snake_save.ini");
    highscore = ini_read_real("scores", "highscore", 0);
    ini_close();
}


// ============================================
// HELPER: HIGH SCORE SPEICHERN
// ============================================

save_highscore = function()
{
    if (score > highscore)
    {
        highscore = score;

        ini_open("snake_save.ini");
        ini_write_real("scores", "highscore", highscore);
        ini_close();
    }
};


// ============================================
// HELPER: FOOD SPAWN
// ============================================

food_spawn = function()
{
    var free_cells = [];

    for (var yy = 1; yy < grid_h - 1; yy++)
    {
        for (var xx = 1; xx < grid_w - 1; xx++)
        {
            var occupied =
			    powerdown_visible &&
			    xx == powerdown_x &&
			    yy == powerdown_y;

            for (var i = 0; i < array_length(snake); i++)
            {
                if (snake[i].x == xx && snake[i].y == yy)
                {
                    occupied = true;
                    break;
                }
            }

            if (!occupied)
            {
                array_push(free_cells, {
                    x: xx,
                    y: yy
                });
            }
        }
    }

    if (array_length(free_cells) == 0)
    {
        game_state = STATE_GAME_OVER;
        save_highscore();
        return;
    }

    var choice = free_cells[irandom(array_length(free_cells) - 1)];

    food_x = choice.x;
    food_y = choice.y;
};


//============================================
// HELPER: Power Down spawner
//============================================
powerdown_spawn = function()
{
    var free_cells = [];

    for (var yy = 1; yy < grid_h - 1; yy++)
    {
        for (var xx = 1; xx < grid_w - 1; xx++)
        {
            var occupied = (xx == food_x && yy == food_y);

            for (var i = 0; i < array_length(snake); i++)
            {
                if (snake[i].x == xx && snake[i].y == yy)
                {
                    occupied = true;
                    break;
                }
            }

            if (!occupied)
            {
                array_push(free_cells, { x: xx, y: yy });
            }
        }
    }

    if (array_length(free_cells) == 0) return;

    var choice = free_cells[irandom(array_length(free_cells) - 1)];

    powerdown_x = choice.x;
    powerdown_y = choice.y;
    powerdown_visible = true;
    powerdown_spawn_timer = powerdown_lifetime;
};

// ============================================
// HELPER: GAME RESET
// ============================================

game_reset = function()
{
    score = 0;
    move_delay = start_move_delay;
    move_timer = 0;

    
    // reset direction
    dir_x = 1;
    dir_y = 0;

    turn_queue = [];
    snake = [];

    var start_x = grid_w div 2;
    var start_y = grid_h div 2;

    array_push(snake, { x: start_x,     y: start_y });
    array_push(snake, { x: start_x - 1, y: start_y });
    array_push(snake, { x: start_x - 2, y: start_y });

    game_state = STATE_READY;
	
	// restart music
	if (music_handle != -1)
    {
        audio_stop_sound(music_handle);
        music_handle = -1;
    }
    music_handle = audio_play_sound(mus_game, 10, true);
	
	powerdown_visible = false;
	powerdown_x = -1;
	powerdown_y = -1;
	powerdown_active = false;
	powerdown_timer = 0;
	powerdown_spawn_timer = random_range(
	    powerdown_spawn_min,
	    powerdown_spawn_max
	);
	powerdown_effect = PowerdownEffect.INVERT_HORIZONTAL;

    food_spawn();
};


// ============================================
// HELPER: TURN QUEUE
// ============================================

queue_turn = function(_dx, _dy)
{
	if (powerdown_active &&  powerdown_effect == PowerdownEffect.INVERT_HORIZONTAL)
	{
	    _dx = -_dx;
	}
    if (game_state != STATE_PLAYING) return;
    if (_dx == 0 && _dy == 0) return;

    var last_dx = dir_x;
    var last_dy = dir_y;

    if (array_length(turn_queue) > 0)
    {
        var last_turn = turn_queue[array_length(turn_queue) - 1];
        last_dx = last_turn.x;
        last_dy = last_turn.y;
    }

    // no identic direction or direct reverse
    if (_dx == last_dx && _dy == last_dy) return;
    if (_dx == -last_dx && _dy == -last_dy) return;

    if (array_length(turn_queue) < queue_max)
    {
        array_push(turn_queue, { x: _dx, y: _dy });
    }
};


// ============================================
// HELPER: ONE SNAKE STEP
// ============================================

snake_step = function()
{
    if (game_state != STATE_PLAYING) return;

    if (array_length(turn_queue) > 0)
    {
        var next_turn = turn_queue[0];

        dir_x = next_turn.x;
        dir_y = next_turn.y;

        array_delete(turn_queue, 0, 1);
    }

    var head = snake[0];

    var nx = head.x + dir_x;
    var ny = head.y + dir_y;

    // Wallcollision
    if (nx <= 0 || nx >= grid_w - 1 ||
        ny <= 0 || ny >= grid_h - 1)
    {
        game_state = STATE_GAME_OVER;
        save_highscore();
        return;
    }

    var eating_normal = (nx == food_x && ny == food_y);

	var eating_powerdown =
	    powerdown_visible &&
	    nx == powerdown_x &&
	    ny == powerdown_y;

	var eating = eating_normal || eating_powerdown;

    // Self collision
	// if not eating the last segment is allowed to be collide
    var check_length = array_length(snake);

    if (!eating)
    {
        check_length -= 1;
    }

    for (var i = 0; i < check_length; i++)
    {
        if (snake[i].x == nx && snake[i].y == ny)
        {
            game_state = STATE_GAME_OVER;
            save_highscore();
            return;
        }
    }

    array_insert(snake, 0, { x: nx, y: ny });

    if (eating)
{
    if (eating_powerdown)
    {
        score += 30;

        audio_play_sound(snd_collect_powerdown, 20, false);

        // Powerdown disappears instantly
        powerdown_visible = false;
        powerdown_x = -1;
        powerdown_y = -1;

        powerdown_spawn_timer = random_range(
            powerdown_spawn_min,
            powerdown_spawn_max
        );

        // Choose random effect for powerdown
        powerdown_effect = irandom(3);
        powerdown_active = true;
        powerdown_timer = powerdown_duration;
		
		powerdown_duration = 4.0;

		if (powerdown_effect == PowerdownEffect.BLIND_SPOT)
		{
		    powerdown_timer = 3.5;
		}
		else
		{
		    powerdown_timer = powerdown_duration;
		}

        turn_queue = [];
    }
    else if (eating_normal)
    {
        score += 10;

        audio_play_sound(snd_collect, 20, false);

        food_spawn();
    }

    // scorebase speed
    var base_delay = max(
        move_delay_min,
        start_move_delay - floor(score / 50) * 0.01
    );

    move_delay = base_delay;

    if (powerdown_active)
    {
        if (powerdown_effect == PowerdownEffect.SLOW_SNAKE)
        {
            move_delay = min(0.30, base_delay * 1.5);
        }
        else if (powerdown_effect == PowerdownEffect.FAST_SNAKE)
        {
            move_delay = max(move_delay_min, base_delay * 0.65);
        }
    }

    // raised music pitch
    var music_step = floor(score / 50);

    var new_pitch = min(
        music_max_pitch,
        music_base_pitch + music_step * music_pitch_step
    );

    if (music_handle != -1)
    {
        audio_sound_pitch(music_handle, new_pitch);
    }

    if (array_length(snake) >=
        (grid_w - 2) * (grid_h - 2))
	    {
	        game_state = STATE_GAME_OVER;
	        save_highscore();
	    }
	}
	else
	{
	    array_delete(snake, array_length(snake) - 1, 1);
	}
};

game_reset();