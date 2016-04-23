Unit Rodent;
Interface
Uses Dos;

const MDD = $33;   { mouse interupt }
                   { Interupt driven        Polled       = AX  }
      bit_0 = $01; { mouse movement         left button down   }
      bit_1 = $02; { left button pressed    right button down  }
      bit_2 = $04; { left button released   center button down }
      bit_3 = $08; { right button pressed }
      bit_4 = $10; { right button released }
      bit_5 = $20; { center pressed }
      bit_6 = $40; { center released }
      bit_7 = $80;

type
  resetRec = record
    exists   : Boolean;
    nButtons : Integer;
  end;
  LocRec = record
    buttonStatus,
    opCount,
    column,
    row       : Integer;
  end;
  moveRec = record
    hCount,
    vCount    : Integer;
  end;
{$F+}
  eventRec = record
               flag, button, col, row: Word;
             end;
{$F-}

var mReg     : Registers;
    theMouse : resetRec;     { Does mouse exist }
    mrecord  : locRec;       { polled record    }
    mEvent   : eventRec;     { interupt record  }

procedure mFixXY (x1,y1,x2,y2:integer);
function mouseX (n:integer) : integer;
function mouseY (n:integer) : integer;
procedure mReset (VAR Mouse: resetRec);                                {  0 }
procedure mShow;                                                       {  1 }
procedure mHide;                                                       {  2 }
procedure mPos (VAR Mouse: LocRec);                                    {  3 }
procedure mMoveto (col, row: Integer);                                 {  4 }
procedure mPressed (button: Integer; VAR Mouse: LocRec);               {  5 }
procedure mReleased (button: Integer; VAR Mouse: LocRec);              {  6 }
procedure mColRange (min, max : Integer);                              {  7 }
procedure mRowRange (min, max : Integer);                              {  8 }
procedure mGraphCursor (hHot, vHot: Integer; maskSeg, maskOfs: Word);  {  9 }
procedure mTextCursor (ctype, p1, p2: Word);                           { 10 }
procedure mMotion (VAR moved: moveRec);                                { 11 }
procedure mInstTask (mask: Word);                                      { 12 }
procedure mLpenOn;                                                     { 13 }
procedure mLpenOff;                                                    { 14 }
procedure mRatio (horiz, vert: Integer);                               { 15 }

implementation
var
  maxcol   : word absolute $0040:$004A;   { x }

procedure EventHandler(Flags,CS,AX,BX,CX,DX,SI,DI,DS,ES,BP: Word);
interrupt;
begin
  mEvent.flag   := AX;
  mEvent.button := BX;
  mEvent.col    := CX;
  mEvent.row    := DX;
  inLine($8B/$E5/$5D/$07/$1F/$5F/$5E/$5A/$59/$5B/$58/$CB);
end;

function Lower (n1, n2: Integer): Integer;
  begin
    if n1 < n2 then Lower := n1 else Lower := n2;
  end;

function Upper (n1, n2: Integer): Integer;
  begin
    if n1 > n2 then Upper := n1 else Upper := n2;
  end;

procedure mFixXY;
  var i : integer;
  begin
    if maxcol = 80
    then i := 3
    else i := 4;
    mColRange(pred(x1) shl i,pred(x2) shl i);
    mRowRange(pred(y1) shl 3,pred(y2) shl 3);
  end;

function mouseX;
  var i : integer;
  begin
    if maxcol = 80
    then i := 3
    else i := 4;
    mouseX := succ(n shr i);
  end;

function mouseY;
  begin
    mouseY := succ(n shr 3);
  end;

procedure mReset (VAR Mouse: resetRec);
  begin
    mreg.ax := 0;
    intr(MDD, mreg);
    Mouse.exists := boolean(mreg.ax <> 0);
    Mouse.nButtons := mreg.bx;
  end;

