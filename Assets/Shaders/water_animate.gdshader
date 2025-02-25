shader_type spatial;

uniform vec4 albedo_color = vec4(0.08, 0.2, 0.48, 1.0);
uniform float time;
uniform float oscillation_frequency : hint_range(0.0, 5.0) = 2;
uniform float max_angle : hint_range(0.0, 0.5) = 0.2;
uniform float phase_offset : hint_range(0.0, 6.28318530718) = 0.0;
// A new uniform to control the rounding effect (0 = no rounding, 1 = fully spherical)
uniform float roundness : hint_range(0.0, 1.0) = 0.5;

void vertex() {
    // Existing rotation code
    float pitch_offset = sin(time * oscillation_frequency + phase_offset) * max_angle;
    float roll_offset = cos(time * oscillation_frequency + phase_offset) * max_angle;

    mat3 rotX = mat3(
        vec3(1.0, 0.0, 0.0),
        vec3(0.0, cos(pitch_offset), -sin(pitch_offset)),
        vec3(0.0, sin(pitch_offset), cos(pitch_offset))
    );

    mat3 rotZ = mat3(
        vec3(cos(roll_offset), -sin(roll_offset), 0.0),
        vec3(sin(roll_offset), cos(roll_offset), 0.0),
        vec3(0.0, 0.0, 1.0)
    );

    VERTEX = (rotZ * rotX) * VERTEX;

    // Create a spherical version of the vertex position.
    // This moves the vertex to a point on a sphere with the same radial distance.
    vec3 spherical_vertex = normalize(VERTEX) * length(VERTEX);
    // Blend the original position with the spherical one according to roundness.
    VERTEX = mix(VERTEX, spherical_vertex, roundness);
}

void fragment() {
    ALPHA = 0.3;
    ALBEDO = albedo_color.rgb;
}
