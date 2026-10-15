// MarioSunshineRay: original screen-space diorama treatment for Dolphin.
// This filter has no game depth, normals or object IDs. It is not ray tracing.
/*
[configuration]
[OptionBool]
GUIName = Enable diorama treatment
OptionName = DioramaEnabled
DefaultValue = true
[OptionRangeFloat]
GUIName = Color treatment
OptionName = GradeStrength
MinValue = 0.0
MaxValue = 1.0
StepAmount = 0.05
DefaultValue = 0.8
[OptionRangeFloat]
GUIName = Bloom glow
OptionName = BloomStrength
MinValue = 0.0
MaxValue = 1.5
StepAmount = 0.05
DefaultValue = 0.4
[OptionRangeFloat]
GUIName = Miniature blur (screen position, not depth)
OptionName = BlurStrength
MinValue = 0.0
MaxValue = 2.0
StepAmount = 0.1
DefaultValue = 0.5
[OptionRangeFloat]
GUIName = Focus band vertical center
OptionName = FocusCenter
MinValue = 0.2
MaxValue = 0.8
StepAmount = 0.02
DefaultValue = 0.5
[OptionRangeFloat]
GUIName = Focus band width
OptionName = FocusWidth
MinValue = 0.1
MaxValue = 0.5
StepAmount = 0.02
DefaultValue = 0.24
[OptionRangeFloat]
GUIName = Pixel treatment
OptionName = PixelStrength
MinValue = 0.0
MaxValue = 1.0
StepAmount = 0.05
DefaultValue = 0.35
[OptionRangeFloat]
GUIName = Vignette
OptionName = VignetteStrength
MinValue = 0.0
MaxValue = 0.8
StepAmount = 0.05
DefaultValue = 0.25
[OptionBool]
GUIName = Keep HUD corners sharp
OptionName = ProtectCorners
DefaultValue = true
[OptionBool]
GUIName = Cascading sunlight rays
OptionName = SunRays
DefaultValue = true
[OptionRangeFloat]
GUIName = Sunlight ray strength (zero restores previous look)
OptionName = RayStrength
MinValue = 0.0
MaxValue = 2.5
StepAmount = 0.05
DefaultValue = 1.15
[OptionRangeFloat]
GUIName = Sunlight ray reach
OptionName = RayReach
MinValue = 0.2
MaxValue = 1.0
StepAmount = 0.05
DefaultValue = 0.85
[OptionRangeFloat]
GUIName = Sunlight origin horizontal (left to right)
OptionName = SunX
MinValue = 0.0
MaxValue = 1.0
StepAmount = 0.02
DefaultValue = 0.32
[OptionRangeFloat]
GUIName = Sunlight origin vertical (top to bottom)
OptionName = SunY
MinValue = 0.0
MaxValue = 0.5
StepAmount = 0.02
DefaultValue = 0.02
[/configuration]
*/

float3 ReadScene(float2 uv)
{
    return SampleLocation(clamp(uv,float2(0.001,0.001),float2(0.999,0.999))).rgb;
}

// Artistic screen-space scattering: bright upper-scene gaps supply light.
// No depth or sun tracking is available; bright scenery can also emit rays.
float SunMask(float2 uv)
{
    // Reject out-of-frame taps instead of smearing clamped border pixels.
    if(uv.x<=0.0 || uv.x>=1.0 || uv.y<=0.0 || uv.y>=1.0) return 0.0;
    float3 c=ReadScene(uv);
    float brightness=dot(c,float3(0.2126,0.7152,0.0722));
    float skyBand=1.0-smoothstep(0.32,0.58,uv.y);
    float edgeMask=smoothstep(0.04,0.16,uv.x)*(1.0-smoothstep(0.84,0.96,uv.x));
    return smoothstep(0.56,0.94,brightness)*skyBand*edgeMask;
}

