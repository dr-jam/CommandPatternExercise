using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Captain.Command;

namespace Captain.Command
{
    public class CaptainMotivateCommand : MonoBehaviour, ICaptainCommand
    {
        private bool Active;
        private const float DURATION = 0.4f;
        private const float OFFSET = 0.2f;
        private float ElapsedTime;
        private GameObject Motivator;
        private BoxCollider2D MotivationBox;

        void Start()
        {
            this.ElapsedTime = 0.0f;
            this.Active = false;
        }

        void Update()
        {
            if (this.Active)
            {
                this.ElapsedTime += Time.deltaTime;
                if (this.ElapsedTime > OFFSET)
                {
                    var contacts = new Collider2D[32];
                    this.MotivationBox.GetContacts(contacts);

                    foreach (var col in contacts)
                    {

                        if (col != null && col.gameObject != null && col.gameObject.tag == "Pirate")
                        {
                            col.gameObject.GetComponent<PirateController>().Motivate();
                            this.Active = false;
                        }
                        break;
                    }

                    if (this.ElapsedTime > DURATION || !this.Active)
                    {
                        this.Active = false;

                    }

                }
                this.Motivator.GetComponent<Animator>().SetBool("Motivate", this.Active);
            }
        }

        public void Execute(GameObject gameObject)
        {
            if(!this.Active)
            {
                this.ElapsedTime = 0.0f;
                this.Active = true;
                this.Motivator = gameObject;
                this.MotivationBox = this.Motivator.transform.Find("Motivator").GetComponent<BoxCollider2D>();
            }
        }
    }
}
