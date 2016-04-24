(*
  Category: SWAG Title: ANSI CONTROL & OUTPUT
  Original name: 0038.PAS
  Description: ANSI Color Setting
  Author: UELI RUTISHAUSER
  Date: 05-26-95  22:57
*)


{ Updated ANSI.SWG on May 26, 1995 }

{
(*===================================================================*)
(*                              ANSI.PAS                             *)
(*    Die Unit stellt ein Inferface zum ANSI-Treiber zur Verfügung   *)
(*===================================================================*)

UNIT ANSI;

INTERFACE

VAR
  CON: Text;

(*   Überprüfung, ob ein ANSI-Treiber installiert ist                *)
FUNCTION AnsiSys: BOOLEAN;

(* Übergabe von beliebigen Werten an den ANSI-Treiber                *)
PROCEDURE AnsiOut(s: SHORTINT);

(* ANSI-Farbeinschaltung: Attribut 7 = grau                          *)
PROCEDURE AnsiGray;

(* ANSI-Farbeinschaltung: Attribut 15 = weiß                         *)
PROCEDURE AnsiWhite;

(* ANSI-Farbeinschaltung: Attribut 14 = gelb                         *)
PROCEDURE AnsiYellow;

IMPLEMENTATION

USES
  Crt;

CONST
  ESC = #27;
  ansiinstalled: BOOLEAN = FALSE;

FUNCTION AnsiSys: BOOLEAN;
(* Test ob ANSI.SYS installiert ist; da alle Ausgaben über die       *)
(* Standard-Ausgabe gehen, müssen die Bildschirmfarben über ANSI-Se- *)
(* quenzen gesteuert werden. Ist ANSI.SYS nicht installiert, werden  *)
(* keine ANSI-Steuerbefehle vom Programm ausgegeben.                 *)
VAR
  posold,
  posnew  : BYTE;
BEGIN
  AnsiSys := FALSE;
  posold  := WhereX;                                (* Spalte merken *)
  Write(CON, Chr(27), '[2m');                       (* ANSI-Sequenz  *)
  posnew  := WhereX;                                (* neue Position *)

  IF posnew = posold THEN AnsiSys := TRUE;(*Sequenz wurde verarbeitet*)

  GotoXY(1, WhereY);                             (* evtl. vorhandene *)
  ClrEoL;                                        (* Zeichen löschen  *)
END;

(*-------------------------------------------------------------------*)

PROCEDURE AnsiOut(s: SHORTINT);
BEGIN
  Write(CON, ESC + '[' , s , 'm');
END;

(*-------------------------------------------------------------------*)

PROCEDURE AnsiGray;
BEGIN
  IF ansiinstalled THEN AnsiOut(0);
END;

(*-------------------------------------------------------------------*)

PROCEDURE AnsiWhite;
BEGIN
  IF ansiinstalled THEN
  BEGIN
    AnsiOut(0);
    AnsiOut(1);
  END;
END;

(*-------------------------------------------------------------------*)

PROCEDURE AnsiYellow;
BEGIN
  IF ansiinstalled THEN AnsiOut(33);
END;

VAR
  OldExitProc: Pointer;

{$F+}
PROCEDURE ANSIExitProc;
VAR
  ExitProc: POINTER;
BEGIN
  Close(CON);
  ExitProc := OldExitProc;
END;
{$F-}

(*-------------------------------------------------------------------*)

BEGIN
  Assign(CON, '');
  Append(CON);
  ansiinstalled := AnsiSys;
  OldExitProc := ExitProc;
  ExitProc := @ANSIExitProc;
END.

(*===================================================================*)

{ And a Example: }

program test_ansi;

uses crt, ansi;

begin
  writeln(con,'[);
  readln;
end.



