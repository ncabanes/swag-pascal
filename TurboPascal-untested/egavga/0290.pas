{$A+,G+,R-,S-}
UNIT MCGA;   { Copyright by Stefan Ohrhallinger in 1991,92,93,94 }
             { aka »The Faker« of AARDVARK }
INTERFACE
CONST
     Up=0;
     Right=1;
     Down=2;
     Left=3;

PROCEDURE SetPixel(X,Y:Word; C:Byte);
FUNCTION GetPixel(X,Y:Word):Byte;
PROCEDURE DrawLineH(X1,X2,Y1:Word; C:Byte);
PROCEDURE DrawLineV(X1,Y1,Y2:Word; C:Byte);
PROCEDURE DrawLine(X1,Y1,X2,Y2:Integer; C:Byte);
PROCEDURE SetColor(Nr,R,G,B:Byte);
PROCEDURE GetColor(Nr:Byte; VAR R,G,B:Byte);
FUNCTION PaintChar(Ch,X,Y:Integer; C:Byte):Boolean;
PROCEDURE GrWrite(X,Y:Integer; C:Byte; S:String);
PROCEDURE LoadFont(Nr:Byte; Name:String);
PROCEDURE SetText(Nr:Byte; MultX,DivX,MultY,DivY:Byte);
PROCEDURE DrawPolygon(Count:Integer; VAR P; C:Byte);
PROCEDURE Fill(X,Y:Integer; C:Byte);  { Nur die selbe Farbe ersetzen }
PROCEDURE Flood(X,Y:Integer; C,C2:Byte);  { Anfärben bis zur Randfarbe C2 }
PROCEDURE MCGAOn;
PROCEDURE MCGAOff;
PROCEDURE FillPolygon(Size:Integer; VAR P1; C:Byte);
PROCEDURE Ellipse(MX,MY,A,B:Integer; C:Byte);
PROCEDURE FillEllipse(MX,MY,A,B:Integer; C:Byte);
PROCEDURE Circle(X,Y,R:Integer; C:Byte);
PROCEDURE FillCircle(X,Y,R:Integer; C:Byte);
PROCEDURE RotateArray(VAR P; Count,MX,MY:Integer; Winkel:Real);
PROCEDURE N4eck(N,X,Y,R1,R2:Integer; C:Byte);
PROCEDURE Neck(N,X,Y,A,B:Integer; Drehen:Real);
PROCEDURE DrawRing(X,Y,R1,R2:Integer; C:Byte);
PROCEDURE FillRing(X,Y,R1,R2:Integer; C:Byte);
PROCEDURE SetFrameColor(C:Byte);
PROCEDURE RecTangle(X1,Y1,X2,Y2:Integer; C:Byte);
PROCEDURE GetImage(X1,Y1,X2,Y2:Integer; VAR P);
PROCEDURE PutImage(X1,Y1:Integer; VAR P);
PROCEDURE PutImagePart(X1,Y1,XS2,YS2:Integer; VAR P);
PROCEDURE FillBlock(X1,Y1,X2,Y2:Integer; C:Byte);
PROCEDURE ScrollLeft(X1,Y1,X2,Y2:Word);
PROCEDURE ScrollRight(X1,Y1,X2,Y2:Word);
PROCEDURE ScrollUp(X1,Y1,X2,Y2:Word);
PROCEDURE ScrollDown(X1,Y1,X2,Y2:Word);
PROCEDURE Scroll(Direction:Byte; X1,Y1,X2,Y2:Word);
PROCEDURE SwitchOff;
PROCEDURE SwitchOn;
PROCEDURE LoadPalette(DateiName:String);
PROCEDURE SavePalette(DateiName:String);
PROCEDURE LoadScreen(DateiName:String);
PROCEDURE SaveScreen(DateiName:String);
PROCEDURE BCircle(X,Y,R:Integer; C:Byte);
PROCEDURE BFillCircle(X,Y,R:Integer; C:Byte);
PROCEDURE Split(Row:Integer);
PROCEDURE ScrollText(Nr:Word);
PROCEDURE SetStart(S:Word);
PROCEDURE VerticalRetrace;
PROCEDURE WaitScreen;
PROCEDURE WaitRetrace;
PROCEDURE SetOffset(B:Byte);
PROCEDURE LoadSprite(DateiName:String; VAR P);
PROCEDURE SaveSprite(DateiName:String; VAR P);
FUNCTION SpriteXSize(Sprite:Pointer):Word;
FUNCTION SpriteYSize(Sprite:Pointer):Word;
FUNCTION SpriteSize(Sprite:Pointer):Word;
PROCEDURE FillScreen(C:Byte);
PROCEDURE SetChain4;
PROCEDURE ClearChain4;
PROCEDURE CharHeight(B:Byte);
PROCEDURE Wait4Line;
PROCEDURE CLI;
PROCEDURE STI;
PROCEDURE PutImage4(X1,Y1:Integer; VAR P);
PROCEDURE SetWriteMap(Map:Byte);
PROCEDURE SetWriteMode(M:Byte);
PROCEDURE Unchain;
PROCEDURE Rechain;
PROCEDURE ClearScreen;
PROCEDURE SetModeNr(Nr:Word);
PROCEDURE Set16Pal(Nr:Byte);
PROCEDURE Init16Pal;
PROCEDURE SetLineRepeat(Nr:Byte);
PROCEDURE TextMode;
PROCEDURE Init13X;
PROCEDURE SetReadMap(Map:Byte);
PROCEDURE DrawLineH4(X1,X2,Y1:Word; C:Byte);
PROCEDURE DrawLineV4(X1,Y1,Y2:Word; C:Byte);
PROCEDURE SetHorizOfs(Count:Byte);

{
PROCEDURE SetModeReg(Reg:String);
PROCEDURE SetDoubleLines(Ok:Boolean);
PROCEDURE SetPal(VAR A);
PROCEDURE ReducePal(VAR A);
}

IMPLEMENTATION
CONST
     MaxFont=4;
     FontName:ARRAY[1..MaxFont] OF String[4]=('TRIP','LITT','SANS','GOTH');
     VekMax=100;
     X_zu_Y=0.69;
TYPE
    FontType=RECORD
                   FBuf:ARRAY[0..16000] OF Byte;
                   WPtr:^Word;
                   DataOffs,MinChar,TBStart,TblSize,WidthTbl,VecStart,CUp,CDown:Integer;
                   GLine,Index,CharWidth:Integer;
             END;
VAR
   Font:ARRAY[1..4] OF ^FontType;
   FontNr,MX,DX,MY,DY:Byte;
   CurrMode,OldMode:Byte;

PROCEDURE SetPixel(X,Y:Word; C:Byte);
BEGIN
     ASM
        mov ax,$a000
        mov es,ax
        mov bx,x
        mov dx,y
        xchg dh,dl
        mov al,c
        mov di,dx
        shr di,1
        shr di,1
        add di,dx
        add di,bx
        stosb
     END;
END;

FUNCTION GetPixel(X,Y:Word):Byte;
BEGIN
     ASM
        mov ax,$a000
        mov es,ax
        mov bx,x
        mov dx,y
        mov di,dx
        shl di,1
        shl di,1
        add di,dx
        mov cl,6
        shl di,cl
        add di,bx
        mov al,es:[di]
        mov [bp-1],al
     END;
END;

