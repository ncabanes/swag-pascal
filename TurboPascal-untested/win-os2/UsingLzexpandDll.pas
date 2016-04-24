(*
  Category: SWAG Title: WINDOWS & OS2 STUFF
  Original name: 0035.PAS
  Description: Using lzexpand.dll
  Author: MICHAEL VINCZE
  Date: 08-25-94  09:08
*)

{
From: mav@dseg.ti.com (Michael Vincze)

>Does anyone know how to use the decompression tool
>incorporated into MS-Windows (lzexpand.dll) in BP7?

Here's an example.  Note that you can only do decompression and not
compression :^(
}
  function CopyLZ (FileIn, FileOut: PChar): LongInt;
  var
    HandleIn  : Integer;
    HandleOut : Integer;
    StructIn  : TOFStruct;
    StructOut : TOFStruct;
    ReturnCode: LongInt;
  begin
  HandleIn := LZOpenFile (FileIn, StructIn, OF_READ);
  ReturnCode := LongInt (HandleIn);
  if (HandleIn > -1) then
    begin
    HandleOut := LZOpenFile (FileOut, StructOut, OF_CREATE or OF_WRITE);
    ReturnCode := LongInt (HandleOut);
    if (HandleOut > -1) then
      begin
      ReturnCode := LZCopy (HandleIn, HandleOut);
      LZClose (HandleOut);
      end;
    end;
  LZClose (HandleIn);
  CopyLZ := ReturnCode;
  end;

