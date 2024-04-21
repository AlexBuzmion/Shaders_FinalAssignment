using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AccessRenderer : MonoBehaviour
{
    private Renderer _sineWave; 

    // Start is called before the first frame update
    void Start()
    {
        _sineWave = GetComponent<Renderer>();    
    }

    // Update is called once per frame
    void Update()
    {
        _sineWave.material.SetFloat("_Period", Input.mousePosition.x); 
    }
}
