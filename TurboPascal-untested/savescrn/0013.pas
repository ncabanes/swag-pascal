{
:   Is there a way to save the current text screen so you can call it
: up later? (ie: Either save the screen so you can display something else
: in text, then bring back the first page, or to display graphics, then
: bring back the old text screen.)  Also, is there a way to dumb the screen
: to disk?

Here's the stuff i use... (It works from TP 4.0 and up)
}

Type
    ScreenRecord =
      Record
        X, Y: Byte; {x,y coord. of cursor}
        Screen: Pointer
      End;

  Var
    OriginalScreen: ScreenRecord;


Function QueryAdapterType: AdapterType;

  Var
    Code: Byte;
    Regs: Registers;

  Begin
    Regs.AH := $1A; { Attempt to call VGA Identify Adapter Function }
    Regs.AL := $00; { Must clear AL to 0 ... }
    Intr($10, Regs);
    If Regs.AL = $1A then { ...so that If $1A comes back in AL... }
      Begin { ...we know a PS/2 video BIOS is out there. }
      Case Regs.BL of { Code comes back in BL }
        $00:
          QueryAdapterType := None;
        $01:
          QueryAdapterType := MDA;
        $02:
          QueryAdapterType := CGA;
        $04:
          QueryAdapterType := EGAColor;
        $05:
          QueryAdapterType := EGAMono;
        $07:
          QueryAdapterType := VGAMono;
        $08:
          QueryAdapterType := VGAColor;
        $0A, $0C:
          QueryAdapterType := MCGAColor;
        $0B:
          QueryAdapterType := MCGAMono
        else
          QueryAdapterType := CGA
        End { Case }
      End
    else
    { Next we have to check for the presence of an EGA BIOS: }
      Begin
      Regs.AH := $12; { Select Alternate Function service }
      Regs.BX := $10; { BL=$10 means return EGA information }
      Intr($10, Regs); { Call BIOS VIDEO }
      If Regs.BX <> $10 then { BX unchanged means EGA is NOT there...}
        Begin
        Regs.AH := $12; { Once we know Alt Function exists... }
        Regs.BL := $10; { ...we call it again to see If it's... }
        Intr($10, Regs); { ...EGA color or EGA monochrome. }
        If Regs.BH = 0 then
          QueryAdapterType := EGAColor
        else
          QueryAdapterType := EGAMono
        End
      else { Now we know we have an EGA or MDA: }
        Begin
        Intr($11, Regs); { Equipment determination service }
        Code := (Regs.AL and $30) Shr 4;
        Case Code of
          1:
            QueryAdapterType := CGA;
          2:
            QueryAdapterType := CGA;
          3:
            QueryAdapterType := MDA
          else
            QueryAdapterType := CGA
          End { Case }
        End
      End
  End;


Function DeterminePoints: Integer;

  Var
    Regs: Registers;

  Begin
    Case QueryAdapterType of
      CGA:
        DeterminePoints := 8;
      MDA:
        DeterminePoints := 14;
      EGAMono, { These adapters may be using any of }
      EGAColor, { several different font cell heights, }
      VGAMono, { so we need to query the BIOS to find }
      VGAColor, { out which is currently in use. }
      MCGAMono, MCGAColor:
        Begin
        With Regs do
          Begin
          AH := $11; { EGA/VGA Information Call }
          AL := $30;
          BL := 0
          End;

        Intr($10, Regs);
        DeterminePoints := Regs.CX
        End
      End { Case }
  End;


Procedure SaveScreen(Var StashPtr: Pointer);

  Type
    VidPtr = ^VidSaver;
    VidSaver =
      Record
        Base, Size: Word;
        BufStart: Byte
      End;

  Var
    VidVector: VidPtr;
    StashBuf: VidSaver;
    VidBuffer: Pointer;
    Adapter: AdapterType;

  Begin
    Adapter := QueryAdapterType;
    With StashBuf do
      Begin
      Case Adapter of
        MDA, EGAMono, VGAMono, MCGAMono:
          Base := $B000
        else
          Base := $B800
        End; { Case }
      Case DeterminePoints of
        8:
          Case Adapter of
            CGA:
              Size := 4000; { 25-line screen }
            EGAMono, EGAColor:
              Size := 6880 { 43-line screen }
            else
              Size := 8000 { 50-line screen }
            End; { Case }
        14:
          Case Adapter of
            EGAMono, EGAColor:
              Size := 4000; { 25-line screen }
            else
              Size := 4320 { 27-line screen }
            End; { Case }
        16:
          Size := 4000
        End; { Case }
      VidBuffer := Ptr(Base, 0)
      End;

    { Allocate heap for whole shebang }
    GetMem(StashPtr, StashBuf.Size + 16);
    { Here we move *ONLY* the VidSaver Record (5 bytes) to the heap: }
    Move(StashBuf, StashPtr^, Sizeof(StashBuf));
    { This casts StashPtr, a generic pointer, to a pointer to a VidSaver: }
    VidVector := StashPtr;
      { Now we move the video buffer itself to the heap.  The vide data is
        written starting at the BufStart byte in the VidSaver Record, and
        goes on for Size bytes to fit the whole buffer.  Messy but hey,
        this is PC land! }
    Move(VidBuffer^, VidVector^.BufStart, StashBuf.Size);
  End;


Procedure RestoreScreen(StashPtr: Pointer);

  Type
    VidPtr = ^VidSaver;
    VidSaver =
      Record
        Base, Size: Word;
        BufStart: Byte
      End;

  Var
    DataSize: Word;
    VidVector: VidPtr;
    VidBuffer: Pointer;

  Begin
    VidVector := StashPtr; { Cast generic pointer onto VidSaver pointer }
    DataSize := VidVector^.Size;
    { Create a pointer to the base of the video buffer: }
    VidBuffer := Ptr(VidVector^.Base, 0);
    { Move the buffer portion of the data on the heap to the video buffer: }
    Move(VidVector^.BufStart, VidBuffer^, VidVector^.Size);
    FreeMem(StashPtr, DataSize + 16)
  End;
(*

Here's how you save a screen...

      With OriginalScreen do
        Begin
        X := WhereX; {save the x,y cursor positions...}
        Y := WhereY - 1;
        SaveScreen(Screen) {then the screen}
        End;

Here's how you restore a screen...

    With OriginalScreen do
      Begin
      RestoreScreen(Screen); {restore the screen}
      GotoXY(X, Y) {go back to the orig. cursor position}
      End;

:   While we're at it, I might as well get all my questions out of my
: system :)  First, is there a way to stop the program from crashing if
: someone enters a character instead of an integer (or any incompatible
: data types?)  I've been looking around but havn't found anything...

The best way is to read the number in as a string (characters), then use
the procedure Val(), to convert it from a character string to numeric.

: And lastly, how do you stop the program from crashing if a user enters
: a filename to load, and it doesn't exist?  I think this has something
: to do with the doserror (is that the function name?  Don't recall offhand)
: but I couldn't get it to work.

Check to see if the file exists, before you open it (Reset)...  Here's a
quick function..

Function Exists(FileName: String): Boolean;

  Begin
    Exists := FSearch(FileName, '') <> ''
  End;
*)
