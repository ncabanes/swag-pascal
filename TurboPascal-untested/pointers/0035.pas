
UNIT Queues;  { see test program at the end ! }

INTERFACE

TYPE
  PStrRec = ^TStrQueue;
  TStrQueue = RECORD
                 Data : string;
                 Next : PStrRec;
              END; (* of RECORD *)
  StrQueue = OBJECT
             Private
               Start, Finish, Temp : PStrRec;
             Public
               CONSTRUCTOR Init;
               PROCEDURE Reset;
               FUNCTION Copy : String;
               FUNCTION AtEnd : boolean;
               PROCEDURE Enqueue (S : string);
               PROCEDURE Dequeue (VAR S : string);
               FUNCTION Empty : boolean;
               DESTRUCTOR Done;
             END; (* of Object StrQueue *)
  pStrQueue = ^StrQueue;

IMPLEMENTATION

CONSTRUCTOR StrQueue.Init;
BEGIN
  Start := nil;
  Finish := nil;
  Temp := nil;
END; (* of CONSTRUCTOR StrQueue.Init *)



PROCEDURE StrQueue.Reset;
BEGIN
  Temp := Start;
END;  (* of StrQueue.Reset *)



FUNCTION StrQueue.Copy : String;
BEGIN
  if Temp <> nil then Copy := Temp^.Data
  else Copy := '';

  if Temp <> Finish then Temp := Temp^.Next
  else Temp := nil;
END; (* of StrQueue.Copy *)


FUNCTION StrQueue.AtEnd : boolean;
BEGIN
  AtEnd := Temp = nil;
END; (* of StrQueue.AtEnd *)



PROCEDURE StrQueue.Enqueue (S : string);
VAR
  T : PStrRec;

BEGIN
  new (T);
  T^.Data := S;
  T^.Next := nil;

  IF Start = nil THEN
    Start := T
  ELSE
    Finish^.Next := T;
  Finish := T;
END; (* of StrQueue.Enqueue *)



PROCEDURE StrQueue.Dequeue (VAR S : string);
VAR
  T : PStrRec;

BEGIN

  IF Start = nil THEN BEGIN
    S := '';
    exit;
  END; (* of IF *)

  S := Start^.Data;
  T := Start^.Next;
  dispose (Start);
  Start := T;
END; (* of StrQueue.Dequeue *)



FUNCTION StrQueue.Empty : boolean;
BEGIN
  Empty := Start = nil;
END; (* of StrQueue.Empty *)



DESTRUCTOR StrQueue.Done;
VAR
  Belch : string;
BEGIN
  REPEAT
    Dequeue (Belch);
  UNTIL Empty;
END; (* of Destructor StrQueue.Done *)


END. (* of UNIT Queues *)

---------------

PROGRAM TestStr;

USES Queues,strings;

CONST
  MaxStrLen = $FFF8;

VAR
  ThisString : StrQueue;
  Temp : string;
  blah : pchar;
  theend : pointer;
  T2 : array[0..80] of char;

BEGIN

  ThisString.Init;

  readln (temp);
  WHILE Temp <> '' DO BEGIN
    ThisString.enqueue (Temp);
    readln (temp);
  END; (* of WHILE *)

  getmem (blah, MaxStrLen);
  fillchar (blah^, MaxStrLen, #0);


  WHILE (NOT ThisString.Empty) and (strlen (blah) < (MaxStrLen - 81)) DO BEGIN
    ThisString.dequeue (Temp);
    StrPCopy (T2, Temp);
    StrLCat (blah, T2, MaxStrLen);
    StrLCat (blah, #13#10, MaxStrLen);
  END; (* of WHILE *)

  write (blah);

  freemem (blah, MaxStrLen);

  readln;
END.
