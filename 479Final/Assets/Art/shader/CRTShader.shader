Shader "Custom/CRTShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ScanlineWidth ("Scanline Width", Float) = 0.002
        _ScanlineIntensity ("Scanline Intensity", Float) = 0.3     
        _RGBOffset ("RGB Offset", Float) = 0.005
        _LensDistortionStrength ("Lens Distortion Strength", Float) = 0.5
        _OutOfBoundColour ("Out of Bound Color", Color) = (0,0,0,1)
        _BloomThreshold ("Bloom Threshold", Float) = 1.0
        _FlickerFrequency ("Flicker Frequency", Float) = 10.0
        _FlickerIntensity ("Flicker Intensity", Range(0.0, 1.0)) = 0.1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float _ScanlineWidth;
            float _ScanlineIntensity;
            float _RGBOffset;
            float _LensDistortionStrength;
            float4 _OutOfBoundColour;
            float _BloomThreshold;
            float _FlickerFrequency;
            float _FlickerIntensity;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float ScanlineEffect(float2 uv, float width, float intensity)
            {
                float screenResolutionY = 1080.0;
                float value = uv.y * screenResolutionY * 3.14159265;
                float lineEffect = sin(value) * intensity;

                return 1.0 - lineEffect * width;
            }

            float4 frag (v2f i) : SV_Target
            {
                float2 uvNormalized = i.uv * 2 - 1;
                float distortionMagnitude = abs(uvNormalized.x * uvNormalized.y);
                float smoothDistortionMagnitude = pow(distortionMagnitude, _LensDistortionStrength);
                float2 uvDistorted = i.uv + uvNormalized * smoothDistortionMagnitude * _LensDistortionStrength;

                if (uvDistorted.x < 0 || uvDistorted.x > 1 || uvDistorted.y < 0 || uvDistorted.y > 1)
                    return _OutOfBoundColour;

                float4 col = tex2D(_MainTex, uvDistorted);

                float3 rgbOffset = float3(_RGBOffset, 0, -_RGBOffset);
                float3 colorR = tex2D(_MainTex, uvDistorted + rgbOffset.xx).rgb;
                float3 colorG = tex2D(_MainTex, uvDistorted + rgbOffset.yy).rgb;
                float3 colorB = tex2D(_MainTex, uvDistorted + rgbOffset.zz).rgb;
                col.rgb = float3(colorR.r, colorG.g, colorB.b);

                float luminance = dot(col.rgb, float3(0.299, 0.587, 0.114));
                float4 bloom = col * step(_BloomThreshold, luminance);

                col *= ScanlineEffect(uvDistorted, _ScanlineWidth, _ScanlineIntensity);
                col += bloom;

                float flicker = abs(sin(_Time.y * _FlickerFrequency)) * _FlickerIntensity + (1.0 - _FlickerIntensity);
                col *= flicker;

                return col;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
