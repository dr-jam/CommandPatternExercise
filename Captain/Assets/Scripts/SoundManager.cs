using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Audio;

/**
 * Adapted from "Indroduction to AUDIO in Unity" by Brackeys:
 * https://www.youtube.com/watch?v=6OT43pvUyfY
 *
 * Audio assets from: https://sirental.itch.io/elemental-dungeons
 */

public class SoundManager : MonoBehaviour
{
    [SerializeField]
    private AudioMixerGroup musicMixerGroup;

    [SerializeField]
    private AudioMixerGroup sfxMixerGroup;

    [SerializeField]
    private List<SoundClip> musicTracks;

    [SerializeField]
    private List<SoundClip> sfxClips;

    private SoundClip trackPlaying;
    private SoundClip trackFading;
    private SoundClip sfxPlaying;


    void Awake()
    {
        foreach (var track in this.musicTracks)
        {
            track.audioSource = this.gameObject.AddComponent<AudioSource>();
            track.audioSource.clip = track.clip;
            track.audioSource.volume = track.volume;
            track.audioSource.pitch = track.pitch;
            track.audioSource.loop = track.loop;
            track.audioSource.outputAudioMixerGroup = this.musicMixerGroup;
        }

        foreach (var clip in this.sfxClips)
        {
            clip.audioSource = this.gameObject.AddComponent<AudioSource>();
            clip.audioSource.clip = clip.clip;
            clip.audioSource.volume = clip.volume;
            clip.audioSource.pitch = clip.pitch;
            clip.audioSource.loop = clip.loop;
            clip.audioSource.outputAudioMixerGroup = this.sfxMixerGroup;
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
        
        track.audioSource.Play();

        if(null != this.trackPlaying) {
            this.trackPlaying.audioSource.Stop();
        }   

        this.trackPlaying = track;
    }


    public void PlaySoundEffect(string title)
    {
        var track = this.sfxClips.Find(track => track.title == title);

        if(null == track) 
        {
            Debug.Log("Sound track not found: " + title);
            return;
        }

        track.audioSource.Play();
    }
}
