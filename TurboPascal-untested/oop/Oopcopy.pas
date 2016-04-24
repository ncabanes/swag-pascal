(*
  Category: SWAG Title: OOP/TURBO VISION ROUTINES
  Original name: 0012.PAS
  Description: OOPCOPY.PAS
  Author: ANDRES CVITKOVICH
  Date: 05-28-93  13:53
*)

{************************************************}
{                                                }
{   Turbo Pascal 6.0                             }
{   Turbo Vision Utilities                       }
{   Written (w) 1993 by Andres Cvitkovich        }
{                                                }
{   Public Domain                                }
{                                                }
{************************************************}

Unit TVUtis;

{$F+,O+,S-,D-,B-}

Interface

Uses Dos, Objects, Views, App;

Type
  PProgressBar = ^TProgressBar;
  TProgressBar = Object (TView)
    empty, filled: Char;
    total: LongInt;
    percent: Word;
    Constructor Init (Var Bounds: TRect; ch_empty,
      ch_filled: Char; totalwork: LongInt);
    Procedure Draw; virtual;
    Procedure SetTotal (newtotal: LongInt);
    Procedure Update (nowdone: LongInt); virtual;
    Procedure UpdatePercent (newpercent: Integer); virtual;
  end;

  PFileCopy = ^TFileCopy;
  TFileCopy = Object
    bufsize: Word;
    buffer: Pointer;
    ConstRUCTOR Init (BufferSize: Word);
    Destructor Done; VIRTUAL;
    Function  SetBufferSize (newsize: Word): Word; VIRTUAL;
    Function  CopyFile (File1, File2: PathStr): Integer; VIRTUAL;
    Procedure Progress (Bytesdone, Bytestotal: LongInt;
      percent: Integer); VIRTUAL;
    Function  Error (code: Word): Integer; VIRTUAL;
  end;

Implementation

Uses drivers;

Constructor TProgressBar.Init (Var Bounds: TRect; ch_empty, ch_filled: Char;
totalwork: LongInt);
begin
  TView.Init (Bounds);
  total  := totalwork;
  empty  := ch_empty;
  filled := ch_filled;
  percent := 0;
end;

Procedure TProgressBar.Draw;
Var
  S: String;
  B: TDrawBuffer;
  C: Byte;
  y: Byte;
  newbar: Word;
begin
  if (Size.X * Size.Y) = 0 then Exit;              { Exit if no extent }
  C := GetColor (6);
  MoveChar (B, empty, C, Size.X);
  MoveChar (B, filled, C, Size.X * percent div 100);
  WriteLine (0, 0, Size.X, Size.Y, B);
end;


Procedure TProgressBar.SetTotal (newtotal: LongInt);
begin
  total := newtotal
end;

Procedure TProgressBar.Update (nowdone: LongInt);
Var newpercent: Word;
begin
  if total=0 then Exit;
  newpercent := 100 * nowdone div total;
  if newpercent > 100 then newpercent := 100;
  if percent <> newpercent then begin
    percent := newpercent;
    DrawView
  end;
end;

Procedure TProgressBar.UpdatePercent (newpercent: Integer);
begin
  if newpercent > 100 then newpercent := 100;
  if percent <> newpercent then begin
    percent := newpercent;
    DrawView
  end;
end;


{
  TFileCopy.Init
  ──────────────

  initializes the Object and allocates memory

    BufferSize   size of buffer in Bytes to be allocated For disk i/o

}
ConstRUCTOR TFileCopy.Init (BufferSize: Word);
begin
  If MaxAvail < BufferSize Then
    bufsize := 0
  Else
    bufsize := BufferSize;
  If bufsize > 0 Then GetMem (buffer, bufsize);
end;


{
  TFileCopy.Done
  ──────────────

  Destructor, free up buffer memory

}
Destructor TFileCopy.Done;
begin
  If bufsize > 0 Then FreeMem (buffer, bufsize);
  { bufsize := 0; }   { man weiß ja nie... }
end;


{
  TFileCopy.SetBufferSize
  ───────────────────────

  change buffer size

    NewSize = new size of disk i/o buffer in Bytes

}
Function TFileCopy.SetBufferSize (newsize: Word): Word;
begin
  If MaxAvail >= newsize Then begin
    If bufsize > 0 Then FreeMem (buffer, bufsize);
    bufsize := newsize;
    If bufsize > 0 Then GetMem (buffer, bufsize);
  end;
  SetBufferSize := bufsize
