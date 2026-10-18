draw_set_alpha(1);
draw_set_color(col_lcd_light);

draw_rectangle(
    display_x,
    display_y,
    display_x + display_w - 1,
    display_y + display_h - 1,
    false
);

draw_set_font(fnt_hud_title);
draw_set_color(col_lcd_deep);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

var center_x = display_x + display_w / 2;
var center_y = display_y + display_h / 2;

if (title_state == TitleState.BOOT)
{
    // Fallbewegung mit sanftem Abbremsen
    var t = clamp(boot_timer / 0.9, 0, 1);
    var eased = 1 - power(1 - t, 3);

    var start_y = display_y - 12;
    var target_y = center_y;

    var text_y = lerp(start_y, target_y, eased);

    draw_text(center_x, text_y, "LUDUM DARE 60");
}

else if (title_state == TitleState.MENU)
{
    draw_sprite(
	    spr_logo,
	    0,
	    center_x,
	    display_y + 40
	);

    for (var i = 0; i < array_length(menu_items); i++)
    {
        var item_y = display_y + 64 + i * 18;

        var prefix = (i == menu_selection) ? "> " : "  ";

        draw_text(
            center_x,
            item_y,
            prefix + menu_items[i]
        );
    }
}

else if (title_state == TitleState.HOW_TO_PLAY)
{
    draw_text(center_x, display_y + 28, "HOW TO PLAY");

    draw_text(center_x, display_y + 52, "ARROWS / WASD");
    draw_text(center_x, display_y + 70, "EAT FOOD: +10");
    draw_text(center_x, display_y + 88, "GLITCH: +30");
    draw_text(center_x, display_y + 106, "AVOID YOURSELF");

    draw_text(center_x, display_y + 128, "ENTER = BACK");
}

else if (title_state == TitleState.HIGH_SCORE)
{
    draw_text(center_x, display_y + 42, "HIGH SCORE");

    draw_text(
        center_x,
        display_y + 72,
        string(title_highscore)
    );

    draw_text(
        center_x,
        display_y + 118,
        "ENTER = BACK"
    );
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);