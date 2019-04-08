using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraObjectFollow : MonoBehaviour
{
    public GameObject Target;
    public float Speed = 0.75f;

    private Vector3 TargetPosition;

    void Start()
    {
        this.TargetPosition = this.transform.position;
    }
    
    void FixedUpdate()
    {
        if (this.Target)
        {
            var from = new Vector3(this.transform.position.x, this.transform.position.y, this.transform.position.z);
            var to = new Vector3(this.Target.transform.position.x, this.transform.position.y, this.transform.position.z);
            transform.position = Vector3.Lerp(from, to, this.Speed);
        }
    }
}
