class_name EaseType
enum {
	LINEAR,
	EASE_IN_QUAD,
	EASE_OUT_QUAD,
	EASE_IN_OUT_QUAD,
	SMOOTHSTEP
}

static func interpolate(t, ease_type):
	match(ease_type):
		EaseType.LINEAR:
			return t
		EaseType.EASE_IN_QUAD:
			return t*t
		EaseType.EASE_OUT_QUAD:
			return 1-((1-t)*(1-t))
		EaseType.EASE_IN_OUT_QUAD:
			
			if t < 0.5:
				return 2 *t * t
			else:
				return 2 * (t-0.5) * (1 - (t-0.5)) + 0.5
				
		EaseType.SMOOTHSTEP:
			return smooth(t)


static func smooth(t):
	return -2*t**3+3*t**2 #nebo hornerovo t*t*(3-2*t)
	#nebo taky:
static func smooth2(t):
	return lerp(interpolate(t,EASE_IN_QUAD),interpolate(t,EASE_OUT_QUAD),t)
