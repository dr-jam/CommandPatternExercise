using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Captain.Command;

namespace Captain.Command
{
    public class CaptainMotivateCommand : MonoBehaviour, ICaptainCommand
    {
        private bool active;
        private const float DURATION = 0.4f;
        private const float OFFSET = 0.2f;
        private float elapsedTime;
        private GameObject motivator;
        private BoxCollider2D motivationBox;

        void Start()
        {
            this.elapsedTime = 0.0f;
            this.active = false;
        }

        void Update()
        {
            if (this.active)
            {
                this.elapsedTime += Time.deltaTime;
                
                if (this.elapsedTime > OFFSET)
                {
                    var contacts = new Collider2D[32];
                    this.motivationBox.GetContacts(contacts);

                    foreach (var contactedObject in contacts)
                    {

                        if (contactedObject != null && contactedObject.gameObject != null && contactedObject.gameObject.tag == "Pirate")
                        {
                            contactedObject.gameObject.GetComponent<PirateController>().Motivate();
                            this.active = false;
                        }
                        break;
                    }

                    if (this.elapsedTime > DURATION || !this.active)
                    {
                        this.active = false;

                    }

                }

                this.motivator.GetComponent<Animator>().SetBool("Motivate", this.active);
            }
        }

        public void Execute(GameObject gameObject)
        {
            FindObjectOfType<SoundManager>().PlaySoundEffect("hit");

            if(!this.active)
            {
                this.elapsedTime = 0.0f;
                this.active = true;
                this.motivator = gameObject;
                this.motivationBox = this.motivator.transform.Find("Motivator").GetComponent<BoxCollider2D>();
            }
        }
    }
}
