/// @description Hier Beschreibung einfügen
// Sie können Ihren Code in diesem Editor schreiben
gpu_set_texfilter(false);
menu_items[0] = "Start Game"
menu_items[1] = "Quit";

menu_selected_index = 0;

menu_input = 0;

draw_set_font(fnt_hud);

show_debug_message("Start menu")

title_timer = 0;
blink_show  = false;
lock_menu_movement = false;