(*
  Category: SWAG Title: CRT ROUTINES
  Original name: 0025.PAS
  Description: ANSI/BIOS/DIRECT Writes
  Author: P. MACKAY
  Date: 08-26-94  08:32
*)


Unit IO;


{ Copyright (C) 1988 by P.Mackay. All Rights Reserved

   Name     :  IO

   Compiler :  Unit for Borland's Turbo-Pascal v4/5 ...

   Function :  Provides capability to easily use and switch between the 3
                 output methods available: ANSI/BIOS/DIRECT-WRITES.

   Guarantee:  If it breaks, you get to keep both pieces.

   Author   :  Phil Mackay,
               21 Andrew Place, North Rocks
               2151 N.S.W  Australia.                                      }

interface

Type
  OutType        = (ANSI,BIOS,DIRECT);

Const
  CLS            = #27 + '[2J';
  Left           = #27 + '[1D';
  Right          = #27 + '[1C';
  Up             = #27 + '[1A';
  Down           = #27 + '[1B';
  Black          = #27 + '[30m';
  Blue           = #27 + '[34m';
  Green          = #27 + '[32m';
  Cyan           = #27 + '[36m';
  Orange         = #27 + '[31m';
  Purple         = #27 + '[35m';
  Red            = #27 + '[33m';
  White          = #27 + '[37m';
  BlackB         = #27 + '[40m';
  BlueB          = #27 + '[44m';
  GreenB         = #27 + '[42m';
  CyanB          = #27 + '[46m';
  OrangeB        = #27 + '[41m';
  PinkB          = #27 + '[45m';
  RedB           = #27 + '[43m';
  WhiteB         = #27 + '[47m';
  Bold           = #27 + '[1m';
  Flash          = #27 + '[5m';
  Off            = #27 + '[0m';

var
  IOmethod         : OutType;
  backcolor        : integer;
procedure IOGotoXY(x,y : integer);
procedure IOTextColor(color : integer);
procedure IOTextBackground(color : integer);
procedure IOClrEol;
procedure IOClrScr;
procedure OutputMethod (Method : OutType);

implementation

Uses CRT;

procedure IOGotoXY(x,y : integer);
var
  Sx,Sy : string;
