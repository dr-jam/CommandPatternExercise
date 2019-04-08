using UnityEngine;

namespace Captain.Command
{
    public interface ICaptainCommand
    {
        void Execute(GameObject gameObject);
    }
}
