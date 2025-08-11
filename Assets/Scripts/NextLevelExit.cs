using System.Collections;
using UnityEngine;

public class NextLevelExit : MonoBehaviour
{
    public bool HasEntered;

    void OnTriggerEnter(Collider other){
        if(other.gameObject.layer == 6 && !HasEntered){ // player
            HasEntered = true;
            LevelTransition.Instance.TransitionLevel();
        }
    }
}
