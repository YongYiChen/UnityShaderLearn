// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Hi Shader Tutorial/Outline"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        
        _OutlineWidth ("Outline Width", Range(0.001, 1)) = 0.001
        _OutlineColor ("Outline Color", Color) = (0,0,0,0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        
        Pass{
            ZWrite Off    
            
            CGPROGRAM
            
            #include <UnityCG.cginc>

            #pragma vertex vert;
            #pragma fragment frag;

            float _OutlineWidth;
            fixed4 _OutlineColor;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                fixed4 color : TEXCOORD0;
            };

            v2f vert(appdata v)
            {
                v2f o;
                float4 newVertex = float4(v.tangent.xyz + v.normal * _OutlineWidth * 0.000001,1);
                o.vertex = UnityObjectToClipPos(newVertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                return (0,0,0,0);
            }
            
            ENDCG
        }
        
        Pass
        {
            CGPROGRAM
            #include <UnityCG.cginc>
            
            #pragma vertex vert;
            #pragma fragment frag;

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                fixed4 color : TEXCOORD0;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                return fixed4(1,1,1,1);
            }
            ENDCG
        }
    }
}
