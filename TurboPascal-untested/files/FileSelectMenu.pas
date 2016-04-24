(*
  Category: SWAG Title: FILE HANDLING ROUTINES
  Original name: 0101.PAS
  Description: File Select Menu
  Author: AVONTURE CHRISTOPHE
  Date: 03-04-97  13:18
*)

{

   File select menu unit.  Something like a FileListBox unit.

   You can select a file from a listbox and change directory or disk if 
   needed (and allowed by the programmer: see the Attribut propertie.)

   Remarks
   -------

       The (Y1 - Y0) value must be greater than 15.  This means that the
           number of columns of the file select window must be at least of
           16 characters.
       The flTouche will be used in order to know which key the user has
           pressed (13 for Enter key, 59 for F1 key, and so on)
       The Escape key or F10 key will terminate the selection without any
           filename in return of the function

               ╔════════════════════════════════════════╗
               ║                                        ║░
               ║          AVONTURE CHRISTOPHE           ║░
               ║              AVC SOFTWARE              ║░
               ║     BOULEVARD EDMOND MACHTENS 157/53   ║░
               ║           B-1080 BRUXELLES             ║░
               ║              BELGIQUE                  ║░
               ║                                        ║░
               ╚════════════════════════════════════════╝░
               ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░


    This is one of my very best unit.  Please send me a postcard if you find
    it usefull.  Thanks in advance!

    ==> Hey, is there somebody  in the United States of America?  I have <==
    ==> received postcard from severall country but none from the States <==
    ==>                           Be the first!                          <==

}

Unit FileList;

Interface

Const FlTouche : Byte = 0;                 { Key that the user has pressed }
      FName    : String = '';                          { Selected filename }

Type Str14 = String[14];

     FileListP = Record
       X0, X1, Y0, Y1 : Byte;                         { Window coordinates }
       TAttr          : Byte;                        { Color of the window }
       TBarre         : Byte;                    { Color of the select bar }
       Masque         : Str14;                   { Mask - *.*,  *.BAT, ... }
       Attribut       : Word;    { File attribut: only files matching this }
                                              { attribut will be displayed }
       ChgRep         : Boolean; { Do we must return to the original path? }
     End;


{ The only public function. }

Function GetFName (Donnees : FileListP) : String;

Implementation

Uses Crt, Dos;

Type TCadre     = Array [1..8] of Char;

Const Double    : Tcadre = ('╔','═','╗','║','║','╚','═','╝');
      MaxFich = 1024;                       { Max number of displayed file }

Var NbrFich : Byte;                                 { File number per line }
    NbrF    : Byte;                                     { Working variable }
    NbrFRep : Word;                 { Number of file find in the directory }
    TabF    : Array [1..MaxFich] of Str14;              { The directory... }
    I, J    : Byte;
    DosFich : SearchRec;
    Rep     : Byte;
    Disque  : Byte;
    MaxF    : Byte;
    X_Barre : Byte;
    Y_Barre : Byte;
    wPos     : Byte;
    TBack   : Byte;
    Complet : Boolean;                          { Is there several screen? }
    RepAct  : String;

{ This function will return True if the disk exist, false otherwise }

Function Disque_Exist (Disq: Byte) : Boolean; Assembler;
Asm
             Push Ds

             Cmp Disq, 2                  { Test if this is a floppy drive }
             Jbe @@A_or_B

             Mov Ax, 4409h                     { Hard disk or network one? }
             Mov Bl, Disq
             Int 21h

             Jc  @@False

             Mov Ax, 1
             Jmp @@Fin

@@A_or_B:    Mov Ah, 44h
             Mov Al, 0Eh
             Mov Bl, Disq
             Int 21h

             Cmp Al, Disq
             Jnz @@False

             Mov Ax, 1

             Jmp @@Fin

@@False:     Mov Ax, 1500h                     { Test if the disk is a CD }
             Mov Bx, 0000h
             Int 2Fh

             Xor Ax, Ax

             Cmp Bx, 0
             Jz @@Fin

             Inc Cl
             Cmp Cl, [Disq]
             Jne @@Fin

             Mov Ax, 1

@@Fin:       Pop Ds

End;

