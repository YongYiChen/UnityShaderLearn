Shader "Unity Shader Book/Chapter 6/Specular Vertex"
{
    Properties
    {
        _diffuse("diffuse",Color) = (1,1,1,1)
        _specular("Specular",Color) = (1,1,1,1)
        _gloss("Gloss",Range(1,20)) = 5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            
            fixed4 _diffuse;
            fixed4 _specular;
            float _gloss;
            
            struct v2f
            {
                float4 vertex : SV_POSITION;
                fixed3 color : Color;
            };


            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                //将法线转换到世界坐标下的法线
                fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
                //光源方向
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                
                fixed3 diffuse = _LightColor0.rgb * _diffuse.rgb * saturate(dot(worldNormal,worldLightDir));
                //计算反射方向，reflect方法就是计算基于法线方向的入射光线的反射光线的计算。由于方法计算与unity的世界光照方向相反，所以需要加个-值
                fixed3 reflectDir = normalize(reflect(-worldLightDir, worldNormal)); //反射光线方向
                
                //fixed3 viewDir = normalize(WorldSpaceViewDir(v.vertex)); //unity自己提供的一个计算视角 方向的函数
                
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld, v.vertex).xyz); //计算视角方向
                
                //phong高光反射公式，gloss为调整高光程度的一个次幂级数
                fixed3 specular = _LightColor0.rgb * _specular.rgb * pow(saturate(dot(reflectDir, viewDir)), _gloss);
                
                o.color =  diffuse + ambient + specular;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return fixed4(i.color,1);
            }
            ENDCG
        }
    }
}


