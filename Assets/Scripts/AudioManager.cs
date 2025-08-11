using System.Collections.Generic;
using UnityEngine;
using AYellowpaper.SerializedCollections;
using System.Linq;
public class AudioManager : MonoBehaviour
{
    public static AudioManager Instance;
    [SerializedDictionary]
    public SerializedDictionary<string, AudioSource> sfx;
    public SerializedDictionary<string, AudioClip> music;
    public AudioSource MusicGlobal;
    public bool PlayMusic = true;
    void Start() => Instance = this;
    public void PlaySound(string id){
        sfx.TryGetValue(id, out AudioSource val);
        if(val != null) val.Play();
        else Debug.Log("bad id!");
    }

    void Update()
    {
        if(PlayMusic && !MusicGlobal.isPlaying){
            MusicGlobal.clip = music.ElementAt(Random.Range(0,music.Count())).Value;
            MusicGlobal.Play(); // yup. that's it
        }
    }
}
