#version 150

uniform bool uUseColorMap;
uniform sampler2D uColorMapSampler;
in vec2 vTextureUV;
in vec4 vColor;
out vec4 fragColor;

void main(void) {
	if (uUseColorMap)
		fragColor = vColor * texture(uColorMapSampler, vTextureUV);
	else
		fragColor = vColor;
}
