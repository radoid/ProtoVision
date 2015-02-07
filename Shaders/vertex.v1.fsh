uniform bool uUseColorMap;
uniform sampler2D uColorMapSampler;
varying lowp vec2 vTextureUV;
varying lowp vec4 vColor;

void main(void) {
	if (uUseColorMap)
		gl_FragColor = vColor * texture2D(uColorMapSampler, vTextureUV);
	else
		gl_FragColor = vColor;
}
