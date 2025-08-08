Shader "Stencil/Invisible Mask"
{
    Properties {}
    SubShader
    {
        Tags {}      
        
        Pass
        {
            ColorMask 0 // We do not want our mask to be visible
            ZWrite Off // We do not want to write to the depth buffer
            
            Stencil
            {
                Ref 1
                Comp always // always pass
                Pass Replace                 
            }
        }
    }
}
//https://medium.com/@brunolorenz98/unity-3d-shaders-using-stencil-buffers-to-hide-and-reveal-6a80ccf559bf