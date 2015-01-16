#version 150

uniform bool uTexture;
uniform sampler2D uTexSampler;
in vec4 vColor;
in vec2 vTexture;
out vec4 fragColor;

void main(void) {
	if (uTexture)
		fragColor = vec4(texture(uTexSampler, vTexture).xyz, vColor.w);
	else
		fragColor = vColor;
}
