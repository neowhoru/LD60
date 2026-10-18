// ============================================
// HUD TEXT
// ============================================

draw_set_alpha(1);
draw_set_font(fnt_hud);
draw_set_color(col_lcd_deep);

draw_set_halign(fa_left);
draw_set_valign(fa_top);

draw_text(
    display_x + 8,
    display_y + 3,
    "SCORE " + string(score)
);

draw_set_halign(fa_right);

draw_text(
    display_x + display_w - 8,
    display_y + 3,
    "HI " + string(highscore)
);


// ============================================
// CENTER MESSAGES
// ============================================

draw_set_halign(fa_center);
draw_set_valign(fa_middle);

if (game_state == STATE_READY)
{
    draw_set_color(col_lcd_deep);

    draw_text(
        display_x + display_w / 2,
        display_y + display_h / 2,
        "PRESS ENTER"
    );
}
else if (game_state == STATE_GAME_OVER)
{
    draw_set_color(col_lcd_light);

    draw_rectangle(
        display_x + 16,
        display_y + 48,
        display_x + display_w - 17,
        display_y + 88,
        false
    );

    draw_set_color(col_lcd_deep);

    draw_text(
        display_x + display_w / 2,
        display_y + 60,
        "GAME OVER"
    );

    draw_text(
        display_x + display_w / 2,
        display_y + 77,
        "ENTER = RETRY"
    );
}

if (powerdown_active)
{
    if ((current_time div 180) mod 2 == 0)
    {
        draw_set_font(fnt_hud);
        draw_set_halign(fa_center);
        draw_set_valign(fa_top);
        draw_set_color(col_lcd_deep);

        draw_text(
            display_x + display_w / 2,
            display_y + display_h - 16,
            "ERR // " + string(ceil(powerdown_timer)) + "s"
        );
    }
}


// ============================================
// RESET DRAW SETTINGS
// ============================================

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);