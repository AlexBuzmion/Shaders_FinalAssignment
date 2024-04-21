Shader "Custom/TotallyDynamicShaderV2"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _EmissionColor ("Emission Color", Color) = (0,0,0,1)
        _BumpMap ("Normal Map", 2D) = "bump" {}
        _SecondaryTex ("Secondary Texture", 2D) = "white" {}
        _BlendFactor ("Blend Factor", Range(0,1)) = 0.5
        _PulseColor ("Pulse Color", Color) = (1, 0, 0, 1)
        _PulseRate ("Pulse Rate", Float) = 1.0
        _RippleMagnitude ("Ripple Magnitude", Float) = 0.1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _SecondaryTex;
        sampler2D _BumpMap;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_SecondaryTex;
            float2 uv_BumpMap;
            float3 worldPos;
            float3 worldRefl; // World reflection vector
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        fixed4 _EmissionColor;
        fixed4 _PulseColor;
        float _BlendFactor;
        float _PulseRate;
        float _RippleMagnitude;

        UNITY_INSTANCING_BUFFER_START(Props)
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Scrolling texture coordinates over time
            IN.uv_MainTex += float2(_Time.y, _Time.y) * 0.1;

            // Ripple effect
            float ripple = sin(dot(IN.worldPos.xy, float2(12.9898, 78.233)) * 25.0 + _Time.y * 10.0) * _RippleMagnitude;
            IN.uv_MainTex += ripple;

            // Pulsating color effect
            fixed4 pulsate = lerp(_Color, _PulseColor, 0.5 + 0.5 * sin(_Time.y * _PulseRate));

            // Mix textures based on blend factor
            fixed4 c = lerp(tex2D(_MainTex, IN.uv_MainTex), tex2D(_SecondaryTex, IN.uv_MainTex), _BlendFactor) * pulsate;

            // Normal map for added depth
            o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));

            // Adding light-dependent color change
            fixed3 lightDir = normalize(UnityWorldSpaceLightDir(IN.worldPos)); // Direction to the light
            float NdotL = max(0, dot(o.Normal, lightDir));
            fixed4 lightColor = _Color * NdotL; // Light intensity based on angle

            o.Albedo = c.rgb + lightColor.rgb;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Emission = _EmissionColor.rgb * c.rgb;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
