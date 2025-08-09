using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.ProBuilder;
using UnityEngine.UI;
// https://gamedev.stackexchange.com/questions/47917/procedural-house-with-rooms-generator 
// &&
// https://www.roguebasin.com/index.php/Basic_BSP_Dungeon_generation
// https://github.com/rombdn/unitydungeonbsp
public class RoomGenerator : MonoBehaviour
{
    public static RoomGenerator Instance;
    [SerializeField] Vector2Int RoomDimensionsMin = new(100, 100);
    [SerializeField] Vector2Int RoomDimensionsMax = new(200, 200);
    [SerializeField] int depthLimit = 3;
    [SerializeField] int minSpace = 9;
    [SerializeField] float wallHeight;
    [SerializeReference] Corridor rootRoom;
    public ProBuilderMesh BaseMesh;
    [SerializeField] RawImage map;

    void Start() => Instance = this;

    void Clear(){
        while (BaseMesh.transform.childCount > 0)
            DestroyImmediate(BaseMesh.transform.GetChild(0).gameObject);
    }

    [ContextMenu("DO IT")]
    public void BakeMesh(){
        Clear();
        var size = new Vector2Int(UnityEngine.Random.Range(RoomDimensionsMin.x, RoomDimensionsMax.x), 
                                  UnityEngine.Random.Range(RoomDimensionsMin.y, RoomDimensionsMax.y));
        
        rootRoom = new Corridor { Pos = Vector2Int.zero, Size = size };
        Corridor.MaxDepth = depthLimit;
        Corridor.MinSpace = minSpace;
        
        Corridor.PartitionCorridors(rootRoom, 0);
        Corridor.CreateRooms(rootRoom);
        
        MeshGen.GenerateMesh(rootRoom, size, wallHeight);
        map.texture = MeshGen.CreateMap();
        map.rectTransform.sizeDelta = new(map.texture.width, map.texture.height);
        map.rectTransform.anchoredPosition = new(-map.rectTransform.sizeDelta.x/2, -map.rectTransform.sizeDelta.y/2);
        map.gameObject.SetActive(true);
    }
}