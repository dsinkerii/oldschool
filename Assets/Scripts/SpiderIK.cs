using System;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// manage IK's for the spider, nothing crazy
/// </summary>
public class SpiderIK : MonoBehaviour
{
    // because i dont want to pull up serialized dictionaries, or just do legs by indices, we're using custom classes
    // the ones we raycast to below, hope the directions are clear enough
    [Serializable] public class SpiderLegTargets{ 
        public Transform LF;
        public Transform RF;
        public Transform LB;
        public Transform RB;
    }
    [SerializeField] SpiderLegTargets legTargets;
    // same as above, except not really. 
    // provided by Animation Rigging package, but for ease of use are treated separately.
    [Serializable] public class InternalIKTargets{ 
        public Transform LF;
        public Transform RF;
        public Transform LB;
        public Transform RB;
    }
    [SerializeField] InternalIKTargets ikTargets;
    void Start()
    {
        
    }

    void Update()
    {
        
    }
}
