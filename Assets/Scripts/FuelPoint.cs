using UnityEngine;

public class FuelPoint : MonoBehaviour
{
    public bool HasRecharged;
    public float fuelAdd;
    public float hpAdd = 25;
    public GameObject FuelIcon;
    void OnTriggerEnter(Collider other){
        if(!HasRecharged && other.gameObject.layer == 6){ // if player
            HasRecharged = true;
            ValueManager.AddFuel(fuelAdd);
            AudioManager.Instance.PlaySound("fuelAdd");
            ValueManager.AddHp(hpAdd);
            FuelIcon.SetActive(false);
        }
    }
}
