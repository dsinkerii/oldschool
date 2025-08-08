// Stencil Injection by ShaderGraphStencilInjector

Shader "Stencil Shader Graph/wall_DitheredMaterial"
{
Properties
{
[NoScaleOffset]_OriginalTex("OriginalTex", 2D) = "white" {}
_Color("Color", Color) = (1, 1, 1, 1)
_ditherToNoiseRatio("ditherToNoiseRatio", Float) = 0
_CutoffThresholds("CutoffThresholds", Vector) = (-0.38, 1.01, 0, 0)
[HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
[HideInInspector]_QueueControl("_QueueControl", Float) = -1

        // Stencil Properties
        [IntRange] _StencilRef ("Stencil Reference Value", Range(0, 255)) = 0
        [IntRange] _StencilReadMask ("Stencil ReadMask Value", Range(0, 255)) = 255
        [IntRange] _StencilWriteMask ("Stencil WriteMask Value", Range(0, 255)) = 255
        [Enum(UnityEngine.Rendering.CompareFunction)] _StencilComp ("Stencil Comparison", Float) = 0
        [Enum(UnityEngine.Rendering.StencilOp)] _StencilPass ("Stencil Pass Op", Float) = 0
        [Enum(UnityEngine.Rendering.StencilOp)] _StencilFail ("Stencil Fail Op", Float) = 0
        [Enum(UnityEngine.Rendering.StencilOp)] _StencilZFail ("Stencil ZFail Op", Float) = 0
        [Enum(Off,0,On,1)] _StencilEnabled ("Stencil Enabled", Float) = 0
}
SubShader
{
Tags
{
"RenderPipeline"="UniversalPipeline"
"RenderType"="Opaque"
"UniversalMaterialType" = "Unlit"
"Queue"="Geometry"
"DisableBatching"="False"
"ShaderGraphShader"="true"
"ShaderGraphTargetId"="UniversalUnlitSubTarget"
}
Pass
{
    Name "Universal Forward"
    Tags
    {
        // LightMode: <None>
    }

// Render State
Cull Back
Blend One Zero
ZTest LEqual
ZWrite On

        // Stencil Buffer Setup
        Stencil
        {
            Ref [_StencilRef]
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
            Comp [_StencilComp]
            Pass [_StencilPass]
            Fail [_StencilFail]
            ZFail [_StencilZFail]
        }

// Debug
// <None>

// --------------------------------------------------
// Pass

HLSLPROGRAM

// Pragmas
#pragma target 2.0
#pragma multi_compile_instancing
#pragma instancing_options renderinglayer
#pragma vertex vert
#pragma fragment frag

// Keywords
#pragma multi_compile _ LIGHTMAP_ON
#pragma multi_compile _ DIRLIGHTMAP_COMBINED
#pragma multi_compile _ USE_LEGACY_LIGHTMAPS
#pragma multi_compile _ LIGHTMAP_BICUBIC_SAMPLING
#pragma shader_feature _ _SAMPLE_GI
#pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
#pragma multi_compile_fragment _ DEBUG_DISPLAY
#pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
// GraphKeywords: <None>

// Defines

#define ATTRIBUTES_NEED_NORMAL
#define ATTRIBUTES_NEED_TANGENT
#define ATTRIBUTES_NEED_TEXCOORD0
#define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
#define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
#define VARYINGS_NEED_POSITION_WS
#define VARYINGS_NEED_NORMAL_WS
#define VARYINGS_NEED_TEXCOORD0
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_UNLIT
#define _FOG_FRAGMENT 1


// custom interpolator pre-include
/* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

// Includes
#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Fog.hlsl"
#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

// --------------------------------------------------
// Structs and Packing

// custom interpolators pre packing
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

struct Attributes
{
 float3 positionOS : POSITION;
 float3 normalOS : NORMAL;
 float4 tangentOS : TANGENT;
 float4 uv0 : TEXCOORD0;
#if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
 uint instanceID : INSTANCEID_SEMANTIC;
#endif
};
struct Varyings
{
 float4 positionCS : SV_POSITION;
 float3 positionWS;
 float3 normalWS;
 float4 texCoord0;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
 uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
};
struct SurfaceDescriptionInputs
{
 float3 WorldSpaceNormal;
 float2 NDCPosition;
 float2 PixelPosition;
 float4 uv0;
};
struct VertexDescriptionInputs
{
 float3 ObjectSpaceNormal;
 float3 ObjectSpaceTangent;
 float3 ObjectSpacePosition;
};
struct PackedVaryings
{
 float4 positionCS : SV_POSITION;
 float4 texCoord0 : INTERP0;
 float3 positionWS : INTERP1;
 float3 normalWS : INTERP2;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
 uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
};

PackedVaryings PackVaryings (Varyings input)
{
PackedVaryings output;
ZERO_INITIALIZE(PackedVaryings, output);
output.positionCS = input.positionCS;
output.texCoord0.xyzw = input.texCoord0;
output.positionWS.xyz = input.positionWS;
output.normalWS.xyz = input.normalWS;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}

Varyings UnpackVaryings (PackedVaryings input)
{
Varyings output;
output.positionCS = input.positionCS;
output.texCoord0 = input.texCoord0.xyzw;
output.positionWS = input.positionWS.xyz;
output.normalWS = input.normalWS.xyz;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}


// --------------------------------------------------
// Graph

// Graph Properties
CBUFFER_START(UnityPerMaterial)
float4 _OriginalTex_TexelSize;
float4 _Color;
float _ditherToNoiseRatio;
float2 _CutoffThresholds;
UNITY_TEXTURE_STREAMING_DEBUG_VARS;
CBUFFER_END


// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
TEXTURE2D(_OriginalTex);
SAMPLER(sampler_OriginalTex);

// Graph Includes
// GraphIncludes: <None>

// -- Property used by ScenePickingPass
#ifdef SCENEPICKINGPASS
float4 _SelectionID;
#endif

// -- Properties used by SceneSelectionPass
#ifdef SCENESELECTIONPASS
int _ObjectId;
int _PassValue;
#endif

// Graph Functions

void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
{
Out = A * B;
}

void Unity_ColorspaceConversion_RGB_HSV_float(float3 In, out float3 Out)
{
    float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    float4 P = lerp(float4(In.bg, K.wz), float4(In.gb, K.xy), step(In.b, In.g));
    float4 Q = lerp(float4(P.xyw, In.r), float4(In.r, P.yzx), step(P.x, In.r));
    float D = Q.x - min(Q.w, Q.y);
    float  E = 1e-10;
    float V = (D == 0) ? Q.x : (Q.x + E);
    Out = float3(abs(Q.z + (Q.w - Q.y)/(6.0 * D + E)), D / (Q.x + E), V);
}

void MainLightDirection_float(out float3 Direction)
{
    #if SHADERGRAPH_PREVIEW
    Direction = half3(-0.5, -0.5, 0);
    #else
    Direction = SHADERGRAPH_MAIN_LIGHT_DIRECTION();
    #endif
}

void Unity_Negate_float3(float3 In, out float3 Out)
{
    Out = -1 * In;
}

void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
{
    Out = dot(A, B);
}

void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
{
    Out = smoothstep(Edge1, Edge2, In);
}

void Unity_Blend_HardLight_float(float Base, float Blend, out float Out, float Opacity)
{
    float result1 = 1.0 - 2.0 * (1.0 - Base) * (1.0 - Blend);
    float result2 = 2.0 * Base * Blend;
    float zeroOrOne = step(Blend, 0.5);
    Out = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
    Out = lerp(Base, Out, Opacity);
}

void Unity_Multiply_float_float(float A, float B, out float Out)
{
Out = A * B;
}

void Unity_Dither_float(float In, float4 ScreenPosition, out float Out)
{
    float2 uv = ScreenPosition.xy * _ScreenParams.xy;
    float DITHER_THRESHOLDS[16] =
    {
        1.0 / 17.0,  9.0 / 17.0,  3.0 / 17.0, 11.0 / 17.0,
        13.0 / 17.0,  5.0 / 17.0, 15.0 / 17.0,  7.0 / 17.0,
        4.0 / 17.0, 12.0 / 17.0,  2.0 / 17.0, 10.0 / 17.0,
        16.0 / 17.0,  8.0 / 17.0, 14.0 / 17.0,  6.0 / 17.0
    };
    uint index = (uint(uv.x) % 4) * 4 + uint(uv.y) % 4;
    Out = In - DITHER_THRESHOLDS[index];
}

void Unity_RandomRange_float(float2 Seed, float Min, float Max, out float Out)
{
     float randomno =  frac(sin(dot(Seed, float2(12.9898, 78.233)))*43758.5453);
     Out = lerp(Min, Max, randomno);
}

void Unity_Comparison_Greater_float(float A, float B, out float Out)
{
    Out = A > B ? 1 : 0;
}

void Unity_Lerp_float(float A, float B, float T, out float Out)
{
    Out = lerp(A, B, T);
}

void Unity_ColorspaceConversion_HSV_RGB_float(float3 In, out float3 Out)
{
    float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    float3 P = abs(frac(In.xxx + K.xyz) * 6.0 - K.www);
    Out = In.z * lerp(K.xxx, saturate(P - K.xxx), In.y);
}

// Custom interpolators pre vertex
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

// Graph Vertex
struct VertexDescription
{
float3 Position;
float3 Normal;
float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
VertexDescription description = (VertexDescription)0;
description.Position = IN.ObjectSpacePosition;
description.Normal = IN.ObjectSpaceNormal;
description.Tangent = IN.ObjectSpaceTangent;
return description;
}

// Custom interpolators, pre surface
#ifdef FEATURES_GRAPH_VERTEX
Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
{
return output;
}
#define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
#endif

// Graph Pixel
struct SurfaceDescription
{
float3 BaseColor;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
SurfaceDescription surface = (SurfaceDescription)0;
UnityTexture2D _Property_99468924ee3b4b59ab1541b3cf90badd_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_OriginalTex);
float4 _UV_059412960ef84b3fb7cb447bea372777_Out_0_Vector4 = IN.uv0;
float4 _SampleTexture2D_42c7c0781dd344c2ae9340e648f11a4c_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_99468924ee3b4b59ab1541b3cf90badd_Out_0_Texture2D.tex, _Property_99468924ee3b4b59ab1541b3cf90badd_Out_0_Texture2D.samplerstate, _Property_99468924ee3b4b59ab1541b3cf90badd_Out_0_Texture2D.GetTransformedUV((_UV_059412960ef84b3fb7cb447bea372777_Out_0_Vector4.xy)) );
float _SampleTexture2D_42c7c0781dd344c2ae9340e648f11a4c_R_4_Float = _SampleTexture2D_42c7c0781dd344c2ae9340e648f11a4c_RGBA_0_Vector4.r;
float _SampleTexture2D_42c7c0781dd344c2ae9340e648f11a4c_G_5_Float = _SampleTexture2D_42c7c0781dd344c2ae9340e648f11a4c_RGBA_0_Vector4.g;
float _SampleTexture2D_42c7c0781dd344c2ae9340e648f11a4c_B_6_Float = _SampleTexture2D_42c7c0781dd344c2ae9340e648f11a4c_RGBA_0_Vector4.b;
float _SampleTexture2D_42c7c0781dd344c2ae9340e648f11a4c_A_7_Float = _SampleTexture2D_42c7c0781dd344c2ae9340e648f11a4c_RGBA_0_Vector4.a;
float4 _Property_dd8f7b8dc32c4254b4e8f5a657a7af67_Out_0_Vector4 = _Color;
float4 _Multiply_d1a4c49a5ad74ac2b92dea28aaa7e273_Out_2_Vector4;
Unity_Multiply_float4_float4(_SampleTexture2D_42c7c0781dd344c2ae9340e648f11a4c_RGBA_0_Vector4, _Property_dd8f7b8dc32c4254b4e8f5a657a7af67_Out_0_Vector4, _Multiply_d1a4c49a5ad74ac2b92dea28aaa7e273_Out_2_Vector4);
float3 _ColorspaceConversion_48175174be9e49b8b5a4bd2507f559d2_Out_1_Vector3;
Unity_ColorspaceConversion_RGB_HSV_float((_Multiply_d1a4c49a5ad74ac2b92dea28aaa7e273_Out_2_Vector4.xyz), _ColorspaceConversion_48175174be9e49b8b5a4bd2507f559d2_Out_1_Vector3);
float _Split_c4d9dd8d63054368a7beb9d2a61eb6ef_R_1_Float = _ColorspaceConversion_48175174be9e49b8b5a4bd2507f559d2_Out_1_Vector3[0];
float _Split_c4d9dd8d63054368a7beb9d2a61eb6ef_G_2_Float = _ColorspaceConversion_48175174be9e49b8b5a4bd2507f559d2_Out_1_Vector3[1];
float _Split_c4d9dd8d63054368a7beb9d2a61eb6ef_B_3_Float = _ColorspaceConversion_48175174be9e49b8b5a4bd2507f559d2_Out_1_Vector3[2];
float _Split_c4d9dd8d63054368a7beb9d2a61eb6ef_A_4_Float = 0;
float2 _Property_b865684938e04c81bcf72c43e3b1f0c9_Out_0_Vector2 = _CutoffThresholds;
float _Split_af657b9014aa431fad81fda380b6a623_R_1_Float = _Property_b865684938e04c81bcf72c43e3b1f0c9_Out_0_Vector2[0];
float _Split_af657b9014aa431fad81fda380b6a623_G_2_Float = _Property_b865684938e04c81bcf72c43e3b1f0c9_Out_0_Vector2[1];
float _Split_af657b9014aa431fad81fda380b6a623_B_3_Float = 0;
float _Split_af657b9014aa431fad81fda380b6a623_A_4_Float = 0;
float3 _MainLightDirection_24c122e7fcaf4227bfad8ee2042f4a5f_Direction_0_Vector3;
MainLightDirection_float(_MainLightDirection_24c122e7fcaf4227bfad8ee2042f4a5f_Direction_0_Vector3);
float3 _Negate_7fe8f0a65b8c40f784e816f7fd62d36d_Out_1_Vector3;
Unity_Negate_float3(_MainLightDirection_24c122e7fcaf4227bfad8ee2042f4a5f_Direction_0_Vector3, _Negate_7fe8f0a65b8c40f784e816f7fd62d36d_Out_1_Vector3);
float _DotProduct_33f4e0e36f534b24b02ee9b610d70652_Out_2_Float;
Unity_DotProduct_float3(_Negate_7fe8f0a65b8c40f784e816f7fd62d36d_Out_1_Vector3, IN.WorldSpaceNormal, _DotProduct_33f4e0e36f534b24b02ee9b610d70652_Out_2_Float);
float _Smoothstep_5650b32ba8b9412c960a117ca08cc7b7_Out_3_Float;
Unity_Smoothstep_float(_Split_af657b9014aa431fad81fda380b6a623_R_1_Float, _Split_af657b9014aa431fad81fda380b6a623_G_2_Float, _DotProduct_33f4e0e36f534b24b02ee9b610d70652_Out_2_Float, _Smoothstep_5650b32ba8b9412c960a117ca08cc7b7_Out_3_Float);
float _Blend_5174bd68113148618a7545e50a011478_Out_2_Float;
Unity_Blend_HardLight_float(_Split_c4d9dd8d63054368a7beb9d2a61eb6ef_B_3_Float, _Smoothstep_5650b32ba8b9412c960a117ca08cc7b7_Out_3_Float, _Blend_5174bd68113148618a7545e50a011478_Out_2_Float, float(0.5));
float _Float_aac4e8a63bc145ab95a29bc91bf79385_Out_0_Float = _Blend_5174bd68113148618a7545e50a011478_Out_2_Float;
float _Multiply_9aee5a41025a481d9e84571d2ab6184f_Out_2_Float;
Unity_Multiply_float_float(_Float_aac4e8a63bc145ab95a29bc91bf79385_Out_0_Float, 2, _Multiply_9aee5a41025a481d9e84571d2ab6184f_Out_2_Float);
float _Dither_178111f60a844b2d84016493f37d5006_Out_2_Float;
Unity_Dither_float(_Multiply_9aee5a41025a481d9e84571d2ab6184f_Out_2_Float, float4(IN.NDCPosition.xy, 0, 0), _Dither_178111f60a844b2d84016493f37d5006_Out_2_Float);
float4 _ScreenPosition_476d67e49c27459481bcec3d59d12b7c_Out_0_Vector4 = float4(IN.NDCPosition.xy, 0, 0);
float _RandomRange_7bc0d55a2e4a4cb58a233e5903f0bd73_Out_3_Float;
Unity_RandomRange_float((_ScreenPosition_476d67e49c27459481bcec3d59d12b7c_Out_0_Vector4.xy), float(0), float(1), _RandomRange_7bc0d55a2e4a4cb58a233e5903f0bd73_Out_3_Float);
float _Comparison_9a87df5a14df41fab8cae7c380ae6da9_Out_2_Boolean;
Unity_Comparison_Greater_float(_Float_aac4e8a63bc145ab95a29bc91bf79385_Out_0_Float, _RandomRange_7bc0d55a2e4a4cb58a233e5903f0bd73_Out_3_Float, _Comparison_9a87df5a14df41fab8cae7c380ae6da9_Out_2_Boolean);
float _Property_6bd49cb9d4c74d0a82c2e6d2f0b066b5_Out_0_Float = _ditherToNoiseRatio;
float _Lerp_43f5dfd61d5f45b6bb3538c8cacc6b02_Out_3_Float;
Unity_Lerp_float(_Dither_178111f60a844b2d84016493f37d5006_Out_2_Float, ((float) _Comparison_9a87df5a14df41fab8cae7c380ae6da9_Out_2_Boolean), _Property_6bd49cb9d4c74d0a82c2e6d2f0b066b5_Out_0_Float, _Lerp_43f5dfd61d5f45b6bb3538c8cacc6b02_Out_3_Float);
float3 _Vector3_b2ecb20a57ed4c20bbaaef387177e80d_Out_0_Vector3 = float3(_Split_c4d9dd8d63054368a7beb9d2a61eb6ef_R_1_Float, _Split_c4d9dd8d63054368a7beb9d2a61eb6ef_G_2_Float, _Lerp_43f5dfd61d5f45b6bb3538c8cacc6b02_Out_3_Float);
float3 _ColorspaceConversion_6fdb1d464c4b43b382439b796f3ce10f_Out_1_Vector3;
Unity_ColorspaceConversion_HSV_RGB_float(_Vector3_b2ecb20a57ed4c20bbaaef387177e80d_Out_0_Vector3, _ColorspaceConversion_6fdb1d464c4b43b382439b796f3ce10f_Out_1_Vector3);
surface.BaseColor = _ColorspaceConversion_6fdb1d464c4b43b382439b796f3ce10f_Out_1_Vector3;
return surface;
}

// --------------------------------------------------
// Build Graph Inputs
#ifdef HAVE_VFX_MODIFICATION
#define VFX_SRP_ATTRIBUTES Attributes
#define VFX_SRP_VARYINGS Varyings
#define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
#endif
VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
    {
        VertexDescriptionInputs output;
        ZERO_INITIALIZE(VertexDescriptionInputs, output);
    
        output.ObjectSpaceNormal =                          input.normalOS;
        output.ObjectSpaceTangent =                         input.tangentOS.xyz;
        output.ObjectSpacePosition =                        input.positionOS;
    #if UNITY_ANY_INSTANCING_ENABLED
    #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
    #endif
    
        return output;
    }
    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
    {
        SurfaceDescriptionInputs output;
        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
    
    #ifdef HAVE_VFX_MODIFICATION
    #if VFX_USE_GRAPH_VALUES
        uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
        /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
    #endif
        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
    
    #endif
    
        
    
        // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        float3 unnormalizedNormalWS = input.normalWS;
        const float renormFactor = 1.0 / length(unnormalizedNormalWS);
    
    
        output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
    
    
    
        #if UNITY_UV_STARTS_AT_TOP
        output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
        #else
        output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
        #endif
    
        output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
        output.NDCPosition.y = 1.0f - output.NDCPosition.y;
    
        output.uv0 = input.texCoord0;
    #if UNITY_ANY_INSTANCING_ENABLED
    #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
    #endif
    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
    #else
    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
    #endif
    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
    
            return output;
    }
    
// --------------------------------------------------
// Main

#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/UnlitPass.hlsl"

// --------------------------------------------------
// Visual Effect Vertex Invocations
#ifdef HAVE_VFX_MODIFICATION
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
#endif

ENDHLSL
}
Pass
{
    Name "DepthOnly"
    Tags
    {
        "LightMode" = "DepthOnly"
    }

// Render State
Cull Back
ZTest LEqual
ZWrite On
ColorMask R

// Debug
// <None>

// --------------------------------------------------
// Pass

HLSLPROGRAM

// Pragmas
#pragma target 2.0
#pragma multi_compile_instancing
#pragma vertex vert
#pragma fragment frag

// Keywords
// PassKeywords: <None>
// GraphKeywords: <None>

// Defines

#define ATTRIBUTES_NEED_NORMAL
#define ATTRIBUTES_NEED_TANGENT
#define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
#define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_DEPTHONLY


// custom interpolator pre-include
/* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

// Includes
#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

// --------------------------------------------------
// Structs and Packing

// custom interpolators pre packing
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

struct Attributes
{
 float3 positionOS : POSITION;
 float3 normalOS : NORMAL;
 float4 tangentOS : TANGENT;
#if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
 uint instanceID : INSTANCEID_SEMANTIC;
#endif
};
struct Varyings
{
 float4 positionCS : SV_POSITION;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
 uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
};
struct SurfaceDescriptionInputs
{
};
struct VertexDescriptionInputs
{
 float3 ObjectSpaceNormal;
 float3 ObjectSpaceTangent;
 float3 ObjectSpacePosition;
};
struct PackedVaryings
{
 float4 positionCS : SV_POSITION;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
 uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
};

PackedVaryings PackVaryings (Varyings input)
{
PackedVaryings output;
ZERO_INITIALIZE(PackedVaryings, output);
output.positionCS = input.positionCS;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}

Varyings UnpackVaryings (PackedVaryings input)
{
Varyings output;
output.positionCS = input.positionCS;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}


// --------------------------------------------------
// Graph

// Graph Properties
CBUFFER_START(UnityPerMaterial)
float4 _OriginalTex_TexelSize;
float4 _Color;
float _ditherToNoiseRatio;
float2 _CutoffThresholds;
UNITY_TEXTURE_STREAMING_DEBUG_VARS;
CBUFFER_END


// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
TEXTURE2D(_OriginalTex);
SAMPLER(sampler_OriginalTex);

// Graph Includes
// GraphIncludes: <None>

// -- Property used by ScenePickingPass
#ifdef SCENEPICKINGPASS
float4 _SelectionID;
#endif

// -- Properties used by SceneSelectionPass
#ifdef SCENESELECTIONPASS
int _ObjectId;
int _PassValue;
#endif

// Graph Functions
// GraphFunctions: <None>

// Custom interpolators pre vertex
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

// Graph Vertex
struct VertexDescription
{
float3 Position;
float3 Normal;
float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
VertexDescription description = (VertexDescription)0;
description.Position = IN.ObjectSpacePosition;
description.Normal = IN.ObjectSpaceNormal;
description.Tangent = IN.ObjectSpaceTangent;
return description;
}

// Custom interpolators, pre surface
#ifdef FEATURES_GRAPH_VERTEX
Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
{
return output;
}
#define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
#endif

// Graph Pixel
struct SurfaceDescription
{
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
SurfaceDescription surface = (SurfaceDescription)0;
return surface;
}

// --------------------------------------------------
// Build Graph Inputs
#ifdef HAVE_VFX_MODIFICATION
#define VFX_SRP_ATTRIBUTES Attributes
#define VFX_SRP_VARYINGS Varyings
#define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
#endif
VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
    {
        VertexDescriptionInputs output;
        ZERO_INITIALIZE(VertexDescriptionInputs, output);
    
        output.ObjectSpaceNormal =                          input.normalOS;
        output.ObjectSpaceTangent =                         input.tangentOS.xyz;
        output.ObjectSpacePosition =                        input.positionOS;
    #if UNITY_ANY_INSTANCING_ENABLED
    #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
    #endif
    
        return output;
    }
    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
    {
        SurfaceDescriptionInputs output;
        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
    
    #ifdef HAVE_VFX_MODIFICATION
    #if VFX_USE_GRAPH_VALUES
        uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
        /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
    #endif
        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
    
    #endif
    
        
    
    
    
    
    
    
        #if UNITY_UV_STARTS_AT_TOP
        #else
        #endif
    
    
    #if UNITY_ANY_INSTANCING_ENABLED
    #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
    #endif
    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
    #else
    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
    #endif
    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
    
            return output;
    }
    
// --------------------------------------------------
// Main

#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

// --------------------------------------------------
// Visual Effect Vertex Invocations
#ifdef HAVE_VFX_MODIFICATION
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
#endif

ENDHLSL
}
Pass
{
    Name "MotionVectors"
    Tags
    {
        "LightMode" = "MotionVectors"
    }

// Render State
Cull Back
ZTest LEqual
ZWrite On
ColorMask RG

// Debug
// <None>

// --------------------------------------------------
// Pass

HLSLPROGRAM

// Pragmas
#pragma target 3.5
#pragma multi_compile_instancing
#pragma vertex vert
#pragma fragment frag

// Keywords
// PassKeywords: <None>
// GraphKeywords: <None>

// Defines

#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_MOTION_VECTORS


// custom interpolator pre-include
/* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

// Includes
#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

// --------------------------------------------------
// Structs and Packing

// custom interpolators pre packing
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

struct Attributes
{
 float3 positionOS : POSITION;
#if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
 uint instanceID : INSTANCEID_SEMANTIC;
#endif
};
struct Varyings
{
 float4 positionCS : SV_POSITION;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
 uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
};
struct SurfaceDescriptionInputs
{
};
struct VertexDescriptionInputs
{
 float3 ObjectSpacePosition;
};
struct PackedVaryings
{
 float4 positionCS : SV_POSITION;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
 uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
};

PackedVaryings PackVaryings (Varyings input)
{
PackedVaryings output;
ZERO_INITIALIZE(PackedVaryings, output);
output.positionCS = input.positionCS;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}

Varyings UnpackVaryings (PackedVaryings input)
{
Varyings output;
output.positionCS = input.positionCS;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}


// --------------------------------------------------
// Graph

// Graph Properties
CBUFFER_START(UnityPerMaterial)
float4 _OriginalTex_TexelSize;
float4 _Color;
float _ditherToNoiseRatio;
float2 _CutoffThresholds;
UNITY_TEXTURE_STREAMING_DEBUG_VARS;
CBUFFER_END


// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
TEXTURE2D(_OriginalTex);
SAMPLER(sampler_OriginalTex);

// Graph Includes
// GraphIncludes: <None>

// -- Property used by ScenePickingPass
#ifdef SCENEPICKINGPASS
float4 _SelectionID;
#endif

// -- Properties used by SceneSelectionPass
#ifdef SCENESELECTIONPASS
int _ObjectId;
int _PassValue;
#endif

// Graph Functions
// GraphFunctions: <None>

// Custom interpolators pre vertex
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

// Graph Vertex
struct VertexDescription
{
float3 Position;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
VertexDescription description = (VertexDescription)0;
description.Position = IN.ObjectSpacePosition;
return description;
}

// Custom interpolators, pre surface
#ifdef FEATURES_GRAPH_VERTEX
Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
{
return output;
}
#define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
#endif

// Graph Pixel
struct SurfaceDescription
{
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
SurfaceDescription surface = (SurfaceDescription)0;
return surface;
}

// --------------------------------------------------
// Build Graph Inputs
#ifdef HAVE_VFX_MODIFICATION
#define VFX_SRP_ATTRIBUTES Attributes
#define VFX_SRP_VARYINGS Varyings
#define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
#endif
VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
    {
        VertexDescriptionInputs output;
        ZERO_INITIALIZE(VertexDescriptionInputs, output);
    
        output.ObjectSpacePosition =                        input.positionOS;
    #if UNITY_ANY_INSTANCING_ENABLED
    #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
    #endif
    
        return output;
    }
    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
    {
        SurfaceDescriptionInputs output;
        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
    
    #ifdef HAVE_VFX_MODIFICATION
    #if VFX_USE_GRAPH_VALUES
        uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
        /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
    #endif
        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
    
    #endif
    
        
    
    
    
    
    
    
        #if UNITY_UV_STARTS_AT_TOP
        #else
        #endif
    
    
    #if UNITY_ANY_INSTANCING_ENABLED
    #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
    #endif
    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
    #else
    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
    #endif
    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
    
            return output;
    }
    
// --------------------------------------------------
// Main

#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/MotionVectorPass.hlsl"

// --------------------------------------------------
// Visual Effect Vertex Invocations
#ifdef HAVE_VFX_MODIFICATION
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
#endif

ENDHLSL
}
Pass
{
    Name "DepthNormalsOnly"
    Tags
    {
        "LightMode" = "DepthNormalsOnly"
    }

// Render State
Cull Back
ZTest LEqual
ZWrite On

// Debug
// <None>

// --------------------------------------------------
// Pass

HLSLPROGRAM

// Pragmas
#pragma target 2.0
#pragma multi_compile_instancing
#pragma vertex vert
#pragma fragment frag

// Keywords
#pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
// GraphKeywords: <None>

// Defines

#define ATTRIBUTES_NEED_NORMAL
#define ATTRIBUTES_NEED_TANGENT
#define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
#define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
#define VARYINGS_NEED_NORMAL_WS
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_DEPTHNORMALSONLY


// custom interpolator pre-include
/* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

// Includes
#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

// --------------------------------------------------
// Structs and Packing

// custom interpolators pre packing
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

struct Attributes
{
 float3 positionOS : POSITION;
 float3 normalOS : NORMAL;
 float4 tangentOS : TANGENT;
#if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
 uint instanceID : INSTANCEID_SEMANTIC;
#endif
};
struct Varyings
{
 float4 positionCS : SV_POSITION;
 float3 normalWS;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
 uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
};
struct SurfaceDescriptionInputs
{
};
struct VertexDescriptionInputs
{
 float3 ObjectSpaceNormal;
 float3 ObjectSpaceTangent;
 float3 ObjectSpacePosition;
};
struct PackedVaryings
{
 float4 positionCS : SV_POSITION;
 float3 normalWS : INTERP0;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
 uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
};

PackedVaryings PackVaryings (Varyings input)
{
PackedVaryings output;
ZERO_INITIALIZE(PackedVaryings, output);
output.positionCS = input.positionCS;
output.normalWS.xyz = input.normalWS;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}

Varyings UnpackVaryings (PackedVaryings input)
{
Varyings output;
output.positionCS = input.positionCS;
output.normalWS = input.normalWS.xyz;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}


// --------------------------------------------------
// Graph

// Graph Properties
CBUFFER_START(UnityPerMaterial)
float4 _OriginalTex_TexelSize;
float4 _Color;
float _ditherToNoiseRatio;
float2 _CutoffThresholds;
UNITY_TEXTURE_STREAMING_DEBUG_VARS;
CBUFFER_END


// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
TEXTURE2D(_OriginalTex);
SAMPLER(sampler_OriginalTex);

// Graph Includes
// GraphIncludes: <None>

// -- Property used by ScenePickingPass
#ifdef SCENEPICKINGPASS
float4 _SelectionID;
#endif

// -- Properties used by SceneSelectionPass
#ifdef SCENESELECTIONPASS
int _ObjectId;
int _PassValue;
#endif

// Graph Functions
// GraphFunctions: <None>

// Custom interpolators pre vertex
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

// Graph Vertex
struct VertexDescription
{
float3 Position;
float3 Normal;
float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
VertexDescription description = (VertexDescription)0;
description.Position = IN.ObjectSpacePosition;
description.Normal = IN.ObjectSpaceNormal;
description.Tangent = IN.ObjectSpaceTangent;
return description;
}

// Custom interpolators, pre surface
#ifdef FEATURES_GRAPH_VERTEX
Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
{
return output;
}
#define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
#endif

// Graph Pixel
struct SurfaceDescription
{
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
SurfaceDescription surface = (SurfaceDescription)0;
return surface;
}

// --------------------------------------------------
// Build Graph Inputs
#ifdef HAVE_VFX_MODIFICATION
#define VFX_SRP_ATTRIBUTES Attributes
#define VFX_SRP_VARYINGS Varyings
#define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
#endif
VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
    {
        VertexDescriptionInputs output;
        ZERO_INITIALIZE(VertexDescriptionInputs, output);
    
        output.ObjectSpaceNormal =                          input.normalOS;
        output.ObjectSpaceTangent =                         input.tangentOS.xyz;
        output.ObjectSpacePosition =                        input.positionOS;
    #if UNITY_ANY_INSTANCING_ENABLED
    #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
    #endif
    
        return output;
    }
    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
    {
        SurfaceDescriptionInputs output;
        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
    
    #ifdef HAVE_VFX_MODIFICATION
    #if VFX_USE_GRAPH_VALUES
        uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
        /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
    #endif
        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
    
    #endif
    
        
    
    
    
    
    
    
        #if UNITY_UV_STARTS_AT_TOP
        #else
        #endif
    
    
    #if UNITY_ANY_INSTANCING_ENABLED
    #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
    #endif
    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
    #else
    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
    #endif
    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
    
            return output;
    }
    
// --------------------------------------------------
// Main

#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"

// --------------------------------------------------
// Visual Effect Vertex Invocations
#ifdef HAVE_VFX_MODIFICATION
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
#endif

ENDHLSL
}
Pass
{
    Name "ShadowCaster"
    Tags
    {
        "LightMode" = "ShadowCaster"
    }

// Render State
Cull Back
ZTest LEqual
ZWrite On
ColorMask 0

// Debug
// <None>

// --------------------------------------------------
// Pass

HLSLPROGRAM

// Pragmas
#pragma target 2.0
#pragma multi_compile_instancing
#pragma vertex vert
#pragma fragment frag

// Keywords
#pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
// GraphKeywords: <None>

// Defines

#define ATTRIBUTES_NEED_NORMAL
#define ATTRIBUTES_NEED_TANGENT
#define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
#define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
#define VARYINGS_NEED_NORMAL_WS
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_SHADOWCASTER


// custom interpolator pre-include
/* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

// Includes
#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

// --------------------------------------------------
// Structs and Packing

// custom interpolators pre packing
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

struct Attributes
{
 float3 positionOS : POSITION;
 float3 normalOS : NORMAL;
 float4 tangentOS : TANGENT;
#if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
 uint instanceID : INSTANCEID_SEMANTIC;
#endif
};
struct Varyings
{
 float4 positionCS : SV_POSITION;
 float3 normalWS;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
 uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
};
struct SurfaceDescriptionInputs
{
};
struct VertexDescriptionInputs
{
 float3 ObjectSpaceNormal;
 float3 ObjectSpaceTangent;
 float3 ObjectSpacePosition;
};
struct PackedVaryings
{
 float4 positionCS : SV_POSITION;
 float3 normalWS : INTERP0;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
 uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
};

PackedVaryings PackVaryings (Varyings input)
{
PackedVaryings output;
ZERO_INITIALIZE(PackedVaryings, output);
output.positionCS = input.positionCS;
output.normalWS.xyz = input.normalWS;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}

Varyings UnpackVaryings (PackedVaryings input)
{
Varyings output;
output.positionCS = input.positionCS;
output.normalWS = input.normalWS.xyz;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}


// --------------------------------------------------
// Graph

// Graph Properties
CBUFFER_START(UnityPerMaterial)
float4 _OriginalTex_TexelSize;
float4 _Color;
float _ditherToNoiseRatio;
float2 _CutoffThresholds;
UNITY_TEXTURE_STREAMING_DEBUG_VARS;
CBUFFER_END


// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
TEXTURE2D(_OriginalTex);
SAMPLER(sampler_OriginalTex);

// Graph Includes
// GraphIncludes: <None>

// -- Property used by ScenePickingPass
#ifdef SCENEPICKINGPASS
float4 _SelectionID;
#endif

// -- Properties used by SceneSelectionPass
#ifdef SCENESELECTIONPASS
int _ObjectId;
int _PassValue;
#endif

// Graph Functions
// GraphFunctions: <None>

// Custom interpolators pre vertex
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

// Graph Vertex
struct VertexDescription
{
float3 Position;
float3 Normal;
float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
VertexDescription description = (VertexDescription)0;
description.Position = IN.ObjectSpacePosition;
description.Normal = IN.ObjectSpaceNormal;
description.Tangent = IN.ObjectSpaceTangent;
return description;
}

// Custom interpolators, pre surface
#ifdef FEATURES_GRAPH_VERTEX
Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
{
return output;
}
#define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
#endif

// Graph Pixel
struct SurfaceDescription
{
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
SurfaceDescription surface = (SurfaceDescription)0;
return surface;
}

// --------------------------------------------------
// Build Graph Inputs
#ifdef HAVE_VFX_MODIFICATION
#define VFX_SRP_ATTRIBUTES Attributes
#define VFX_SRP_VARYINGS Varyings
#define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
#endif
VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
    {
        VertexDescriptionInputs output;
        ZERO_INITIALIZE(VertexDescriptionInputs, output);
    
        output.ObjectSpaceNormal =                          input.normalOS;
        output.ObjectSpaceTangent =                         input.tangentOS.xyz;
        output.ObjectSpacePosition =                        input.positionOS;
    #if UNITY_ANY_INSTANCING_ENABLED
    #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
    #endif
    
        return output;
    }
    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
    {
        SurfaceDescriptionInputs output;
        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
    
    #ifdef HAVE_VFX_MODIFICATION
    #if VFX_USE_GRAPH_VALUES
        uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
        /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
    #endif
        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
    
    #endif
    
        
    
    
    
    
    
    
        #if UNITY_UV_STARTS_AT_TOP
        #else
        #endif
    
    
    #if UNITY_ANY_INSTANCING_ENABLED
    #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
    #endif
    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
    #else
    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
    #endif
    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
    
            return output;
    }
    
// --------------------------------------------------
// Main

#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

// --------------------------------------------------
// Visual Effect Vertex Invocations
#ifdef HAVE_VFX_MODIFICATION
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
#endif

ENDHLSL
}
Pass
{
    Name "GBuffer"
    Tags
    {
        "LightMode" = "UniversalGBuffer"
    }

// Render State
Cull Back
Blend One Zero
ZTest LEqual
ZWrite On

// Debug
// <None>

// --------------------------------------------------
// Pass

HLSLPROGRAM

// Pragmas
#pragma target 4.5
#pragma exclude_renderers gles3 glcore
#pragma multi_compile_instancing
#pragma instancing_options renderinglayer
#pragma vertex vert
#pragma fragment frag

// Keywords
#pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
#pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
// GraphKeywords: <None>

// Defines

#define ATTRIBUTES_NEED_NORMAL
#define ATTRIBUTES_NEED_TANGENT
#define ATTRIBUTES_NEED_TEXCOORD0
#define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
#define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
#define VARYINGS_NEED_POSITION_WS
#define VARYINGS_NEED_NORMAL_WS
#define VARYINGS_NEED_TEXCOORD0
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_GBUFFER


// custom interpolator pre-include
/* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

// Includes
#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

// --------------------------------------------------
// Structs and Packing

// custom interpolators pre packing
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

struct Attributes
{
 float3 positionOS : POSITION;
 float3 normalOS : NORMAL;
 float4 tangentOS : TANGENT;
 float4 uv0 : TEXCOORD0;
#if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
 uint instanceID : INSTANCEID_SEMANTIC;
#endif
};
struct Varyings
{
 float4 positionCS : SV_POSITION;
 float3 positionWS;
 float3 normalWS;
 float4 texCoord0;
#if !defined(LIGHTMAP_ON)
 float3 sh;
#endif
#if defined(USE_APV_PROBE_OCCLUSION)
 float4 probeOcclusion;
#endif
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
 uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
};
struct SurfaceDescriptionInputs
{
 float3 WorldSpaceNormal;
 float2 NDCPosition;
 float2 PixelPosition;
 float4 uv0;
};
struct VertexDescriptionInputs
{
 float3 ObjectSpaceNormal;
 float3 ObjectSpaceTangent;
 float3 ObjectSpacePosition;
};
struct PackedVaryings
{
 float4 positionCS : SV_POSITION;
#if !defined(LIGHTMAP_ON)
 float3 sh : INTERP0;
#endif
#if defined(USE_APV_PROBE_OCCLUSION)
 float4 probeOcclusion : INTERP1;
#endif
 float4 texCoord0 : INTERP2;
 float3 positionWS : INTERP3;
 float3 normalWS : INTERP4;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
 uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
};

PackedVaryings PackVaryings (Varyings input)
{
PackedVaryings output;
ZERO_INITIALIZE(PackedVaryings, output);
output.positionCS = input.positionCS;
#if !defined(LIGHTMAP_ON)
output.sh = input.sh;
#endif
#if defined(USE_APV_PROBE_OCCLUSION)
output.probeOcclusion = input.probeOcclusion;
#endif
output.texCoord0.xyzw = input.texCoord0;
output.positionWS.xyz = input.positionWS;
output.normalWS.xyz = input.normalWS;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}

Varyings UnpackVaryings (PackedVaryings input)
{
Varyings output;
output.positionCS = input.positionCS;
#if !defined(LIGHTMAP_ON)
output.sh = input.sh;
#endif
#if defined(USE_APV_PROBE_OCCLUSION)
output.probeOcclusion = input.probeOcclusion;
#endif
output.texCoord0 = input.texCoord0.xyzw;
output.positionWS = input.positionWS.xyz;
output.normalWS = input.normalWS.xyz;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}


// --------------------------------------------------
// Graph

// Graph Properties
CBUFFER_START(UnityPerMaterial)
float4 _OriginalTex_TexelSize;
float4 _Color;
float _ditherToNoiseRatio;
float2 _CutoffThresholds;
UNITY_TEXTURE_STREAMING_DEBUG_VARS;
CBUFFER_END


// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
TEXTURE2D(_OriginalTex);
SAMPLER(sampler_OriginalTex);

// Graph Includes
// GraphIncludes: <None>

// -- Property used by ScenePickingPass
#ifdef SCENEPICKINGPASS
float4 _SelectionID;
#endif

// -- Properties used by SceneSelectionPass
#ifdef SCENESELECTIONPASS
int _ObjectId;
int _PassValue;
#endif

// Graph Functions

void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
{
Out = A * B;
}

void Unity_ColorspaceConversion_RGB_HSV_float(float3 In, out float3 Out)
{
    float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    float4 P = lerp(float4(In.bg, K.wz), float4(In.gb, K.xy), step(In.b, In.g));
    float4 Q = lerp(float4(P.xyw, In.r), float4(In.r, P.yzx), step(P.x, In.r));
    float D = Q.x - min(Q.w, Q.y);
    float  E = 1e-10;
    float V = (D == 0) ? Q.x : (Q.x + E);
    Out = float3(abs(Q.z + (Q.w - Q.y)/(6.0 * D + E)), D / (Q.x + E), V);
}

void MainLightDirection_float(out float3 Direction)
{
    #if SHADERGRAPH_PREVIEW
    Direction = half3(-0.5, -0.5, 0);
    #else
    Direction = SHADERGRAPH_MAIN_LIGHT_DIRECTION();
    #endif
}

void Unity_Negate_float3(float3 In, out float3 Out)
{
    Out = -1 * In;
}

void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
{
    Out = dot(A, B);
}

void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
{
    Out = smoothstep(Edge1, Edge2, In);
}

void Unity_Blend_HardLight_float(float Base, float Blend, out float Out, float Opacity)
{
    float result1 = 1.0 - 2.0 * (1.0 - Base) * (1.0 - Blend);
    float result2 = 2.0 * Base * Blend;
    float zeroOrOne = step(Blend, 0.5);
    Out = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
    Out = lerp(Base, Out, Opacity);
}

void Unity_Multiply_float_float(float A, float B, out float Out)
{
Out = A * B;
}

void Unity_Dither_float(float In, float4 ScreenPosition, out float Out)
{
    float2 uv = ScreenPosition.xy * _ScreenParams.xy;
    float DITHER_THRESHOLDS[16] =
    {
        1.0 / 17.0,  9.0 / 17.0,  3.0 / 17.0, 11.0 / 17.0,
        13.0 / 17.0,  5.0 / 17.0, 15.0 / 17.0,  7.0 / 17.0,
        4.0 / 17.0, 12.0 / 17.0,  2.0 / 17.0, 10.0 / 17.0,
        16.0 / 17.0,  8.0 / 17.0, 14.0 / 17.0,  6.0 / 17.0
    };
    uint index = (uint(uv.x) % 4) * 4 + uint(uv.y) % 4;
    Out = In - DITHER_THRESHOLDS[index];
}

void Unity_RandomRange_float(float2 Seed, float Min, float Max, out float Out)
{
     float randomno =  frac(sin(dot(Seed, float2(12.9898, 78.233)))*43758.5453);
     Out = lerp(Min, Max, randomno);
}

void Unity_Comparison_Greater_float(float A, float B, out float Out)
{
    Out = A > B ? 1 : 0;
}

void Unity_Lerp_float(float A, float B, float T, out float Out)
{
    Out = lerp(A, B, T);
}

void Unity_ColorspaceConversion_HSV_RGB_float(float3 In, out float3 Out)
{
    float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    float3 P = abs(frac(In.xxx + K.xyz) * 6.0 - K.www);
    Out = In.z * lerp(K.xxx, saturate(P - K.xxx), In.y);
}

// Custom interpolators pre vertex
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

// Graph Vertex
struct VertexDescription
{
float3 Position;
float3 Normal;
float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
VertexDescription description = (VertexDescription)0;
description.Position = IN.ObjectSpacePosition;
description.Normal = IN.ObjectSpaceNormal;
description.Tangent = IN.ObjectSpaceTangent;
return description;
}

// Custom interpolators, pre surface
#ifdef FEATURES_GRAPH_VERTEX
Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
{
return output;
}
#define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
#endif

// Graph Pixel
struct SurfaceDescription
{
float3 BaseColor;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
SurfaceDescription surface = (SurfaceDescription)0;
UnityTexture2D _Property_99468924ee3b4b59ab1541b3cf90badd_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_OriginalTex);
float4 _UV_059412960ef84b3fb7cb447bea372777_Out_0_Vector4 = IN.uv0;
float4 _SampleTexture2D_42c7c0781dd344c2ae9340e648f11a4c_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_99468924ee3b4b59ab1541b3cf90badd_Out_0_Texture2D.tex, _Property_99468924ee3b4b59ab1541b3cf90badd_Out_0_Texture2D.samplerstate, _Property_99468924ee3b4b59ab1541b3cf90badd_Out_0_Texture2D.GetTransformedUV((_UV_059412960ef84b3fb7cb447bea372777_Out_0_Vector4.xy)) );
float _SampleTexture2D_42c7c0781dd344c2ae9340e648f11a4c_R_4_Float = _SampleTexture2D_42c7c0781dd344c2ae9340e648f11a4c_RGBA_0_Vector4.r;
float _SampleTexture2D_42c7c0781dd344c2ae9340e648f11a4c_G_5_Float = _SampleTexture2D_42c7c0781dd344c2ae9340e648f11a4c_RGBA_0_Vector4.g;
float _SampleTexture2D_42c7c0781dd344c2ae9340e648f11a4c_B_6_Float = _SampleTexture2D_42c7c0781dd344c2ae9340e648f11a4c_RGBA_0_Vector4.b;
float _SampleTexture2D_42c7c0781dd344c2ae9340e648f11a4c_A_7_Float = _SampleTexture2D_42c7c0781dd344c2ae9340e648f11a4c_RGBA_0_Vector4.a;
float4 _Property_dd8f7b8dc32c4254b4e8f5a657a7af67_Out_0_Vector4 = _Color;
float4 _Multiply_d1a4c49a5ad74ac2b92dea28aaa7e273_Out_2_Vector4;
Unity_Multiply_float4_float4(_SampleTexture2D_42c7c0781dd344c2ae9340e648f11a4c_RGBA_0_Vector4, _Property_dd8f7b8dc32c4254b4e8f5a657a7af67_Out_0_Vector4, _Multiply_d1a4c49a5ad74ac2b92dea28aaa7e273_Out_2_Vector4);
float3 _ColorspaceConversion_48175174be9e49b8b5a4bd2507f559d2_Out_1_Vector3;
Unity_ColorspaceConversion_RGB_HSV_float((_Multiply_d1a4c49a5ad74ac2b92dea28aaa7e273_Out_2_Vector4.xyz), _ColorspaceConversion_48175174be9e49b8b5a4bd2507f559d2_Out_1_Vector3);
float _Split_c4d9dd8d63054368a7beb9d2a61eb6ef_R_1_Float = _ColorspaceConversion_48175174be9e49b8b5a4bd2507f559d2_Out_1_Vector3[0];
float _Split_c4d9dd8d63054368a7beb9d2a61eb6ef_G_2_Float = _ColorspaceConversion_48175174be9e49b8b5a4bd2507f559d2_Out_1_Vector3[1];
float _Split_c4d9dd8d63054368a7beb9d2a61eb6ef_B_3_Float = _ColorspaceConversion_48175174be9e49b8b5a4bd2507f559d2_Out_1_Vector3[2];
float _Split_c4d9dd8d63054368a7beb9d2a61eb6ef_A_4_Float = 0;
float2 _Property_b865684938e04c81bcf72c43e3b1f0c9_Out_0_Vector2 = _CutoffThresholds;
float _Split_af657b9014aa431fad81fda380b6a623_R_1_Float = _Property_b865684938e04c81bcf72c43e3b1f0c9_Out_0_Vector2[0];
float _Split_af657b9014aa431fad81fda380b6a623_G_2_Float = _Property_b865684938e04c81bcf72c43e3b1f0c9_Out_0_Vector2[1];
float _Split_af657b9014aa431fad81fda380b6a623_B_3_Float = 0;
float _Split_af657b9014aa431fad81fda380b6a623_A_4_Float = 0;
float3 _MainLightDirection_24c122e7fcaf4227bfad8ee2042f4a5f_Direction_0_Vector3;
MainLightDirection_float(_MainLightDirection_24c122e7fcaf4227bfad8ee2042f4a5f_Direction_0_Vector3);
float3 _Negate_7fe8f0a65b8c40f784e816f7fd62d36d_Out_1_Vector3;
Unity_Negate_float3(_MainLightDirection_24c122e7fcaf4227bfad8ee2042f4a5f_Direction_0_Vector3, _Negate_7fe8f0a65b8c40f784e816f7fd62d36d_Out_1_Vector3);
float _DotProduct_33f4e0e36f534b24b02ee9b610d70652_Out_2_Float;
Unity_DotProduct_float3(_Negate_7fe8f0a65b8c40f784e816f7fd62d36d_Out_1_Vector3, IN.WorldSpaceNormal, _DotProduct_33f4e0e36f534b24b02ee9b610d70652_Out_2_Float);
float _Smoothstep_5650b32ba8b9412c960a117ca08cc7b7_Out_3_Float;
Unity_Smoothstep_float(_Split_af657b9014aa431fad81fda380b6a623_R_1_Float, _Split_af657b9014aa431fad81fda380b6a623_G_2_Float, _DotProduct_33f4e0e36f534b24b02ee9b610d70652_Out_2_Float, _Smoothstep_5650b32ba8b9412c960a117ca08cc7b7_Out_3_Float);
float _Blend_5174bd68113148618a7545e50a011478_Out_2_Float;
Unity_Blend_HardLight_float(_Split_c4d9dd8d63054368a7beb9d2a61eb6ef_B_3_Float, _Smoothstep_5650b32ba8b9412c960a117ca08cc7b7_Out_3_Float, _Blend_5174bd68113148618a7545e50a011478_Out_2_Float, float(0.5));
float _Float_aac4e8a63bc145ab95a29bc91bf79385_Out_0_Float = _Blend_5174bd68113148618a7545e50a011478_Out_2_Float;
float _Multiply_9aee5a41025a481d9e84571d2ab6184f_Out_2_Float;
Unity_Multiply_float_float(_Float_aac4e8a63bc145ab95a29bc91bf79385_Out_0_Float, 2, _Multiply_9aee5a41025a481d9e84571d2ab6184f_Out_2_Float);
float _Dither_178111f60a844b2d84016493f37d5006_Out_2_Float;
Unity_Dither_float(_Multiply_9aee5a41025a481d9e84571d2ab6184f_Out_2_Float, float4(IN.NDCPosition.xy, 0, 0), _Dither_178111f60a844b2d84016493f37d5006_Out_2_Float);
float4 _ScreenPosition_476d67e49c27459481bcec3d59d12b7c_Out_0_Vector4 = float4(IN.NDCPosition.xy, 0, 0);
float _RandomRange_7bc0d55a2e4a4cb58a233e5903f0bd73_Out_3_Float;
Unity_RandomRange_float((_ScreenPosition_476d67e49c27459481bcec3d59d12b7c_Out_0_Vector4.xy), float(0), float(1), _RandomRange_7bc0d55a2e4a4cb58a233e5903f0bd73_Out_3_Float);
float _Comparison_9a87df5a14df41fab8cae7c380ae6da9_Out_2_Boolean;
Unity_Comparison_Greater_float(_Float_aac4e8a63bc145ab95a29bc91bf79385_Out_0_Float, _RandomRange_7bc0d55a2e4a4cb58a233e5903f0bd73_Out_3_Float, _Comparison_9a87df5a14df41fab8cae7c380ae6da9_Out_2_Boolean);
float _Property_6bd49cb9d4c74d0a82c2e6d2f0b066b5_Out_0_Float = _ditherToNoiseRatio;
float _Lerp_43f5dfd61d5f45b6bb3538c8cacc6b02_Out_3_Float;
Unity_Lerp_float(_Dither_178111f60a844b2d84016493f37d5006_Out_2_Float, ((float) _Comparison_9a87df5a14df41fab8cae7c380ae6da9_Out_2_Boolean), _Property_6bd49cb9d4c74d0a82c2e6d2f0b066b5_Out_0_Float, _Lerp_43f5dfd61d5f45b6bb3538c8cacc6b02_Out_3_Float);
float3 _Vector3_b2ecb20a57ed4c20bbaaef387177e80d_Out_0_Vector3 = float3(_Split_c4d9dd8d63054368a7beb9d2a61eb6ef_R_1_Float, _Split_c4d9dd8d63054368a7beb9d2a61eb6ef_G_2_Float, _Lerp_43f5dfd61d5f45b6bb3538c8cacc6b02_Out_3_Float);
float3 _ColorspaceConversion_6fdb1d464c4b43b382439b796f3ce10f_Out_1_Vector3;
Unity_ColorspaceConversion_HSV_RGB_float(_Vector3_b2ecb20a57ed4c20bbaaef387177e80d_Out_0_Vector3, _ColorspaceConversion_6fdb1d464c4b43b382439b796f3ce10f_Out_1_Vector3);
surface.BaseColor = _ColorspaceConversion_6fdb1d464c4b43b382439b796f3ce10f_Out_1_Vector3;
return surface;
}

// --------------------------------------------------
// Build Graph Inputs
#ifdef HAVE_VFX_MODIFICATION
#define VFX_SRP_ATTRIBUTES Attributes
#define VFX_SRP_VARYINGS Varyings
#define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
#endif
VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
    {
        VertexDescriptionInputs output;
        ZERO_INITIALIZE(VertexDescriptionInputs, output);
    
        output.ObjectSpaceNormal =                          input.normalOS;
        output.ObjectSpaceTangent =                         input.tangentOS.xyz;
        output.ObjectSpacePosition =                        input.positionOS;
    #if UNITY_ANY_INSTANCING_ENABLED
    #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
    #endif
    
        return output;
    }
    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
    {
        SurfaceDescriptionInputs output;
        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
    
    #ifdef HAVE_VFX_MODIFICATION
    #if VFX_USE_GRAPH_VALUES
        uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
        /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
    #endif
        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
    
    #endif
    
        
    
        // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        float3 unnormalizedNormalWS = input.normalWS;
        const float renormFactor = 1.0 / length(unnormalizedNormalWS);
    
    
        output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
    
    
    
        #if UNITY_UV_STARTS_AT_TOP
        output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
        #else
        output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
        #endif
    
        output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
        output.NDCPosition.y = 1.0f - output.NDCPosition.y;
    
        output.uv0 = input.texCoord0;
    #if UNITY_ANY_INSTANCING_ENABLED
    #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
    #endif
    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
    #else
    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
    #endif
    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
    
            return output;
    }
    
// --------------------------------------------------
// Main

#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/UnlitGBufferPass.hlsl"

// --------------------------------------------------
// Visual Effect Vertex Invocations
#ifdef HAVE_VFX_MODIFICATION
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
#endif

ENDHLSL
}
Pass
{
    Name "SceneSelectionPass"
    Tags
    {
        "LightMode" = "SceneSelectionPass"
    }

// Render State
Cull Off

// Debug
// <None>

// --------------------------------------------------
// Pass

HLSLPROGRAM

// Pragmas
#pragma target 2.0
#pragma vertex vert
#pragma fragment frag

// Keywords
// PassKeywords: <None>
// GraphKeywords: <None>

// Defines

#define ATTRIBUTES_NEED_NORMAL
#define ATTRIBUTES_NEED_TANGENT
#define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
#define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_DEPTHONLY
#define SCENESELECTIONPASS 1
#define ALPHA_CLIP_THRESHOLD 1


// custom interpolator pre-include
/* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

// Includes
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

// --------------------------------------------------
// Structs and Packing

// custom interpolators pre packing
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

struct Attributes
{
 float3 positionOS : POSITION;
 float3 normalOS : NORMAL;
 float4 tangentOS : TANGENT;
#if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
 uint instanceID : INSTANCEID_SEMANTIC;
#endif
};
struct Varyings
{
 float4 positionCS : SV_POSITION;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
 uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
};
struct SurfaceDescriptionInputs
{
};
struct VertexDescriptionInputs
{
 float3 ObjectSpaceNormal;
 float3 ObjectSpaceTangent;
 float3 ObjectSpacePosition;
};
struct PackedVaryings
{
 float4 positionCS : SV_POSITION;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
 uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
};

PackedVaryings PackVaryings (Varyings input)
{
PackedVaryings output;
ZERO_INITIALIZE(PackedVaryings, output);
output.positionCS = input.positionCS;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}

Varyings UnpackVaryings (PackedVaryings input)
{
Varyings output;
output.positionCS = input.positionCS;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}


// --------------------------------------------------
// Graph

// Graph Properties
CBUFFER_START(UnityPerMaterial)
float4 _OriginalTex_TexelSize;
float4 _Color;
float _ditherToNoiseRatio;
float2 _CutoffThresholds;
UNITY_TEXTURE_STREAMING_DEBUG_VARS;
CBUFFER_END


// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
TEXTURE2D(_OriginalTex);
SAMPLER(sampler_OriginalTex);

// Graph Includes
// GraphIncludes: <None>

// -- Property used by ScenePickingPass
#ifdef SCENEPICKINGPASS
float4 _SelectionID;
#endif

// -- Properties used by SceneSelectionPass
#ifdef SCENESELECTIONPASS
int _ObjectId;
int _PassValue;
#endif

// Graph Functions
// GraphFunctions: <None>

// Custom interpolators pre vertex
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

// Graph Vertex
struct VertexDescription
{
float3 Position;
float3 Normal;
float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
VertexDescription description = (VertexDescription)0;
description.Position = IN.ObjectSpacePosition;
description.Normal = IN.ObjectSpaceNormal;
description.Tangent = IN.ObjectSpaceTangent;
return description;
}

// Custom interpolators, pre surface
#ifdef FEATURES_GRAPH_VERTEX
Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
{
return output;
}
#define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
#endif

// Graph Pixel
struct SurfaceDescription
{
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
SurfaceDescription surface = (SurfaceDescription)0;
return surface;
}

// --------------------------------------------------
// Build Graph Inputs
#ifdef HAVE_VFX_MODIFICATION
#define VFX_SRP_ATTRIBUTES Attributes
#define VFX_SRP_VARYINGS Varyings
#define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
#endif
VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
    {
        VertexDescriptionInputs output;
        ZERO_INITIALIZE(VertexDescriptionInputs, output);
    
        output.ObjectSpaceNormal =                          input.normalOS;
        output.ObjectSpaceTangent =                         input.tangentOS.xyz;
        output.ObjectSpacePosition =                        input.positionOS;
    #if UNITY_ANY_INSTANCING_ENABLED
    #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
    #endif
    
        return output;
    }
    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
    {
        SurfaceDescriptionInputs output;
        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
    
    #ifdef HAVE_VFX_MODIFICATION
    #if VFX_USE_GRAPH_VALUES
        uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
        /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
    #endif
        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
    
    #endif
    
        
    
    
    
    
    
    
        #if UNITY_UV_STARTS_AT_TOP
        #else
        #endif
    
    
    #if UNITY_ANY_INSTANCING_ENABLED
    #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
    #endif
    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
    #else
    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
    #endif
    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
    
            return output;
    }
    
// --------------------------------------------------
// Main

#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"

// --------------------------------------------------
// Visual Effect Vertex Invocations
#ifdef HAVE_VFX_MODIFICATION
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
#endif

ENDHLSL
}
Pass
{
    Name "ScenePickingPass"
    Tags
    {
        "LightMode" = "Picking"
    }

// Render State
Cull Back

// Debug
// <None>

// --------------------------------------------------
// Pass

HLSLPROGRAM

// Pragmas
#pragma target 2.0
#pragma vertex vert
#pragma fragment frag

// Keywords
// PassKeywords: <None>
// GraphKeywords: <None>

// Defines

#define ATTRIBUTES_NEED_NORMAL
#define ATTRIBUTES_NEED_TANGENT
#define ATTRIBUTES_NEED_TEXCOORD0
#define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
#define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
#define VARYINGS_NEED_NORMAL_WS
#define VARYINGS_NEED_TEXCOORD0
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_DEPTHONLY
#define SCENEPICKINGPASS 1
#define ALPHA_CLIP_THRESHOLD 1


// custom interpolator pre-include
/* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

// Includes
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

// --------------------------------------------------
// Structs and Packing

// custom interpolators pre packing
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

struct Attributes
{
 float3 positionOS : POSITION;
 float3 normalOS : NORMAL;
 float4 tangentOS : TANGENT;
 float4 uv0 : TEXCOORD0;
#if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
 uint instanceID : INSTANCEID_SEMANTIC;
#endif
};
struct Varyings
{
 float4 positionCS : SV_POSITION;
 float3 normalWS;
 float4 texCoord0;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
 uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
};
struct SurfaceDescriptionInputs
{
 float3 WorldSpaceNormal;
 float2 NDCPosition;
 float2 PixelPosition;
 float4 uv0;
};
struct VertexDescriptionInputs
{
 float3 ObjectSpaceNormal;
 float3 ObjectSpaceTangent;
 float3 ObjectSpacePosition;
};
struct PackedVaryings
{
 float4 positionCS : SV_POSITION;
 float4 texCoord0 : INTERP0;
 float3 normalWS : INTERP1;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
 uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
};

PackedVaryings PackVaryings (Varyings input)
{
PackedVaryings output;
ZERO_INITIALIZE(PackedVaryings, output);
output.positionCS = input.positionCS;
output.texCoord0.xyzw = input.texCoord0;
output.normalWS.xyz = input.normalWS;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}

Varyings UnpackVaryings (PackedVaryings input)
{
Varyings output;
output.positionCS = input.positionCS;
output.texCoord0 = input.texCoord0.xyzw;
output.normalWS = input.normalWS.xyz;
#if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}


// --------------------------------------------------
// Graph

// Graph Properties
CBUFFER_START(UnityPerMaterial)
float4 _OriginalTex_TexelSize;
float4 _Color;
float _ditherToNoiseRatio;
float2 _CutoffThresholds;
UNITY_TEXTURE_STREAMING_DEBUG_VARS;
CBUFFER_END


// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
TEXTURE2D(_OriginalTex);
SAMPLER(sampler_OriginalTex);

// Graph Includes
// GraphIncludes: <None>

// -- Property used by ScenePickingPass
#ifdef SCENEPICKINGPASS
float4 _SelectionID;
#endif

// -- Properties used by SceneSelectionPass
#ifdef SCENESELECTIONPASS
int _ObjectId;
int _PassValue;
#endif

// Graph Functions

void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
{
Out = A * B;
}

void Unity_ColorspaceConversion_RGB_HSV_float(float3 In, out float3 Out)
{
    float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    float4 P = lerp(float4(In.bg, K.wz), float4(In.gb, K.xy), step(In.b, In.g));
    float4 Q = lerp(float4(P.xyw, In.r), float4(In.r, P.yzx), step(P.x, In.r));
    float D = Q.x - min(Q.w, Q.y);
    float  E = 1e-10;
    float V = (D == 0) ? Q.x : (Q.x + E);
    Out = float3(abs(Q.z + (Q.w - Q.y)/(6.0 * D + E)), D / (Q.x + E), V);
}

void MainLightDirection_float(out float3 Direction)
{
    #if SHADERGRAPH_PREVIEW
    Direction = half3(-0.5, -0.5, 0);
    #else
    Direction = SHADERGRAPH_MAIN_LIGHT_DIRECTION();
    #endif
}

void Unity_Negate_float3(float3 In, out float3 Out)
{
    Out = -1 * In;
}

void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
{
    Out = dot(A, B);
}

void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
{
    Out = smoothstep(Edge1, Edge2, In);
}

void Unity_Blend_HardLight_float(float Base, float Blend, out float Out, float Opacity)
{
    float result1 = 1.0 - 2.0 * (1.0 - Base) * (1.0 - Blend);
    float result2 = 2.0 * Base * Blend;
    float zeroOrOne = step(Blend, 0.5);
    Out = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
    Out = lerp(Base, Out, Opacity);
}

void Unity_Multiply_float_float(float A, float B, out float Out)
{
Out = A * B;
}

void Unity_Dither_float(float In, float4 ScreenPosition, out float Out)
{
    float2 uv = ScreenPosition.xy * _ScreenParams.xy;
    float DITHER_THRESHOLDS[16] =
    {
        1.0 / 17.0,  9.0 / 17.0,  3.0 / 17.0, 11.0 / 17.0,
        13.0 / 17.0,  5.0 / 17.0, 15.0 / 17.0,  7.0 / 17.0,
        4.0 / 17.0, 12.0 / 17.0,  2.0 / 17.0, 10.0 / 17.0,
        16.0 / 17.0,  8.0 / 17.0, 14.0 / 17.0,  6.0 / 17.0
    };
    uint index = (uint(uv.x) % 4) * 4 + uint(uv.y) % 4;
    Out = In - DITHER_THRESHOLDS[index];
}

void Unity_RandomRange_float(float2 Seed, float Min, float Max, out float Out)
{
     float randomno =  frac(sin(dot(Seed, float2(12.9898, 78.233)))*43758.5453);
     Out = lerp(Min, Max, randomno);
}

void Unity_Comparison_Greater_float(float A, float B, out float Out)
{
    Out = A > B ? 1 : 0;
}

void Unity_Lerp_float(float A, float B, float T, out float Out)
{
    Out = lerp(A, B, T);
}

void Unity_ColorspaceConversion_HSV_RGB_float(float3 In, out float3 Out)
{
    float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    float3 P = abs(frac(In.xxx + K.xyz) * 6.0 - K.www);
    Out = In.z * lerp(K.xxx, saturate(P - K.xxx), In.y);
}

// Custom interpolators pre vertex
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

// Graph Vertex
struct VertexDescription
{
float3 Position;
float3 Normal;
float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
VertexDescription description = (VertexDescription)0;
description.Position = IN.ObjectSpacePosition;
description.Normal = IN.ObjectSpaceNormal;
description.Tangent = IN.ObjectSpaceTangent;
return description;
}

// Custom interpolators, pre surface
#ifdef FEATURES_GRAPH_VERTEX
Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
{
return output;
}
#define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
#endif

// Graph Pixel
struct SurfaceDescription
{
float3 BaseColor;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
SurfaceDescription surface = (SurfaceDescription)0;
UnityTexture2D _Property_99468924ee3b4b59ab1541b3cf90badd_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_OriginalTex);
float4 _UV_059412960ef84b3fb7cb447bea372777_Out_0_Vector4 = IN.uv0;
float4 _SampleTexture2D_42c7c0781dd344c2ae9340e648f11a4c_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_99468924ee3b4b59ab1541b3cf90badd_Out_0_Texture2D.tex, _Property_99468924ee3b4b59ab1541b3cf90badd_Out_0_Texture2D.samplerstate, _Property_99468924ee3b4b59ab1541b3cf90badd_Out_0_Texture2D.GetTransformedUV((_UV_059412960ef84b3fb7cb447bea372777_Out_0_Vector4.xy)) );
float _SampleTexture2D_42c7c0781dd344c2ae9340e648f11a4c_R_4_Float = _SampleTexture2D_42c7c0781dd344c2ae9340e648f11a4c_RGBA_0_Vector4.r;
float _SampleTexture2D_42c7c0781dd344c2ae9340e648f11a4c_G_5_Float = _SampleTexture2D_42c7c0781dd344c2ae9340e648f11a4c_RGBA_0_Vector4.g;
float _SampleTexture2D_42c7c0781dd344c2ae9340e648f11a4c_B_6_Float = _SampleTexture2D_42c7c0781dd344c2ae9340e648f11a4c_RGBA_0_Vector4.b;
float _SampleTexture2D_42c7c0781dd344c2ae9340e648f11a4c_A_7_Float = _SampleTexture2D_42c7c0781dd344c2ae9340e648f11a4c_RGBA_0_Vector4.a;
float4 _Property_dd8f7b8dc32c4254b4e8f5a657a7af67_Out_0_Vector4 = _Color;
float4 _Multiply_d1a4c49a5ad74ac2b92dea28aaa7e273_Out_2_Vector4;
Unity_Multiply_float4_float4(_SampleTexture2D_42c7c0781dd344c2ae9340e648f11a4c_RGBA_0_Vector4, _Property_dd8f7b8dc32c4254b4e8f5a657a7af67_Out_0_Vector4, _Multiply_d1a4c49a5ad74ac2b92dea28aaa7e273_Out_2_Vector4);
float3 _ColorspaceConversion_48175174be9e49b8b5a4bd2507f559d2_Out_1_Vector3;
Unity_ColorspaceConversion_RGB_HSV_float((_Multiply_d1a4c49a5ad74ac2b92dea28aaa7e273_Out_2_Vector4.xyz), _ColorspaceConversion_48175174be9e49b8b5a4bd2507f559d2_Out_1_Vector3);
float _Split_c4d9dd8d63054368a7beb9d2a61eb6ef_R_1_Float = _ColorspaceConversion_48175174be9e49b8b5a4bd2507f559d2_Out_1_Vector3[0];
float _Split_c4d9dd8d63054368a7beb9d2a61eb6ef_G_2_Float = _ColorspaceConversion_48175174be9e49b8b5a4bd2507f559d2_Out_1_Vector3[1];
float _Split_c4d9dd8d63054368a7beb9d2a61eb6ef_B_3_Float = _ColorspaceConversion_48175174be9e49b8b5a4bd2507f559d2_Out_1_Vector3[2];
float _Split_c4d9dd8d63054368a7beb9d2a61eb6ef_A_4_Float = 0;
float2 _Property_b865684938e04c81bcf72c43e3b1f0c9_Out_0_Vector2 = _CutoffThresholds;
float _Split_af657b9014aa431fad81fda380b6a623_R_1_Float = _Property_b865684938e04c81bcf72c43e3b1f0c9_Out_0_Vector2[0];
float _Split_af657b9014aa431fad81fda380b6a623_G_2_Float = _Property_b865684938e04c81bcf72c43e3b1f0c9_Out_0_Vector2[1];
float _Split_af657b9014aa431fad81fda380b6a623_B_3_Float = 0;
float _Split_af657b9014aa431fad81fda380b6a623_A_4_Float = 0;
float3 _MainLightDirection_24c122e7fcaf4227bfad8ee2042f4a5f_Direction_0_Vector3;
MainLightDirection_float(_MainLightDirection_24c122e7fcaf4227bfad8ee2042f4a5f_Direction_0_Vector3);
float3 _Negate_7fe8f0a65b8c40f784e816f7fd62d36d_Out_1_Vector3;
Unity_Negate_float3(_MainLightDirection_24c122e7fcaf4227bfad8ee2042f4a5f_Direction_0_Vector3, _Negate_7fe8f0a65b8c40f784e816f7fd62d36d_Out_1_Vector3);
float _DotProduct_33f4e0e36f534b24b02ee9b610d70652_Out_2_Float;
Unity_DotProduct_float3(_Negate_7fe8f0a65b8c40f784e816f7fd62d36d_Out_1_Vector3, IN.WorldSpaceNormal, _DotProduct_33f4e0e36f534b24b02ee9b610d70652_Out_2_Float);
float _Smoothstep_5650b32ba8b9412c960a117ca08cc7b7_Out_3_Float;
Unity_Smoothstep_float(_Split_af657b9014aa431fad81fda380b6a623_R_1_Float, _Split_af657b9014aa431fad81fda380b6a623_G_2_Float, _DotProduct_33f4e0e36f534b24b02ee9b610d70652_Out_2_Float, _Smoothstep_5650b32ba8b9412c960a117ca08cc7b7_Out_3_Float);
float _Blend_5174bd68113148618a7545e50a011478_Out_2_Float;
Unity_Blend_HardLight_float(_Split_c4d9dd8d63054368a7beb9d2a61eb6ef_B_3_Float, _Smoothstep_5650b32ba8b9412c960a117ca08cc7b7_Out_3_Float, _Blend_5174bd68113148618a7545e50a011478_Out_2_Float, float(0.5));
float _Float_aac4e8a63bc145ab95a29bc91bf79385_Out_0_Float = _Blend_5174bd68113148618a7545e50a011478_Out_2_Float;
float _Multiply_9aee5a41025a481d9e84571d2ab6184f_Out_2_Float;
Unity_Multiply_float_float(_Float_aac4e8a63bc145ab95a29bc91bf79385_Out_0_Float, 2, _Multiply_9aee5a41025a481d9e84571d2ab6184f_Out_2_Float);
float _Dither_178111f60a844b2d84016493f37d5006_Out_2_Float;
Unity_Dither_float(_Multiply_9aee5a41025a481d9e84571d2ab6184f_Out_2_Float, float4(IN.NDCPosition.xy, 0, 0), _Dither_178111f60a844b2d84016493f37d5006_Out_2_Float);
float4 _ScreenPosition_476d67e49c27459481bcec3d59d12b7c_Out_0_Vector4 = float4(IN.NDCPosition.xy, 0, 0);
float _RandomRange_7bc0d55a2e4a4cb58a233e5903f0bd73_Out_3_Float;
Unity_RandomRange_float((_ScreenPosition_476d67e49c27459481bcec3d59d12b7c_Out_0_Vector4.xy), float(0), float(1), _RandomRange_7bc0d55a2e4a4cb58a233e5903f0bd73_Out_3_Float);
float _Comparison_9a87df5a14df41fab8cae7c380ae6da9_Out_2_Boolean;
Unity_Comparison_Greater_float(_Float_aac4e8a63bc145ab95a29bc91bf79385_Out_0_Float, _RandomRange_7bc0d55a2e4a4cb58a233e5903f0bd73_Out_3_Float, _Comparison_9a87df5a14df41fab8cae7c380ae6da9_Out_2_Boolean);
float _Property_6bd49cb9d4c74d0a82c2e6d2f0b066b5_Out_0_Float = _ditherToNoiseRatio;
float _Lerp_43f5dfd61d5f45b6bb3538c8cacc6b02_Out_3_Float;
Unity_Lerp_float(_Dither_178111f60a844b2d84016493f37d5006_Out_2_Float, ((float) _Comparison_9a87df5a14df41fab8cae7c380ae6da9_Out_2_Boolean), _Property_6bd49cb9d4c74d0a82c2e6d2f0b066b5_Out_0_Float, _Lerp_43f5dfd61d5f45b6bb3538c8cacc6b02_Out_3_Float);
float3 _Vector3_b2ecb20a57ed4c20bbaaef387177e80d_Out_0_Vector3 = float3(_Split_c4d9dd8d63054368a7beb9d2a61eb6ef_R_1_Float, _Split_c4d9dd8d63054368a7beb9d2a61eb6ef_G_2_Float, _Lerp_43f5dfd61d5f45b6bb3538c8cacc6b02_Out_3_Float);
float3 _ColorspaceConversion_6fdb1d464c4b43b382439b796f3ce10f_Out_1_Vector3;
Unity_ColorspaceConversion_HSV_RGB_float(_Vector3_b2ecb20a57ed4c20bbaaef387177e80d_Out_0_Vector3, _ColorspaceConversion_6fdb1d464c4b43b382439b796f3ce10f_Out_1_Vector3);
surface.BaseColor = _ColorspaceConversion_6fdb1d464c4b43b382439b796f3ce10f_Out_1_Vector3;
return surface;
}

// --------------------------------------------------
// Build Graph Inputs
#ifdef HAVE_VFX_MODIFICATION
#define VFX_SRP_ATTRIBUTES Attributes
#define VFX_SRP_VARYINGS Varyings
#define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
#endif
VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
    {
        VertexDescriptionInputs output;
        ZERO_INITIALIZE(VertexDescriptionInputs, output);
    
        output.ObjectSpaceNormal =                          input.normalOS;
        output.ObjectSpaceTangent =                         input.tangentOS.xyz;
        output.ObjectSpacePosition =                        input.positionOS;
    #if UNITY_ANY_INSTANCING_ENABLED
    #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
    #endif
    
        return output;
    }
    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
    {
        SurfaceDescriptionInputs output;
        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
    
    #ifdef HAVE_VFX_MODIFICATION
    #if VFX_USE_GRAPH_VALUES
        uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
        /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
    #endif
        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
    
    #endif
    
        
    
        // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        float3 unnormalizedNormalWS = input.normalWS;
        const float renormFactor = 1.0 / length(unnormalizedNormalWS);
    
    
        output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
    
    
    
        #if UNITY_UV_STARTS_AT_TOP
        output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
        #else
        output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
        #endif
    
        output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
        output.NDCPosition.y = 1.0f - output.NDCPosition.y;
    
        output.uv0 = input.texCoord0;
    #if UNITY_ANY_INSTANCING_ENABLED
    #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
    #endif
    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
    #else
    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
    #endif
    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
    
            return output;
    }
    
// --------------------------------------------------
// Main

#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"

// --------------------------------------------------
// Visual Effect Vertex Invocations
#ifdef HAVE_VFX_MODIFICATION
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
#endif

ENDHLSL
}
}
CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
CustomEditorForRenderPipeline "UnityEditor.ShaderGraphUnlitGUI" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
FallBack "Hidden/Shader Graph/FallbackError"
}