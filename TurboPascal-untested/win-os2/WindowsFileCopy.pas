(*
  Category: SWAG Title: WINDOWS & OS2 STUFF
  Original name: 0012.PAS
  Description: Windows File Copy
  Author: MICHAEL VINCZE
  Date: 11-26-93  17:06
*)


{
WINDOWS File Copy
Michael Vincze
mav@asd470.dseg.ti.com
}

uses
  WinTypes,
  WinProcs,
  Objects;

const
  BufStreamSize = $400;

var
  InBufStream : TBufStream;
  OutBufStream: TBufStream;
  C           : Byte;

procedure Gasp;
var
  Msg: TMsg;
begin
while PeekMessage (Msg, 0, 0, 0, pm_Remove) do
  with Msg do
    if (Message < wm_KeyFirst) or (Message > wm_MouseLast) or
       ((Message > wm_KeyLast) and (Message < wm_MouseFirst)) then
      begin
      TranslateMessage (Msg);
      DispatchMessage (Msg);
      end;
end;

{ function copies one file to the other.  The return code
  is the same as the TBufStream return codes.  The Gasp
  procedure is inserted to yield for other applications
  during a copy.
}
function MyCopy (InFileName, OutFileName: PChar): Word;
begin
InBufStream.Init (InFileName, stOpenRead, BufStreamSize);
if InBufStream.Status <> stOk then
  begin
  MyCopy := InBufStream.Status;
  end
else
  begin
  OutBufStream.Init (OutFileName, stCreate, BufStreamSize);
  if OutBufStream.Status <> stOk then
    begin
    MyCopy := OutBufStream.Status;
    end
  else
    begin
    InBufStream.Read (C, 1);
    while InBufStream.Status = stOk do
      begin
      Gasp;
      OutBufStream.Write (C, 1);
      InBufStream.Read (C, 1);
      end;
    end;
  end;
InBufStream.Done;
OutBufStream.Done;
end;

