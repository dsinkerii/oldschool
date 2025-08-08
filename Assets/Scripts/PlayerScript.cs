using System.Collections;
using UnityEngine;
using UnityEngine.InputSystem;
public class PlayerScript : MonoBehaviour
{
    public static PlayerScript Instance;
    public GameObject playerObject;
    [SerializeField] Transform CameraOffset;
    [SerializeField] Rigidbody rb;
    [SerializeField] Vector3 walkVec;
    [SerializeField] float jumpSpeed;
    [SerializeField] float forceSpeed;
    [SerializeField] float torque;
    [SerializeField] float sprintMultiplier = 2;
    [SerializeField] ParticleSystem fireParticle;
    [SerializeField] ParticleSystem dustParticle;
    [SerializeField] float FlamethrowerRate = 1; // 1 litre a sec
    [SerializeField] float RunFuelRate = 0.05f;
    [SerializeField] float EnemyDamageRate = 1f;
    [SerializeField] Transform FlameRaycastPoint;
    [SerializeField] SpiderIK spiderIK;
    InputAction moveAction;
    InputAction jumpAction;
    InputAction sprintAction;
    InputAction attackAction;
    [SerializeField] LayerMask ShootLayers;
    bool canJump = true;

    public void Damage(float val){
        ValueManager.Instance.HP=Mathf.Max(ValueManager.Instance.HP-val,0);
    }

    private void Start(){
        Instance = this;
        moveAction = InputSystem.actions.FindAction("Move");
        jumpAction = InputSystem.actions.FindAction("Jump");
        sprintAction = InputSystem.actions.FindAction("Sprint");
        attackAction = InputSystem.actions.FindAction("Attack");
    }
    void Update()
    {
        walkVec = moveAction.ReadValue<Vector2>();
        float realSprintMul = 1;
        if (sprintAction.IsInProgress() && ValueManager.Instance.Fuel > 0 && walkVec.magnitude > 0){
            realSprintMul = sprintMultiplier;
            ValueManager.Instance.Fuel-=Time.deltaTime*RunFuelRate;
        }
        rb.AddForce(CameraOffset.TransformDirection(realSprintMul * forceSpeed * Time.deltaTime * new Vector3(0,0,-walkVec.y)));
        rb.AddTorque(CameraOffset.TransformDirection(moveAction.ReadValue<Vector2>().x * Time.deltaTime * torque * transform.up));
        if (jumpAction.IsPressed() && spiderIK.Grounded && spiderIK.StickToGround && canJump){
            spiderIK.StickToGround = false;
            rb.AddForce(CameraOffset.TransformDirection(Vector3.up + Vector3.back*0.5f)*jumpSpeed);
            IEnumerator TurnOnLater(){
                canJump = false;
                yield return new WaitForSeconds(0.5f);
                float timeoutTime = Time.time;
                yield return new WaitUntil(() => spiderIK.Grounded || Time.time - timeoutTime > 2);
                yield return new WaitForSeconds(0.05f);
                spiderIK.StickToGround = true;
                yield return new WaitForSeconds(0.4f);
                canJump = true;
            }
            StartCoroutine(TurnOnLater());
        }
        if (attackAction.IsInProgress() && ValueManager.Instance.Fuel > 0){
            if(fireParticle.isStopped){
                fireParticle.Play();
                dustParticle.Play();
            }
            if(fireParticle.isEmitting){
                ValueManager.Instance.Fuel-=Time.deltaTime*FlamethrowerRate;
                for(int i = -15; i < 15; i+=2){
                    if(Physics.Raycast(FlameRaycastPoint.position + FlameRaycastPoint.TransformDirection(new Vector3(i/1.5f,0,0)), Quaternion.AngleAxis(i, Vector3.up) * FlameRaycastPoint.forward, out RaycastHit hit, 10, ShootLayers)){
                        ShootPoint = hit.point;
                        if(hit.collider.gameObject.layer == 9 && GuardScript.CachedGuards.ContainsKey(hit.collider.transform.parent.name)){
                            GuardScript.CachedGuards[hit.collider.transform.parent.name].Damage(EnemyDamageRate*Time.deltaTime);
                            break;
                        }
                    }
                }
            }
        }else{
            if(fireParticle.isPlaying){
                fireParticle.Stop();
                dustParticle.Stop();
            }
        }
    }
    Vector3 ShootPoint;
    void OnDrawGizmos()
    {
        Gizmos.color = Color.red;
        Gizmos.DrawLine(FlameRaycastPoint.position, ShootPoint);
    }
}