float CascadingRays(float2 uv)
{
    float2 sun=float2(GetOption(SunX),GetOption(SunY));
    float2 delta=(sun-uv)*GetOption(RayReach);
    float2 axis=delta*GetResolution();
    float2 side=float2(-axis.y,axis.x)/max(length(axis),1.0)*GetInvResolution()*2.0;
    // Fixed subpixel phase prevents concentric sampling bands without animation flicker.
    float phase=fract(52.9829189*fract(dot(floor(uv*GetResolution()),float2(0.06711056,0.00583715))));
    float sum=0.0;
    for(int i=0;i<48;i++)
    {
        float t=(float(i)+phase)/48.0;
        float2 p=uv+delta*t;
        float mask=(SunMask(p-side)+SunMask(p+side))*0.5;
        sum+=mask*(1.0-t*0.65);
    }
    float distanceFromSun=length((uv-sun)*float2(GetResolution().x/GetResolution().y,1.0));
    float spread=smoothstep(0.04,0.2,distanceFromSun);
    float floorFade=1.0-smoothstep(0.65,1.0,uv.y);
    return sum/32.4*spread*floorFade;
}

void main()
{
    float2 uv=GetCoordinates();
    float4 original=Sample();
    if (!OptionEnabled(DioramaEnabled)) { SetOutput(original); return; }
    float2 sourceSize=GetResolution();
    float2 grid=float2(480.0,480.0*sourceSize.y/sourceSize.x);
    float2 pixelUV=(floor(uv*grid)+0.5)/grid;
    float3 color=mix(original.rgb,ReadScene(pixelUV),GetOption(PixelStrength));
    float corner=0.0;
    if(OptionEnabled(ProtectCorners))
        corner=smoothstep(0.23,0.4,abs(uv.x-0.5))*smoothstep(0.24,0.37,abs(uv.y-0.5));
    float blurBand=smoothstep(GetOption(FocusWidth)*0.5,0.48,abs(uv.y-GetOption(FocusCenter)));
    float radius=blurBand*GetOption(BlurStrength)*6.0;
    float3 blurred=float3(0.0,0.0,0.0);float weightSum=0.0;
    // Dense Gaussian grid avoids sparse circular sampling ghosts.
    for(int y=-2;y<=2;y++)for(int x=-2;x<=2;x++)
    {
        float weight=exp(-float(x*x+y*y)*0.55);
        blurred+=ReadScene(uv+float2(float(x),float(y))*radius*GetInvResolution())*weight;
        weightSum+=weight;
    }
    color=mix(color,blurred/weightSum,clamp(radius,0.0,1.0)*(1.0-corner));
    float3 glow=float3(0.0,0.0,0.0);
    for(int i=0;i<12;i++)
    {
        float angle=float(i)*2.399963;
        float ring=sqrt((float(i)+0.5)/12.0);
        float3 sampleColor=ReadScene(uv+float2(cos(angle),sin(angle))*(3.0+ring*18.0)*GetInvResolution());
        float luma=dot(sampleColor,float3(0.2126,0.7152,0.0722));
        glow+=sampleColor*smoothstep(0.65,0.95,luma);
    }
    color+=(float3(1.0,1.0,1.0)-color)*glow/12.0*GetOption(BloomStrength)*(1.0-corner*0.8);
    float luma=dot(color,float3(0.2126,0.7152,0.0722));
    float3 graded=mix(float3(luma,luma,luma),color,0.78);
    graded=mix(graded*float3(0.85,0.95,1.05),graded*float3(1.09,1.02,0.88),smoothstep(0.15,0.85,luma));
    graded=clamp((graded-0.5)*1.07+0.5,0.0,1.0);
    color=mix(color,graded,GetOption(GradeStrength));
    if(OptionEnabled(SunRays) && GetOption(RayStrength)>0.0)
    {
        float shafts=CascadingRays(uv)*(1.0-corner);
        float light=1.0-exp(-shafts*GetOption(RayStrength)*1.15);
        color+=(float3(1.0,1.0,1.0)-color)*float3(1.0,0.83,0.55)*light;
    }
    color*=1.0-GetOption(VignetteStrength)*smoothstep(0.18,0.68,length((uv-0.5)*float2(1.0,0.85)));
    color=mix(color,original.rgb,corner*0.7);
    SetOutput(float4(color,original.a));
}
