// Stencil Injection by ShaderGraphStencilInjector

Shader "Stencil Shader Graph/StencilFog"
{
Properties
{
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
"Queue"="AlphaTest"
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
AlphaToMask On

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
#define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
#define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
#define VARYINGS_NEED_POSITION_WS
#define VARYINGS_NEED_NORMAL_WS
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_UNLIT
#define _FOG_FRAGMENT 1
#define _ALPHATEST_ON 1


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
#if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
 uint instanceID : INSTANCEID_SEMANTIC;
#endif
};
struct Varyings
{
 float4 positionCS : SV_POSITION;
 float3 positionWS;
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
 float3 WorldSpaceNormal;
 float3 WorldSpaceViewDirection;
 float2 NDCPosition;
 float2 PixelPosition;
 float3 TimeParameters;
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
 float3 positionWS : INTERP0;
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
UNITY_TEXTURE_STREAMING_DEBUG_VARS;
CBUFFER_END


// Object and Global properties

// Graph Includes
#include_with_pragmas "Assets/Materials/Noise/NoiseShader/ImageGenerator (1).hlsl"

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

void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
{
    Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
}

void Unity_OneMinus_float(float In, out float Out)
{
    Out = 1 - In;
}

void Unity_Add_float(float A, float B, out float Out)
{
    Out = A + B;
}

void Unity_Divide_float(float A, float B, out float Out)
{
    Out = A / B;
}

void Unity_RandomRange_float(float2 Seed, float Min, float Max, out float Out)
{
     float randomno =  frac(sin(dot(Seed, float2(12.9898, 78.233)))*43758.5453);
     Out = lerp(Min, Max, randomno);
}

void Unity_Blend_Overlay_float(float Base, float Blend, out float Out, float Opacity)
{
    float result1 = 1.0 - 2.0 * (1.0 - Base) * (1.0 - Blend);
    float result2 = 2.0 * Base * Blend;
    float zeroOrOne = step(Base, 0.5);
    Out = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
    Out = lerp(Base, Out, Opacity);
}

void Unity_Comparison_Greater_float(float A, float B, out float Out)
{
    Out = A > B ? 1 : 0;
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
float Alpha;
float AlphaClipThreshold;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
SurfaceDescription surface = (SurfaceDescription)0;
float _FresnelEffect_6f758b19f2af4fc98b8eea99c7d71bd3_Out_3_Float;
Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, float(0.13), _FresnelEffect_6f758b19f2af4fc98b8eea99c7d71bd3_Out_3_Float);
float _OneMinus_e4b88cf8ea1b4b32bed63c1b104ad30e_Out_1_Float;
Unity_OneMinus_float(_FresnelEffect_6f758b19f2af4fc98b8eea99c7d71bd3_Out_3_Float, _OneMinus_e4b88cf8ea1b4b32bed63c1b104ad30e_Out_1_Float);
float _FresnelEffect_286e15be0c7a494d8806aa2b7128ef23_Out_3_Float;
Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, float(0.66), _FresnelEffect_286e15be0c7a494d8806aa2b7128ef23_Out_3_Float);
float _Add_d36af46da02046ce9560de5498c79671_Out_2_Float;
Unity_Add_float(_FresnelEffect_286e15be0c7a494d8806aa2b7128ef23_Out_3_Float, float(0.24), _Add_d36af46da02046ce9560de5498c79671_Out_2_Float);
float _OneMinus_a0ca3eb5267d4b6c88c142f9ff7e4a1c_Out_1_Float;
Unity_OneMinus_float(_Add_d36af46da02046ce9560de5498c79671_Out_2_Float, _OneMinus_a0ca3eb5267d4b6c88c142f9ff7e4a1c_Out_1_Float);
float _Add_eeaf240474b648fbaf8ef43bac2fcdbf_Out_2_Float;
Unity_Add_float(_OneMinus_e4b88cf8ea1b4b32bed63c1b104ad30e_Out_1_Float, _OneMinus_a0ca3eb5267d4b6c88c142f9ff7e4a1c_Out_1_Float, _Add_eeaf240474b648fbaf8ef43bac2fcdbf_Out_2_Float);
float4 _ScreenPosition_8d9021488038460cb1336474c073db33_Out_0_Vector4 = float4(IN.NDCPosition.xy, 0, 0);
float _Divide_45f6237f772244c8b721940a54c4b3dc_Out_2_Float;
Unity_Divide_float(IN.TimeParameters.x, float(2), _Divide_45f6237f772244c8b721940a54c4b3dc_Out_2_Float);
float _Divide_f6fc0efea14345a58111006e71ea95e2_Out_2_Float;
Unity_Divide_float(IN.TimeParameters.x, float(20), _Divide_f6fc0efea14345a58111006e71ea95e2_Out_2_Float);
float3 _Vector3_11675ccb66fd4f8497756cd68d560179_Out_0_Vector3 = float3(_Divide_45f6237f772244c8b721940a54c4b3dc_Out_2_Float, float(0), _Divide_f6fc0efea14345a58111006e71ea95e2_Out_2_Float);
float _ImageGeneratorMainCustomFunction_077b1daf1f1244bdb3ae7b6af74cc447_Output_1_Float;
ImageGeneratorMain_float((_ScreenPosition_8d9021488038460cb1336474c073db33_Out_0_Vector4.xy), float(4.47), float(8.45), _Vector3_11675ccb66fd4f8497756cd68d560179_Out_0_Vector3, float(0.91), _ImageGeneratorMainCustomFunction_077b1daf1f1244bdb3ae7b6af74cc447_Output_1_Float);
float _RandomRange_e2991f33575e417e93e11c210bd32a75_Out_3_Float;
Unity_RandomRange_float((_ScreenPosition_8d9021488038460cb1336474c073db33_Out_0_Vector4.xy), float(0), float(0.7), _RandomRange_e2991f33575e417e93e11c210bd32a75_Out_3_Float);
float _Blend_254c6fdb71264f03ba503442029a4c83_Out_2_Float;
Unity_Blend_Overlay_float(_ImageGeneratorMainCustomFunction_077b1daf1f1244bdb3ae7b6af74cc447_Output_1_Float, _RandomRange_e2991f33575e417e93e11c210bd32a75_Out_3_Float, _Blend_254c6fdb71264f03ba503442029a4c83_Out_2_Float, float(1));
float _Comparison_73d712f5846b42f88a28d30ca41e8d72_Out_2_Boolean;
Unity_Comparison_Greater_float(_Blend_254c6fdb71264f03ba503442029a4c83_Out_2_Float, float(0.24), _Comparison_73d712f5846b42f88a28d30ca41e8d72_Out_2_Boolean);
float _Blend_f3336b09d4a240c8b7a478c28569698a_Out_2_Float;
Unity_Blend_Overlay_float(_Add_eeaf240474b648fbaf8ef43bac2fcdbf_Out_2_Float, ((float) _Comparison_73d712f5846b42f88a28d30ca41e8d72_Out_2_Boolean), _Blend_f3336b09d4a240c8b7a478c28569698a_Out_2_Float, float(0.83));
float _Multiply_3c5aced32bed437a9ceb9ad0a07f97d6_Out_2_Float;
Unity_Multiply_float_float(_Blend_f3336b09d4a240c8b7a478c28569698a_Out_2_Float, 2, _Multiply_3c5aced32bed437a9ceb9ad0a07f97d6_Out_2_Float);
float _Dither_c1a1fb6b712843498265dcc4192c91f7_Out_2_Float;
Unity_Dither_float(_Multiply_3c5aced32bed437a9ceb9ad0a07f97d6_Out_2_Float, float4(IN.NDCPosition.xy, 0, 0), _Dither_c1a1fb6b712843498265dcc4192c91f7_Out_2_Float);
surface.BaseColor = IsGammaSpace() ? float3(1, 1, 1) : SRGBToLinear(float3(1, 1, 1));
surface.Alpha = _Dither_c1a1fb6b712843498265dcc4192c91f7_Out_2_Float;
surface.AlphaClipThreshold = float(0.5);
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
    
    
        output.WorldSpaceViewDirection = GetWorldSpaceNormalizeViewDir(input.positionWS);
    
        #if UNITY_UV_STARTS_AT_TOP
        output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
        #else
        output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
        #endif
    
        output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
        output.NDCPosition.y = 1.0f - output.NDCPosition.y;
    
    #if UNITY_ANY_INSTANCING_ENABLED
    #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
    #endif
        output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
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
#define VARYINGS_NEED_POSITION_WS
#define VARYINGS_NEED_NORMAL_WS
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_DEPTHONLY
#define _ALPHATEST_ON 1


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
 float3 positionWS;
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
 float3 WorldSpaceNormal;
 float3 WorldSpaceViewDirection;
 float2 NDCPosition;
 float2 PixelPosition;
 float3 TimeParameters;
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
 float3 positionWS : INTERP0;
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
UNITY_TEXTURE_STREAMING_DEBUG_VARS;
CBUFFER_END


// Object and Global properties

// Graph Includes
#include_with_pragmas "Assets/Materials/Noise/NoiseShader/ImageGenerator (1).hlsl"

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

void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
{
    Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
}

void Unity_OneMinus_float(float In, out float Out)
{
    Out = 1 - In;
}

void Unity_Add_float(float A, float B, out float Out)
{
    Out = A + B;
}

void Unity_Divide_float(float A, float B, out float Out)
{
    Out = A / B;
}

void Unity_RandomRange_float(float2 Seed, float Min, float Max, out float Out)
{
     float randomno =  frac(sin(dot(Seed, float2(12.9898, 78.233)))*43758.5453);
     Out = lerp(Min, Max, randomno);
}

void Unity_Blend_Overlay_float(float Base, float Blend, out float Out, float Opacity)
{
    float result1 = 1.0 - 2.0 * (1.0 - Base) * (1.0 - Blend);
    float result2 = 2.0 * Base * Blend;
    float zeroOrOne = step(Base, 0.5);
    Out = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
    Out = lerp(Base, Out, Opacity);
}

void Unity_Comparison_Greater_float(float A, float B, out float Out)
{
    Out = A > B ? 1 : 0;
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
float Alpha;
float AlphaClipThreshold;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
SurfaceDescription surface = (SurfaceDescription)0;
float _FresnelEffect_6f758b19f2af4fc98b8eea99c7d71bd3_Out_3_Float;
Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, float(0.13), _FresnelEffect_6f758b19f2af4fc98b8eea99c7d71bd3_Out_3_Float);
float _OneMinus_e4b88cf8ea1b4b32bed63c1b104ad30e_Out_1_Float;
Unity_OneMinus_float(_FresnelEffect_6f758b19f2af4fc98b8eea99c7d71bd3_Out_3_Float, _OneMinus_e4b88cf8ea1b4b32bed63c1b104ad30e_Out_1_Float);
float _FresnelEffect_286e15be0c7a494d8806aa2b7128ef23_Out_3_Float;
Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, float(0.66), _FresnelEffect_286e15be0c7a494d8806aa2b7128ef23_Out_3_Float);
float _Add_d36af46da02046ce9560de5498c79671_Out_2_Float;
Unity_Add_float(_FresnelEffect_286e15be0c7a494d8806aa2b7128ef23_Out_3_Float, float(0.24), _Add_d36af46da02046ce9560de5498c79671_Out_2_Float);
float _OneMinus_a0ca3eb5267d4b6c88c142f9ff7e4a1c_Out_1_Float;
Unity_OneMinus_float(_Add_d36af46da02046ce9560de5498c79671_Out_2_Float, _OneMinus_a0ca3eb5267d4b6c88c142f9ff7e4a1c_Out_1_Float);
float _Add_eeaf240474b648fbaf8ef43bac2fcdbf_Out_2_Float;
Unity_Add_float(_OneMinus_e4b88cf8ea1b4b32bed63c1b104ad30e_Out_1_Float, _OneMinus_a0ca3eb5267d4b6c88c142f9ff7e4a1c_Out_1_Float, _Add_eeaf240474b648fbaf8ef43bac2fcdbf_Out_2_Float);
float4 _ScreenPosition_8d9021488038460cb1336474c073db33_Out_0_Vector4 = float4(IN.NDCPosition.xy, 0, 0);
float _Divide_45f6237f772244c8b721940a54c4b3dc_Out_2_Float;
Unity_Divide_float(IN.TimeParameters.x, float(2), _Divide_45f6237f772244c8b721940a54c4b3dc_Out_2_Float);
float _Divide_f6fc0efea14345a58111006e71ea95e2_Out_2_Float;
Unity_Divide_float(IN.TimeParameters.x, float(20), _Divide_f6fc0efea14345a58111006e71ea95e2_Out_2_Float);
float3 _Vector3_11675ccb66fd4f8497756cd68d560179_Out_0_Vector3 = float3(_Divide_45f6237f772244c8b721940a54c4b3dc_Out_2_Float, float(0), _Divide_f6fc0efea14345a58111006e71ea95e2_Out_2_Float);
float _ImageGeneratorMainCustomFunction_077b1daf1f1244bdb3ae7b6af74cc447_Output_1_Float;
ImageGeneratorMain_float((_ScreenPosition_8d9021488038460cb1336474c073db33_Out_0_Vector4.xy), float(4.47), float(8.45), _Vector3_11675ccb66fd4f8497756cd68d560179_Out_0_Vector3, float(0.91), _ImageGeneratorMainCustomFunction_077b1daf1f1244bdb3ae7b6af74cc447_Output_1_Float);
float _RandomRange_e2991f33575e417e93e11c210bd32a75_Out_3_Float;
Unity_RandomRange_float((_ScreenPosition_8d9021488038460cb1336474c073db33_Out_0_Vector4.xy), float(0), float(0.7), _RandomRange_e2991f33575e417e93e11c210bd32a75_Out_3_Float);
float _Blend_254c6fdb71264f03ba503442029a4c83_Out_2_Float;
Unity_Blend_Overlay_float(_ImageGeneratorMainCustomFunction_077b1daf1f1244bdb3ae7b6af74cc447_Output_1_Float, _RandomRange_e2991f33575e417e93e11c210bd32a75_Out_3_Float, _Blend_254c6fdb71264f03ba503442029a4c83_Out_2_Float, float(1));
float _Comparison_73d712f5846b42f88a28d30ca41e8d72_Out_2_Boolean;
Unity_Comparison_Greater_float(_Blend_254c6fdb71264f03ba503442029a4c83_Out_2_Float, float(0.24), _Comparison_73d712f5846b42f88a28d30ca41e8d72_Out_2_Boolean);
float _Blend_f3336b09d4a240c8b7a478c28569698a_Out_2_Float;
Unity_Blend_Overlay_float(_Add_eeaf240474b648fbaf8ef43bac2fcdbf_Out_2_Float, ((float) _Comparison_73d712f5846b42f88a28d30ca41e8d72_Out_2_Boolean), _Blend_f3336b09d4a240c8b7a478c28569698a_Out_2_Float, float(0.83));
float _Multiply_3c5aced32bed437a9ceb9ad0a07f97d6_Out_2_Float;
Unity_Multiply_float_float(_Blend_f3336b09d4a240c8b7a478c28569698a_Out_2_Float, 2, _Multiply_3c5aced32bed437a9ceb9ad0a07f97d6_Out_2_Float);
float _Dither_c1a1fb6b712843498265dcc4192c91f7_Out_2_Float;
Unity_Dither_float(_Multiply_3c5aced32bed437a9ceb9ad0a07f97d6_Out_2_Float, float4(IN.NDCPosition.xy, 0, 0), _Dither_c1a1fb6b712843498265dcc4192c91f7_Out_2_Float);
surface.Alpha = _Dither_c1a1fb6b712843498265dcc4192c91f7_Out_2_Float;
surface.AlphaClipThreshold = float(0.5);
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
    
    
        output.WorldSpaceViewDirection = GetWorldSpaceNormalizeViewDir(input.positionWS);
    
        #if UNITY_UV_STARTS_AT_TOP
        output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
        #else
        output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
        #endif
    
        output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
        output.NDCPosition.y = 1.0f - output.NDCPosition.y;
    
    #if UNITY_ANY_INSTANCING_ENABLED
    #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
    #endif
        output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
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

