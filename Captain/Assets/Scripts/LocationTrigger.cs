using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(BoxCollider2D))]
public class LocationTrigger : MonoBehaviour
{
    [SerializeField]
    private string musicTrack = "Water";

    void OnTriggerEnter2D(Collider2D other)
    {
        if(other && other.tag == "Captain") 
        {
            FindObjectOfType<SoundManager>().PlayMusicTrack(this.musicTrack);
        }
    }
}
