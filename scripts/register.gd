class_name RuneRegister extends RefCounted

var yin := Vector2.RIGHT
var yang := Vector2.ZERO

func apply(rune: String, angle := PI) -> void:
	var a := yin
	var b := yang
	match rune:
		"X":
			yin = b
			yang = a
		"H":
			yin = (a + b) / sqrt(2.0)
			yang = (a - b) / sqrt(2.0)
		"P":
			yang = b.rotated(angle)

func measure(rng: RandomNumberGenerator) -> int:
	var bit := int(rng.randf() < clampf(yang.length_squared(), 0, 1))
	if is_equal_approx(yang.length_squared(), 1.0):
		bit = 1
	yin = Vector2.RIGHT if bit == 0 else Vector2.ZERO
	yang = Vector2.RIGHT if bit == 1 else Vector2.ZERO
	return bit
