exiting = false;
param_value = param_max_value;

_layer = layer_create(-500, "TransitionLayer");
filter  = fx_create(filter_name);
layer_set_fx(_layer, filter);
fx_set_parameter(filter, param_name, param_value);