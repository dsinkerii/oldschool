using System.Collections.Generic;
using UnityEngine;
using UnityEngine.ProBuilder;
using UnityEngine.ProBuilder.MeshOperations;

public class MeshGen : MonoBehaviour
{
    public Material defaultMaterial;
    public GameObject masterMesh;
    public static MeshGen Instance;
    void Start(){
        Instance = this;
    }
    static readonly List<ProBuilderMesh> RawObjects = new();
    public static void GenerateMesh(Corridor root)
    {
        GameObject masterMesh = Instance.masterMesh;
        GenerateMeshes(root, masterMesh.transform);
        LocalCombineMeshes(masterMesh);
    }

    static void LocalCombineMeshes(GameObject masterMesh){
        CombineMeshes.Combine(RawObjects, masterMesh.GetComponent<ProBuilderMesh>());
        //pbm.SetMaterial(pbm.faces,Instance.defaultMaterial); //apply to all
    }

    static void GenerateMeshes(Corridor corridor, Transform parent){
        if (corridor == null) return;

        if (corridor is Room){
            CreateRoomMesh(corridor, parent);
        }

        if (corridor.corridors != null){
            foreach (var child in corridor.corridors)
                GenerateMeshes(child, parent);
        }
    }

    static void CreateRoomMesh(Corridor corridor, Transform parent){
        var room = ShapeGenerator.GenerateCube(
            PivotLocation.Center,
            new(corridor.Width, 3, corridor.Height)
        );
        
        room.transform.position = new( // set pivot point to be in center
            corridor.x + corridor.Width/2f,
            1.5f,
            corridor.y + corridor.Height/2f
        );
        
        room.transform.parent = parent;
        room.GetComponent<MeshRenderer>().sharedMaterial = Instance.defaultMaterial;
        RawObjects.Add(room);

        if (corridor is Room roomCorridor){
            foreach (var door in roomCorridor.doors){
                CreateDoorTunnel(roomCorridor, door, room.transform);
            }
        }
    }

    static void CreateDoorTunnel(Room room, Door door, Transform parent){
        float tunnelDepth = Corridor.Space + 2;
        Vector3 size = new(door.Width,1.5f,door.Height);
        Vector3 position = new(door.x,1.5f,door.y);

        var tunnel = ShapeGenerator.GenerateCube(PivotLocation.Center, size);
        tunnel.GetComponent<MeshRenderer>().sharedMaterial = Instance.defaultMaterial;
        tunnel.transform.position = position;
        tunnel.transform.parent = parent;
    }
}