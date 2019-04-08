using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Captain.Command;

namespace Captain.Command
{
    public class DoNothing : ScriptableObject, ICaptainCommand
    {
        public void Execute(GameObject gameObject)
        {
            //doing nothing
        }
    }
}