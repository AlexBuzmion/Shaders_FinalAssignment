Shader "Custom/Class_05Shader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _BumpMap ("Normal Map", 2D) = "bump" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _ParallaxMap ("Height Map", 2D) = "black" {}
        _Parallax ("Height", Range(0,0.1)) = 0.02
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

            fixed3 normal = UnpackNormal(tex2D(_BumpMap, parallaxUV)); 

            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
            o.Normal = normal; 
        }
        ENDCG
    }
    FallBack "Diffuse"
}
