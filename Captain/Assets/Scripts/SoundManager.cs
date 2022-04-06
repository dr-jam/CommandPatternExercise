using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/**
 * Adapted from "Indroduction to AUDIO in Unity" by Brackeys:
 * https://www.youtube.com/watch?v=6OT43pvUyfY
 */

public class SoundManager : MonoBehaviour
{
    [SerializeField]
    private List<MusicTrack> musicTracks;

    private MusicTrack playing;
    private MusicTrack fading;

    void Awake()
    {
        foreach (var track in this.musicTracks)
        {
            track.audioSource = this.gameObject.AddComponent<AudioSource>();
            track.audioSource.clip = track.clip;
            track.audioSource.volume = track.volume;
            track.audioSource.pitch = track.pitch;
            track.audioSource.loop = track.loop;
        }
    }

    public void PlayMusicTrack(string title)
    {
        var track = this.musicTracks.Find(track => track.title == title);

        if(null == track) 
        {
            Debug.Log("Sound track not found: " + title);
            return;
        }
        Debug.Log("Playing " + title);
        track.audioSource.Play();
        if(null != this.playing) {
            this.playing.audioSource.Stop();
        }         
        this.playing = track;
    }
}
