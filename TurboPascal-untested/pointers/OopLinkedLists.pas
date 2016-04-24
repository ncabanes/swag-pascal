(*
  Category: SWAG Title: POINTERS, LINKING, LISTS, TREES
  Original name: 0021.PAS
  Description: OOP Linked Lists
  Author: MARK GAUTHIER
  Date: 08-24-94  13:49
*)

Unit MgLinked;

interface

const

      { Error list. }
      Succes       = $00;
      Need_Mem     = $01;
      Point_To_Nil = $02;

type

  DoubleLstPtr = ^DoubleLst;
  DoubleLst    = record
                   Serial       : longint;
                   Size         : word;
                   Addresse     : pointer;
                   Next         : DoubleLstPtr;
                   Previous     : DoubleLstPtr;
                 end;


  PDoubleLst = ^ODoubleLst;
  ODoubleLst = object

    private
    LastCodeErr : word;          {-- Last error.         --}

    public
    TotalObj    : longint;       {-- Total obj allocate. --}
    CurentObj   : DoubleLstPtr;  {-- Curent obj number.  --}

    constructor Init(var Install:boolean; Serial:longint; Size:word;
Data:pointer);
    {-- Initialise all variables, new curent.    ---}

    destructor Done;

    {--- get and clear the last err. ---}
    function  LastError:word;

    {--- Seek to end and add an object.                            ---}
    procedure Add(Size:word; Data:pointer);

    {--- Change the size of data of a object. 0 = change curent.   ---}
    procedure ChangeSize(Serial:longint; NewSize : word);

    {--- Insert an object before the curent obj. 0 = insert curent pos ---}
    procedure Insert(Serial:longint; Size:word; Data:pointer);

    {--- Delete an object from the list.  0 = delete curent.       ---}
    procedure Delete(Serial:longint);

    {--- Pointe on next or end, etc.                               ---}
    procedure SeekFirst;
    procedure SeekLast;
    procedure SeekNext;
    procedure SeekPrevious;
    procedure SeekNum(Serial:longint);

    {--- Move data from obj to user buffer                          ---}
    {--- 0 = use curent object.                                     ---}
    function MoveObjToPtr(Serial:longint; p:pointer):word;

    {--- Move user buffer to obj data.  obj data take ObjSize bytes ---}
    {--- 0 = use curent object.                                     ---}
    function MovePtrToObj(Serial:longint; p:pointer):word;

  end;

implementation

(****************************************************************************)

 procedure move(Src,Dst:pointer; Size:word);assembler;
 asm
    lds si,Src
    les di,Dst
    mov cx,Size
    cld
    rep movsb
 end;


(****************************************************************************)

constructor ODoubleLst.Init(var Install:boolean; Serial:longint; Size:word;
Data:pointer);
{-- Initialise all variables, new curent.    ---}
begin
     Install := false;
     if Serial = 0 then exit;
     New(CurentObj);
     if CurentObj = nil then exit;
     GetMem(CurentObj^.Addresse, Size);
     if CurentObj^.Addresse = nil then
     begin
          LastCodeErr := Need_Mem;
          exit;
     end;

     CurentObj^.Next     := nil;
     CurentObj^.Previous := nil;
     CurentObj^.Size     := Size;
     CurentObj^.Serial   := Serial;
     move(Data, CurentObj^.Addresse, Size);

     TotalObj := 1;

     Install             := true;
     LastCodeErr         := Succes;
end;

(****************************************************************************)

destructor ODoubleLst.Done;
{-- Initialise all variables, new curent.    ---}
begin
     repeat delete(0);
     until (LastError <> Succes) or (TotalObj <= 0);
end;

(****************************************************************************)

function  ODoubleLst.LastError:word;
{--- get and clear the last err. ---}
begin
     LastError   := LastCodeErr;
     LastCodeErr := 0;
end;

(****************************************************************************)

procedure ODoubleLst.Add(Size:word; Data:pointer);
{--- Seek to end and add an object.                            ---}
begin
     repeat SeekNext until LastError <> Succes; { SeekEnd }

     New(CurentObj^.Next);
     if CurentObj^.Next = nil then
     begin
          LastCodeErr := Need_Mem;
          exit;
     end;

     GetMem(CurentObj^.Next^.Addresse, Size);
     if CurentObj^.Next^.Addresse = nil then
     begin
          LastCodeErr := Need_Mem;
          exit;
     end;

     CurentObj^.Next^.Size := Size;

     { Store information data. }
     move(Data, CurentObj^.Next^.Addresse, Size);

     { Increment the total number of reccords. }
     inc(TotalObj);

     CurentObj^.Next^.Next := nil;
     CurentObj^.Next^.Previous := CurentObj;

     LastCodeErr := Succes;
