using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.AI;
public class GuardScript : MonoBehaviour
{
    public NavMeshAgent NavMesh;
    public Bounds Goto;
    [SerializeField] NavMeshPath path;
    [SerializeField] bool IsActive;
    [SerializeField] float RotateRate; // deg in sec
    [SerializeField] float walkSpeed = 1;
    [SerializeField] float DamageRate = 1;
    [SerializeField] float Health = 50;
    public bool IsDead;
    public bool AggressiveToPlayer;
    [SerializeField] ParticleSystem sparks;
    [SerializeField] ParticleSystem Explosion;
    [SerializeField] JustShake shake;
    [SerializeField] GameObject ViewField;
    [SerializeField] Transform shootPoint;
    [SerializeField] ParticleSystem ShootTrail;
    [SerializeField] LayerMask ShootLayers;
    [SerializeField] int Shootrate = 3;
    [SerializeField] float fuelAdd = 12;
    [SerializeField] float hpAdd = 35;
    [SerializeField] int scoreAdd = 100;
    [SerializeField] float FinishTimeWait = 4;
    public static float DamagePlayerMult = 1;
    public bool FinishedWalking;
    float finishTimedelta = 0;
    public AudioSource robotShoot;
    void Start(){
        path ??= new();
        MoveIdx = 0;
    }
    public void Damage(float amount){
        Health = Mathf.Max(Health-amount,0);
        if(Health < 40&& !IsDead){
            if(!sparks.isPlaying){
                sparks.Play();
            }
            var emission = sparks.emission;
            emission.rateOverTime = Mathf.Lerp(200,0,Health/40);
            AggressiveToPlayer = true;
        }
        if(Health < 20&& !IsDead){
            shake.Amount = Mathf.Lerp(0.1f,0,Health/20);
        }
        if(Health == 0 && !IsDead){
            IsDead = true;
            NavMesh.enabled = false; // become static
            Explosion.Play();
            AudioManager.Instance.PlaySound("explosion");
            shake.Amount = 0;
            sparks.Stop();
            ViewField.SetActive(false);
            ValueManager.AddFuel(fuelAdd);
            ValueManager.AddScore(scoreAdd);
            ValueManager.AddHp(hpAdd);
            CachedGuards.Remove(gameObject.name); // remove ourselfs from the dict since we dont need it atp
        }
    }
    
    [ContextMenu("setpath")]
    public void SetPath(){
        if(NavMesh.CalculatePath(Goto.center, path)){
            MoveIdx = 0;
        }
    }
    float PlayerPosUpdateTime = 0;
    public Vector3 ShootPoint;
    int shootTick;
    public static Dictionary<string,GuardScript> CachedGuards = new();
    void Awake()
    {
        gameObject.name = System.Guid.NewGuid().ToString();
        CachedGuards.Add(gameObject.name, this); // cache yourself...
    }
    void FixedUpdate(){
        if(path == null || path.corners.Count() == 0 || FinishedWalking){
            if(finishTimedelta > FinishTimeWait){
                Goto = GameManager.Instance.GetRoomToGoAt();
                FinishedWalking = false;
                finishTimedelta = 0;
                SetPath();
            }else{
                finishTimedelta+=1/20f;
            }
        }
        ShootTrail.transform.position = shootPoint.position;  
        if(AggressiveToPlayer && !IsDead && shootTick >= Shootrate){
            shootTick = 0;
            if(ShootTrail.isStopped){
                ShootTrail.Play();
            }
            if(Time.time - PlayerPosUpdateTime > 1 && Vector3.Distance(NavMesh.transform.position, PlayerScript.Instance.playerObject.transform.position) > 2){ // dont update if too close
                if(NavMesh.CalculatePath(PlayerScript.Instance.playerObject.transform.position, path)){
                    MoveIdx = 0;
                }
                PlayerPosUpdateTime = Time.time;
            }
            Vector3 random = Random.insideUnitSphere.normalized / 30;
            if(Physics.Raycast(shootPoint.position, (shootPoint.forward+random).normalized, out RaycastHit hit2, 50, ShootLayers)){
                ShootTrail.transform.position = hit2.point;
                robotShoot.Play();
                if(hit2.collider.gameObject.layer == 9 && CachedGuards.ContainsKey(hit2.collider.transform.parent.name)){ // other guard
                    CachedGuards[hit2.collider.transform.parent.name].AggressiveToPlayer = true;
                }else if(hit2.collider.gameObject.layer == 6){ // player
                    PlayerScript.Instance.Damage(DamageRate*DamagePlayerMult);
                }
            }
        }else{
            if(ShootTrail.isPlaying){
                ShootTrail.Stop();
            }
        }
        if(AggressiveToPlayer && !IsDead)
            shootTick++;
        Move();
        CheckCrowding();
    }
    [SerializeField] List<Transform> nearbyGuards = new();
    [SerializeField] float avoidanceForce = 2f;

