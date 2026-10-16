shader_type canvas_item;
render_mode unshaded;
uniform sampler2D scene : hint_screen_texture, repeat_disable, filter_linear;
uniform float night_amount = 0.0;
uniform float sunset_amount = 0.0;
uniform float night_darkness = 0.0;
void fragment() {
 vec2 uv = SCREEN_UV;
 vec3 c = texture(scene, uv).rgb;
 float lum = dot(c, vec3(0.2126, 0.7152, 0.0722));
 c = mix(vec3(lum), c, 1.025);
 c = (c - 0.5) * 1.025 + 0.5;
 c *= mix(vec3(1.012, 1.004, 0.99), vec3(0.94, 0.99, 1.055), night_amount);
 c *= mix(vec3(1.0),vec3(1.07,0.98,0.88),sunset_amount);
 float moon_tint=clamp(night_darkness*2.5,0.0,1.0);
 c=mix(c,mix(vec3(lum),c,0.65)*vec3(0.58,0.78,1.12),moon_tint);
 c *= 1.0-night_darkness;
 vec2 p = (uv - 0.5) * vec2(1.0, 0.8);
 float vignette = smoothstep(0.23, 0.63, length(p));
 c *= 1.0 - vignette * 0.18;
 COLOR = vec4(clamp(c, 0.0, 1.0), 1.0);
}