#define ATTRIBUTES_NEED_NORMAL
#define VARYINGS_NEED_POSITION_WS
#define VARYINGS_NEED_NORMAL_WS
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_MOTION_VECTORS
#define _ALPHATEST_ON 1


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
#if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
 uint instanceID : INSTANCEID_SEMANTIC;
#endif
};
struct Varyings
{
 float4 positionCS : SV_POSITION;
 float3 positionWS;
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
 float3 WorldSpaceNormal;
 float3 WorldSpaceViewDirection;
 float2 NDCPosition;
 float2 PixelPosition;
 float3 TimeParameters;
};
struct VertexDescriptionInputs
{
 float3 ObjectSpacePosition;
};
struct PackedVaryings
{
 float4 positionCS : SV_POSITION;
 float3 positionWS : INTERP0;
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
UNITY_TEXTURE_STREAMING_DEBUG_VARS;
CBUFFER_END


// Object and Global properties

// Graph Includes
#include_with_pragmas "Assets/Materials/Noise/NoiseShader/ImageGenerator (1).hlsl"

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

void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
{
    Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
}

void Unity_OneMinus_float(float In, out float Out)
{
    Out = 1 - In;
}

void Unity_Add_float(float A, float B, out float Out)
{
    Out = A + B;
}

void Unity_Divide_float(float A, float B, out float Out)
{
    Out = A / B;
}

void Unity_RandomRange_float(float2 Seed, float Min, float Max, out float Out)
{
     float randomno =  frac(sin(dot(Seed, float2(12.9898, 78.233)))*43758.5453);
     Out = lerp(Min, Max, randomno);
}

void Unity_Blend_Overlay_float(float Base, float Blend, out float Out, float Opacity)
{
    float result1 = 1.0 - 2.0 * (1.0 - Base) * (1.0 - Blend);
    float result2 = 2.0 * Base * Blend;
    float zeroOrOne = step(Base, 0.5);
    Out = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
    Out = lerp(Base, Out, Opacity);
}

void Unity_Comparison_Greater_float(float A, float B, out float Out)
{
    Out = A > B ? 1 : 0;
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
float Alpha;
float AlphaClipThreshold;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
SurfaceDescription surface = (SurfaceDescription)0;
float _FresnelEffect_6f758b19f2af4fc98b8eea99c7d71bd3_Out_3_Float;
Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, float(0.13), _FresnelEffect_6f758b19f2af4fc98b8eea99c7d71bd3_Out_3_Float);
float _OneMinus_e4b88cf8ea1b4b32bed63c1b104ad30e_Out_1_Float;
Unity_OneMinus_float(_FresnelEffect_6f758b19f2af4fc98b8eea99c7d71bd3_Out_3_Float, _OneMinus_e4b88cf8ea1b4b32bed63c1b104ad30e_Out_1_Float);
float _FresnelEffect_286e15be0c7a494d8806aa2b7128ef23_Out_3_Float;
Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, float(0.66), _FresnelEffect_286e15be0c7a494d8806aa2b7128ef23_Out_3_Float);
float _Add_d36af46da02046ce9560de5498c79671_Out_2_Float;
Unity_Add_float(_FresnelEffect_286e15be0c7a494d8806aa2b7128ef23_Out_3_Float, float(0.24), _Add_d36af46da02046ce9560de5498c79671_Out_2_Float);
float _OneMinus_a0ca3eb5267d4b6c88c142f9ff7e4a1c_Out_1_Float;
Unity_OneMinus_float(_Add_d36af46da02046ce9560de5498c79671_Out_2_Float, _OneMinus_a0ca3eb5267d4b6c88c142f9ff7e4a1c_Out_1_Float);
float _Add_eeaf240474b648fbaf8ef43bac2fcdbf_Out_2_Float;
Unity_Add_float(_OneMinus_e4b88cf8ea1b4b32bed63c1b104ad30e_Out_1_Float, _OneMinus_a0ca3eb5267d4b6c88c142f9ff7e4a1c_Out_1_Float, _Add_eeaf240474b648fbaf8ef43bac2fcdbf_Out_2_Float);
float4 _ScreenPosition_8d9021488038460cb1336474c073db33_Out_0_Vector4 = float4(IN.NDCPosition.xy, 0, 0);
float _Divide_45f6237f772244c8b721940a54c4b3dc_Out_2_Float;
Unity_Divide_float(IN.TimeParameters.x, float(2), _Divide_45f6237f772244c8b721940a54c4b3dc_Out_2_Float);
float _Divide_f6fc0efea14345a58111006e71ea95e2_Out_2_Float;
Unity_Divide_float(IN.TimeParameters.x, float(20), _Divide_f6fc0efea14345a58111006e71ea95e2_Out_2_Float);
float3 _Vector3_11675ccb66fd4f8497756cd68d560179_Out_0_Vector3 = float3(_Divide_45f6237f772244c8b721940a54c4b3dc_Out_2_Float, float(0), _Divide_f6fc0efea14345a58111006e71ea95e2_Out_2_Float);
float _ImageGeneratorMainCustomFunction_077b1daf1f1244bdb3ae7b6af74cc447_Output_1_Float;
ImageGeneratorMain_float((_ScreenPosition_8d9021488038460cb1336474c073db33_Out_0_Vector4.xy), float(4.47), float(8.45), _Vector3_11675ccb66fd4f8497756cd68d560179_Out_0_Vector3, float(0.91), _ImageGeneratorMainCustomFunction_077b1daf1f1244bdb3ae7b6af74cc447_Output_1_Float);
float _RandomRange_e2991f33575e417e93e11c210bd32a75_Out_3_Float;
Unity_RandomRange_float((_ScreenPosition_8d9021488038460cb1336474c073db33_Out_0_Vector4.xy), float(0), float(0.7), _RandomRange_e2991f33575e417e93e11c210bd32a75_Out_3_Float);
float _Blend_254c6fdb71264f03ba503442029a4c83_Out_2_Float;
Unity_Blend_Overlay_float(_ImageGeneratorMainCustomFunction_077b1daf1f1244bdb3ae7b6af74cc447_Output_1_Float, _RandomRange_e2991f33575e417e93e11c210bd32a75_Out_3_Float, _Blend_254c6fdb71264f03ba503442029a4c83_Out_2_Float, float(1));
float _Comparison_73d712f5846b42f88a28d30ca41e8d72_Out_2_Boolean;
Unity_Comparison_Greater_float(_Blend_254c6fdb71264f03ba503442029a4c83_Out_2_Float, float(0.24), _Comparison_73d712f5846b42f88a28d30ca41e8d72_Out_2_Boolean);
float _Blend_f3336b09d4a240c8b7a478c28569698a_Out_2_Float;
Unity_Blend_Overlay_float(_Add_eeaf240474b648fbaf8ef43bac2fcdbf_Out_2_Float, ((float) _Comparison_73d712f5846b42f88a28d30ca41e8d72_Out_2_Boolean), _Blend_f3336b09d4a240c8b7a478c28569698a_Out_2_Float, float(0.83));
float _Multiply_3c5aced32bed437a9ceb9ad0a07f97d6_Out_2_Float;
Unity_Multiply_float_float(_Blend_f3336b09d4a240c8b7a478c28569698a_Out_2_Float, 2, _Multiply_3c5aced32bed437a9ceb9ad0a07f97d6_Out_2_Float);
float _Dither_c1a1fb6b712843498265dcc4192c91f7_Out_2_Float;
Unity_Dither_float(_Multiply_3c5aced32bed437a9ceb9ad0a07f97d6_Out_2_Float, float4(IN.NDCPosition.xy, 0, 0), _Dither_c1a1fb6b712843498265dcc4192c91f7_Out_2_Float);
surface.Alpha = _Dither_c1a1fb6b712843498265dcc4192c91f7_Out_2_Float;
surface.AlphaClipThreshold = float(0.5);
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
    
        
    
        // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        float3 unnormalizedNormalWS = input.normalWS;
        const float renormFactor = 1.0 / length(unnormalizedNormalWS);
    
    
        output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
    
    
        output.WorldSpaceViewDirection = GetWorldSpaceNormalizeViewDir(input.positionWS);
    
        #if UNITY_UV_STARTS_AT_TOP
        output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
        #else
        output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
        #endif
    
        output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
        output.NDCPosition.y = 1.0f - output.NDCPosition.y;
    
    #if UNITY_ANY_INSTANCING_ENABLED
    #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
    #endif
        output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
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
#define VARYINGS_NEED_POSITION_WS
#define VARYINGS_NEED_NORMAL_WS
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
#define _ALPHATEST_ON 1


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
 float3 positionWS;
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
 float3 WorldSpaceNormal;
 float3 WorldSpaceViewDirection;
 float2 NDCPosition;
 float2 PixelPosition;
 float3 TimeParameters;
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
 float3 positionWS : INTERP0;
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
UNITY_TEXTURE_STREAMING_DEBUG_VARS;
CBUFFER_END


