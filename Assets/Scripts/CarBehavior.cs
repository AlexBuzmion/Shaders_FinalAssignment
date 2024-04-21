using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CarBehavior : MonoBehaviour
{
    public float speed = 10.0f;
    public Rigidbody rb;
    public Material mat;
    public Transform go;

    void Awake()
    {
        rb = GetComponent<Rigidbody>();  
    }

    // Update is called once per frame
    void Update()
    {
        if (go)
        {
            mat.SetVector("_MagnetDir", (transform.position - go.position).normalized);
        }
        else
        {
            mat.SetVector("_MagnetPos", transform.position);   
        }
        // make the car move forward
        transform.position += new Vector3 (0,0,-speed) * Time.deltaTime;
    }

    
}
