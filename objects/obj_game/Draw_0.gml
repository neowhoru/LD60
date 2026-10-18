// ============================================
// BACKGROUND
// ============================================

draw_set_alpha(1);
draw_set_color(col_lcd_light);

draw_rectangle(
    display_x,
    display_y,
    display_x + display_w - 1,
    display_y + display_h - 1,
    false
);


// ============================================
// HUD DIVIDER
// ============================================

draw_set_color(col_lcd_deep);

draw_rectangle(
    display_x,
    board_y,
    display_x + display_w - 1,
    board_y + 2,
    false
);


// ============================================
// BOARD WALLS
// ============================================

draw_set_color(col_lcd_deep);

// up and down
draw_rectangle(
    board_x,
    board_y,
    board_x + display_w - 1,
    board_y + cell_size - 1,
    false
);

draw_rectangle(
    board_x,
    board_y + (grid_h - 1) * cell_size,
    board_x + display_w - 1,
    board_y + grid_h * cell_size - 1,
    false
);

// left and right
draw_rectangle(
    board_x,
    board_y,
    board_x + cell_size - 1,
    board_y + grid_h * cell_size - 1,
    false
);

draw_rectangle(
    board_x + (grid_w - 1) * cell_size,
    board_y,
    board_x + grid_w * cell_size - 1,
    board_y + grid_h * cell_size - 1,
    false
);


// ============================================
// NORMALES FOOD
// ============================================

var food_px = board_x + food_x * cell_size + cell_size / 2;
var food_py = board_y + food_y * cell_size + cell_size / 2;

var food_frame =
    floor(current_time / 140) mod sprite_get_number(spr_collect);

draw_sprite(
    spr_collect,
    food_frame,
    food_px,
    food_py
);


// ============================================
// Addition powerdown food
// ============================================

if (powerdown_visible)
{
    var powerdown_px =
        board_x + powerdown_x * cell_size + cell_size / 2;

    var powerdown_py =
        board_y + powerdown_y * cell_size + cell_size / 2;

    var powerdown_frame =
        floor(current_time / 140)
        mod sprite_get_number(spr_power_down);

    draw_sprite(
        spr_power_down,
        powerdown_frame,
        powerdown_px,
        powerdown_py
    );
}


// ============================================
// SNAKE BODY
// ============================================

var body_frame =
    floor(current_time / 140) mod sprite_get_number(spr_snake_body);

var snake_length = array_length(snake);

for (var i = snake_length - 1; i >= 1; i--)
{
    var px = board_x + snake[i].x * cell_size + cell_size / 2;
    var py = board_y + snake[i].y * cell_size + cell_size / 2;
	
	if (powerdown_active &&
    powerdown_effect == PowerdownEffect.BLIND_SPOT &&
    i >= max(1, snake_length - blind_spot_segments))
	{
	    // Zufälliges Flackern in kurzen Intervallen
	    var flicker =
	        (current_time div blind_spot_flicker_speed + i * 3) mod 2;

	    if (flicker == 0)
	    {
	        continue;
	    }
	}

    var angle = 0;
    var is_corner = false;

    // Connection to previos segment
    var prev_dx = snake[i - 1].x - snake[i].x;
    var prev_dy = snake[i - 1].y - snake[i].y;

    // Connection to next
    if (i < snake_length - 1)
    {
        var next_dx = snake[i + 1].x - snake[i].x;
        var next_dy = snake[i + 1].y - snake[i].y;

		// Corner handling
        is_corner =
            (prev_dx != 0 && next_dy != 0) ||
            (prev_dy != 0 && next_dx != 0);

        if (is_corner)
        {
            // direction flags
            var has_up    = (prev_dy == -1 || next_dy == -1);
			var has_down  = (prev_dy ==  1 || next_dy ==  1);
			var has_left  = (prev_dx == -1 || next_dx == -1);
			var has_right = (prev_dx ==  1 || next_dx ==  1);

            
            if (has_right && has_down) angle = 0;
			else if (has_down && has_left) angle = -90;
			else if (has_left && has_up) angle = 180;
			else if (has_up && has_right) angle = -270;
			else is_corner = false;
        }
    }

    if (is_corner)
    {
        draw_sprite_ext(
            spr_body_corner,
            0,
            px,
            py,
            1,
            1,
            angle,
            c_white,
            1
        );
    }
    else
    {
        if (i < snake_length - 1)
        {
            var next_dx2 = snake[i + 1].x - snake[i].x;
            var next_dy2 = snake[i + 1].y - snake[i].y;

            if (next_dy2 != 0)
                angle = 90;
            else
                angle = 0;
        }
        else
        {
            // snake segment orientation
            var tail_dx = snake[i - 1].x - snake[i].x;
            var tail_dy = snake[i - 1].y - snake[i].y;

            if (tail_dy != 0)
                angle = 90;
            else
                angle = 0;
        }

        var frame = body_frame;

        draw_sprite_ext(
            spr_snake_body,
            frame,
            px,
            py,
            1,
            1,
            angle,
            c_white,
            1
        );
    }
}


// ============================================
// SNAKE HEAD
// ============================================

if (snake_length > 0)
{
    var head_angle = 0;

    if (dir_x > 0) head_angle = 0;
    else if (dir_y < 0) head_angle = 90;
    else if (dir_x < 0) head_angle = 180;
    else if (dir_y > 0) head_angle = 270;

    var head_frame =
        floor(current_time / 140) mod sprite_get_number(spr_snake_head);

    var head_px = board_x + snake[0].x * cell_size + cell_size / 2;
    var head_py = board_y + snake[0].y * cell_size + cell_size / 2;

    draw_sprite_ext(
        spr_snake_head,
        head_frame,
        head_px,
        head_py,
        1,
        1,
        head_angle,
        c_white,
        1
    );
}