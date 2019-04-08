using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Captain.Command;

public class CaptainController : MonoBehaviour
{
    private ICaptainCommand Fire1;
    private ICaptainCommand Fire2;
    private ICaptainCommand Right;
    private ICaptainCommand Left;

    public UnityEngine.UI.Text Booty;
    public int Mushrooms;
    public int Skulls;
    public int Gems;

    // Start is called before the first frame update
    void Start()
    {
        this.gameObject.AddComponent<CaptainMotivateCommand>();
        this.Fire1 = this.gameObject.GetComponent<CaptainMotivateCommand>();
        this.Fire2 = ScriptableObject.CreateInstance<DoNothing>();
        this.Right = ScriptableObject.CreateInstance<DoNothing>();
        this.Left = ScriptableObject.CreateInstance<MoveCharacterLeft>();
        this.Booty.text = "Booty";

    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetButtonDown("Fire1"))
        {
            this.Fire1.Execute(this.gameObject);
        }
        if (Input.GetButtonDown("Fire2"))
        {
            this.Fire2.Execute(this.gameObject);
        }
        if(Input.GetAxis("Horizontal") > 0.01)
        {
            this.Right.Execute(this.gameObject);
        }
        if(Input.GetAxis("Horizontal") < -0.01)
        {
            this.Left.Execute(this.gameObject);
        }

        var animator = this.gameObject.GetComponent<Animator>();
        animator.SetFloat("Velocity", Mathf.Abs(this.gameObject.GetComponent<Rigidbody2D>().velocity.x/5.0f));
        this.Booty.text = "x" + (this.Mushrooms * 1 + this.Gems * 3 + this.Skulls * 2);
    }

    private void OnCollisionEnter2D(Collision2D collision)
    {
        //Debug.Log(collision);
        if (collision.gameObject.tag == "Mushroom")
        {
            Destroy(collision.gameObject);
            this.Mushrooms++;
        }
        else if (collision.gameObject.tag == "Skull")
        {
            Destroy(collision.gameObject);
            this.Skulls++;
        }else if(collision.gameObject.tag == "Gem")
        {
            Destroy(collision.gameObject);
            this.Gems++;
        }
    }
}