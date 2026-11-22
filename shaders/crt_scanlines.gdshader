shader_type canvas_item;

uniform float scanline_count : hint_range(0.0, 1080.0) = 220.0;
uniform float scanline_intensity : hint_range(0.0, 1.0) = 0.07;
uniform float vignette_intensity : hint_range(0.0, 2.0) = 0.35;
uniform float flicker_speed : hint_range(0.0, 50.0) = 12.0;
uniform float flicker_amount : hint_range(0.0, 0.1) = 0.012;

void fragment() {
    vec2 uv = UV;
    float scan = sin(uv.y * scanline_count * 3.14159265) * 0.5 + 0.5;
    float alpha = scan * scanline_intensity;
    
    float flicker = sin(TIME * flicker_speed) * flicker_amount;
    alpha += flicker;
    
    vec2 d = uv - vec2(0.5);
    float vig = dot(d, d) * vignette_intensity;
    alpha += vig;
    
    COLOR = vec4(0.01, 0.03, 0.06, clamp(alpha, 0.0, 0.6));
}