// Object and Global properties

// Graph Includes
#include_with_pragmas "Assets/Materials/Noise/NoiseShader/ImageGenerator (1).hlsl"

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

void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
{
    Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
}

void Unity_OneMinus_float(float In, out float Out)
{
    Out = 1 - In;
}

void Unity_Add_float(float A, float B, out float Out)
{
    Out = A + B;
}

void Unity_Divide_float(float A, float B, out float Out)
{
    Out = A / B;
}

void Unity_RandomRange_float(float2 Seed, float Min, float Max, out float Out)
{
     float randomno =  frac(sin(dot(Seed, float2(12.9898, 78.233)))*43758.5453);
     Out = lerp(Min, Max, randomno);
}

void Unity_Blend_Overlay_float(float Base, float Blend, out float Out, float Opacity)
{
    float result1 = 1.0 - 2.0 * (1.0 - Base) * (1.0 - Blend);
    float result2 = 2.0 * Base * Blend;
    float zeroOrOne = step(Base, 0.5);
    Out = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
    Out = lerp(Base, Out, Opacity);
}

void Unity_Comparison_Greater_float(float A, float B, out float Out)
{
    Out = A > B ? 1 : 0;
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
float Alpha;
float AlphaClipThreshold;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
SurfaceDescription surface = (SurfaceDescription)0;
float _FresnelEffect_6f758b19f2af4fc98b8eea99c7d71bd3_Out_3_Float;
Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, float(0.13), _FresnelEffect_6f758b19f2af4fc98b8eea99c7d71bd3_Out_3_Float);
float _OneMinus_e4b88cf8ea1b4b32bed63c1b104ad30e_Out_1_Float;
Unity_OneMinus_float(_FresnelEffect_6f758b19f2af4fc98b8eea99c7d71bd3_Out_3_Float, _OneMinus_e4b88cf8ea1b4b32bed63c1b104ad30e_Out_1_Float);
float _FresnelEffect_286e15be0c7a494d8806aa2b7128ef23_Out_3_Float;
Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, float(0.66), _FresnelEffect_286e15be0c7a494d8806aa2b7128ef23_Out_3_Float);
float _Add_d36af46da02046ce9560de5498c79671_Out_2_Float;
Unity_Add_float(_FresnelEffect_286e15be0c7a494d8806aa2b7128ef23_Out_3_Float, float(0.24), _Add_d36af46da02046ce9560de5498c79671_Out_2_Float);
float _OneMinus_a0ca3eb5267d4b6c88c142f9ff7e4a1c_Out_1_Float;
Unity_OneMinus_float(_Add_d36af46da02046ce9560de5498c79671_Out_2_Float, _OneMinus_a0ca3eb5267d4b6c88c142f9ff7e4a1c_Out_1_Float);
float _Add_eeaf240474b648fbaf8ef43bac2fcdbf_Out_2_Float;
Unity_Add_float(_OneMinus_e4b88cf8ea1b4b32bed63c1b104ad30e_Out_1_Float, _OneMinus_a0ca3eb5267d4b6c88c142f9ff7e4a1c_Out_1_Float, _Add_eeaf240474b648fbaf8ef43bac2fcdbf_Out_2_Float);
float4 _ScreenPosition_8d9021488038460cb1336474c073db33_Out_0_Vector4 = float4(IN.NDCPosition.xy, 0, 0);
float _Divide_45f6237f772244c8b721940a54c4b3dc_Out_2_Float;
Unity_Divide_float(IN.TimeParameters.x, float(2), _Divide_45f6237f772244c8b721940a54c4b3dc_Out_2_Float);
float _Divide_f6fc0efea14345a58111006e71ea95e2_Out_2_Float;
Unity_Divide_float(IN.TimeParameters.x, float(20), _Divide_f6fc0efea14345a58111006e71ea95e2_Out_2_Float);
float3 _Vector3_11675ccb66fd4f8497756cd68d560179_Out_0_Vector3 = float3(_Divide_45f6237f772244c8b721940a54c4b3dc_Out_2_Float, float(0), _Divide_f6fc0efea14345a58111006e71ea95e2_Out_2_Float);
float _ImageGeneratorMainCustomFunction_077b1daf1f1244bdb3ae7b6af74cc447_Output_1_Float;
ImageGeneratorMain_float((_ScreenPosition_8d9021488038460cb1336474c073db33_Out_0_Vector4.xy), float(4.47), float(8.45), _Vector3_11675ccb66fd4f8497756cd68d560179_Out_0_Vector3, float(0.91), _ImageGeneratorMainCustomFunction_077b1daf1f1244bdb3ae7b6af74cc447_Output_1_Float);
float _RandomRange_e2991f33575e417e93e11c210bd32a75_Out_3_Float;
Unity_RandomRange_float((_ScreenPosition_8d9021488038460cb1336474c073db33_Out_0_Vector4.xy), float(0), float(0.7), _RandomRange_e2991f33575e417e93e11c210bd32a75_Out_3_Float);
float _Blend_254c6fdb71264f03ba503442029a4c83_Out_2_Float;
Unity_Blend_Overlay_float(_ImageGeneratorMainCustomFunction_077b1daf1f1244bdb3ae7b6af74cc447_Output_1_Float, _RandomRange_e2991f33575e417e93e11c210bd32a75_Out_3_Float, _Blend_254c6fdb71264f03ba503442029a4c83_Out_2_Float, float(1));
float _Comparison_73d712f5846b42f88a28d30ca41e8d72_Out_2_Boolean;
Unity_Comparison_Greater_float(_Blend_254c6fdb71264f03ba503442029a4c83_Out_2_Float, float(0.24), _Comparison_73d712f5846b42f88a28d30ca41e8d72_Out_2_Boolean);
float _Blend_f3336b09d4a240c8b7a478c28569698a_Out_2_Float;
Unity_Blend_Overlay_float(_Add_eeaf240474b648fbaf8ef43bac2fcdbf_Out_2_Float, ((float) _Comparison_73d712f5846b42f88a28d30ca41e8d72_Out_2_Boolean), _Blend_f3336b09d4a240c8b7a478c28569698a_Out_2_Float, float(0.83));
float _Multiply_3c5aced32bed437a9ceb9ad0a07f97d6_Out_2_Float;
Unity_Multiply_float_float(_Blend_f3336b09d4a240c8b7a478c28569698a_Out_2_Float, 2, _Multiply_3c5aced32bed437a9ceb9ad0a07f97d6_Out_2_Float);
float _Dither_c1a1fb6b712843498265dcc4192c91f7_Out_2_Float;
Unity_Dither_float(_Multiply_3c5aced32bed437a9ceb9ad0a07f97d6_Out_2_Float, float4(IN.NDCPosition.xy, 0, 0), _Dither_c1a1fb6b712843498265dcc4192c91f7_Out_2_Float);
surface.Alpha = _Dither_c1a1fb6b712843498265dcc4192c91f7_Out_2_Float;
surface.AlphaClipThreshold = float(0.5);
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
    
    
        output.WorldSpaceViewDirection = GetWorldSpaceNormalizeViewDir(input.positionWS);
    
        #if UNITY_UV_STARTS_AT_TOP
        output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
        #else
        output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
        #endif
    
        output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
        output.NDCPosition.y = 1.0f - output.NDCPosition.y;
    
    #if UNITY_ANY_INSTANCING_ENABLED
    #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
    #endif
        output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
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
#define VARYINGS_NEED_POSITION_WS
#define VARYINGS_NEED_NORMAL_WS
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_SHADOWCASTER
#define _ALPHATEST_ON 1


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
 float3 positionWS;
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
 float3 WorldSpaceNormal;
 float3 WorldSpaceViewDirection;
 float2 NDCPosition;
 float2 PixelPosition;
 float3 TimeParameters;
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
 float3 positionWS : INTERP0;
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
UNITY_TEXTURE_STREAMING_DEBUG_VARS;
CBUFFER_END


