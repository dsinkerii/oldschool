
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using UnityEngine;
using UnityEngine.UI;
[Serializable]
public class StarterCorridor : Corridor{
    public static int ServerSpace;
    public StarterCorridor(int x, int y, int width, int height){
        Height = height;
        Width = width;
        this.x = x;
        this.y = y;
    }
    public override (int x,int y,int width,int height) GetSpaceCorridorValues(){ return (firstRoomBudget+x,y,ServerSpace,Height); }
    public override (int x,int y,int width,int height) GetFirstRoomValues(){ return (x,y,firstRoomBudget,Height); }
    public override (int x,int y,int width,int height) GetSecondRoomValues(){ return (x+firstRoomBudget+ServerSpace,y,secondRoomBudget,Height); }
    public override void PartitionCorridors(int depthLimit){
        firstRoomBudget = (Width-ServerSpace)/2;
        secondRoomBudget = Width - ServerSpace - firstRoomBudget;
        var spaceVals = GetSpaceCorridorValues();
        var firstVals = GetFirstRoomValues();
        var secndVals = GetSecondRoomValues();

        corridors = new(3){
            new HorizontalCorridor(firstVals.x,firstVals.y,firstVals.width,firstVals.height),
            new SpaceCorridor(spaceVals.x,spaceVals.y,spaceVals.width,spaceVals.height),
            new HorizontalCorridor(secndVals.x,secndVals.y,secndVals.width,secndVals.height),
        };

        corridors[0].PartitionCorridors(depthLimit-1);
        corridors[2].PartitionCorridors(depthLimit-1);
    }
}
[Serializable]
public abstract class Corridor{
    public int Height;
    public int Width;
    // pivot point is bottom left
    public int x;
    public int y;
    public int Budget;
    public static int Space;
    public static int MinSpace;
    [SerializeReference] public List<Corridor> corridors;
    public List<Door> doors = new();

    // partition values
    internal int firstRoomBudget;
    internal int secondRoomBudget;
    public Corridor parentCorridor;
    public virtual void PartitionCorridors(int depthLimit){
        if(depthLimit <= 0) {PartitionRoom();return;}
        //precalc
        Budget -= Space;

        if(Budget <= MinSpace*2) {PartitionRoom();return;}

        firstRoomBudget = UnityEngine.Random.Range(MinSpace, Budget-MinSpace+1);
        secondRoomBudget = Budget - firstRoomBudget;
        var spaceVals = GetSpaceCorridorValues();
        var firstVals = GetFirstRoomValues();
        var secndVals = GetSecondRoomValues();

        corridors = new(3){
            GetRoomType(firstVals.x,firstVals.y,firstVals.width,firstVals.height),
            new SpaceCorridor(spaceVals.x,spaceVals.y,spaceVals.width,spaceVals.height),
            GetRoomType(secndVals.x,secndVals.y,secndVals.width,secndVals.height)
        };

        foreach (var child in corridors) 
            child.parentCorridor = this;

        corridors[0].PartitionCorridors(depthLimit-1);
        corridors[2].PartitionCorridors(depthLimit-1);
    }
    public virtual void PartitionRoom(){
        int width2 = UnityEngine.Random.Range((MinSpace+Width)/2-Space, Width-Space);
        int height2 = UnityEngine.Random.Range((MinSpace+Height)/2-Space, Height-Space);
        int x2 = x+(Width-width2)/2;
        int y2 = y+(Height-height2)/2;
        corridors = new(1){
            new Room(x2,y2,width2,height2)
        };
        ((Room)corridors[0]).Parent = this;
    }
    //help functions
    public virtual (int x,int y,int width,int height) GetSpaceCorridorValues(){ return (0,0,0,0); }
    public virtual (int x,int y,int width,int height) GetFirstRoomValues(){ return (0,0,0,0); }
    public virtual (int x,int y,int width,int height) GetSecondRoomValues(){ return (0,0,0,0); }
    private Corridor GetRoomType(int x,int y,int width,int height){
        return width > height ? new VerticalCorridor(x,y,width,height) : new HorizontalCorridor(x,y,width,height);
    }
    public Corridor GetClosestChild(int x, int y, Corridor contendant = null,Corridor exclude = null){
        if(corridors == null || corridors.Count != 3) return contendant; // nothing to return
        contendant ??= corridors[0]; // set to our first child to compare with

        if(corridors[0] != exclude && corridors[0].x <= contendant.x && corridors[0].y < contendant.y){ // the = in <= is important
            contendant = corridors[0];
        }else if(corridors[2] != exclude && corridors[2].x <= contendant.x && corridors[2].y < contendant.y){ // skip spaces at [1]
            contendant = corridors[2];
        }

        contendant = corridors[0].GetClosestChild(x,y,contendant,exclude);
        contendant = corridors[2].GetClosestChild(x,y,contendant,exclude);

        return contendant;
    }
}
[Serializable]
public class VerticalCorridor : Corridor{
    public VerticalCorridor(int x, int y, int width, int height){
        Height = height;
        Width = Budget = width;
        this.x = x;
        this.y = y;
    }
    // return values of the corridor based on THIS corridor
    public override (int x,int y,int width,int height) GetSpaceCorridorValues(){ 
        return (firstRoomBudget+x, y, Space, Height);
    }
    public override (int x,int y,int width,int height) GetFirstRoomValues(){ 
        return (x, y, firstRoomBudget, Height);
    }
    public override (int x,int y,int width,int height) GetSecondRoomValues(){ 
        return (x+firstRoomBudget+Space, y, secondRoomBudget, Height);
    }
}
[Serializable]
public class HorizontalCorridor : Corridor{
    public HorizontalCorridor(int x, int y, int width, int height){
        Width = width;
        Height = Budget = height;
        this.x = x;
        this.y = y;
    }
    public override (int x,int y,int width,int height) GetSpaceCorridorValues(){ 
        return (x, firstRoomBudget+y, Width, Space);
    }
    // below sounds horrible, but we actually need to reverse first & second rooms because we need the pivot point to be on bottom left, so we reverse the values of horizontal corridors
    public override (int x,int y,int width,int height) GetFirstRoomValues(){ 
        return (x, y+firstRoomBudget+Space, Width, secondRoomBudget);
    }
    public override (int x,int y,int width,int height) GetSecondRoomValues(){ 
        return (x, y, Width, firstRoomBudget);
    }
}
[Serializable]
public class SpaceCorridor : Corridor{
    public SpaceCorridor(int x, int y, int width, int height){
        Height = height;
        Width = width;
        this.x = x;
        this.y = y;
    }
}

