(*
  Category: SWAG Title: FILE HANDLING ROUTINES
  Original name: 0083.PAS
  Description: Record Scrolling
  Author: ROBERT MATSON
  Date: 11-22-95  15:50
*)

{
 ms> Does anybody have a database scroling rutine. When I say a database
 ms> scroling rutine I mean that you have som records which is longer than the
 ms> screen and then you need to scroll up or down to view the rest of it.

 ms> In the rutine you should could scroll up and down.

  Here is a copy of a sort of generic viewing routine incorporating most of
the VT100 keyboard commands, including home/end and pgup/pgdn.
}

Procedure PrintScr;

Type
   GenFile : String[80];

Var
   QuitBrowse : Boolean;
   BalString  : String[80];
   M, Lin, Top : Integer;
   Com, Key : Char;
   DtaLen   : Word;
   ViewFile : File of GenFile;

Begin
   ClrScr;
   QuitBrowse := False;
   Top := 0;

   Assign(ViewFile,'yourfile.txt');
   Reset(ViewFile);
   DtaLen := Filesize(ViewFile) -1;

   While Not QuitBrowse Do
     Begin
       For Lin := Top to (Top+24) Do
         Begin
           Seek(ViewFile,Lin);
           Read(ViewFile,LineData);
           RetrLine(DtaHandle,Lin);
           BalString[0] := #80;
           For M := 1 to 80 Do
             BalString[M] := LineData[M];
           QWrite((Lin-Top)+1,1,CfgData.IFo+CfgData.IBa,BalString);
         End;
       Com := ReadKey;
       Case Com Of
         #0:
            Begin
              Key := ReadKey;
              Case Key Of
                #73 : { PgUp }
                     Begin
                       Top := Top -24;
                       If Top < 0 Then Top := 0;
                     End;
                #81 : { PgDn }
                     Begin
                       Top := Top +24;
                       If Top > DtaLen Then
                          Top := DtaLen;
                     End;
                #72 : { Up Arrow }
                     Begin
                       Dec(Top);
                       If Top < 0 Then Top := 0;
                     End;
                #80 : { Dn Arrow }
                     Begin
                       Inc(Top);
                       If Top > DtaLen Then
                          Top := DtaLen;
                     End;
                #119,#132 : { ^Home / ^PgUp }
                      Top := 0;
                #117,#118 : { ^End / ^PgDn }
                      Begin
                        Top := DtaLen -5;
                        If Top < 0 Then Top := 0;
                      End;
              End; { Case Key }
            End; { Case #0 }

         #27: { ESC }
             QuitBrowse := True;

       End; { Case Com }
     End;

End; { Procedure PrintScr }


  You will, of course, need to modify the parameters and such to fit your own
needs. As a rule, I use this as a pattern for viewing routines, adjusting as
required for the type of material being displayed.

  Good luck,

RB


