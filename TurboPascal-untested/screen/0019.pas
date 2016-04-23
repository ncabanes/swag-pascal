unit scrn;
{$D-,I-,S-,V-}
interface
Uses
        Dos;
Const
      display : Boolean = true;
      FGround : Byte = 0;
      BGround : Byte = 0;
      attribute : Byte = 0;
      apage : Word = $B800;
      apoint : Word = 0;
      { foreground and background colors }
      Black        = 0;
      Blue         = 1;
      Green        = 2;
      Cyan         = 3;
      Red          = 4;
      Magenta      = 5;
      Brown        = 6;
      LightGray    = 7;

      { foreground colors }
      DarkGray     = 8;
      LightBlue    = 9;
      LightGreen   = 10;
      LightCyan    = 11;
      LightRed     = 12;
      LightMagenta = 13;
      Yellow       = 14;
      White        = 15;

      { add for blinking characters }
      Blink        = 128;

VAR
        regs : Registers;

Function GetMode : Byte;
{returns the current video mode}

Procedure SetMode (m : Byte);
{sets the video mode}

Procedure Scroll (ur, lc, lr, rc : Byte; nbr : ShortInt);
{scrolls the window up (nbr is +) or down (nbr is -)}
{If nbr is 0 or out of range then the screen clears}
{ur is the upper row, lc is the left column,
 lr is the lower row, and rc is the right column}
{Note:  using an out-of-range number may have unpredictable
 results on the colors...it is not recommended}

Procedure SetCursor (s, e : Byte);
{sets the size of the cursor}
{s is the starting line, e is the ending line}

Procedure SetAPage (page : Word);
{Set the Active (drawing) page}

Procedure SetVPage (vpage : Byte);
{Set the display page}

Function DisplayCursor (display1 : Boolean) : Boolean;
{hides or displays the cursor}

Function Xis : Byte;
{Tells you what the X coordinate is for the current active page}

Function Yis : Byte;
{Tells you what the Y coordinate is for the current active page}

Procedure PXY (x, y : Byte);
{sets the coordinates on the current active page}
{To move the cursor on the visual page, first make the visual page
 and active page the same}
{x is the row, y is the column}

Procedure SetFGround (FG : Byte);
{sets the foreground color}
{constants can be used}
{add 128 or the constant BLINK to make the foreground blink}

Procedure SetBGround (BG : Byte);
{sets the background color}
{constants can be used}

Procedure PWrite (S : String);
{writes a string to the current active page}
{numbers must be converted to a string before calling this procedure}

Procedure PWriteln (S : String);

Procedure ClrScrn;
{Clear the current active page}

implementation

Function GetMode : Byte;
{returns the current video mode}
Begin
     regs.ah := $0F;
     Intr($10,regs);
     GetMode := regs.al;
End;

Procedure SetMode (m : Byte);
{sets the video mode}
Begin
     regs.ah := 0;
     regs.al := m;
     Intr($10,regs);
End;

Procedure Scroll (ur, lc, lr, rc : Byte; nbr : ShortInt);
{scrolls the window up (nbr is +) or down (nbr is -)}
{If nbr is 0 or out of range then the screen clears}
Begin
        Dec(ur);
        Dec(lc);
        Dec(lr);
        Dec(rc);
        If nbr < 0 Then regs.ah := 7 Else regs.ah := 6;
        regs.al := Abs(nbr);
        regs.bh := attribute;
        regs.ch := ur;
        regs.cl := lc;
        regs.dh := lr;
        regs.dl := rc;
        Intr($10,regs);
End;

Procedure SetCursor (s, e : Byte);
Begin
        regs.ah := 1;
        regs.ch := s;
        regs.cl := e;
        Intr($10,regs);
End;

Procedure SetAPage (page : Word);
Begin
        apage := $B800 + (page * $100);
End;

Procedure SetVPage (vpage : Byte);
Begin
        regs.ah := 5;
        regs.al := vpage;
        Intr($10,regs);
End;

Function DisplayCursor(display1 : Boolean) : Boolean;
Begin
        If Not(display1) Then Begin
           regs.dh := 50;
           regs.dl := 0;
           End
        Else regs.dx := apoint;
        regs.ah := 2;
        regs.bh := (apage - $B800) DIV $100;
        Intr($10,regs);
        display := display1;
End;

Function Xis : Byte;
Var        cpage : Word;
Begin
        cpage := (apage - $B800) DIV $100;
        Xis := (Mem[$40:$51+(cpage * 2)]) + 1;
End;

Function Yis : Byte;
Var        cpage : Word;
Begin
        cpage := (apage - $B800) DIV $100;
        Yis := (Mem[$40:$50+(cpage * 2)]) + 1;
End;


Procedure PXY (x, y : Byte);
Begin
        Dec(x);
        Dec(y);
        regs.dh := x;
        regs.dl := y;
        regs.ah := 2;
        regs.bh := (apage - $B800) DIV $100;
        Intr($10,regs);
        If Not(display) Then Begin
           regs.dh := 50;
           regs.dl := 0;
        regs.ah := 2;
        regs.bh := (apage - $B800) DIV $100;
        Intr($10,regs);
        End;
        apoint := x * 80 * 2 + y * 2;
End;

Procedure SetFGround (FG : Byte);
Begin
        FGround := FG;
        attribute := BGround * 16 + FGround;
End;

Procedure SetBGround (BG : Byte);
Begin
        BGround := BG;
        attribute := BGround * 16 + FGround;
End;

Procedure PWrite (S : String);
Var
        Len, x, y : Byte;
        tmp : Word;
Begin
        If Length(S) = 0 Then Exit;
        tmp := apoint;
        For Len := 0 To Length(S) - 1 Do Begin
            Mem[apage:apoint+Len] := Ord(S[Len+1]);
            Inc(apoint);
            Mem[apage:apoint+Len] := attribute;
        End;
        apoint := (tmp + Length(S) * 2) DIV 2;
        y := apoint MOD 80;
        x := apoint DIV 80;
        Inc(x);
        Inc(y);
        PXY(x,y);
        If Not(display) Then Begin
           regs.dh := 50;
           regs.dl := 0;
        regs.ah := 2;
        regs.bh := (apage - $B800) DIV $100;
        Intr($10,regs);
        End;
End;

Procedure PWriteln (S : String);
Var
        Len, x, y : Byte;
        tmp : Word;
Begin
        If Length(S) = 0 Then Exit;
        tmp := apoint;
        For Len := 0 To Length(S) - 1 Do Begin
            Mem[apage:apoint+Len] := Ord(S[Len+1]);
            Inc(apoint);
            Mem[apage:apoint+Len] := attribute;
        End;
        apoint := (tmp + Length(S) * 2) DIV 2;
        x := apoint DIV 80 + 2;
        y := 1;
        PXY(x,y);
        If Not(display) Then Begin
           regs.dh := 50;
           regs.dl := 0;
        regs.ah := 2;
        regs.bh := (apage - $B800) DIV $100;
        Intr($10,regs);
        End;
End;

Procedure ClrScrn;
Var
        x : Word;
Begin
        x := 0;
        While x < 4048 Do Begin
          Mem[apage:x] := $20;
          Inc(x);
          Mem[apage:x] := attribute;
          Inc(x);
          End;
End;

{initializes the foreground and backbround colors}
Begin
        regs.ah := 8;
        regs.bh := 0;
        Intr($10,regs);
        attribute := regs.ah;
        FGround := attribute MOD 16;
        BGround := (attribute - FGround) DIV 16;
End.

