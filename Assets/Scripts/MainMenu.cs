using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public class MainMenu : MonoBehaviour
{
    [Header("Menu Panels")]
    public GameObject mainMenuPanel;
    public GameObject settingsPanel;
    public GameObject creditsPanel;
    
    [Header("Fade Settings")]
    public Image fadeImage; 
    public float fadeSpeed = 1f;
    
    void Start(){
        ShowMainMenu();
    }
    
    public void PlayGame(){
        StartCoroutine(FadeAndLoadScene());
    }
    
    public void OpenSettings(){
        mainMenuPanel.SetActive(false);
        settingsPanel.SetActive(true);
        gameObject.GetComponent<Settings>().UpdateUI();
    }
    
    public void OpenCredits(){
        mainMenuPanel.SetActive(false);
        creditsPanel.SetActive(true);
    }
    
    public void ShowMainMenu(){
        mainMenuPanel.SetActive(true);
        settingsPanel.SetActive(false);
        creditsPanel.SetActive(false);
    }
    
    // FADE AND LOAD
    private System.Collections.IEnumerator FadeAndLoadScene(){
        Color fadeColor = fadeImage.color;
        float startTime = Time.time;
        
        while (fadeColor.a < 1f){
            fadeColor.a = (Time.time - startTime)*fadeSpeed;
            fadeImage.color = fadeColor;
            yield return null;
        }
        
        SceneManager.LoadScene("SampleScene");
    }

    [SerializeField] List<Image> covers;
    [SerializeField] List<TextMeshProUGUI> texts;
    // set button active/inactive
    public void SetButtonActive(int idx){
        for(int i = 0; i < covers.Count; i++){
            covers[i].color = Color.black;
            texts[i].color = Color.white;
        }
        //invert
        covers[idx].color = Color.white;
        texts[idx].color = Color.black;
    }
    public void SetButtonInactive(int idx){
        covers[idx].color = Color.black;
        texts[idx].color = Color.white;
    }
    public void OpenLink(string link){
        Application.OpenURL(link);
    }
}