PROCEDURE DrawLineH(X1,X2,Y1:Word; C:Byte);
BEGIN
     ASM
        mov ax,$a000
        mov es,ax
        mov ax,y1
        mov di,ax
        shl di,1
        shl di,1
        add di,ax
        mov cl,6
        shl di,cl
        mov bx,x1
        mov dx,x2
        cmp bx,dx
        jl @1
        xchg bx,dx
@1:     inc dx
        add di,bx
        mov cx,dx
        sub cx,bx
        shr cx,1
        mov al,c
        mov ah,al
        ror bx,1
        jnb @2
        stosb
        ror dx,1
        jnb @3
        dec cx
@3:     rol dx,1
@2:     rep
        stosw
        ror dx,1
        jnb @4
        stosb
@4:
     END;
END;

PROCEDURE DrawLineV(X1,Y1,Y2:Word; C:Byte);
BEGIN
     ASM
        mov ax,x1
        mov bx,y1
        mov dx,y2
        cmp bx,dx
        jl @1
        xchg bx,dx
@1:     mov di,bx
        shl di,1
        shl di,1
        add di,bx
        mov cl,6
        shl di,cl
        add di,ax
        mov cx,$a000
        mov es,cx
        mov cx,dx
        sub cx,bx
        inc cx
        mov al,c
        mov bx,$13f
@2:     stosb
        add di,bx
        loop @2
     END;
END;

PROCEDURE DrawLine(X1,Y1,X2,Y2:Integer; C:Byte);
BEGIN
     ASM
        mov al,c
        xor ah,ah
        mov si,ax
        mov ax,x1
        cmp ax,319
        ja @Ende
        mov bx,x2
        cmp bx,319
        ja @Ende
        mov cx,y1
        cmp cx,199
        ja @Ende
        mov dx,y2
        cmp dx,199
        ja @Ende
        cmp ax,bx
        jnz @weiter
        cmp cx,dx
        jnz @vertical
        push ax
        push cx
        push si
        call setpixel
        jmp @ende
@weiter:cmp cx,dx
        jnz @weiter2
        push ax
        push bx
        push cx
        push si
        call drawlineh
        jmp @ende
@vertical:push ax
        push cx
        push dx
        push si
        call drawlinev
        jmp @ende
@weiter2:cmp cx,dx
        jbe @1
        xchg cx,dx
        xchg ax,bx
@1:     mov di,cx
        shl di,1
        shl di,1
        add di,cx
        push si
        mov si,bx
        mov bx,dx
        sub bx,cx
        mov cl,06
        shl di,cl
        add di,ax
        mov dx,si
        pop si
        sub dx,ax
        mov ax,$a000
        mov es,ax
        mov ax,si
        push bp
        or dx,0
        jge @jmp1
        neg dx
        cmp dx,bx
        jbe @jmp3
        mov cx,dx
        inc cx
        mov si,dx
        shr si,1
        std
        mov bp,320
@1c:    stosb
@1b:    or si,si
        jge @1a
        add di,bp
        add si,dx
        jmp @1b
@1a:    sub si,bx
        loop @1c
        jmp @Ende2
@jmp3:  mov cx,bx
        inc cx
        mov si,bx
        neg si
        sar si,1
        cld
        mov bp,319
@2c:    stosb
@2b:    or si,si
        jl @2a
        sub si,bx
        dec di
        jmp @2b
@2a:    add di,bp
        add si,dx
        loop @2c
        jmp @Ende2
@jmp1:  cmp dx,bx
        jbe @jmp4
        mov cx,dx
        inc cx
        mov si,dx
        shr si,1
        cld
        mov bp,320
@3c:    stosb
@3b:    or si,si
        jge @3a
        add di,bp
        add si,dx
        jmp @3b
@3a:    sub si,bx
        loop @3c
        jmp @Ende2
@jmp4:  mov cx,bx
        inc cx
        mov si,bx
        neg si
        sar si,1
        std
        mov bp,321
@4c:    stosb
@4b:    or si,si
        jl @4a
        sub si,bx
        inc di
        jmp @4b
@4a:    add di,bp
        add si,dx
        loop @4c
@Ende2: pop bp
        cld
@Ende:
     END;
END;

PROCEDURE SetColor(Nr,R,G,B:Byte);
BEGIN
     Port[$3C8]:=Nr;
     Port[$3C9]:=R;
     Port[$3C9]:=G;
     Port[$3C9]:=B;
END;

PROCEDURE GetColor(Nr:Byte; VAR R,G,B:Byte);
BEGIN
     Port[$3C7]:=Nr;
     R:=Port[$3C9];
     G:=Port[$3C9];
     B:=Port[$3C9];
END;

FUNCTION PaintChar(Ch,X,Y:Integer; C:Byte):Boolean;
VAR
   XVec,YVec,Func,GraphX,GraphY:Integer;
BEGIN
     PaintChar:=FALSE;
     WITH Font[FontNr]^ DO
     BEGIN
          IF (Ch<MinChar) OR (Ch>MinChar+TblSize-1) THEN
             Exit;
          Index:=VecStart+FBuf[TBStart+(Ch-MinChar)*2]+FBuf[TBStart+(Ch-MinChar)*2+1]*256;
          REPEAT
                XVec:=ShortInt(FBuf[Index]);
                YVec:=ShortInt(FBuf[Index+1]);
                Inc(Index,2);
                Func:=(XVec AND $80) SHR 6+(YVec AND $80) SHR 7;
                XVec:=XVec AND $7F;
                YVec:=YVec AND $7F;
                IF XVec>=$40 THEN
                   XVec:=-128+XVec;
                IF YVec>=$40 THEN
                   YVec:=-128+YVec;
                IF MX<>1 THEN
                   XVec:=XVec*MX;
                IF DX<>1 THEN
                   XVec:=XVec DIV DX;
                IF MY<>1 THEN
                   YVec:=YVec*MY;
                IF DY<>1 THEN
                   YVec:=YVec DIV DY;
                CASE Func OF
                     2:BEGIN
                            GraphX:=X+XVec;
                            GraphY:=CUp+Y-YVec;
                       END;
                     3:BEGIN
                            DrawLine(X+XVec,CUp+Y-YVec,GraphX,GraphY,C);
                            GraphX:=X+XVec;
                            GraphY:=CUp+Y-YVec;
                       END;
                END;
          UNTIL Func=0;
     END;
     PaintChar:=TRUE;
END;

PROCEDURE GrWrite(X,Y:Integer; C:Byte; S:String);
VAR
   I:Byte;
BEGIN
     WITH Font[FontNr]^ DO
     BEGIN
          FOR I:=1 TO Ord(S[0]) DO
          BEGIN
               IF X+FBuf[WidthTbl+Ord(S[I])-MinChar]*MX DIV DX>319 THEN
               BEGIN
                    X:=0;
                    IF Y+(CUp-CDown)*MY DIV DY>319 THEN
                       Exit;
                    Inc(Y,(CUp-CDown)*MY DIV DY);
               END;
               IF PaintChar(Ord(S[I]),X,Y,C) THEN
                  Inc(X,(FBuf[WidthTbl+Ord(S[I])-MinChar])*MX DIV DX);
          END;
     END;
END;

PROCEDURE LoadFont(Nr:Byte; Name:String);
VAR
   X:Integer;
   ChrFile:File;
