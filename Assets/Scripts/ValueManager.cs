using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class ValueManager : MonoBehaviour
{
    public float MaxHp = 100;
    public float HP = 100;
    public float HPPerPistonbar = 20;
    public float MaxFuel = 50;
    public float Fuel = 50;
    public float HPLoseRate = 0.3f;// per second
    public List<Sprite> PistonSprites;
    public List<Image> PistonImages;
    public List<JustShake> PistonShakes;
    private readonly float[] PistonUpdateTicks = new[]{0f,0,0,0,0};
    private readonly int[] pistonFrame = new[]{0,0,0,0,0};
    public static ValueManager Instance;
    public int Score;


    public Slider FuelSlider;
    public TextMeshProUGUI FuelRateText;
    public TextMeshProUGUI ScoreText;
    public Image FuelPour;
    float PourDelta;
    void Start()
    {
        Instance = this;
        ScoreText.text = $"{Score}";
    }
    void Update()
    {
        // set hp bars
        for(int i = 0; i < 5; i++){
            PistonShakes[i].Amount = 0; // reset just in case
            SetImageForPiston(i);
        }
        FuelRateText.text = $"<mspace=16>fuel: {Fuel:F1}L / {MaxFuel:F1}L";
        FuelSlider.maxValue = MaxFuel;
        FuelSlider.value = Mathf.Lerp(FuelSlider.value,Fuel,Time.deltaTime);
        if(Fuel <= 0){
            Fuel = 0; // dont go below 0
            HP -= HPLoseRate * Time.deltaTime;
        }
        if(PourDelta < 0.2f && FuelPour.gameObject.activeSelf){
            PourDelta = 0;
            FuelPour.gameObject.SetActive(false);
        }else if(PourDelta >= 0.2f){
            if(!FuelPour.gameObject.activeSelf){
                FuelPour.gameObject.SetActive(true);
            }
            FuelPour.rectTransform.sizeDelta = Vector2.Lerp(FuelPour.rectTransform.sizeDelta,new Vector2(Mathf.Min(PourDelta*1.5f, 32), FuelPour.rectTransform.sizeDelta.y), Time.deltaTime*8);
        }
        PourDelta = Mathf.Lerp(PourDelta, 0, Time.deltaTime*3);
        if(HP <= 0 && !PlayerScript.Instance.IsDead){
            PlayerScript.Instance.IsDead = true;
            LevelTransition.Instance.Die();
            AudioManager.Instance.PlaySound("death");
        }
    }
    void SetImageForPiston(int pistonID){
        if(HPPerPistonbar * pistonID >= HP){
            PistonImages[pistonID].sprite = PistonSprites[4];
            PistonShakes[pistonID].Amount = 0;
            PistonImages[pistonID].rectTransform.anchoredPosition = new Vector3(0,0,0);
            return;
        }
        if(PistonUpdateTicks[pistonID] <= 0){ // next frame
            if(Mathf.Ceil(Mathf.Clamp(HP,1,MaxHp-1)/HPPerPistonbar)-1 == pistonID){ // hp is on this piston
                PistonUpdateTicks[pistonID] = Mathf.Lerp(1/60f,1/10f, (Mathf.Clamp(HP,1,MaxHp-1) % HPPerPistonbar) / HPPerPistonbar);
                if(Mathf.Clamp(HP-1,1,MaxHp-1) % HPPerPistonbar < 7.5f){
                    float alpha = 1-(Mathf.Clamp(HP,1,MaxHp-1) % HPPerPistonbar)/7.5f;
                    PistonShakes[pistonID].Amount = alpha*4;
                }
                PistonImages[pistonID].rectTransform.anchoredPosition = new Vector3(0,10,0);
            }else{
                PistonUpdateTicks[pistonID] = 0.1f; // 10 fps
                PistonImages[pistonID].rectTransform.anchoredPosition = new Vector3(0,0,0);
            }
            pistonFrame[pistonID] = (pistonFrame[pistonID] + 1) % 4;
            PistonImages[pistonID].sprite = PistonSprites[(pistonFrame[pistonID] + pistonID) % 4];
        }
        PistonUpdateTicks[pistonID]-=Time.deltaTime;
    }
    public static void AddFuel(float val){
        Instance.Fuel = Mathf.Min(Instance.Fuel+val, Instance.MaxFuel);
        Instance.PourDelta+=val;
    }
    public static void AddScore(int val){
        Instance.Score+=val;
        Instance.ScoreText.text = $"{Instance.Score}";
    }
    public static void AddHp(float val){
        Instance.HP=Mathf.Min(Instance.HP+val,100);
    }
}
