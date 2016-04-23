
> I'm Looking For a Routine to get the number of serial ports in a
> machine, There is a function GetSerialPortList but Not in Delphi
> Unit Files or any C Header File What function can I use....?

...and here is it - the best function for that!

function SerialAvail(ComPort : integer) : boolean;
const
  UsedComm : array[0..5] of char = 'COMx';
var
  H : integer;
  {$IFNDEF VER80}
  i : integer;
  CommConfig : TCommConfig;
  {$ENDIF}
begin
  SerialAvail:=false;
  UsedComm[3]:=chr(ComPort+$31);
  {$IFDEF VER80}   { Win 3.x }
  H:=OpenComm(@UsedComm,256,256);
  if H>=0 then
  begin
    CloseComm(H);
    SerialAvail:=true;
  end;
  {$ELSE}          { Win95/NT }
  H:=CreateFile(UsedComm,GENERIC_READ or GENERIC_WRITE,
                0,nil,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0);
  if H<>INVALID_HANDLE_VALUE then
  begin
    CloseHandle(H);
    SerialAvail:=true;
  end;
  GetLastError;
  {$ENDIF}
end;