BEGIN
     New(Font[Nr]);
     WITH Font[Nr]^ DO
     BEGIN
          Assign(ChrFile,Name+'.CHR');
          Reset(ChrFile,1);
          BlockRead(ChrFile,FBuf,FileSize(ChrFile));
          Close(ChrFile);
          X:=0;
          WHILE (X<$80) AND (FBuf[X]<>$1A) DO
                Inc(X);
          Inc(X);
          DataOffs:=FBuf[X]+FBuf[X+1] SHL 8;
          TblSize:=FBuf[DataOffs+1];
          MinChar:=FBuf[DataOffs+4];
          CUp:=FBuf[DataOffs+8];
          CDown:=ShortInt(FBuf[DataOffs+$0A]);
          TBStart:=DataOffs+$10;
          WidthTbl:=TBStart+TblSize SHL 1;
          WPtr:=@FBuf[DataOffs+5];
          VecStart:=WPtr^+DataOffs;
     END;
END;

PROCEDURE SetText(Nr:Byte; MultX,DivX,MultY,DivY:Byte);
BEGIN
     IF (Nr<1) OR (Nr>MaxFont) THEN
        Exit;
     IF Font[Nr]=NIL THEN
        LoadFont(Nr,FontName[Nr]);
     FontNr:=Nr;
     MX:=MultX;
     DX:=DivX;
     MY:=MultY;
     DY:=DivY;
END;

PROCEDURE DrawPolygon(Count:Integer; VAR P; C:Byte);
TYPE
    PunkteArray=ARRAY[1..16383,1..2] OF Integer;
VAR
   A:PunkteArray ABSOLUTE P;
   I:Integer;
BEGIN
     DrawLine(A[Count,1],A[Count,2],A[1,1],A[1,2],C);
     FOR I:=2 TO Count DO
         DrawLine(A[I-1,1],A[I-1,2],A[I,1],A[I,2],C);
END;

PROCEDURE Fill(X,Y:Integer; C:Byte);  { Nur die selbe Farbe ersetzen }
VAR
   C2:Byte;

   PROCEDURE Suchen(L,R,Y:Integer; UpDown:Byte);
   VAR
      X,X2:Integer;
   BEGIN
        IF GetPixel(L,Y)=C2 THEN
           WHILE (L>0) AND (GetPixel(L-1,Y)=C2) DO
                 Dec(L);
        X:=L;
        IF GetPixel(R,Y)=C2 THEN
           WHILE (R<319) AND (GetPixel(R+1,Y)=C2) DO
                 Inc(R);
        WHILE X<=R DO
        BEGIN
             X2:=X;
             IF GetPixel(X,Y)=C2 THEN
             BEGIN
                  WHILE (GetPixel(X+1,Y)=C2) AND (X<319) DO
                        Inc(X);
                  DrawLineH(X2,X,Y,C);
                  IF UpDown=2 THEN
                  BEGIN
                       IF Y>0 THEN
                          Suchen(X2,X,Y-1,2);
                       IF Y<199 THEN
                          IF (L>X2) AND (R<X) THEN
                          BEGIN
                               Suchen(X2,L-1,Y+1,1);
                               Suchen(R+1,X,Y+1,1);
                          END
                          ELSE
                          IF (L<=X2) AND (R<X) THEN
                             Suchen(R+1,X,Y+1,1)
                          ELSE
                          IF (L>X2) AND (R>=X) THEN
                             Suchen(X2,L-1,Y+1,1);
                  END;
                  IF UpDown=1 THEN
                  BEGIN
                       IF Y<199 THEN
                          Suchen(X2,X,Y+1,1);
                       IF Y>0 THEN
                          IF (L>X2) AND (R<X) THEN
                          BEGIN
                               Suchen(X2,L-1,Y-1,2);
                               Suchen(R+1,X,Y-1,2);
                          END
                          ELSE
                          IF (L<=X2) AND (R<X) THEN
                             Suchen(R+1,X,Y-1,2)
                          ELSE
                          IF (L>X2) AND (R>=X) THEN
                             Suchen(X2,L-1,Y-1,2);
                  END;
             END;
             Inc(X);
        END;
   END;

BEGIN
     C2:=GetPixel(X,Y);
     IF Y<>0 THEN
        Dec(Y);
     Suchen(X,X,Y,2);
     Suchen(X,X,Y+1,1);
END;

PROCEDURE Flood(X,Y:Integer; C,C2:Byte);  { Anfärben bis zur Randfarbe C2 }

   PROCEDURE Suchen(L,R,Y:Integer; UpDown:Byte);
   VAR
      X,X2:Integer;
   BEGIN
        IF GetPixel(L,Y)<>C2 THEN
           WHILE (L>0) AND (GetPixel(L-1,Y)<>C2) DO
                 Dec(L);
        X:=L;
        IF GetPixel(R,Y)<>C2 THEN
           WHILE (R<319) AND (GetPixel(R+1,Y)<>C2) DO
                 Inc(R);
        WHILE X<=R DO
        BEGIN
             X2:=X;
             IF GetPixel(X,Y)<>C2 THEN
             BEGIN
                  WHILE (GetPixel(X+1,Y)<>C2) AND (X<319) DO
                        Inc(X);
                  DrawLineH(X2,X,Y,C);
                  IF UpDown=2 THEN
                  BEGIN
                       IF Y>0 THEN
                          Suchen(X2,X,Y-1,2);
                       IF Y<199 THEN
                          IF (L>X2) AND (R<X) THEN
                          BEGIN
                               Suchen(X2,L-1,Y+1,1);
                               Suchen(R+1,X,Y+1,1);
                          END
                          ELSE
                          IF (L<=X2) AND (R<X) THEN
                             Suchen(R+1,X,Y+1,1)
                          ELSE
                          IF (L>X2) AND (R>=X) THEN
                             Suchen(X2,L-1,Y+1,1);
                  END;
                  IF UpDown=1 THEN
                  BEGIN
                       IF Y<199 THEN
                          Suchen(X2,X,Y+1,1);
                       IF Y>0 THEN
                          IF (L>X2) AND (R<X) THEN
                          BEGIN
                               Suchen(X2,L-1,Y-1,2);
                               Suchen(R+1,X,Y-1,2);
                          END
                          ELSE
                          IF (L<=X2) AND (R<X) THEN
                             Suchen(R+1,X,Y-1,2)
                          ELSE
                          IF (L>X2) AND (R>=X) THEN
                             Suchen(X2,L-1,Y-1,2);
                  END;
             END;
             Inc(X);
        END;
   END;

BEGIN
     IF Y<>0 THEN
        Dec(Y);
     Suchen(X,X,Y,2);
     Suchen(X,X,Y+1,1);
END;

PROCEDURE MCGAOn;
BEGIN
     ASM
        mov ah,$f
        int $10
        mov [offset oldmode],al
     END;
     ASM
        mov ax,$13
        int $10
     END;
END;

PROCEDURE MCGAOff;
BEGIN
     ASM
        mov al,[offset oldmode]
        xor ah,ah
        int $10
     END;
END;

PROCEDURE FillPolygon(Size:Integer; VAR P1; C:Byte);
TYPE
    Vektor=RECORD
                 X,Y,XMax,DX,DY,DZ,Z,Spalte:Integer;
           END;
    VekPoly=ARRAY[1..VekMax,1..2,1..2] OF Integer;
