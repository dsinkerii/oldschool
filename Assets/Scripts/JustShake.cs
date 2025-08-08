using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class JustShake : MonoBehaviour
{
    [Header("radius at which we will shake\none unit = one meter in-game")]
    public float Amount;
    public Vector3 StartPos;
    public bool DisableXAxis;
    public bool DisableYAxis;
    public bool DisableZAxis;
    [Header("how fast do we go away. 1 unit = fade away in 1 sec\n(if amount = 1)")]
    public float Falloff;
    public bool UseAnchoredPosition;
    public RectTransform rectTransform;
    public int fps;
    float fpsinternalcounter;
    void Start()
    {
        if(UseAnchoredPosition && rectTransform == null){
            rectTransform = GetComponent<RectTransform>();
        }
        if(UseAnchoredPosition)
            StartPos = rectTransform.anchoredPosition;
        else
            StartPos = transform.localPosition;
    }
    public void ResetStartPos(Vector3? newPos = null){
        StartPos = (Vector3)(newPos == null ? (UseAnchoredPosition ? rectTransform.anchoredPosition : transform.localPosition) : newPos);
    }

    // Update is called once per frame
    void Update()
    {
        if(Falloff > 0 && Amount > 0){
            Amount -= Falloff * Time.unscaledDeltaTime;
            if(Amount < 0){
                Amount = 0;
            }
        }
        bool CanShake = false;
        if(fps > 0){
            if(Time.time-fpsinternalcounter >= 1/fps){
                fpsinternalcounter=Time.time;
                CanShake = true;
            }
        }else{
            CanShake = true;
        }
            if(CanShake){
                if(UseAnchoredPosition)
                    rectTransform.anchoredPosition = StartPos + new Vector3(!DisableXAxis ? Random.insideUnitSphere.normalized.x : 0,!DisableYAxis ? Random.insideUnitSphere.normalized.y : 0,!DisableZAxis ? Random.insideUnitSphere.normalized.z : 0) * Amount;
                else
                    transform.localPosition = StartPos + new Vector3(!DisableXAxis ? Random.insideUnitSphere.normalized.x : 0,!DisableYAxis ? Random.insideUnitSphere.normalized.y : 0,!DisableZAxis ? Random.insideUnitSphere.normalized.z : 0) * Amount;
            }

    }
    public void SuddenJump(float _Amount){ // for animations
        Amount = _Amount;
    }
}
