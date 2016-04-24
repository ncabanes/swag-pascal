(*
  Category: SWAG Title: STREAM HANDLING ROUTINES
  Original name: 0003.PAS
  Description: TEMSStream.Done Bug
  Author: DJ MURDOCH & ALEXANDER PETROSYAN
  Date: 11-26-94  04:57
*)

{
There's a bug in TEMSStream.Done.  It leaves EMSCurHandle and EMSCurPage with
the last used values, even though it's releasing an EMS handle, which may
well be EMSCurHandle.  This means that if you allocate a second EMSStream
after disposing of the first one, it can happen that it sees the page frame
as already valid, when in fact it should load it.
A workaround is to set EMSCurHandle := $FFFF after calling TEMSStream.Done.

Here's some sample code to demonstrate the bug.  It was posted to Usenet's
comp.lang.pascal:

  From: paf@fbit.msk.su (Alexander Petrosyan)
  Subject: TEMSStream trouble (Bug?)
  Date: Mon, 26 Sep 94 16:24:34 +0400

  Try to compile and run this prog:
}

uses
  Objects,
  wincrt;

var
  ES: TEMSStream;
  A, B: array [0..$400-1] of Byte;
  I, J: Integer;

procedure Error;
begin
  WriteLn ('Error !');
  ES.Done;
  Halt (1);
end;

begin
  FillChar (A, $400, 1);
  ES.Init (18 * $400, 18 * $400);            { Allocate 18K EMS }
  for I := 1 to 18 do ES.Write (A, $400);    { Fill with 1 }
  ES.Seek (0);
  for I := 1 to 10{*} do begin                  { Read 10K of 18K }
    ES.Read (B, $400);
    for J := Low (B) to High (B) do if B[J] <> 1 then { Verify }
      Error;
  end;
  ES.Done;                                   { Free allocated EMS }

{ Above code causes problem to below code }

(*  emscurhandle := $ffff;  *)    { Uncomment this line to fix the bug }

  FillChar (A, $400, 2);
  ES.Init (79 * $400, 79 * $400);            { Allocate 79K EMS }
  for I := 1 to 79 do ES.Write (A, $400);    { Fill with 2 }
  ES.Seek (0);
  for I := 1 to 79 do begin                  { Verify ALL }
    ES.Read (B, $400);
    for J := Low (B) to High (B) do if B[J] <> 2 then
      Error;  { I'm getting error at this point. Why? }
  end;
  ES.Done;

  writeln('Done');
{
  It seems that 1st page of this stream when being read are mapped not to the
  right place but to some page of previous stream.
}
end.

(*
It seems to me that error occurs when stream position at dispose time not in
last 16K EMS page (stream must be readed before dispose).

In this example we are writing 18K but reading 10K leaving stream position
not  in last page. When I change 10 to 18 at {*} all goes OK.
*)

