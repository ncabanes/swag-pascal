(*
  Category: SWAG Title: TEXT FILE MANAGEMENT ROUTINES
  Original name: 0015.PAS
  Description: Reading Text Backwards
  Author: LARS FOSDAL
  Date: 08-27-93  20:12
*)

{
LARS FOSDAL

> I'm working on a project where Text Records are appended to a disk File
> at regular intervals.  I'd like to position the Pointer at the end of the
> File and read the line ending at the end of File into a null-terminated
> String (BP7).
> I can think of a couple of ways to implement this quickly:  1) prepend
> the Record to the File instead of appending, and 2) Write a fast driver
> to do the backwards reading For me.

1) Prepending instead of appending...
   I think you might run into some problems With this...
   To prepend a line, you must first read the entire File,
   then move to the start of the File again, Write the new Record,
   and finally Write back all the Records you first read.
   The overhead would become enormous if the File was large.

2) Fast driver For backwards reading...  Aha!
   This is the way to do it.

   Below you will find the source of a "tail" Program.
   I wrote it because I needed to check the status of some log Files,
   and I didn't want to go through the entire File every time, as the
   Files could grow quite large.

   It is currently limited to 255 Chars per line, but that
   can easily be fixed (see the Limit Const).

   Although it's not an exact solution to your problem, it will show you
   how to do "backwards" reading.
}

Program Tail;
{
  Shows the tailing lines of a Text File.

  Syntax: TAIL [d:\path]Filespec.ext [-<lines>]
          Default number of lines is 10.

          "TAIL Filename -20" will show the 20 last lines

  Written by Lars Fosdal, 1993
  Released to the Public Domain by Lars Fosdal, 1993
}

Uses
  Dos, Objects, Strings;

Const
  MaxBufSize = 32000;

Type
  pBuffer = ^TBuffer;
  TBuffer = Array[0..MaxBufSize-1] of Char;

  pRawStrCollection = ^TRawStrCollection;
  TRawStrCollection = Object(TCollection)
    Procedure FreeItem(Item : Pointer); VIRTUAL;
  end;

  CharSet = Set of Char;

Var
  r, l, e : Integer;


Procedure TRawStrCollection.FreeItem(Item : Pointer);
begin
  if Item <> nil then
    StrDispose(pChar(Item));
end;

Function ShowTail(FileName : String; n : Integer) : Integer;
Const
  Limit = 255;
Var
  lines   : pRawStrCollection;
  fm      : Byte;
  f       : File;
  fs, fp  : LongInt;
  MaxRead : Word;
  Buf     : pBuffer;
  lc, ix,
  ex      : Integer;
  sp      : Array [0..Limit] of Char;

  Procedure DumpLine(p : pChar); Far;
  begin
    if p^ = #255 then
      Writeln
    else
      Writeln(p);
  end;

begin
  lines := nil;
  fm    := FileMode;
  FileMode := $40; {Read-only, deny none}
  Assign(f, FileName);
  Reset(f, 1);
  lc := IOResult;

  if lc = 0 then
  begin
    New(Buf);

    fs := FileSize(f); {First, let's find out how much to read}
    fp := fs - MaxBufSize;
    if fp < 0 then
      fp := 0;

    Seek(f, fp); {Then, read it}
    BlockRead(f, Buf^, MaxBufSize, MaxRead);
    Close(f);

    if MaxRead > 0 then
    begin
      New(Lines, Init(n, 10));
      ix := MaxRead - 1;

      if Buf^[ix] = ^J then
        Dec(ix);
      if (ix > 0) and (Buf^[ix] = ^M) then
        Dec(ix); {Skip trailing line break}

      While (lc < n) and (ix > 0) DO
      begin
        ex := ix;
        FillChar(sp, SizeOf(sp), 0);

        While (ix > 0) and not (Buf^[ix] = ^J) DO
          Dec(ix);

        if ex - ix <= Limit then
        {if no break was found Within limit, it's no txt File}
        begin
          if ix = ex then
            sp[0] := #255 {Pad empty lines to avoid zero-length pChar}
          else
            StrLCopy(sp, @Buf^[ix + 1], ex - ix);
          Inc(lc);

          Lines^.AtInsert(0, StrNew(sp));

          Dec(ix);
          While (ix > 0) and (Buf^[ix] = ^M) DO
            Dec(ix);
        end
        else
        begin
          Writeln('"', FileName, '" doesn''t seem to be a Text File');
          ix := -1;
        end;

      end; {lc<n and ix>0}
    end {Maxread>0}
    else
      Lines := nil;
    Dispose(Buf);
  end
  else
    lc := -lc;

  if Lines <> nil then
  begin
    Lines^.ForEach(@DumpLine);
    Dispose(Lines, Done);
  end;

  ShowTail := lc;
  FileMode := fm;
end;

Function StripAll(Const Exclude : CharSet; S : String) : String;
Var
  ix : Integer;
begin
  ix := Length(S);
  While ix > 0 DO
  begin
    if S[ix] in Exclude then
      Delete(S, ix, 1);
    Dec(ix);
  end;
  StripAll := S;
end;

begin
  if (ParamCount < 1) or (ParamCount > 2) then
  begin
    Writeln('TAIL v.1.0 - PD 1993 Lars Fosdal');
    Writeln('  TAIL [d:\path]Filename.ext [-n]');
    Writeln('  Default is 10 lines');
  end
  else
  begin
    if ParamCount = 2 then
    begin
      Val(StripAll(['/','-'], ParamStr(2)), l, e);
      if e <> 0 then
        l := 10
    end
    else
      l := 10;

    r := ShowTail(ParamStr(1), l);
    if r < 0 then
    begin
      Writeln('Couldn''t open "', ParamStr(1), '"!  (Error ', -r, ')');
      Halt(Word(-r));
    end;
  end;
end.

