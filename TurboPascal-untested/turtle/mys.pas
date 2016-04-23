(* ┌───────────────────────────────────────────────────────────┐
   │ Programated by Vladimir Zahoransky                        │
   │                Vladko software                            │
   │ Contact      : zahoran@cezap.ii.fmph.uniba.sk             │
   │ Program tema : Unit - Standard turtle mouse commands      │
   └───────────────────────────────────────────────────────────┘ *)

{    This is turtle mouse unit. This unit is for turtle graphic.
  It is defined in assembler. All who want to have your commands
  it this unit then make descendent of mouse object. This object
  is dynamical. (in this version over polymorphism) Here is
  clipboard of mousecursor type.

  Translator :

   InicMyc  = Init
   UkazMys  = Show
   SkryMys  = Hide
   Stavmysi = GetMouseButton
   MysX     = GetMouseX
   MysY     = GetMouseY
   ZmenKurzorMysi = ChangeCursor
}

unit OKorMys;

interface

Uses Dos;

Type TMouse_Cursor=Record
                   x,y:byte;
                   k:Array[1..32] of word
                   End;

    Mouse_Inf = Record
                BaudRate   :WORD;
                Emulation  :WORD;
                ReportRate :WORD;
                FirmRev    :WORD;
                ZeroWord   :WORD;
                PortLoc    :WORD;
                PhysButtons:WORD;
                LogButtons :WORD;
                End;

    PMouse=^Mouse;
      Mouse=Object
            Function  Init:boolean;
            Function  GetMouseButton:byte;
            Procedure Show;
            Procedure Hide;
            Procedure ChangeCursor(k:TMouse_Cursor);
            Procedure GetMouseInf(Var M_info);
            Function  GetMouseX:integer;
            Function  GetMouseY:integer;
            Procedure SetMouseX(x1:integer);
            Procedure SetMouseY(y1:integer);
            End;

Const

  Cursor_Sipka:TMouse_Cursor=
   (x:1; y:1;
    k:($3fff,$1fff,$0fff,$07ff,$03ff,$01ff,$00ff,$007f,
       $003f,$01ff,$30ff,$70ff,$f87f,$f87f,$fc3f,$fc7f,
       $0000,$4000,$6000,$5000,$4800,$5400,$5a00,$5900,
       $4c00,$4c00,$0600,$0600,$0300,$0300,$0180,$0000));

  Cursor_Hand:TMouse_Cursor=
   (x:3; y:0;
    k:($efff,$c7ff,$c7ff,$c7ff,$c2bf,$c01f,$801f,$001f,
       $001f,$001f,$001f,$001f,$001f,$801f,$c03f,$e03f,
       $0000,$1000,$1000,$1000,$1000,$1540,$1540,$5540,
       $5540,$5fc0,$5fc0,$7fc0,$7fc0,$3fc0,$1f80,$0000));

  Cursor_Palm:TMouse_Cursor =
  (x:8;y:8;
   k:($FF7F,$FC1F,$F807,$F803,$F803,$F803,$9801,$0801,
      $0001,$8001,$C001,$E003,$F007,$F80F,$FC0F,$FC0F,
      $0080,$0360,$0558,$0554,$0554,$0554,$6416,$9402,
      $8C02,$4402,$2006,$1004,$0808,$0410,$0210,$03F0));

  Cursor_Cross:TMouse_Cursor=
   (x:7; y:7;
    k:($ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,
       $ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,
       $0100,$0100,$0100,$0100,$0100,$0100,$0100,$fefe,
       $0100,$0100,$0100,$0100,$0100,$0100,$0100,$0000));

  Cursor_Diskette : TMouse_Cursor =
   (x:4; y:4;
      k:($0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,
         $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,
         $0000,32766,32766,32760,32760,32766,32382,31806,
         31806,32382,32766,32382,32382,32382,32766,$0000));

  Cursor_face:TMouse_Cursor =
   (x:7;y:8;
    k:( $C003,$8001,$07E0,$0000,$0000,$0000,$0000,$0000,
        $0000,$0000,$0000,$8001,$C003,$C003,$E007,$F81F,
        $0FF0,$1008,$2004,$4002,$4E72,$4A52,$4E72,$4002,
        $4992,$581A,$2424,$13C8,$1008,$0C30,$03C0,$0000));

  Cursor_text: TMouse_Cursor =
    (x:7;y:7;
    k:( $E10F,$E00F,$F01F,$FC7F,$FC7F,$FC7F,$FC7F,$FC7F,
        $FC7F,$FC7F,$FC7F,$FC7F,$F01F,$E00F,$E10F,$FFFF,
        $0000,$0C60,$0280,$0100,$0100,$0100,$0100,$0100,
        $0100,$0100,$0100,$0100,$0280,$0C60,$0000,$0000));

  Cursor_check: TMouse_Cursor =
    (x:5;y:10;
    k:($FFF0,$FFE0,$FFC0,$FF81,$FF03,$0607,$000F,$001F,
       $803F,$C07F,$E0FF,$F1FF,$FFFF,$FFFF,$FFFF,$FFFF,
       $0000,$0006,$000C,$0018,$0030,$0060,$70C0,$3980,
       $1F00,$0E00,$0400,$0000,$0000,$0000,$0000,$0000));

  Kursor_roll: TMouse_Cursor =
   (x:7;y:3;
    k:($8003,$0001,$0001,$1831,$1011,$0001,$0001,$8003,
       $F83F,$F83F,$F83F,$F83F,$F83F,$F83F,$F83F,$F83F,
       $0000,$3FF8,$4284,$4104,$4284,$4444,$3FF8,$0380,
       $0380,$0380,$0380,$0380,$0380,$0380,$0380,$0000));

  Cursor_watch: TMouse_Cursor =
    (x:8;y:8;
    k:($ffff,$c003,$8001,$0000,$0000,$0000,$0000,$0000,
       $0000,$0000,$0000,$0000,$0000,$8001,$c003,$ffff,
       $0000,$0000,$1ff8,$2004,$4992,$4022,$4042,$518a,
       $4782,$4002,$4992,$4002,$2004,$1ff8,$0000,$0000));

  Cursor_clock: TMouse_Cursor =
    (x:8;y:7;
    k:($0000,$0000,$0000,$0000,$8001,$C003,$E007,$F00F,
       $E007,$C003,$8001,$0000,$0000,$0000,$0000,$FFFF,
       $0000,$7FFE,$67E6,$33CC,$1998,$0C30,$0660,$03C0,
       $0660,$0C30,$1818,$300C,$6006,$7FFE,$0000,$0000));

