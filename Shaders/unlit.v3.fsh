#version 150

uniform bool uUseColorMap;
uniform sampler2D uColorMapSampler;
in vec4 vColor;
in vec2 vTextureUV;
out vec4 fragColor;

void main(void) {
	if (uUseColorMap)
		fragColor = vec4(texture(uColorMapSampler, vTextureUV).xyz, vColor.w);
	else
		fragColor = vColor;
}
