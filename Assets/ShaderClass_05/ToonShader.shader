Shader "Custom/ToonShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _BumpMap ("Normal Map", 2D) = "bump" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _ParallaxMap ("Height Map", 2D) = "black" {}
        _Parallax ("Parallax Height", Range(0, 0.1)) = 0.02
        _RimColor ("Rim Color", Color) = (1,1,1,1)
        _RimAmount ("Rim Amount", Range(0,1)) = 0.7
        _RimThreshold ("Rim Threshold", Range(0,1)) = 0.1
        _NumDiffuseBands ("Diffuse Bands", Range(0,10)) = 3
        _NumSpecBands ( "Specular Bands", Range(0,10)) = 4
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _BumpMap;
        sampler2D _ParallaxMap;
        float _Parallax;
        fixed4 _RimColor;
        fixed _RimAmount;
        fixed _RimThreshold;

        float _NumDiffuseBands;
        float _NumSpecBands;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_BumpMap;
            float3 viewDir;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        float2 ParallaxOffset(float2 uv, float3 viewDir, sampler2D heightMap, float heightScale)
        {
            float height = tex2D(heightMap, uv).r;

            float2 offset = (viewDir.xy / viewDir.z) * (height * heightScale);
            return uv - offset;
        }

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            float2 parallaxUV = ParallaxOffset(IN.uv_MainTex, IN.viewDir, _ParallaxMap, _Parallax);
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, parallaxUV) * _Color;
            o.Albedo = c.rgb;

            //fixed3 normal = UnpackNormal(tex2D(_BumpMap, IN.uv_MainTex));
            //o.Normal = normal;

            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;

            half rim = pow(1.0 - max(dot(IN.viewDir, o.Normal), 0.0), _RimThreshold);
            rim = smoothstep(_RimAmount - 0.01, _RimAmount + 0.01, rim);
            o.Emission += rim * _RimColor.rgb;

            float NdotL = max(dot(o.Normal, _WorldSpaceLightPos0.xyz), 0.0);
            NdotL = floor(NdotL * _NumDiffuseBands + 0.5) / _NumDiffuseBands;
            fixed3 toonDiffuse = lerp(fixed3(0,0,0), o.Albedo, NdotL+0.1);

            float3 viewDir = normalize(IN.viewDir);
            float3 halfDir = normalize(_WorldSpaceLightPos0.xyz + viewDir);
            float NdotH = max(dot(o.Normal, halfDir), 0.0);
            float specular = pow(NdotH * NdotL, o.Smoothness);
            specular = floor(specular * _NumSpecBands) / _NumSpecBands;

            fixed3 toonSpecular = o.Smoothness * specular * (specular > 0.0);

            o.Albedo = toonDiffuse + toonSpecular;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
