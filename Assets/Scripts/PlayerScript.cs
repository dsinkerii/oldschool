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
    public bool IsDead;
    public float flamethrowerVol;
    [SerializeField] LayerMask ShootLayers;
    bool canJump = true;
    public AudioSource flamethrowerAudio;

    public void Damage(float val){
        ValueManager.Instance.HP=Mathf.Max(ValueManager.Instance.HP-val,0);
        if(!IsDead)
            AudioManager.Instance.PlaySound("hitHurt");
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
        if(!IsDead){
            Vector3 currentPos = transform.position;
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
                    AudioManager.Instance.PlaySound("jump");
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
            if (transform.position.magnitude < 0.1f && currentPos.magnitude > 1f){
                transform.position = currentPos;
                rb.linearVelocity = Vector3.zero;
                rb.angularVelocity = Vector3.zero;
            }
        }
        if (!IsDead && attackAction.IsInProgress() && ValueManager.Instance.Fuel > 0){ // we dont just do return on death, because we need to turn off particles
            if(fireParticle.isStopped){
                fireParticle.Play();
                dustParticle.Play();
                flamethrowerVol = 1;
            }
            else if(fireParticle.isEmitting){
                ValueManager.Instance.Fuel-=Time.deltaTime*FlamethrowerRate;
                for(int i = 0; i < 10; i++){ // 10 tries
                    if(Physics.Raycast(FlameRaycastPoint.position + FlameRaycastPoint.TransformDirection(new Vector3(Random.Range(-8,8),0,0)), Quaternion.AngleAxis(i, Vector3.up) * FlameRaycastPoint.forward, out RaycastHit hit, 10, ShootLayers)){
                        ShootPoint = hit.point;
                        if(hit.collider.gameObject.layer == 9 && GuardScript.CachedGuards.ContainsKey(hit.collider.transform.parent.name)){
                            if(GuardScript.CachedGuards[hit.collider.transform.parent.name].IsDead) continue; // ignore this one
                            GuardScript.CachedGuards[hit.collider.transform.parent.name].Damage(EnemyDamageRate*Time.deltaTime);
                            AudioManager.Instance.PlaySound("successHit");
                            break;
                        }
                        if(hit.collider.gameObject.layer == 13){
                            if(!ServerScript.CachedServers.ContainsKey(hit.collider.transform.name)){
                                Debug.Log("not in list");
                                continue;
                            }
                            if(ServerScript.CachedServers[hit.collider.transform.name].IsDead) continue; // ignore this one
                            ServerScript.CachedServers[hit.collider.transform.name].Damage(EnemyDamageRate*Time.deltaTime);
                            AudioManager.Instance.PlaySound("successHit");
                            break;
                        }
                    }
                }
            }
        }else{
            if(fireParticle.isPlaying){
                fireParticle.Stop();
                dustParticle.Stop();
                flamethrowerVol = 0;
            }
        }
        flamethrowerAudio.volume = Mathf.Lerp(flamethrowerAudio.volume, flamethrowerVol*0.25f, Time.deltaTime*5f);
    }
    Vector3 ShootPoint;
    void OnDrawGizmos()
    {
        Gizmos.color = Color.red;
        Gizmos.DrawLine(FlameRaycastPoint.position, ShootPoint);
    }
}