{ Write a string at the specified screen coordinates and with the given
  color attribut
}

Procedure WriteStrXY (X, Y, TAttr, TBack : Word; Texte : String);

Var Offset   : Word;
    i        : Byte;
    Attr     : Word;

Begin

    offset := Y * 160 + X Shl 1;
    Attr := ((TAttr+(TBack Shl 4)) shl 8);

    For i:= 1 to Length (Texte) do Begin
        MemW[$B800:Offset] := Attr or Ord(Texte[i]);
        Inc (Offset,2);
    End;

End;

{ Return the full filename }

Function TrueName (FName : String) : String;

Var Temp : String;
    Regs : Registers;

Begin

  FName := FName + #0;

  Regs.Ah := $60;
  Regs.Ds := Seg(FName);
  Regs.Si := Ofs(FName[1]);
  Regs.Es := Seg(Temp);
  Regs.Di := Ofs(Temp[1]);
  Intr ($21, Regs);

  DosError := Regs.Ax * ((Regs.Flags And FCarry) shr 7);

  Temp[0] := #255;
  Temp[0] := Chr (Pos(#0, Temp) - 1);

  If DosError <> 0 then
    Temp := '';

  TrueName := Temp;

end;

{ Read a character on the screen at the specified coordinates
}

Procedure ReadCar (X, Y : word;Var Attr : Byte; Var Carac : Char);

var Car      : ^char;
    Attribut : ^Byte;

Begin

     New (car);
     Car := ptr ($B800,(Y*160 + X Shl 1));
     Carac := car^;
     New (attribut);
     Attribut := ptr ($B800,(Y*160 + X Shl 1 + 1));
     Attr := attribut^;

End;

{ Draw a cadre
}

Procedure Cadre (ColD, LigD, ColF, LigF, Attr, Back : Byte; Cad : TCadre);

Var
   X, Y, I, Longueur, Hauteur : Byte;
   sLine : String;

Begin

     X := WhereX;  Y := WhereY;
     Longueur := (ColF-ColD)-1;
     Hauteur  := (LigF-LigD)-1;

     WriteStrXy (ColD, LigD, Attr, Back, Cad[1]);

     FillChar (sLine[1], Longueur, Cad[2]);
     sLine [0] := Chr(Longueur);
     WriteStrXy (ColD+1, LigD, Attr, Back, sLine);

     WriteStrXy (ColD+1+Longueur, LigD, Attr, Back, Cad[3]);

     For i:= 1 To Hauteur Do Begin
         WriteStrXy (ColD, LigD+I, Attr, Back, Cad[4]);

         FillChar (sLine[1], Longueur, ' ');
         sLine [0] := Chr(Longueur);
         WriteStrXy (ColD+1, LigD+I, Attr, Back, sLine);

         WriteStrXy (ColD+1+Longueur, LigD+I, Attr, Back, Cad[5]);
     End;

     WriteStrXy (ColD, LigF, Attr, Back, Cad[6]);

     FillChar (sLine[1], Longueur, Cad[7]);
     sLine [0] := Chr(Longueur);
     WriteStrXy (ColD+1, LigF, Attr, Back, sLine);

     WriteStrXy (ColD+1+Longueur, LigF, Attr, Back, Cad[8]);

     GotoXy (X, Y);

End;

{ Fill the TabF array with the name of each file found in the directory
}

Procedure SearchCurrentDir (Masque : Str14; Attribut : Word);

Begin

   FillChar (TabF, SizeOf (TabF), ' ');             { Initialize the array }

   I := 1; Disque := 0;

   If Disque_Exist  (1) then Begin TabF[I] := '[A:..]'; Inc (I); Inc (Disque); End;
   If Disque_Exist  (2) then Begin TabF[I] := '[B:..]'; Inc (I); Inc (Disque); End;
   If Disque_Exist  (3) then Begin TabF[I] := '[C:..]'; Inc (I); Inc (Disque); End;
   If Disque_Exist  (4) then Begin TabF[I] := '[D:..]'; Inc (I); Inc (Disque); End;
   If Disque_Exist  (5) then Begin TabF[I] := '[E:..]'; Inc (I); Inc (Disque); End;
   If Disque_Exist  (6) then Begin TabF[I] := '[F:..]'; Inc (I); Inc (Disque); End;
   If Disque_Exist  (7) then Begin TabF[I] := '[G:..]'; Inc (I); Inc (Disque); End;
   If Disque_Exist  (8) then Begin TabF[I] := '[H:..]'; Inc (I); Inc (Disque); End;
   If Disque_Exist  (9) then Begin TabF[I] := '[I:..]'; Inc (I); Inc (Disque); End;
   If Disque_Exist (10) then Begin TabF[I] := '[J:..]'; Inc (I); Inc (Disque); End;
   If Disque_Exist (11) then Begin TabF[I] := '[K:..]'; Inc (I); Inc (Disque); End;
   If Disque_Exist (12) then Begin TabF[I] := '[L:..]'; Inc (I); Inc (Disque); End;
   If Disque_Exist (13) then Begin TabF[I] := '[M:..]'; Inc (I); Inc (Disque); End;
   If Disque_Exist (14) then Begin TabF[I] := '[N:..]'; Inc (I); Inc (Disque); End;
   If Disque_Exist (15) then Begin TabF[I] := '[O:..]'; Inc (I); Inc (Disque); End;
   If Disque_Exist (16) then Begin TabF[I] := '[P:..]'; Inc (I); Inc (Disque); End;
   If Disque_Exist (17) then Begin TabF[I] := '[Q:..]'; Inc (I); Inc (Disque); End;
   If Disque_Exist (18) then Begin TabF[I] := '[R:..]'; Inc (I); Inc (Disque); End;
   If Disque_Exist (19) then Begin TabF[I] := '[S:..]'; Inc (I); Inc (Disque); End;
   If Disque_Exist (20) then Begin TabF[I] := '[T:..]'; Inc (I); Inc (Disque); End;
   If Disque_Exist (21) then Begin TabF[I] := '[U:..]'; Inc (I); Inc (Disque); End;
   If Disque_Exist (22) then Begin TabF[I] := '[V:..]'; Inc (I); Inc (Disque); End;
   If Disque_Exist (23) then Begin TabF[I] := '[W:..]'; Inc (I); Inc (Disque); End;
   If Disque_Exist (24) then Begin TabF[I] := '[X:..]'; Inc (I); Inc (Disque); End;
   If Disque_Exist (25) then Begin TabF[I] := '[Y:..]'; Inc (I); Inc (Disque); End;
   If Disque_Exist (26) then Begin TabF[I] := '[Z:..]'; Inc (I); Inc (Disque); End;

                             { Test if we can show path name or only file? }
   If ((Attribut and 16) = 16) then Begin          { We can show path name }

      Rep := 0;

      FindFirst ('*.*', 16, DosFich);

      FindNext (DosFich);

      While DosError = 0 do Begin

        If (DosFich.Attr and Directory = Directory) then Begin

           { We have found a directory }

           TabF[I] := '<'+DosFich.Name+'>';

           Inc (I);

           Inc (Rep);

        End;

        FindNext (DosFich);

      End;

   End;

   { Clear the attribute bit of Directory only }

   Attribut := Attribut and not 16;

   { Test if we can show file name or not }

   If Not (Attribut = 0) then Begin                { We can show file name }

     FindFirst (Masque, Attribut, DosFich);

     While DosError = 0 do Begin

         If Not (DosFich.Attr and Attribut = 0) then Begin
           TabF[I] := DosFich.Name;
           Inc (I);
         End;
         FindNext (DosFich);
     End;

   End;

   NbrFRep := I - 1;

End;

{ Write the filename or the path name
}

Procedure Prompt (X , Y, TAttr : Byte; Option : Str14);
Begin
   GotoXY (X,Y);
   WriteStrXy (X, Y, TAttr, 0, Option);
End;

{ Give the possibility to the user to select a name. }

Function MChoix (X0, Y0, X1, Y1, X, Y, TAttr, TBarre : Byte) : String;

{ Handle the select bar
}

Procedure SurBrillance (X, TBarre : Byte);

Var Attribut : Word;
    Offset   : Word;
    i        : Byte;
    Lig      : Str14;
    Attr     : Byte;
    Chh      : Char;

Begin

     offset := Y * 160 + X * 2;

     Lig := '';

     For I := 0 to 12 Do Begin
         ReadCar (X+I, Y, Attr, Chh);
         Lig := Lig + Chh;
     End;

     For i:= 1 to 13 do Begin
         MemW[$B800:Offset] := (TBarre shl 8) or Ord(Lig[I]);
         Inc (Offset,2);
     End;

End;

{ Construct the screen with the bar and the file/path name
}

Procedure Affiche (X0, Y0 : Byte; Depart : Word);

Begin

   GotoXy (0,2); NbrF := 0; wPos := Depart;
   X_Barre := X0+2; Y_Barre := Y0+1;

   For J := Depart to (Depart+(MaxF*NbrFich)-1) do Begin

      If Not (J > NbrFRep) then Prompt (X_Barre, Y_Barre, TAttr, TabF[J]+'                   ')
      Else Prompt (X_Barre, Y_Barre, TAttr, '                      ');

      Inc (NbrF);

      If Not (NbrF < NbrFich) then Begin

         Inc (Y_Barre);
         X_Barre := X0 + 2;
         NbrF := 0;

      End
      Else Inc (X_Barre, 13);

   End;

End;

{ Main of MChoix function }

Var
   Ch : Char;

Begin

   GotoXy (X, Y);

   wPos := 1;

   SurBrillance (X, TBarre);

   Repeat

       Ch := Readkey; If Ch = #0 then Ch := Readkey;

       SurBrillance (X, TAttr);

       Case Ch Of

        #72 : Begin        {UpKey}
                 If Complet then Begin
                   If (wPos - NbrFich - 1 < NbrFRep) then Begin
                      Dec (Y); Dec (wPos, NbrFich);
                   End;
                 End
                 Else
                  If ((Y-1 = Y0) and (Not (wPos - 1 < NbrFich))) then Begin
                        wPos := wPos - (((X - X0) Div 13));
                        Affiche (X0, Y0, Abs(wPos-(NbrFich*MaxF)));
                        X := X0 + 2;
                        Y := Y0 + 1;
                  End
                  Else If Not (wPos - NbrFich - 1 < 0) then Begin
                      Dec (Y); Dec (wPos, NbrFich);
                  End
                  Else If Not (wPos - 1 > NbrFRep) then Begin
                      If (wPos - NbrFich - 1 < NbrFRep) then Begin
                         Dec (Y); Dec (wPos, NbrFich);
                      End;
                   End;
              End;
        #80 : Begin        {DownKey}
                 If Complet then Begin
                   If (wPos + NbrFich -1 < NbrFRep) then Begin
                      Inc (Y); inc (wPos, NbrFich);
                   End
                 End
                 Else
                  If (wPos + NbrFich - 1 < NbrFich*MaxF) then Begin
                      Inc (Y); inc (wPos, NbrFich);
                  End
                  Else If (Y+1 = Y1) then Begin
                        wPos := wPos - (((X - X0) Div 13));
                        Affiche (X0, Y0, wPos+NbrFich);
                        X := X0 + 2;
                        Y := Y0 + 1;
                   End
                   Else If Not (wPos + 1 > NbrFRep) then Begin
                      If (wPos + NbrFich  - 1< NbrFRep) then Begin
                         Inc (Y); inc (wPos, NbrFich);
                      End;
                   End;
              End;
        #77 : Begin        {Right}
                 If Complet then Begin
                   If Not (wPos+1 > NbrFRep) then Begin
                     If Not (X + 13 > (X0+(NbrFich-1)*(13)+2)) then Begin
                      Inc (X, 13); Inc (wPos);
                     End
                     Else If Not (Y > Y0 + (NbrFRep Div NbrFich)) then Begin
                       X := X0 + 2; Inc (Y); Inc (wPos);
                     End;
                   End
                 End
                 Else Begin
                   If Not (wPos+1 > NbrFich*MaxF) then Begin
                     If Not (X + 13 > (X0+(NbrFich-1)*(13)+2)) then Begin
                      Inc (X, 13); Inc (wPos);
                     End
                     Else If Not (Y > Y0 + (NbrFich*MaxF Div NbrFich)) then Begin
                       X := X0 + 2; Inc (Y); Inc (wPos);
                     End;
                   End
                   Else If ((Y+1 = Y1) and ((((X - X0) Div 13 ) +  1) = NbrFich)) then Begin
                        Affiche (X0, Y0, wPos+1);
                        X := X0 + 2;
                        Y := Y0 + 1;
                   End
                   Else If Not (wPos + 1 > NbrFRep) then Begin
                     If Not (X + 13 > (X0+(NbrFich-1)*(13)+2)) then Begin
                      Inc (X, 13); Inc (wPos);
                     End
                     Else If Not (Y > Y0 + (NbrFich*MaxF Div NbrFich)) then Begin
                       X := X0 + 2; Inc (Y); Inc (wPos);
                     End;
                   End;
                 End
              End;
        #75 : Begin        {Left}
                If Complet then Begin
                  If Not (X = X0+2) then Begin
                     Dec (X, 13); Dec (wPos);
                  End
                  Else If Not (Y < Y0 + 2) then Begin
                     X := X0+((NbrFich-1)*(13)+2);
                     Dec (Y); Dec (wPos);
                  End;
                End
                Else
                  If ((Y-1 = Y0) and ((((X - X0) Div 13) = 0)) and Not (wPos = 1)) then Begin
                        wPos := wPos - (((X - X0) Div 13));
                        Affiche (X0, Y0, Abs(wPos-(NbrFich*MaxF)));
                        X := X0 + 2;
                        Y := Y0 + 1;
                  End
                  Else If Not (X = X0+2) then Begin
                       Dec (wPos); Dec (X, 13);
                  End
                  Else If Not (Y < Y0 + 2) then Begin
                     X := X0+((NbrFich-1)*(13)+2);
                     Dec (Y); Dec (wPos);
                  End;
              End;
       End;

       GotoXy (X, Y);

       SurBrillance (X, TBarre);

       { Only Enter key, Escape key or Function key (F1-F10) can stopped
         the selection
       }

   Until (Ch in [#13, #27, #59..#68]);

   { FLTouche retains the value of the pressed key }

   FLTouche := Ord(Ch);

   { If the pressed key is not F10 or Escape then return the filename }

   If ((Ch = #27) or (Ch = #68)) then MChoix := ''
   Else MChoix := TabF[wPos];

End;

{ The only function public.
}

Function GetFName (Donnees : FileListP) : String;

Var FinJ   : Word;
    NomRep : String;

Begin

   TBack := TextAttr;

   With Donnees Do Begin

     TextAttr := TAttr;

     { The window must be at least 17 columns great }

     If (X1 - X0 < 16) then X1 := X0 + 16;

     { Process the number of file per line }

     NbrFich := ((( X1 - X0) - 2) Div 13);

     Repeat

       { Show the current directory }

       SearchCurrentDir (Masque, Attribut);

       MaxF := Y1 - Y0 - 1;

       { Draw a cadre on the screen
       }

       Cadre (X0, Y0, X1, Y1, (TAttr And $F), (TAttr Shr 4), Double);

       X_Barre := X0 + 2;
       Y_Barre := Y0 + 1;

       NbrF := 0;

       If (NbrFRep > MaxF * NbrFich) then Begin
            FinJ := MaxF*NbrFich;
            Complet := False;
       End
       Else Begin
            FinJ := NbrFRep;
            Complet := True;
       End;

       For J := 1 to FinJ do Begin

         Prompt (X_Barre, Y_Barre, TAttr, TabF[J]);
         Inc (NbrF);

         If Not (NbrF < NbrFich) then Begin

             Inc (Y_Barre);
             X_Barre := X0 + 2;
             NbrF := 0;

         End
         Else Inc (X_Barre, 13);

       End;

       { Give the possibility to the user to select a file/path name or
         another disk }

       FName := MChoix (X0, Y0, X1, Y1, X0+2, Y0+1, TAttr, TBarre);

       gotoxy (0,0);

       If Not ((FLTouche = 27) or (FLTouche = 68)) then Begin

          If Not (wPos > Disque + Rep) then Begin

             { The user has pressed the Enter key on a disk specification or
               on a path name }

             FName := ''; FLTouche := 0;

          End;

          If Not (wPos > Disque) then Begin

             { Change the active disk }

             NomRep := Copy (TabF[wPos], 2, 2);

             {$I-}
             ChDir (NomRep);
             {$I+}

          End

          Else If Not (wPos > Disque+Rep) then Begin

             { Change the current path }

             NomRep := Copy (TabF[wPos], 2, Length(TabF[wPos]) - 2);

             {$I-}
             ChDir (NomRep);
             {$I+}

          End;

       End

       Else ChDir (RepAct);

   Until Not ((FLTouche = 0) and (FName = ''));

   { Return the selected file name }

   If Not (FName = '') then GetFName := TrueName (FName)
   Else GetFName := FName;

   If ChgRep then ChDir (RepAct);

   End;

   TextAttr := TBack;

End;

Begin

    RepAct := TrueName (ParamStr(0));              { Save the current path }

    For J := Length (RepAct) Downto 1 do
        If RepAct[J] = '\' then Begin
           I := J;
           J := 1;
        End;

    RepAct := Copy (RepAct, 1, I-1);

End.

{  ----------------------------- cut here -------------------------------- }
{

   Example of the file select menu unit


               ╔════════════════════════════════════════╗
               ║                                        ║░
               ║          AVONTURE CHRISTOPHE           ║░
               ║              AVC SOFTWARE              ║░
               ║     BOULEVARD EDMOND MACHTENS 157/53   ║░
               ║           B-1080 BRUXELLES             ║░
               ║              BELGIQUE                  ║░
               ║                                        ║░
               ╚════════════════════════════════════════╝░
               ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

}

{ Include the FileList unit }

Uses Crt, Filelist;

{ What you must do: declare a variable based on the FileListP type and 
  initialized it in your code }

Var FFilelist : FileListP;
    NomF      : String;          { Stored the full name of the selected file }

Begin

   ClrScr;

   { If you set the Attribut  propertie to "AnyFile - VolumeId - Directoy"
     then the user can't  change directory.  So he must select a file from
     the current directory with no possibility to go to other directory or
     disk!  For a list  of value, see  the SearchRec  function in the  DOS 
     unit: values used by my unit are the same. 

     Remember that the (Y1 - Y0) value must be greater than 15.  If no, the
     unit will automatically set the Y1 value to (15 - Y0) + Y1.

     The Masque propertie is the DOS match pattern: works exactly like the
     SearchRec function. 

     The TAttr value represent the color -0 to 255- of the window.  Exactly
     like the Attr CRT variable.

     The TBarre value represent the color -0 to 255- of the main bar: the bar
     with it you can select a file, directory or drive. Exactly like the Attr
     CRT variable. 

     You the  user  has  select  a  file (and  perhaps changed  drive  and/or 
     directory), the ChgRep  value specifies to your program if the unit must
     go back to  the original path  after the selection or not.  The original 
     path is the current path  just before the GetFName  function is called. }

   With FFileList Do Begin

       X0       := 6;       { Size                    }
       X1       := 78;      {         of              }
       Y0       := 3;       {             the         }
       Y1       := 17;      {                  window }
       TAttr    := 30;      { window color attribut   }
       TBarre   := 57;      { bar color attribut      }
       Masque   := '*.*';   { File Mask               }
       Attribut := $3F-$08; { AnyFile - VolumeId      }
       ChgRep   := True;    { Return to original path }

   End;

   { Call the filename selector }

   NomF := GetFName (FFileList);

   { Here a file has been selected and his full name if stored in NomF. }

   ClrScr;

   { And show the selected file name.
   
     A file is select only the user press on the Enter key under the filename.

     If the user has pressed the Escape Key or a function key (from F1 to F10),
     then the result of the GetFName function is emtpy.  So, in this example, 
     the NomF variable is equal to "" and the flTouche is set to the ASCII 
     value of the Key: 13 if Enter, 27 if Escape, 59 if F1, 60 if F2, ...

     The flTouche variable is declared in the unit so don't declared it again }

   Writeln ('Selected file : ',NomF,' ... Key pressed (ASCII value) ',flTouche);

End.
