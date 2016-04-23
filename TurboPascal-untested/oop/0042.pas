UNIT filelist;
{
  Contains Object List for keeping a list of files.
}
INTERFACE
USES DOS, OPString;

TYPE  CmdPtr = ^CmdRec;
      CmdRec = RECORD
          CmdStr : PathStr;  {79 char to allow for maximum path length}
          Next   : CmdPtr;
      end;

      List   = OBJECT
          First, Last, Current : CmdPtr;
          ListCount : Word;

          CONSTRUCTOR Init;
          Procedure AddName( Name : String );
          Procedure SortList;
          Procedure SortListReverse;
          Function Compare( A, B : String ) : Boolean;
          Function FirstName : String;
          Function LastName : String;
          Function CurrentName : String;
          Function NextName : String;
          Function TotalCount : Word;
          Procedure ClearList;
          Function InList( Name : String; CheckCase : Boolean ) : Boolean;
          DESTRUCTOR Done;
      END;

IMPLEMENTATION

CONSTRUCTOR LIST.INIT;
BEGIN
  FIRST := NIL;
  LAST := NIL;
  CURRENT := NIL;
  LISTCOUNT := 0;
END;

PROCEDURE LIST.ADDNAME( NAME : STRING );
  { Add a new CmdRec to the list }
VAR
  TempCmdPtr : CmdPtr;
BEGIN
  NEW(TempCmdPtr);
  If First = NIL then begin
    First := TempCmdPtr;
    Current := TempCmdPtr;
  end else
    Last^.Next := TempCmdPtr;
  TempCmdPtr^.Next := NIL;
  TempCmdPtr^.CmdStr := Name;
  Last := TempCmdPtr;
  INC(ListCount);
END;

PROCEDURE LIST.SORTLIST;
VAR
  TempCmdPtr : CmdPtr;
  P, Q : CmdPtr;
BEGIN
  if (First = NIL) or (First^.Next = NIL) then EXIT;
  TempCmdPtr := First;
  First := First^.Next;
  TempCmdPtr^.Next := Nil;

  repeat
     p := TempCmdPtr;

     if not Compare( p^.CmdStr, First^.CmdStr ) then
        begin
          TempCmdPtr := First;
          First := First^.Next;
          TempCmdPtr^.Next := p;
        end
     else
     begin
       while (compare( p^.CmdStr, First^.CmdStr ) AND
             (p <> NIL)) do
       begin
         q := p;
         p := p^.Next;
       end;

       if p = NIL then
       begin
         p := First;
         First := First^.Next;
         q^.Next := p;
         p^.Next := NIL;
       end
         else
       begin
         q^.next := First;
         First := First^.next;
         q^.next^.next := p;
       end;
     end;
  until First = NIL;

  First := TempCmdPtr;
  Current := First;
  Last := First;

  repeat
  Last := Last^.Next;
  until Last^.Next = NIL;

END;

PROCEDURE LIST.SORTLISTREVERSE;
VAR
  TempCmdPtr : CmdPtr;
  CheckPtr   : CmdPtr;
  tempstr    : string;
BEGIN
  if (First = NIL) or (First^.Next = NIL) then EXIT;
  TempCmdPtr := First;
  CheckPtr := First^.Next;

  While (TempCmdPtr <> NIL) DO
  BEGIN
    While (CheckPtr <> NIL) DO
    BEGIN
      { if the tempcmdptr string is less then the checkptr string }
      If compare(TempCmdPtr^.CmdStr, CheckPtr^.CmdStr) then
      BEGIN
        { then swap the strings }
        tempstr := tempCmdPtr^.cmdstr;           { save temp's string }
        TempCmdPtr^.cmdStr := CheckPtr^.Cmdstr; { assign check's string to temp
        CheckPtr^.Cmdstr := tempstr;            { assign tempptr's string to ch
      end;
      CheckPtr := Checkptr^.next;               { get a pointer to next node }
    end; { while checkptr }
    TempCmdPtr := TempCmdPtr^.Next;             { get the next compairson base 
  end; { while tempcmdptr }
end; { SortListReverse }

FUNCTION LIST.COMPARE( A, B : String ) : BOOLEAN;
begin
  Compare := (CompUCString( A,B ) = Less);
end;


FUNCTION LIST.FIRSTNAME : String;
BEGIN
  if First <> NIL then begin
    FirstName := First^.CmdStr;
    Current := First;
  end else
    FirstName := '';
END;

FUNCTION LIST.LASTNAME : String;
BEGIN
  if Last <> NIL then begin
    LastName := Last^.CmdStr;
    Current := Last;
  end else
    LastName := '';
END;

FUNCTION LIST.CURRENTNAME : String;
BEGIN
  if Current <> NIL then
    CurrentName := Current^.CmdStr
  else
    CurrentName := '';
END;

FUNCTION LIST.NEXTNAME : String;
BEGIN
  if (Current <> NIL) Then begin
    Current := Current^.Next;
    if (Current <> NIL) then
      NextName := Current^.CmdStr
    else
      NextName := '';
  end else
    NextName := '';
END;

FUNCTION LIST.TOTALCOUNT : Word;
BEGIN
  TotalCount := ListCount;
END;

PROCEDURE LIST.CLEARLIST;
BEGIN
  if First <> NIL then
    repeat
      Current := First^.Next;
      Dispose(First);
      First := Current;
    until First = nil;
  Last := First;
  ListCount := 0;
END;

Function List.InList(Name:String; CheckCase : Boolean) : Boolean;
{ returns true if string was in list }
VAR
  TempPtr : CmdPtr;
  OK      : Boolean;
BEGIN
  Ok := false;
  TempPtr := Current;
  Current := First;
  If checkCase then OK := (CompString(FirstName,Name) = Equal)
  Else Ok := (CompUCString(FirstName,Name) = Equal);
  If Not OK then
  BEGIN
    While (Current <> Nil) AND Not OK DO
    If CheckCase then OK := (CompString(NextName,Name) = Equal)
    Else OK := (CompUCString(NextName,Name) = Equal);
  end;
  InList := OK;
  Current := TempPtr;
end;

DESTRUCTOR LIST.DONE;
BEGIN
  ClearList;
END;

BEGIN
END.

