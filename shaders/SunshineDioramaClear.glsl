// MarioSunshineRay clarity preset. Original single-sample color treatment.
// No depth, shadow mask, UI mask, or cinematic detection is available here.
// One unshifted image sample preserves source detail everywhere on screen.
/*
[configuration]
[OptionBool]
GUIName = Enable clear color treatment
OptionName = ClarityEnabled
DefaultValue = true
[OptionRangeFloat]
GUIName = Warm color treatment
OptionName = ColorStrength
MinValue = 0.0
MaxValue = 1.0
StepAmount = 0.05
DefaultValue = 0.55
[OptionRangeFloat]
GUIName = Lift dark tones (not shadow edge blur)
OptionName = DarkToneLift
MinValue = 0.0
MaxValue = 0.4
StepAmount = 0.02
DefaultValue = 0.0
[OptionRangeFloat]
GUIName = Gentle vignette
OptionName = EdgeShade
MinValue = 0.0
MaxValue = 0.3
StepAmount = 0.02
DefaultValue = 0.06
[/configuration]
*/

void main()
{
    float4 original = Sample();
    if (!OptionEnabled(ClarityEnabled)) { SetOutput(original); return; }
    float3 color = original.rgb;
    float luminance = dot(color, float3(0.2126, 0.7152, 0.0722));
    // Keep some warmth without the old contrast boost or crushed shadows.
    float3 graded = mix(float3(luminance, luminance, luminance), color, 0.92);
    float3 tint = mix(float3(0.98, 1.0, 1.025), float3(1.035, 1.01, 0.965),
                      smoothstep(0.2, 0.9, luminance));
    // Fade the tint near white, preserving bright text and highlight neutrality.
    graded *= mix(tint, float3(1.0, 1.0, 1.0), smoothstep(0.8, 1.0, luminance));
    color = mix(color, graded, GetOption(ColorStrength));
    // Monotonic endpoint-preserving curve. Black stays black; text gets no halo.
    // This affects all dark colors, not only surfaces inside cast shadows.
    color += GetOption(DarkToneLift) * color * (1.0-color) * (1.0-color) * 3.0;
    float2 uv = GetCoordinates();
    float edge = smoothstep(0.24, 0.7, length((uv-0.5)*float2(1.0, 0.85)));
    // Keep bright lettering out of the vignette; spatial detail remains intact.
    color *= 1.0 - GetOption(EdgeShade)*edge*(1.0-smoothstep(0.6, 0.95, luminance));
    SetOutput(float4(clamp(color, 0.0, 1.0), original.a));
}
