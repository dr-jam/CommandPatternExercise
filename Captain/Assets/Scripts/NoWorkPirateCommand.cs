using System.Collections;
using System.Collections.Generic;
using UnityEngine;

using Captain.Command;

namespace Captain.Command
{
    public class NoWorkPirateCommand : ScriptableObject, IPirateCommand
    {
        private float TotalWorkDuration;
        private float TotalWorkDone;
        private float CurrentWork;
        private const float PRODUCTION_TIME = 2.0f;
        private bool Exhausted = false;

        public NoWorkPirateCommand()
        {

        }

        public bool Execute(GameObject pirate, Object productPrefab)
        {
            //This function returns false when no work is done. 
            //After you implement work according to the specification and
            //generate instances of productPrefab, this function should return true.
            return false;
        }
    }
}
