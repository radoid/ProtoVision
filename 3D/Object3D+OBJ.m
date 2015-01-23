//
// ProtoVision Framework
// Rapid 2D & 3D prototiping engine
//
// http://www.radoid.com/protovision/
//

#import "Object3D+OBJ.h"


@implementation Object3D (OBJ)

- (Object3D *)initWithOBJ:(NSString *)path {
	return [self initWithOBJ:path size:0 rotation:Quaternion3DZero];
}

- (Object3D *)initWithOBJ:(NSString *)path size:(float)size rotation:(Quaternion3D)correction {
	int vertexcount, indexcount, normalcount;
	Buffer3DVertex *vertices = 0;
	Vector3D *normals = 0;
	GLushort *indices = 0;
	Vector3D min, max, center = Vector3DZero;
	float scale;

	FILE *f = fopen([path UTF8String], "rt");
	if (!f)
		return nil;
	for (int phase=0; phase < 2; phase++) {
		vertexcount = indexcount = normalcount = 0;
		Vector3D v, vn;
		int f1, f2, f3, n1, n2, n3;
		char line[256];
		fseek(f, 0, SEEK_SET);
		while (fgets(line, sizeof(line), f)) {
			if (sscanf(line, "v %f %f %f", &v.x, &v.y, &v.z) == 3) {
				if (vertices)
					vertices[vertexcount++].vertex = Vector3DScale(Vector3DRotateByQuaternion(Vector3DSubtract(v, center), correction), scale);  // v.subtract (center).rotate (rotation).scale (scale);
				else
					if (vertexcount++) {
						min = Vector3DMake(min(v.x, min.x), min(v.y, min.y), min(v.z, min.z));
						max = Vector3DMake(max(v.x, max.x), max(v.y, max.y), max(v.z, max.z));
					} else
						min = max = v;
			}
			else if (sscanf(line, "vn %f %f %f", &vn.x, &vn.y, &vn.z) == 3) {
				if (normals)
					normals[normalcount] = vn;
				normalcount++;
			}
			else if (sscanf(line, "f %d %d %d", &f1, &f2, &f3) >= 3) {
				NSAssert(f1 > 0 && f1-1 < vertexcount, nil);
				NSAssert(f2 > 0 && f2-1 < vertexcount, nil);
				NSAssert(f3 > 0 && f3-1 < vertexcount, nil);
				if (indices) {
					indices[indexcount+0] = (f1 > 0 ? f1-1 : f1+vertexcount);
					indices[indexcount+1] = (f2 > 0 ? f2-1 : f2+vertexcount);
					indices[indexcount+2] = (f3 > 0 ? f3-1 : f3+vertexcount);
				}
				indexcount += 3;
			}
			else if (sscanf(line, "f %d//%d %d//%d %d//%d", &f1, &n1, &f2, &n2, &f3, &n3) >= 6) {
				NSAssert(f1 > 0 && f1-1 < vertexcount, nil);
				NSAssert(f2 > 0 && f2-1 < vertexcount, nil);
				NSAssert(f3 > 0 && f3-1 < vertexcount, nil);
				NSAssert(n1 > 0 && n1-1 < normalcount, nil);
				NSAssert(n2 > 0 && n2-1 < normalcount, nil);
				NSAssert(n3 > 0 && n3-1 < normalcount, nil);
				if (indices) {
					indices[indexcount+0] = (f1 > 0 ? f1-1 : f1+vertexcount);
					indices[indexcount+1] = (f2 > 0 ? f2-1 : f2+vertexcount);
					indices[indexcount+2] = (f3 > 0 ? f3-1 : f3+vertexcount);
				}
				indexcount += 3;
			}
		}

		if (phase == 0) {
			printf("%d vrhova, %d indeksa, %d normala\n", vertexcount, indexcount, normalcount);
			if (vertexcount > 0xffff || !vertexcount || !indexcount)
				return nil;// TODO new IOException ("Too much vertices (" + vertexcount + " > " + 0x7fff + ") in model");
			scale = (size > 0 ? size / max (max.x - min.x, max (max.y - min.y, max.z - min.z)) : 1);
			//if (Math.signum (max.x) == Math.signum (min.x) || Math.signum (max.y) == Math.signum (min.y) || Math.signum (max.z) == Math.signum (min.z))
			center = Vector3DScale(Vector3DAdd(min, max), 0.5f);

			vertices = calloc(vertexcount, sizeof(Buffer3DVertex));
			indices = malloc(indexcount * sizeof(GLushort));
			if (normalcount)
				normals = malloc(normalcount * sizeof(Vector3D));
		}
	}
	fclose(f);

	// TODO self = [self initWithBuffer:[[Buffer3D alloc] initWithNormalsCalculatedAsSharp:NO vertexBuffer:vertices vertexCount:vertexcount indices:indices indexCount:indexcount isDynamic:NO]];

	if (vertices) free(vertices);
	if (normals) free(normals);
	if (indices) free(indices);

	return self;
}

@end
/*
public static Object3D loadOBJModel (GL2ES2 gl, String resourcepath, float size, Quaternion3D rotation, Program3D material) throws IOException {
	float scale = 1;

	for (int phase = 0; phase < 2; phase++) {
		while (br.ready ()) {
			StringTokenizer line = new StringTokenizer (br.readLine ());
			if (line.countTokens () > 0) {
				String command = line.nextToken ();
				else if (command.equalsIgnoreCase ("f")) {
					for (int i=0; i < 4 && line.hasMoreTokens (); i++) {
						if (indices != null) {
							String[] params = line.nextToken ().split ("/");
							short index = (short) (Short.parseShort (params[0]) - 1);
							if (index < 0)
								index += vertexcount + 1;
							indices[indexcount+i] = index;
							if (params.length >= 3) {
								short normal = (short) (Short.parseShort (params[2]) - 1);
								if (normal < 0)
									normal += normalcount + 1;
								vertices[index*6+3] = normals[normal*3];  // TODO: += ako ne želimo sharpen?
								vertices[index*6+4] = normals[normal*3+1];
								vertices[index*6+5] = normals[normal*3+2];
							}
							if (i == 3) {  // quad dodaje još prvu i prethodnu točku trokuta za novi trokut
								indices[indexcount+4] = indices[indexcount];
								indices[indexcount+5] = indices[indexcount+2];
								if (line.hasMoreTokens ())
									System.out.println (resourcepath + " ima višekut s više od 4 točke!");
							}
						}
						if (i == 3)  // quad dodaje još prvu i prethodnu točku trokuta za novi trokut
							indexcount += 3;
					}
					indexcount += 3;
				}
			}
		}
	}
}
*/