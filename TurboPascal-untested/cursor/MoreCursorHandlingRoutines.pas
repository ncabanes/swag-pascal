(*
  Category: SWAG Title: CURSOR HANDLING ROUTINES
  Original name: 0029.PAS
  Description: More Cursor Handling Routines
  Author: HERBERT VOSS
  Date: 05-31-96  09:16
*)

{
Cursor An  ---> Cursor on

Cursor Aus ---> Cursor Off

Cursor ?   ---> The helptext
}

Program Cursor;

Uses
  Dos;

Label
  Schluss;

Var

  r :Registers;
  p : String[10];
  cH, cL : Byte;

Begin
  p := ParamStr(1);
  If P = 'An'
    Then
      Begin
        cH := 0;
        cL := 8;
      End;
  If (P = 'Aus')
    Then
      Begin
        cH := 8;
        cL := 0;
      End;
  If (P = '?')
    Then
      Begin
        WriteLn('Folgende Parameter sind mvglich:');
        WriteLn('--------------------------------');
        WriteLn('Cursor An  :  liefert den Block');
        WriteLn('Cursor Aus :  schaltet den Cursor ab');
        WriteLn('Cursor ?   :  liefert diese Aufstellung');
        WriteLn;
        Write('Weiter --> Return-(Enter-)Taste dr|cken');
        ReadLn(p);
        GoTo Schluss;
      End;
  R.ax := 1 ShL 8;
  R.cx := cH ShL 8 + cL;
  Intr($10,r);

Schluss:

End.


--

eMail: voss@ck.be.schule.de

       Herbert_Voss@msn.com




