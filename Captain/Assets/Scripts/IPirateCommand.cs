using UnityEngine;

namespace Captain.Command
{
    public interface IPirateCommand
    {
        bool Execute(GameObject pirate, Object productPrefab);
    }
}