VAR
   P:ARRAY[1..VekMax,1..2] OF Integer ABSOLUTE P1;
   Sp:VekPoly;
   NF:Boolean;
   V:ARRAY[1..VekMax] OF Vektor;
   S:ARRAY[1..2*VekMax] OF Integer;
   I,J,K,N,SX,YRMin,YRMax,YR,XMin,YMin,YMax,I2:Integer;
BEGIN
     IF Size>VekMax THEN
        Exit;
     K:=1;
     FOR I:=1 TO Size DO
     BEGIN
          Sp[K,1,1]:=P[I,1];
          Sp[K,1,2]:=P[I,2];
          IF I=Size THEN
          BEGIN
               Sp[K,2,1]:=P[1,1];
               Sp[K,2,2]:=P[1,2];
          END
          ELSE
          BEGIN
               Sp[K,2,1]:=P[I+1,1];
               Sp[K,2,2]:=P[I+1,2];
          END;
          IF Sp[K,2,2]-Sp[K,1,2]<0 THEN
          BEGIN
               J:=Sp[K,2,1];
               Sp[K,2,1]:=Sp[K,1,1];
               Sp[K,1,1]:=J;
               J:=Sp[K,2,2];
               Sp[K,2,2]:=Sp[K,1,2];
               Sp[K,1,2]:=J;
          END;
          Inc(K);
     END;
     YRMin:=199;
     YRMax:=0;
     FOR K:=1 TO Size DO
         FOR I:=1 TO 2 DO
         BEGIN
              IF Sp[K,I,2]>YRMax THEN
                 YRMax:=Sp[K,I,2];
              IF Sp[K,I,2]<YRMin THEN
                 YRMin:=Sp[K,I,2];
         END;
     IF YRMin<0 THEN
        YRMin:=0;
     IF YRMax>199 THEN
        YRMax:=199;
     FOR K:=1 TO Size DO
         WITH V[K] DO
         BEGIN
              XMin:=Sp[K,1,1];
              YMin:=Sp[K,1,2];
              XMax:=Sp[K,2,1];
              YMax:=Sp[K,2,2];
              DX:=Abs(XMin-XMax);
              DY:=Abs(YMin-YMax);
              X:=XMin;
              Y:=YMin;
              IF XMin<XMax THEN
                 Z:=1
              ELSE Z:=-1;
              IF DX>DY THEN
                 I2:=DX
              ELSE I2:=DY;
              DZ:=I2 DIV 2;
              Spalte:=XMin;
         END;
     FOR YR:=YRMin TO YRMax DO
     BEGIN
          N:=0;
          FOR K:=1 TO Size DO
              IF ((Sp[K,1,2]<=YR) AND (YR<SP[K,2,2])) OR ((YR=YRMax) AND (YRMax=Sp[K,2,2]) AND (YRMax<>Sp[K,1,2])) THEN
              BEGIN
                   WITH V[K] DO
                   BEGIN
                        Inc(N);
                        S[N]:=X;
                        SX:=X;
                        REPEAT
                              IF DZ<DX THEN
                              BEGIN
                                   DZ:=DZ+DY;
                                   X:=X+Z;
                              END;
                              IF DZ>=DX THEN
                              BEGIN
                                   DZ:=DZ-DX;
                                   Inc(Y);
                              END;
                              IF Y=YR THEN
                                 SX:=X;
                              Inc(Spalte,Z);
                        UNTIL (Y>YR) OR (Spalte=XMax);
                        Inc(N);
                        S[N]:=SX;
                   END;
              END;
          FOR I:=2 TO N DO
              FOR K:=N DOWNTO I DO
                  IF S[K-1]>S[K] THEN
                  BEGIN
                       J:=S[K-1];
                       S[K-1]:=S[K];
                       S[K]:=J;
                  END;
          K:=1;
          WHILE K<=N DO
          BEGIN
               IF S[K]<0 THEN
                  S[K]:=0;
               IF S[K+3]>319 THEN
                  S[K+3]:=319;
               DrawLineH(S[K],S[K+3],YR,C);
               K:=K+4;
          END;
     END;
END;

PROCEDURE Ellipse(MX,MY,A,B:Integer; C:Byte);
VAR
   X,Y,X2,J:Integer;
BEGIN
     Dec(B);
     X2:=A;
     FOR Y:=0 TO B DO
     BEGIN
          X:=Trunc(A/B*Sqrt(Sqr(B)-Sqr(Y-0.5)));
          FOR J:=X TO X2 DO
          BEGIN
               SetPixel(MX+J,MY+Y,C);
               SetPixel(MX-J,MY+Y,C);
               SetPixel(MX+J,MY-Y,C);
               SetPixel(MX-J,MY-Y,C);
          END;
          X2:=X;
     END;
     Inc(B);
     FOR J:=0 TO X DO
     BEGIN
          SetPixel(MX+J,MY+B,C);
          SetPixel(MX-J,MY+B,C);
          SetPixel(MX+J,MY-B,C);
          SetPixel(MX-J,MY-B,C);
     END;
END;

PROCEDURE FillEllipse(MX,MY,A,B:Integer; C:Byte);
VAR
   X,Y,X2,J:Integer;
BEGIN
     Dec(B);
     X2:=A;
     DrawLineH(MX-A,MX+A,MY,C);
     FOR Y:=1 TO B DO
     BEGIN
          X:=Trunc(A/B*Sqrt((Sqr(LongInt(B)))-Sqr(Y-0.5)));
          DrawLineH(MX-X,MX+X,MY+Y,C);
          DrawLineH(MX-X,MX+X,MY-Y,C);
          X2:=X;
     END;
END;

PROCEDURE Circle(X,Y,R:Integer; C:Byte);
BEGIN
     Ellipse(X,Y,R,Trunc(R*X_zu_Y),C);
END;

PROCEDURE FillCircle(X,Y,R:Integer; C:Byte);
BEGIN
     FillEllipse(X,Y,R,Round(R*X_zu_Y),C);
END;

PROCEDURE RotateArray(VAR P; Count,MX,MY:Integer; Winkel:Real);
TYPE
    PunkteArray=ARRAY[1..16383,1..2] OF Integer;
VAR
   A:PunkteArray ABSOLUTE P;
   I,X,Y:Integer;
   CosWi,SinWi:Real;
BEGIN
     Winkel:=-Pi*Winkel/180;
     CosWi:=Cos(Winkel);
     SinWi:=Sin(Winkel);
     FOR I:=1 TO Count DO
     BEGIN
          X:=A[I,1]-MX;
          Y:=A[I,2]-MY;
          A[I,1]:=Round(X*CosWi+Y*SinWi)+MX;
          A[I,2]:=Round(-X*SinWi+Y*CosWi)+MY;
     END;
END;

PROCEDURE N4eck(N,X,Y,R1,R2:Integer; C:Byte);
VAR
   D:ARRAY[0..100] OF Word;
   I,X1,Y1,X2,Y2:Integer;
   Pi180:Real;
