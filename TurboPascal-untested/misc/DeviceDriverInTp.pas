(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0029.PAS
  Description: Device Driver in TP
  Author: GORDON TACKETT
  Date: 08-27-93  20:38
*)

{
GORDON TACKETT

In version 7 of TP/BP you can write a device driver But it is tricky! The
following code is not fully tested but seems to work. After looking at some
disassembly listings I added the patch file section. Use or abuse at your own
risk :-)
}

Program TestDriver;

Procedure Dev_Strategy; Forward;
Procedure Dev_Int; Forward;

Procedure DeviceDriverHeader;
begin
  Inline(
    $FFFF/
    $FFFF/
    $2000/
    $0000/
    $0000/
    $FFFF/$FFFF/$FFFF/$FFFF/0);
End;

Procedure Dev_Strategy;
Begin
End;

Procedure Dev_Int;
Begin
End;

Var
  F : File;

Begin
  If ParamCount = 999 Then
    DeviceDriverHeader
  else
  Begin
    {patch driver}
    movemem(devicedriverheader, DeviceDriverHeader + 3, 20);
    Assign(F, ParamStr(0));
    Reset(F, 1);
    BlockWrite(F, DeviceDriverHeader, 20);
    Close(F);
  End;
End.


