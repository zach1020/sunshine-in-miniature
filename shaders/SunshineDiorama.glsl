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
[/configuration]
*/

float3 ReadScene(float2 uv)
{
    return SampleLocation(clamp(uv,float2(0.001,0.001),float2(0.999,0.999))).rgb;
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
    color*=1.0-GetOption(VignetteStrength)*smoothstep(0.18,0.68,length((uv-0.5)*float2(1.0,0.85)));
    color=mix(color,original.rgb,corner*0.7);
    SetOutput(float4(color,original.a));
}
