(*
  Category: SWAG Title: POINTERS, LINKING, LISTS, TREES
  Original name: 0037.PAS
  Description: Dynamically Sized List Unit
  Author: MICHAEL DALES
  Date: 08-30-96  09:36
*)

unit Lists;

{--------------------------------------------------------------------------}
{ Abstract Data Type for dynamically sized list                            }
{ By Michael Dales 30th May 1996                                           }
{                                                                          }
{ Here is a simple list unit, that has the advantage of being dynamically  }
{ sized, unlike normal arrays. To use the list you only need to know the   }
{ data type names and the methods declared in the interface of this unit   }
{ are used to manipulate them without the need to know the underlying      }
{ representation.                                                          }
{                                                                          }
{ Deaclare your list variable to be of type TList, and remeber to use      }
{ CreateList on it before you carry out any operations using it. Data is   }
{ stored in nodes as pointers, just so you can have a list which isn't     }
{ tied to just one kind of data type. Remeber though that because of this  }
{ you'll need to typecast your pointers when you retrieve them from the    }
{ list. Each node is has a type called PListNode, and an invalid node has  }
{ the value null.                                                          }
{                                                                          }
{ Email comments to: 9402198d@udcf.gla.ac.uk                               }
{ URL: http://www.gla.ac.uk/Clubs/WebSoc/~9402198d/index.html              }
{--------------------------------------------------------------------------}

interface

const null = nil;        {Non specific terminator}

type PListNode = ^TListNode;             {Pointer to node}
     TListNode = record                  {Node record}
               Item      : Pointer;      {Pointer to node data}
               Next      : PListNode;    {Next node}
               Previous  : PListNode;    {Previous node}
     end;

     TList = record                   {Holder for list}
           First : PListNode;         {Pointer to start of list}
           Rear  : PListNode;         {Pointer to end of list}
           Size  : integer;           {Size of list}
     end;

{CreateList - Initiates a new list}
procedure CreateList(var L : TList);

{DestroyList - Frees up all memory used by list and sets list to nil}
procedure DestroyList(var L : TList);

{AddNewNode - Adds new node to list L, filling it with the data
              supplied. Returns true is new node sucessfully
              added, otherwise returns false.}
procedure AddNewNode(var L : TList; Data : Pointer);

{DeleteListElement - Deletes an element passed.}
procedure DeleteNode(var L : TList; ANode : PListNode);

{GetFirstNode - Returns the first node in a given list}
function GetFirstNode(L:TList):PListNode;

{GetNextNode - Returns the successor of the given node}
function GetNextNode(Node:PListNode):PListNode;

{GetNodeData - Returns the data in a specific node}
procedure GetNodeData(Node:PListNode; var Data:Pointer);

{UpdateNode - Replaces a nodes details with new ones}
procedure UpdateNode(Node:PListNode; Data:Pointer);

{--------------------------------------------------------------------------}
implementation
{--------------------------------------------------------------------------}

    {CreateList - Initiates a new list}

procedure CreateList(var L : TList);
begin
     L.First := nil;      {No list yet}
     L.Rear := nil;
     L.Size := 0;         {No length yet}
end;


    {RemoveLastNode - Deletes last node on the list}

procedure RemoveLastNode(var L : TList);
begin
     with L do                                  {With the list}
     begin
          if Size > 0 then                        {If nodes in list}
          begin
               if Size = 1 then                   {If just one node}
               begin
                    if First^.Item <> nil then  {If data in node then}
                       Dispose(First^.Item);        {Dispose of it}
                    Dispose(First);             {Dispose of first node}
                    First := nil;
                    Rear := nil;                  {Set rear to nil}
               end else
               begin                            {If more than one node}
                    Rear := Rear^.Previous;       {Set rear to second last}
                    Dispose(Rear^.Next);        {Remove last node}
               end;
               Size := Size-1;                    {Decrement list size}
          end;
     end;
end;


    {DestroyList - Frees up all memory used by list and sets list to nil}

procedure DestroyList(var L : TList);
begin
     while L.First <> nil do              {While still nodes left}
           RemoveLastNode(L);             {Remove last node}
     CreateList(L);
end;


    {GetFirstNode - Returns the first node in a given list}

function GetFirstNode(L : TList) : PListNode;
begin
     GetFirstNode := L.First;
end;


    {GetNextNode - Returns the successor of the given node}

function GetNextNode(Node : PListNode) : PListNode;
begin
     if Node <> nil then
        GetNextNode := Node^.Next
     else
         GetNextNode := nil;
end;


    {GetNodeData - Returns the data in a specific node}

procedure GetNodeData(Node : PListNode; var Data : Pointer);
begin
     if Node <> nil then
        Data := Node^.Item
     else
         Data := nil;
end;


    {AddNewNode - Adds new node to list L, filling it with the data
                  supplied. Returns true is new node sucessfully
                  added, otherwise returns false.}

procedure AddNewNode(var L:TList; Data:Pointer);
var temp    : PListNode;
begin
     new(temp);                 {Create new node}
     with temp^ do              {Fill node}
     begin
          Item := Data;
          Next := nil;
          Previous := L.Rear;
     end;
     If (L.Size = 0) then         {If empty list...}
     begin
          L.First := temp;        {Add as first node}
          L.Rear := temp;
     end else                       {else add at end}
     begin
          L.Rear^.Next := temp;  {Make old rear of list point to new}
          L.Rear := temp;        {Make rear point to new node}
     end;
     L.Size := L.Size + 1;          {Increment list length}
end;


    {UpdateNode - Replaces a nodes details with new ones}

procedure UpdateNode(Node : PListNode; Data : Pointer);
begin
     if Node <> nil then
     begin
          Node^.Item := Data;
     end;
end;


    {DeleteListElement - Deletes an element passed.}

procedure DeleteNode(var L : TList; ANode : PListNode);
begin
     if (L.Size = 1) or (ANode^.Next = nil) then    {If we're deeling with}
        RemoveLastNode(L)            {last node then that's easy}
     else                            {otherwise...}
     begin
          if (ANode = L.First) then      {if we're deleting the first node}
          begin
               L.First := L.First^.Next;    {Start list from second node}
               L.First^.Previous := nil;    {Set new starts previous link}
               Dispose(ANode);              {Dispose of old first}
          end else
          begin
               ANode^.Previous^.Next := ANode^.next;     {Move pointers...}
               ANode^.Next^.Previous := ANode^.Previous;
               Dispose(ANode);          {Dispose of node}
          end;
          L.Size := L.Size-1;           {Note new list size}
     end;
end;

end.

