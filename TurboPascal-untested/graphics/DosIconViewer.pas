(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0252.PAS
  Description: Dos Icon Viewer
  Author: AVONTURE CHRISTOPHE
  Date: 03-04-97  13:18
*)

{

   Dos icon viewer


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

Uses Crt, Dos;

CONST
   IcoSize = 32;  { An icon is a 32*32 square }

VAR
   arrNom : Array[1..255] of String[12]; { Store the full filename }

{ Display a pixel }

Procedure Put_Pixel (Colonne, Ligne, Couleur : Word); Assembler;
Asm
     Mov  Ah, 0Ch
     Mov  Al, Byte Ptr Couleur
     Mov  Cx, Colonne
     Mov  Dx, Ligne
     Xor  Bh, Bh
     Int  10h
End;

{ Display the given icon file to the given coordinates }

Procedure Show_Ico   (sFileName : String; wColumn, wLine : Word);

Type
   TIconRec = Array[0..1023] of Byte;
   TIcon    = ^TIconRec;

Var
   Color    : Byte;
   fIcon    : File;
   I, J     : Word;
   Icon     : TIcon;

Begin

   Assign (fIcon, sFileName);
   FileMode := 0;                           { Read only }
   Reset  (fIcon, 1);

   GetMem (Icon, 1024);                    { Allocate memory for the icon }

   BlockRead (fIcon, Icon^, 126);

   For I := 0 to 511 Do                     { Process the icon file }
       BEGIN
          BlockRead (fIcon, Color, 1);
          Icon^[I shl 1]       := Color Shr 4;
          Icon^[(I shl 1) + 1] := Color And $0F;
       END;

   Close (fIcon);

   wLine := wLine + icoSize;

   { Display the icon. }

   For J := 31 Downto 0 do
       For I := 31 Downto 0 do
          Put_Pixel (wColumn+I, wLine-J, Icon^[I+J Shl 5]);

   Release (Icon);                          { Release icon memory }

End;

{ Load all icon files present in the specified directory }

PROCEDURE Load_Icons;

VAR
   DosFile    : SearchRec;
   OldX, OldY : Word;
   I          : Byte;
   wPos       : Word;

BEGIN

   OldX := IcoSize; OldY := IcoSize; wPos := 0;

   FindFirst (Paramstr(1)+'\*.Ico', AnyFile, DosFile);

   WHILE DosError = 0 DO
      BEGIN

        { List all icon file and display it }

        Inc (wPos);

        arrNom[wPos] := DosFile.Name;

        Show_Ico (Paramstr(1)+'\'+DosFile.Name, OldX, OldY);

        { Process the screen coordinates for the next icon }

        IF OldX < (640-(IcoSize Shl 1)) THEN
           OldX := OldX + IcoSize
        ELSE
           BEGIN
              OldX := IcoSize;
              OldY := OldY + IcoSize;
           END;

        IF OldY = 14*IcoSize THEN
          BEGIN
             OldX := IcoSize;
             OldY := IcoSize;
             ClrScr;
          END;

        FindNext (DosFile);

   END;

END;

{ Main program }

BEGIN

   GotoXy (0,0);
   TextAttr := 10;
   Write ('IconView (c) AVONTURE Christophe    February 1996');

   { If a parameter is specified, supposed that this parameter is a path
     name and try to display all icon files present in this directory }

   IF NOT (ParamCount = 0) THEN
      BEGIN

         { Initialize graphic mode 640*480 256 colors }

         Asm
            Mov Ax, 0012h
            Int 10h
         End;

         Load_Icons;

         TextAttr := 15;

         REPEAT UNTIL KEYPRESSED; READKEY;

         { Restore 80*25 255 colors screen mode }

         Asm
            Mov Ax, 0003h
            Int 10h
         End;

       END
    ELSE
       BEGIN

           { No parameters has been given to the program.  So show a little
             help. }

           WriteLN ('');
           WriteLN ('');
           WriteLN ('');
           WriteLN ('You must specify the path where ICO files are stored.');
           WriteLN ('');
           WriteLN ('For instance, ICO_VIEW C:\WINDOWS\SYSTEM. ');
           WriteLN ('');
           WriteLN ('');

           REPEAT UNTIL KEYPRESSED; READKEY;

       END;

END.
