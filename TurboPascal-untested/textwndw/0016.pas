{
> I can't find a procedure to call and display a text
> to the screen inside a window [window(1,2,80,24)] and be able to put pauses
> scrolling into it if'n it takes up more than 23 lines of text.

I took a swing at this when I saw your message.  I wrote a little unit called
BuffrTxt that should be pretty self-explainatory, since I was so generous
with my comments.  Is this pretty much what you were looking for?

{ **********************************************************************
  *                           BufferText                               *
  *                               by                                   *
  *                         Todd A. Jacobs                            *
  *                                                                   *
  *        Buffers a text file to prevent a view port overflow.        *
  **********************************************************************

This code is hereby released into the public domain.  This program was an
excercise I did when someone asked about how to read a text file into a
text window without having it all scroll off the screen.

This unit buffers the text into an array which is based on how many lines
exist between the upper and lower boundaries of the window.  One of the
problems with doing it this way is that if the text read in is the same
width as the view port, it will wrap--thereby throwing off the buffer.  To
"solve" this, I elected to truncate the lines to prevent wrapping. }

Unit BuffrTxt;

Interface

Var
  Lines : Byte;

{Example parameters for DefineWindow:

    DefineWindow (10, 3, 70, 23, 1, 15);

The first four XY parameters are self-explanitory.  BG & FG set the
background and foreground colors for the text viewport. }
Procedure DefineWindow (ULeftX, ULeftY, LRightX, LRightY, BG, FG : BYTE);
Procedure ReadFile (FileName : String);

{By keeping all the details hidden inside the implementation, you won't
have to recompile every piece of source you have used this with if you
change one of the constants, because the interface will remain the same. }
Implementation

Uses Crt;

Const
  PauseStr = '-=[ Press any key to continue ]=-';
  MaxScrWidth = 80;
  MaxArraySize = 25;

Procedure DefineWindow;
Begin {DefineWindow}
  Lines := LRightY - ULeftY; {Sets boundaries for use in ReadFile}
  Window (ULeftX, ULeftY, LRightX, LRightY);
  TextBackground (BG);
  TextColor (FG);
  ClrScr;
End; {DefineWindow}

Procedure ReadFile;

{Set the size of the array from the window boundaries as defined in
the constants}
Type
  StringArray = Array [1..MaxArraySize] of String[MaxScrWidth];
Var
  F: Text;
  TmpBuf: String[MaxScrWidth]; {Will truncate longer lines to prevent wrap}
  StrBuf: StringArray;  {This buffer holds 25 lines of 80 cols each}
  Counter1, Counter2: Byte;

Begin {ReadFile}
  Assign(F, FileName);
  Reset(F);
  While not Eof(F) do
  Begin
    {Initialize the counters each time through the loop}
    Counter1 := 0;
    Counter2 := 0;
    Repeat  {This is where the buffer is restricted to Y2 - Y1 Lines}
     Inc (Counter1);
     Readln(F, TmpBuf);
     StrBuf[Counter1] := TmpBuf;
    Until Eof(F) or (Counter1 = Lines);  {Also prevents reading past EOF}

    {Write buffered lines to the screen}
    For Counter2 := 1 to Counter1 do
     Writeln (StrBuf[Counter2]);
    Write (PauseStr);
    Readln;
  End; {Goes back for more buffering "while not EOF"}
  Close(F);
End; {ReadFile}

End.  {Unit}