BEGIN
     Pi180:=Pi/180;
     FOR I:=0 TO N DO
         D[I]:=Round(Sin(Pi180*I/N*90)*10000);
     X1:=Round(D[0]*R1/10000);
     Y1:=Round(D[N]*R2/10000);
     FOR I:=1 TO N DO
     BEGIN
          X2:=Round(D[I]*R1/10000);
          Y2:=Round(D[N-I]*R2/10000);
          DrawLine(X-X1,Y+Y1,X-X2,Y+Y2,C);
          DrawLine(X+X1,Y+Y1,X+X2,Y+Y2,C);
          DrawLine(X+X1,Y-Y1,X+X2,Y-Y2,C);
          DrawLine(X-X1,Y-Y1,X-X2,Y-Y2,C);
          X1:=X2;
          Y1:=Y2;
     END;
END;

PROCEDURE Neck(N,X,Y,A,B:Integer; Drehen:Real);
VAR
   I:Integer;
   Winkel,Wi:Real;
   P:ARRAY[1..100,1..2] OF Integer;
BEGIN
     Winkel:=2*Pi/N;
     Wi:=Winkel;
     FOR I:=1 TO N DO
     BEGIN
          P[I,1]:=Round(A*Cos(Wi))+X;
          P[I,2]:=Round(B*Sin(Wi))+Y;
          Wi:=Wi+Winkel;
     END;
     IF Drehen<>0 THEN
        RotateArray(P,N,X,Y,Drehen);
     DrawPolygon(N,P,255);
END;

PROCEDURE DrawRing(X,Y,R1,R2:Integer; C:Byte);
TYPE
    Arr52=ARRAY[1..52,1..2] OF Integer;
CONST
     D:ARRAY[1..14] OF Integer=(0,1205,2393,3546,4647,5681,6631,7485,8230,8855,9350,9709,9927,10000);
     A:Arr52=(
     (0,10000),(1205,9927),(2393,9709),(3546,9350),(4647,8855),(5681,8230),(6631,7485),
     (7485,6631),(8230,5681),(8855,4647),(9350,3546),(9709,2393),(9927,1205),
     (10000,0),(9927,-1205),(9709,-2393),(9350,-3546),(8855,-4647),(8230,-5681),(7485,-6631),
     (6631,-7485),(5681,-8230),(4647,-8855),(3546,-9350),(2393,-9709),(1205,-9927),
     (0,-10000),(-1205,-9927),(-2393,-9709),(-3546,-9350),(-4647,-8855),(-5681,-8230),(-6631,-7485),
     (-7485,-6631),(-8230,-5681),(-8855,-4647),(-9350,-3546),(-9709,-2393),(-9927,-1205),
     (-10000,0),(-9927,1205),(-9709,2393),(-9350,3546),(-8855,4647),(-8230,5681),(-7485,6631),
     (-6631,7485),(-5681,8230),(-4647,8855),(-3546,9350),(-2393,9709),(-1205,9927));
VAR
   I,X1,Y1,X2,Y2:Integer;
   A2:Arr52;
BEGIN
     A2:=A;
     FOR I:=1 TO 52 DO
     BEGIN
          A2[I,1]:=X+Round(A2[I,1]/10000*R1);
          A2[I,2]:=Y+Round(A2[I,2]/10000*R2);
     END;
     DrawPolygon(52,A2,C);
END;

PROCEDURE FillRing(X,Y,R1,R2:Integer; C:Byte);
TYPE
    Arr52=ARRAY[1..52,1..2] OF Integer;
CONST
     D:ARRAY[1..14] OF Integer=(0,1205,2393,3546,4647,5681,6631,7485,8230,8855,9350,9709,9927,10000);
     A:Arr52=(
     (0,10000),(1205,9927),(2393,9709),(3546,9350),(4647,8855),(5681,8230),(6631,7485),
     (7485,6631),(8230,5681),(8855,4647),(9350,3546),(9709,2393),(9927,1205),
     (10000,0),(9927,-1205),(9709,-2393),(9350,-3546),(8855,-4647),(8230,-5681),(7485,-6631),
     (6631,-7485),(5681,-8230),(4647,-8855),(3546,-9350),(2393,-9709),(1205,-9927),
     (0,-10000),(-1205,-9927),(-2393,-9709),(-3546,-9350),(-4647,-8855),(-5681,-8230),(-6631,-7485),
     (-7485,-6631),(-8230,-5681),(-8855,-4647),(-9350,-3546),(-9709,-2393),(-9927,-1205),
     (-10000,0),(-9927,1205),(-9709,2393),(-9350,3546),(-8855,4647),(-8230,5681),(-7485,6631),
     (-6631,7485),(-5681,8230),(-4647,8855),(-3546,9350),(-2393,9709),(-1205,9927));
VAR
   I,X1,Y1,X2,Y2:Integer;
   A2:Arr52;
BEGIN
     A2:=A;
     FOR I:=1 TO 52 DO
     BEGIN
          A2[I,1]:=X+Round(A2[I,1]/10000*R1);
          A2[I,2]:=Y+Round(A2[I,2]/10000*R2);
     END;
     FillPolygon(52,A2,C);
END;

PROCEDURE SetFrameColor(C:Byte);
BEGIN
     ASM
        mov ax,$1001
        mov bh,[bp+offset c]
        int $10
     END;
END;

PROCEDURE RecTangle(X1,Y1,X2,Y2:Integer; C:Byte);
BEGIN
     DrawLineH(X1,X2,Y1,C);
     DrawLineH(X1,X2,Y2,C);
     DrawLineV(X1,Y1,Y2,C);
     DrawLineV(X2,Y1,Y2,C);
END;

PROCEDURE GetImage(X1,Y1,X2,Y2:Integer; VAR P);
VAR
   Data:ARRAY[0..64003] OF Byte ABSOLUTE P;
   I,XS,YS:Word;
   P2:Pointer ABSOLUTE P;
BEGIN
     XS:=X2-X1;
     YS:=Y2-Y1;
     Data[0]:=Lo(XS);
     Data[1]:=Hi(XS);
     Data[2]:=Lo(YS);
     Data[3]:=Hi(YS);
     FOR I:=0 TO YS DO
         Move(Ptr($A000,(Y1+I)*320+X1)^,Data[(XS+1)*I+4],XS+1);
END;
{
PROCEDURE PutImage(X1,Y1:Integer; VAR P);
VAR
   Data:ARRAY[0..64003] OF Byte ABSOLUTE P;
   I,XS,YS:Word;
BEGIN
     XS:=Data[0]+Data[1] SHL 8;
     YS:=Data[2]+Data[3] SHL 8;
     FOR I:=0 TO YS DO
         Move(Data[(XS+1)*I+4],Ptr($A000,(Y1+I)*320+X1)^,XS+1);
END;
}

PROCEDURE PutImage(X1,Y1:Integer; VAR P);
VAR
   Data:ARRAY[0..64003] OF Byte ABSOLUTE P;
   Adr,I,XS,YS:Word;
   DataDS,DataSI:Word;
BEGIN
     XS:=Data[0]+Data[1] SHL 8;
     YS:=Data[2]+Data[3] SHL 8;
     Adr:=Word(Y1)*320+X1;
     DataDS:=Seg(Data[4]);
     DataSI:=Ofs(Data[4]);
     ASM
        mov dx,ys
        inc dx
        mov bx,xs
        inc bx
        mov ax,$a000
        mov es,ax
        mov di,adr
        mov si,DataSI
        mov ax,DataDS
        push ds
        mov ds,ax
        cld
