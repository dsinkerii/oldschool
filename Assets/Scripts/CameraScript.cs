using UnityEngine;

public class CameraScript : MonoBehaviour
{
    public Camera Cam;
    public Transform SpiderBody;
    public float FollowSpeed=0.5f;
    public float CameraDistance = 10;
    public float Size = 10;
    public Transform Sphere;
    Vector3 kill;
    [SerializeField] LayerMask ShootLayers;
    void FixedUpdate()
    {
        // center on the body
        Cam.transform.position = Vector3.Lerp(Cam.transform.position,SpiderBody.position,FollowSpeed)-Cam.transform.forward*CameraDistance;
        if (Physics.Raycast(transform.position, transform.forward, out RaycastHit hit, Mathf.Infinity, ShootLayers)){
            kill = hit.point;
            if(hit.collider.gameObject.layer != 6){
                Sphere.transform.localScale = Vector3.Lerp(Sphere.transform.localScale, new Vector3(Size,Size,Size),0.2f);
            }else{
                Sphere.transform.localScale = Vector3.Lerp(Sphere.transform.localScale, new Vector3(0,0,0),0.2f);
            }
        }else{
            kill = transform.position;  
        }
    }

    void OnDrawGizmos()
    {
        Gizmos.color = Color.yellow;
        Gizmos.DrawLine(transform.position,kill);
    }
}
