exiting    = true;       // wir verlassen gerade einen Room
param_value = param_min_value;
target_room = -1;        // wird von außen gesetzt

// Temporären Layer + Filter erstellen
_layer = layer_create(-500, "TransitionLayer");
filter  = fx_create(filter_name);
layer_set_fx(_layer, filter);
fx_set_parameter(filter, param_name, param_value);