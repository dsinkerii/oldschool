using TMPro;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.UI;

public class KeybindHelper : MonoBehaviour
{
    public Button button;
    public TextMeshProUGUI text;
    public InputActionReference actionReference;
    public InputAction action => actionReference?.action;
    public int bindingIndex;
}
