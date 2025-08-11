using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.SceneManagement;

public class PauseGame : MonoBehaviour
{
    public static PauseGame Instance;
    InputAction pause;
    bool paused;
    public GameObject quit;
    bool IsActivelyPressing;
    void Start(){
        Instance = this;
        pause = InputSystem.actions.FindAction("Previous");
    }
    public void Unclose(){
        paused = false;
        Time.timeScale = 1;
        quit.SetActive(true);
    }
    public void MainMenu(){
        SceneManager.LoadScene("MainMenu");
    }
    void Update()
    {
        if(PlayerScript.Instance.IsDead) return;
        if(pause.IsPressed() && !IsActivelyPressing){
            IsActivelyPressing = true;
            paused = !paused;
            Time.timeScale = paused ? 0 : 1;
            quit.SetActive(paused);
        }else if(!IsActivelyPressing){
            IsActivelyPressing = false;
        }
    }
}
