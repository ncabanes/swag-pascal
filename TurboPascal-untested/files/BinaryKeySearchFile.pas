(*
  Category: SWAG Title: FILE HANDLING ROUTINES
  Original name: 0016.PAS
  Description: Binary Key Search - File
  Author: SWAG SUPPORT TEAM
  Date: 06-08-93  08:25
*)

{===========================================================================
 BBS: Canada Remote Systems
Date: 05-31-93 (20:29)             Number: 24331
From: HERB BROWN                   Refer#: NONE
  To: ERIC GIVLER                   Recvd: NO
Subj: USERS FILE                     Conf: (1221) F-PASCAL
---------------------------------------------------------------------------
On this day, <May 28 17:32>, Eric Givler (1:270/101.15@fidonet) noted:
 EG> How would this help?  You'd still have to search the entire
 EG> INDEX file LINEARLY, correct?  Or would you have the INDEX sorted?
 EG> If so, how would you keep it sorted?  More input would REALLY be
 EG> appreciated!

This is code for a binary "split and search" method.   Anyways, thats just
something I call it.  Actually, it's a rudimentary binary search.

Suppose you had a key record of                                           }

 key = record
 reference : Longint;  { room for a lot of records }
 KeySearchField : String30; { The key string to be stored}
 end;     { Note, several smaller strings could be put together to make the
            search critical, i.e., keysearchField:=First+second+ThirdName;
            As long as the field length stays less than or equal to what you
         defined }

{Then using a function that would return a boolean value, i.e., true if data
matches, false if not found, then it would look like so.. }

Function FindKey( VAR  AKey : AKeyFile;
                  VAR  AKeyRef : Longint;
                       FindMe : String80): Boolean;

VAR High,Low,Mid : Longint;  { For collision processing }
     Target : Key;
     Gotit  : Boolean;
     Collison : Boolean;
     NumRecs  : Longint;


begin
 AKeyRef :=0;
 NumRecs := FileSize(AKey);  {Get the number of records stored in file}

 High := NumRecs;
 Low := 0;
 Mid := (Low + High) DIV 2 { Split point }
 FindKey := False;
 Gotit := False;
 Collision := False;
 If NumRecs > 0 Then {the file is not empty }
  Repeat
   Seek(AKey,Mid);
   Read(Akey,Target);
   {Was there a position collision ??}
   IF (Low = Mid) OR (High = Mid) the Collision := True;
     IF Findme := Target.KeySearchField Then { Yay ! }
         begin
          Gotit := True;
          FindKey := True;
          AKeyRef := Target.Reference;
        End
    Else  { Divide in half and try it again..}
     Begin
      If FindMe > Target.KeySearchField then Low := Mid
       Else High := Mid;
      Mid := (Low + High + 1) DIV 2;
      AKeyRef := Mid
    End
 Until Collision or Gotit;
End;

(*
This is a working example.  There are some minor precautions that need to be
noted, though.   This will only work on sorted data, for one.  The data can be
sorted with a Quick Sort and the key file re-written in sorted order.   The
advantage here is the actual data file need not be sorted at all.

Any time you work with a data base, get into the habit of ALWAYS including a
deleted tag field.  The above example lacks this, though.

This is just one of many ways of searching a database.  Professional <grin>
applications would probably be better suited for AVL trees or Btrees.

Building an array "cache" helps speed up processing as well.  That is whole
'nuder ball game, though.. *)

