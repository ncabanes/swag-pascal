(*
  Category: SWAG Title: TEXT FILE MANAGEMENT ROUTINES
  Original name: 0049.PAS
  Description: Generalized Text handling
  Author: RICK HAINES
  Date: 02-28-95  10:10
*)

{

The fastest way to read screen characters is to get them from video
memory directly.  It's located at either Segment B800h (Color) or
Segment B000h (Monochrome).  Each character is stored as two bytes, the
Ascii code and an Attribute byte.  Here is some source if you are
confused.

{ ********************************************************** }
{ *********************** Text Unit ************************ }
{ ********************************************************** }
{ **************** Written by: Rick Haines ***************** }
{ **************************** 507 LakeShore Dr. *********** }
{ **************************** Eustis FL, 32726 ************ }
{ ********************************************************** }
{ ***************** Last Revised 11/12/94 ****************** }
{ ********************************************************** }

Unit Text;

{ ************************* Attribute Byte ************************* }
{ ****************************************************************** }
{ ************** Bits 0-3 contain the foreground color ************* }
{ ************** Bits 4-6 contain the background color ************* }
{ ******************** Bit 7 is the blink bit ********************** }
{ ****************************************************************** }

Interface

 Const
  Black  = 0;
  Blue   = 1;
  Green  = 2;
  Cyan   = 3;
  Red    = 4;
  Violet = 5;
  Orange = 6;
  Gray   = 8;

  LightGray   = 7;
  LightBlue   = 9;
  LightGreen  = 10;
  LightCyan   = 11;
  LightRed    = 12;
  LightViolet = 13;

  Yellow = 14;
  White  = 15;

  Blink   = 128;

 Procedure WriteXY(X, Y : Byte; TextStr : String);
 Procedure SetColor(Color : Byte);
 Procedure SetBGColor(Color : Byte);
 Procedure SaveScreen(Name : String);
 Procedure LoadScreen(Name : String);

Implementation
 Uses Crt;

 Type
  RefreshBuffer = Array[0..24,0..79] Of Word;

 Var
  TextMem   : ^RefreshBuffer;
  TextColor : Byte;

 Procedure SetColor(Color : Byte);
  Begin
   TextColor := TextColor Or Color;
  End;

 Procedure SetBGColor(Color : Byte);
  Begin
   If Color > 8 Then Exit;
    Asm
     Mov AL, [Color]
     Mov BL, [TextColor]
     RoR BL, 4
     Or  BL, AL
     RoL BL, 4
     Mov [TextColor], BL
    End;
  End;

 Function TextChar(Ch : Char) : Word; Assembler;
  Asm
   Mov AH, TextColor
   Mov AL, Ch
  End;

 Procedure WriteXY(X, Y : Byte; TextStr : String);
  Var
   I : Byte;
  Begin
   For I := 1 To Length(TextStr) Do TextMem^[Y,X+I-1] := TextChar(TextStr[I]);
  End;

 Procedure SaveScreen(Name : String);
  Var
   FileN : File;
  Begin
   Assign(FileN, Name + '.Scr');
   Rewrite(FileN, 2000);
   BlockWrite(FileN, TextMem^, 2);
   Close(FileN);
  End;

 Procedure LoadScreen(Name : String);
  Var
   FileN : File;
  Begin
   Assign(FileN, Name + '.Scr');
   Reset(FileN, 2000);
   BlockRead(FileN, TextMem^, 2);
   Close(FileN);
  End;

Begin
 If LastMode = Mono Then TextMem := Ptr($B000,$0000) Else TextMem := Ptr($B800,
 SetBGColor(Black);
 SetColor(LightGray);
End.


                                                Good Luck,

                                                -Rick


 * OLX 2.1 TD * With Pascal Do Write(Program);


--- QScan v1.12b / 01-0240
 * Origin: Craig's DATA Exchange! BBS 1:3669/50 904-483-2463 (1:3669/50)
SEEN-BY: 363/3 34 118 157 603 1571 396/1 3615/50 51 3633/132
SEEN-BY: 3669/18 50 54
PATH: 3669/50 54 363/157 3615/50
              
