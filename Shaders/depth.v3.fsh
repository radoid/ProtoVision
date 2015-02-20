#version 150

out float fragmentdepth;

void main(void) {
	fragmentdepth = gl_FragCoord.z;
}
