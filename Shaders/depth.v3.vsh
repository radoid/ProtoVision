#version 150

uniform mat4 uProjection, uModelView;
in vec3 aPosition;

void main (void) {
	gl_Position = uProjection * uModelView * vec4(aPosition, 1.0);
}
