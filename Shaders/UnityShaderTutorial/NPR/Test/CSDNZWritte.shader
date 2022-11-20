Shader "Unlit/Ouline"
{
    Properties
    {
	_OutlineWidth ("Outline Width", Range(0.001, 1)) = 0.24
        _OutLineColor ("OutLine Color", Color) = (0.5,0.5,0.5,1)

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        pass
        {
           Tags {"LightMode"="ForwardBase"}
			 
            Cull Back
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            float4 vert(appdata_base v): SV_POSITION
	    {
                return UnityObjectToClipPos(v.vertex);
            }

            half4 frag() : SV_TARGET 
	   {
                return half4(1,1,1,1);
            }

            ENDCG
        }

        Pass
	{
	    Tags {"LightMode"="ForwardBase"}
			 
            Cull Front
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            half _OutlineWidth;
            half4 _OutLineColor;

            struct a2v 
	    {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
                float4 vertColor : COLOR;
                float4 tangent : TANGENT;
            };

            struct v2f
	   {
                float4 pos : SV_POSITION;
            };


            v2f vert (a2v v) 
	        {
                v2f o;
                UNITY_INITIALIZE_OUTPUT(v2f, o);
                float4 pos = UnityObjectToClipPos(v.vertex);
                float3 viewNormal = mul((float3x3)UNITY_MATRIX_IT_MV, v.tangent.xyz);
                float3 ndcNormal = normalize(TransformViewToProjection(viewNormal.xyz)) * pos.w;//将法线变换到NDC空间
                float4 nearUpperRight = mul(unity_CameraInvProjection, float4(1, 1, UNITY_NEAR_CLIP_VALUE, _ProjectionParams.y));//将近裁剪面右上角位置的顶点变换到观察空间
                float aspect = abs(nearUpperRight.y / nearUpperRight.x);//求得屏幕宽高比
                ndcNormal.x *= aspect;
                pos.xy +=  _OutlineWidth * ndcNormal.xy;
                o.pos = pos;
                return o;
            }

            half4 frag(v2f i) : SV_TARGET 
	    {
                return _OutLineColor;
            }
            ENDCG
        }
    }
}