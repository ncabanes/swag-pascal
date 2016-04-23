{
I have code that will save a textmode screen to an ANSI format
 text file by reading the text mode screen directly. The code came
 from another discussion on saving text screens to ANSI files;
 the code is not mine.
}

PROGRAM Ansi_Save_Screen;
{*
 * Save a color-screen in Ansi-format. Simple way, char by char: blanks
 * not skipped.
 *}
Uses
 Dos;

PROCEDURE SaveANSI(Filename : PathStr);
CONST
 Esc = #27;
 MaxCol  = 70;
 AnsiCols : array [0..7] of char = '04261537';

TYPE
 TCell = RECORD
C : Char;
A : byte;
 END;
 TScreen = array [1..25, 1..80] of TCell;

 ANSIATTR = record
Bright : boolean;
Blink : boolean;
FG : byte;
BG : byte;
 end;

VAR
 Screen  : TSCreen ABSOLUTE $B800:$0000;
 F: text;
 X, Y : byte;
 s, s1: String;
 AnsiLast,
 AnsiTmp : ANSIATTR;

function WriteAttr(var Old, New : ANSIATTR) : string;
{ Write Attributes (ESC[..m) into a string }
var
 s : string;
begin
 WriteAttr := '';
 s := ESC + '[';
 if (not(New.Bright = Old.Bright)) or (not(New.Blink = Old.Blink)) then
 begin
if (Not (New.Bright and New.Blink)) then
 s := s + '0;'
else
if (not New.Bright) and (New.Blink) then
begin
 if Old.Bright then
s := s + '0;5;'
 else
s := s + '5;';
end
else
if (New.Bright) and (not New.Blink) then
begin
 if Old.Blink then
s := s + '0;1;'
 else
s := s + '1;';
end
else
begin
 if not Old.Bright then
s := s + '1;';
 if not Old.Blink then
s := s + '5;';
end;
 end;

 if (Old.FG <> New.FG) or ((not New.Bright) and Old.Bright) or
  ((not New.Blink) and Old.Blink) then
 begin
{* I don't have no info why, but obviously backswitching to dark
 * colorset, what has to be done via ^[0m, must turn fg/bg colors to
 * 37/40. However, we can optimize still then a bit !-. *}
if not ( (New.FG=7) and ((not New.Bright) and Old.Bright) )
  then s:=s+'3'+AnsiCols[New.FG]+';';
 end;

 if (Old.BG<>New.BG) or ((not New.Bright) and Old.Bright) or
 ((not New.Blink) and Old.Blink) then
 begin
if not ( (New.BG=0) and ((not New.Bright) and Old.Bright) )
  then s:=s+'4'+AnsiCols[New.BG]+';';
 end;

 if s[length(s)]=';' then s[length(s)]:='m' else s:=s+'m';

 if length(s)>length(ESC+'[m') then WriteAttr:=s;
end;

BEGIN
 Assign(F, filename);
 Rewrite(F);

 AnsiTmp.FG := Screen[1, 1].A and 15;
 AnsiTmp.BG := Screen[1, 1].A SHR 4;
 AnsiTmp.Blink := (AnsiTmp.BG AND 8) = 8;
 AnsiTmp.Bright := (AnsiTmp.FG AND 8) = 8;
 AnsiTmp.FG:=AnsiTmp.FG and 7;
 AnsiTmp.BG:=AnsiTmp.BG and 7;

 s:=Esc+'[2J'+Esc+'[0m'+ESC+'[';
 if AnsiTmp.Bright then s:=s+'1;';
 if AnsiTmp.Blink then s:=s+'5;';
 s:=s+'3'+ansicols[AnsiTmp.FG]+';';
 s:=s+'4'+ansicols[AnsiTmp.BG]+'m';

 FOR Y := 1 TO 25 DO
BEGIN
 FOR X := 1 TO 80 DO
  BEGIN
 AnsiLast:=AnsiTmp;

 AnsiTmp.FG := Screen[Y, X].A AND 15;
 AnsiTmp.BG := Screen[Y, X].A SHR 4;
 AnsiTmp.Bright := (AnsiTmp.FG AND 8)<>0;
 AnsiTmp.Blink := (AnsiTmp.BG AND 8)<>0;
 AnsiTmp.FG:=AnsiTmp.FG and 7;
 AnsiTmp.BG:=AnsiTmp.BG and 7;

 s1:=WriteAttr(AnsiLast, AnsiTmp);
 s1:=s1+Screen[Y, X].C;

 IF (length(s+s1+ESC+'[s')) <= MaxCol then s:=s+s1 else
 begin
  Write(F,s+ESC+'[s'+#13#10);
  s:=ESC+'[u'+s1;
 end;

  END;
END;
Write(F, Esc+'[0;37;40m');
Close(F);
END;
BEGIN
 SaveANSI('test3.ans');
END.
