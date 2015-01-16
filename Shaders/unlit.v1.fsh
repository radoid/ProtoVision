uniform bool uTexture;
uniform sampler2D uTexSampler;
varying vec4 vColor;
varying vec2 vTexture;
out vec4 fragColor;

void main(void) {
	if (uTexture)
		gl_FragColor = vec4(texture(uTexSampler, vTexture).xyz, vColor.w);
	else
		gl_FragColor = vColor;
}
