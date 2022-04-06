using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraObjectFollow : MonoBehaviour
{
    public GameObject target;
    public float speed = 0.75f;

    private Vector3 targetPosition;

    void Start()
    {
        this.targetPosition = this.transform.position;
    }
    
    void FixedUpdate()
    {
        if (this.target)
        {
            var from = new Vector3(this.transform.position.x, this.transform.position.y, this.transform.position.z);
            var to = new Vector3(this.target.transform.position.x, this.transform.position.y, this.transform.position.z);
            transform.position = Vector3.Lerp(from, to, this.speed);
        }
    }
}
