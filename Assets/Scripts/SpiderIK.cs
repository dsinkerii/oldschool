using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// manage IK's for the spider, nothing crazy
/// </summary>
public class SpiderIK : MonoBehaviour
{
    // because i dont want to pull up serialized dictionaries, or just do legs by indices, we're using custom classes
    // the ones we raycast to below, hope the directions are clear enough
    [Serializable] public class SpiderLimbTargets{ 
        public List<Vector3> LocalStartPosition = new List<Vector3>(4); // for when we start to move
        public Transform LF;
        public Transform RF;
        public Transform LB;
        public Transform RB;
        public float LastBoneHeight = 1;
        // kind of easier to read rather than an ienumerator, bad example but works easier in my eyes.
        public Transform[] LegArray{
            set{}
            get{
                return new Transform[4]{LF,RF,LB,RB};
            }
        }
        public void CopyTargetPos(int index, Vector3 position, Vector3 normal){
            // since i didn't setup the rig correctly, we need to offset the tip just a bit to make it visible
            LegArray[index].position = position;
            LegArray[index].localPosition += new Vector3(0, LastBoneHeight, 0);
            LegArray[index].rotation = Quaternion.Euler(normal);
            LegArray[index].localRotation = Quaternion.Euler(new Vector3(0,0,180) + LegArray[index].localRotation.eulerAngles);
        }
    }
    // send raycasts from these objects
    [Serializable] public class RaycasterParents{ 

        public Transform LF;
        public Transform RF;
        public Transform LB;
        public Transform RB;
        // kind of easier to read rather than an ienumerator, bad example but works easier in my eyes.
        public Transform[] RaycastArray{
            set{}
            get{
                return new Transform[4]{LF,RF,LB,RB};
            }
        }
    }
    [SerializeField] Transform spiderBody;
    [SerializeField] SpiderLimbTargets legTargets;
    [SerializeField] RaycasterParents raycaster;
    [SerializeField] List<Vector3> raycastLookAhead = new List<Vector3>(4);
    [SerializeField] List<Vector3> RaycastPositions = new List<Vector3>(4);
    [SerializeField] List<Vector3> RaycastRotations = new List<Vector3>(4);
    [SerializeField] float PosAdjustRatio = 0.1f;
    [SerializeField] float RotAdjustRatio = 0.2f;
    private List<Vector3> hiddenLerpPos = new List<Vector3>(4){Vector3.zero,Vector3.zero,Vector3.zero,Vector3.zero}; // for moving legs + y offset
    public float MoveSpeedMin = 2;
    public float MoveDistance = 0.5f;
    public float MoveAhead = 2;
    public float StepHeight = 1;
    public float SpiderHeight = 1;
    private Vector3 bodyUp;
    private Vector3 bodyForward;
    private Vector3 bodyRight;
    private Vector3 bodyPos;
    public Vector3 BodyRotOffset; // our spidey-boy is a little stupid (thanks to blender's switch of coordinates), we need to add an offset parameter
    private Quaternion bodyRotation;
    public bool StickToGround;
    public bool Grounded;
    [SerializeField] List<bool> UpdateLegPos = new(4);
    [SerializeField] float moveSpeedlocal = 2;
    [SerializeField] float groundHeight = 3;
    [SerializeField] float accelerationSpeed = 20;
    [SerializeField] Rigidbody rb;
    void Start()
    {
        // init setup
        UpdateLegPos = new (){false,false,false,false}; // in case it broke
        if(RaycastPositions.Count != 4) RaycastPositions = new List<Vector3>(4); // no out of range errors
        if(RaycastRotations.Count != 4) RaycastRotations = new List<Vector3>(4);
        if(raycastLookAhead.Count != 4) raycastLookAhead = new List<Vector3>(4);
        // shoot rays downward
        int i = 0;
        foreach(var parent in raycaster.RaycastArray){
            RaycastHit hit;
            if (Physics.Raycast(parent.position, parent.TransformDirection(Vector3.down), out hit, 10)){
                // hit
                RaycastPositions[i] = hit.point;
                legTargets.LegArray[i].position = hit.point;
                RaycastRotations[i] = hit.normal;
            }
            i++;
        }
    }
    RaycastHit hit;
    float acceleration;
    void Update(){
        // grounded
        Grounded = Physics.Raycast(rb.position, rb.transform.TransformDirection(Vector3.down), out hit, groundHeight);
        acceleration = Grounded && StickToGround ? 0 : Mathf.Min(acceleration += Time.deltaTime*accelerationSpeed, 10);
        if(!StickToGround){
            rb.AddForce(new Vector3(0,-45.6f*acceleration,0));
        }
        
        // get speed
        moveSpeedlocal = MoveSpeedMin + rb.linearVelocity.magnitude*Time.deltaTime*2;
        // shoot rays downward
        int i = 0;
        foreach(var parent in raycaster.RaycastArray){
            if (Physics.Raycast(parent.position, parent.TransformDirection(Vector3.down), out hit, 10)){
                // hit
                RaycastPositions[i] = hit.point;
                RaycastRotations[i] = hit.normal;
            }
            i++;
        }

        // now targets
        SetLegTargets();
        // set body pos (https://github.com/Sopiro/Unity-Procedural-Animation/blob/master/Assets/Scripts/LegController.cs)
        RotateBody();
    }
    void SetLegTargets(){
        int i=0;
        foreach(var target in legTargets.LegArray){
            if(Vector3.Distance(target.position, RaycastPositions[i]) > MoveDistance && !UpdateLegPos[i]){ // only move if we're not moving already
                if(legTargets.LocalStartPosition.Count != 4) legTargets.LocalStartPosition = new List<Vector3>(4); // no out of range errors
                legTargets.LocalStartPosition[i] = target.position;

                // we dont move our foot to the center of our body when we walk, we move it ahead, so we dont switch legs too fast, so we move it for convenience
                raycastLookAhead[i] = (RaycastPositions[i]-target.position).normalized*MoveAhead+RaycastPositions[i]; // get direction of where to go, multiply by ahead value, and add to center of where to go
                hiddenLerpPos[i] = legTargets.LocalStartPosition[i];

                ///
                /// okay so this one's kinda stupid written, so here's a recap:
                /// we allow the current leg we're iterating to move, only
                /// if the leg opposite to it is not moving already
                /// we're doing this by doing a quick swith with opposite leg
                /// being inverted
                /// 
                /// this is faster than making it universal for many legs, because
                /// i dont expect there to be more than 4 legs
                ///
                UpdateLegPos[i] = i switch{ // switch legs only if the opposite is not moving
                    0 => !UpdateLegPos[1] && !UpdateLegPos[2], // LF check against RF & LB
                    1 => !UpdateLegPos[0] && !UpdateLegPos[3], // RF check against LF & RB
                    2 => !UpdateLegPos[3] && !UpdateLegPos[0], // LB check against RB & LF
                    3 => !UpdateLegPos[2] && !UpdateLegPos[1], // RB check against LB & RF
                    _ => true // ermm, 5th leg??? what the flip, set to true anyway then
                };
            }
            if(UpdateLegPos[i] && StickToGround){
                float Ylerp = Vector3.Distance(hiddenLerpPos[i], raycastLookAhead[i]) / (Vector3.Distance(raycastLookAhead[i], legTargets.LocalStartPosition[i])+0.001f);
                hiddenLerpPos[i] = Vector3.MoveTowards(hiddenLerpPos[i], raycastLookAhead[i], moveSpeedlocal);
                var pos = hiddenLerpPos[i] + spiderBody.TransformDirection(new Vector3(0,0,Mathf.Abs(Mathf.Sin(Ylerp*Mathf.PI))*StepHeight*-1));
                legTargets.CopyTargetPos(i, pos, RaycastRotations[i]);
                if(Vector3.Distance(hiddenLerpPos[i], raycastLookAhead[i]) < 0.00005f){
                    UpdateLegPos[i] = false; // we're done here
                }
            }else if (!StickToGround){
                legTargets.CopyTargetPos(i, new Vector3(RaycastPositions[i].x,Mathf.Max(spiderBody.position.y-2,RaycastPositions[i].y),RaycastPositions[i].z), RaycastRotations[i]);
            }
            i++;
        }
    }
    void RotateBody(){
        Vector3 tipCenter = Vector3.zero;
        bodyUp = Vector3.zero;

        // Collect leg information to calculate body transform
        for (int j = 0; j < 4; j++)
        {
            tipCenter += RaycastPositions[j];
            bodyUp += RaycastRotations[j];
        }

        if (Physics.Raycast(spiderBody.position, spiderBody.up * -1, out hit, 10.0f))
        {
            bodyUp += hit.normal;
        }

        tipCenter /= 4;
        bodyUp.Normalize();

        // Interpolate postition from old to new
        if(StickToGround){
            bodyPos = tipCenter + bodyUp * SpiderHeight;
            spiderBody.position = Vector3.Lerp(spiderBody.position, bodyPos, PosAdjustRatio);
        }

        // Calculate new body axis
        bodyRight = Vector3.Cross(bodyUp, spiderBody.forward);
        bodyForward = Vector3.Cross(bodyRight, bodyUp);

        // Interpolate rotation from old to new
        if(StickToGround)
            bodyRotation = Quaternion.LookRotation(bodyForward, bodyUp);
        else
            bodyRotation = Quaternion.LookRotation(bodyForward, Vector3.up);
        spiderBody.rotation = Quaternion.Slerp(spiderBody.rotation, bodyRotation, RotAdjustRatio);
    }
    void OnDrawGizmos()
    {
        Gizmos.color = Color.yellow;
        foreach(var parent in raycaster.RaycastArray){
            RaycastHit hit;
            if (Physics.Raycast(parent.position, parent.TransformDirection(Vector3.down), out hit, 10)){
                Gizmos.DrawLine(parent.position, hit.point); 
            }
        }
    }
}
