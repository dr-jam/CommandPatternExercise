using System.Collections;
using System.Collections.Generic;
using UnityEngine;

using Captain.Command;

namespace Captain.Command
{
    public class MoveCharacterLeft : ScriptableObject, ICaptainCommand
    {
        private float Speed = 5.0f;

        public void Execute(GameObject gameObject)
        {
            var rigidBody = gameObject.GetComponent<Rigidbody2D>();
            if (rigidBody != null)
            {
                rigidBody.velocity = new Vector2(-this.Speed, rigidBody.velocity.y);
                gameObject.GetComponent<SpriteRenderer>().flipX = true;
            }
        }
    }
}