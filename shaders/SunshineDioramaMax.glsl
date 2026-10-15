// MarioSunshineRay: DIORAMA MAX. Opt-in exaggerated miniature treatment.
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
DefaultValue = 1.0
[OptionRangeFloat]
GUIName = Bloom glow
OptionName = BloomStrength
MinValue = 0.0
MaxValue = 1.5
StepAmount = 0.05
DefaultValue = 0.85
[OptionRangeFloat]
GUIName = Miniature blur (screen position, not depth)
OptionName = BlurStrength
MinValue = 0.0
MaxValue = 2.0
StepAmount = 0.1
DefaultValue = 1.8
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
DefaultValue = 0.16
[OptionRangeFloat]
GUIName = Pixel treatment
OptionName = PixelStrength
MinValue = 0.0
MaxValue = 1.0
StepAmount = 0.05
DefaultValue = 0.65
[OptionRangeFloat]
GUIName = Vignette
OptionName = VignetteStrength
MinValue = 0.0
MaxValue = 0.8
StepAmount = 0.05
DefaultValue = 0.45
[OptionBool]
GUIName = Keep HUD corners sharp
OptionName = ProtectCorners
DefaultValue = true
[OptionBool]
GUIName = Crisp mode for dialogue and cutscenes
OptionName = CrispMode
DefaultValue = false
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
    float2 grid=float2(360.0,360.0*sourceSize.y/sourceSize.x);
    float2 pixelUV=(floor(uv*grid)+0.5)/grid;
    float3 color=mix(original.rgb,ReadScene(pixelUV),(OptionEnabled(CrispMode)?0.0:GetOption(PixelStrength)));
    float corner=0.0;
    if(OptionEnabled(ProtectCorners))
        corner=smoothstep(0.23,0.4,abs(uv.x-0.5))*smoothstep(0.24,0.37,abs(uv.y-0.5));
    float blurBand=smoothstep(GetOption(FocusWidth)*0.5,0.48,abs(uv.y-GetOption(FocusCenter)));
    float radius=OptionEnabled(CrispMode)?0.0:blurBand*GetOption(BlurStrength)*6.0;
    float3 blurred=float3(0.0,0.0,0.0);float weightSum=0.0;
    // Dense Gaussian grid avoids sparse circular sampling ghosts.
    for(int y=-4;y<=4;y++)for(int x=-4;x<=4;x++)
    {
        float weight=exp(-float(x*x+y*y)*0.14);
        blurred+=ReadScene(uv+float2(float(x),float(y))*radius*0.5*GetInvResolution())*weight;
        weightSum+=weight;
    }
    color=mix(color,blurred/weightSum,clamp(radius,0.0,1.0)*(1.0-corner));
    float3 glow=float3(0.0,0.0,0.0);
    for(int i=0;i<24;i++)
    {
        float angle=float(i)*2.399963;
        float ring=sqrt((float(i)+0.5)/24.0);
        float3 sampleColor=ReadScene(uv+float2(cos(angle),sin(angle))*(2.0+ring*24.0)*GetInvResolution());
        float luma=dot(sampleColor,float3(0.2126,0.7152,0.0722));
        glow+=sampleColor*smoothstep(0.65,0.95,luma);
    }
    color+=(float3(1.0,1.0,1.0)-color)*glow/24.0*(OptionEnabled(CrispMode)?0.0:GetOption(BloomStrength))*(1.0-corner*0.8);
    float luma=dot(color,float3(0.2126,0.7152,0.0722));
    float3 graded=mix(float3(luma,luma,luma),color,0.9);
    graded=mix(graded*float3(0.82,0.96,1.08),graded*float3(1.12,1.035,0.86),smoothstep(0.15,0.85,luma));
    graded=clamp((graded-0.5)*1.12+0.5,0.0,1.0);
    color=mix(color,graded,GetOption(GradeStrength));
    color*=1.0-GetOption(VignetteStrength)*smoothstep(0.18,0.68,length((uv-0.5)*float2(1.0,0.85)));
    color=mix(color,original.rgb,corner*0.7);
    SetOutput(float4(color,original.a));
}