@1:     mov cx,bx
        rep movsb
        add di,320
        sub di,bx
        dec dx
        jnz @1
        pop ds
     END;
{
     FOR I:=0 TO YS DO
         Move(Data[(XS+1)*I+4],Ptr($A000,(Y1+I)*320+X1)^,XS+1);
}
END;

PROCEDURE PutImagePart(X1,Y1,XS2,YS2:Integer; VAR P);
VAR
   Data:ARRAY[0..64003] OF Byte ABSOLUTE P;
   Adr,I,XS,YS:Word;
   DataDS,DataSI:Word;
BEGIN
     XS:=Data[0]+Data[1] SHL 8+1;
     YS:=Data[2]+Data[3] SHL 8+1;
     IF (XS2<0) OR (XS2>XS) THEN
        XS2:=XS;
     IF (YS2<0) OR (YS2>YS) THEN
        YS2:=YS;
     Adr:=Word(Y1)*320+X1;
     DataDS:=Seg(Data[4]);
     DataSI:=Ofs(Data[4]);
     ASM
        mov dx,ys
        mov bx,xs2
        mov ax,$a000
        mov es,ax
        mov di,adr
        mov si,DataSI
        mov ax,DataDS
        mov cx,xs
        sub cx,xs2
        push ds
        mov ds,ax
        mov ax,cx
        cld
@1:     mov cx,bx
        rep movsb
        add di,320
        sub di,bx
        add si,ax
        dec dx
        jnz @1
        pop ds
     END;
{
     FOR I:=0 TO YS DO
         Move(Data[(XS+1)*I+4],Ptr($A000,(Y1+I)*320+X1)^,XS+1);
}
END;

PROCEDURE FillBlock(X1,Y1,X2,Y2:Integer; C:Byte);
VAR
   Y:Integer;
BEGIN
     FOR Y:=Y1 TO Y2 DO
         DrawLineH(X1,X2,Y,C);
END;

PROCEDURE ScrollLeft(X1,Y1,X2,Y2:Word);
BEGIN
     ASM
        push ds
        mov ax,$a000
        mov es,ax
        mov ds,ax
        mov si,[bp+offset y1]
        mov cx,[bp+offset y2]
        sub cx,si
        inc cx
        mov ax,320
        mul si
        mov bx,[bp+offset x1]
        add ax,bx
        mov dx,[bp+offset x2]
        sub dx,bx
        inc dx
        cld
@1:     mov bx,cx
        mov di,ax
        dec di
        mov si,ax
        mov cx,dx
        rep movsb
        mov cx,bx
        add ax,320
        loop @1
        pop ds
     END;
END;

PROCEDURE ScrollRight(X1,Y1,X2,Y2:Word);
BEGIN
     ASM
        push ds
        mov ax,$a000
        mov es,ax
        mov ds,ax
        mov si,[bp+offset y1]
        mov cx,[bp+offset y2]
        sub cx,si
        inc cx
        mov ax,320
        mul si
        mov bx,[bp+offset x1]
        mov dx,[bp+offset x2]
        add ax,dx
        sub dx,bx
        inc dx
        std
@1:     mov bx,cx
        mov di,ax
        mov si,ax
        dec si
        mov cx,dx
        rep movsb
        mov cx,bx
        add ax,320
        loop @1
        cld
        pop ds
     END;
END;

PROCEDURE ScrollUp(X1,Y1,X2,Y2:Word);
BEGIN
     ASM
        push ds
        mov ax,$a000
        mov es,ax
        mov ds,ax
        mov si,[bp+offset y1]
        mov cx,[bp+offset y2]
        sub cx,si
        inc cx
        mov ax,320
        mul si
        mov bx,[bp+offset x1]
        add ax,bx
        mov dx,[bp+offset x2]
        sub dx,bx
        inc dx
        cld
@1:     mov bx,cx
        mov di,ax
        sub di,320
        mov si,ax
        mov cx,dx
        rep movsb
        mov cx,bx
        add ax,320
        loop @1
        pop ds
     END;
END;

PROCEDURE ScrollDown(X1,Y1,X2,Y2:Word);
BEGIN
     ASM
        push ds
        mov ax,$a000
        mov es,ax
        mov ds,ax
        mov si,[bp+offset y1]
        mov cx,[bp+offset y2]
        mov ax,320
        mul cx
        sub cx,si
        inc cx
        mov bx,[bp+offset x1]
        mov dx,[bp+offset x2]
        add ax,bx
        sub dx,bx
        inc dx
        cld
@1:     mov bx,cx
        mov di,ax
        mov si,ax
        sub si,320
        mov cx,dx
        rep movsb
        mov cx,bx
        sub ax,320
        loop @1
        pop ds
     END;
END;

PROCEDURE Scroll(Direction:Byte; X1,Y1,X2,Y2:Word);
BEGIN
     CASE Direction OF
          Up:ScrollUp(X1,Y1,X2,Y2);
          Right:ScrollRight(X1,Y1,X2,Y2);
          Down:ScrollDown(X1,Y1,X2,Y2);
          Left:ScrollLeft(X1,Y1,X2,Y2);
     END;
END;

PROCEDURE SwitchOff; ASSEMBLER;
ASM
   mov dx,$3c4
   mov al,1
   out dx,al
   inc dx
   in al,dx
   or al,$20
   out dx,al
END;

PROCEDURE SwitchOn; ASSEMBLER;
ASM
   mov dx,$3c4
   mov al,1
   out dx,al
   inc dx
   in al,dx
   and al,$df
   out dx,al
END;

PROCEDURE LoadPalette(DateiName:String);
VAR
   Datei:File;
   RGB:ARRAY[0..255,1..3] OF Byte;
   I:Byte;
BEGIN
     Assign(Datei,DateiName+'.PAL');
     Reset(Datei,1);
     BlockRead(Datei,RGB,768);
     SwitchOff;
     FOR I:=0 TO 255 DO
         SetColor(I,RGB[I,1],RGB[I,2],RGB[I,3]);
     SwitchOn;
END;

PROCEDURE SavePalette(DateiName:String);
VAR
   Datei:File;
   RGB:ARRAY[0..255,1..3] OF Byte;
   I:Byte;
BEGIN
     Assign(Datei,DateiName+'.PAL');
     Rewrite(Datei,1);
     FOR I:=0 TO 255 DO
         GetColor(I,RGB[I,1],RGB[I,2],RGB[I,3]);
     BlockWrite(Datei,RGB,768);
END;

PROCEDURE LoadScreen(DateiName:String);
VAR
   Datei:File;
   RGB:ARRAY[0..255,1..3] OF Byte;
   I:Byte;
BEGIN
     Assign(Datei,DateiName+'.BLD');
     Reset(Datei,1);
     BlockRead(Datei,RGB,768);
     SwitchOff;
     FOR I:=0 TO 255 DO
         SetColor(I,RGB[I,1],RGB[I,2],RGB[I,3]);
     BlockRead(Datei,Ptr($A000,0)^,64000);
     SwitchOn;
     Close(Datei);
END;

PROCEDURE SaveScreen(DateiName:String);
VAR
   Datei:File;
   RGB:ARRAY[0..255,1..3] OF Byte;
   I:Byte;
BEGIN
     Assign(Datei,DateiName+'.BLD');
     Rewrite(Datei,1);
     FOR I:=0 TO 255 DO
         GetColor(I,RGB[I,1],RGB[I,2],RGB[I,3]);
     BlockWrite(Datei,RGB,768);
     BlockWrite(Datei,Ptr($A000,0)^,64000);
     Close(Datei);
