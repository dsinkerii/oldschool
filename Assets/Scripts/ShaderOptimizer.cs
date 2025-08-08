
using UnityEngine;
using TMPro;

public class ShaderOptimizer : MonoBehaviour
{
    [SerializeField] bool autoDetectPerformance = true;
    [SerializeField] int forcePerformanceLevel = -1;
    [SerializeField] bool enableEditorTesting = true;
    [SerializeField] PerformanceLevel testLevel = PerformanceLevel.High;
    [SerializeField] int potatoMemoryThreshold = 1000;
    [SerializeField] int mediumMemoryThreshold = 3000;
    [SerializeField] TextMeshProUGUI debugdata;
    [SerializeField] Camera renderCam;
    public enum PerformanceLevel
    {
        Potato = 0,
        Medium = 1,
        High = 2
    }
    
    private PerformanceLevel currentLevel;
    
    void Start(){
        OptimizeShaders();
        if(Debug.isDebugBuild){
            debugdata.text = "";
        }else{
            debugdata.transform.parent.gameObject.SetActive(false); // disable
        }
    }
    
    void Update()
    {
        if (enableEditorTesting && Application.isEditor){
            if (testLevel != currentLevel){
                currentLevel = testLevel;
                OptimizeShaders();
            }
        }
        if(Debug.isDebugBuild){
            debugdata.text = $"fps: {(int)(1f / Time.unscaledDeltaTime)}\n"+
            $"level: {currentLevel}\n"+
            $"allocated v-ram: {SystemInfo.graphicsMemorySize}\n"+
            $"processor frequency: {SystemInfo.processorFrequency}\n"+
            $"ram: {SystemInfo.systemMemorySize}\n"+
            $"true health: {ValueManager.Instance.HP}";
        }
    }
    
    void OptimizeShaders()
    {
        currentLevel = DeterminePerformanceLevel();
        switch (currentLevel)
        {
            case PerformanceLevel.Potato:
                ApplyPotatoOptimizations();
                break;
            case PerformanceLevel.Medium:
                ApplyMediumOptimizations();
                break;
            case PerformanceLevel.High:
                ApplyHighOptimizations();
                break;
        }
        SetQualityLevel();
    }
    
    PerformanceLevel DeterminePerformanceLevel()
    {
        if (forcePerformanceLevel >= 0)
            return (PerformanceLevel)forcePerformanceLevel;
        
        if (!autoDetectPerformance)
            return PerformanceLevel.High;
        
        int memoryMB = SystemInfo.graphicsMemorySize;
        bool isMobile = Application.isMobilePlatform;
        bool isLowEnd = SystemInfo.processorFrequency < 2000;
        
        if (isMobile || memoryMB < potatoMemoryThreshold || isLowEnd)
            return PerformanceLevel.Potato;
        
        if (memoryMB < mediumMemoryThreshold)
            return PerformanceLevel.Medium;
        
        return PerformanceLevel.High;
    }
    
    void ApplyPotatoOptimizations()
    {
        Shader.globalMaximumLOD = 100; 
        
        Shader.SetGlobalFloat("_DisableNormalMaps", 1.0f);
        Shader.SetGlobalFloat("_DisableReflections", 1.0f);
        Shader.SetGlobalFloat("_SimpleLighting", 1.0f);
        
        QualitySettings.globalTextureMipmapLimit = 2;
    }
    
    void ApplyMediumOptimizations()
    {
        Shader.globalMaximumLOD = 200;
        
        Shader.SetGlobalFloat("_DisableNormalMaps", 0.0f);
        Shader.SetGlobalFloat("_DisableReflections", 0.5f);
        Shader.SetGlobalFloat("_SimpleLighting", 0.0f);
        
        QualitySettings.globalTextureMipmapLimit = 1;
    }
    
    void ApplyHighOptimizations()
    {
        Shader.globalMaximumLOD = 600;
        Shader.SetGlobalFloat("_DisableNormalMaps", 0.0f);
        Shader.SetGlobalFloat("_DisableReflections", 0.0f);
        Shader.SetGlobalFloat("_SimpleLighting", 0.0f);
        QualitySettings.globalTextureMipmapLimit = 0;
    }
    
    void SetQualityLevel()
    {
        //QualitySettings.SetQualityLevel((int)currentLevel);
        
        switch (currentLevel)
        {
            case PerformanceLevel.Potato:
                QualitySettings.shadows = ShadowQuality.Disable;
                QualitySettings.shadowResolution = ShadowResolution.Low;
                QualitySettings.shadowDistance = 20f;
                QualitySettings.pixelLightCount = 1;
                break;
                
            case PerformanceLevel.Medium:
                QualitySettings.shadows = ShadowQuality.HardOnly;
                QualitySettings.shadowResolution = ShadowResolution.Medium;
                QualitySettings.shadowDistance = 50f;
                QualitySettings.pixelLightCount = 2;
                break;
                
            case PerformanceLevel.High:
                QualitySettings.shadows = ShadowQuality.All;
                QualitySettings.shadowResolution = ShadowResolution.VeryHigh;
                QualitySettings.shadowDistance = 100f;
                QualitySettings.pixelLightCount = 4;
                break;
        }
    }
}
