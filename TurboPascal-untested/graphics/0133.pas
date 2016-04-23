
{ Illustration on how VGA Write Mode 1 works }
{ by Andrew Golovin (2:5080/10@Fidonet)      }
{ Can be used at your own risk freely w/o    }
{ any charge                                 }
{============================================}
{ PREFACE:                                   }
{ This example illustrate posibility to save }
{ Bitmaps in unused VRam. And use VWM1 to    }
{ restore it by 4 pixels at one byte         }
{ Use arrows to move "bitmap" on screen.     }
{ This example _only_ illustrate this mode   }
{ Extremly needs optimization! Don't use it  }
{ as is. Just an idea.                       }

Uses CRT;
var
  OldMode: Byte;

procedure SetWriteMode(Wmode: Byte); assembler;
asm
  Mov     DX,3ceh
  Mov     AL,5
  Out     DX,AL
  Inc     DX
  In      AL,DX
  And     AL,11111100b
  Or      AL,WMode
  Out     DX,AL
end;

procedure Init320x200_X; assembler;
asm
  Mov AH,0fh; Int 10h; Mov [OldMode],al; Mov AX,13h; Int 10h;
  Mov DX,3c4h; Mov AL,04h; Out DX,AL; Inc DX; In AL,DX; And AL,011110111b;
  Or AL,000000100b; Out DX,AL; Dec DX; Mov AX,0f02h; Out DX,AX;
  Mov AX,0a000h; Mov ES,AX; XOr DI,DI; Mov AX,0202h; Mov CX,8000h;
  ClD; RepNZ StoSW; Mov DX,3d4h; Mov AL,14h; Out DX,AL; Inc DX;
  In AL,DX; And AL,010111111b; Out DX,AL; Dec DX; Mov AL,017h;
  Out DX,AL; Inc DX; In AL,DX; Or AL,01000000b; Out DX,AL; Mov DX,3d4h;
  Mov AX,80; ShR AX,1; Mov AH,AL; Mov AL,13h; Out DX,AX; Ret
end;

Procedure PutPixel(x,y: Word; c: Byte);
  begin
    asm
      Mov    DX,3c4h
      Mov    AL,02
      Out    DX,AL
      Mov    AX,Y
      ShL    AX,4
      Mov    DI,AX
      ShL    AX,2
      Add    DI,AX
      Mov    AX,X
      ShR    AX,2
      Add    DI,AX
      Mov    AX,X
      And    AX,3
      Mov    CL,AL
      Mov    AL,1
      ShL    AL,CL
      Inc    DX
      Out    DX,AL
      Mov    AX,0a000h
      Mov    ES,AX
      Mov    AL,C
      StoSB
    end;
  end;

procedure MaskBits(BitsToMask: Byte); assembler;
  asm
    Mov     DX,3ceh
    Mov     AL,8
    Mov     AH,BitsToMask
    Out     DX,AX
  end;

Procedure MaskPlanes(PlaneToMask: Byte); assembler;
asm
  Mov     DX,3c4h
  Mov     AL,2
  Out     DX,AL
  Inc     DX
  Mov     AL,PlaneToMask
  Out     DX,AL
End;

Procedure StoreBack(x,y,w,h: word; toAddr: word);
  var
    curx,cury: Word;
  begin
    SetWriteMode(1);
    MaskPlanes($f);
    MaskBits($ff);
    For CurY:=Y to Y+H do
      Move(Mem[$a000:CurY*80+x],Mem[$a000:toAddr+(CurY-Y)*W],w);
    SetWriteMode(0);
  end;

Procedure RestoreBack(x,y,w,h: word; fromAddr: Word);
  var
    cury,curx: Word;
  begin
    SetWriteMode(1);
    MaskPlanes($f);
    MaskBits($ff);
    For CurY:=Y to Y+H do
      Move(Mem[$a000:fromAddr+(CurY-Y)*W],Mem[$a000:CurY*80+x],w);
    SetWriteMode(0);
  end;

var
  x,y: Word;
  curx,cury: Word;
  c: Char;
Begin
  Init320x200_x;
  For x:=0 to 319 do
    For y:=0 to 199 do
      PutPixel(x,y,(x +y) mod 16+16);
  StoreBack(0,0,3,12,16000);
  For x:=0 to 11 do
    For y:=0 to 11 do
      PutPixel(x,y,Random(255));
  StoreBack(0,0,3,12,16200);
  CurX:=0;CurY:=0;
  Repeat
    Repeat Until KeyPressed;
    c:=ReadKey;
    If c=#0
       then
         begin
           RestoreBack(CurX,CurY,3,12,16000);
           c:=ReadKey;
           Case c of
             #80: If CurY<187
                     then
                       Inc(CurY);
             #72: If CurY>0
                     Then
                       Dec(CurY);
             #75: If CurX>0
                     Then
                       Dec(CurX);
             #77: If CurX<77
                     Then
                       Inc(CurX);
           end;
           StoreBack(CurX,CurY,3,12,16000);
           RestoreBack(CurX,CurY,3,12,16200);
         end;
  Until c=#27;
  asm Mov al,OldMode; XOr AH,AH; Int 10h end;
End.

