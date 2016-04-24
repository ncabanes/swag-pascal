(*
  Category: SWAG Title: NOVELL/LANTASTIC NETWORK ROUTINES
  Original name: 0054.PAS
  Description: AS/400 to ASCII converter
  Author: TOBIAS SCHROEDEL
  Date: 08-30-97  10:09
*)

{
This code if herewith given to the public domain and may be used for and in
any situation needed. It may help you to convert AS/400 data to ASCII char
set.
It is not yet the fastest as I use a Blockread with 1 Byte only, but you
can optimize it yourself.
I will not take any responsibilty in any case if your data is not accurate
after usage or something is destroyed. Therefore compile it yourself and
it is your code.
Toby Schroedel
}
Program AS400_to_ASCII;
Uses
  Dos, Crt;

Const
  AS400Table : Array[0..255] of Integer =
{Note : Char #10 should normally be set to #0, because it is unknown,
 BUT as it is the LF command of an ASCII file it should transfer to #10
 also. Please change, if needed !}
(  0,  1,  2,  3,  0,  9,  0,127,  0,  0, 10, 11, 12, 13, 14, 15,
  16, 17, 18, 19,  0,  0,  8,  0, 24, 25,  0,  0, 28, 29, 30, 31,
   0,  0,  0,  0,  0, 10, 23, 27,  0,  0,  0,  0,  0,  5,  6,  7,
   0,  0, 22,  0,  0,  0,  0,  4,  0,  0,  0,  0, 20, 21,  0, 26,
  32, 32,131,132,133,160,166,134,135,164, 91, 46, 60, 40, 43,124,
  38,130,136,137,138,161,140,139,141,225, 93, 36, 42, 41, 59,170,
  45, 47,  0,142,  0,  0,  0,143,128,165,124, 44, 37, 95, 62, 63,
 237,144,  0,  0,  0,  0,  0,  0,  0, 96, 58, 35, 64, 39, 61, 34,
 237, 97, 98, 99,100,101,102,103,104,105,174,175,235,  0,  0,241,
 248,106,107,108,109,110,111,112,113,114,166,167,145,  0,146,  0,
 230,126,115,116,117,118,119,120,121,122,173,168,  0, 89,  0,  0,
  94,156,157,250,  0, 21, 20,172,171,  0, 91, 93,  0,  0, 39,  0,
 123, 65, 66, 67, 68, 69, 70, 71, 72, 73, 45,147,148,149,162,167,
 125, 74, 75, 76, 77, 78, 79, 80, 81, 82,  0,150,129,151,163,152,
  92,246, 83, 84, 85, 86, 87, 88, 89, 90,253,  0,153,  0,  0,  0,
  48, 49, 50, 51, 52, 53, 54, 55, 56, 57,  0,150,154,  0,  0,  0);

Var
  FIn, FOut : File;
  KeyPress,
  SIn, SOut : Char;
  FSize,
  Counter   : LongInt;
  ErrText   : String;

Function  Prozent(Ist, Gesamt : Real) : LongInt;
Begin;
  If Gesamt > 0
    Then Prozent:=Trunc(Ist / Gesamt *100)
    Else Prozent := 0;
End;

Function  FileExist(strn : String) : Boolean;
Var
  FileInfo : SearchRec;
Begin;
  FindFirst(Strn,AnyFile,FileInfo);
  If DosError=0 then FileExist:=TRUE else FileExist:=FALSE;
end;


Function Convert_AS400_to_ASCII ( S : Char ) : Char;
Var
  L : Integer;
  I : Byte;
  O : Char;
Begin;
  L := Ord( S );
  O := Chr( AS400Table[ L ] );
  Convert_AS400_to_ASCII := O;
End;


Begin;
  ClrScr;
  WriteLn('AS/400 to ASCII file converter');
  Writeln('- Freeware, no warranty, use at your own risk -');
  Writeln;
  ErrText := '';
  If ParamCount <> 2 Then Begin;
    ErrText := ErrText + 'Incorrect parameters.' + #13;
  End Else Begin
    If not FileExist( ParamStr( 1 )) Then ErrText := ErrText + 'Inputfile not found.'       + #13;
    If     FileExist( ParamStr( 2 )) Then ErrText := ErrText + 'Outputfile already exists.' + #13;
  End;
  If ErrText <> '' Then Begin;
    WriteLn('AS/400 to ASCII file converter');
    WriteLn('AS4_ASCI <Infile> <Outfile>');
    WriteLn( ErrText );
    Halt;
  End;
  Counter := 0;
  Assign( FIn , ParamStr( 1 ));
  Assign( FOut, ParamStr( 2 ));
  Reset( FIn, 1 );
  ReWrite( FOut, 1 );
  FSize   := FileSize( FIn );
  GotoXY(1,3);
  Write('Conversion progress : ');
  While not Eof(FIn) Do begin;
    If KeyPressed Then Begin;
      KeyPress := ReadKey;
      If KeyPress = #27 Then Exit;
    End;
    Inc( Counter );
    GotoXY( 23, 3 );
    Write( Prozent( Counter, FSize ), '%');
    BlockRead( FIn, SIn , 1);
    SOut := Convert_AS400_to_ASCII( SIn );
    BlockWrite( FOut, SOut, 1 );
  End;
  Close( FIn  );
  Close( FOut );
End.



