var dt = delta_time / 1000000;

if (title_state == TitleState.BOOT)
{
    boot_timer += dt;
	
	if (boot_timer >= 0.9 && !boot_sound_played)
	{
	    audio_play_sound(snd_startuptune, 10, false);
	    boot_sound_played = true;
	}

    if (boot_timer >= boot_duration)
    {
        title_state = TitleState.MENU;
    }
}

else if (title_state == TitleState.MENU)
{
    if (keyboard_check_pressed(vk_up) ||
        keyboard_check_pressed(ord("W")))
    {
        menu_selection =
            (menu_selection + array_length(menu_items) - 1)
            mod array_length(menu_items);
    }

    if (keyboard_check_pressed(vk_down) ||
        keyboard_check_pressed(ord("S")))
    {
        menu_selection =
            (menu_selection + 1) mod array_length(menu_items);
    }

    if (keyboard_check_pressed(vk_enter) ||
        keyboard_check_pressed(vk_space))
    {
        switch (menu_selection)
        {
            case 0:
                room_goto(rm_game);
                break;

            case 1:
                title_state = TitleState.HOW_TO_PLAY;
                break;

            case 2:
				ini_open("snake_save.ini");
				title_highscore = ini_read_real("scores", "highscore", 0);
				ini_close();
				title_state = TitleState.HIGH_SCORE;
                break;
        }
    }
}

else if (title_state == TitleState.HOW_TO_PLAY || title_state == TitleState.HIGH_SCORE)
{
    if (keyboard_check_pressed(vk_enter) ||
        keyboard_check_pressed(vk_space) ||
        keyboard_check_pressed(vk_escape))
    {
        title_state = TitleState.MENU;
    }
}