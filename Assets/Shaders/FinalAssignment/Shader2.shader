Shader "A5/Shader2"
{
    Properties 
    {
        _BumpMap ("Bump Texture", 2D) = "bump" {}
        _EnvMap ("Environment Map", CUBE) = "" {}
        _Color ("Main Color", Color) = (1, 1, 1, 1)
        _RimPow ("Rim power", Range(0.01, 10.0)) = 0.01
        [Toggle(SWITCH_ORDER)] _switchOrder("Switch order", Float) = 0
    }
    
    SubShader 
    {
        CGPROGRAM
        #pragma surface surf Lambert
        #pragma shader_feature SWITCH_ORDER
        
        sampler2D _BumpMap;
        samplerCUBE _EnvMap;
        fixed4 _Color;
        fixed _RimPow;

        struct Input
        {
            float3 viewDir;
            float2 uv_BumpMap;
            float3 worldRefl; INTERNAL_DATA
        };
        
        void surf(Input IN, inout SurfaceOutput o) 
        {
            #if SWITCH_ORDER
                o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap)) * (_SinTime.w * 0.5 + 0.5);
                o.Albedo = texCUBE(_EnvMap, WorldReflectionVector(IN, o.Normal)).rgb;
                float rim = 1.0 - saturate(dot(IN.viewDir, o.Normal));
                o.Emission = _Color  * pow(rim, _RimPow * (sin(_Time.w) * 0.5 + 0.5));   
            #else
                o.Albedo = texCUBE(_EnvMap, WorldReflectionVector(IN, o.Normal)).rgb;
                o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap)) * (_SinTime.w * 0.5 + 0.5);
            #endif
            
        }
        ENDCG
    }
}