    [SerializeField] float crowdCheckTime = 0f;
    [SerializeField] float crowdTimeout = 3f;
    void CheckCrowding(){
        if(nearbyGuards.Count >= 1){
            crowdCheckTime += 1/20f;
            
            if(crowdCheckTime >= crowdTimeout) {
                Goto = GameManager.Instance.GetRoomToGoAt();
                FinishedWalking = false;
                finishTimedelta = 0;
                SetPath();
                crowdCheckTime = 0; 
            }
        }
        else{
            crowdCheckTime = 0;
        }
    }
    Vector3 GetAvoidanceOffset(){
        Vector3 avoidance = Vector3.zero;
        
        foreach(Transform guard in nearbyGuards){
            if(guard == null) continue;
            
            Vector3 diff = transform.position - guard.position;
            float distance = diff.magnitude;
            
            if(distance > 0){
                avoidance += diff.normalized * (avoidanceForce / distance);
            }
        }
        
        return avoidance;
    }
    [SerializeField] int MoveIdx = 0;
    [SerializeField] bool IsOnPoint;
    void Move(){
        // shotgun all bad scenarios
        if(IsDead) return; // gettaouttahere
        if(!IsActive) return; // gettaouttahere
        if(path.corners.Length == 0) return; // no path yet
        if(MoveIdx >= path.corners.Length) {MoveIdx--; return;} // out of bounds
        if(IsOnPoint && MoveIdx == path.corners.Length-1){FinishedWalking = true; return;} // we've finished walking

        //we're good to continue
        if(MoveIdx == 0){
            NavMesh.transform.position = path.corners[MoveIdx];
            IsOnPoint = true; // cant be otherwise
        }
        
        Vector3 uplesscorner = new(path.corners[MoveIdx].x,0,path.corners[MoveIdx].z);
        Vector3 uplesscornernext = new();
        if(MoveIdx < path.corners.Length-1){
            uplesscornernext = new(path.corners[MoveIdx+1].x,0,path.corners[MoveIdx+1].z);
        }
        if(IsOnPoint){ // rotate
            Quaternion rot = Quaternion.LookRotation(uplesscornernext - uplesscorner, Vector3.up);
            NavMesh.transform.rotation = Quaternion.RotateTowards(NavMesh.transform.rotation, rot, RotateRate*(AggressiveToPlayer ? 5 : 1));
            if(Vector3.Distance(path.corners[MoveIdx+1],NavMesh.transform.position) < 0.03f || (NavMesh.transform.forward - (uplesscornernext - uplesscorner).normalized).magnitude < 0.01f){
                NavMesh.transform.rotation = NavMesh.transform.rotation;
                MoveIdx++;
                IsOnPoint = false; // done, next point
            }
        }else{
            if(Vector3.Distance(path.corners[MoveIdx-1],NavMesh.transform.position) <= Vector3.Distance(path.corners[MoveIdx],path.corners[MoveIdx-1])-.01){ 
                if(!(Vector3.Distance(NavMesh.transform.position, PlayerScript.Instance.playerObject.transform.position) < 10 && AggressiveToPlayer)){
                    Vector3 targetPos = path.corners[MoveIdx] + GetAvoidanceOffset();
                    NavMesh.transform.position = Vector3.MoveTowards(NavMesh.transform.position, targetPos, walkSpeed * (AggressiveToPlayer ? 4 : 1)/20);
                }else{
                }
            }else{
                NavMesh.transform.position = path.corners[MoveIdx];
                IsOnPoint = true;
            }
        }
    }
    void OnTriggerEnter(Collider other){
        if(other.gameObject.layer == 6)  {
            AggressiveToPlayer = true;
        }
        else if(other.gameObject.layer == 9){ // other guard
            nearbyGuards.Add(other.transform.parent);
        }
    }

    void OnTriggerStay(Collider other){
        if(other.gameObject.layer == 6) {
            AggressiveToPlayer = true;
        }
    }

    void OnTriggerExit(Collider other) {
        if(other.gameObject.layer == 9){
            nearbyGuards.Remove(other.transform.parent);
        }
    }
    void OnDestroy(){
        if(!IsDead)
        CachedGuards.Remove(gameObject.name);
    }
    void OnDrawGizmosSelected(){
        if(path == null) return;
        Gizmos.color = Color.yellow;
        for( int i = 0; i < path.corners.Length-1; i++ ){
            Gizmos.DrawLine(path.corners[i], path.corners[i+1]);
        }
        Gizmos.color = Color.green;
        Gizmos.DrawLine(NavMesh.transform.position, PlayerScript.Instance.playerObject.transform.position);
    }
}
