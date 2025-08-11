using System.Collections.Generic;
using UnityEngine;

public class ServerScript : MonoBehaviour
{
    public float HP = 50;
    public float FuelAdd = 12;
    public float DamageSelfMultiplier = 2;
    public float PlayerHurt = 12;
    public int ScoreAdd = 1000;
    public bool IsDead;
    public bool IsEvilServer;
    [SerializeField] ParticleSystem sparks;
    [SerializeField] ParticleSystem Explosion;
    [SerializeField] JustShake shake;
    [SerializeField] GameObject EvilServerShow;
    [SerializeField] GameObject IsAliveParticle;
    public static Dictionary<string,ServerScript> CachedServers = new();
    void Awake(){
        if(IsEvilServer){
            EvilServerShow.SetActive(true);
        }
        gameObject.name = System.Guid.NewGuid().ToString();
        CachedServers.Add(gameObject.name, this);
        IsAliveParticle.SetActive(true);
    }
    void OnDestroy(){
        if(!IsDead)
        CachedServers.Remove(gameObject.name);
    }
    void FixedUpdate(){
        if(IsEvilServer && !EvilServerShow.activeSelf){
            EvilServerShow.SetActive(true);
        }
    }
    public void Damage(float amount){
        HP = Mathf.Max(HP-amount*DamageSelfMultiplier,0);
        if(HP < 40&& !IsDead){
            if(!sparks.isPlaying){
                sparks.Play();
            }
            var emission = sparks.emission;
            emission.rateOverTime = Mathf.Lerp(200,0,HP/40);
        }
        if(HP < 20&& !IsDead){
            shake.Amount = Mathf.Lerp(0.1f,0,HP/20);
        }
        if(HP == 0 && !IsDead){
            shake.Amount = 0;
            sparks.Stop();
            IsAliveParticle.SetActive(false);
            if(IsEvilServer){
                Explosion.transform.localScale = Vector3.one*2;
                Explosion.Play();
                AudioManager.Instance.PlaySound("explosion");
                PlayerScript.Instance.Damage(PlayerHurt);
                foreach(var kvp in GuardScript.CachedGuards){ // trigger random enemy (if any)
                    if(kvp.Value.AggressiveToPlayer) continue;
                    kvp.Value.AggressiveToPlayer = true;
                    break; 
                }
            }else{
                Explosion.Play();
                IsDead = true;
                ValueManager.AddFuel(FuelAdd);
                ValueManager.AddScore(ScoreAdd);
            }
            CachedServers.Remove(gameObject.name); // remove ourselfs from the dict since we dont need it atp
        }
    }
}
