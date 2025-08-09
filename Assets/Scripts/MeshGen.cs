using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.ProBuilder;
using UnityEngine.ProBuilder.MeshOperations;

public class MeshGen : MonoBehaviour
{
    public static MeshGen Instance;
    public Material floorMat, wallMat;
    public int Space = 2;
    public float wallThickness = 2;
    void Start() => Instance = this;
    public float vertexMergeDistance = 0.001f;
    private static List<Room> corridors = new();
    private static readonly List<ProBuilderMesh> meshes = new();
    private static bool[,] floorMap;

    public static void GenerateMesh(Corridor rootRoom, Vector2Int size, float wallHeight){
        corridors.Clear();
        meshes.Clear();
        CreateCorridors(rootRoom);
        CreateFloor(rootRoom);
        CreateWalls(rootRoom, size, wallHeight);
        PostProcessMeshes();

    }

    //for roomgenerator
    public static Texture2D CreateMap(){
        Vector2Int size = new(floorMap.GetLength(0),floorMap.GetLength(1));
        Texture2D newTex = new(size.x, size.y){filterMode=FilterMode.Point};
        for(int x = 0; x < size.x; x++){
            for(int y = 0; y < size.y; y++){
                newTex.SetPixel(x,y,floorMap[x,y] ? Color.white : Color.black);
            }
        }
        newTex.Apply();
        return newTex;
    }

    static void CreateCorridors(Corridor node){
        if (node.IsLeaf) return;
        CreateCorridors(node.left);
        CreateCorridors(node.right);
        
        var room1 = GetRandomRoom(node.left);
        var room2 = GetRandomRoom(node.right);
        var p1 = new Vector2Int(Random.Range(room1.Pos.x, room1.Pos.x + room1.Size.x), Random.Range(room1.Pos.y, room1.Pos.y + room1.Size.y));
        var p2 = new Vector2Int(Random.Range(room2.Pos.x, room2.Pos.x + room2.Size.x), Random.Range(room2.Pos.y, room2.Pos.y + room2.Size.y));

        if(Dice()){
            CreateHorizontalCorridor(p1.x, p2.x, p1.y);
            CreateVerticalCorridor(p1.y, p2.y, p2.x);
        } else {
            CreateVerticalCorridor(p1.y, p2.y, p1.x);
            CreateHorizontalCorridor(p1.x, p2.x, p2.y);
        }
    }

    static void PostProcessMeshes(){
        CombineObjects();
    }

    //////////////////////
    /// help functions /// : GenerateMeshes
    //////////////////////
    
    static bool Dice() => Random.value > 0.5f;
    static Room GetRandomRoom(Corridor node) => node.IsLeaf ? node.room : GetRandomRoom(Dice() ? node.left : node.right);
    static void CreateHorizontalCorridor(int x1, int x2, int y) => corridors.Add(new Room { Pos = new Vector2Int(Mathf.Min(x1, x2), y), Size = new Vector2Int(Mathf.Abs(x2 - x1) + Instance.Space, Instance.Space) });
    static void CreateVerticalCorridor(int y1, int y2, int x) => corridors.Add(new Room { Pos = new Vector2Int(x, Mathf.Min(y1, y2)), Size = new Vector2Int(Instance.Space, Mathf.Abs(y2 - y1) + Instance.Space) });

    //////////////////////
    /// help functions /// : CreateFloor
    //////////////////////

    static void CreateFloor(Corridor rootNode){
        var parent = new GameObject("Floor").transform;
        parent.parent = RoomGenerator.Instance.BaseMesh.transform;
        CreateFloorsForRooms(rootNode, parent);
        foreach(var corridor in corridors) CreateFloorSection(corridor, parent);
    }

    static void CreateFloorsForRooms(Corridor node, Transform parent){
        if(node == null) return;
        if(node.IsLeaf && node.room != null) CreateFloorSection(node.room, parent);
        else { CreateFloorsForRooms(node.left, parent); CreateFloorsForRooms(node.right, parent); }
    }

    static void CreateFloorSection(Room room, Transform parent){
        var floor = ShapeGenerator.CreateShape(ShapeType.Cube).gameObject;
        floor.transform.parent = parent;
        floor.transform.position = new Vector3(room.Pos.x + room.Size.x/2f, 0, room.Pos.y + room.Size.y/2f);
        floor.transform.localScale = new Vector3(room.Size.x, 0.1f, room.Size.y);
        floor.GetComponent<MeshRenderer>().material = Instance.floorMat;
        meshes.Add(floor.GetComponent<ProBuilderMesh>());
    }

    //////////////////////
    /// help functions /// : CreateWalls
    //////////////////////
    
    static void CreateWalls(Corridor rootRoom, Vector2Int size, float wallHeight){
        var wallParent = new GameObject("Walls").transform;
        wallParent.parent = RoomGenerator.Instance.BaseMesh.transform;
        
        floorMap = new bool[size.x, size.y];
        bool[,] wallMap = new bool[size.x, size.y];
        
        MarkFloorAreas(rootRoom, floorMap, size);
        foreach(var corridor in corridors) MarkFloorArea(corridor, floorMap, size);

        for(int x = 0; x < size.x; x++)
            for(int y = 0; y < size.y; y++)
                if(!floorMap[x,y] && (IsAdjacentToFloor(x, y, floorMap, size) || IsBoundaryWall(x, y, floorMap, size)))
                    wallMap[x, y] = true;

        var wallSegments = FindWallSegments(wallMap, size);
        foreach(var segment in wallSegments) CreateWallSegment(segment, wallParent, wallHeight);
    }
    
