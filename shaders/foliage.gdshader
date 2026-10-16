shader_type canvas_item;
render_mode unshaded;
uniform float wind_time = 0.0;
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
 uv.x += breeze*0.0017*mask;
 uv.y += sin(wind_time*1.1+uv.x*19.0)*0.00045*mask;
 COLOR=texture(TEXTURE,clamp(uv,vec2(0.0),vec2(1.0)))*vertex_tint;
}
