using UnityEngine;
using System.Threading;
using System.Collections;
using Unity.Jobs;
using System.Collections.Generic;
using System.Linq;
using UnityEngine.UI;
using TMPro;
public class GameManager : MonoBehaviour
{
    public Transform PlayerObj;
    public static GameManager Instance;
    [SerializeReference] RoomGenerator rgRef;
    [SerializeReference] Room fuelRoom1;
    [SerializeReference] Room fuelRoom2;
    [SerializeReference] Room Start;
    [SerializeReference] Room End;
    [SerializeReference] Room ServerRoom;
    public float SafeSpace = 40;
    [SerializeReference] float SafeSpaceInternal = 40;
    public SpiderIK spiderIK;
    public PlayerScript playerScript;
    public GameObject AIPrefab;
    public GameObject ExitPrefab;
    public GameObject FuelPrefab;
    public List<GuardScript> Guards;
    public Dictionary<Room,Bounds> walkRooms = new();
    [SerializeField] RawImage fogMask;
    [SerializeField] float revealRadius = 15f;
    [SerializeField] float updateInterval = 0.5f;
    [SerializeField] Color fogColor = Color.black;
    [SerializeField] int fixedGuardCount = 5;
    [SerializeField] float minDistanceFromPlayer = 25f;
    
    private Texture2D fogTexture;
    private Vector2Int mapSize;
    private Vector2Int worldSize;
    private Coroutine fogUpdateCoroutine;
    private GameObject currentExitRoom;
    public GameObject ServerPrefab;
    public Material PlatformMaterial;
    public TextMeshProUGUI stats;
    public int levelCounter;
    public int MaxGuards;
    public int MaxServers;
    System.Random rnd = new();
    public int AIsKilled => MaxGuards - GuardScript.CachedGuards.Count();
    public int ServersKilled => MaxServers - ServerScript.CachedServers.Count();
    
    void Awake(){
        spiderIK.StickToGround = false;
        Instance = this;
        StartCoroutine(StartFrameLate());
    }
    [ContextMenu("resetlevel")]
    public void ResetLevel(){
        levelCounter++;
        Debug.Log("resetting level...");
        
        if (fogUpdateCoroutine != null){
            StopCoroutine(fogUpdateCoroutine);
            fogUpdateCoroutine = null;
        }
        CleanupGuards();
        if (currentExitRoom != null){
            DestroyImmediate(currentExitRoom);
            currentExitRoom = null;
        }
        ResetPlayer();
        ClearRoomReferences();
        ResetFogMap();
        
        StartCoroutine(StartFrameLate());
    }
    void FixedUpdate()
    {
        SafeSpaceInternal=Mathf.Max(0,SafeSpaceInternal-0.5f);
        stats.text = $"lvl: {levelCounter}\nAIs: {GuardScript.CachedGuards.Count()}/{MaxGuards}\nservers: {ServerScript.CachedServers.Count()}/{MaxServers}";
    }

    void CleanupGuards(){
        foreach(var guard in Guards){
            if(guard != null && guard.gameObject != null){
                DestroyImmediate(guard.gameObject);
            }
        }
        Guards.Clear();
        
        var guardsParent = GameObject.Find("guards");
        if(guardsParent != null){
            DestroyImmediate(guardsParent);
        }
    }
    
    void ResetPlayer(){
        PlayerObj.gameObject.SetActive(false);
        spiderIK.StickToGround = false;
        spiderIK.enabled = false;
        playerScript.enabled = false;
    }
    
    void ClearRoomReferences(){
        fuelRoom1 = null;
        fuelRoom2 = null;
        Start = null;
        End = null;
        ServerRoom = null;
        Corridor.CleanRefs();
        walkRooms.Clear();
        MaxGuards = 0;
        MaxServers = 0;
        GuardScript.CachedGuards.Clear();
        ServerScript.CachedServers.Clear();
    }
    
