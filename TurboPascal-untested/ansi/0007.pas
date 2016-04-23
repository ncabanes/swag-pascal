{
 Well here it is again, its a little rough and some of the Crt.tpu Functions
are left out. This Unit will generate Ansi TextColor and TextBackGrounds.
Becuase of the Ansi screen Writes you can send the Program to the com port
just by using CTTY or GateWay in a bat File before you start your Program.
}

Unit Crtclone;

Interface

Const
{ Foreground and background color Constants }

  Black         = 0;
  Blue          = 1;
  Green         = 2;
  Cyan          = 3;
  Red           = 4;
  Magenta       = 5;
  Brown         = 6;
  LightGray     = 7;

{ Foreground color Constants }

  DarkGray      = 8;
  LightBlue     = 9;
  LightGreen    = 10;
  LightCyan     = 11;
  LightRed      = 12;
  LightMagenta  = 13;
  Yellow        = 14;
  White         = 15;

{ Add-in For blinking }

  Blink         = 128;

Var

{ Interface Variables }

  CheckBreak: Boolean;    { Enable Ctrl-Break }
  CheckEOF: Boolean;      { Enable Ctrl-Z }
  Procedure TextColor(Color: Byte);
  Procedure TextBackground(Color: Byte);
  Function KeyPressed  : Boolean;
  Function GetKey      : Char;
  Function ReadKey     : Char;
  Function WhereX      : Byte;
  Function WhereY      : Byte;
  Procedure NormVideo;
  Procedure ClrEol;
  Procedure ClrScr;
  Procedure GotoXY(X, Y : Byte);


  Implementation

  Function KeyPressed : Boolean;   { Replacement For Crt.KeyPressed }
                         {  ;Detects whether a key is pressed}
                         {  ;Does nothing With the key}
                         {  ;Returns True if key is pressed}
                         {  ;Otherwise, False}
                         {  ;Key remains in kbd buffer}
    Var IsThere : Byte;
    begin
      Inline(
      $B4/$0B/               {    MOV AH,+$0B         ;Get input status}
      $CD/$21/               {    INT $21             ;Call Dos}
      $88/$86/>ISTHERE);     {    MOV >IsThere[BP],AL ;Move into Variable}
      if IsThere = $FF then KeyPressed := True else KeyPressed := False;
    end;

  Procedure  ClrEol;     { ANSI replacement For Crt.ClrEol }
    begin
      Write(#27'[K');
    end;

  Procedure ClrScr;     { ANSI replacement For Crt.ClrScr }
    begin
      Write(#27'[2J');
    end;

  Function GetKey : Char;     { Additional Function.  Not in Crt Unit }
    Var CH : Char;
    begin
      Inline(
                     {; Function GetKey : Char}
                     {; Clears the keyboard buffer then waits Until}
                     {; a key is struck.  if the key is a special, e.g.}
                     {; Function key, goes back and reads the next}
                     {; Byte in the keyboard buffer.  Thus does}
                     {; nothing special With Function keys.}
       $B4/$0C       {       MOV  AH,$0C      ;Set up to clear buffer}
      /$B0/$08       {       MOV  AL,8        ;then to get a Char}
      /$CD/$21       {SPCL:  INT  $21         ;Call Dos}
      /$3C/$00       {       CMP  AL,0        ;if it's a 0 Byte}
      /$75/$04       {       JNZ  CHRDY       ;is spec., get second Byte}
      /$B4/$08       {       MOV  AH,8        ;else set up For another}
      /$EB/$F6       {       JMP  SHORT SPCL  ;and get it}
      /$88/$46/>CH   {CHRDY: MOV  >CH[BP],AL  ;else put into Function return}
       );
      if CheckBreak and (Ch = #3) then
        begin        {if CheckBreak is True and it's a ^C}
          Inline(    {then execute Ctrl_Brk}
          $CD/$23);
        end;
      GetKey := Ch;
    end; {Inline Function GetKey}


  Function ReadKey : Char;  { Replacement For Crt.ReadKey }
    Var chrout : Char;
    begin
                         {  ;Just like ReadKey in Crt Unit}
      Inline(
      $B4/$07/               {  MOV AH,$07          ;Char input w/o echo}
      $CD/$21/               {  INT $21             ;Call Dos}
      $88/$86/>CHROUT);      {  MOV >chrout[bp],AL  ;Put into Variable}
      if CheckBreak and (chrout = #3) then  {if it's a ^C and CheckBreak True}
        begin                             {then execute Ctrl_Brk}
          Inline(
          $CD/$23);           {     INT $23}
        end;
      ReadKey := chrout;                    {else return Character}
    end;

  Function WhereX : Byte;       { ANSI replacement For Crt.WhereX }
    Var                         { Cursor position report. This is column or }
      ch  : Char;               { X axis report.}
      st  : String;
      st1 : String[2];
      x   : Byte;
      i   : Integer;

    begin
      Write(#27'[6n');          { Ansi String to get X-Y position }
      st := '';                 { We will only use X here }
      ch := #0;                 { Make sure Character is not 'R' }
      While ch <> 'R' do        { Return will be }
        begin                   { Esc - [ - Ypos - ; - Xpos - R }
          ch := #0;
          ch := ReadKey;        { Get one }
          st := st + ch;        { Build String }
        end;
        St1 := copy(St,6,2);    { Pick off subString having number in ASCII}
        Val(St1,x,i);           { Make it numeric }
        WhereX := x;            { Return the number }
    end;

  Function WhereY : Byte;       { ANSI replacement For Crt.WhereY }
    Var                         { Cursor position report.  This is row or }
      ch  : Char;               { Y axis report.}
      st  : String;
      st1 : String[2];
      y   : Byte;
      i   : Integer;

    begin
      Write(#27'[6n');          { Ansi String to get X-Y position }
      st := '';                 { We will only use Y here }
      ch := #0;                 { Make sure Character is not 'R' }
      While ch <> 'R' do        { Return will be }
        begin                   { Esc - [ - Ypos - ; - Xpos - R }
          ch := #0;
          ch := ReadKey;        { Get one }
          st := st + ch;        { Build String }
        end;
        St1 := copy(St,3,2);    { Pick off subString having number in ASCII}
        Val(St1,y,i);           { Make it numeric }
        WhereY := y;            { Return the number }
    end;


    Procedure GotoXY(x : Byte ; y : Byte); { ANSI replacement For Crt.GoToXY}
      begin
        if (x < 1) or (y < 1) then Exit;
        if (x > 80) or (y > 25) then Exit;
        Write(#27'[',y,';',x,'H');
      end;

   Procedure TextBackGround(Color:Byte);
    begin
     Case color of
          0: begin      Write(#27#91#52#48#109); end;
          1: begin      Write(#27#91#52#52#109); end;
          2: begin      Write(#27#91#52#50#109); end;
          3: begin      Write(#27#91#52#54#109); end;
          4: begin      Write(#27#91#52#49#109); end;
          5: begin      Write(#27#91#52#53#109); end;
          6: begin      Write(#27#91#52#51#109); end;
          6: begin      Write(#27#91#52#55#109); end;
     end;
   end;

   Procedure TextColor(Color:Byte);
     begin
      Case color of
         0: begin  Write(#27#91#51#48#109); end;
         1: begin  Write(#27#91#51#52#109); end;
         2: begin  Write(#27#91#51#50#109); end;
         3: begin  Write(#27#91#51#54#109); end;
         4: begin  Write(#27#91#51#49#109); end;
         5: begin  Write(#27#91#51#53#109); end;
         6: begin  Write(#27#91#51#51#109); end;
         7: begin  Write(#27#91#51#55#109); end;
         8: begin  Write(#27#91#49#59#51#48#109); end;
         9: begin  Write(#27#91#49#59#51#52#109); end;
        10: begin  Write(#27#91#49#59#51#50#109); end;
        11: begin  Write(#27#91#49#59#51#54#109); end;
        12: begin  Write(#27#91#49#59#51#49#109); end;
        13: begin  Write(#27#91#49#59#51#53#109); end;
        14: begin  Write(#27#91#49#59#51#51#109); end;
        15: begin  Write(#27#91#49#59#51#55#109); end;
       128: begin  Write(#27#91#53#109); end;
      end;
     end;

 Procedure NormVideo;
      begin
        Write(#27#91#48#109);
      end;

end.
