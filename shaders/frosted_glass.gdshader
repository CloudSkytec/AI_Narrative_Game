shader_type canvas_item;

// 可调参数
uniform float lod_level : hint_range(0.0, 8.0) = 3.0; // 模糊强度（越大越糊）
uniform float brightness : hint_range(0.0, 3.0) = 1.0; // 亮度
uniform float saturation : hint_range(0.0, 3.0) = 1.0; // 饱和度
uniform sampler2D noise_tex : source_color;            // 可选：噪声/磨砂贴图
uniform float noise_intensity : hint_range(0.0, 1.0) = 0.05;

vec3 adjust_hsv(vec3 color, float b, float s) {
	// 转HSV做简单调节（近似）
	float maxc = max(max(color.r, color.g), color.b);
	float minc = min(min(color.r, color.g), color.b);
	float v = maxc;
	float c = maxc - minc;
	float sat = (v == 0.0) ? 0.0 : c / v;
	sat *= s;
	v *= b;
	// 只调整亮度/饱和度，保留原色调（不精确，但足够UI效果）
	float k = (v == 0.0) ? 0.0 : (sat * v);
	return mix(vec3(v), color * b, step(0.0001, k)); 
}

void fragment() {
	// 取屏幕纹理（UI 背后）
	vec2 suv = SCREEN_UV;
	// 进行多次采样简易模糊（近似 LOD）
	vec4 col = vec4(0.0);
	float r = lod_level * 0.0025; // 与分辨率相关的采样半径
	// 9 点采样（你也可以改成更高的核）
	vec2 offs[9] = vec2[](
		vec2(-r, -r), vec2(0.0, -r), vec2(r, -r),
		vec2(-r,  0.0), vec2(0.0, 0.0), vec2(r,  0.0),
		vec2(-r,  r), vec2(0.0,  r), vec2(r,  r)
	);
	for (int i=0;i<9;i++){
		col += texture(SCREEN_TEXTURE, suv + offs[i]);
	}
	col /= 9.0;

	// 可选：加入噪声让“磨砂感”更真实
	if (noise_intensity > 0.0 && textureSize(noise_tex, 0).x > 0) {
		vec3 noise = texture(noise_tex, UV * 2.0).rgb - 0.5;
		col.rgb += noise * noise_intensity;
	}

	// 调整亮度/饱和度
	col.rgb = adjust_hsv(col.rgb, brightness, saturation);

	COLOR = col;
}