    IEnumerator StartFrameLate(){
        ClearRoomReferences(); // just to make sure
        // difficulty
        fixedGuardCount = levelCounter switch
        {
            0 => 5,
            int n when (n > 0 && n < 10) => 5 + levelCounter,     // never knew this holy moly
            int n when (n >= 10 && n < 15) => levelCounter * 2 - 4,
            _ => 40,
        };
        RoomGenerator.SizeMult = levelCounter >= 50 ? 0.75f : 1;
        GuardScript.DamagePlayerMult = levelCounter switch{
            0 => 0.5f,
            int n when n > 0 && n < 10 => 0.75f,
            int n when n > 10 && n < 15 => 1,
            _ => 1.5f
        };
        bool FirstFrameRun = true;
        while(FirstFrameRun || Corridor.AllRooms.Count < 6){ // we really need at least 6 rooms
            yield return new WaitForEndOfFrame();
            rgRef.BakeMesh();
            FirstFrameRun = false; // we must run atleast once when we run this
        }

        yield return new WaitUntil(() => Corridor.AllRooms != null && Corridor.AllRooms.Count() >= 6);
        Debug.Log("rooms loaded");
        
        var copyRooms = new Dictionary<Room,Bounds>();
        foreach(var room in MeshGen.allRooms){
            if(!room.Key.IsTunnel){
                copyRooms.Add(room.Key,room.Value);
            }
        }
        copyRooms = copyRooms.OrderBy((item) => rnd.Next()).ToDictionary(t => t.Key, t => t.Value); // shuffle

        var biggestRoom = Room.GetBiggestRoom(Corridor.AllRooms);
        ServerRoom = biggestRoom; 
        copyRooms.Remove(biggestRoom);
        walkRooms = new Dictionary<Room,Bounds>(MeshGen.allRooms);

        Start = copyRooms.ElementAt(0).Key;
        copyRooms.Remove(copyRooms.ElementAt(0).Key);
        
        startPos = MeshGen.allRooms[Start].center;
        startSize = MeshGen.allRooms[Start].size;
        
        
        End = copyRooms.ElementAt(0).Key;
        copyRooms.Remove(copyRooms.ElementAt(0).Key);
        currentExitRoom = Instantiate(ExitPrefab);
        currentExitRoom.transform.parent = MeshGen.CombinedMesh.transform;
        currentExitRoom.transform.position = MeshGen.allRooms[End].center;
        currentExitRoom.SetActive(true);

        if(copyRooms.Count >= 2){
            fuelRoom1 = copyRooms.ElementAt(0).Key;
            CreateFuel(MeshGen.allRooms[fuelRoom1].center);
            copyRooms.Remove(copyRooms.ElementAt(0).Key);
            fuelRoom2 = copyRooms.ElementAt(0).Key;
            CreateFuel(MeshGen.allRooms[fuelRoom2].center);
            copyRooms.Remove(copyRooms.ElementAt(0).Key);
        }
        CreateServerFarm();
        MeshGen.PrepareForAI();
        SpawnFixedGuards(copyRooms);

        PlayerObj.position = startPos + Vector3.up*2;
        PlayerObj.gameObject.SetActive(true);
        spiderIK.StickToGround = true;
        spiderIK.enabled = true;
        spiderIK.ResetLegTargets();
        playerScript.enabled = true;

        InitializeFogMap(RoomGenerator.Instance.map.texture.width, RoomGenerator.Instance.map.texture.height);
    }
    void CreateFuel(Vector3 fuelBounds){
        var fuelObj = Instantiate(FuelPrefab);
        fuelObj.transform.parent = MeshGen.CombinedMesh.transform;
        fuelObj.transform.position = fuelBounds;
        fuelObj.SetActive(true);
    }
    
