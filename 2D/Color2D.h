//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

typedef struct {
	float r, g, b, alpha;
} Color2D;

static Color2D Color2DMake(float r, float g, float b, float alpha) {
	Color2D color = {r, g, b, alpha };
	return color;
}

static Color2D Color2DFromHex(int hex, float alpha) {
	Color2D color = { ((hex>>16) & 255)/255., ((hex>>8) & 255)/255., (hex & 255)/255., alpha };
	return color;
}

static Color2D ColorHSLFromRGB(float r, float g, float b, float alpha) {
	float min = (r < g && r < b ? r : (g < r && g < b ? g : b));
	float max = (r > g && r > b ? r : (g > r && g > b ? g : b));
	float diff = max - min;
	float h = 0, s = 0, l = (min + max) / 2;
	if (diff != 0) {
		s = l < 0.5 ? diff / (max + min) : diff / (2 - max - min);
		h = (r == max ? (g - b) / diff : g == max ? 2 + (b - r) / diff : 4 + (r - g) / diff) * 60;
	}
	Color2D hsl = {h, s, l, alpha};
	return hsl;
}

static Color2D ColorRGBFromHSL(float h, float s, float l, float alpha) {
	float r = l, g = l, b = l;
	float v = (l <= 0.5f) ? (l * (1.0f + s)) : (l + s - l * s);
	if (v > 0) {
		float m = l + l - v;
		float sv = (v - m) / v;
		h *= 6.0;
		int sextant = (int) h;
		float fract = h - sextant;
		float vsf = v * sv * fract;
		float mid1 = m + vsf;
		float mid2 = v - vsf;
		switch (sextant % 6) {
			case 0:
				r = v;
				g = mid1;
				b = m;
				break;
			case 1:
				r = mid2;
				g = v;
				b = m;
				break;
			case 2:
				r = m;
				g = v;
				b = mid1;
				break;
			case 3:
				r = m;
				g = mid2;
				b = v;
				break;
			case 4:
				r = mid1;
				g = m;
				b = v;
				break;
			case 5:
				r = v;
				g = m;
				b = mid2;
				break;
		}
	}
	Color2D rgb = {r, g, b, alpha};
	return rgb;
}
