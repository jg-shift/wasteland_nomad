shader_type canvas_item;

uniform float flash : hint_range(0.0, 1.0) = 0.0;
uniform float sat_mul : hint_range(0.0, 2.0) = 1.0; // 0=ч/б, 1=норма, >1=перенасыщение
uniform float val_mul : hint_range(0.0, 2.0) = 1.0; // яркость/светлота

void fragment() {
	vec4 c = texture(TEXTURE, UV) * COLOR;

	// Насыщенность через смешивание с серым
	float gray = dot(c.rgb, vec3(0.299, 0.587, 0.114));
	vec3 gray_rgb = vec3(gray);
	c.rgb = mix(gray_rgb, c.rgb, sat_mul);

	// Яркость
	c.rgb *= val_mul;

	// Hit-flash
	c.rgb = mix(c.rgb, vec3(1.0), flash);

	COLOR = c;
}
