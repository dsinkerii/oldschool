
using System.Drawing;
using UnityEngine;

[System.Serializable]
public class Corridor{
    // static fields
    public static int MaxDepth;
    public static int MinSpace;

    // corridor fields
    public Corridor left, right;
    // pivot point is bottom left
    public Vector2Int Pos, Size;
    public Room room;
    public bool IsLeaf => left == null && right == null;
    // hi staticvoid._.
    public static void PartitionCorridors(Corridor node, int depth){
        if (depth >= MaxDepth) return;

        float ratio = (float)node.Size.x / node.Size.y;
        bool splitH = ratio <= 1.25f && (ratio < 0.8f || Random.value > 0.5f);
        
        int max = (splitH ? node.Size.y : node.Size.x) - MinSpace;
        if(max <= MinSpace) return;

        int split = Random.Range(MinSpace, max);

        if(splitH){
            node.left = new Corridor { Pos = node.Pos, Size = new(node.Size.x, split) };
            node.right = new Corridor { Pos = node.Pos + new Vector2Int(0, split), Size = new(node.Size.x, node.Size.y - split) };
        } else {
            node.left = new Corridor { Pos = node.Pos, Size = new(split, node.Size.y) };
            node.right = new Corridor { Pos = node.Pos + new Vector2Int(split, 0), Size = new(node.Size.x - split, node.Size.y) };
        }
        
        PartitionCorridors(node.left, depth + 1);
        PartitionCorridors(node.right, depth + 1);
    }
    public static void CreateRooms(Corridor node){
        if(node.IsLeaf){
            int roomWidth = Random.Range(node.Size.x / 2, node.Size.x - 2);
            int roomHeight = Random.Range(node.Size.y / 2, node.Size.y - 2);
            int roomX = node.Pos.x + Random.Range(1, node.Size.x - roomWidth);
            int roomY = node.Pos.y + Random.Range(1, node.Size.y - roomHeight);
            
            node.room = new Room { Pos = new Vector2Int(roomX, roomY), Size = new Vector2Int(roomWidth, roomHeight) };
        } else {
            CreateRooms(node.left);
            CreateRooms(node.right);
        }
    }
}
public class Room{ // no longer a child of corridor
    public Vector2Int Pos, Size;
}
public class WallSegment{
    public Vector2Int start;
    public Vector2Int end;
    public bool isHorizontal;
    
    public WallSegment(Vector2Int start, Vector2Int end, bool isHorizontal)
    {
        this.start = start;
        this.end = end;
        this.isHorizontal = isHorizontal;
    }
}
// old code used to be.... WAY longer.