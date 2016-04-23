
{*********** Part 1 *************}
{ Unit includs functions to get access to the Windows-Clipboard }
{ within DOS-Programs, based upon an article in the German      }
{ magazine c't 12/92 p. 242 "Mailbox".                          }
{ Created 01/93, extended 12/96, (c) 1993,96 Dr. Guido Scholz   }

unit winclip;

interface

uses Dos;

{ for protected mode only one function will be exported }
function ClipboardFunctionsAvailable: boolean; far;

{$IFNDEF DPMI}
function ClipboardCompact(lDesired: longint): longint; far;
function CloseClipboard: boolean; far;
function EmptyClipboard: boolean; far;
function GetClipboardDataSize(wFormat: Word): longint; far;
function GetClipboardData(wFormat: Word; DataPtr: Pointer): boolean; far;
function OpenClipboard: boolean; far;
function SetClipboardData(wFormat: Word; DataPtr: Pointer;
  lSize: longint): boolean; far;

const
  cf_Text      = 1;
  cf_Bitmap    = 2;
  cf_OemText   = 7;
  cf_DspText   = $81;   { Formated Text }
  cf_DspBitmap = $82;
{$ENDIF}

implementation

{$IFDEF DPMI}
function ClipboardFunctionsAvailable: boolean;
begin
  ClipboardFunctionsAvailable:= false;
end;

{$ELSE}
function ClipboardFunctionsAvailable: boolean;
var
  r: registers;
begin
  r.ax:= $1700;
  intr($2F,r);
  ClipboardFunctionsAvailable:= r.ax <> $1700;
end;

function ClipboardCompact(lDesired: longint): longint;
var
  r: registers;
begin
  r.ax:= $1709;
  r.si:= Word(lDesired shr 16);
  r.cx:= Word(lDesired);
  intr($2F,r);
  ClipboardCompact:= longint(r.ax) + longint(r.dx) shl 16;
end;

function CloseClipboard: boolean;
var
  r: registers;
begin
  r.ax:= $1708;
  intr($2F,r);
  CloseClipboard:= r.ax <> 0;
end;

function EmptyClipboard: boolean;
var
  r: registers;
begin
  r.ax:= $1702;
  intr($2F,r);
  EmptyClipboard:= r.ax <> 0;
end;

function GetClipboardDataSize(wFormat: Word): longint;
var
  r: registers;
begin
  r.ax:= $1704;
  r.dx:= wFormat;
  intr($2F,r);
  GetClipboardDataSize:= longint(r.ax) + longint(r.dx) shl 16;
end;

function GetClipboardData(wFormat: Word; DataPtr: Pointer): boolean;
var
  r: registers;
begin
  r.ax:= $1705;
  r.dx:= wFormat;
  r.es:= seg(DataPtr^);
  r.bx:= ofs(DataPtr^);
  intr($2F,r);
  GetClipboardData:= r.ax <> 0;
end;

function OpenClipboard: boolean;
var
  r: registers;
begin
  r.ax:= $1701;
  intr($2F,r);
  OpenClipboard:= r.ax <> 0;
end;

function SetClipboardData(wFormat: Word; DataPtr: Pointer;
  lSize: longint): boolean;
var
  r: registers;
begin
  SetClipboardData:= false;
  if (DataPtr <> nil) and (lSize <> 0) then
  if ClipboardCompact(lSize) >= lSize then
  begin
    r.ax:= $1703;
    r.dx:= wFormat;
    r.es:= seg(DataPtr^);
    r.bx:= ofs(DataPtr^);
    r.si:= word(lSize shr 16);
    r.cx:= word(lSize);
    intr($2F,r);
    SetClipboardData:= r.ax <> 0;
  end;
end;
{$ENDIF}

end.


{*********** Part 2 *************}
program ClipCopy;
{Demo for WinClip-Unit}
{Dr. Guido Scholz 07.12.96}

uses Crt, Strings, Winclip;

var
  DerText: PChar;

  { The easiest way is a zero terminated string. Pascal- }
  { strings have to be converted using "StrPCopy".       }

begin
  if ClipboardFunctionsAvailable then begin { is Windows running ?   }
    DerText:= 'This text will go into the clipboard.';
    if OpenClipboard then begin     { can the clipboard be opend ?   }
      if EmptyClipboard then begin  { can the clipboard be cleared ? }
        SetClipboardData(cf_OemText, DerText, StrLen(DerText)+1);
        {+1 fuer die Terminierung mit #0}
      end else writeln('Error clearing the clipboard.');
      CloseClipboard;
    end else writeln('Error opening the clipboard.');
  end else begin
    writeln('Windows-Clipboard not available.');
    writeln('Run this program in a Windows DOS-Box.');
  end;
  write('Quit ClipCopy with <RETURN>'); readln;
end.


{*********** Part 3 *************}
program ClipPaste;
{ Demo for WinClip-Unit    }
{ Dr. Guido Scholz 07.12.96 }

uses Crt, Strings, Winclip;

var
  DerText: PChar;
  Laenge: Longint;

begin
  if ClipboardFunctionsAvailable then begin { is Windows running ?   }
    if OpenClipboard then begin     { can the clipboard be opend ?   }
      Laenge:= GetClipboardDataSize(cf_OemText);
      if (Laenge > 0) and (Laenge <= 65528) then begin { something useable in cliboard ? }
        GetMem(DerText, Laenge);
        GetClipboardData(cf_OemText, DerText);
        writeln('The following is from the clipbard:');
        writeln(DerText);
        FreeMem(DerText, Laenge);
      end else writeln('No text or too many text inside the clipbard.');
      CloseClipboard;
    end else writeln('Error opening the clipboard.');
  end else begin
    writeln('Windows-Clipboard not available.');
    writeln('Run this program in a Windows DOS-Box.');
  end;
  write('Quit ClipPaste with <RETURN>'); readln;
end.

