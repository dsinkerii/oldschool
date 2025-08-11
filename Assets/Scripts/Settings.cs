using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.Audio;
using UnityEngine.InputSystem;
using UnityEngine.UI;

public class Settings : MonoBehaviour{
    public Slider volumeSlider;
    public List<KeybindHelper> keybinds;
    public MainMenu menuManager;
    private InputAction currentAction;
    public AudioMixer Master;
    private int currentIndex;
    public RectTransform Root;
    public void UpdateUI(){

        for (int i = 0; i < keybinds.Count; i++){
            StartCoroutine(Refresh(i));
        }
    }
    void Start(){
        volumeSlider.value = PlayerPrefs.GetFloat("volume", -30);
        Master.SetFloat("vol",volumeSlider.value);
        
        for (int i = 0; i < keybinds.Count; i++){
            keybinds[i].action.Enable();
            int index = i;
            keybinds[i].button.onClick.AddListener(() => StartRebind(index));
            
            // Add this validation:
            string savedPath = PlayerPrefs.GetString(keybinds[i].action.name, "");
            if (!string.IsNullOrEmpty(savedPath) && IsValidBindingPath(savedPath)){
                try {
                    keybinds[i].action.ApplyBindingOverride(keybinds[i].bindingIndex, savedPath);
                }
                catch (System.Exception e) {
                    Debug.Log($"failed to apply binding override for {keybinds[i].action.name}: {e.Message}");
                }
            }
            
            StartCoroutine(Refresh(i));
        }
        UpdateAllTexts();
    }

    bool IsValidBindingPath(string path) {
        return !string.IsNullOrEmpty(path) && 
            !path.Contains("[") && 
            !path.Contains(";");
    }
    
    void StartRebind(int index){
        if (currentAction != null) return;
        
        currentAction = keybinds[index].action;
        currentIndex = index;
        keybinds[index].text.text = "_press...";
        
        currentAction.Disable();
        currentAction.PerformInteractiveRebinding(keybinds[index].bindingIndex)
            .WithControlsExcluding("Mouse")
            .WithControlsExcluding("Gamepad")
            .OnComplete((rO) => FinishRebind(rO))
            .OnCancel(_ => CancelRebind())
            .WithTimeout(3)
            .Start();
    }
    IEnumerator Refresh(int idx){
        yield return new WaitForEndOfFrame();
        LayoutRebuilder.ForceRebuildLayoutImmediate(Root);
        var layout = keybinds[idx].text.transform.parent.gameObject.GetComponent<VerticalLayoutGroup>();
        LayoutRebuilder.ForceRebuildLayoutImmediate(layout.GetComponent<RectTransform>());
        LayoutRebuilder.ForceRebuildLayoutImmediate(layout.GetComponent<RectTransform>());
        layout.CalculateLayoutInputVertical();
        Canvas.ForceUpdateCanvases();
    }
    string GetName(InputAction action, int idx){
        string val = action.GetBindingDisplayString(idx,InputBinding.DisplayStringOptions.DontUseShortDisplayNames);
        if(val.Length == 0) return "Enter";
        if(val.Length <= 1){
            val = val.Replace(" ", "space").Replace("\n", "enter").Replace("□","?");
        }
        return val;
    }
    void FinishRebind(InputActionRebindingExtensions.RebindingOperation rO){
        if(rO.selectedControl != null){
            string cleanPath = rO.selectedControl.path;
            keybinds[currentIndex].action.ApplyBindingOverride(keybinds[currentIndex].bindingIndex, cleanPath);
            PlayerPrefs.SetString(keybinds[currentIndex].action.name, cleanPath);
            PlayerPrefs.Save();
        }
        
        currentAction.Enable();
        keybinds[currentIndex].text.text = GetName(currentAction,keybinds[currentIndex].bindingIndex);
        StartCoroutine(Refresh(currentIndex));
        currentAction = null;
    }
    
    void CancelRebind(){
        currentAction.Enable();
        keybinds[currentIndex].text.text = GetName(currentAction,keybinds[currentIndex].bindingIndex);
        StartCoroutine(Refresh(currentIndex));
        currentAction = null;
    }
    
    void UpdateAllTexts(){
        for (int i = 0; i < keybinds.Count; i++){
            string displayText = GetName(keybinds[i].action,keybinds[i].bindingIndex);
            keybinds[i].text.text = displayText ?? "none.";
            StartCoroutine(Refresh(i));
        }

    }
    public void SetVolume(){
        Master.SetFloat("vol",volumeSlider.value);
    }
    public void ResetKeys() {
        for (int i = 0; i < keybinds.Count; i++) {
            keybinds[i].action.RemoveAllBindingOverrides();
            PlayerPrefs.DeleteKey(keybinds[i].action.name);
        }
        UpdateAllTexts();
    }
    public void BackToMenu() => menuManager.ShowMainMenu();
}
