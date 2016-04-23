{> Basically all I'm asking For are SaveScreen and
> RestoreScreen Procedures. Procedures capable of just
> partial screen saves and restores would be even better,
> but anything will do!  :-)
}
Program SaveScr;

Uses
  Crt,
  Dos;

Const
  vidseg : Word = $B800;
  ismono : Boolean = False;

Type
  Windowrec = Array [0..4003] Of
  Byte;

Var
  NewWindow : Windowrec;
  c : Char;

Procedure checkvidseg;
begin
  If (mem [$0000 : $0449] = 7) Then
     vidseg := $B000
  Else
     vidseg := $B800;
  ismono := (vidseg = $B000);
end;

Procedure savescreen (Var wind : Windowrec;
  TLX, TLY, BRX, BRY : Integer);
Var x, y, i : Integer;
begin
  checkvidseg;
  wind [4000] := TLX;
  wind [4001] := TLY;
  wind [4002] := BRX;
  wind [4003] := BRY;
  i := 0;
  For y := TLY To BRY Do
      For x := TLX To BRX Do
          begin
          InLine ($FA);
          wind [i] := mem [vidseg : (160 * (y - 1) + 2 * (x - 1) ) ];
          wind [i + 1] := mem [vidseg : (160 * (y - 1) + 2 * (x - 1) ) + 1];
          InLine ($FB);
          Inc (i, 2);
          end;
end;

Procedure setWindow (Var wind : Windowrec;
  TLX, TLY, BRX, BRY : Integer);
Var i : Integer;
begin
  savescreen (wind, TLX, TLY, BRX, BRY);
  Window (TLX, TLY, BRX, BRY);
  ClrScr;
end;

Procedure removeWindow (wind : Windowrec);
Var TLX, TLY, BRX, BRY, x, y, i : Integer;
begin
  checkvidseg;
  Window (1, 1, 80, 25);
  TLX := wind [4000];
  TLY := wind [4001];
  BRX := wind [4002];
  BRY := wind [4003];
  i := 0;
  For y := TLY To BRY Do
      For x := TLX To BRX Do
          begin
          InLine ($FA);
          mem [vidseg : (160 * (y - 1) + 2 * (x - 1) ) ] := wind [i];
          mem [vidseg : (160 * (y - 1) + 2 * (x - 1) ) + 1] := wind [i + 1];
          InLine ($FB);
          Inc (i, 2);
          end;
end;

begin
  setWindow (NewWindow, 1, 1, 80, 25);
  GotoXY(1, 12);
  Write ('Press a key to restore original screen...');
  Repeat
  Until KeyPressed;
  c := ReadKey;
  removeWindow (NewWindow);
  GotoXY (1, 24);
end.

{
You can set the size of the Window to whatever you want, and save/restore as
many Windows as you have memory available.
}