    void SpawnFixedGuards(Dictionary<Room,Bounds> availableRooms){
        var GuardParent = new GameObject("guards");
        GuardParent.transform.parent = MeshGen.CombinedMesh.transform;
        
        var suitableRooms = new List<KeyValuePair<Room, Bounds>>();
        
        foreach(var kvp in availableRooms){
            if(kvp.Key.IsTunnel) continue;
            if(Vector3.Distance(startPos, kvp.Value.center) < minDistanceFromPlayer) continue;
            suitableRooms.Add(kvp);
        }
        SafeSpaceInternal = SafeSpace;
        
        if(suitableRooms.Count == 0){
            foreach(var kvp in availableRooms){
                if(kvp.Key.IsTunnel) continue;
                if(Vector3.Distance(startPos, kvp.Value.center) < SafeSpace) continue;
                suitableRooms.Add(kvp);
            }
        }
        
        if(suitableRooms.Count == 0){
            foreach(var kvp in availableRooms){
                if(kvp.Key.IsTunnel) continue;
                suitableRooms.Add(kvp);
            }
        }
        
        suitableRooms = suitableRooms.OrderBy((item) => rnd.Next()).ToList();
        
        for(int i = 0; i < fixedGuardCount; i++){
            if(suitableRooms.Count == 0)break;
            
            var roomToUse = suitableRooms[i % suitableRooms.Count];
            
            GameObject newGuard = Instantiate(AIPrefab, GuardParent.transform);
            MaxGuards++;
            
            Vector3 basePosition = roomToUse.Value.center;
            if(i >= suitableRooms.Count){
                Vector3 randomOffset = new(
                    Random.Range(-2f, 2f), 
                    0, 
                    Random.Range(-2f, 2f)
                );
                basePosition += randomOffset;
            }
            
            newGuard.transform.position = new(basePosition.x, 0.12f, basePosition.z);
            Guards.Add(newGuard.GetComponent<GuardScript>());
            newGuard.SetActive(true);
        }
    }
    [SerializeField] float platformPadding = 6;
    [SerializeField] float serverPadding = 1f;
    void CreateServerFarm() {
        if (ServerRoom == null || ServerPrefab == null) return;
        
        Bounds roomBounds = MeshGen.allRooms[ServerRoom];
        Vector3 roomCenter = roomBounds.center;
        Vector3 roomSize = roomBounds.size;
        
        float platformHeight = 0.2f;
        Vector3 platformSize = new(roomSize.x - platformPadding, platformHeight, roomSize.z - platformPadding);
        Vector3 platformPos = new(roomCenter.x, roomCenter.y - roomSize.y/2f + platformHeight/2f, roomCenter.z);
        
        GameObject platform = GameObject.CreatePrimitive(PrimitiveType.Cube);
        platform.name = "platform";
        platform.transform.position = platformPos;
        platform.transform.localScale = platformSize;
        platform.transform.parent = MeshGen.CombinedMesh.transform;
        
        if (PlatformMaterial != null) {
            platform.GetComponent<MeshRenderer>().material = PlatformMaterial;
        }
        
        float serverSize = 3f;
        float walkwayWidth = 4f;
        float availableWidth = platformSize.x - 1f; 
        float availableDepth = platformSize.z - 1f;
        
        int serversPerRow = Mathf.FloorToInt(availableWidth / (serverSize + serverPadding));
        float totalRowWidth = serversPerRow * serverSize + (serversPerRow - 1) * serverPadding;
        
        int maxRows = Mathf.FloorToInt(availableDepth / (serverSize + walkwayWidth));
        
        GameObject serverParent = new("farm");
        serverParent.transform.parent = platform.transform;
        
        Vector3 serverStartPos = new(
            platformPos.x - totalRowWidth/2f + serverSize/2f,
            platformPos.y + platformHeight/2f + serverSize/2f-1,
            platformPos.z - availableDepth/2f + serverSize/2f
        );
        
        for (int row = 0; row < maxRows; row++) {
            for (int col = 0; col < serversPerRow; col++) {
                MaxServers++;
                Vector3 serverPos = new(
                    serverStartPos.x + col * (serverSize + serverPadding),
                    serverStartPos.y,
                    serverStartPos.z + row * (serverSize + walkwayWidth)
                );
                
                GameObject server = Instantiate(ServerPrefab, serverParent.transform);
                if(Random.Range(0, 10) == 2){ // random number
                    server.GetComponent<ServerScript>().IsEvilServer = true;
                }
                server.transform.position = serverPos;
                server.SetActive(true);
            }
        }
    }
    System.Random Walkrnd = new();
    public Bounds GetRoomToGoAt(){
        int[] CheckValues = new int[walkRooms.Count];
        for(int i = 0; i < walkRooms.Count; i++){
            CheckValues[i] = i; // crazy i know
        }
        CheckValues = CheckValues.OrderBy((item) => Walkrnd.Next()).ToArray(); // shuffle

        for(int i = 0; i < walkRooms.Count; i++){
            var kvpToCheck = walkRooms.ElementAt(CheckValues[i]);
            if(Vector3.Distance(startPos, kvpToCheck.Value.center) < SafeSpaceInternal) continue;
            //fits all criterias, return this one
            return walkRooms.ElementAt(CheckValues[i]).Value;
        }
        return walkRooms.ElementAt(3).Value;
    }
    Vector3 startPos = new();
    Vector3 startSize = new();
    void InitializeFogMap(int width, int height){
        mapSize = new Vector2Int(width, height);
        
        if (MeshGen.allRooms != null && MeshGen.allRooms.Count > 0) {
            Bounds worldBounds = new();
            bool first = true;
            foreach (var room in MeshGen.allRooms) {
                if (first) {
                    worldBounds = room.Value;
                    first = false;
                } else {
                    worldBounds.Encapsulate(room.Value);
                }
            }
            worldSize = new(
                Mathf.RoundToInt(worldBounds.size.x),
                Mathf.RoundToInt(worldBounds.size.z)
            );
        } else {
            worldSize = new Vector2Int(width, height);
        }
        
        fogTexture = new Texture2D(width, height, TextureFormat.RGBA32, false){filterMode = FilterMode.Point};
        
        Color32[] pixels = new Color32[width * height];
        for (int i = 0; i < pixels.Length; i++){
            pixels[i] = fogColor;
        }
        fogTexture.SetPixels32(pixels);
        fogTexture.Apply();
        
        if (fogMask != null){
            fogMask.texture = fogTexture;
            fogMask.gameObject.SetActive(true);
        }
        
        if (fogUpdateCoroutine != null){
            StopCoroutine(fogUpdateCoroutine);
        }
        fogUpdateCoroutine = StartCoroutine(UpdateFogMap());
    }
    
