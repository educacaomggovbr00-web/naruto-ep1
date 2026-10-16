shader_type canvas_item;
render_mode unshaded;
uniform sampler2D scene : hint_screen_texture, repeat_disable, filter_linear;
uniform float night_amount = 0.0;
void fragment() {
 vec2 uv = SCREEN_UV;
 vec3 c = texture(scene, uv).rgb;
 float lum = dot(c, vec3(0.2126, 0.7152, 0.0722));
 c = mix(vec3(lum), c, 1.025);
 c = (c - 0.5) * 1.025 + 0.5;
 c *= mix(vec3(1.012, 1.004, 0.99), vec3(0.94, 0.99, 1.055), night_amount);
 vec2 p = (uv - 0.5) * vec2(1.0, 0.8);
 float vignette = smoothstep(0.23, 0.63, length(p));
 c *= 1.0 - vignette * 0.18;
 COLOR = vec4(clamp(c, 0.0, 1.0), 1.0);
}
