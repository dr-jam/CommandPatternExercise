using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(SpriteRenderer))]
public class Parallax : MonoBehaviour
{
    public float ParallaxMagnitude;
    public Camera Cam;

    private float SpriteLength;
    private float SpriteLeft;
        
    void Start()
    {
        this.SpriteLeft = this.transform.position.x;
        this.SpriteLength = GetComponent<SpriteRenderer>().bounds.size.x;
    }

    void Update()
    {
        float distToSpriteEnd = this.Cam.transform.position.x * this.ParallaxMagnitude;
        float distAlongSprite = this.Cam.transform.position.x * (1 - this.ParallaxMagnitude);

        this.transform.position = new Vector3(this.SpriteLeft + distToSpriteEnd, this.transform.position.y, this.transform.position.z);

        if (distAlongSprite > this.SpriteLeft + this.SpriteLength)
        {
            this.SpriteLeft += this.SpriteLength;
        } else if (distAlongSprite < this.SpriteLeft - this.SpriteLength)
        {
            this.SpriteLeft -= this.SpriteLength;
        }
    }
}