    IEnumerator UpdateFogMap(){
        while (PlayerObj != null){
            yield return new WaitForSeconds(updateInterval);
            if (PlayerObj == null) {
                Debug.LogError("PlayerObj is null");
            }
            
            RevealAroundPlayer();
        }
    }
    
    void RevealAroundPlayer(){
        if (fogTexture == null || PlayerObj == null) return;
        Vector3 playerWorldPos = PlayerObj.position;
        
        Vector2Int texturePos = WorldToTextureCoords(playerWorldPos);
        
        float textureRadius = revealRadius / worldSize.x * mapSize.x;
        
        RevealCircle(texturePos, textureRadius);
    }
    
    Vector2Int WorldToTextureCoords(Vector3 worldPos){
        float normalizedX = Mathf.Clamp01(worldPos.x / worldSize.x);
        float normalizedZ = Mathf.Clamp01(worldPos.z / worldSize.y);
        
        int textureX = Mathf.RoundToInt(normalizedX * mapSize.x);
        int textureY = Mathf.RoundToInt(normalizedZ * mapSize.y);
        
        return new Vector2Int(textureX, textureY);
    }
    
    void RevealCircle(Vector2Int center, float radius){
        int minX = Mathf.Max(0, Mathf.FloorToInt(center.x - radius));
        int maxX = Mathf.Min(mapSize.x - 1, Mathf.CeilToInt(center.x + radius));
        int minY = Mathf.Max(0, Mathf.FloorToInt(center.y - radius));
        int maxY = Mathf.Min(mapSize.y - 1, Mathf.CeilToInt(center.y + radius));
        
        bool needsUpdate = false;
        for (int x = minX; x <= maxX; x++){
            for (int y = minY; y <= maxY; y++) {
                float distance = Vector2.Distance(new Vector2(x, y), new Vector2(center.x, center.y));
                
                if (distance <= radius){
                    Color currentColor = fogTexture.GetPixel(x, y);
                    
                    if (currentColor.a > 0.1f){
                        int alpha = (int)Mathf.Clamp01((radius - distance) / (radius * 0.3f));
                        alpha = 1 - alpha;
                        
                        Color newColor = new(fogColor.r, fogColor.g, fogColor.b, alpha * 0.2f);
                        fogTexture.SetPixel(x, y, newColor);
                        needsUpdate = true;
                    }
                }
            }
        }
        
        if (needsUpdate){
            fogTexture.Apply();
        }
    }
    
    public void ResetFogMap() {
        if (fogTexture != null){
            Color32[] pixels = new Color32[fogTexture.width * fogTexture.height];
            for (int i = 0; i < pixels.Length; i++){
                pixels[i] = fogColor;
            }
            fogTexture.SetPixels32(pixels);
            fogTexture.Apply();
        }
    }
    
    void OnDestroy(){
        if (fogUpdateCoroutine != null){
            StopCoroutine(fogUpdateCoroutine);
        }
        
        if (fogTexture != null){
            DestroyImmediate(fogTexture);
        }
    }
    void OnDrawGizmosSelected(){
        if(walkRooms.Count > 0){
            foreach(var kvp in walkRooms){
                if(kvp.Key.IsTunnel) continue;
                Gizmos.color = Color.magenta;
                Gizmos.DrawCube(kvp.Value.center, kvp.Value.size);
                Gizmos.DrawSphere(kvp.Value.center, 0.5f);
            }
        }
        
        if(MeshGen.allRooms != null){
            Gizmos.color = Color.gray;
            foreach(var room in MeshGen.allRooms){
                Gizmos.DrawWireCube(room.Value.center, room.Value.size);
            }
        }
        
        if(PlayerObj != null && PlayerObj.gameObject.activeInHierarchy){
            Gizmos.color = Color.white;
            Gizmos.DrawSphere(PlayerObj.position, 1f);
        }
        
        if(Guards != null){
            Gizmos.color = Color.orange;
            foreach(var guard in Guards){
                if(guard != null){
                    Gizmos.DrawSphere(guard.transform.position, 0.8f);
                }
            }
        }
    }
}