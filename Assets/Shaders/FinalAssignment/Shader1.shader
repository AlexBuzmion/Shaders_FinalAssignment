Shader "A5/Shader1"
{
    Properties
    {
        _EnvMap ("Environment Map", CUBE) = "" {}
    }
    
    SubShader
    {
        CGPROGRAM
        #pragma surface surf Lambert
        
        samplerCUBE _EnvMap;
        
        struct Input
        {
            float3 worldRefl;
        };
        
        void surf(Input IN, inout SurfaceOutput o)
        {
            float3 animatedRefl = IN.worldRefl;
            animatedRefl.x *= sin(_Time * 50.5);
            animatedRefl.z *= cos(_Time * 10.5); 
            
            o.Emission = texCUBE(_EnvMap, animatedRefl).rgb;
            o.Albedo = animatedRefl;
        }
        ENDCG
    }
}
