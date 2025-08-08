using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
//https://gamedev.stackexchange.com/questions/47917/procedural-house-with-rooms-generator
public class RoomGenerator : MonoBehaviour
{
    public static RoomGenerator Instance;
    [SerializeField] RawImage PreviewImage;
    [SerializeField] Vector2 RoomDimensionsMin = new Vector2(100, 100);
    [SerializeField] Vector2 RoomDimensionsMax = new Vector2(200, 200);
    [SerializeField] int depthLimit = 3;
    [SerializeField] int minSpace = 9;
    [SerializeField] int corridorSpace = 3;
    [SerializeField] int ServerSpace = 50;
    [SerializeReference] RoomSettings readRoom;
    [Serializable]
    public class RoomSettings{
        public Vector2Int RoomSize;
        public Texture2D texture2D;
        [SerializeReference] public Corridor InitialCorridor;
        int depthLimit;
        int ServerSpace;
        public RoomSettings(int depthLimit, int corridorSpace, int minSpace, int serverSpace){
            Corridor.Space = corridorSpace;
            Corridor.MinSpace = minSpace;
            this.depthLimit = depthLimit;
            this.ServerSpace = serverSpace;
        }
        
        public void GenerateRoom(){
            // make initial room
            //InitialCorridor = new VerticalCorridor(RoomSize.y,RoomSize.x);
            StarterCorridor.ServerSpace=ServerSpace;
            InitialCorridor = new StarterCorridor(0,0,RoomSize.x,RoomSize.y);
            InitialCorridor.PartitionCorridors(depthLimit);

            Door.ConnectRooms(InitialCorridor);
        }
        
    }
    void Start()
    {
        Instance = this;
        var output = generateRoomPreview();
        readRoom = output;

        PreviewImage.texture = output.texture2D;
        PreviewImage.rectTransform.sizeDelta = output.RoomSize*2;
        PreviewImage.gameObject.SetActive(true);

        MeshGen.GenerateMesh(readRoom.InitialCorridor);
    }
    public static RoomSettings GenerateRoomPreview(){
        return Instance.generateRoomPreview();
    }    

    void DrawCorridor(Corridor toRender, Texture2D texture, Color color){
        for(int x = 0; x < toRender.Width; x++){
            for(int y = 0; y < toRender.Height; y++){
                texture.SetPixel(toRender.x+x,toRender.y+y,color);
            }
        }
    }
    void DrawDoor(Door door, Texture2D texture){
        for(int i = -1; i <= 1; i++){
            if(door.x + i >= 0 && door.x + i < texture.width)
                texture.SetPixel(door.x + i, door.y, Color.green);
            if(door.y + i >= 0 && door.y + i < texture.height)
                texture.SetPixel(door.x, door.y + i, Color.green);
        }
    }
    void DrawCorridorRecursive(Corridor toRender, Texture2D texture, int depth){
        if(toRender == null) return;

        if(toRender is Room){
            DrawCorridor(toRender, texture, Color.black);
            foreach(var door in toRender.doors)
                DrawDoor(door, texture);
        }
        else if(toRender is SpaceCorridor){
            DrawCorridor(toRender, texture, Color.gray);
        }

        if(toRender.corridors != null){
            foreach(var child in toRender.corridors)
                DrawCorridorRecursive(child, texture, depth + 1);
        }
    }
    RoomSettings generateRoomPreview(){
        RoomSettings roomSettings = new(depthLimit,corridorSpace,minSpace, ServerSpace){
            RoomSize = new((int)UnityEngine.Random.Range(RoomDimensionsMin.x, RoomDimensionsMax.x), (int)UnityEngine.Random.Range(RoomDimensionsMin.y, RoomDimensionsMax.y))
        };
        roomSettings.texture2D = new(roomSettings.RoomSize.x, roomSettings.RoomSize.y){
            filterMode = FilterMode.Point
        };

        roomSettings.GenerateRoom();

        // now render onto a rendertexture
        DrawCorridorRecursive(roomSettings.InitialCorridor, roomSettings.texture2D, 0);
        roomSettings.texture2D.Apply();


        return roomSettings;
    }
}