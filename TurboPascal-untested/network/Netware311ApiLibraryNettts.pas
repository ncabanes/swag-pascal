(*
  Category: SWAG Title: NOVELL/LANTASTIC NETWORK ROUTINES
  Original name: 0044.PAS
  Description: Netware 3.11 API Library - NetTTS
  Author: S.PEREVOZNIK
  Date: 11-29-96  08:17
*)

{
            ╔══════════════════════════════════════════════════╗
            ║     ┌╦═══╦┐┌╦═══╦┐┌╦═══╦┐┌╦═╗ ╦┐┌╦═══╦┐┌╔═╦═╗┐   ║
            ║     │╠═══╩┘├╬═══╬┤└╩═══╦┐│║ ║ ║│├╬══      ║      ║
            ║     └╩     └╩   ╩┘└╩═══╩┘└╩ ╚═╩┘└╩═══╩┘   ╩      ║
            ║                                                  ║
            ║     NetWare 3.11 API Library for Turbo Pascal    ║
            ║                      by                          ║
            ║                  S.Perevoznik                    ║
            ║                     1996                         ║
            ╚══════════════════════════════════════════════════╝
}

Unit NetTTS;

Interface

Uses NetConv;

Function TTSIsAvailable : byte;
{True, if TTS is available}

Function TTSAbortTransaction : byte;
{Abort current transaction}

Function TTSBeginTransaction : byte;
{Begin new transaction}

Function TTSEndTransaction (Var transNumber : longInt) : byte;
{End current transaction}

Function TTSTransactionStatus(transNumber : longint) : byte;
{Return transaction status}

Implementation

Uses Dos;


Function TTSIsAvailable : byte;
var r : registers;

begin
  r.AH := $C7;
  r.AL := $02;
  intr($21,r);
  TTSIsAvailable := r.AL;
end;

Function TTSAbortTransaction : byte;
var r : registers;
begin
  r.AH := $C7;
  r.AL := $03;
  intr($21,r);
  TTSAbortTransaction := r.AL;
end;

Function TTSBeginTransaction : byte;
var r : registers;
begin
  r.AH := $C7;
  r.AL := $00;
  intr($21,r);
  TTSBeginTransaction := r.AL;
end;

Function TTSEndTransaction ( Var transNumber : longInt) : byte;
var r : registers;
begin
   r.AH := $C7;
   r.AL := $01;
   intr($21,r);
   transNumber := Int2Long(r.DX,r.CX);
   TTSEndTransAction := r.AL;
end;


Function TTSTransactionStatus(transNumber : longint) : byte;
var r : registers;
begin
  r.AH := $C7;
  r.AL := $04;
  long2Int(transNumber,r.DX,r.CX);
  intr($21,r);
  TTSTransactionStatus := r.AL;
end;

end.

