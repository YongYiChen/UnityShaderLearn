# 《Unity Shader 入门精要》记录

## Chapter 7 基础纹理

### 7.2凹凸映射

```CG
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shader Book/Chapter 7/NormalMapTangentSpace"{
    Properties{
        _Color ("Color Tint", Color) = (1,1,1,1)
        _MainTex ("Main Texture", 2D) = "white" {}
        _BumpMap ("Normal Map", 2D) = "bump" {}
        _BumpScale ("Bump Scale", Float) = 1.0
        _Specular ("Specular", Color) = (1,1,1,1)
        _Gloss ("Gloss", Range(6.0, 512)) = 20
    }    
    SubShader{
        Pass{
            Tags {"LightMode" = "ForwardBase"}
            CGPROGRAM
            #pragma vertex vert;
            #pragma fragment frag;
            
            #include <UnityCG.cginc>
            #include <Lighting.cginc>

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            fixed4 _Specular;
            float _BumpScale;
            float _Gloss;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD10;
                float3 lightDir : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                //分别存储两个贴图和法线贴图
                o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
 
                float3 binormal = cross(normalize(v.normal), normalize(v.tangent.xyz)) * v.tangent.w; //叉乘得副切线

                float3x3 rotation = float3x3(v.tangent.xyz, binormal, v.normal); //计算用于从模型空间变换到切线空间的矩阵
                //但是貌似Unity提供了这个？^_^ TANGENT_SPACE_ROTATION ^_^
                o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz; //变换光线到切线空间
                o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz; //变换观察视角到切线空间
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed3 tangentLightDir = normalize(i.lightDir);
                fixed3 tangentViewDir = normalize(i.viewDir);

                fixed4 packedNormal = tex2D(_BumpMap, i.uv.zw);
                fixed3 tangentNormal;

                tangentNormal = UnpackNormal(packedNormal);
                tangentNormal.xy *= _BumpScale;
                tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy))); //这行z分量是咋算出来的呀？我不理解

                fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(tangentNormal,tangentLightDir));
                fixed3 halfDir = normalize(tangentViewDir + tangentLightDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(tangentNormal, halfDir)),_Gloss);
                return fixed4(ambient + diffuse + specular, 1.0);
            }
            
            ENDCG
        }    
    }
    FallBack "Specular"
}
```

#### 效果展示

![凹凸映射](https://github.com/YongYiChen/UnityShaderLearn/blob/main/pic/%E5%87%B9%E5%87%B8%E6%98%A0%E5%B0%84.png)

场景为Scene_7_2_3