end;

(****************************************************************************)

procedure ODoubleLst.ChangeSize(Serial:longint; NewSize : word);
{--- Change the size of an object.                             ---}
var p:pointer;
begin
     getmem(p,NewSize);
     if p = nil then
     begin
          LastCodeErr := Need_mem;
          exit;
     end;
     SeekNum(Serial);
     move(CurentObj^.Addresse, p, NewSize);
     freemem(CurentObj^.Addresse, CurentObj^.Size);
     CurentObj^.Size := NewSize;
     CurentObj^.Addresse := p;
     LastCodeErr := Succes;
end;

(****************************************************************************)

procedure ODoubleLst.Insert(Serial:longint; Size:word; Data:pointer);
{--- Insert an object before the curent obj.                   ---}
Var n:DoubleLstPtr;
begin
     new(n);
     if n = nil then
     begin
          LastCodeErr := Need_mem;
          exit;
     end;
     SeekNum(Serial);
     getmem(n^.Addresse, Size);
     if n^.Addresse = nil then
     begin
          LastCodeErr := Need_mem;
          exit;
     end;

     n^.Size := Size;
     move(Data, n^.Addresse, Size);

     n^.Previous := CurentObj^.Previous;
     n^.Next     := CurentObj;

     CurentObj^.Previous^.Next := n;
     CurentObj^.Previous       := n;

     inc(TotalObj);
end;

(****************************************************************************)

procedure ODoubleLst.Delete(Serial:longint);
{--- Delete an object from the list.                           ---}
begin
     SeekNum(Serial);
     if CurentObj^.Addresse <> nil then
     begin
           FreeMem(CurentObj^.Addresse,CurentObj^.Size);
          CurentObj^.Addresse := nil;
     end;

     CurentObj^.Next^.Previous := CurentObj^.Previous;
     CurentObj^.Previous^.Next := CurentObj^.Next;

     if CurentObj <> nil then Dispose(CurentObj);
     CurentObj := CurentObj^.Previous;

     dec(TotalObj);
end;

(****************************************************************************)

procedure ODoubleLst.SeekLast;
begin
     repeat SeekNext until LastError <> Succes;
end;

(****************************************************************************)

procedure ODoubleLst.SeekFirst;
begin
     repeat SeekPrevious until LastError <> Succes;
end;

(****************************************************************************)

procedure ODoubleLst.SeekNext;
begin
     if CurentObj^.Next = nil then
     begin
          LastCodeErr := Point_To_Nil;
          exit;
     end;
     CurentObj := CurentObj^.Next;
     LastCodeErr := Succes;
end;

(****************************************************************************)

procedure ODoubleLst.SeekPrevious;
begin
     if CurentObj^.Previous = nil then
     begin
          LastCodeErr := Point_To_Nil;
          exit;
     end;
     CurentObj := CurentObj^.Previous;
     LastCodeErr := Succes;
end;

(****************************************************************************)

procedure ODoubleLst.SeekNum(Serial:longint);
begin
     if Serial = 0 then exit;
     SeekFirst;
     repeat

           SeekNext;

           if CurentObj^.Serial = Serial then
           begin
                LastCodeErr := Succes;
                break;
           end;

           if LastError <> Succes then
           begin
                LastCodeErr := Point_To_Nil;
                break;
           end
           else continue;

     until false;

end;

(****************************************************************************)

function ODoubleLst.MoveObjToPtr(Serial:longint; p:pointer):word;
{--- Move data from obj to user buffer                         ---}
begin
     SeekNum(Serial);
     if (CurentObj^.Addresse = nil) or (p = nil) then
     begin
          LastCodeErr := Point_To_Nil;
          exit;
     end;
     move(CurentObj^.Addresse, p, CurentObj^.Size);
     LastCodeErr := Succes;
     MoveObjToPtr := CurentObj^.Size;
end;


(****************************************************************************)

function ODoubleLst.MovePtrToObj(Serial:longint; p:pointer):word;
{--- Move user buffer to obj data.  obj data take ObjSize bytes ---}
begin
     SeekNum(Serial);
     if (CurentObj^.Addresse = nil) or (p = nil) then
     begin
          LastCodeErr := Point_To_Nil;
          exit;
     end;
     move(p, CurentObj^.Addresse, CurentObj^.Size);
     LastCodeErr := Succes;
     MovePtrToObj := CurentObj^.Size;
end;


end.