END;

PROCEDURE BCircle(X,Y,R:Integer; C:Byte);
VAR
   XX4,XX,YY,D:Integer;
BEGIN
     XX:=0;
     YY:=R;
     D:=3-(2*R);
     WHILE XX<=YY DO
     BEGIN
          SetPixel(X+XX,Y+YY,C);
          SetPixel(X-XX,Y+YY,C);
          SetPixel(X+XX,Y-YY,C);
          SetPixel(X-XX,Y-YY,C);
          SetPixel(X+YY,Y+XX,C);
          SetPixel(X-YY,Y+XX,C);
          SetPixel(X+YY,Y-XX,C);
          SetPixel(X-YY,Y-XX,C);
          XX4:=XX SHL 2;
          IF D<0 THEN
             Inc(D,XX4+6)
          ELSE
          BEGIN
               Inc(D,XX4-YY SHL 2+10);
               Dec(YY);
          END;
          Inc(XX);
     END;
END;

PROCEDURE BFillCircle(X,Y,R:Integer; C:Byte);
VAR
   XX4,XX,YY,D:Integer;
BEGIN
     XX:=0;
     YY:=R;
     D:=3-(2*R);
     WHILE XX<=YY DO
     BEGIN
          DrawLineH(X-XX,X+XX,Y+YY,C);
          DrawLineH(X-XX,X+XX,Y-YY,C);
          DrawLineH(X-YY,X+YY,Y+XX,C);
          DrawLineH(X-YY,X+YY,Y-XX,C);
          XX4:=XX SHL 2;
          IF D<0 THEN
             Inc(D,XX4+6)
          ELSE
          BEGIN
               Inc(D,XX4-YY SHL 2+10);
               Dec(YY);
          END;
          Inc(XX);
     END;
END;

PROCEDURE Split(Row:Integer);
BEGIN
     ASM
        mov dx,$3d4
        mov ax,row
        mov bh,ah
        mov bl,ah
        and bx,201h
        mov cl,4
        shl bx,cl
        mov ah,al
        mov al,18h
        out dx,ax
        mov al,7
        cli
        out dx,al
        inc dx
        in al,dx
        sti
        dec dx
        mov ah,al
        and ah,0efh
        or ah,bl
        mov al,7
        out dx,ax
        mov al,9
        cli
        out dx,al
        inc dx
        in al,dx
        sti
        dec dx
        mov ah,al
        and ah,0bfh
        shl bh,1
        shl bh,1
        or ah,bh
        mov al,9
        out dx,ax
     END;
END;

PROCEDURE ScrollText(Nr:Word);
BEGIN
     ASM
        mov ax,nr
        push es
        push cx
        push dx
        mov cx,$40
        mov es,cx
        mov cl,es:[$85]
        div cl
        mov cx,ax
        mov dx,es:[$63]
        push dx
        mov al,$13
        cli
        out dx,al
        jmp @1
@1:     inc dx
        in al,dx
        sti
        mul cl
        shl ax,1
        mov es:[$4e],ax
        pop dx
        mov cl,al
        mov al,$c
        out dx,ax
        jmp @2
@2:     mov al,$d
        mov ah,cl
        out dx,ax
        jmp @3
@3:     mov ah,ch
        mov al,8
        out dx,ax
        pop dx
        pop cx
        pop es
     END;
END;

PROCEDURE SetStart(S:Word);
BEGIN
     ASM
        mov bx,s
        mov dx,$3d4
        mov al,$c
        mov ah,bh
        out dx,ax
        inc ax
        mov ah,bl
        out dx,ax
     END;
END;

PROCEDURE VerticalRetrace;
BEGIN
     ASM
        mov dx,3dah
@1:     in al,dx
        test al,8
        jz @1
@2:     in al,dx
        test al,8
        jnz @2
     END;
END;

PROCEDURE WaitScreen;
BEGIN
     ASM
        mov dx,3dah
@1:     in al,dx
        test al,8
        jnz @1
     END;
END;

PROCEDURE WaitRetrace;
BEGIN
     ASM
        mov dx,3dah
@1:     in al,dx
        test al,8
        jz @1
     END;
END;

PROCEDURE SetOffset(B:Byte);
BEGIN
     ASM
        mov dx,$3d4
        mov al,$13
        mov ah,b
        out dx,ax
     END;
END;

PROCEDURE LoadSprite(DateiName:String; VAR P);
VAR
   Datei:File;
   Size,I:Word;
   P2:Pointer ABSOLUTE P;
BEGIN
     Assign(Datei,DateiName+'.SPR');
     Reset(Datei,1);
     Size:=FileSize(Datei);
     GetMem(P2,Size+15);
     IF Ofs(P2^)<>0 THEN
        P2:=Ptr(Seg(P2^)+1,0);
     BlockRead(Datei,P2^,Size);
     Close(Datei);
END;

PROCEDURE SaveSprite(DateiName:String; VAR P);
VAR
   A:ARRAY[-4..32000] OF Byte ABSOLUTE P;
   Datei:File;
   Size,I:Word;
   XS,YS:Word;
BEGIN
     XS:=A[-4]+A[-3] SHL 8;
     YS:=A[-2]+A[-1] SHL 8;
     Assign(Datei,DateiName+'.SPR');
     Rewrite(Datei,1);
     Size:=(XS+1)*(YS+1)+4;
     BlockWrite(Datei,A,Size);
     Close(Datei);
END;

PROCEDURE FillScreen(C:Byte);
BEGIN
     ASM
        mov ax,$a000
        mov es,ax
        mov al,c
        mov ah,al
        cld
        xor di,di
        mov cx,32000
        rep stosw
     END;
END;

PROCEDURE Unchain;
BEGIN
     PortW[$3C4]:=$0604;
     PortW[$3D4]:=$0014;
     PortW[$3D4]:=$E317;
     PortW[$3C4]:=$0F02;
END;

PROCEDURE Rechain;
BEGIN
     PortW[$3C4]:=$0E04;
     PortW[$3C4]:=$0100;
     PortW[$3C4]:=$0300;
     PortW[$3D4]:=$4014;
     PortW[$3D4]:=$A317;
END;

PROCEDURE ClearScreen;
BEGIN
     PortW[$3C4]:=$0F02;
     ASM
        mov ax,$a000
        mov es,ax
        mov cx,16383
        db $66
        xor ax,ax
        xor di,di
        cld
        db $66
        rep stosw
     END;
END;

PROCEDURE SetChain4;
BEGIN
     Port[$3CE]:=$05;
     Port[$3CF]:=Port[$3CF] AND $EF;
     Port[$3CE]:=$06;
     Port[$3CF]:=Port[$3CF] AND $FD;
     Port[$3C4]:=$04;
     Port[$3C5]:=Port[$3C5] AND $F7;
     Port[$3D4]:=$14;
     Port[$3D5]:=Port[$3D5] AND $BF;
     Port[$3D4]:=$17;
     Port[$3D5]:=Port[$3D5] OR $40;
END;

PROCEDURE ClearChain4;
BEGIN
     ASM
        mov ax,$a000
        mov es,ax
        mov cx,32768
        xor di,di
        cld
        xor ax,ax
        rep stosw
     END;
END;

