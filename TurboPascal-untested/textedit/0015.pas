{$B+}    {Boolean complete evaluation on}
{$I+}    {I/O checking on} 
{$N-}    {No numeric coprocessor} 
{$R-}    {Range checking off} 
{$S-}    {Stack checking on}
{$V-}    {Var String checking off} 
 
Uses Crt,Dos,Printer;
 
Const 
   MaxWidth      = 128; 
   RtMrg         : Integer = 76; 
   LeftM         : Integer = 1; 
   Wrap          : Boolean = True; 
   InSrt         : Boolean = True;
   GoodColorCard : Boolean = True;     {set false for IBM CGA} 
 
Type 
   Line       = String[MaxWidth]; 
   LPtr       = ^LineRec; 
   LineRec    = Record
                  Last : LPtr; 
                  Data : Line; 
                  Next : LPtr; 
                  Clr  : BYTE;
                  End;
   ScreenLine = String[80]; 
   String80   = String[80]; 
   Word       = String[24]; 

Var 
   LWord                    : ScreenLine;     { left margin spacer } 
   Find ,Repl , 
   InPut,OutPut             : Word; 
   Fore , Back, Attr        : Byte;           { text colors for Write} 
   BaseOfScreen,Mode        : LongInt;        { used by FASTWRITE } 
   WaitforRetrace           : Boolean;        {  "   "      "     } 
   VidStatPort, VidModePort : LongInt;        {  "   "      "     } 
   ModePortData             : Byte Absolute $40 : $65; {          } 
   SearchString, 
   Replacement              : ScreenLine; 
   TextLine ,BlankLine      : ScreenLine; 
   FileFound, 
   Finished ,Changed        : Boolean; 
   TabSet                   : Array [1..MaxWidth] Of Boolean;
   TextFile                 : Text; 
   WorkFile                 : Text; 
   Ln,LastLn,NextLn, 
   FirstLn,EndLn            : LPtr; 
   MaxLines                 : Integer ; 
   IBeg    , IEnd           : Integer ; 
   BlockBeg, BlockEnd       : LPtr; 
   I , J,                     {cursor position: i = line, j = column} 
   Len,                       {length of current line} 
   NLines,                    {length of file} 
   NBl,                       {number of buffer lines} 
   Top,                       {first line on screen} 
   Offset, K, N             : Integer; 
   Choice, Ch               : Char; 

(*-------------------------------------------------------------------*) 
 
Function YN: Boolean; 
Begin 
  Repeat 
    Ch := ReadKey 
  Until Ch In['y','Y','n','N']; 
  If UpCase(Ch) = 'Y' Then 
    YN := True 
  Else YN := False; 
End; 
 
Procedure Beep; 
Begin 
  Sound(800);
  Delay(400); 
  NoSound; 
  Delay(1000); 
End; 
 
Procedure Capitalize(var fname:word); 
Begin 
  For J := 1 To Length(FName) Do 
    FName[J] := UpCase(FName[J]); 
End; 
 
Procedure ReadFile; 
Var  OvFlw     : Boolean; 
     InputLine : String[255]; 
Begin
  If ParamStr(1) = '' Then 
    Begin 
      Write('File to edit: '); 
      ReadLn(Input); 
    End 
  Else 
    InPut := ParamStr(1); 
  Capitalize(Input); 
  New(Ln); 
  Ln^.Data := ''; 
  FirstLn  := Ln; 
  EndLn    := Ln; 
  Assign(WorkFile,Input); 
  {$I-} ReSet(WorkFile); {I+} 
  If IoResult = 0 Then
    Begin 
      OvFlw := False; 
      MaxLines := MemAvail Div 12; 
      If MaxLines < 0 Then 
        MaxLines := 2730; 
      NLines := 0; 
      Write(' Reading file '); 
      While Not (Eof(WorkFile) Or OvFlw) Do 
        Begin 
          ReadLn(WorkFile,InputLine); 
          If Length(InputLine) > MaxWidth Then 
            Begin 
              WriteLn('File is too fat for this editor'); 
              OvFlw := True; Delay(1000); 
            End
          Else 
            Begin 
              Ln^.Data := InputLine; 
              LastLn   := Ln; 
              New(Ln); 
              Ln^.data     := ''; 
              Ln^.last     := LastLn; 
              LastLn^.Next := Ln; 
              NLines       := NLines + 1; 
              If NLines > MaxLines Then 
                Begin 
                  WriteLn('File is too long. Not enough memory'); 
                  OvFlw := True; Delay(1000); 
                End; 
            End; 
        End;       {not EOF} 
     EndLn := Ln; 
     If Not OvFlw Then 
       FileFound := True; 
    End   {IOresult = 0} 
  Else 
    Begin 
      Write('Can''t find this file. Is this a new file?'); 
      If YN Then 
        Begin 
          FileFound := True; 
          NLines := 1; 
          New(Ln); 
          Ln^.Data      := ''; 
          FirstLn^.Next := Ln; 
          Ln^.Last      := FirstLn; 
          EndLn         := Ln; 
        End 
      Else 
        FileFound := False; 
    End; 
  Close(WorkFile); 
End; 
 
Procedure WriteFile;     { save changes to file } 
Begin 
  GotoXY(1,1); For J := 1 To 45 Do Write(' '); 
  GotoXY(1,1); Write('Text was changed. Save? '); 
  If YN Then 
    Begin 
      Write('as: '); ReadLn(OutPut); 
      If OutPut = '' Then 
        OutPut := Input; 
      Capitalize(OutPut); 
      GotoXY(40,1); WriteLn('    Writing to disk as ',OutPut); 
      Assign(WorkFile,OutPut); 
      ReWrite(WorkFile); 
      Ln := EndLn^.Next; 
      Repeat 
        WriteLn(WorkFile,Ln^.Data); 
        Ln := Ln^.Next 
      Until Ln = EndLn; 
      Close(WorkFile); 
   End; 
End; 
 
{------------------------- FastWrite Routines -------------------------} 
 
Function Attribute(Foreground, Background : Byte) : Byte; 
  {-Translates foreground and background colors into video attributes. 
    "And 127" masks out the blink bit. Add 128 to the result to set it.} 
Begin 
   Attribute := ((Background Shl 4) + Foreground) And 127; 
End; 
 
Function EgaInstalled : Boolean; 
  {-Test for presence of the EGA. I have little idea how this works, but 
    it does.} 
Begin 
Inline( 
  $B8/$00/$12      {      MOV AX,$1200} 
  /$BB/$10/$00     {      MOV BX,$10} 
  /$B9/$FF/$FF     {      MOV CX,$FFFF} 
  /$CD/$10         {      INT $10} 
  /$31/$C0         {      XOR AX,AX} 
  /$81/$F9/$FF/$FF {      CMP CX,$FFFF} 
  /$74/$01         {      JE DONE} 
  /$40             {      INC AX} 
  /$88/$46/$04     {DONE: MOV [BP+$04],AL} 
); 
End; 
 
Procedure GetVideoMode; 
  {-Video mode of 7 indicates mono display; all other modes are for color 
    displays. This routine MUST be called before any of the screen writing 
    routines are used!} 
Var 
  Mode : Integer; 
  Vid  : Integer Absolute $40 : $63; 
Begin 
     Inline( 
       $B4/$0F        {MOV AH,$F} 
       /$CD/$10       {INT $10} 
       /$30/$E4       {XOR AH,AH} 
       /$89/$46/<Mode {MOV [BP+<Mode],AX} 
     ); 
     If Mode = 6 Then Mode := 7; 
     If Mode = 7 Then BaseOfScreen := $B000  { Mono } 
                 Else BaseOfScreen := $B800; { Color } 
     VidStatPort    := Vid + 6;   {video status port for either card} 
     VidModePort    := Vid + 4;   {video mode port for either card} 
     WaitForRetrace := (BaseOfScreen = $B800) And Not EgaInstalled; 
     { *VERY IMPORTANT*  WaitForRetrace MUST be false if BaseOfScreen = $B000. } 
End; 
 
Procedure VideoOff; 
{-avoid snow writing full screen to c/g card} 
Begin 
  {clear video enable bit} 
  Port[VidModePort] := ModePortData And 247; 
End; 
 
Procedure VideoOn; 
{-reenable video} 
Begin 
  {set video enable bit} 
  Port[VidModePort] := ModePortData Or 8; 
End; 
 
Procedure FastWrite( St : String80; Row, Col, Attr : Byte ); 
  {-Write St directly to video memory, without snow.} 
Begin 
Inline( 
  $1E                    {         PUSH DS                  ;Save DS} 
  /$31/$C0               {         XOR AX,AX                ;AX = 0} 
  /$88/$C1               {         MOV CL,AL                ;CL = 0} 
  /$8A/$AE/>Row          {         MOV CH,[BP+>Row]         ;CX = Row * 256} 
  /$FE/$CD               {         DEC CH                   ;Row to 0..24 range} 
  /$D1/$E9               {         SHR CX,1                 ;CX = Row * 128} 
  /$89/$CF               {         MOV DI,CX                ;Store in DI} 
  /$D1/$EF               {         SHR DI,1                 ;DI = Row * 64} 
  /$D1/$EF               {         SHR DI,1                 ;DI = Row * 32} 
  /$01/$CF               {         ADD DI,CX                ;DI = (Row * 160)} 
  /$8B/$8E/>Col          {         MOV CX,[BP+>Col]         ;CX = Column} 
  /$49                   {         DEC CX                   ;Col to 0..79 range} 
  /$D1/$E1               {         SHL CX,1                 ;Account for attribute bytes} 
  /$01/$CF               {         ADD DI,CX                ;DI = (Row * 160) + (Col * 2)} 
  /$8E/$06/>BaseOfScreen {         MOV ES,[>BaseOfScreen]   ;ES:DI points to Base:Row,Col} 
  /$8A/$0E/>WaitForRetrace{        MOV CL,[>WaitForRetrace] ;Grab this before changing DS} 
  /$8C/$D2               {         MOV DX,SS                ;Move SS...} 
  /$8E/$DA               {         MOV DS,DX                ; into DS} 
  /$8D/$B6/>St           {         LEA SI,[BP+>St]          ;DS:SI points to St[0]} 
  /$FC                   {         CLD                      ;Set direction to forward} 
  /$AC                   {         LODSB                    ;AX = Length(St); DS:SI -> St[1]} 
  /$91                   {         XCHG AX,CX               ;CX = Length; AL = Wait} 
  /$E3/$29               {         JCXZ Exit                ;If string empty, Exit} 
  /$8A/$A6/>Attr         {         MOV AH,[BP+>Attr]        ;AH = Attribute} 
  /$D0/$D8               {         RCR AL,1                 ;If WaitForRetrace is False...} 
  /$73/$1D               {         JNC NoWait               ; use NoWait routine} 
  /$BA/$DA/$03           {         MOV DX,$03DA             ;Point DX to CGA status port} 
  /$AC                   {Next:    LODSB                    ;Load next character into AL} 
                         {                                  ; AH already has Attr} 
  /$89/$C3               {         MOV BX,AX                ;Store video word in BX} 
  /$FA                   {         CLI                      ;No interrupts now} 
  /$EC                   {WaitNoH: IN AL,DX                 ;Get 6845 status} 
  /$A8/$08               {         TEST AL,8                ;Check for vertical retrace} 
  /$75/$09               {         JNZ Store                ; In progress? go} 
  /$D0/$D8               {         RCR AL,1                 ;Else, wait for end of} 
  /$72/$F7               {         JC WaitNoH               ; horizontal retrace} 
  /$EC                   {WaitH:   IN AL,DX                 ;Get 6845 status again} 
  /$D0/$D8               {         RCR AL,1                 ;Wait for horizontal} 
  /$73/$FB               {         JNC WaitH                ; retrace} 
  /$89/$D8               {Store:   MOV AX,BX                ;Move word back to AX...} 
  /$AB                   {         STOSW                    ; and then to screen} 
  /$FB                   {         STI                      ;Allow interrupts} 
  /$E2/$E8               {         LOOP Next                ;Get next character} 
  /$EB/$04               {         JMP SHORT Exit           ;Done} 
  /$AC                   {NoWait:  LODSB                    ;Load next character into AL} 
                         {                                  ; AH already has Attr} 
  /$AB                   {         STOSW                    ;Move video word into place} 
  /$E2/$FC               {         LOOP NoWait              ;Get next character} 
  /$1F                   {Exit:    POP DS                   ;Restore DS} 
); 
End; 
 
Procedure FastWriteV( Var St; Row, Col, Attr : Byte ); 
  {-Works with string variables ONLY. (I made St an untyped parameter 
    only to make this easier to use when type checking is on.) This is 
    just FastWrite optimized for use with string Variables, for times 
    when speed really matters.} 
Begin 
Inline( 
  $1E                    {         PUSH DS} 
  /$31/$C0               {         XOR AX,AX} 
  /$88/$C1               {         MOV CL,AL} 
  /$8A/$6E/<Row          {         MOV CH,[BP+<Row]} 
  /$FE/$CD               {         DEC CH} 
  /$D1/$E9               {         SHR CX,1} 
  /$89/$CF               {         MOV DI,CX} 
  /$D1/$EF               {         SHR DI,1} 
  /$D1/$EF               {         SHR DI,1} 
  /$01/$CF               {         ADD DI,CX} 
  /$8B/$4E/<Col          {         MOV CX,[BP+<Col]} 
  /$49                   {         DEC CX} 
  /$D1/$E1               {         SHL CX,1} 
  /$01/$CF               {         ADD DI,CX} 
  /$8E/$06/>BaseOfScreen {         MOV ES,[>BaseOfScreen]} 
  /$8A/$0E/>WaitForRetrace{        MOV CL,[>WaitForRetrace]} 
  /$C5/$76/<St           {         LDS SI,[BP+<St]          ;DS:SI points to St[0]} 
  /$FC                   {         CLD} 
  /$AC                   {         LODSB} 
  /$91                   {         XCHG AX,CX} 
  /$E3/$28               {         JCXZ Exit} 
  /$8A/$66/<Attr         {         MOV AH,[BP+<Attr]} 
  /$D0/$D8               {         RCR AL,1} 
  /$73/$1D               {         JNC NoWait} 
  /$BA/$DA/$03           {         MOV DX,$03DA} 
  /$AC                   {Next:    LODSB} 
  /$89/$C3               {         MOV BX,AX} 
  /$FA                   {         CLI} 
  /$EC                   {WaitNoH: IN AL,DX} 
  /$A8/$08               {         TEST AL,8} 
  /$75/$09               {         JNZ Store} 
  /$D0/$D8               {         RCR AL,1} 
  /$72/$F7               {         JC WaitNoH} 
  /$EC                   {WaitH:   IN AL,DX} 
  /$D0/$D8               {         RCR AL,1} 
  /$73/$FB               {         JNC WaitH} 
  /$89/$D8               {Store:   MOV AX,BX} 
  /$AB                   {         STOSW} 
  /$FB                   {         STI} 
  /$E2/$E8               {         LOOP Next} 
  /$EB/$04               {         JMP SHORT Exit} 
  /$AC                   {NoWait:  LODSB} 
  /$AB                   {         STOSW} 
  /$E2/$FC               {         LOOP NoWait} 
  /$1F                   {Exit:    POP DS} 
); 
End; 
 
{------------------------- FastWrite Routines -------------------------} 
 
Procedure RulerLine; 
Var 
  C , J : Byte; 
Begin 
  TextLine := BlankLine; 
  For J := 1 To 79 Do 
    Begin 
      If J Mod 5 = 0 Then 
        TextLine[J] := '+' 
      Else 
        TextLine[J] := '-'; 
      C := 48 + ((J + Offset) Div 10) Mod 10 ; 
      If J Mod 10 = 0 Then 
        TextLine[J] := Chr(C); 
    End; 
  FastWriteV(TextLine,2,1, Attr); 
  If (Wrap) Then   { put margin markers on ruler } 
    Begin 
      Textcolor(14); 
      TextBackGround(Green); 
      if LeftM >= Offset Then 
        Begin 
          GotoXY(LeftM - Offset + 1, 2); 
          Write('|'); 
        End; 
      If RtMrg >= Offset Then 
        Begin 
          GotoXY(RtMrg - Offset + 1, 2); 
          Write('|'); 
        End; 
      TextColor( Fore ); 
      TextBackGround( Back ); 
   End; 
End; 
 
Procedure StatusLine; 
Begin 
  Textline := BlankLine; 
  Insert(' Line:      Column:',TextLine,1); 
  If Insrt Then Insert('Insert ',TextLine,26) 
    Else Insert('OverWrite ',TextLine,25); 
  If Wrap  Then Insert(' WordWrap',TextLine,35) 
    Else Insert('  NoWrap   ',TextLine,35); 
  Insert(' Workfile:',TextLine,47); 
  Insert(Input,TextLine,58); 
  FastWriteV(TextLine,1,1,Attr); 
  RulerLine; 
End; 
 
Procedure WriteLine(Row,Attr:Byte);    { direct write to screen } 
Var Len        : Byte;                 { writes blanks where there is no text} 
    Contents   : ScreenLine; 
Begin 
  TextLine := BlankLine; 
  Contents := Copy(Ln^.Data,Offset,80); 
  Len      := Ord(Contents[0]); 
  Insert(Contents,TextLine,1); 
  If Len = 80 Then TextLine[80] := '+' 
    Else If Len > 0 Then TextLine[80] := '<'; 
  FastWriteV(TextLine,Row,1,Attr); 
End; 
 
Procedure Screen;     { rewrites the bottom 23 lines } 
Var Row   : Byte; 
    TopLn : LPtr; 
Begin                 { makes sure i and ln are in register } 
  Ln := EndLn^.Next; 
  If Top > 1 Then 
   For K := 2 To Top Do 
    Ln := Ln^.Next; 
  TopLn := Ln; 
  For Row := 3 to 25 do 
   Begin 
    WriteLine(Row,Attr); 
    If Ln <> EndLn Then 
     Ln := Ln^.Next; 
   End; 
  Ln  := TopLn; 
  Row := I - Top; 
  While Row > 0 do 
   Begin 
    Ln  := Ln^.Next; 
    Row := Row - 1; 
   End; 
End; 
 
Procedure Help; 
Begin 
  Window(1, 1, 80, 25); 
  ClrScr;
  GetVideoMode;
  FastWrite('╔══════════════════════════════════════════════════════════════════════════════╗', 1, 1, Attr );
  FastWrite('║                    Window Editor -- by GDSOFT                                ║', 2, 1, Attr );
  FastWrite('║ ┌───────────────────────┐ ┌───────────────────────┐ ┌──────────────────────┐ ║', 3, 1, Attr );
  FastWrite('║ │  ^X      line up      │ │  ^S     column left   │ │  Alt-A   Ascii       │ ║', 4, 1, Attr );
  FastWrite('║ │  ^E      line down    │ │  ^D     column right  │ │  Alt-B   Back Color  │ ║', 5, 1, Attr );
  FastWrite('║ │  ^C      page up      │ │  ^PgUp  file home     │ │  Alt-C   Copy Block  │ ║', 6, 1, Attr );
  FastWrite('║ │  ^R      page down    │ │  ^PgDn  file end      │ │  Alt-D   Del  Block  │ ║', 7, 1, Attr );
  FastWrite('║ │  ^K      quit         │ │  ^N     insert line   │ │  Alt-F   Fore Color  │ ║', 8, 1, Attr );
  FastWrite('║ │  ^P      set margins  │ │  ^Y     delete line   │ │  Alt-G   Goto Block  │ ║', 9, 1, Attr );
  FastWrite('║ │  ^BkSp   delete word  │ │  BkSp   delete char   │ │  Alt-M   Move Block  │ ║',10, 1, Attr );
  FastWrite('║ │  ^V      toggle ins   │ │  Ins    toggle insert │ │  Alt-N   Clr  Marks  │ ║',11, 1, Attr );
  FastWrite('║ │  ^W      window dn    │ │                       │ │  Alt-S   Beg  Block  │ ║',12, 1, Attr );
  FastWrite('║ │  ^Z      window up    │ │  Del    delete char   │ │  Alt-T   End  Block  │ ║',13, 1, Attr );
  FastWrite('║ │  ^Home   erase bol    │ │  Home   beg of line   │ │                      │ ║',14, 1, Attr );
  FastWrite('║ │  ^End    erase eol    │ │  End    end of line   │ │  SPELLING CHECK      │ ║',15, 1, Attr );
  FastWrite('║ │  ^F      next word    │ │  Tab    next tab stop │ │  Alt-0   Document    │ ║',16, 1, Attr );
  FastWrite('║ │  ^A      prev word    │ │  BTab   last tab stop │ │  Alt-1   Word        │ ║',17, 1, Attr );
  FastWrite('║ │  F1      help         │ │  F6     replace       │ │                      │ ║',18, 1, Attr );
  FastWrite('║ │  F2      clear marks  │ │  F7     page up       │ │                      │ ║',19, 1, Attr );
  FastWrite('║ │  F3      quit         │ │  F8     page down     │ │                      │ ║',20, 1, Attr );
  FastWrite('║ │  F4      set margins  │ │  F9     prev word     │ │                      │ ║',21, 1, Attr );
  FastWrite('║ │  F5      search       │ │  F10    next word     │ │                      │ ║',22, 1, Attr );
  FastWrite('║ └───────────────────────┘ └───────────────────────┘ └──────────────────────┘ ║',23, 1, Attr );
  FastWrite('║                  Press any key to return to your editing.....                ║',24, 1, Attr );
  FastWrite('╚══════════════════════════════════════════════════════════════════════════════╝',25, 1, Attr );
  Repeat
  Until KeyPressed;
  Ch := ReadKey;
  StatusLine;
  Screen; 
End; 
 
Procedure PageUp; 
Begin 
  If Top > 22 Then Begin 
    Top := Top - 22; I := I - 22; End 
  Else Begin 
    I := I - Top + 1; Top := 1; End; 
  Screen; 
End; 
 
Procedure PageDown; 
begin 
  If Top <= (NLines - 44) Then 
   Begin 
    Top := Top + 22; 
    I := I + 22; 
   End 
  Else If NLines > 22 Then 
   Begin 
    I := I - Top + NLines - 22; 
    Top := NLines - 22; 
   End; 
  Screen; 
End; 
 
Procedure Cursor;       { make sure the cursor is visible on the screen } 
Var ii,jj,chgd : Word; 
    Shifted    : Boolean; 
Begin 
  Shifted := False; 
  If I < 1 Then 
    Begin 
      I  := 1; 
      Ln := EndLn^.Next; 
    End; 
  If I > NLines Then 
    Begin 
      I  := NLines; 
      Ln := EndLn^.Last; 
    End; 
  If J < 1 Then 
    J := 1; 
  If J > MaxWidth Then 
    J := MaxWidth; 
  Len := Ord(Ln^.Data[0]); 
  If ( J > Offset + 77 ) Then 
    Begin 
      Offset  := 10 * ( J Div 10 ) - 59; 
      Shifted := True; 
    End; 
  If J < Offset Then 
    Begin 
      Offset  := 10 * ( ( J - 10 ) Div 10 ) + 1; 
      Shifted := True; 
    End; 
  If I < Top Then 
    Begin 
      Top     := I; 
      Shifted := True; 
    End; 
  If I > Top + 22 Then 
    Begin 
      Top     := I - 22; 
      Shifted := True; 
    End; 
  If Shifted Then 
    Begin 
      RulerLine; 
      Screen; 
    End; 
  Str(i:4,ii); 
  Str(j:3,jj); 
  If Changed Then Chgd := ' * ' 
    Else Chgd := '   '; 
  FastWriteV(ii,1,7,Attr);    GetVideoMode; 
  FastWriteV(jj,1,20,Attr);   GetVideoMode; 
  FastWriteV(Chgd,1,76,Attr); GetVideoMode; 
  GotoXY( J - Offset + 1, i - top + 3); 
End; 
 
Procedure CursorLeft; 
Begin 
  J := J - 1; 
  If J < 1 Then 
    Begin 
      I := I - 1; 
      If I < 1 Then 
        Begin 
          I  := 1; 
          J  := 1; 
          Ln := EndLn^.Next ; 
          Exit; 
        End; 
      J := Length(Ln^.Last^.Data) + 1 ; 
      Ln := Ln^.Last ; 
   End 
End; 
 
Procedure CursorRight; 
Begin 
  j := j + 1; 
  if j > MaxWidth then 
    Begin 
      i := i + 1; 
      If I > NLines then 
        Begin 
          I  := NLines; 
          Ln := EndLn^.Last ; 
        End 
      Else If I < NLines Then 
        Ln := Ln^.Next ; 
      J := 1; 
    End; 
End; 
 
Procedure ParaForm;  { set margins, wordwrap on/off } 
Begin 
  GotoXY(1,1); ClrEol; 
  Write('WordWrap? '); 
  If YN Then 
    Wrap := True 
  Else 
    Begin 
      Wrap  := False; 
      LeftM := 1; 
      LWord := ''; 
    End; 
  If Wrap Then 
    Begin 
      GotoXY(15,1); Write('Left margin: '); 
      ReadLn(LeftM); 
      LWord := ''; 
      While Length(LWord) < LeftM - 1 Do 
        LWord := LWord + ' '; 
      RulerLine; 
      Repeat 
        GotoXY(35,1); Write('Right margin: '); 
        ReadLn(RtMrg); 
      Until RtMrg > LeftM + 24; 
    End; 
  ClrScr; 
  StatusLine; 
  Screen; 
End;    { ParaForm } 
 
Procedure InsertLn(contents:line);  {insert after current line} 
Begin 
  New(NextLn); 
  NextLn^.Data := Contents; 
  NextLn^.Last := Ln; 
  NextLn^.Next := Ln^.Next; 
  Ln^.Next^.Last := NextLn; 
  Ln^.Next := NextLn; 
  NLines   := NLines + 1; 
End; 
 
Procedure CutLine;    { start new line after <CR> } 
Var 
  More : Line; 
Begin 
  More := Copy(Ln^.Data,J,Len-J+1); 
  Delete(Ln^.Data,J,Len-J+1); 
  InsertLn(LWord + More); 
  i := i + 1; 
  j := LeftM; 
  Screen; 
End; 
 
Procedure WordWrap; 
Begin 
  N := 0; 
  Repeat 
    J := J - 1; 
    N := N + 1; 
  Until (Ln^.Data[J] = ' ') Or (J = 1); 
  J   := J + 1; 
  Len := Len + 1; 
  CutLine; 
  J := LeftM + N - 1 ; 
end; 
 
Procedure StackLine;   { put current line on top of previous line } 
begin 
  j := length(ln^.last^.data)+1; 
  ln^.last^.data := ln^.last^.data + ln^.data; 
  ln^.last^.next := ln^.next;     { isolate current line } 
  ln^.next^.last := ln^.last; 
  Dispose(Ln);                    { and zap it} 
  I := I - 1; 
  NLines := NLines - 1; 
  Screen; 
End; 
 
Procedure DeleteLine; 
Begin 
  Ln^.Last^.Next := Ln^.Next;     { isolate current line } 
  Ln^.Next^.Last := Ln^.Last; 
  Dispose(Ln);                    { and zap it} 
  J  := 1 ;  I := I - 1; 
  NLines  := NLines - 1; 
  Changed := True; 
  StatusLine; 
  Screen; 
End; 
 
Procedure DeleteEOL; 
Begin 
  If J < MaxWidth Then 
    Begin 
      Ln^.Data := Copy ( Ln^.Data, 1 , J - 1 ) ; 
      Changed := True; 
    End; 
  If J > 1 Then 
    J := J - 1; 
  StatusLine ; 
  Screen ; 
End; 
 
Procedure DeleteBOL; 
Begin 
  If J > 1 Then 
    Begin 
      Ln^.Data := Copy ( BlankLine, 1, J ) + Copy ( Ln^.Data, J + 1 , MaxWidth ) ; 
      Changed := True; 
    End; 
  If J < MaxWidth Then 
    J := J + 1; 
  StatusLine ; 
  Screen ; 
End; 
 
Procedure DeleteWord; 
Var 
  EndW : Byte; 
Begin 
  While (( Copy(Ln^.Data,J,1) <> ' ' ) And ( J > 0 )) Do 
    J := J - 1 ; 
  If J = 0 Then 
    J := 1 ; 
  EndW := J + 1; 
  While (( Copy(Ln^.Data,EndW,1) <> ' ' ) And ( EndW < MaxWidth )) Do 
    EndW := EndW + 1 ; 
  If J = 1 Then 
    Ln^.Data := Copy ( Ln^.Data , EndW + 1, MaxWidth ) 
  Else 
    Ln^.Data := Copy ( Ln^.Data, 1, J ) + Copy ( Ln^.Data , EndW + 1, MaxWidth ) ; 
  Changed := True ; 
  StatusLine ; 
  Screen ; 
End; 
 
Procedure PrevWord; 
Begin 
(* if i am in a word then skip to the space *) 
  While (Not ((Ln^.Data[j] = ' ') Or ( j >= Length(Ln^.Data) ))) And 
         (( i <> 1 ) Or ( j <> 1 )) Do 
      CursorLeft; 
(* find end of previous word *) 
  While ((Ln^.Data[j] = ' ') Or ( j >= Length(Ln^.Data) )) And 
         (( i <> 1 ) Or ( j <> 1 )) Do 
      CursorLeft; 
(* find start of previous word *) 
  While (Not ((Ln^.Data[j] = ' ') Or ( j >= Length(Ln^.Data) ))) And 
         (( i <> 1 ) Or ( j <> 1 )) do 
      CursorLeft; 
   CursorRight; 
End; 
 
Procedure NextWord; 
Begin 
(* if i am in a word, then move to the whitespace *) 
  while (not ((Ln^.Data[j] = ' ') or ( j >= length(Ln^.Data)))) and 
        ( i < NLines ) do 
    CursorRight; 
(* skip over the space to the other word *) 
  while ((Ln^.Data[j] = ' ') or ( j >= Length(Ln^.Data))) and 
         ( i < NLines ) do 
    CursorRight; 
End; 
 
Procedure Tab; 
Begin 
  If J < MaxWidth Then 
    Begin 
      Repeat 
        J := J + 1; 
      Until ( TabSet [J]= True ) Or ( J = MaxWidth ); 
    End; 
End; 
 
Procedure BackTab; 
Begin 
  If J > 1 Then 
    Begin 
      Repeat 
         J := J - 1; 
      Until ( TabSet [J]= True ) Or ( J = 1 ); 
  End; 
End; 
 
Procedure Search; 
var 
  Temp              : ScreenLine; 
  Pointer, Position : Integer; 
  LocPtr , Location : Integer; 
  TmpPtr            : LPtr; 
Begin 
   Window(1, 1, 80, 25); 
   GotoXY(1, 1); ClrEol; 
   Write('Search:     Enter string: <',SearchString,'> '); 
   Temp := ''; 
   ReadLn(Temp); 
   If Temp <> '' Then 
      SearchString := Temp; 
   If Length( SearchString ) = 0 Then 
     Begin 
       StatusLine; 
       Screen; 
       Exit; 
     End; 
   GotoXY(1,1); ClrEol; 
   Write('Searching...'); 
   NextWord; 
   TmpPtr := Ln; 
   LocPtr := J; 
   For Location := I + 1 To NLines Do 
     begin 
       (* look for matches on this line *) 
       Pointer := Pos (SearchString, Copy(Ln^.Data,LocPtr,MaxWidth)); 
       (* if there was a match then get ready to print it *) 
       If (Pointer > 0) Then 
         Begin 
           I := Location - 1 ; 
           J := Pointer; 
           StatusLine; 
           Screen; 
           Exit; 
         End 
       Else If Location <> NLines Then 
         Begin 
           Ln := Ln^.Next ; 
           LocPtr := 1 ; 
         End 
   End; 
   Window(1, 1, 80, 25); 
   GotoXY(1, 1); ClrEol; 
   Write('Search string not found.  Press any key to exit...'); 
   Repeat 
   Until KeyPressed; 
   Ch := ReadKey; 
   Ln := TmpPtr ; 
   StatusLine; 
   Screen; 
End; 
 
Procedure Replace; 
Var 
  Temp               : ScreenLine; 
  Pointer , Position : Integer; 
  Location, Len      : Integer; 
Begin 
  Window(1, 1, 80, 25); 
  GotoXY(1, 1); ClrEol; 
  Write('Replace:     Enter search string: <',SearchString,'> '); 
  Temp := ''; 
  ReadLn(Temp); 
  If Temp <> '' Then 
    SearchString := Temp; 
  If Length(SearchString) = 0 Then 
    Begin 
      StatusLine; 
      Screen; 
      Exit; 
    End; 
  GotoXY(1, 1); ClrEol; 
  Write('Replace:     Enter replacement string: <',replacement,'> '); 
  Temp := ''; 
  ReadLn(Temp); 
  if Temp <> '' Then 
    Replacement := Temp; 
  Len := Length (Replacement); 
  Ln  := EndLn^.Next ; 
  I   := 1 ;  J := 1 ; 
  GotoXY(1, 1);  ClrEol; 
  Write('Searching...'); 
  For Location := 1 to NLines Do 
    Begin 
      (* look for matches on this line *) 
      Position := Pos (SearchString, Ln^.Data ); 
      (* if there was a match then get ready to print it *) 
      While (Position > 0) Do 
        Begin 
          I   := Location ; 
          J   := Position ; 
          If Location > 8 Then 
            Top := Location - 8 
          Else 
            Top := 1 ; 
          Screen ; 
          TextColor( Back ); 
          TextBackGround( Fore ); 
          GotoXY( J - Offset + 1, I - Top + 3 ); 
          Write ( SearchString ); 
          TextColor( Fore ); 
          TextBackGround( Back ); 
          GotoXY(1, 1); ClrEol; 
          Write('Replace (Y/N/ESC)? '); 
          Ch := ReadKey; 
          If Ord (Ch)= 27 Then 
            Begin 
              I  := 1; 
              J  := 1; 
              Ln := EndLn^.Next ; 
              StatusLine; 
              Screen; 
              Exit; 
            End; 
          If Ch In ['y','Y'] Then 
            Begin 
              Ln^.Data := Copy (Ln^.Data, 1, Position - 1) + Replacement + 
                              Copy (Ln^.Data, Position + Length (SearchString), MaxWidth); 
              Position := Pos (SearchString, Copy (Ln^.Data, Position + Len + 1,MaxWidth)) ; 
            End 
          Else 
            Position := Pos (SearchString, Copy (Ln^.Data, Position + Length(SearchString) + 1,MaxWidth)) ; 
        End; 
      Ln := Ln^.Next ; 
      GotoXY(1, 1);  ClrEol; 
      Write('Searching...'); 
    End; 
  Window(1, 1, 80, 25); 
  GotoXY(1, 1); ClrEol; 
  Write('End of replace.  Press any key to exit...'); 
  Repeat 
  Until KeyPressed; 
  Ch := ReadKey; 
  Ln := EndLn^.Next ; 
  I  := 1 ; 
  J  := 1 ; 
  StatusLine; 
  Screen; 
End; 
 
Procedure ClearMarks ; 
Begin 
  IBeg := 0 ; 
  IEnd := 0 ; 
  BlockBeg := Nil ; 
  BlockEnd := Nil ; 
End; 
 
Procedure InsertMark( Mark : Char ); 
Begin 
  If Mark = 'B' Then 
    Begin 
      If BlockBeg = Nil Then 
        Begin 
          BlockBeg := Ln ; 
          IBeg     := I  ; 
        End 
      Else  { BlockBeg Already Defined } 
        Write(#7); 
    End; 
  If Mark = 'E' Then 
    Begin 
      If BlockEnd = Nil Then 
        Begin 
          BlockEnd := Ln ; 
          IEnd     := I  ; 
        End 
      Else  { BlockEnd Already Defined } 
        Write(#7); 
    End; 
End; 
 
Procedure GotoBlock ; 
Begin 
  If BlockBeg <> Nil Then 
    Begin 
      Ln  := BlockBeg ; 
      I   := IBeg; 
      J   := 1 ; 
      If ( I >= 12 ) Then 
        Top := I - 8; 
      StatusLine ; 
      Screen ; 
    End; 
End; 
 
Procedure DeleteBlock; 
Var 
  TPtr   : LPtr; 
Begin 
  If IEnd < IBeg Then 
    Exit; 
  Ln := BlockEnd ; 
  I  := IEnd ; 
  Repeat 
    TPtr           := Ln^.Last;     { save location of previous line } 
    Ln^.Last^.Next := Ln^.Next;     { isolate current line } 
    Ln^.Next^.Last := Ln^.Last; 
    Dispose(Ln);                    { and zap it} 
    J  := 1 ;  I := I - 1; 
    NLines  := NLines - 1; 
    Ln      := TPtr; 
  Until Ln = BlockBeg^.Last ; 
  If I >= 12 Then 
    Top := I - 8 
  Else 
    Top := 1 ; 
  Changed := True; 
  ClearMarks; 
  StatusLine; 
  Screen; 
End; 
 
Procedure CopyBlock; 
var 
  TPtr : LPtr ; 
  Size : Integer; 
Begin 
  If IEnd < IBeg then 
    Exit; 
  If (IBeg < I) And (I <= IEnd) Then 
    Exit; 
  Size := IEnd - IBeg - 1;  { exclude markers } 
  If Size = 0 Then 
    Exit; 
  If NLines + Size <= MaxLines Then 
    Begin 
      Repeat 
          InsertLn (BlockEnd^.Data) ; 
          BlockEnd := BlockEnd^.Last ; 
          NLines   := NLines + 1 ; 
      Until BlockEnd = BlockBeg^.Last ; 
    End 
  Else 
    Write(#7); 
  Changed := True; 
  ClearMarks; 
  StatusLine; 
  Screen; 
End; 
 
Procedure MoveBlock; 
Var 
  Size : Integer; 
  TPtr : LPtr; 
Begin 
  If IEnd < IBeg Then 
    Exit; 
  If (IBeg <= I) And (I <= IEnd + 1) Then 
    Exit; 
  Size := IEnd - IBeg + 1; 
  If NLines + Size <= MaxLines Then 
    Begin 
      TPtr := Ln^.Next ; 
      BlockBeg^.Last^.Next := BlockEnd^.Next ; 
      BlockEnd^.Next^.Last := BlockBeg^.Last ; 
      Ln^.Next   := BlockBeg ; 
      TPtr^.Last := BlockEnd ; 
      BlockBeg^.Last := Ln ; 
      BlockEnd^.Next := TPtr ; 
    End 
  Else 
    Write(#7); 
  Changed := True; 
  ClearMarks; 
  StatusLine; 
  Screen; 
End; 
 
Procedure WriteBlock ; 
Var 
  TPtr : LPtr ; 
Begin 
  If ((BlockBeg = Nil) Or (BlockEnd = Nil)) Then 
    Exit ; 
  If IBeg + 1 < IEnd Then 
    Begin 
      GotoXY(1,1); For J := 1 To 45 Do Write(' '); 
      GotoXY(1,1); Write('Write Block To Disk ? '); 
      If YN Then 
        Begin 
          Write('as: '); ReadLn(OutPut); 
          If OutPut = '' Then 
            OutPut := Input; 
          Capitalize(OutPut); 
          GotoXY(40,1); WriteLn('    Writing to disk as ',OutPut); 
          Assign(WorkFile,OutPut); 
          ReWrite(WorkFile); 
          TPtr := BlockBeg; 
          Repeat 
            WriteLn(WorkFile,TPtr^.Data); 
            TPtr := TPtr^.Next 
          Until TPtr = BlockEnd; 
          Close(WorkFile); 
       End; 
    End 
  Else 
    Write(#7); 
  StatusLine ; 
  Screen ; 
End; 
 
Procedure AddChar;       { keyboard entry } 
begin 
  Changed := True; 
  While J > Len + 1 Do 
    Begin 
      Ln^.Data := Ln^.Data + ' ' ; 
      Len := Len + 1 ; 
    End; 
  If J = Len + 1 Then 
    Ln^.Data := Ln^.Data + Ch 
  Else If InSrt Then 
    Insert(Ch,Ln^.Data,J) 
  Else 
    Ln^.Data[J] := Ch; 
  J := J + 1; 
  WriteLine( I - Top + 3,Attr); 
  If  (J > RtMrg + 2) And Wrap Then 
    WordWrap; 
End; 
 
Procedure Ascii; 
Var 
  AscNo, Repeats, R : Integer; 
  AsciiLine         : ScreenLine; 
Begin 
  AsciiLine := ''; 
  GotoXY( 1, 1); ClrEol; 
  Write('Enter ASCII code number: --- '); 
  GotoXY(26,1); 
  Readln(AscNo); 
  GotoXY(1,1); 
  Write('Enter number of repeats: --  '); 
  GotoXY(26,1); 
  ReadLn(Repeats); 
  If Not(Repeats In [1..79]) Then 
    Repeats := 1; 
  If (AscNo > 0) And (AscNo < 256) Then 
    Begin 
      For R := 1 To Repeats Do 
        Begin 
          Ch := Chr(AscNo); 
          AsciiLine := AsciiLine + Ch ; 
        End; 
    End; 
  While J > Length(Ln^.Data) + 1 Do 
    Begin 
      Ln^.Data := Ln^.Data + ' ' ; 
      Len := Len + 1 ; 
    End; 
  J := J - 1; 
  If J = Length(Ln^.Data) + 1 Then 
    Ln^.Data := Ln^.Data + AsciiLine 
  Else If InSrt Then 
    Insert(AsciiLine,Ln^.Data,J) 
  Else 
    Ln^.Data := Copy(Ln^.Data,1,J) + AsciiLine + Copy(Ln^.Data,J + Length(AsciiLine),128); 
  Changed    := True; 
  StatusLine; 
  Screen; 
End; 
 
Procedure Leave; 
Var 
  Trash : Char; 
Begin 
  VideoOff; 
  Repeat 
  Until KeyPressed; 
  Trash := ReadKey; 
  If (Trash = #0) And (KeyPressed) Then 
    Trash := ReadKey; 
  VideoOn; 
End; 
 
Procedure Colors; 
Begin 
  Case Ch Of 
     #48 : Back  := (Back + 1) Mod 8; 
     #33 : Fore  := (Fore + 1) Mod 16; 
  End; 
  Attr := Attribute( Fore, Back ); 
  StatusLine; 
  Screen; 
End; 

Procedure Command;
Begin
  If Ch = #0 Then
    If KeyPressed Then Ch := ReadKey; { keypad input }
  Case Ch Of
{alt 1}  'x' : Begin
               { do something useful here }
               End;
{alt A}  #30 : Ascii;
{alt B, alt F}  #48,#33 : If Mode <> 7 Then Colors;
{alt C}  #46 : CopyBlock;
{alt D}  #32 : DeleteBlock;
{alt G}  #34 : GotoBlock;
{alt H}  #35 : Help;
{alt K}  #37 : ;
{alt L}  #38 : Leave; 
{alt M}  #50 : MoveBlock; 
{alt N}  #49 : ClearMarks; 
{alt S}  #31 : InsertMark('B'); 
{alt T}  #20 : InsertMark('E'); 
{alt W}  #17 : WriteBlock; 
{alt X}  #45 : Finished := True; 
{tab}     #9 : Tab; 
{bktab}  #15 : BackTab; 
{F1}     #59 : Help; 
{F2}     #60 : ClearMarks; 
{F3}     #61 : Finished := True; 
{F4}     #62 : ParaForm ; 
{F5}     #63 : Search ; 
{F6}     #64 : Replace; 
{F7}     #65 : PageUp ; 
{F8}     #66 : PageDown; 
{F9}     #67 : PrevWord; 
{F10}    #68 : NextWord; 
{home}   #71 : J := LeftM;
{end }   #79 : J := Len + 1; 
{^home} #119 : DeleteBOL; 
{^end } #117 : DeleteEOL; 
{^A} #116,#1 : PrevWord; 
{^D} #77, #4 : J := J + 1; 
{^S} #75,#19 : If J > 1 Then 
                 J := J - 1; 
{^E} #72, #5 : If I > 1 Then 
                 Begin 
                   I := I - 1; 
                   Ln := Ln^.Last; 
                 End; 
{^F} #115,#6 : NextWord; 
{^X} #80,#24 : If I < NLines Then 
                 Begin 
                   I  := I + 1; 
                   Ln := Ln^.Next; 
                 End; 
{del}#83, #7 : Begin 
                 Delete(Ln^.Data,J,1);
                 WriteLine(I - Top + 3,Attr); 
               End; 
{ <-- }   #8 : If J = 1 Then 
                 StackLine 
               Else 
                 Begin 
                   J := J - 1; 
                   Delete(Ln^.Data,J,1); 
                   Cursor; 
                   WriteLine(i - Top + 3,Attr); 
                 End; 
{^<--}  #127 : DeleteWord; 
{Enter}  #13 : Begin 
                 If InSrt Then 
                   Begin 
                     If J = Len Then 
                       J := J + 1; 
                     CutLine; 
                   End 
                 Else
                   Begin 
                     I := I + 1 ; 
                     J := 1 ; 
                     Ln^ := Ln^.Next^ 
                   End; 
               End; 
{^R} #73,#18 : PageUp; 
{^C} #81, #3 : PageDown; 
{^PgUp} #132 : Begin 
                 I   := 1; 
                 Top := 1; 
                 Ln  := FirstLn; 
                 Screen; 
               End; 
{^PgDn} #118 : Begin 
                 I   := NLines; 
                 Top := NLines - 22; 
                 Ln  := EndLn; 
                 Screen; 
               End;
{^Y}     #25 : DeleteLine; 
{^N}     #14 : Begin 
                 Ln := Ln^.Last; 
                 InsertLn(''); 
                 Screen; 
               End; 
{Ins}#22,#82 : Begin 
                 If InSrt Then 
                   InSrt := False 
                 Else 
                   InSrt := True; 
                 StatusLine; 
               End; 
{^P}     #16 : ParaForm; 
{^W}     #23 : If Top > 1 Then 
                 Begin 
                   Top := Top - 1;
                   I := I - 1;
                   Screen;
                 End;
{^Z}     #26 : If Top < NLines + 22 Then
                 Begin
                   Top := Top + 1;
                   I := I + 1;
                   Screen;
                 End;
{^K} #27,#11 : Finished := True;
          Else Begin
            GotoXY(1,1); WriteLn('****** COMMAND NOT RECOGNIZED ******                    ');
            Beep; StatusLine;
          End;
   End; {case}
End;

Begin {Main}

  CheckBreak  := TRUE;
  DirectVideo := TRUE;

  ClearMarks  ;
  GetVideoMode;

  IF BaseOfScreen = $B000 Then
     Begin
        Fore := White;
        Back := Black;
     End
  Else Begin
        Fore := White; { make these whatever you want }
        Back := Black;
       End;

  Attr  := Attribute( Fore, Back );
  TextColor( Fore );
  TextBackground( Back );
  ClrScr;
  BlankLine := '';
  For J := 1 To 80 Do
    BlankLine := BlankLine + ' ';
  For I := 1 To MaxWidth Do
    TabSet[I]:=( I Mod 8 ) = 1;
  FileFound := False;
  ReadFile;
  If FileFound Then Begin
    FirstLn^.Last := EndLn ;
    EndLn^.Next   := FirstLn ;    { close chain, endless loop }
    J    := 1;   I      := 1 ;
    Top  := 1;   Offset := 1 ;
    Find := '.'; Repl   := '';
    Nbl  := 0;   Lword  := '';
    SearchString := ''; Finished := False;
    Replacement  := ''; Changed  := False;
    ClrScr;
    StatusLine;
    Screen;
    Repeat
      Cursor;
      Ch := ReadKey;
      Case Ch Of
        #0..#31,#127 : Command;
                Else   AddChar;
      End;
    Until Finished;
    If Changed Then WriteFile;
  End;  {FileFound}

  TextAttr := 7;
  ClrScr;
End. 
