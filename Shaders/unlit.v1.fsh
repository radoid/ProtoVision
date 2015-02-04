uniform bool uUseColorMap;
uniform sampler2D uColorMapSampler;
varying vec4 vColor;
varying vec2 vTextureUV;
out vec4 fragColor;

void main(void) {
	if (uUseColorMap)
		gl_FragColor = vec4(texture(uColorMapSampler, vTextureUV).xyz, vColor.w);
	else
		gl_FragColor = vColor;
}
