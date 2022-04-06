using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TeleportCaptain : MonoBehaviour
{

    public GameObject DestinationLevel;
    public Camera MainCamera;

    private void OnCollisionEnter2D(Collision2D collision)
    {
        if(collision.gameObject.name == "Captain")
        {
            collision.gameObject.transform.position = new Vector2(Random.value * 20.0f - 10.0f, this.DestinationLevel.transform.position.y + 4);
            this.MainCamera.transform.position = new Vector3(this.DestinationLevel.transform.position.x, this.DestinationLevel.transform.position.y, this.MainCamera.transform.position.z);
            FindObjectOfType<SoundManager>().PlaySoundEffect("bomb");
        }
    }
}
