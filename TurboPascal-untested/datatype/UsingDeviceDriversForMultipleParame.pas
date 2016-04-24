(*
  Category: SWAG Title: DATA TYPE & COMPARE ROUTINES
  Original name: 0034.PAS
  Description: Using Device Drivers for multiple Parame
  Author: RGDAWSON
  Date: 05-26-95  23:24
*)

{
From: rgdawson@aol.com (RGDawson)

>Does anyone know how I can make a procedure accept as many or as little
>parameters as a I want. For example, in writeln, you can use no parameters
>or a lot of parameters with the same call. Could I do the same thing for
>something that writes to a com port without assigning a file to the port?

The best way is to write a device driver.  Here is an example of a device
driver that lets write and writeln send strings to a global PChar
variable.  This is very handy for formatting and concatenating strings and
number variables of all types.  To use simply include this unit and do
something like

  WriteLn(PD, 'X=', X:5:2, 'The lazy fox...', S);

The global variable PDStr now contains the formatted output of writeln.
}

UNIT PCharDev;

{$K+}

INTERFACE

uses
  WinTypes, WinProcs, WinDOS, Strings;

const
  MaxPDStrSize = 255;
var
  PDStr: array[0..MaxPDStrSize] of Char;
  PD: Text;

procedure AssignPCharDev(var F: Text);

IMPLEMENTATION

procedure WriteBuffer(Buffer: PChar; Count: Word);
var
  i: integer;
begin
  i := 0;
  while (Count > 0) AND (i <= MaxPDStrSize - 1) do begin
    if Buffer^ in [#9, #32..#255] then begin
      PDStr[i] := Buffer^;
      Inc(i);
    end;
    {$IFOPT R+}
    if i > (MaxPDStrSize - 1) then
      MessageBox(0, 'Max string size exceeded in PChar Device.  String Truncated.',
                    'PCharDev Error', mb_OK + mb_IconExclamation);
    {$ENDIF}
    Inc(Buffer);
    Dec(Count);
  end;
  PDStr[i] := #0;
end;

function PCharDevClose(var F: TTextRec): integer; far;
begin
  PCharDevClose := 0;
end;

function PCharDevOut(var F: TTextRec): integer; far;
begin
  if F.BufPos <> 0 then begin
    WriteBuffer(PChar(F.BufPtr), F.BufPos);
    F.BufPos := 0;
  end;
  PCharDevOut := 0;
end;

function PCharDevOpen(var F: TTextRec): integer; far;
begin
  {.$IFOPT R+}
  if F.Mode <> fmOutput then
    MessageBox(0, 'PCharDev mode must be fmOutput only.','Error',mb_OK);
  {.$ENDIF}
  F.Mode := fmOutput;
  F.InOutFunc := @PCharDevOut;
  F.FlushFunc := @PCharDevOut;
  F.CloseFunc := @PCharDevClose;
  PCharDevOpen := 0;
end;

procedure AssignPCharDev(var F: Text);
begin
  with TTextRec(F) do begin
    handle := $FFFF;
    Mode := fmClosed;
    BufSize := SizeOf(Buffer);
    BufPtr := @Buffer;
    OpenFunc := @PCharDevOpen;
    Name[0] := #0;
  end;
end;

BEGIN
  AssignPCharDev(PD);
  Rewrite(PD);
END.