PROCEDURE CharHeight(B:Byte);
BEGIN
     Port[$3D4]:=$09;
     Port[$3D5]:=(Port[$3D5] AND $E0) OR B;
END;

PROCEDURE Wait4Line;
BEGIN
     ASM
        mov dx,$3da
@1:     in al,dx
        test al,1
        jnz @1
@2:     in al,dx
        test al,1
        jz @2
     END;
END;

PROCEDURE CLI; ASSEMBLER;
ASM
   cli
END;

PROCEDURE STI; ASSEMBLER;
ASM
   sti
END;

PROCEDURE SetWriteMap(Map:Byte);
BEGIN
     Port[$3C4]:=2;
     Port[$3C5]:=Map;
END;

PROCEDURE PutImage4(X1,Y1:Integer; VAR P);
VAR
   Data:ARRAY[0..64003] OF Byte ABSOLUTE P;
   Adr,I,J,K,XS,YS:Word;
   DataDS,DataSI:Word;
BEGIN
     XS:=Data[0]+Data[1] SHL 8;
     YS:=Data[2]+Data[3] SHL 8;
     DataDS:=Seg(Data);
     FOR J:=0 TO YS DO
     BEGIN
          DataSI:=Ofs(Data)+4+(XS+1)*J;
          FOR K:=0 TO 3 DO
          BEGIN
               Adr:=Word(Y1+J)*80+(X1+K) SHR 2;
               SetWriteMap(1 SHL ((X1+K) AND 3));
               ASM
                  push ds
                  mov ax,$a000
                  mov es,ax
                  mov di,adr
                  mov cx,xs
                  shr cx,2
                  inc cx
                  mov si,datasi
                  mov ax,datads
                  mov ds,ax
                  mov bx,3
                  cld
@1:               movsb
                  add si,bx
                  loop @1
                  pop ds
               END;
               Inc(DataSI);
          END;
     END;
END;

FUNCTION SpriteXSize(Sprite:Pointer):Word;
BEGIN
     ASM
        push ds
        lds si,sprite
        lodsw
        inc ax
        mov @result,ax
        pop ds
     END;
END;

FUNCTION SpriteYSize(Sprite:Pointer):Word;
BEGIN
     ASM
        push ds
        lds si,sprite
        lodsw
        lodsw
        inc ax
        mov @result,ax
        pop ds
     END;
END;

FUNCTION SpriteSize(Sprite:Pointer):Word;
BEGIN
     ASM
        push ds
        lds si,sprite
        lodsw
        inc ax
        mov bx,ax
        lodsw
        inc ax
        mul bx
        add ax,4
        mov @result,ax
        pop ds
     END;
END;

PROCEDURE SetWriteMode(M:Byte);
BEGIN
     Port[$3CE]:=$05;
     Port[$3CF]:=(Port[$3CF] AND $FC) OR (M AND 3);
END;

PROCEDURE SetModeNr(Nr:Word);
BEGIN
     ASM
        mov ax,nr
        int $10
     END;
END;

PROCEDURE Set16Pal(Nr:Byte);
VAR
   I:Byte;
BEGIN
     I:=Port[$3DA];
     Port[$3C0]:=$34;
     Port[$3C0]:=Nr;
END;

PROCEDURE Init16Pal;
VAR
   I:Byte;
BEGIN
     I:=Port[$3DA];
     FOR I:=0 TO 15 DO
     BEGIN
          Port[$3C0]:=I;
          Port[$3C0]:=I;
     END;
     Port[$3C0]:=$10;
     Port[$3C0]:=$81;
     Set16Pal(0);
END;

PROCEDURE Init13X;
BEGIN
     MCGAOn;
     Unchain;
END;

PROCEDURE TextMode;
BEGIN
     ASM
        mov ax,3
        int 10h
     END;
END;

PROCEDURE SetLineRepeat(Nr:Byte);
BEGIN
     Port[$3C4]:=9;
     Port[$3C5]:=(Port[$3C5] AND $F0)+Nr;
END;

PROCEDURE SetReadMap(Map:Byte);
BEGIN
     Port[$3C4]:=4;
     Port[$3C5]:=Map;
END;

PROCEDURE DrawLineH4(X1,X2,Y1:Word; C:Byte);
VAR
   Adresse:LongInt;

   PROCEDURE DrawLineH4X(X1,X2,Y1:Word; C:Byte);
   BEGIN
        ASM
           mov ax,$a000
           mov es,ax
           mov ax,[bp+offset y1]
           mov bx,800
           mul bx
           add ax,[bp+offset x1]
           adc dx,0
           mov di,$3cd
           xchg di,ax
           xchg ax,dx
           or al,$40
           out dx,al
           mov bx,[bp+offset x1]
           mov dx,[bp+offset x2]
           inc dx
           mov cx,dx
           sub cx,bx
           shr cx,1
           mov al,[bp+offset c]
           mov ah,al
           ror bx,1
           jnb @2
           stosb
           ror dx,1
           jnb @3
           dec cx
   @3:     rol dx,1
   @2:     rep
           stosw
           ror dx,1
           jnb @4
           stosb
   @4:  END;
   END;

BEGIN
     Adresse:=LongInt(Y1)*800;
     IF (Adresse+X1) SHR 16<>(Adresse+X2) SHR 16 THEN
     BEGIN
          DrawLineH4X(X1,65535-Word(Y1*800),Y1,C);
          DrawLineH4X(Word(-Word(Y1*800)),X2,Y1,C);
     END
     ELSE DrawLineH4X(X1,X2,Y1,C);
END;

PROCEDURE DrawLineV4(X1,Y1,Y2:Word; C:Byte);
VAR
   Adresse:LongInt;
   Y:Word;
   A:Byte;

   PROCEDURE DrawLineV4X(X1,Y1,Y2:Word; C:Byte);
   BEGIN
        ASM
           mov bx,[bp+offset x1]
           mov ax,[bp+offset y1]
           mov cx,800
           mul cx
           add ax,bx
           adc dx,0
           mov di,$3cd
           xchg di,ax
           xchg ax,dx
           or al,$40
           out dx,al
           mov dx,[bp+offset y2]
           mov cx,$a000
           mov es,cx
           mov cx,dx
           sub cx,[bp+offset y1]
           inc cx
           mov al,[bp+offset c]
           mov bx,799
   @2:     stosb
           add di,bx
           loop @2
        END;
   END;

BEGIN
     Y:=Y1;
     WHILE (LongInt(Y)*800+X1) SHR 16<>(LongInt(Y2)*800+X1) SHR 16 DO
     BEGIN
          A:=(LongInt(Y)*800+X1) SHR 16;
          DrawLineV4X(X1,Y,(LongInt(A+1)*65536-1-X1) DIV 800,C);
          Y:=(LongInt(A+1)*65536-1-X1) DIV 800+1;
     END;
     DrawLineV4X(X1,Y,Y2,C);
END;

PROCEDURE SetHorizOfs(Count:Byte);
BEGIN
     Port[$3C0]:=$13;
     Port[$3C0]:=Count SHL 1;
END;

{
PROCEDURE SetReg(Reg:Word; Index,Value:Byte);
VAR
   B:Byte;
BEGIN
     CASE Reg OF
          $3C0:BEGIN
                    B:=Port[$3DA];
                    Port[$3C0]:=Index OR $20;
}
END.
