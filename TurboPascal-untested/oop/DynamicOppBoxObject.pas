(*
  Category: SWAG Title: OOP/TURBO VISION ROUTINES
  Original name: 0023.PAS
  Description: Dynamic OPP Box Object
  Author: SWAG SUPPORT TEAM
  Date: 08-17-93  08:47
*)

program Dynamic_Object_Demo;

 { DYN-DEMO.PAS }

uses Crt, Dos;

type
   ScrPtr = ^SaveScreen;
   BoxPtr = ^ReportBox;
   SaveScreen = array[1..80,1..25] of word;
   ReportBox = object
      SavPtr: ScrPtr;  FColor, BColor: byte;
      WPosX, WPosY, WSizeX, WSizeY: integer;
      constructor Init( PtX, PtY, Width, Height,
                         C1, C2 : integer );
      destructor  Done;
      procedure   Draw;
      procedure   Erase;
   end;

{==========================================}
{ implementation for object type ReportBox }
{==========================================}

constructor ReportBox.Init;
var
   i, j: integer;
   Regs: Registers;
begin
   WPosX  := PtX;
   WPosY  := PtY;
   WSizeX := Width;
   WSizeY := Height;
   FColor := C1;
   BColor := C2;
   New( SavPtr ); { allocate memory for array }
   window( WPosX, WPosY, WPosX+WSizeX-1,
                         WPosY+WSizeY-1 );

  {read character and attribute on video page 0}

   for i := 1 to WSizeX do
      for j := 1 to WSizeY do
      begin
         gotoxy(i,j);
         Regs.AH := 08;
         Regs.BH := 00;
         intr( $10, Regs );
         SavPtr^[i,j] := Regs.AX;
      end;
   Draw;
end;

destructor ReportBox.Done;
begin
   Erase;
   Dispose( SavPtr );
end;

procedure ReportBox.Erase;
var
   i, j : integer;
   Regs : Registers;
begin
   window( WPosX, WPosY,
           WPosX+WSizeX-1, WPosY+WSizeY-1 );
   ClrScr;   { inner window }

{ Write character and attr on video page 0 }

{ AL stores the character value }
{ BL stores the attribute value }
{ CL stores the repititions value (1) }

   for i := 1 to WSizeX do
      for j := 1 to WSizeY do
      begin
         gotoxy(i,j);
         Regs.AH := 09;
         Regs.BH := 00;
         Regs.AL := lo( SavPtr^[i,j] );
         Regs.BL := hi( SavPtr^[i,j] );
         Regs.CL := 1;
         intr( $10, Regs );
      end;
   window( 1, 1, 80, 25 );
end;

procedure ReportBox.Draw;
var
   BoxStr : string[6];
   i : integer;
   MemSize : longint;
begin
   TextColor( FColor );
   TextBackground( BColor );
   BoxStr := #$C9 + #$CD + #$BB +
             #$BA +#$BC + #$C8;
   window( WPosX, WPosY,
           WPosX+WSizeX-1, WPosY+WSizeY-1 );
   ClrScr;
   gotoxy( 1, 1 );           write( BoxStr[1] );
   for i := 1 to WSizeX-2 do write( BoxStr[2] );
                             write( BoxStr[3] );
   gotoxy( 1, WSizeY-1 );    write( BoxStr[6] );
   for i := 1 to WSizeX-2 do write( BoxStr[2] );
                             write( BoxStr[5] );
   gotoxy( 1, 2 );
   InsLine;
   for i := 2 to WSizeY-1 do
   begin
      gotoxy( 1, i );      write( BoxStr[4] );
      gotoxy( WSizeX, i ); write( BoxStr[4] );
   end;
   window( WPosX+1, WPosY+1,
           WPosX+WSizeX-2, WPosY+WSizeY-2 );
   ClrScr;
   MemSize := MemAvail;
   for i := 1 to 30 do
      write('Memory now = ',MemSize,' bytes! ');
   window( 1, 1, 80, 25 );
end;

{ **** end of methods **** }

var
   Box : array[1..5] of BoxPtr;
   MemSize : longint;
   i : integer;

procedure Prompt;
begin
   gotoxy( 1, 1 ); clreol;
   write('Memory now = ', MemAvail,
         '. Press ENTER to continue ');
   readln;
end;

begin
   ClrScr;
   TextColor( White );
   TextBackground( Black );
   MemSize := MemAvail;
   for i := 1 to 100 do
      write(' Initial memory available = ',
              MemSize, ' bytes! ' );
   gotoxy( 1, 1 ); clreol;
   write('Press ENTER to continue ');
   readln;
   Box[1] := New( BoxPtr, Init(  5, 12, 30, 10,
                  LightRed, Black ) );
   gotoxy( 1, 1 ); clreol;
   write('Memory now = ', MemAvail,
         '. Press ENTER to continue ');
   readln;
   Box[2] := New( BoxPtr, Init( 40,  5, 30, 10,
                  LightGreen, Blue ) );
   gotoxy( 1, 1 ); clreol;
   write('Memory now = ', MemAvail,
         '. Press ENTER to continue ');
   readln;
   Dispose( Box[1], Done );
   Dispose( Box[2], Done );
   gotoxy( 1, 1 ); clreol;
   write( 'Final memory (after release) = ',
           MemAvail, ' bytes...');
   readln;
end.

