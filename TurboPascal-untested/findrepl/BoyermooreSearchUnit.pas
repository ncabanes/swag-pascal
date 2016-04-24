(*
  Category: SWAG Title: SEARCH/FIND/REPLACE ROUTINES
  Original name: 0021.PAS
  Description: Boyer-Moore Search Unit
  Author: SWAG TEAM SUPPORT
  Date: 08-30-97  10:09
*)


Unit BMoore;

Interface

Type
  bigarray = Array [0..65520] Of
  Byte;
  baptr    = ^bigarray;
  BMTable  = Array [0..255] Of
  Byte;
  
  
Type  pBMSearchObj = ^bmsearchobj;
  bmsearchobj = Object
  Constructor Init (s:string);
  Function   Search (Var buff; size : Word) : Word;
  Destructor Done;

  Private
  Btable : BMTable;
  ss     : String;
End;

Implementation

Constructor bmsearchobj.Init (s:string);
  
Var
  st   : BMTable Absolute s;
  slen : Byte Absolute s;
  x    : Byte;
Begin
{  Move (s, ss, Byte (s) );}
  ss:=s;

  FillChar (Btable, SizeOf (Btable), slen);
  For x := slen DownTo 1 Do
      If (Btable [st [x] ] = slen) Then
         Btable [st [x] ] := slen - x
  End;

Function bmsearchobj.Search (Var buff; size : Word) : Word;

Var
  buffer : bigarray Absolute buff;
  s      : Array [0..255] Of byte Absolute ss;
  len    : Byte Absolute ss;
  s1     : String Absolute ss;
  s2     : String;
  count,
  x      : Word;
  found  : Boolean;
Begin
  s2 [0] := Chr (len);       
  found := False;
  
  count := Pred (len);
  While (Not found) And (count < (size - len) ) Do
        Begin
        If (buffer [count] = s [len]) Then 
           Begin
           If buffer [count - Pred (len) ] = s [1] Then 
              Begin
              Move (buffer [count - Pred (len) ], s2 [1], len);
              found := s1 = s2;                   
              Search := count - Pred (len);      
              End;
           Inc (count);                
           End
        Else
           Inc (count, Btable [buffer [count] ]);   
        End;
  If Not found Then
     Search := $ffff;
End;  

Destructor bmsearchobj.Done;
Begin
End;

End.