end;


{
  TFileCopy.CopyFile
  ──────────────────

  copy a File onto another; no wildcards allowed
  calls Progress and Error

    File1   source File
    File2   target File

  Error code returned:

   1  low on buffer memory
   2  error opening source File
   3  error creating destination File
   4  error reading from source File
   5  error writing to destination File
   6  error writing File date/time and/or attributes

}
Function TFileCopy.CopyFile (File1, File2: PathStr): Integer;
Var fsrc, fdest: File;
    fsize, ftime, cnt, cnt1: LongInt;
    fattr, rd, wr, iores: Word;
begin
  {$I-}
  If bufsize = 0 then begin CopyFile := 1; Exit end;
  Assign (fsrc, File1);
  Repeat
    Reset (fsrc, 1);
    iores := IOResult;
    If iores <> 0 Then
      If Error (iores) = 1 Then begin
        CopyFile := 2;
        Exit
      end;
  Until iores = 0;
  Assign (fdest, File2);
  Repeat
    ReWrite (fdest, 1);
    iores := IOResult;
    If iores <> 0 Then
      If Error (iores) = 1 Then begin
        Close (fsrc);
        CopyFile := 3;
        Exit
      end;
  Until iores = 0;
  fsize := FileSize (fsrc);
  GetFTime (fsrc, ftime);
  GetFAttr (fsrc, fattr);
  Repeat
    Repeat
      cnt := FilePos (fsrc);
      BlockRead (fsrc, buffer^, bufsize, rd);
      iores := IOResult;
      If iores <> 0 Then begin
        If Error (iores) = 1 Then begin      {abort?}
          Close (fsrc);                      {* }
          Close (fdest);                     {* hier könnte man auch}
          Erase (fdest);                     {* Error aufrufen, naja...}
          CopyFile := 4;
          Exit;
        end;
        Seek (fsrc, cnt);      {step back on retry!}
      end;
    Until iores = 0;
    if rd > 0 then
      Repeat
        cnt1 := FilePos (fdest);
        BlockWrite (fdest, buffer^, rd, wr);
        iores := IOResult;
        If (rd <> wr) or (iores <> 0) Then begin
          If Error (iores) = 1 Then begin      {abort?}
            Close (fsrc);                      {* }
            Close (fdest);                     {* hier könnte man auch}
            Erase (fdest);                     {* Error aufrufen, naja...}
            CopyFile := 5;
            Exit;
          end;
          Seek (fdest, cnt1);      {step back on retry!}
        end;
      Until (rd = wr) and (iores = 0);
    Progress (cnt, fsize, cnt * 100 div fsize);
  Until (rd = 0) or (rd <> wr);
  Close (fsrc);
  Repeat
    Close (fdest);     {close&flush}
    iores := IOResult;
    If iores <> 0 Then If Error (iores) = 1 Then Exit;
  Until iores = 0;
  Reset (fdest);
  If IOResult <> 0 Then begin CopyFile := 6; Exit end;
  SetFTime (fdest, ftime);
  SetFAttr (fdest, fattr);
  If IOResult <> 0 Then begin Close (fdest); CopyFile := 6; Exit end;
  Close (fdest);
end;


{
  TFileCopy.Progress
  ──────────────────

  is called by CopyFile to allow displaying a progress bar or s.e.

    Bytesdone    Bytes read in and written
    Bytestotal   Bytes to read&Write total (that is, File size)
    percent      amount done in percent

}
Procedure TFileCopy.Progress (Bytesdone, Bytestotal: LongInt; percent:
Integer);
begin
  {abstract - inherit For use!}
end;

{
  TFileCopy.Error
  ───────────────

  is called by CopyFile if an error occured during the copy process

    code   the IOResult code <> 0

  should return an Integer value:

    0  Repeat action
    1  abort

  Note: TurboVision installs it's own Dos critical error handler, so you
        don't need to overWrite Error (only called if Abort is chosen from
        the TV Error Msg) if you use CopyFile in a TV Program.

}
Function TFileCopy.Error (code: Word): Integer;
begin
  Error := 1;
