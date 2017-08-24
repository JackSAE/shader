Shader "Custom/CelShader" {
	Properties {
		_MainTex ("Texture", 2D) = "white" {}
		_celThreshold("Cel shader Threshold",Range(1.,25.))=5.
		_Ambient("Ambient inensity", Range(0.,0.5))=.1
		_lineThreshold("Outline Width",Range(0.,1))=.3
		_lineColour("Outline Colour",Color) = (0,0,0,1)
	}

	CGINCLUDE
	#pragma vertex vert
    #pragma fragment frag
           
    #include "UnityCG.cginc"

	struct v2f{
		float4 pos : SV_POSITION;
		float3 wNormal : NORMAL;
		float2 uv : TEXCOORD0;
	};

	//Outline Stuff
	uniform float4 _lineColour;
	uniform float _lineThreshold;

	//Cel Shading stuff
    float _celThreshold;
    sampler2D _MainTex;
    float4 _MainTex_ST;
	fixed4 _LightColor0;
    half _Ambient;

	ENDCG

	SubShader {
		Tags { "RenderType"="Opaque" "LightMode"="ForwardBase" }
		
		pass 
		{

			CGPROGRAM

			float sToonShading(float3 n, float3 light){
				//dot product of light dir and normal
				float nDotL = max(0., dot(normalize(n),normalize(light)));
				return floor(nDotL * _celThreshold) / (_celThreshold - 0.5);
			}

			v2f vert (appdata_full app){
				v2f o;
				o.pos = UnityObjectToClipPos(app.vertex);
				o.uv = TRANSFORM_TEX(app.texcoord,_MainTex);
				o.wNormal = mul(app.normal.xyz, (float3x3) unity_WorldToObject);

				//Trying to do outlines
				//o.normalDir = normalize(mul(float4(app.normal,0.0),unity_WorldToObject).xyz);
				//float4 worldPos = mul(unity_ObjectToWorld,app.vertex);
				//o.viewDir = normalize(_WorldSpaceCameraPos.xyz -worldPos.xyz );

				return o;
			}

			fixed4 frag(v2f index) : SV_Target{
				fixed4 col = tex2D(_MainTex,index.uv);

				//float outlineStrength = saturate((dot(index.normalDir,index.viewDir) - _lineThreshold) * 1);

				col.rgb *= saturate(sToonShading(index.wNormal,_WorldSpaceLightPos0.xyz)+_Ambient) * _LightColor0.rgb;
				return col;
			}
			ENDCG
		}
	}
}
