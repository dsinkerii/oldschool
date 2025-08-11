using UnityEngine;
using TMPro;

public class AwesomeText : MonoBehaviour{
    public string referenceText;
    public bool interpolateText = false;
    public float glitchSpeed = 0.1f;
    public float typeSpeed = 0.1f;
    public float removeSpeed = 0.05f;
    
    [SerializeField] TextMeshProUGUI textComponent;
    private string currentDisplayText = "";
    private float typeTimer = 0f;
    private float removeTimer = 0f;
    private float glitchTimer = 0f;
    private int currentCharIndex = 0;
    private readonly string glitchChars = "!@#$%^&*()_+-=[]{}|;:,.<>?";
    
    public static float Linear(float from, float to, float x) 
        {return from + (to - from) * x;}    
    public static float EaseInOutCubic(float from, float to, float x) 
        {return Linear(from, to, x < 0.5f ? 4 * x * x * x : 1 - Mathf.Pow(-2 * x + 2, 3) / 2);}
    void FixedUpdate(){
        if (textComponent == null) return;
        
        if (interpolateText){
            typeTimer += Time.fixedDeltaTime;
            glitchTimer += Time.fixedDeltaTime;
            
            if (typeTimer >= typeSpeed && currentCharIndex < referenceText.Length){
                currentCharIndex++;
                int EaseCharIdx = (int)EaseInOutCubic(0, referenceText.Length+1,currentCharIndex*1f/referenceText.Length);
                EaseCharIdx = Mathf.Clamp(EaseCharIdx, 0, referenceText.Length-1);
                currentDisplayText = referenceText[..EaseCharIdx];
                typeTimer = 0f;
            }
            if (currentCharIndex >= referenceText.Length && glitchTimer >= glitchSpeed){
                ApplyGlitchEffect();
                glitchTimer=0;
            }
        }
        else{
            removeTimer += Time.fixedDeltaTime;
            
            if (removeTimer >= removeSpeed && currentCharIndex > 0){
                currentCharIndex--;
                int EaseCharIdx = (int)EaseInOutCubic(0, referenceText.Length+1,currentCharIndex*1f/referenceText.Length);
                EaseCharIdx = Mathf.Clamp(EaseCharIdx, 0, referenceText.Length-1);
                currentDisplayText = referenceText[..EaseCharIdx];
                removeTimer = 0f;
            }
        }
        
        textComponent.text = $"<mspace={textComponent.fontSize}>{currentDisplayText}</mspace>";
    }
    
    void ApplyGlitchEffect() {
        currentDisplayText = referenceText;
        
        char[] textArray = currentDisplayText.ToCharArray();
        
        textArray[Random.Range(0, currentDisplayText.Length)] = glitchChars[Random.Range(0, glitchChars.Length)];
        
        currentDisplayText = new string(textArray);
    }
}
