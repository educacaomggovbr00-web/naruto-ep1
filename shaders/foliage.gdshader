shader_type canvas_item;
render_mode unshaded;
uniform float wind_time = 0.0;
uniform float wind_strength = 1.0;
uniform vec2 shake_at = vec2(0.0);
uniform float shake_life = 0.0;
uniform int area_id = 0;
varying vec4 vertex_tint;
void vertex() { vertex_tint=COLOR; }
void fragment() {
 vec2 uv = UV;
 // The traversable floor stays still. Interiors and painted village buildings do too.
 float canopy = (1.0-smoothstep(0.22,0.40,uv.y)) * (area_id == 0 || area_id == 2 ? 1.0 : 0.0);
 float foreground = smoothstep(0.82,0.98,uv.y);
 float mask = area_id < 3 ? max(canopy,foreground) : 0.0;
 float breeze = sin(wind_time*1.35+uv.y*17.0)+0.35*sin(wind_time*2.1+uv.x*29.0);
 float local_shake = (1.0-smoothstep(0.0,0.19,distance(UV,shake_at)))*shake_life;
 uv.x += breeze*0.0038*wind_strength*mask + sin(wind_time*24.0)*local_shake*0.004*canopy;
 uv.y += sin(wind_time*1.1+uv.x*19.0)*0.0011*wind_strength*mask;
 // Village canal: feather the banks and keep the painted bridge rigid.
 vec2 pixel = UV * vec2(960.0,540.0);
 float canal = smoothstep(426.0,440.0,pixel.x)*(1.0-smoothstep(711.0,725.0,pixel.x));
 canal *= smoothstep(340.0,350.0,pixel.y)*(1.0-smoothstep(386.0,395.0,pixel.y));
 float bridge = smoothstep(520.0,528.0,pixel.x)*(1.0-smoothstep(635.0,643.0,pixel.x));
 float water = area_id == 1 ? canal*(1.0-bridge) : 0.0;
 float waves = sin(pixel.y*0.31-wind_time*1.7+sin(pixel.x*0.04+wind_time*0.4));
 uv.x += water * waves * 0.0011;
 uv.y += water * sin(pixel.x*0.09+wind_time*1.2)*0.0005;
 vec4 painted = texture(TEXTURE,clamp(uv,vec2(0.0),vec2(1.0)))*vertex_tint;
 painted.rgb += vec3(0.025,0.045,0.04)*water*pow(max(0.0,waves),6.0);
 COLOR=painted;
}