implementation

var regs:registers;

function Mouse.Init:boolean;
Begin
asm
        xor        ax,ax
        int        $33
        not        ax
        xor        ax,1
        and        ax,1
End;
End;

function Mouse.GetMouseButton:byte;
Var Mb:0..7;
begin
  regs.AX:=3; Intr($33,regs);
  if regs.BX and 1 <> 0 Then Mb:=1 Else
  if regs.BX and 2 <> 0 Then Mb:=2 Else
  if regs.BX and 3 <> 0 Then Mb:=3 Else
  if regs.BX and 4 <> 0 Then Mb:=4 Else
  if regs.BX and 5 <> 0 Then Mb:=5 Else
  if regs.BX and 6 <> 0 Then Mb:=6 Else
  if regs.BX and 7 <> 0 Then Mb:=7 Else
  Mb:=0;
  GetMouseButton:=Mb;
end;

Procedure Mouse.Show;Assembler;
Asm
  Mov AX,1;
  Int $33;
End;

Procedure Mouse.Hide;Assembler;
Asm
  Mov AX,2;
  Int $33;
End;

procedure Mouse.ChangeCursor(k:TMouse_Cursor);
Begin
  regs.AX:=9;
  regs.BX:=k.x;
  regs.CX:=k.y;
  regs.ES:=Seg(k.k);
  regs.DX:=Ofs(k.k);
  Intr($33,regs);
End;

Procedure Mouse.GetMouseInf(Var M_info);Assembler;
Asm
  Push AX
  Push ES
  Push DX
  Mov AX,$246C
  LES DX,M_info
  Int $33
  Pop DX
  Pop ES
  Pop AX
End;

Function Mouse.GetMouseX : Integer;
Var x:integer;
Begin
Asm
  Mov Ax, 3
  Int 33h
  Mov x, cx
End;
GetMouseX:=x;
End;

Function Mouse.GetMouseY : Integer;
Var y:integer;
Begin
Asm
  Mov Ax, 3
  Int 33h
  Mov y, dx
End;
GetMouseY:=y;
End;

Procedure Mouse.SetMouseX(x1:Integer);Assembler;
Asm
  Mov Ax, 4
  Mov Cx, x1
  Int 33h
End;

Procedure Mouse.SetMouseY(y1:Integer);Assembler;
Asm
  Mov Ax, 4
  Mov Dx, y1
  Int 33h
End;

End.
