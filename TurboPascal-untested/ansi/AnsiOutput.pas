(*
  Category: SWAG Title: ANSI CONTROL & OUTPUT
  Original name: 0005.PAS
  Description: ANSI Output
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:33
*)

{
> Now that I need to make a .ANS bulletin Type File, I was wondering
> how to Write from a Pascal Program, ANSI control Characters to a
> File and produce nice color bulletin screen to be displayed by RA.

The following Unit will enable you to Write Ansi sequences to a Text
File Without having to look them up yourself. It enables you to do this
using the (easier) Crt Unit style of commands, and provides the optimum
Ansi sequence to do the job.
}

Unit AnsiOut;
{1. Contains reduced set of Procedures from AnsiCrt Unit by I.Hinson.}
{2. Modified to provide output to a Text File.}

Interface

Const Black = 0;     Blue = 1;          Green = 2;       Cyan = 3;
      Red =   4;     Magenta = 5;       Brown = 6;       LightGray = 7;
      DarkGray = 8;  LightBlue = 9;     LightGreen = 10; LightCyan = 11;
      LightRed = 12; LightMagenta = 13; Yellow = 14;     White = 15;
      Blink = 128;

Var AnsiFile: Text;

Procedure TextColor(fore : Byte);
Procedure TextBackGround(back : Byte);
Procedure NormVideo;
Procedure LowVideo;
Procedure HighVideo;
Procedure ClrEol;
Procedure ClrScr;

Implementation

Const forestr: Array[Black..LightGray] of String[2]
               = ('30','34','32','36','31','35','33','37');
      backstr: Array[Black..LightGray] of String[2]
               = ('40','44','42','46','41','45','43','47');
      decisiontree: Array[Boolean, Boolean, Boolean, Boolean] of Integer =
      ((((0,1),(2,0)),((1,1),(3,3))),(((4,5),(6,4)),((0,5),(2,0))));

Var forecolour, backcolour: Byte; { stores last colours set }
    boldstate, blinkstate: Boolean;

Procedure TextColor(fore : Byte);
  Var
    blinknow, boldnow: Boolean;
    outstr: String;
  begin
    blinknow := (fore and $80) = $80;
    boldnow := (fore and $08) = $08;
    fore := fore and $07;  { mask out intensity and blink attributes }
    forecolour := fore;
    Case decisiontree[blinknow, blinkstate, boldnow, boldstate] OF
    0: outstr := Concat(#27,'[',forestr[fore],'m');
    1: outstr := Concat(#27,'[0;',backstr[backcolour],';',forestr[fore],'m');
    2: outstr := Concat(#27,'[1;',forestr[fore],'m');
    3: outstr :=
         Concat(#27,'[0;1;',backstr[backcolour],';',forestr[fore],'m');
    4: outstr := Concat(#27,'[5;',forestr[fore],'m');
    5: outstr :=
         Concat(#27,'[0;5;',backstr[backcolour],';',forestr[fore],'m');
    6: outstr := Concat(#27,'[1;5;',forestr[fore],'m');
    end; { Case }
    Write(AnsiFile,outstr);
    blinkstate := blinknow;
    boldstate := boldnow;
  end;

Procedure TextBackGround(back: Byte);
  Var outString: String;
  begin
    if Back > 7 then Exit; { No such thing as bright or blinking backgrounds }
    BackColour := Back;
    outString := Concat(#27,'[',backstr[back],'m');
    Write(AnsiFile,outString)
  end;

Procedure NormVideo;
  begin
    Write(AnsiFile,#27'[0m');
    forecolour := LightGray;
    backcolour := Black;
    boldstate := False;
    blinkstate := False
  end;

Procedure LowVideo;
  begin
    if blinkstate then forecolour := forecolour or $80;  { retain blinking }
    TextColor(forecolour);   { stored forecolour never contains bold attr }
  end;

Procedure HighVideo;
  begin
    if not boldstate then
    begin
      boldstate := True;
      Write(AnsiFile,#27,'[1m')
    end;
  end;

Procedure ClrEol;
  begin
    Write(AnsiFile,#27'[K')
  end;

Procedure ClrScr;
  begin
    Write(AnsiFile,#27'[2J');
  end;

begin
  forecolour := LightGray;
  backcolour := Black;
  boldstate := False;
  blinkstate := False
end.

___------------------------------------------------------------------
Program Demo;
Uses AnsiOut;
begin
  Assign(AnsiFile,'CON');   { or a File - e.g. 'MYSCREEN.ANS' }
  ReWrite(AnsiFile);
  ClrScr;
  TextColor(Blue); TextBackGround(LightGray);
  Writeln(AnsiFile,' Blue Text on LightGray ');
  HighVideo; Write(AnsiFile,' Now the Text is LightBlue ');
  TextBackground(Red); Writeln(AnsiFile,' on a Red background');
  TextColor(Black+Blink); TextBackground(Cyan);
  Writeln(AnsiFile,' Blinking Black ');
  TextBackGround(Green); ClrEol;         { a blank Green line }
(53 min left), (H)elp, More?   Writeln(AnsiFile);
  NormVideo;
  Close(AnsiFile);
end.

