float random(in float2 st)
{
    return frac(sin(dot(st.xy,
                         float2(12.9898, 78.233)))
                * 43758.5453123);
}

// Value noise by Inigo Quilez - iq/2013
// https://www.shadertoy.com/view/lsf3WH
float noise(float2 st)
{
    float2 i = floor(st);
    float2 f = frac(st);
    float2 u = f * f * (3.0 - 2.0 * f);
    return lerp(lerp(random(i + float2(0.0, 0.0)),
                     random(i + float2(1.0, 0.0)), u.x),
                lerp(random(i + float2(0.0, 1.0)),
                     random(i + float2(1.0, 1.0)), u.x), u.y);
}

float2x2 rotate2d(float angle)
{
    return float2x2(cos(angle), -sin(angle),
                sin(angle), cos(angle));
}

float lines(in float2 pos, float b)
{
    float scale = 10.0;
    pos *= scale;
    return smoothstep(0.0,
                    .5 + b * .5,
                    abs((sin(pos.x * 3.1415) + b * 2.0)) * .5);
}

void createNoise_float(in float2 uv, float2 scale, out float pattern)
{ 
    float2 pos = uv * scale;
    pattern = pos.x;

    // Add noise
    pos = rotate2d(noise(pos))._m00_m00 * pos;

    // Draw lines
    pattern = lines(pos, .5);
}