// Object and Global properties

// Graph Includes
#include_with_pragmas "Assets/Materials/Noise/NoiseShader/ImageGenerator (1).hlsl"

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

void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
{
    Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
}

void Unity_OneMinus_float(float In, out float Out)
{
    Out = 1 - In;
}

void Unity_Add_float(float A, float B, out float Out)
{
    Out = A + B;
}

void Unity_Divide_float(float A, float B, out float Out)
{
    Out = A / B;
}

void Unity_RandomRange_float(float2 Seed, float Min, float Max, out float Out)
{
     float randomno =  frac(sin(dot(Seed, float2(12.9898, 78.233)))*43758.5453);
     Out = lerp(Min, Max, randomno);
}

void Unity_Blend_Overlay_float(float Base, float Blend, out float Out, float Opacity)
{
    float result1 = 1.0 - 2.0 * (1.0 - Base) * (1.0 - Blend);
    float result2 = 2.0 * Base * Blend;
    float zeroOrOne = step(Base, 0.5);
    Out = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
    Out = lerp(Base, Out, Opacity);
}

void Unity_Comparison_Greater_float(float A, float B, out float Out)
{
    Out = A > B ? 1 : 0;
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
float Alpha;
float AlphaClipThreshold;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
SurfaceDescription surface = (SurfaceDescription)0;
float _FresnelEffect_6f758b19f2af4fc98b8eea99c7d71bd3_Out_3_Float;
Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, float(0.13), _FresnelEffect_6f758b19f2af4fc98b8eea99c7d71bd3_Out_3_Float);
float _OneMinus_e4b88cf8ea1b4b32bed63c1b104ad30e_Out_1_Float;
Unity_OneMinus_float(_FresnelEffect_6f758b19f2af4fc98b8eea99c7d71bd3_Out_3_Float, _OneMinus_e4b88cf8ea1b4b32bed63c1b104ad30e_Out_1_Float);
float _FresnelEffect_286e15be0c7a494d8806aa2b7128ef23_Out_3_Float;
Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, float(0.66), _FresnelEffect_286e15be0c7a494d8806aa2b7128ef23_Out_3_Float);
float _Add_d36af46da02046ce9560de5498c79671_Out_2_Float;
Unity_Add_float(_FresnelEffect_286e15be0c7a494d8806aa2b7128ef23_Out_3_Float, float(0.24), _Add_d36af46da02046ce9560de5498c79671_Out_2_Float);
float _OneMinus_a0ca3eb5267d4b6c88c142f9ff7e4a1c_Out_1_Float;
Unity_OneMinus_float(_Add_d36af46da02046ce9560de5498c79671_Out_2_Float, _OneMinus_a0ca3eb5267d4b6c88c142f9ff7e4a1c_Out_1_Float);
float _Add_eeaf240474b648fbaf8ef43bac2fcdbf_Out_2_Float;
Unity_Add_float(_OneMinus_e4b88cf8ea1b4b32bed63c1b104ad30e_Out_1_Float, _OneMinus_a0ca3eb5267d4b6c88c142f9ff7e4a1c_Out_1_Float, _Add_eeaf240474b648fbaf8ef43bac2fcdbf_Out_2_Float);
float4 _ScreenPosition_8d9021488038460cb1336474c073db33_Out_0_Vector4 = float4(IN.NDCPosition.xy, 0, 0);
float _Divide_45f6237f772244c8b721940a54c4b3dc_Out_2_Float;
Unity_Divide_float(IN.TimeParameters.x, float(2), _Divide_45f6237f772244c8b721940a54c4b3dc_Out_2_Float);
float _Divide_f6fc0efea14345a58111006e71ea95e2_Out_2_Float;
Unity_Divide_float(IN.TimeParameters.x, float(20), _Divide_f6fc0efea14345a58111006e71ea95e2_Out_2_Float);
float3 _Vector3_11675ccb66fd4f8497756cd68d560179_Out_0_Vector3 = float3(_Divide_45f6237f772244c8b721940a54c4b3dc_Out_2_Float, float(0), _Divide_f6fc0efea14345a58111006e71ea95e2_Out_2_Float);
float _ImageGeneratorMainCustomFunction_077b1daf1f1244bdb3ae7b6af74cc447_Output_1_Float;
ImageGeneratorMain_float((_ScreenPosition_8d9021488038460cb1336474c073db33_Out_0_Vector4.xy), float(4.47), float(8.45), _Vector3_11675ccb66fd4f8497756cd68d560179_Out_0_Vector3, float(0.91), _ImageGeneratorMainCustomFunction_077b1daf1f1244bdb3ae7b6af74cc447_Output_1_Float);
float _RandomRange_e2991f33575e417e93e11c210bd32a75_Out_3_Float;
Unity_RandomRange_float((_ScreenPosition_8d9021488038460cb1336474c073db33_Out_0_Vector4.xy), float(0), float(0.7), _RandomRange_e2991f33575e417e93e11c210bd32a75_Out_3_Float);
float _Blend_254c6fdb71264f03ba503442029a4c83_Out_2_Float;
Unity_Blend_Overlay_float(_ImageGeneratorMainCustomFunction_077b1daf1f1244bdb3ae7b6af74cc447_Output_1_Float, _RandomRange_e2991f33575e417e93e11c210bd32a75_Out_3_Float, _Blend_254c6fdb71264f03ba503442029a4c83_Out_2_Float, float(1));
float _Comparison_73d712f5846b42f88a28d30ca41e8d72_Out_2_Boolean;
Unity_Comparison_Greater_float(_Blend_254c6fdb71264f03ba503442029a4c83_Out_2_Float, float(0.24), _Comparison_73d712f5846b42f88a28d30ca41e8d72_Out_2_Boolean);
float _Blend_f3336b09d4a240c8b7a478c28569698a_Out_2_Float;
Unity_Blend_Overlay_float(_Add_eeaf240474b648fbaf8ef43bac2fcdbf_Out_2_Float, ((float) _Comparison_73d712f5846b42f88a28d30ca41e8d72_Out_2_Boolean), _Blend_f3336b09d4a240c8b7a478c28569698a_Out_2_Float, float(0.83));
float _Multiply_3c5aced32bed437a9ceb9ad0a07f97d6_Out_2_Float;
Unity_Multiply_float_float(_Blend_f3336b09d4a240c8b7a478c28569698a_Out_2_Float, 2, _Multiply_3c5aced32bed437a9ceb9ad0a07f97d6_Out_2_Float);
float _Dither_c1a1fb6b712843498265dcc4192c91f7_Out_2_Float;
Unity_Dither_float(_Multiply_3c5aced32bed437a9ceb9ad0a07f97d6_Out_2_Float, float4(IN.NDCPosition.xy, 0, 0), _Dither_c1a1fb6b712843498265dcc4192c91f7_Out_2_Float);
surface.Alpha = _Dither_c1a1fb6b712843498265dcc4192c91f7_Out_2_Float;
surface.AlphaClipThreshold = float(0.5);
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
    
    
        output.WorldSpaceViewDirection = GetWorldSpaceNormalizeViewDir(input.positionWS);
    
        #if UNITY_UV_STARTS_AT_TOP
        output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
        #else
        output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
        #endif
    
        output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
        output.NDCPosition.y = 1.0f - output.NDCPosition.y;
    
    #if UNITY_ANY_INSTANCING_ENABLED
    #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
    #endif
        output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
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
#define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
#define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
#define VARYINGS_NEED_POSITION_WS
#define VARYINGS_NEED_NORMAL_WS
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_GBUFFER
#define _ALPHATEST_ON 1


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
#if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
 uint instanceID : INSTANCEID_SEMANTIC;
