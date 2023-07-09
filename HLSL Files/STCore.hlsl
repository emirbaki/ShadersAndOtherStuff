#ifndef STCORE_INCLUDED
#define STCORE_INCLUDED

#include "STFunctions.hlsl"

float _MaxAtten = 1;

float Toon_float(float dot, float atten, out float result)
{
    _MaxLight = max(_MinLight, _MaxLight);
    
    _Steps = _Segmented * _Steps + (1 - _Segmented) * 1;
    _StpSmooth = _Segmented * _StpSmooth + (1 - _Segmented) * 1;
    
    float offset = clamp(_Offset, -1, 1);
    float delta = _MaxLight - _MinLight;

	//intense
    float ints_pls = dot + offset;
    float ints_max = 1.0 + offset;
    float intense = clamp01(ints_pls / ints_max);

	//lit
    float step = 1.0 / floor(_Steps);
    int lit_num = ceil(intense / step);
    float lit = lit_num * step;

	//smooth
    float reduce_v = _Offset - 1.0;
    float reduce_res = 1.0 - clamp01(reduce_v / 0.1); //!v offset plus
    float reduce = lit_num == 1 ? reduce_res : 1;

    float smth_start = lit - step;
    float smth_end = smth_start + step * _StpSmooth;

    float smth_lrp = invLerp01(smth_end, smth_start, intense);
    float smth_stp = smoothstep(smth_end, smth_start, intense, 0.);

    float smooth_v = smoothlerp(smth_stp, smth_lrp, _StpSmooth);
    float smooth = clamp01(lit - smooth_v * reduce * step);

	//shadow
    float atten_inv = clamp(atten, 1.0 - _MaxAtten, 1);
    float dimLit = smooth * atten_inv;
    float dim_dlt = dimLit - _MinLight;

	//luminocity
    float lumLight = _MaxLight + _Lumin;
    float lum_dlt = lumLight - _MinLight;

	//clipped
    float litd_clmp = clamp01(dim_dlt);
    float clip_cf = litd_clmp / delta;

    float clip_uncl = _MinLight + clip_cf * lum_dlt;
    float clip_v = clamp(clip_uncl, _MinLight, lumLight);

	//relative limits
    float lerp_v = lum_dlt * dimLit;
    float relate_v = _MinLight + lerp_v;

	//result
    result = _Clipped * clip_v;
    result += !_Clipped * relate_v;

    return result;
}

//post effects

void PostShineVoid(inout float4 col, float dot, float atten)
{
    float pos = abs(dot - 1.0);
    float len = _ShineRange * 2;

    float smth_inv = 1.0 - _ShineSmoothness;
    float smth_end = len * smth_inv;

    float shine = posz(len - pos);
    float smooth = smoothstep(len, smth_end, pos, 1.);
    float dim = 1.0 - _MaxAtten * rev(atten) * rev(_ShineOverlap);

    float blend = _ShineIntense * shine * smooth * dim;
    col = ColorBlend(col, _ShineColor, blend);
}
float4 PostShine(inout float4 col, float dot, float atten)
{
    float pos = abs(dot - 1.0);
    float len = _ShineRange * 2;

    float smth_inv = 1.0 - _ShineSmoothness;
    float smth_end = len * smth_inv;

    float shine = posz(len - pos);
    float smooth = smoothstep(len, smth_end, pos, 1.);
    float dim = 1.0 - _MaxAtten * rev(atten) * rev(_ShineOverlap);

    float blend = _ShineIntense * shine * smooth * dim;
    col = ColorBlend(col, _ShineColor, blend);
    return col;
}
float4 PostEffects(inout float4 col, float toon, float atten, float NdotL, float NdotH, float VdotN, float FdotV)
{
    PostShine(col, NdotL, atten);

    return col;
}
void PostEffects_float(float4 col, float toon, float atten, float NdotL, float NdotH, float VdotN, float FdotV, out float4 Out)
{
    Out = PostShine(col, NdotL, atten);
}


#endif