public class Room : Corridor{
    public Corridor Parent;
    public Room(int x, int y, int Width, int Height){
        this.Width = Width;
        this.Height = Height;
        this.x = x;
        this.y = y;
    }
}

public class Door{ // not related to corridor class
    public static List<Door> staticDoors = new();
    public int x;
    public int y;
    public int Width;
    public int Height;
    public static int baseLength = 3; // for vertical/horizontal length in the other direction
    public Room[] ConnectedRooms;
    
    public static bool ConnectionExists(Room room1, Room room2){
        if(room1 == null && room2 == null){
            Debug.Log("invalid rooms passed");
            return false;
        }
        return staticDoors.Any(x => x.ConnectedRooms != null && x.ConnectedRooms[0] != null && x.ConnectedRooms[1] != null && x.ConnectedRooms[0] == room1 && x.ConnectedRooms[1] == room2);
    }
    
    public static void ConnectRooms(Corridor corridor){
        if (corridor == null) return;
        
        if (corridor.corridors != null){
            foreach (var child in corridor.corridors)
                ConnectRooms(child);
        }

        if (corridor.corridors?.Count == 3){
            var leftChild = corridor.corridors[0];
            var rightChild = corridor.corridors[2];
            var spaceChild = corridor.corridors[1];
            
            var leftRoom = GetAnyRoom(leftChild);
            var rightRoom = GetAnyRoom(rightChild);

            if (leftRoom != null && rightRoom != null && !ConnectionExists(leftRoom, rightRoom)){
                if (corridor is VerticalCorridor)
                    ConnectVertical(leftRoom, rightRoom, spaceChild);
                else if (corridor is HorizontalCorridor) 
                    ConnectHorizontal(leftRoom, rightRoom, spaceChild);
            }
        }
    }
    
    private static Room GetAnyRoom(Corridor corridor){
        if (corridor is Room room) 
            return room;
            
        if (corridor.corridors?.Count > 0){
            foreach(var child in corridor.corridors){
                var foundRoom = GetAnyRoom(child);
                if(foundRoom != null) return foundRoom;
            }
        }
        
        return null;
    }


    private static void ConnectVertical(Room left, Room right, Corridor spaceChild) {
        int minY = Math.Max(left.y, right.y);
        int maxY = Math.Min(left.y + left.Height, right.y + right.Height);

        if (minY >= maxY) return;
        if(ConnectionExists(left, right)) return;
        
        int doorY = (minY + maxY) / 2;
        int doorX = spaceChild.x + spaceChild.Width / 2;
        var leftroomclosest = spaceChild.parentCorridor.GetClosestChild(doorX,doorY+Corridor.MinSpace);
        var rightroomclosest = spaceChild.parentCorridor.GetClosestChild(doorX,doorY+Corridor.MinSpace, null, leftroomclosest);

        if(leftroomclosest == rightroomclosest){
            Debug.Log("huh??? that cant happen");
            return;
        }

        int width = (leftroomclosest.x+leftroomclosest.Width+rightroomclosest.x)/2;
        
        right.doors.Add(new Door{ 
            x = doorX, 
            y = doorY,
            Height=baseLength,
            Width=width,
            ConnectedRooms = new[]{left, right} 
        });
        staticDoors.Add(right.doors.Last());
    }

    private static void ConnectHorizontal(Room bottom, Room top, Corridor spaceChild) {
        int minX = Math.Max(bottom.x, top.x);
        int maxX = Math.Min(bottom.x + bottom.Width, top.x + top.Width);
        
        if (minX >= maxX) return;
        if(ConnectionExists(bottom, top)) return;
        
        int doorX = (minX + maxX) / 2;
        int doorY = spaceChild.y + spaceChild.Height / 2;
        var uproomclosest = spaceChild.parentCorridor.GetClosestChild(doorX-Corridor.MinSpace,doorY);
        var downroomclosest = spaceChild.parentCorridor.GetClosestChild(doorX+Corridor.MinSpace,doorY, null, uproomclosest);

        if(uproomclosest == downroomclosest){
            Debug.Log("huh??? that cant happen");
            return;
        }

        int height = (downroomclosest.x+downroomclosest.Width+uproomclosest.x)/2;
        
        top.doors.Add(new Door{ 
            x = doorX, 
            y = doorY,
            Width=baseLength,
            Height=height,
            ConnectedRooms = new[]{bottom, top} 
        });
        staticDoors.Add(top.doors.Last());
    }
}