procedure mShow;
  begin
    inline($B8/$01/$00/$CD/MDD);
{    mreg.ax := 1;    }
{    intr(MDD, mreg); }
  end;

procedure mHide;
  begin
    inline($B8/$02/$00/$CD/MDD);
{    mreg.ax := 2;    }
{    intr(MDD, mreg); }
  end;

procedure mPos (VAR Mouse: LocRec);
  begin
    mreg.ax := 3;
    intr(MDD, mreg);
    Mouse.buttonStatus := mreg.bx;
    Mouse.column := mreg.cx;
    Mouse.row := mreg.dx;
  end;

procedure mMoveto (col, row: Integer);
  var i : word;
  begin
    if maxcol = 80
    then i := 3
    else i := 4;
    mreg.ax := 4;
    mreg.cx := col shl i;
    mreg.dx := row shl i;;
    intr(MDD, mreg);
  end;

procedure mPressed (button: Integer; VAR Mouse: LocRec);
  begin
    mreg.ax := 5;
    mreg.bx := button;
    intr(MDD, mreg);
    Mouse.buttonStatus := mreg.ax;
    Mouse.opCount := mreg.bx;
    Mouse.column := mreg.cx;
    Mouse.row := mreg.dx;
  end;

procedure mReleased (button: Integer; VAR Mouse: LocRec);
  begin
    mreg.ax := 6;
    mreg.bx := button;
    intr(MDD, mreg);
    Mouse.buttonStatus := mreg.ax;
    Mouse.opCount := mreg.bx;
    Mouse.column := mreg.cx;
    Mouse.row := mreg.dx;
  end;

procedure mColRange (min, max : Integer);
  begin
    mreg.ax := 7;
    mreg.cx := Lower(min, max);
    mreg.dx := Upper(min, max);
    intr(MDD, mreg);
  end;

procedure mRowRange (min, max : Integer);
  begin
    mreg.ax := 8;
    mreg.cx := Lower (min, max);
    mreg.dx := Upper (min, max);
    intr(MDD, mreg);
  end;

procedure mGraphCursor (hHot, vHot: Integer; maskSeg, maskOfs: Word);
  begin
    mreg.ax := 9;
    mreg.bx := hHot;
    mreg.cx := vHot;
    mreg.dx := maskOfs;
    mreg.es := maskSeg;
    intr(MDD, mreg);
  end;

procedure mTextCursor (ctype, p1, p2: Word);
  begin
    mreg.ax := 10;
    mreg.bx := ctype;       { 0=software, 1=hardware          }
    mreg.cx := p1;          { 0=and mask else start line      }
    mreg.dx := p2;          { 0=xor mask else Cursor end line }
    intr(MDD, mreg);
  end;

{ Returns mouse displacement in mickeys since last call }
procedure mMotion (VAR moved: moveRec);
  begin
    mreg.ax := 11;
    intr(MDD, mreg);
    moved.hCount := mreg.cx;
    moved.vCount := mreg.dx;
  end;

procedure mInstTask;
  begin
    mreg.ax := 12;
    mreg.cx := mask;         { see bit constants above }
    mreg.dx := Ofs(EventHandler);
    mreg.es := Seg(EventHandler);
    intr(MDD, mreg);
  end;

procedure mLpenOn;
  begin
    mreg.ax := 13;
    intr(MDD, mreg);
  end;

procedure mLpenOff;
  begin
    mreg.ax := 14;
    intr(MDD, mreg);
  end;

procedure mRatio (horiz, vert: Integer);
  begin
    mreg.ax := 15;
    mreg.cx := horiz;
    mreg.dx := vert;
    intr(MDD, mreg);
  end;

{ Sample base line program...
  mReset(theMouse);
  if theMouse.exists
  then minstTask(15);      (* for 80x25 *)
  mFixXY(1,1,succ(lo(windmax)),succ(hi(windmax)));
  mEvent.Flag := 0;
<< do the program >>
  mReset(theMouse);
}
END.