#endif
};
struct Varyings
{
 float4 positionCS : SV_POSITION;
 float3 positionWS;
 float3 normalWS;
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
 float3 WorldSpaceViewDirection;
 float2 NDCPosition;
 float2 PixelPosition;
 float3 TimeParameters;
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
 float3 positionWS : INTERP2;
 float3 normalWS : INTERP3;
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
UNITY_TEXTURE_STREAMING_DEBUG_VARS;
CBUFFER_END


// Object and Global properties

// Graph Includes
#include_with_pragmas "Assets/Materials/Noise/NoiseShader/ImageGenerator (1).hlsl"

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

void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
{
    Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
}

void Unity_OneMinus_float(float In, out float Out)
{
    Out = 1 - In;
}

void Unity_Add_float(float A, float B, out float Out)
{
    Out = A + B;
}

void Unity_Divide_float(float A, float B, out float Out)
{
    Out = A / B;
}

void Unity_RandomRange_float(float2 Seed, float Min, float Max, out float Out)
{
     float randomno =  frac(sin(dot(Seed, float2(12.9898, 78.233)))*43758.5453);
     Out = lerp(Min, Max, randomno);
}

void Unity_Blend_Overlay_float(float Base, float Blend, out float Out, float Opacity)
{
    float result1 = 1.0 - 2.0 * (1.0 - Base) * (1.0 - Blend);
    float result2 = 2.0 * Base * Blend;
    float zeroOrOne = step(Base, 0.5);
    Out = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
    Out = lerp(Base, Out, Opacity);
}

void Unity_Comparison_Greater_float(float A, float B, out float Out)
{
    Out = A > B ? 1 : 0;
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
float Alpha;
float AlphaClipThreshold;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
SurfaceDescription surface = (SurfaceDescription)0;
float _FresnelEffect_6f758b19f2af4fc98b8eea99c7d71bd3_Out_3_Float;
Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, float(0.13), _FresnelEffect_6f758b19f2af4fc98b8eea99c7d71bd3_Out_3_Float);
float _OneMinus_e4b88cf8ea1b4b32bed63c1b104ad30e_Out_1_Float;
Unity_OneMinus_float(_FresnelEffect_6f758b19f2af4fc98b8eea99c7d71bd3_Out_3_Float, _OneMinus_e4b88cf8ea1b4b32bed63c1b104ad30e_Out_1_Float);
float _FresnelEffect_286e15be0c7a494d8806aa2b7128ef23_Out_3_Float;
Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, float(0.66), _FresnelEffect_286e15be0c7a494d8806aa2b7128ef23_Out_3_Float);
float _Add_d36af46da02046ce9560de5498c79671_Out_2_Float;
Unity_Add_float(_FresnelEffect_286e15be0c7a494d8806aa2b7128ef23_Out_3_Float, float(0.24), _Add_d36af46da02046ce9560de5498c79671_Out_2_Float);
float _OneMinus_a0ca3eb5267d4b6c88c142f9ff7e4a1c_Out_1_Float;
Unity_OneMinus_float(_Add_d36af46da02046ce9560de5498c79671_Out_2_Float, _OneMinus_a0ca3eb5267d4b6c88c142f9ff7e4a1c_Out_1_Float);
float _Add_eeaf240474b648fbaf8ef43bac2fcdbf_Out_2_Float;
Unity_Add_float(_OneMinus_e4b88cf8ea1b4b32bed63c1b104ad30e_Out_1_Float, _OneMinus_a0ca3eb5267d4b6c88c142f9ff7e4a1c_Out_1_Float, _Add_eeaf240474b648fbaf8ef43bac2fcdbf_Out_2_Float);
float4 _ScreenPosition_8d9021488038460cb1336474c073db33_Out_0_Vector4 = float4(IN.NDCPosition.xy, 0, 0);
float _Divide_45f6237f772244c8b721940a54c4b3dc_Out_2_Float;
Unity_Divide_float(IN.TimeParameters.x, float(2), _Divide_45f6237f772244c8b721940a54c4b3dc_Out_2_Float);
float _Divide_f6fc0efea14345a58111006e71ea95e2_Out_2_Float;
Unity_Divide_float(IN.TimeParameters.x, float(20), _Divide_f6fc0efea14345a58111006e71ea95e2_Out_2_Float);
float3 _Vector3_11675ccb66fd4f8497756cd68d560179_Out_0_Vector3 = float3(_Divide_45f6237f772244c8b721940a54c4b3dc_Out_2_Float, float(0), _Divide_f6fc0efea14345a58111006e71ea95e2_Out_2_Float);
float _ImageGeneratorMainCustomFunction_077b1daf1f1244bdb3ae7b6af74cc447_Output_1_Float;
ImageGeneratorMain_float((_ScreenPosition_8d9021488038460cb1336474c073db33_Out_0_Vector4.xy), float(4.47), float(8.45), _Vector3_11675ccb66fd4f8497756cd68d560179_Out_0_Vector3, float(0.91), _ImageGeneratorMainCustomFunction_077b1daf1f1244bdb3ae7b6af74cc447_Output_1_Float);
float _RandomRange_e2991f33575e417e93e11c210bd32a75_Out_3_Float;
Unity_RandomRange_float((_ScreenPosition_8d9021488038460cb1336474c073db33_Out_0_Vector4.xy), float(0), float(0.7), _RandomRange_e2991f33575e417e93e11c210bd32a75_Out_3_Float);
float _Blend_254c6fdb71264f03ba503442029a4c83_Out_2_Float;
Unity_Blend_Overlay_float(_ImageGeneratorMainCustomFunction_077b1daf1f1244bdb3ae7b6af74cc447_Output_1_Float, _RandomRange_e2991f33575e417e93e11c210bd32a75_Out_3_Float, _Blend_254c6fdb71264f03ba503442029a4c83_Out_2_Float, float(1));
float _Comparison_73d712f5846b42f88a28d30ca41e8d72_Out_2_Boolean;
Unity_Comparison_Greater_float(_Blend_254c6fdb71264f03ba503442029a4c83_Out_2_Float, float(0.24), _Comparison_73d712f5846b42f88a28d30ca41e8d72_Out_2_Boolean);
float _Blend_f3336b09d4a240c8b7a478c28569698a_Out_2_Float;
Unity_Blend_Overlay_float(_Add_eeaf240474b648fbaf8ef43bac2fcdbf_Out_2_Float, ((float) _Comparison_73d712f5846b42f88a28d30ca41e8d72_Out_2_Boolean), _Blend_f3336b09d4a240c8b7a478c28569698a_Out_2_Float, float(0.83));
float _Multiply_3c5aced32bed437a9ceb9ad0a07f97d6_Out_2_Float;
Unity_Multiply_float_float(_Blend_f3336b09d4a240c8b7a478c28569698a_Out_2_Float, 2, _Multiply_3c5aced32bed437a9ceb9ad0a07f97d6_Out_2_Float);
float _Dither_c1a1fb6b712843498265dcc4192c91f7_Out_2_Float;
Unity_Dither_float(_Multiply_3c5aced32bed437a9ceb9ad0a07f97d6_Out_2_Float, float4(IN.NDCPosition.xy, 0, 0), _Dither_c1a1fb6b712843498265dcc4192c91f7_Out_2_Float);
surface.BaseColor = IsGammaSpace() ? float3(1, 1, 1) : SRGBToLinear(float3(1, 1, 1));
surface.Alpha = _Dither_c1a1fb6b712843498265dcc4192c91f7_Out_2_Float;
surface.AlphaClipThreshold = float(0.5);
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
    
    
        output.WorldSpaceViewDirection = GetWorldSpaceNormalizeViewDir(input.positionWS);
    
        #if UNITY_UV_STARTS_AT_TOP
        output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
        #else
        output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
        #endif
    
        output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
        output.NDCPosition.y = 1.0f - output.NDCPosition.y;
    
    #if UNITY_ANY_INSTANCING_ENABLED
    #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
    #endif
        output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
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
#define VARYINGS_NEED_POSITION_WS
#define VARYINGS_NEED_NORMAL_WS
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_DEPTHONLY
#define SCENESELECTIONPASS 1
#define ALPHA_CLIP_THRESHOLD 1
#define _ALPHATEST_ON 1


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
 float3 positionWS;
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
 float3 WorldSpaceNormal;
 float3 WorldSpaceViewDirection;
 float2 NDCPosition;
 float2 PixelPosition;
 float3 TimeParameters;
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
 float3 positionWS : INTERP0;
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
UNITY_TEXTURE_STREAMING_DEBUG_VARS;
CBUFFER_END


