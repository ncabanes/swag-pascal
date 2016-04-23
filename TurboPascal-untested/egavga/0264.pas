{
Ok, here it is. A freeware 100% pascal phongshading program. No extra units
are required. Just extract the program, and run it. I wrote it in bp 7, but I
assume it will work in lower versions as well.A few remarks: 
1) The 'phong-map' is pretty crappy, so it looks a bit like gouraudshading
   (Trust me, it's not :-).
2) Don't tell me it's slow, I know that (My latest routines are 6 times
   faster).
3) Feel free to use it anywhere you want, and spread it if you want.
4) Comments are appreciated, as long as they are positive :-).

I wrote this version exclusively for this purpose, and removing the need for
extra units or external files wasn't easy (Look at CreateTorusData, it was a
real pain in the ...). I might post another program in the future calculate
phong-maps using the complete phong-model, which looks a zillion times better.
But don't count on it. Just an idea: You can try to use the texture-map
routine from gfxfx2 to speed it up. I haven't tried it, but it should be
possible. Last words: Have fun.

>--->---Cut here--->--->

{Freeware phong-shading routine. Spread it if you want. Credit me if you
use it. Made by Jeroen Bouwens, The Netherlands.
Mail me:

e-mail : j.bouwens@tn.ft.hse.nl (Preferred)
Fido   : 2:284/123.3

Greets: Alex,Rob,Martijn,Maarten,Bas,Sean,Richard,Marcel,Jurjen,Michel,
        Sonja,N-Faktor and all the other people I met at Wired (Cool party)}

Uses Crt;{$R- $Q-}

Var Faces                                : Array [1..320,1..3] Of Integer;
    FNX,FNY,FNZ,Pind,PolyZ               : Array [1..320] Of Integer;
    BX,BY,BZ,UT,VT,X,Y,Z,NX,NY,NZ        : Array [1..160] of Integer;
    Cosinus,Sinus                        : Array [0..255] of LongInt;
    Pict,Screen2                         : Pointer;
    NumOfVerts,NumOfFaces,EyeDist,VirSeg : Word;
    I,J,G,NumVisible,XT1,YT1,ZT1         : Integer;
    Alpha,Beta,Gamma,K                   : Byte;
    {Timer variables}Time                : Longint ABSOLUTE $0040:$006C;
    T1,Aantal                            : LongInt;

{------Procedures that are not time-critical (Not used during rotation)------}

Procedure Palette(ColNum,R,G,B:Byte); Assembler;
Asm Mov dx,$3c8; Mov al,ColNum; Out dx,al; Inc dx; Mov al,R;
    Out dx,al; Mov al,G; Out dx,al; Mov al,B; Out dx,al End;

Procedure CalcVertexNormals;
{Calculate the average normal vector at each vertex-point}
Var I,J,NF                                 : Integer;
    RelX1,RelY1,RelZ1,RelX2,RelY2,RelZ2,VL : Real;
Begin
  {In which face is each point used, and average these face-normals}
  For I:=1 To NumOfVerts Do Begin
    RelX1:=0; RelY1:=0; RelZ1:=0; NF:=0;
    For J:=1 To NumOfFaces Do Begin
      If (Faces[J,1]=I) Or (Faces[J,2]=I) Or (Faces[J,3]=I) Then Begin
        RelX1:=RelX1+FNX[J]; RelY1:=RelY1+FNY[J]; RelZ1:=RelZ1+FNZ[J];
        Inc(NF);
      End;
    End;
    If NF<>0 then Begin
      RelX1:=RelX1/NF; RelY1:=RelY1/NF; RelZ1:=RelZ1/NF;
      VL:=Sqrt(RelX1*RelX1+RelY1*RelY1+RelZ1*RelZ1);
      NX[I]:=Round((RelX1/VL)*120); NY[I]:=Round((RelY1/VL)*120);
      NZ[I]:=Round((RelZ1/VL)*120);
    End;
  End;
End;{CalcVertexNormals}

Procedure CreateTorusData;
Var HorAngle,VertAngle,Count       : Integer;
    CX,CY,RX1,RY1,RZ1,RX2,RY2,RZ2  : Real;
