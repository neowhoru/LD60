display_set_gui_size(256, 240);
gpu_set_texfilter(false);

display_x = 48;
display_y = 48;
display_w = 160;
display_h = 144;

col_lcd_light = make_color_rgb(155, 188, 15);
col_lcd_deep  = make_color_rgb(15, 56, 15);

enum TitleState
{
    BOOT,
    MENU,
    HOW_TO_PLAY,
	HIGH_SCORE
}

title_state = TitleState.BOOT;

boot_timer = 0;
boot_duration = 1.8;
boot_y = display_y - 16;

boot_sound_played = false;

menu_selection = 0;
menu_items = ["START GAME", "HOW TO PLAY", "HIGH SCORE"];