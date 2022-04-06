using UnityEngine.Audio;
using UnityEngine;

[System.Serializable]
public class SoundClip 
{
    public AudioClip clip;

    [HideInInspector]
    public AudioSource audioSource;

    public string title;

    [Range(0f, 1f)]
    public float volume = 1.0f;
    
    [Range(0.1f, 3f)]
    public float pitch = 1.0f;
    
    public bool loop = true;
}
