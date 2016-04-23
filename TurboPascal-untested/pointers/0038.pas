unit OrdLists;

{--------------------------------------------------------------------------}
{ Abstract Data Type for a key ordered list.                               }
{ By Michael Dales 30th May 1996                                           }
{                                                                          }
{ A simple ordered list ADT. All you need to use are the decalred          }
{ methods below, you don't even need to know how the type works either.    }
{ To use the list just assign the list variable the type TOrdList, and     }
{ rember to use CreateList before you try and do any operations on it. The }
{ data in each node is stored as a pointer, and each node has a key by     }
{ which the list is ordered which is a 32 character array, type called     }
{ TKey. The type of each node is called PListNode.                         }
{                                                                          }
{ I've designed this as an abstract data type, which means that although   }
{ you can look at the code and see how I've implemented it, you can (and   }
{ should) use just the methods I've declared in the interface of this      }
{ unit. Hence the word abstract in abstract data type. So there.           }
{                                                                          }
{ If you have any comments the email me at: 9402198d@udcf.gla.ac.uk        }
{ URL: http://www.gla.ac.uk/Clubs/WebSoc/~9402198d/index.html              }
{--------------------------------------------------------------------------}

interface

uses Strings;

const null = nil;        {Non specific terminator}

type TKey      = array[0..32] of char;

     PListNode = ^TListNode;             {Pointer to node}
     TListNode = record                  {Node record}
               Key       : TKey;         {Key for node}
               Item      : Pointer;      {Pointer to node data}
               Next      : PListNode;    {Next node}
               Previous  : PListNode;    {Previous node}
     end;

     TOrdList = record                {Holder for list}
           First : PListNode;         {Pointer to start of list}
           Rear  : PListNode;         {Pointer to end of list}
           Size  : integer;           {Size of list}
     end;

{CreateList - Initiates a new list}
procedure CreateList(var L : TOrdList);

{DestroyList - Frees up all memory used by list and sets list to nil}
procedure DestroyList(var L : TOrdList);

{AddNewNode - Adds new node to list L, filling it with the data
              supplied. Returns true is new node sucessfully
              added, otherwise returns false.}
procedure AddNewNode(var L : TOrdList; AKey : PChar; Data : Pointer);

{DeleteNode - Deletes an element passed.}
procedure DeleteNode(var L : TOrdList; ANode : PListNode);

{GetFirstNode - Returns the first node in a given list}
function GetFirstNode(L : TOrdList) : PListNode;

{FindFirstNode - Finds the first node with a matching key}
function FindFirstNode(L : TOrdList; AKey : TKey) : PListNode;

{GetNextNode - Returns the successor of the given node}
function GetNextNode(Node : PListNode) : PListNode;

{GetNodeData - Returns the data in a specific node}
procedure GetNodeData(Node : PListNode; var Data : Pointer);

{GetNodeKey - Returns the key for a given node}
procedure GetNodeKey(Node : PListNode; var AKey : TKey);

{UpdateNode - Replaces a nodes details with new ones}
procedure UpdateNode(Node : PListNode; Data : Pointer);

{--------------------------------------------------------------------------}
implementation
{--------------------------------------------------------------------------}

    {CreateList - Initiates a new list}

procedure CreateList(var L : TOrdList);
begin
     L.First := nil;      {No list yet}
     L.Rear := nil;
     L.Size := 0;         {No length yet}
end;


    {RemoveLastNode - Deletes last node on the list}

procedure RemoveLastNode(var L : TOrdList);
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
                    if Rear^.Item <> nil then
                       Dispose(Rear^.Item);
                    Rear := Rear^.Previous;       {Set rear to second last}
                    Dispose(Rear^.Next);        {Remove last node}
               end;
               Size := Size-1;                    {Decrement list size}
          end;
     end;
end;


    {DestroyList - Frees up all memory used by list and sets list to nil}

procedure DestroyList(var L : TOrdList);
begin
     while L.First <> nil do              {While still nodes left}
           RemoveLastNode(L);             {Remove last node}
     CreateList(L);
end;


    {GetFirstNode - Returns the first node in a given list}

function GetFirstNode(L : TOrdList) : PListNode;
begin
     GetFirstNode := L.First;
end;


    {FindFirstNode - Finds the first node with a matching key}

function FindFirstNode(L : TOrdList; AKey : TKey) : PListNode;
var temp  : PListNode;
    found : boolean;
begin
     found := false;
     temp := L.First;
     while (temp <> nil) and not found do
     begin
          found := temp^.Key = AKey;
          if not found then temp := temp^.Next;
     end;
     FIndFirstNode := temp;
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


    {GetNodeKey - Returns the key for a given node}

procedure GetNodeKey(Node : PListNode; var AKey : TKey);
begin
     if node <> nil then
        AKey := Node^.Key;
end;


    {AddNewNode - Adds new node to list L, filling it with the data
                  supplied. Returns true is new node sucessfully
                  added, otherwise returns false.}

procedure AddNewNode(var L : TOrdList; AKey : PChar; Data : Pointer);
var temp    : PListNode;
    CurNode : PListNode;
    Match   : boolean;
begin
     new(temp);                 {Create new node}
     with temp^ do              {Fill node}
     begin
          StrCopy(Key, AKey);
          Item := Data;
          Next := nil;
          Previous := nil;
     end;
     if L.Size = 0 then
     begin
          L.First := temp;
          L.Rear := temp;
     end else
     begin
          CurNode := L.First;
          Match := false;
          while (CurNode <> nil) and not Match do
          begin
               if StrComp(CurNode^.Key, AKey) >= 0 then
                  Match := true
               else
                   CurNode := CurNode^.Next;
          end;
          if not Match then
          begin
               temp^.Previous := L.Rear;
               L.Rear^.Next := temp;
               L.Rear := temp;
          end else
          begin
               temp^.Next := CurNode;
               temp^.Previous := CurNode^.Previous;
               if (CurNode^.Previous <> nil) then
                  CurNode^.Previous^.Next := temp
               else
                   L.First := temp;
               CurNode^.Previous := temp;
          end;
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


    {DeleteNode - Deletes an element passed.}

procedure DeleteNode(var L : TOrdList; ANode : PListNode);
begin
     if (L.Size = 1) or (ANode^.Next = nil) then
        RemoveLastNode(L)
     else
     begin
          if (ANode = L.First) then
          begin
               L.First := L.First^.Next;
               L.First^.Previous := nil;
               Dispose(ANode);
          end else
          begin
               ANode^.Previous^.Next := ANode^.next;
               ANode^.Next^.Previous := ANode^.Previous;
               Dispose(ANode);
          end;
          L.Size := L.Size-1;
     end;
end;

end.
