Shader "FullScreen/CRTFullScreenPass"
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

    HLSLINCLUDE

    #pragma vertex Vert
    #pragma target 4.5
    #pragma only_renderers d3d11 playstation xboxone xboxseries vulkan metal switch
    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/RenderPass/CustomPass/CustomPassCommon.hlsl"

    TEXTURE2D(_MainTex);
    SAMPLER(sampler_MainTex);

    CBUFFER_START(UnityPerMaterial)
        float _ScanlineWidth;
        float _ScanlineIntensity;
        float _RGBOffset;
        float _LensDistortionStrength;
        float4 _OutOfBoundColour;
        float _BloomThreshold;
        float _FlickerFrequency;
        float _FlickerIntensity;
    CBUFFER_END


    float ScanlineEffect(float2 uv, float width, float intensity)
    {
        float screenResolutionY = 1080.0;
        float value = uv.y * screenResolutionY * 3.14159265;
        float lineEffect = sin(value) * intensity;
        return 1.0 - lineEffect * width;
    }

    float4 FullScreenPass(Varyings varyings) : SV_Target
    {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(varyings);
        float depth = LoadCameraDepth(varyings.positionCS.xy);
        PositionInputs posInput = GetPositionInput(varyings.positionCS.xy, _ScreenSize.zw, depth, UNITY_MATRIX_I_VP, UNITY_MATRIX_V);
        float3 viewDirection = GetWorldSpaceNormalizeViewDir(posInput.positionWS);
    
        // Calculate distortion based on normalized UV coordinates
        float2 uvNormalized = posInput.positionNDC * 2.0 - 1.0;
        float distortionMagnitude = abs(uvNormalized.x * uvNormalized.y);
        float smoothDistortionMagnitude = pow(distortionMagnitude, _LensDistortionStrength);
        float2 uvDistorted = posInput.positionNDC + uvNormalized * smoothDistortionMagnitude * _LensDistortionStrength;
    
        // Return out of bounds color if necessary
        if (uvDistorted.x < 0 || uvDistorted.x > 1 || uvDistorted.y < 0 || uvDistorted.y > 1)
            return _OutOfBoundColour;
    
        // Sample the camera color buffer
        float3 sampledColor = SampleCameraColor(uvDistorted).rgb;
        float4 col = float4(sampledColor, 1.0);
        
    
        // Apply RGB offset for chromatic aberration
        float3 rgbOffset = float3(_RGBOffset, 0, -_RGBOffset);
        float3 colorR = SampleCameraColor(uvDistorted + rgbOffset.xx).rgb;
        float3 colorG = SampleCameraColor(uvDistorted + rgbOffset.yy).rgb;
        float3 colorB = SampleCameraColor(uvDistorted + rgbOffset.zz).rgb;
        col.rgb = float3(colorR.r, colorG.g, colorB.b);
    
        // Compute luminance and apply bloom effect
        float luminance = dot(col.rgb, float3(0.299, 0.587, 0.114));
        float4 bloom = col * step(_BloomThreshold, luminance);
    
        // Apply scanlines
        col *= ScanlineEffect(uvDistorted, _ScanlineWidth, _ScanlineIntensity);
        col += bloom;
    
        // Apply flicker effect
        float flicker = abs(sin(_Time.y * _FlickerFrequency)) * _FlickerIntensity + (1.0 - _FlickerIntensity);
        col *= flicker;
    
        return col;
    }
    

    ENDHLSL

    SubShader
    {
        Tags{ "RenderPipeline" = "HDRenderPipeline" }
        Pass
        {
            Name "Custom Pass 0"

            ZWrite Off
            ZTest Always
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off

            HLSLPROGRAM
                #pragma fragment FullScreenPass
            ENDHLSL
        }
    }
    Fallback Off
}
