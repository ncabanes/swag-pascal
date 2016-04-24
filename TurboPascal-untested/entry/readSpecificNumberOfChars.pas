(*
  Category: SWAG Title: INPUT AND FIELD ENTRY ROUTINES
  Original name: 0028.PAS
  Description: read specific Number of Chars
  Author: CHRIS AUSTIN
  Date: 11-22-95  15:50
*)


Uses CRT;

Function ReadIn(Len : Byte) : String;
Var Inkey   : Char;
    InString: String[255];
Begin
 Instring:='';
 Repeat
  Inkey:=ReadKey;
  If (Inkey=#8)           and
     (Length(InString)>0) then Begin
                                Dec(InString[0]);
                                Write(#8#32#8);
                               End;
 If (Inkey<>#13) and
    (Inkey<>#8) then
                  If Length(InString)<Len  then Begin
                                                 InString:=InString+InKey;
                                                 Write(InKey);
                                                  End
                                              Else
                                           Begin
                                            Write(#7);
                                            Instring[Length(Instring)]:=Inkey;
                                            Write(#8,Inkey);
                                           End;
 Until Inkey=#13;
 WriteLn;
 ReadIn:=InString;
End;

Var
 Insring : String;
Begin
ClrScr;
Insring:=ReadIn(10);
WriteLn(Insring);
Repeat Until Keypressed;
End.

