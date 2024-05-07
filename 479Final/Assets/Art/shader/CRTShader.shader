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
        // Add a property for bloom threshold
        _BloomThreshold ("Bloom Threshold", Float) = 1.0
        _VignetteIntensity ("Vignette Intensity", Range(0.0, 2.0)) = 0.5
        _VignetteSmoothness ("Vignette Smoothness", Range(0.01, 1.0)) = 0.5
        _VignetteEdgeColor ("Vignette Edge Color", Color) = (0,0,0,1)
        _FlickerFrequency ("Flicker Frequency", Float) = 10.0
        _FlickerIntensity ("Flicker Intensity", Range(0.0, 1.0)) = 0.1

        // Add more properties for other effects as needed
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
            float4 _OutOfBoundColour; // Corrected type for color
            float _BloomThreshold;
            float _VignetteIntensity;
            float _VignetteSmoothness;
            float4 _VignetteEdgeColor; // Corrected type for color
            float _FlickerFrequency;
            float _FlickerIntensity;
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }
            // Function to create scanline effect
            float ScanlineEffect(float2 uv, float width, float intensity)
            {
                float screenResolutionY = 1080.0; // Replace with actual vertical resolution or pass as a uniform
                float value = uv.y * screenResolutionY * 3.14159265; // PI as a float constant
                float lineEffect = sin(value) * intensity;

                return 1.0 - lineEffect * width;
            }


            // Fragment shader
            float4 frag (v2f i) : SV_Target
            {
                // Apply lens distortion to UV coordinates
                float2 uvNormalized = i.uv * 2 - 1; // Remap UV from (0,1) to (-1,1)
                float distortionMagnitude = abs(uvNormalized.x * uvNormalized.y);
                float smoothDistortionMagnitude = pow(distortionMagnitude, _LensDistortionStrength);
                float2 uvDistorted = i.uv + uvNormalized * smoothDistortionMagnitude * _LensDistortionStrength;

                // Handle out-of-bound UVs
                if (uvDistorted.x < 0 || uvDistorted.x > 1 || uvDistorted.y < 0 || uvDistorted.y > 1)
                {
                    return _OutOfBoundColour; // Out-of-bound color
                }

                // Now apply the other effects to the distorted UVs

                // Sample the texture with distorted UVs
                float4 col = tex2D(_MainTex, uvDistorted);

                // Apply RGB color offset to distorted UVs
                float3 rgbOffset = float3(_RGBOffset, 0, -_RGBOffset);
                float3 colorR = tex2D(_MainTex, uvDistorted + rgbOffset.xx).rgb;
                float3 colorG = tex2D(_MainTex, uvDistorted + rgbOffset.yy).rgb;
                float3 colorB = tex2D(_MainTex, uvDistorted + rgbOffset.zz).rgb;
                col.rgb = float3(colorR.r, colorG.g, colorB.b);

                // Determine if the color exceeds the bloom threshold
                float luminance = dot(col.rgb, float3(0.299, 0.587, 0.114));
                float4 bloom = col * step(_BloomThreshold, luminance);

                // Add scanline effect to distorted UVs
                col *= ScanlineEffect(uvDistorted, _ScanlineWidth, _ScanlineIntensity);
                // Add bloom back to the original color
                col += bloom;

            // Calculate vignette factor
                float2 uv = i.uv * 2 - 1; // Remap UV to [-1, 1]
                float radius = length(uv);
                float vignette = smoothstep(0.0, _VignetteIntensity, radius);
                vignette *= smoothstep(0.0, _VignetteSmoothness, radius);
                vignette = 1.0 - vignette;

                float4 edgeColor = _VignetteEdgeColor;
                col = lerp(edgeColor, col, vignette);
                // Optionally, you can blend with the vignette edge color
                // col = lerp(col, _VignetteEdgeColor, vignette);



                // Flicker effect
                float flicker = abs(sin(_Time.y * _FlickerFrequency)) * _FlickerIntensity + (1.0 - _FlickerIntensity);
                col *= flicker;

                return col;
            }



            ENDCG
        }
    }
    FallBack "Diffuse"
}