    static List<WallSegment> FindWallSegments(bool[,] wallMap, Vector2Int size){
        var segments = new List<WallSegment>();
        bool[,] processed = new bool[size.x, size.y];
        
        for(int y = 0; y < size.y; y++){
            for(int x = 0; x < size.x; x++){
                if(wallMap[x, y] && !processed[x, y]) {
                    var horizontalSegment = CreateHorizontalSegment(x, y, wallMap, processed, size);
                    if(horizontalSegment != null){ segments.Add(horizontalSegment); continue; }
                    
                    var verticalSegment = CreateVerticalSegment(x, y, wallMap, processed, size);
                    if(verticalSegment != null){ segments.Add(verticalSegment); continue; }
                    
                    // if neither worked, create single wall
                    segments.Add(new WallSegment(new Vector2Int(x, y), new Vector2Int(x, y), true));
                    processed[x, y] = true;
                }
            }
        }
        return segments;
    }
    
    static WallSegment CreateHorizontalSegment(int startX, int startY, bool[,] wallMap, bool[,] processed, Vector2Int size) {
        int endX = startX;
        while(endX + 1 < size.x && wallMap[endX + 1, startY] && !processed[endX + 1, startY]) endX++;
        
        if(endX > startX){
            for(int x = startX; x <= endX; x++) processed[x, startY] = true;
            return new WallSegment(new Vector2Int(startX, startY), new Vector2Int(endX, startY), true);
        }
        return null;
    }
    
    static WallSegment CreateVerticalSegment(int startX, int startY, bool[,] wallMap, bool[,] processed, Vector2Int size){
        int endY = startY;
        while(endY + 1 < size.y && wallMap[startX, endY + 1] && !processed[startX, endY + 1]) endY++;
        
        if(endY > startY){
            for(int y = startY; y <= endY; y++) processed[startX, y] = true;
            return new WallSegment(new Vector2Int(startX, startY), new Vector2Int(startX, endY), false);
        }
        return null;
    }
    
    static void CreateWallSegment(WallSegment segment, Transform parent, float wallHeight){
        var wall = ShapeGenerator.CreateShape(ShapeType.Cube).gameObject;
        wall.transform.parent = parent;
        wall.GetComponent<MeshRenderer>().material = Instance.wallMat;
        
        if(segment.isHorizontal){
            float length = segment.end.x - segment.start.x + 1;
            wall.transform.position = new Vector3(segment.start.x + length * 0.5f - 0.5f, wallHeight * 0.5f, segment.start.y);
            wall.transform.localScale = new Vector3(length, wallHeight, Instance.wallThickness);
        }
        else{
            float length = segment.end.y - segment.start.y + 1;
            wall.transform.position = new Vector3(segment.start.x, wallHeight * 0.5f, segment.start.y + length * 0.5f - 0.5f);
            wall.transform.localScale = new Vector3(Instance.wallThickness, wallHeight, length);
        }
        meshes.Add(wall.GetComponent<ProBuilderMesh>());
    }

    static void MarkFloorAreas(Corridor node, bool[,] floorMap, Vector2Int size){
        if(node == null) return;
        if(node.IsLeaf && node.room != null) MarkFloorArea(node.room, floorMap, size);
        else { MarkFloorAreas(node.left, floorMap, size); MarkFloorAreas(node.right, floorMap, size); }
    }

    static void MarkFloorArea(Room room, bool[,] floorMap, Vector2Int size){
        for(int x = room.Pos.x; x < room.Pos.x + room.Size.x && x < size.x; x++)
            for(int y = room.Pos.y; y < room.Pos.y + room.Size.y && y < size.y; y++)
                if(x >= 0 && y >= 0) floorMap[x, y] = true;
    }

    static bool IsAdjacentToFloor(int x, int y, bool[,] floorMap, Vector2Int size){
        return (x > 0 && floorMap[x-1, y]) || (x < size.x-1 && floorMap[x+1, y]) || 
               (y > 0 && floorMap[x, y-1]) || (y < size.y-1 && floorMap[x, y+1]);
    }

    static bool IsBoundaryWall(int x, int y, bool[,] floorMap, Vector2Int size){
        return (x == 0 || x == size.x-1 || y == 0 || y == size.y-1) && 
               ((x > 0 && floorMap[x-1, y]) || (x < size.x-1 && floorMap[x+1, y]) || 
                (y > 0 && floorMap[x, y-1]) || (y < size.y-1 && floorMap[x, y+1]));
    }

    //////////////////////
    /// help functions /// : PostProcessMeshes
    //////////////////////
    
    static void CombineObjects(){
        var combinedMeshes = CombineMeshes.Combine(meshes);
        if (combinedMeshes != null && combinedMeshes.Count > 0){
            var combined = combinedMeshes[0];
            combined.transform.SetPositionAndRotation(RoomGenerator.Instance.BaseMesh.transform.position, RoomGenerator.Instance.BaseMesh.transform.rotation);
            combined.transform.localScale = RoomGenerator.Instance.BaseMesh.transform.localScale;
            
            var oldBaseMesh = RoomGenerator.Instance.BaseMesh;
            RoomGenerator.Instance.BaseMesh = combined;
            
            if (oldBaseMesh != null ? oldBaseMesh.gameObject : null != null) DestroyImmediate(oldBaseMesh.gameObject);
            foreach (var mesh in meshes) 
                if (mesh != null ? mesh.gameObject : null != null && mesh != combined) DestroyImmediate(mesh.gameObject);
            
            combined.ToMesh();
            combined.Refresh();
            combined.transform.parent = RoomGenerator.Instance.transform;
            var collider = combined.gameObject.AddComponent<MeshCollider>();
            collider.sharedMesh = combined.GetComponent<MeshFilter>().mesh;
        }
    }
}