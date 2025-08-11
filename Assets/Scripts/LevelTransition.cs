using System.Collections;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.SceneManagement;
using UnityEngine.UI;
public class LevelTransition : MonoBehaviour
{
    public static LevelTransition Instance;
    public AwesomeText KillToContinue;
    public AwesomeText DeadToContinue;
    InputAction Back;
    InputAction attackAction;
    void Start() {
        Instance = this;
        StartCoroutine(FadeIn());

        Back = InputSystem.actions.FindAction("Previous");
        attackAction = InputSystem.actions.FindAction("Attack");
    }
    
    public Image TransImage;
    public bool IsTransitioning;
    [ContextMenu("run")]
    public void TransitionLevel(){
        if(IsTransitioning) return;
        if(GameManager.Instance.AIsKilled == 0 && GameManager.Instance.ServersKilled == 0){
            KillToContinue.interpolateText = true;
            return;
        }
        StartCoroutine(GameAnimReset());
    }
    public void Die(){
        StartCoroutine(AnimFadeoff());
    }
    void FixedUpdate()
    {
        if(GameManager.Instance.AIsKilled >= 1 && GameManager.Instance.ServersKilled >= 1){
            KillToContinue.interpolateText = false;
        }
    }
    public static float Linear(float from, float to, float x) 
        {return from + (to - from) * x;}    
    public static float EaseInOutCubic(float from, float to, float x) 
        {return Linear(from, to, x < 0.5f ? 4 * x * x * x : 1 - Mathf.Pow(-2 * x + 2, 3) / 2);}
    IEnumerator FadeOut(){
        IsTransitioning = true;
        TransImage.enabled = true;
        float startTime = Time.time;
        while(Time.time - startTime < 2){
            float x = (Time.time - startTime)/2;
            TransImage.color = new Color(0,0,0,EaseInOutCubic(0,1,x));
            yield return 0;
        }
        IsTransitioning = false;
    }
    IEnumerator FadeIn(){
        IsTransitioning = true;
        TransImage.enabled = true;
        float startTime = Time.time;
        while(Time.time - startTime < 2){
            float x = (Time.time - startTime)/2;
            TransImage.color = new Color(0,0,0,EaseInOutCubic(1,0,x));
            yield return 0;
        }
        TransImage.enabled = false;
        IsTransitioning = false;
    }
    IEnumerator GameAnimReset(){
        yield return StartCoroutine(FadeOut());
        KillToContinue.interpolateText = false;
        GameManager.Instance.ResetLevel();
        yield return StartCoroutine(FadeIn());
    }
    IEnumerator AnimFadeoff(){
        yield return StartCoroutine(FadeOut());
        DeadToContinue.interpolateText = true;
        yield return new WaitUntil(() => Back.IsInProgress() || attackAction.IsInProgress());
        if(Back.IsInProgress()){
            DeadToContinue.interpolateText = false;
            //todo
            yield break;
        }else if (attackAction.IsInProgress()){
            DeadToContinue.interpolateText = false;
            yield return new WaitForSeconds(3);
            SceneManager.LoadScene("SampleScene"); // reload scene
            yield break;
        }
    }
}
