shader_type canvas_item;

void fragment() {
    // Set an arbitrary RGB value (here white), but make it completely transparent.
    COLOR = vec4(1.0, 1.0, 1.0, 0.0);
}