Begin

  NumOfVerts:=160; NumOfFaces:=320; Count:=1;
  For HorAngle:=0 To 15 Do Begin{Calculate vertex-positions}
    CX:=Cos(HorAngle/2.546479089)*170;
    CY:=Sin(HorAngle/2.546479089)*170;
    For VertAngle:=0 To 9 Do Begin
      X[Count]:=Round(CX+Cos(VertAngle/1.592)*Cos(HorAngle/2.546)*90);
      Y[Count]:=Round(CY+Cos(VertAngle/1.592)*Sin(HorAngle/2.546)*90);
      Z[Count]:=Round(Sin(VertAngle/1.59154931)*90);
      Inc(Count);
    End;
  End;

  Count:=1;
  For HorAngle:=0 To 15 Do{Store face-data (Which veticies form which face}
    For VertAngle:=0 To 9 Do Begin
      Faces[Count,3]:=HorAngle*10+VertAngle+1;
      Faces[Count,2]:=HorAngle*10+(VertAngle+1) Mod 10+1;
      Faces[Count,1]:=(HorAngle*10+VertAngle+10) Mod 160+1;
      Inc(Count);
      Faces[Count,3]:=HorAngle*10+(VertAngle+1) Mod 10+1;
      Faces[Count,2]:=(HorAngle*10+(VertAngle+1) Mod 10+10) Mod 160+1;
      Faces[Count,1]:=(HorAngle*10+VertAngle+10) Mod 160+1;
      Inc(Count);
    End;

  For Count:=1 To 320 Do Begin{Calculate and store face-normals}
    RX1:=X[Faces[Count,2]]-X[Faces[Count,1]];
    RY1:=Y[Faces[Count,2]]-Y[Faces[Count,1]];
    RZ1:=Z[Faces[Count,2]]-Z[Faces[Count,1]];
    RX2:=X[Faces[Count,3]]-X[Faces[Count,1]];
    RY2:=Y[Faces[Count,3]]-Y[Faces[Count,1]];
    RZ2:=Z[Faces[Count,3]]-Z[Faces[Count,1]];
    FNX[Count]:=Round(RY1*RZ2-RY2*RZ1);
    FNY[Count]:=Round(RZ1*RX2-RZ2*RX1);
    FNZ[Count]:=Round(RX1*RY2-RX2*RY1);
  End;
End;{CreateTorusData}

Procedure Initialize;
Begin

  Asm Mov ax,$13; Int $10 End;
  GetMem(Screen2,64000);
  VirSeg:=Seg(Screen2^);

  CreateTorusData;
  CalcVertexNormals;

  For I:=0 To 255 Do Begin
    Cosinus[I]:=Round(Cos(I/40.585707465)*128);
    Sinus[I]:=Round(Sin(I/40.585707465)*128);
  End;

  GetMem(Pict,65535);
  {Palette-creation. Skip this one to see the non-lineair colour transition}
  For I:=1 To 63 Do Palette(I,I,10+Round(I/1.4),20+Round(I/1.6));
  {Here, the 'phong-map' as I call it is created. Normally I use a different
   routine for that (Looks WAY better), but that one is too big}
  For I:=0 To 255 Do For J:=0 To 255 Do Begin
    Mem[Seg(Pict^):Ofs(Pict^)+Word(256*I)+J]:=
        Round(Sqr(Sqr(Sin(I/81.487)))*Sqr(Sqr(Sin(J/81.487)))*62)+1;
    {Just to show you how it looks:   }
    Mem[$A000:320*Round(I/1.25)+J]:=Mem[Seg(Pict^):Ofs(Pict^)+Word(256*I)+J];
  End;

End;{Initialize}

{----------Procedures that are time-critical (Used during rotation)----------}
Procedure SwapScreen; Assembler;
Asm Mov dx,$3DA; @@WaitVBL: In al,dx; and al,8; jz @@WaitVBL; Push ds;
    Lds  si,Screen2; Mov  ax,$A000; Mov  es,ax; Xor  di,di;  Mov  cx,16000;
    db $66; Rep  Movsw; Pop  ds End;

Procedure Cls(Var Where); Assembler;
Asm Les di,Where; Mov cx,16000; db $66; Xor ax,ax; db $66; Rep Stosw; End;

Procedure Quicksort(Hi : Integer);
Procedure Sort(L,R : Integer);
Var I,J,X,Y : Integer;
Begin
  I:=L; J:=R; X:=PolyZ[(L+R) Div 2];
  Repeat
    While polyz[i]>x do inc(i); While x>polyz[j] do dec(j);
    If I<=J Then Begin
      Y:=PolyZ[I]; PolyZ[I]:=PolyZ[J]; PolyZ[J]:=Y;
      Y:=Pind[I]; Pind[I]:=Pind[J]; Pind[J]:=Y;
      Inc(I); Dec(J);
    End;
  Until I>J;
  If L<J Then Sort(L,J); If I<R Then Sort(I,R);
End;
Begin Sort(1,Hi) End;{QuickSort}

Procedure NewTex(X1,Y1,U1,V1,X2,Y2,U2,V2,X3,Y3,U3,V3:Integer;Texture:Pointer);
{The actual texture-map routine. Only a little commented :-}
Var TexOfs                                       : Array [0..320] Of Word;
    SO,Long                                      : Word;
    XL,UL,VL,XR,UR,VR                            : Array [0..200] Of LongInt;
    DY21,DY31,DY32,DX21,DX31,DX32,DU21,DU31,DU32 : LongInt;
    DV21,DV31,DV32,U,V,I,J,K                     : LongInt;
Begin

  {Sort for increasing y-coordinates}
  For I:=1 To 2 Do Begin
    If Y3<Y2 Then Begin
      J:=Y3; Y3:=Y2; Y2:=J; J:=X3; X3:=X2; X2:=J;
      J:=U3; U3:=U2; U2:=J; J:=V3; V3:=V2; V2:=J; End;
    If Y2<Y1 Then Begin
      J:=Y1; Y1:=Y2; Y2:=J; J:=X1; X1:=X2; X2:=J;
      J:=U1; U1:=U2; U2:=J; J:=V1; V1:=V2; V2:=J; End;
    If Y3<Y1 Then Begin
      J:=Y1; Y1:=Y3; Y3:=J; J:=X1; X1:=X3; X3:=J;
      J:=U1; U1:=U3; U3:=J; J:=V1; V1:=V3; V3:=J End
  End;

  {Exception occurs when there are two top y-coords with the same value}
  If (Y1=Y2) And (X1>X2) Then Begin
    J:=X1; X1:=X2; X2:=J; J:=U1; U1:=U2; U2:=J; J:=V1; V1:=V2; V2:=J End;

  {Calculate X,U and V along the edges and store these}
DY21:=Y2-Y1; DY31:=Y3-Y1; DY32:=Y3-Y2; DX21:=X2-X1; DX31:=X3-X1; DX32:=X3-X2;
DU21:=U2-U1; DU31:=U3-U1; DU32:=U3-U2; DV21:=V2-V1; DV31:=V3-V1; DV32:=V3-V2;
  XL[0]:=X1; XL[0]:=XL[0]*256; UL[0]:=U1;
  UL[0]:=UL[0]*256; VL[0]:=V1; VL[0]:=VL[0]*256;
  If Y1=Y2 Then Begin
    XR[0]:=X2; XR[0]:=XR[0]*256; UR[0]:=U2; UR[0]:=UR[0]*256;
    VR[0]:=V2; VR[0]:=VR[0]*256 End Else Begin
    XR[0]:=XL[0]; UR[0]:=UL[0]; VR[0]:=VL[0]; End;
  For I:=Y1+1 To Y2 Do Begin
    XL[I-Y1]:=XL[I-Y1-1]+(DX31*256) Div DY31;
    XR[I-Y1]:=XR[I-Y1-1]+(DX21*256) Div DY21;
    UL[I-Y1]:=UL[I-Y1-1]+(DU31*256) Div DY31;
    UR[I-Y1]:=UR[I-Y1-1]+(DU21*256) Div DY21;
    VL[I-Y1]:=VL[I-Y1-1]+(DV31*256) Div DY31;
    VR[I-Y1]:=VR[I-Y1-1]+(DV21*256) Div DY21;
  End;
  For I:=Y2+1 To Y3 Do Begin
    XL[I-Y1]:=XL[I-Y1-1]+(DX31*256) Div DY31;
    XR[I-Y1]:=XR[I-Y1-1]+(DX32*256) Div DY32;
    UL[I-Y1]:=UL[I-Y1-1]+(DU31*256) Div DY31;
    UR[I-Y1]:=UR[I-Y1-1]+(DU32*256) Div DY32;
    VL[I-Y1]:=VL[I-Y1-1]+(DV31*256) Div DY31;
    VR[I-Y1]:=VR[I-Y1-1]+(DV32*256) Div DY32;
  End;

  {Calculate texture-offsets for longest horizontal line (at Y=Y2)}
  Long:=Y2-Y1;
  If XL[Long]<XR[Long] Then Begin
    U:=UL[Long]; V:=VL[Long]; SO:=256*(V Shr 8)+(U Shr 8);
    For I:=0 To XR[Long] Shr 8-XL[Long] Shr 8 Do Begin
      TexOfs[I]:=256*(V Shr 8)+(U Shr 8)-SO;
      U:=U+((UR[Long]-UL[Long])*256) Div (XR[Long]-XL[Long]+1);
      V:=V+((VR[Long]-VL[Long])*256) Div (XR[Long]-XL[Long]+1);
    End;
  End Else Begin
    U:=UR[Long]; V:=VR[Long]; SO:=256*(V Shr 8)+(U Shr 8);
    For I:=0 To XL[Long] Shr 8-XR[Long] Shr 8 Do Begin
      TexOfs[I]:=256*(V Shr 8)+(U Shr 8)-SO;
      U:=U+((UL[Long]-UR[Long])*256) Div (XL[Long]-XR[Long]+1);
      V:=V+((VL[Long]-VR[Long])*256) Div (XL[Long]-XR[Long]+1);
    End;
  End;

  {Fill polygon (=Read back X,U and V-coordinates from buffer) }
  If XL[Long]<XR[Long] Then
    For I:=0 To Y3-Y1 Do Begin
      SO:=256*(VL[I] Shr 8)+(UL[I] Shr 8);
      For J:=XL[I] Shr 8 To XR[I] Shr 8 Do
        Mem[VirSeg:320*(I+Y1)+J]:=Mem[Seg(Texture^):Ofs(Texture^)+SO+
                                      TexOfs[J-XL[I] Shr 8]]
    End
  Else
    For I:=0 To Y3-Y1 Do Begin
      SO:=256*(VR[I] Shr 8)+(UR[I] Shr 8);
      For J:=XR[I] Shr 8 To XL[I] Shr 8 Do
        Mem[VirSeg:320*(I+Y1)+J]:=Mem[Seg(Texture^):Ofs(Texture^)+SO+
                                      TexOfs[J-XR[I] Shr 8]]
    End;
End;{NewTex}

Procedure Rotate(Var X,Y,Z:Integer;Alpha,Beta,Gamma:Byte);
Var X2,X3,Y1,Y3,Z1,Z2 : Integer;
Begin
  Y1:=(Cosinus[Alpha]*Y-Sinus[Alpha]*Z) Div 128;
  Z1:=(Sinus[Alpha]*Y+Cosinus[Alpha]*Z) Div 128;
  X2:=(Cosinus[Beta]*X+Sinus[Beta]*Z1) Div 128;
  Z:=(Cosinus[Beta]*Z1-Sinus[Beta]*X) Div 128;
  X:=(Cosinus[Gamma]*X2-Sinus[Gamma]*Y1) Div 128;
  Y:=(Sinus[Gamma]*X2+Cosinus[Gamma]*Y1) Div 128;
End;{Rotate}

{--------------------------Main program-------------------------------------}

Begin

  Initialize; EyeDist:=150; Alpha:=0; Beta:=0; Gamma:=0;
  Aantal:=0; T1:=Time;
  Repeat
    Cls(Screen2^);

    For I:=1 To NumOfVerts do Begin
      {Rotate the vertex-coordinates}
      XT1:=X[I]; YT1:=Y[I]; ZT1:=Z[I];
      Rotate(XT1,YT1,ZT1,Alpha,Beta,Gamma);
      Inc(ZT1,468);
      BX[I]:=160+(XT1*EyeDist) Div ZT1;
      BY[I]:=100+((YT1*EyeDist*83) Div 100) Div ZT1;
      BZ[I]:=ZT1;
      {Rotate vertex normals (Here's where the phong-shading is done}
      XT1:=NX[I]; YT1:=NY[I]; ZT1:=NZ[I];
      Rotate(XT1,YT1,ZT1,Alpha,Beta,Gamma);
      UT[I]:=128+XT1; VT[I]:=128+YT1;
    End;

    {Sort the polygons by z-value, so I know in which order to draw them}
    NumVisible:=0;
    For I:=1 to NumOfFaces Do
      If (BX[Faces[I,3]]-BX[Faces[I,1]])*(BY[Faces[I,2]]-BY[Faces[I,1]])-
      (BX[Faces[I,2]]-BX[Faces[I,1]])*(BY[Faces[I,3]]-BY[Faces[I,1]])>0 Then
      Begin
        Inc(NumVisible); Pind[NumVisible]:=I;
        PolyZ[NumVisible]:=BZ[Faces[I,1]]+BZ[Faces[I,2]]+BZ[Faces[I,3]];
      End;

    QuickSort(NumVisible);

    {Draw the object}
    For I:=1 To NumVisible Do
      NewTex(BX[Faces[Pind[I],1]],BY[Faces[Pind[I],1]],
             UT[Faces[Pind[I],1]],VT[Faces[Pind[I],1]],
             BX[Faces[Pind[I],2]],BY[Faces[Pind[I],2]],
             UT[Faces[Pind[I],2]],VT[Faces[Pind[I],2]],
             BX[Faces[Pind[I],3]],BY[Faces[Pind[I],3]],
             UT[Faces[Pind[I],3]],VT[Faces[Pind[I],3]],Pict);

    Alpha:=(Alpha+2)Mod 256;Beta:=(Beta+255)Mod 256;Gamma:=(Gamma+1)Mod 256;
    Inc(Aantal); SwapScreen;
  Until KeyPressed;

  T1:=Time-T1; TextMode(LastMode);
  WriteLn(Aantal/(T1/18.2) :1:2,' Frames per second');
  ReadLn; Dispose(Pict);Dispose(Screen2);
End.