// Object and Global properties

// Graph Includes
#include_with_pragmas "Assets/Materials/Noise/NoiseShader/ImageGenerator (1).hlsl"

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

void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
{
    Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
}

void Unity_OneMinus_float(float In, out float Out)
{
    Out = 1 - In;
}

void Unity_Add_float(float A, float B, out float Out)
{
    Out = A + B;
}

void Unity_Divide_float(float A, float B, out float Out)
{
    Out = A / B;
}

void Unity_RandomRange_float(float2 Seed, float Min, float Max, out float Out)
{
     float randomno =  frac(sin(dot(Seed, float2(12.9898, 78.233)))*43758.5453);
     Out = lerp(Min, Max, randomno);
}

void Unity_Blend_Overlay_float(float Base, float Blend, out float Out, float Opacity)
{
    float result1 = 1.0 - 2.0 * (1.0 - Base) * (1.0 - Blend);
    float result2 = 2.0 * Base * Blend;
    float zeroOrOne = step(Base, 0.5);
    Out = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
    Out = lerp(Base, Out, Opacity);
}

void Unity_Comparison_Greater_float(float A, float B, out float Out)
{
    Out = A > B ? 1 : 0;
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
float Alpha;
float AlphaClipThreshold;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
SurfaceDescription surface = (SurfaceDescription)0;
float _FresnelEffect_6f758b19f2af4fc98b8eea99c7d71bd3_Out_3_Float;
Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, float(0.13), _FresnelEffect_6f758b19f2af4fc98b8eea99c7d71bd3_Out_3_Float);
float _OneMinus_e4b88cf8ea1b4b32bed63c1b104ad30e_Out_1_Float;
Unity_OneMinus_float(_FresnelEffect_6f758b19f2af4fc98b8eea99c7d71bd3_Out_3_Float, _OneMinus_e4b88cf8ea1b4b32bed63c1b104ad30e_Out_1_Float);
float _FresnelEffect_286e15be0c7a494d8806aa2b7128ef23_Out_3_Float;
Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, float(0.66), _FresnelEffect_286e15be0c7a494d8806aa2b7128ef23_Out_3_Float);
float _Add_d36af46da02046ce9560de5498c79671_Out_2_Float;
Unity_Add_float(_FresnelEffect_286e15be0c7a494d8806aa2b7128ef23_Out_3_Float, float(0.24), _Add_d36af46da02046ce9560de5498c79671_Out_2_Float);
float _OneMinus_a0ca3eb5267d4b6c88c142f9ff7e4a1c_Out_1_Float;
Unity_OneMinus_float(_Add_d36af46da02046ce9560de5498c79671_Out_2_Float, _OneMinus_a0ca3eb5267d4b6c88c142f9ff7e4a1c_Out_1_Float);
float _Add_eeaf240474b648fbaf8ef43bac2fcdbf_Out_2_Float;
Unity_Add_float(_OneMinus_e4b88cf8ea1b4b32bed63c1b104ad30e_Out_1_Float, _OneMinus_a0ca3eb5267d4b6c88c142f9ff7e4a1c_Out_1_Float, _Add_eeaf240474b648fbaf8ef43bac2fcdbf_Out_2_Float);
float4 _ScreenPosition_8d9021488038460cb1336474c073db33_Out_0_Vector4 = float4(IN.NDCPosition.xy, 0, 0);
float _Divide_45f6237f772244c8b721940a54c4b3dc_Out_2_Float;
Unity_Divide_float(IN.TimeParameters.x, float(2), _Divide_45f6237f772244c8b721940a54c4b3dc_Out_2_Float);
float _Divide_f6fc0efea14345a58111006e71ea95e2_Out_2_Float;
Unity_Divide_float(IN.TimeParameters.x, float(20), _Divide_f6fc0efea14345a58111006e71ea95e2_Out_2_Float);
float3 _Vector3_11675ccb66fd4f8497756cd68d560179_Out_0_Vector3 = float3(_Divide_45f6237f772244c8b721940a54c4b3dc_Out_2_Float, float(0), _Divide_f6fc0efea14345a58111006e71ea95e2_Out_2_Float);
float _ImageGeneratorMainCustomFunction_077b1daf1f1244bdb3ae7b6af74cc447_Output_1_Float;
ImageGeneratorMain_float((_ScreenPosition_8d9021488038460cb1336474c073db33_Out_0_Vector4.xy), float(4.47), float(8.45), _Vector3_11675ccb66fd4f8497756cd68d560179_Out_0_Vector3, float(0.91), _ImageGeneratorMainCustomFunction_077b1daf1f1244bdb3ae7b6af74cc447_Output_1_Float);
float _RandomRange_e2991f33575e417e93e11c210bd32a75_Out_3_Float;
Unity_RandomRange_float((_ScreenPosition_8d9021488038460cb1336474c073db33_Out_0_Vector4.xy), float(0), float(0.7), _RandomRange_e2991f33575e417e93e11c210bd32a75_Out_3_Float);
float _Blend_254c6fdb71264f03ba503442029a4c83_Out_2_Float;
Unity_Blend_Overlay_float(_ImageGeneratorMainCustomFunction_077b1daf1f1244bdb3ae7b6af74cc447_Output_1_Float, _RandomRange_e2991f33575e417e93e11c210bd32a75_Out_3_Float, _Blend_254c6fdb71264f03ba503442029a4c83_Out_2_Float, float(1));
float _Comparison_73d712f5846b42f88a28d30ca41e8d72_Out_2_Boolean;
Unity_Comparison_Greater_float(_Blend_254c6fdb71264f03ba503442029a4c83_Out_2_Float, float(0.24), _Comparison_73d712f5846b42f88a28d30ca41e8d72_Out_2_Boolean);
float _Blend_f3336b09d4a240c8b7a478c28569698a_Out_2_Float;
Unity_Blend_Overlay_float(_Add_eeaf240474b648fbaf8ef43bac2fcdbf_Out_2_Float, ((float) _Comparison_73d712f5846b42f88a28d30ca41e8d72_Out_2_Boolean), _Blend_f3336b09d4a240c8b7a478c28569698a_Out_2_Float, float(0.83));
float _Multiply_3c5aced32bed437a9ceb9ad0a07f97d6_Out_2_Float;
Unity_Multiply_float_float(_Blend_f3336b09d4a240c8b7a478c28569698a_Out_2_Float, 2, _Multiply_3c5aced32bed437a9ceb9ad0a07f97d6_Out_2_Float);
float _Dither_c1a1fb6b712843498265dcc4192c91f7_Out_2_Float;
Unity_Dither_float(_Multiply_3c5aced32bed437a9ceb9ad0a07f97d6_Out_2_Float, float4(IN.NDCPosition.xy, 0, 0), _Dither_c1a1fb6b712843498265dcc4192c91f7_Out_2_Float);
surface.Alpha = _Dither_c1a1fb6b712843498265dcc4192c91f7_Out_2_Float;
surface.AlphaClipThreshold = float(0.5);
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
    
    
        output.WorldSpaceViewDirection = GetWorldSpaceNormalizeViewDir(input.positionWS);
    
        #if UNITY_UV_STARTS_AT_TOP
        output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
        #else
        output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
        #endif
    
        output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
        output.NDCPosition.y = 1.0f - output.NDCPosition.y;
    
    #if UNITY_ANY_INSTANCING_ENABLED
    #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
    #endif
        output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
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
#define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
#define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
#define VARYINGS_NEED_POSITION_WS
#define VARYINGS_NEED_NORMAL_WS
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_DEPTHONLY
#define SCENEPICKINGPASS 1
#define ALPHA_CLIP_THRESHOLD 1
#define _ALPHATEST_ON 1


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
 float3 positionWS;
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
 float3 WorldSpaceNormal;
 float3 WorldSpaceViewDirection;
 float2 NDCPosition;
 float2 PixelPosition;
 float3 TimeParameters;
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
 float3 positionWS : INTERP0;
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
UNITY_TEXTURE_STREAMING_DEBUG_VARS;
CBUFFER_END