begin
  if IOmethod = ANSI then
    begin
      Str(x,Sx);
      str(y,Sy);
      write(#27 + '[' + Sy + ';' + Sx + 'H');
    end
  else GotoXY(x,y);
end;


procedure IOTextColor(color : integer);

var
  flashing : boolean;

begin
  if IOmethod = ANSI then
    begin
      flashing := false;

      if color > 15 then
        begin
          color := color - 16;
          flashing := true;
        end
      else
        write (off);

      if color > 7 then
        begin
          color := color - 8;
          write (Bold);
        end
      else
        write (off);

      if flashing then write (flash);

      case color of
        0 : write (#27 + '[30m');
        1 : write (#27 + '[34m');
        2 : write (#27 + '[32m');
        3 : write (#27 + '[36m');
        4 : write (#27 + '[31m');
        5 : write (#27 + '[35m');
        6 : write (#27 + '[33m');
        7 : write (#27 + '[37m');
      end;
      IOTextBackground(Backcolor);
    end
  else TextColor(color);
end;


procedure IOTextBackground(color : integer);
begin
  if IOmethod = ANSI then
    begin
      Case color of
        0 : write (#27 + '[40m');
        1 : write (#27 + '[44m');
        2 : write (#27 + '[42m');
        3 : write (#27 + '[46m');
        4 : write (#27 + '[41m');
        5 : write (#27 + '[45m');
        6 : write (#27 + '[43m');
        7 : write (#27 + '[47m');
        end;
      BackColor := color;
    end
  else TextBackground(color);
end;


procedure IOClrEol;
begin
  if IOmethod = ANSI then write (#27 + '[K')
    else ClrEol;
end;


procedure IOClrScr;
begin
  if IOmethod = ANSI then write (Cls)
    else clrscr;
end;


procedure OutputMethod (Method: OutType);

begin
  Case Method of
    ANSI   : begin
               assign (input,'');
               reset (input);
               assign (output,'');
               rewrite (output);
               IOmethod := ANSI;
             end;
    BIOS   : begin
               AssignCRT (output);
               rewrite (output);
               AssignCRT (input);
               reset (input);
               DirectVideo := false;
               IOmethod := BIOS;
             end;
    DIRECT : begin
               AssignCRT (output);
               rewrite (output);
               AssignCRT (input);
               reset (input);
               DirectVideo := true;
               IOmethod := DIRECT;
             end;
  end;
end;

begin
  OutputMethod(ANSI);
End.

{--------------------------  DEMO ------------------------ }

Program IOtester;

Uses Crt, {only for the Keypressed function}
     IO;  {  <=== This is it }

(*   This demo will demonstrate the pros and cons of the video addressing
     types. The only thing non-standard about it, is that this program
     uses KeyPressed to detect the "press any key .." which bypasses the
     Standard IO, and uses a BIOS keyboard routine.                       *)

(* IO and IODEMO are written by P.Mackay. *)
(* Copyright (C) 1988 All Rights Reserved *)

procedure Routine;

var
  i : integer;
  ch: char;


begin
  IOClrScr;
  IOTextcolor(7);
  writeln ('TEST;  I/O testing program');
  IOgotoxy(6,4);
  IOtextcolor(2);
  writeln ('This program will demostrate the capabilities of the IO unit.');
  if IOmethod = ANSI then
    begin
      IOgotoxy(14,8);
      IOtextcolor(14);
      writeln ('Current operation: ANSI (standard-output)');
      IOgotoxy(1,10);
      IOtextcolor(3);
      writeln ('   ANSI output uses a special sequence of control codes to send information');
      writeln ('on things such as colour, cursor position etc .. A ANSI driver, however');
      writeln ('is required to see these. ANSI is slow, but very useful for re-direction');
      writeln ('in that it can be sent to a remote over a modem connection.');
    end;
  If IOmethod = BIOS then
    begin
      IOgotoxy(14,8);
      IOtextcolor(14);
      writeln ('Current operation: BIOS');
      IOgotoxy(1,10);
      IOtextcolor(3);
      writeln ('   BIOS output is many times slower than DIRECT, but it is useful in multi-');
      writeln ('tasking environments, where a program can re-route the BIOS video calls.');
      writeln ('Programs which have bulk output would not use BIOS, but BIOS is good for');
      writeln ('static output.');
    end;
  if IOmethod = DIRECT then
    begin
      IOgotoxy(14,8);
      IOtextcolor(14);
      writeln ('Current operation: DIRECT');
      IOgotoxy(1,10);
      IOtextcolor(3);
      writeln ('   DIRECT output is where a program directly writes to the memory on the');
      writeln ('display adapter. The only problems with this, is it sometimes causes snow');
      writeln ('and may not work on some flavours of MS-DOS. Direct-writes are used by');
      writeln ('most applications today, as it is so incredibly fast.');
      writeln ('   It is so fast, infact, you may not be able to see the line below becuase');
      writeln ('it is being updated so frequently. (depends on computer type)');
    end;

  IOgotoxy(15,16);
  IOtextcolor(15);
  write ('Speed test: (press any key)');

  i := 0;
  repeat
    IOgotoxy(5,20);
    write ('This is being written, wiped and re-written: ',i);
    IOgotoxy(5,20);
    write ('                                             ');
    i := i + 1;
  until keypressed;

  ch := readkey;
end;

begin
  CheckSnow := False;

  OutputMethod(ANSI);
  Write (BlackB);     (* Black background ANSI code *)
  Routine;

  OutputMethod(BIOS);
  Routine;

  OutputMethod(DIRECT);
  Routine;

  OutputMethod(ANSI);
  IOClrscr;
  IOTextcolor(15);
  IOTextbackground(1);
  Write ('IO; ANSI/BIOS/DIRECT routines for Turbo-Pascal v4 & 5 DEMO by P.Mackay');
  IOClrEol;
  IOTextbackground(0);
  IOTextcolor(7);
  writeln;
  writeln;
end.

