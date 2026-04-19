shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	COLOR = texture(TEXTURE, UV);
	COLOR.r = COLOR.r * 0.2;
	COLOR.g = COLOR.g * 0.2;
	COLOR.b = COLOR.b * 0.2;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