// Object and Global properties

// Graph Includes
#include_with_pragmas "Assets/Materials/Noise/NoiseShader/ImageGenerator (1).hlsl"

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

void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
{
    Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
}

void Unity_OneMinus_float(float In, out float Out)
{
    Out = 1 - In;
}

void Unity_Add_float(float A, float B, out float Out)
{
    Out = A + B;
}

void Unity_Divide_float(float A, float B, out float Out)
{
    Out = A / B;
}

void Unity_RandomRange_float(float2 Seed, float Min, float Max, out float Out)
{
     float randomno =  frac(sin(dot(Seed, float2(12.9898, 78.233)))*43758.5453);
     Out = lerp(Min, Max, randomno);
}

void Unity_Blend_Overlay_float(float Base, float Blend, out float Out, float Opacity)
{
    float result1 = 1.0 - 2.0 * (1.0 - Base) * (1.0 - Blend);
    float result2 = 2.0 * Base * Blend;
    float zeroOrOne = step(Base, 0.5);
    Out = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
    Out = lerp(Base, Out, Opacity);
}

void Unity_Comparison_Greater_float(float A, float B, out float Out)
{
    Out = A > B ? 1 : 0;
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
float Alpha;
float AlphaClipThreshold;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
SurfaceDescription surface = (SurfaceDescription)0;
float _FresnelEffect_6f758b19f2af4fc98b8eea99c7d71bd3_Out_3_Float;
Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, float(0.13), _FresnelEffect_6f758b19f2af4fc98b8eea99c7d71bd3_Out_3_Float);
float _OneMinus_e4b88cf8ea1b4b32bed63c1b104ad30e_Out_1_Float;
Unity_OneMinus_float(_FresnelEffect_6f758b19f2af4fc98b8eea99c7d71bd3_Out_3_Float, _OneMinus_e4b88cf8ea1b4b32bed63c1b104ad30e_Out_1_Float);
float _FresnelEffect_286e15be0c7a494d8806aa2b7128ef23_Out_3_Float;
Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, float(0.66), _FresnelEffect_286e15be0c7a494d8806aa2b7128ef23_Out_3_Float);
float _Add_d36af46da02046ce9560de5498c79671_Out_2_Float;
Unity_Add_float(_FresnelEffect_286e15be0c7a494d8806aa2b7128ef23_Out_3_Float, float(0.24), _Add_d36af46da02046ce9560de5498c79671_Out_2_Float);
float _OneMinus_a0ca3eb5267d4b6c88c142f9ff7e4a1c_Out_1_Float;
Unity_OneMinus_float(_Add_d36af46da02046ce9560de5498c79671_Out_2_Float, _OneMinus_a0ca3eb5267d4b6c88c142f9ff7e4a1c_Out_1_Float);
float _Add_eeaf240474b648fbaf8ef43bac2fcdbf_Out_2_Float;
Unity_Add_float(_OneMinus_e4b88cf8ea1b4b32bed63c1b104ad30e_Out_1_Float, _OneMinus_a0ca3eb5267d4b6c88c142f9ff7e4a1c_Out_1_Float, _Add_eeaf240474b648fbaf8ef43bac2fcdbf_Out_2_Float);
float4 _ScreenPosition_8d9021488038460cb1336474c073db33_Out_0_Vector4 = float4(IN.NDCPosition.xy, 0, 0);
float _Divide_45f6237f772244c8b721940a54c4b3dc_Out_2_Float;
Unity_Divide_float(IN.TimeParameters.x, float(2), _Divide_45f6237f772244c8b721940a54c4b3dc_Out_2_Float);
float _Divide_f6fc0efea14345a58111006e71ea95e2_Out_2_Float;
Unity_Divide_float(IN.TimeParameters.x, float(20), _Divide_f6fc0efea14345a58111006e71ea95e2_Out_2_Float);
float3 _Vector3_11675ccb66fd4f8497756cd68d560179_Out_0_Vector3 = float3(_Divide_45f6237f772244c8b721940a54c4b3dc_Out_2_Float, float(0), _Divide_f6fc0efea14345a58111006e71ea95e2_Out_2_Float);
float _ImageGeneratorMainCustomFunction_077b1daf1f1244bdb3ae7b6af74cc447_Output_1_Float;
ImageGeneratorMain_float((_ScreenPosition_8d9021488038460cb1336474c073db33_Out_0_Vector4.xy), float(4.47), float(8.45), _Vector3_11675ccb66fd4f8497756cd68d560179_Out_0_Vector3, float(0.91), _ImageGeneratorMainCustomFunction_077b1daf1f1244bdb3ae7b6af74cc447_Output_1_Float);
float _RandomRange_e2991f33575e417e93e11c210bd32a75_Out_3_Float;
Unity_RandomRange_float((_ScreenPosition_8d9021488038460cb1336474c073db33_Out_0_Vector4.xy), float(0), float(0.7), _RandomRange_e2991f33575e417e93e11c210bd32a75_Out_3_Float);
float _Blend_254c6fdb71264f03ba503442029a4c83_Out_2_Float;
Unity_Blend_Overlay_float(_ImageGeneratorMainCustomFunction_077b1daf1f1244bdb3ae7b6af74cc447_Output_1_Float, _RandomRange_e2991f33575e417e93e11c210bd32a75_Out_3_Float, _Blend_254c6fdb71264f03ba503442029a4c83_Out_2_Float, float(1));
float _Comparison_73d712f5846b42f88a28d30ca41e8d72_Out_2_Boolean;
Unity_Comparison_Greater_float(_Blend_254c6fdb71264f03ba503442029a4c83_Out_2_Float, float(0.24), _Comparison_73d712f5846b42f88a28d30ca41e8d72_Out_2_Boolean);
float _Blend_f3336b09d4a240c8b7a478c28569698a_Out_2_Float;
Unity_Blend_Overlay_float(_Add_eeaf240474b648fbaf8ef43bac2fcdbf_Out_2_Float, ((float) _Comparison_73d712f5846b42f88a28d30ca41e8d72_Out_2_Boolean), _Blend_f3336b09d4a240c8b7a478c28569698a_Out_2_Float, float(0.83));
float _Multiply_3c5aced32bed437a9ceb9ad0a07f97d6_Out_2_Float;
Unity_Multiply_float_float(_Blend_f3336b09d4a240c8b7a478c28569698a_Out_2_Float, 2, _Multiply_3c5aced32bed437a9ceb9ad0a07f97d6_Out_2_Float);
float _Dither_c1a1fb6b712843498265dcc4192c91f7_Out_2_Float;
Unity_Dither_float(_Multiply_3c5aced32bed437a9ceb9ad0a07f97d6_Out_2_Float, float4(IN.NDCPosition.xy, 0, 0), _Dither_c1a1fb6b712843498265dcc4192c91f7_Out_2_Float);
surface.BaseColor = IsGammaSpace() ? float3(1, 1, 1) : SRGBToLinear(float3(1, 1, 1));
surface.Alpha = _Dither_c1a1fb6b712843498265dcc4192c91f7_Out_2_Float;
surface.AlphaClipThreshold = float(0.5);
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
    
    
        output.WorldSpaceViewDirection = GetWorldSpaceNormalizeViewDir(input.positionWS);
    
        #if UNITY_UV_STARTS_AT_TOP
        output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
        #else
        output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
        #endif
    
        output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
        output.NDCPosition.y = 1.0f - output.NDCPosition.y;
    
    #if UNITY_ANY_INSTANCING_ENABLED
    #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
    #endif
        output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
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