end;


end.


{
> Unit TVUtis;
>
>   Wow...never seen so much code just to copy a File! =)

well, it's a quite extendable Object, and there's a lot of error-checking,
too.  just see below... :-)

>   I haven't tried OOP yet, and probably was lucky to

>      Anyways, I see you left out a progress display in
>   TFileCopy.Progress, but the Unit also has an a progress bar
>   Object.  Any way to marry the two?

of course, that's why I put them together!
but I didn't want to have the progress bar (and along With this Turbo Vision)
being an essential part of the FileCopy Object, since some guys might want to
Write their own ProgressBars or use the whole Object in a non-TV Program.

>    I implemented your TCopyFile like so...
>
>     Uses Dos, TVUtis;
>     Var
>       DoCopy: TFileCopy;
>       F1, F2: PathStr;
>       R: Integer;
>     begin
>       F1 := 'C:\tp\copyf.pas';
>       F2 := 'C:\copyf.pas';
>       DoCopy.Init(4096);
>       R := DoCopy.CopyFile(F1, F2);
>       DoCopy.Done;
>       Writeln(R);
>     end.

Absolutely correct, no doubt. But poor Graphics...  ;-)

>      How would one modify that and TFileCopy.Progress to use
>     TProgressBar? From what I can surmise, you'd init
>      TProgressBar and then TFilecopy.Progress would
>       call it somehow, like TProgressBar.Update?
>       I don't see what I should put For the totalwork of
>       TProgressBar.Init; the size of the File? Then that
>       means I must cal TProgress.Init from inside
>       TFileCopy.CopyFile (after we have the size of the
>       File.) And TFileCopy.Progress would call
>        TProgressBar.Update.

first of all: The TProgressBar Object is written For Turbo Vision, you can't
use it within a non-TV Program. Next, you have to derive your own Object from
TFileCopy and overWrite the method Progress that calls TProgressBar. Take the
following as an example:
}

Type
  PXFileCopy = ^TXFileCopy;
  TXFileCopy = Object (TFileCopy)
    AProgressBar: PProgressBar;
    ConstRUCTOR Init (BufferSize: Word; ProgBar: PProgressBar);
    Procedure Progress (Bytesdone, Bytestotal: LongInt;
                        percent: Integer); VIRTUAL;
  end;

ConstRUCTOR TXFileCopy.Init (BufferSize: Word; ProgBar: PProgressBar);
begin
  inherited Init (BufferSize);     { or TFileCopy.Init For TP 6 }
  AProgressBar := ProgBar;
end;

Procedure TXFileCopy.Progress (Bytesdone, Bytestotal: LongInt;
                               percent: Integer);
begin
  if AProgressBar <> NIL then
    AProgressBar^.UpdatePercent (percent);
end;
{
You then would use this Object (in a Turbo Vision Program) as follows:
}

Function TMyApp.CopyFile (source, dest: PathStr): Integer;
Var
  Dlg: TDialog;
  MyBar: PProgressBar;
  R: TRect;
  DoCopy: TXFileCopy;
begin
  R.Assign (0,0,40,8);
  Dlg.Init (R, 'Copying File...');
  Dlg.Options := Dlg.Options or ofCentered;
  Dlg.Flags := Dlg.Flags and not wfClose;
  R.Assign (2,2,38,4);
  Dlg.Insert (New (PStaticText, Init (R, ^C'copying '+source+#13+
                                      ^C'to '+dest+', please wait...')));
  R.Assign (2,5,38,6);
  Dlg.Insert (New (PStaticText, Init (R,
                   '0%              50%             100%')));
  R.Move (0, 1);
  MyBar := New (PProgressBar, Init (R, '░', '▓', 0));
  Dlg.Insert (MyBar);
  Desktop^.Insert (@Dlg);
  DoCopy.Init (4096, MyBar);
  ErrorCode := DoCopy.CopyFile (source, dest);
  DoCopy.Done;
  Dlg.Done;
  if ErrorCode <> 0 then
    MessageBox ('Error copying File!', NIL, mfError+mfOkButton);
end;

{
If you don't want to have any progress bar at all, just pass NIL instead of
MyBar to DoCopy.Init. And maybe you want to add this Functionality directly to
TFileCopy rather than deriving a new Object.
}

