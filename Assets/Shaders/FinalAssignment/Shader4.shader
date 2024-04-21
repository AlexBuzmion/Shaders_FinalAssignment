Shader "A5/Shader4"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BumpMap ("Normal", 2D) = "bump" {}
        _ScaleFactor ("Scale factor", Float) = 1.0
        _EnvMap ("Environment Map", CUBE) = "" {}
    }
    
    SubShader
    {
        Tags { "Queue" = "Transparent" }
        
        GrabPass {}

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _GrabTexture;
            float4 _GrabTexture_TexelSize;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            float _ScaleFactor;
            samplerCUBE _EnvMap;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };
            
            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 uvgrab : TEXCOORD2;
                float2 uvbump : TEXCOORD3;
                float3 worldRefl : TEXCOORD4;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                
                #if UNITY_UV_STARTS_AT_TOP
                    float scale = -1.0;
                #else
                    float scale = 1.0;
                #endif
                
                o.uvgrab.xy = (float2(o.vertex.x, o.vertex.y * scale) + o.vertex.w) * 0.5;
                o.uvgrab.zw = o.vertex.zw;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uvbump = TRANSFORM_TEX(v.uv, _BumpMap);
                o.worldRefl = mul((float3x3)UNITY_MATRIX_IT_MV, v.vertex.xyz);
                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET
            {
                half2 bump = UnpackNormal(tex2D(_BumpMap, i.uvbump)).rg;
                float2 offset = bump * sin(_Time.y) * _GrabTexture_TexelSize.xy;
                i.uvgrab.xy += offset;

                float v = 0.0;
                float2 c = i.worldRefl.xy * _ScaleFactor - _ScaleFactor / 2.0;
                v += sin((c.x + _Time.y));
                v += sin((c.y + _Time.y) / 2.0);
                v += sin((c.x + c.y + _Time.y) / 2.0);
                c += _ScaleFactor / 2.0 * float2(sin(_Time.y / 3.0), cos(_Time.y / 2.0));
                v += sin(sqrt(c.x * c.x + c.y * c.y + 1.0) + _Time.y);
                v /= 2.0;

                fixed4 col = tex2Dproj(_GrabTexture, UNITY_PROJ_COORD(i.uvgrab));
                fixed4 tint = tex2D(_MainTex, i.uv);
                col *= tint;

                fixed3 plasmaColor;
                plasmaColor.r = sin(v * UNITY_PI);
                plasmaColor.g = sin(v * UNITY_PI + 2.0 * UNITY_PI / 3.0);
                plasmaColor.b = sin(v * UNITY_PI + 4.0 * UNITY_PI / 3.0);

                return fixed4(plasmaColor * 0.5 + 0.5, 1) * col;
            }
            ENDCG
        }
    }
}
