Shader "Unlit/My2ndUnlitShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (0,1,0,1) //added
        _AmbientColor ("Ambient Color", Color) = (0.2,0.2,0.2,1) //added
        _SpecularColor ("Specular Color", Color) = (0.5,0.5,0.5,1) //added
        _Glossiness ("Glossiness", Float) = 32 //added
    }
    SubShader
    {
        // memes are dreams
        Tags { "RenderType"="Opaque" }
        Tags { 
            "LightMode" = "ForwardBase" // break this 
            "PassFlags" = "OnlyDirectional"
        } //added

        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL; //added 
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 worldNormal : NORMAL; //added
                float3 viewDir : TEXCOORD1; //added 
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color; //added
            float4 _AmbientColor; //added
            float _Glossiness; //added
            float4 _SpecularColor; //added
            

            v2f vert (appdata v)
            {

                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal); //added
                o.viewDir = WorldSpaceViewDir(v.vertex); //added calculates the view direction vs where the camera sees the object

                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 normal = normalize(i.worldNormal); //added
                float nl = dot(_WorldSpaceLightPos0, normal); //added
                float lightIntensity = smoothstep(0.0, 0.2, nl); //added
                //float lightIntensity = nl > 0 ? 1 : 0; //added
                float light = lightIntensity * _LightColor0; //added

                float3 viewDir = normalize(i.viewDir); //added
                float3 halfVector = normalize(_WorldSpaceLightPos0 + viewDir); //added

                float nh = dot(normal, halfVector); //added
                float specularIntensity = pow(nh * lightIntensity, _Glossiness * _Glossiness); //added
                float specAdjustment = smoothstep(0.0, 1, nh); //added
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col * _Color * (light + _AmbientColor + specularIntensity); //added _Color
            }
            ENDCG
        }
        UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
    }
}