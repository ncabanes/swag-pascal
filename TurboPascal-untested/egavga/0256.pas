{ In Procdures FADEIN & FADEOUT, the (X) is the delay between
  screen darkenings. }

 Unit Fade;
 Interface

   Uses Crt;

   Const
     PelAddrRgR  = $3C7;
     PelAddrRgW  = $3C8; {.$3C8}
     PelDataReg  = $3C9;

   Type
     RGB = Record                   
             R,                     
             G,
             B : Byte;
           End;
   Color = Array [0..63] Of RGB;

   Var
     Col : Color;           


   Procedure GetCol(C : Byte; Var R, G, B : Byte);
   Procedure SetCol(C, R, G, B : Byte);
   Procedure SetInten(B : Byte);
   Procedure FadeIn (X:Integer);
   Procedure FadeOut (X:Integer);

 Implementation



Procedure GetCol(C : Byte; Var R, G, B : Byte);
Begin
  Port[PelAddrRgR] := C;
  R := Port[PelDataReg];
  G := Port[PelDataReg];
  B := Port[PelDataReg];
End;

Procedure SetCol(C, R, G, B : Byte);
Begin
  Port[PelAddrRgW] := C;
  Port[PelDataReg] := R;
  Port[PelDataReg] := G;
  Port[PelDataReg] := B;
End;

Procedure SetInten(b : Byte);
 Var
   I : Integer;
   FR, FG, FB : Byte;
 Begin
   For I:=0 To 63 Do
   Begin
     FR:=Col[I].R*B Div 63;
     FG:=Col[I].G*B Div 63;
     FB:=Col[I].B*B Div 63;
     SetCol(I, FR, FG, FB);
   End;
 End;

Procedure FadeIn (X:Integer);
 Var
   Y:Integer;           (* Y is the LCV *)
 Begin
   For Y:=0 To 63 Do
     Begin
       SetInten(Y);
       Delay(X);
     End;
 End;

Procedure FadeOut (X:Integer);
 Var
   Y:Integer;    (* Y is the LCV *)
 Begin
   For Y:=0 To 63 Do
     GetCol(Y, Col[Y].R, Col[Y].G, Col[Y].B);
   For Y:=63 DownTo 0 Do
     Begin
       SetInten(Y);
       Delay(X);
     End;
 End;
End.

