
{$Q-,R-}
{
 THIS PROGRAM IS COPYRIGHTED BY BOJAN LANDEKIC AND IS MADE AVAILABLE TO
 ALL PASCAL PROGRAMMERS WHO WANTED AN EASY WAY OF CREATING BITMAPS FOR USAGE
 IN THEIR PROGRAMS.  I DID THIS AS I WAS SICK AND TIRED OF USING THE PASCAL
 EDITOR FOR PUTTING IN THE 0's AND 1's :)..

 IF YOU FIND A WAY OF IMPROVING IT, PLEASE LET ME KNOW SO THAT I MAY MAKE THE
 NEXT VERSION.  PLEASE DO NOT RELEASE YOUR MODIFIED VERSION.

 THANK YOU

 THIS SHOULD BE INCLUDED IN SWAG WITHOUT THIS LINE  (BUT WITH ABOVE LINES!)
}

Program Convert_PCX;
{converts .PCX files to pascal loadable images}
Uses StrIO,
     ModeX,
     Pcx,
     Fade,
     Crt;

Var
   IncFile: Text;          {includable file}
   R,
   G,
   B,                    {pallete}
   Count   : Byte;       {for counting 80 chars}
   X,
   Y      : Word;        {picture}
   Piece  : String;   {part used from string}
   max_x,
   C,
   max_y  : Word;

Var
   xR,
   xB,
   xG     : Byte;

BEGIN
     If ParamCount = 0 Then
        Begin
             Writeln;
             Writeln('USAGE: C_PCX [FILENAME.PCX] [FILENAME.PAS] [X] [Y]');
             Writeln;
             Writeln('FILENAME.PCX - Contains the FULL path, filename and extensions of the PCX');
             Writeln('FILENAME.PAS - Is the name of the UNIT without the extension');
             Writeln('               Unit will be called FILENAME, and your things inside it');
             Writeln('               will be called PAL_FILENAME for Pallete, and IMG_FILENAME');
             Writeln('               will contain the image (see TEST_P.PAS)');
             Writeln('X            - Up to what X to convert');
             Writeln('Y            - Down to what Y to convert');
             Writeln;
             Writeln;
             Halt(1);
        End;

     Assign(incFile, ParamStr(2) + '.PAS');
     Rewrite(IncFile);
     Init_VGA;
     Show_PCX(ParamStr(1));
     Piece := ParamStr(2);
     Max_X := ATOI(ParamStr(3));
     Max_Y := ATOI(ParamStr(4));
     {saves the palette}
     Writeln(IncFile);
     Writeln(IncFile, 'UNIT ' + ParamStr(2) + ';');
     Writeln(IncFile);
     Writeln(IncFile);
     Writeln(IncFile, 'INTERFACE');
     Writeln(IncFile);
     Writeln(IncFIle, '{The palette data}');
     Writeln(IncFIle, 'CONST ', Piece, '_Pal : Array [0..255, 1..3] Of Byte = (');


     For X := 0 To 255 Do
         Begin
              GetCol(X, xR, xG, xB);
              If X = 255 Then
                 Begin
                      Write(Incfile, '(', xR, ',');
                      Write(Incfile, xG, ',');
                      Writeln(Incfile, xB, '));');
                 End
              Else
                  Begin
                       Write(Incfile, '(', xR, ',');
                       Write(Incfile, xG, ',');
                       Writeln(Incfile, xB, '),');
                  End;
              SetCol(X, xR, xG, xB);
         End;
     Writeln(IncFile);
     Writeln(IncFIle, '{The picture data}');
     Writeln(IncFile, 'CONST ', Piece, '_X = ', Max_X, ';');
     Writeln(IncFile, 'CONST ', Piece, '_Y = ', Max_Y, ';');
     Writeln(IncFIle, 'CONST ', Piece, '_Img : Array [0..', Max_X - 1, ', 0..', Max_Y - 1, '] Of Byte = (');
     {saves the picture}
     Count := 0;
     DirectVideo := False;
     TextColor(15);
     For Y := 0 To Max_Y - 1 Do
         Begin
              Write(IncFile, '(');
              For X := 0 To Max_X - 1 Do
                  Begin
                       Inc(Count);
                       C := GetPix(X, Y, View_Page);
{                       If (X = (Max_X - 1) DIV 2) Then
                          Writeln(IncFile, '');}
                       If (X = Max_X - 1) Then
                          Write(IncFIle, C)
                       Else
                           Write(IncFile, C, ',');
                       SetPix(X, Y, C - 15, View_Page);
                  End;
              If (Y = Max_Y - 1) AND (X = Max_X - 1) Then
                 Writeln(IncFile, ')')
              Else
                  Writeln(IncFile, '),');
         End;
     Writeln(IncFile, ');');
     Writeln(IncFile);
     Writeln(IncFile, 'IMPLEMENTATION');
     Writeln(IncFile);
     Writeln(IncFile, 'BEGIN');
     Writeln(IncFile, 'END.');
     Writeln(IncFile);
     Init_Text;
     Close(IncFile);
END.
