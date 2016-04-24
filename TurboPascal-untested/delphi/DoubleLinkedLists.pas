(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0166.PAS
  Description: Double Linked Lists
  Author: JEFF ATWOOD
  Date: 08-30-96  09:35
*)

unit Tlink;
{ TLink unit: doubly linked lists 5/22/95}
{ by Jeff Atwood, JAtwood159@AOL.COM. }
{ }
{ This unit can be used for stacks, deques, and free lists too.  }
{ }
{ I couldn't find a doubly-linked list implemented as an object ANYWHERE }
{ so I wrote it myself, after much trial, error, and poring over         }
{ obscure programming reference books. Hey-- it's not brain surgery, but }
{ pointers can be so naughty. }
{ }
{ For simplicity's sake, and to keep this a one-day project, I am only    }
{ storing simple integers in the cells. You can easily, easily change     }
{ that to any data type supported by Delphi including records. I would    }
{ NOT recommend trying to store a whole object with methods in there...   }
{ I couldn't get that to work. But if you can, E-Mail me. I don't know if }
{ it's even possible. }
{ }
{ There is one main object, which uses the "CELL" record type for each    }
{ entry in the list. I don't know how to hide the CELL record type from   }
{ the user, but it should be internal to this unit. The main object is    }
{ the TLink, which keeps track of the size, first, last, and current      }
{ cell records. You can move around in the list by using the Move methods }
{ and find using the Seek method. It's all fairly straightforward, look   }
{ at the demo form for examples, there are also comments in the code.     }
{ }
{ If you're feeling ambitious, I recommend you modify the cell record to  }
{ store pointers instead of integers. Don't forget to make copies of the  }
{ data, because if you point to the actual location, you're screwed when  }
{ the user destroys that instance. You gotta copy it... How many times    }
{ did I get burned by THAT one?? Also, it would be cool to turn this into }
{ a VCL component, if anyone wants to do that. }
{ }
{ This code is freeware. Please E-Mail me any cool additions, bug fixes,  }
{ rants, raves, etc. at JAtwood159@AOL.COM! Thanks for trying my code, I  }
{ hope it helps someone... }
interface
type
  CellPtr = ^Cell;
  Cell = record
    data: Integer;
    next: CellPtr;
    prev: CellPtr;
  end;
  TList = class(TObject)
  private
    top: CellPtr;
    bottom: CellPtr;
    current: CellPtr;
    size: Longint;
  public
    constructor create;
    destructor destroy; override;
    function IsEmpty: Boolean;
    function GetSize: Longint;
    procedure InsertBottom(item: Integer);
    procedure InsertTop(item: Integer);
    function InsertCurrent(item: Integer): Boolean;
    function FindFirst(item: Integer; var absLoc: longint): Boolean;
    function Delete: Boolean;
    function MoveFirst: Boolean;
    function MoveLast: Boolean;
    function MoveNext: Boolean;
    function MovePrevious: Boolean;
    function Seek(absLoc: longint): Boolean;
    function GetData(var item: Integer): Boolean;
  end;
implementation
{ set up the TList object with default values }
constructor TList.create;
begin
  inherited create;
  top := nil;
  bottom := nil;
  current := nil;
  size := 0;
end;
{ destroy the entire list, cell by cell }
destructor TList.destroy;
var
  curCell: CellPtr;
  nextCell: CellPtr;
begin
  curCell := top;
  while not (curCell = nil) do begin
    nextCell := curCell^.next;
    freemem(curCell, SizeOf(Cell));
    curCell := nextCell;
  end;
  top := nil;
  bottom := nil;
  current := nil;
  inherited destroy;
end;
{ returns true if the list has no cells }
function TList.isEmpty: Boolean;
begin
  result := (size = 0);
end;
{ returns number of cells in list }
function TList.getSize: Longint;
begin
  result := size;
end;
{ insert cell at bottom of list }
procedure TList.InsertBottom(item: Integer);
var
  newCell: CellPtr;
begin
  GetMem(newCell, Sizeof(Cell));
  newCell^.data := item;
  newCell^.prev := bottom;
  newCell^.next := nil;
  { special case: this is first cell added }
  if bottom = nil then
    top := newCell
  else
    bottom^.next := newCell;
  bottom := newCell;
  size := size + 1;
end;
{ insert cell at top of list }
procedure TList.InsertTop(item: Integer);
var
  newCell: CellPtr;
begin
  GetMem(newCell, Sizeof(Cell));
  newCell^.data := item;
  newCell^.prev := nil;
  newCell^.next := top;
  { special case: this is first cell added }
  if top = nil then
    bottom := newCell
  else
    top^.prev := newCell;
  top := newCell;
  size := size + 1;
end;
{ insert cell after current item }
function TList.InsertCurrent(item: Integer): Boolean;
var
  newCell: CellPtr;
begin
  if (current = nil) then
    result := False
  else begin
    GetMem(newCell, Sizeof(Cell));
    newCell^.data := item;
    newCell^.prev := current;
    newCell^.next := current^.next;
    { special case: current cell is last cell }
    if current^.next = nil then
      bottom := newCell
    else
      current^.next^.prev := newCell;
    current^.next := newCell;
    size := size + 1;
    result := True;
  end;
end;
{ Look for item in data field. Starts at top of list }
{ and looks at every item until a match is found.    }
{ if found, makes matched cell current, and returns  }
{ absolute location of match where 1 = top.          }
function TList.FindFirst(item: Integer; var absLoc: longint): Boolean;
var
  curCell: CellPtr;
  cnt: longInt;
begin
  result := False;
  curCell := top;
  cnt := 0;
  absLoc := 0;
  while not (curCell = nil) do begin
    cnt := cnt + 1;
    if curCell^.Data = item then begin
      absLoc := cnt;
      current := curCell;
      result := True;
      exit;
    end;
    curCell := curCell^.next;
  end;
end;

{ delete the current cell }
function TList.Delete: Boolean;
label
  exitDelete;
begin
  { we can only delete the current record }
  if current = nil then
    result := False
  else begin
    { see if list has one item }
    if size = 1 then begin
      top := nil;
      bottom := nil;
      goto exitDelete;
    end;
    { see if we're at the top of list }
    if current^.prev = nil then begin
      top := current^.next;
      top^.prev := nil;
      goto exitDelete;
    end;
    { see if we're at the bottom of list }
    if current^.next = nil then begin
      bottom := current^.prev;
      bottom^.next := nil;
      goto exitDelete;
    end;
    { we must be in middle of list of size > 1 }
    current^.prev^.next := current^.next;
    current^.next^.prev := current^.prev;
    goto exitDelete;
  end;
  { arrgh-- a goto! but this is a textbook goto! }
  exitDelete: begin
                result := True;
                freemem(current, SizeOf(Cell));
                current := nil;
                size := size - 1;
                if size = 0 then begin
                  top := nil;
                  bottom := nil;
                end;
              end;
end;
{ make first value in list current }
function TList.MoveFirst: Boolean;
begin
  if top = nil then
    result := False
  else begin
    current := top;
    result := True;
  end;
end;
{ make last value in list current }
function TList.MoveLast: Boolean;
begin
  if bottom = nil then
    result := False
  else begin
    current := bottom;
    result := True;
  end;
end;
{ make next value in list current }
function TList.MoveNext: Boolean;
begin
  if (current = nil) or (current^.next = nil) then
    result := False
  else begin
    current := current^.next;
    result := True;
  end
end;
{ make previous value in list current }
function TList.MovePrevious: Boolean;
begin
  if (current = nil) or (current^.prev = nil) then
    result := False
  else begin
    current := current^.prev;
    result := True;
  end;
end;
{ return data item from current list position }
function TList.GetData(var item: Integer): Boolean;
begin
  if (current = nil) then
    result := False
  else begin
    item := current^.data;
    result := True;
  end;
end;
{ make current the absolute cell N in the list }
{ where top = 1 }
function TList.Seek(absloc: longint): Boolean;
var
  curCell: CellPtr;
  cnt: longint;
begin
  result := False;
  if absloc <= 0 then
    exit;
  curCell := top;
  while not (curCell = nil) do begin
    cnt := cnt + 1;
    if cnt = absloc then begin
      current := curCell;
      result := True;
      exit;
    end;
    curCell := curCell^.next;
  end;
end;
end.

