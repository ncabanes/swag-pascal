{
> I need to be able to create a screen then load it into Video Memory.
> Then load it on to the screen... Does anyone have any routines to do
> this??? Thanks...

      Try the following codes
}
Program VidRAMStuff;
Uses
  Crt;
Const
  ScreenHeight = 25;
  ScreenWidth = 80;
Type
  OneChar = Record
    Character : Char;
    Attribute : Byte;
    end;
  RAMBuffer = Array [1..ScreenHeight, 1..ScreenWidth] of OneChar;
  RAMBufPtr = ^RAMBuffer;
Var
  RowLoop, ColLoop : Byte;
  DataFile : Text;
  VideoRAM : RAMBufPtr;

begin
  If (LastMode = 7) { means that the system is monochrome }
    Then
      VideoRAM := Ptr ($B000, $0000) { Segment:Offset address }
    Else
      VideoRAM := Ptr ($B800, $0000);
  Assign (DataFile, 'TESTING.TXT');
  ReWrite (DataFile);
  For RowLoop := 1 to ScreenHeight Do
    begin
      For ColLoop := 1 to ScreenWidth Do
        Write (DataFile, VideoRAM^ [RowLoop, ColLoop].Character);
      WriteLn (DataFile);
    end;
  Close (DataFile);
  {************************ File Saved *****************************}
  {* Just add your own code to read in the data File and loaded it *}
  {* back to the screen and you're all set!                        *}
  {*****************************************************************}
end.

