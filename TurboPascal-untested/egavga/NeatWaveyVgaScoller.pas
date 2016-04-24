(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0169.PAS
  Description: Neat Wavey VGA Scoller
  Author: JEROEN BOUWENS
  Date: 11-26-94  04:59
*)

{
Hmmm, this is a small, but neat routine. Really something to post. I hope you
like it. Made by Jeroen Bouwens, Holland. This routine is PD, Freeware and
Smileware, which means bla..blabla...blablabla. Got it? See ya! :-)

O Yeah, I nearly forgot. It is a perspective scroller that comes right at you.
}
Uses Crt;

Var
  I,J,XS,YS,TL,EP,AD,XT,YT,ZY         : Integer;
  Alpha,Beta,Gamma,G,Tel              : Integer;
  XX,YY,ZZ,BX,BY                      : Integer;
  Exists                              : Boolean;
  Tof,TSeg,SL,ArrayTel,Lof            : Word;
  VX,VY,VZ                            : Real;
  XT1,YT1,ZT1                         : Real;
  Offsets                             : Array[0..160*50] Of Word;
  Colors                              : Array[0..160*50] Of Byte;
  Cosinus,Sinus                       : Array [0..360] of Real;
  Tekst                               : String;

Procedure Rotate(Var X,Y,Z:Real;Alpha,Beta,Gamma:Integer);
Var X1,X2,Y1,Y2,Z1,Z2 : Real;
Begin
  X1:=X;
  Y1:=Cosinus[Alpha]*Y-Sinus[Alpha]*Z;
  Z1:=Sinus[Alpha]*Y+Cosinus[Alpha]*Z;
  X2:=Cosinus[Beta]*X1+Sinus[Beta]*Z1;
  Y2:=Y1;
  Z2:=Cosinus[Beta]*Z1-Sinus[Beta]*X1;
  X:=Cosinus[Gamma]*X2-Sinus[Gamma]*Y2;
  Y:=Sinus[Gamma]*X2+Cosinus[Gamma]*Y2;
  Z:=Z2;
End;{Rotate}

Procedure PrecalcPoints;
Begin
  For I:=0 To 360 Do Begin
    Cosinus[I]:=Cos(I/57.29578);
    Sinus[I]:=Sin(I/57.29578);
  End;
  G:=250;{Find some well working value for this (250 is fine for VZ=300) }
  Alpha:=320; Beta:=310; Gamma:=330;{Change these for an other orientation of
                                     the scroll}
  VX:=0; VY:=0; VZ:=300;             {Don't make VZ 0 -> division by zero!!}
  XX:=-160; YY:=-25; ZZ:=0;
  For I:=1 To 160*50 do Begin
    XT1:=XX; YT1:=YY; ZT1:=Cos(XX/10)*2+Sin(YY/5)*2; {Play with these!}
    Colors[I]:=Round(ZT1*3+44);
    Rotate(XT1,YT1,ZT1,Alpha,Beta,Gamma);
    BX:=160+Round((XT1*G)/(ZT1+VZ));
    BY:=100+Round((YT1*G*0.8333)/(ZT1+VZ));
    Offsets[I]:=320*BY+BX;
    Mem[$A000:Offsets[I]]:=15;
    Inc(YY);
    If YY>=24  Then Begin
      YY:=-25;
      XX:=XX+2;{Also change size of arrays:Offsets,Colors if you change this}
      If XX>=159 Then Begin XX:=-160; YY:=-25; End;
    End;
  End;
  FillChar(Mem[$A000:0],64000,0);
End;

Begin
  Asm Mov AX,$13; Int $10 End;
  PrecalcPoints;
  Tekst:='                    '+
         'Well, this is an interesting routine (and it seems to work too '+
         ':-)                    ';
  TOf:=Ofs(Tekst); TSeg:=Seg(Tekst);
  Tel:=0;
  Repeat
    For TL:=0 To 7 Do Begin
      ArrayTel:=8*49+1;
      For I:=1 To 19 Do Begin
        SL:=Mem[TSeg:TOf+I+Tel];
        LOf:=$FA6E+SL*8;
        For XS:=0 To 7 Do Begin
          For YS:=1 To 8 Do Begin
            If (Mem[$F000:LOf] And (128 Shr XS))<>0 Then Begin
              Mem[$A000:Offsets[ArrayTel-TL*49]]:=Colors[ArrayTel-TL*49];
              Mem[$A000:Offsets[ArrayTel+1-TL*49]]:=Colors[ArrayTel-TL*49];
              Mem[$A000:Offsets[ArrayTel+2-TL*49]]:=Colors[ArrayTel-TL*49];
              Mem[$A000:Offsets[ArrayTel+3-TL*49]]:=Colors[ArrayTel-TL*49];
              Mem[$A000:Offsets[ArrayTel+4-TL*49]]:=Colors[ArrayTel-TL*49];
              Mem[$A000:Offsets[ArrayTel+5-TL*49]]:=Colors[ArrayTel-TL*49];
            End Else Begin
              Mem[$A000:Offsets[ArrayTel-TL*49]]:=0;
              Mem[$A000:Offsets[ArrayTel+1-TL*49]]:=0;
              Mem[$A000:Offsets[ArrayTel+2-TL*49]]:=0;
              Mem[$A000:Offsets[ArrayTel+3-TL*49]]:=0;
              Mem[$A000:Offsets[ArrayTel+4-TL*49]]:=0;
              Mem[$A000:Offsets[ArrayTel+5-TL*49]]:=0;
            End;
            Inc(Lof);
            Inc(ArrayTel,6);
          End;
          Dec(Lof,8);
          Mem[$A000:Offsets[ArrayTel-TL*49]]:=0;
          Inc(ArrayTel);
        End;
      End;
    End;
    Inc(Tel); If Tel>=Length(Tekst)-20 Then Tel:=0;
  Until KeyPressed;
End.


