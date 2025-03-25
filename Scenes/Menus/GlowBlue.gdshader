shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(1.0, 1.0, 0.0, 1.0); // Default glow color (yellow)
uniform float glow_strength : hint_range(0.0, 5.0) = 1.0;
uniform float blur_radius : hint_range(0.0, 10.0) = 2.0;

void fragment() {
    vec2 uv = UV;
    vec4 original_color = texture(TEXTURE, uv);
    vec4 glow = vec4(0.0);

    for (float x = -blur_radius; x <= blur_radius; x++) {
        for (float y = -blur_radius; y <= blur_radius; y++) {
            glow += texture(TEXTURE, uv + vec2(x, y) / TEXTURE_PIXEL_SIZE);
        }
    }

    glow /= (pow(blur_radius * 2.0 + 1.0, 2.0));
    glow = glow * glow_color * glow_strength;
    COLOR = original_color + glow;
}