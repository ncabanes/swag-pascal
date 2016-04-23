
{$G+}
{   Simulador de Campo de Estrellas.        Starfield Simulator
  -------------------------------------|----------------------------
                 Tomas Laurenzo - tlaure@lsa.lsa.com.uy
                            Montevideo - Uruguay
 
  DISCLAIMER: Same as usual, use it at your own risk.
 
  COPYRIGHT: Use it freely, just remember _I_ coded it, BTW the '*' (Big
             Bang Flower) routine will be in a demo i'm coding, and it's
             dedicated to a girl nicknamed Kash, so if you use it, name
             us in the credits, thanks. :)
 
 
  DESCRIPTION:
  This is a simple starfield simulator, with two or three simple routines
  in it, press '?' for help (if you can actually read it >;) ), or just try
  '4','5','0','+','-','*'.. i think that's all, check the code anyway.
  I do use some routines that i've collected for quite awhile.
  I think most of'em are from the SWAG files, and from the Asphyxia VGA
  Trainer by Denthor... which helped me a lot, time ago.
  Sorry, it's not fully optimized, but there are some routines that I do
  not wont to make public yet ;)
 
  Oh, the Big Bang flower in radar mode has a bug... some boxes appear where
  they shouldn't.. help.
  The 'speed < -2' bug is easily fixeable, but I like the 'good bye mon TV'
  effect, and if fixed, the '*' routine would disappear :)
 
  Any comments, suggestions, whatever, _please_ mail.
 
  Salú,
    Tom.
 
 
  P.S. Sorry again, it's not very commented, the procedural names are self
       descriptive, but most of them are in spanish.
       Anyway I think the code should be easy to understand. O:)
       And please oversee my tarzan-style english ;)
 
^`º:;,.,;:º'^`º:;,.,;:º'^`º:;,.,;:º'^`º:;,.,;:º'^`º:;,.,;:º'^`º:;,.,;:º'^`º:;,.
}
 
 
 
PROGRAM Startrek;                         { Yeah, God save the enterprise! }
 
 USES Crt;
 
 CONST CantStars = 1000;   { # of stars }
 
 TYPE
   Observador = RECORD
                   X : Word;
                   Y : Word;
                   Z : Word;
                END;
 
   Colores  = (Blanco, Amarillo, Celeste, Violeta);
 
   Estrella = RECORD
                 X,Y,Z : Word;
              END;
 
   Stars = ARRAY [0..CantStars] OF Estrella;
 
 
 CONST
       VGA = $A000;
       Obs : Observador = (
                          X : 0;
                          Y : 0;
                          Z : 60
                          );
 
 VAR
   CosTable  : ARRAY [0..1024] of Integer;
   Color : Colores;
   AnguloZ : Integer;
   Vel   : ShortInt;
   I     : Byte;
   Campo : Stars;
   Tecla : Char;
   RotoZ,
   Termina,
   Borro : Boolean;
   Cola  : ARRAY [0..CantStars] OF RECORD
                                    X1,Y1,
                                    X2,Y2 : Integer;
                                   END;
 
{............................................................................}
 
 FUNCTION Coseno (Angulo : Integer): Integer; Assembler;
   ASM
    mov  ax,Seg CosTable
    mov  es,ax
    mov  di,Offset CosTable
    mov  dx,Angulo
    shl  dx,1
    add  di,dx
    mov  ax,es:[di]
  END;
 
{............................................................................}
 
  PROCEDURE Proyecta (X, Y, Z :Integer;
                      VAR Xscr, Yscr : Word;
                          XCentro, YCentro : Integer);
 
   BEGIN
    IF Z >= Obs.Z THEN BEGIN
        Xscr := 319;
        Yscr := 200;
    END
    ELSE BEGIN
     Xscr := XCentro + ((Obs.X * Z - X * Obs.Z) div (Z - Obs.Z));
     Yscr := YCentro + ((Obs.Y * Z - Y * Obs.Z) div (Z - Obs.Z));
   END;
  END;
 
{............................................................................}
 
 PROCEDURE MakeCosTable;
 
  VAR
    CntVal : Word;
    CntAng : Real;
    IncDeg : Real;
 
  BEGIN
    IncDeg := 2*PI/1024;
    CntAng := IncDeg;
    CntVal := 0;
    REPEAT
      CosTable [CntVal] := Round(255*cos(CntAng));
      CntAng := CntAng+IncDeg;
      Inc (CntVal);
    UNTIL CntVal > 1024;
 END;
 
{...........................................................................}
 
 FUNCTION Seno (Angulo : Integer): Integer; Assembler;
   ASM
    mov  ax,Seg CosTable
    mov  es,ax
    mov  di,Offset CosTable
    mov  dx,Angulo
    mov  bx,1024
    add  dx,256
    cmp  dx,bx
    jle  @@Ok
    sub  dx,1024
  @@Ok:
    shl  dx,1
    add  di,dx
    mov  ax,es:[di]
  END;
 
{............................................................................}
 
 
  PROCEDURE Modo13h; Assembler;
   ASM
    MOV AX, 13h
    INT 10h
 
{    MOV ah,0fh     Si se quiere que el procedimiento devuelva un errcode
     INT 10h        se le agrega esto, se cambia el proc a func : word
     XOR ah,ah      y si no devuelve 13h ($13) es que no tiene VGA }
 
   END;
 
{............................................................................}
 
  PROCEDURE ModoTexto; Assembler;
   ASM
    MOV ax,03h
    INT 10h
   END;
 
{...........................................................................-}
 
 PROCEDURE Retraso; Assembler;
  ASM
      mov   dx,3DAh
  @@1:
      in    al,dx
      and   al,08h
      jnz   @@1
  @@2:
      in    al,dx
      and   al,08h
      jz    @@2
  END;
{
 BEGIN
  WHILE (PORT[$3da] AND 8)<>0 DO;
  WHILE (PORT[$3da] AND 8)=0 DO;   { Ésta es la implementación pascal   }
{ END;}
 
{............................................................................}
 
  PROCEDURE Cls (Col : Byte; Where:word); assembler;
   ASM
    push    es
    mov     cx, 32000;
    mov     es,[where]
    xor     di,di
    mov     al,[col]
    mov     ah,al
    rep     stosw
    pop     es
   END;
 
{............................................................................}
 
 PROCEDURE PutDot (X,Y : Integer; Color : Byte; SegDes:word); Assembler;
  ASM
   cmp  X,0
   jl   @@END
   cmp  Y,0
   jl   @@END
   cmp  X,319
   jg   @@END
   cmp  Y,199
   jg   @@END
   mov  ax,SegDes
   mov  es,ax
   mov  al,Color
   mov  di,Y
   mov  bx,X
   mov  dx,di
   xchg dh,dl
   shl  di,6
   add  di,dx
   add  di,bx
   mov  es:[di],al
 @@END:
 END;
 
{............................................................................}
 
 PROCEDURE SeteaColor (Col,R,G,B : Byte); assembler;
  ASM
    mov    dx,3c8h
    mov    al,[col]
    out    dx,al
    inc    dx
    mov    al,[r]
    out    dx,al
    mov    al,[g]
    out    dx,al
    mov    al,[b]
    out    dx,al
  END;
 
{--------------------------------------------------------------------------}
 
 PROCEDURE  GeneroPaleta (Tipo : Colores);
  VAR I : Byte;
  BEGIN
   SeteaColor (0,0,0,0);
   CASE Tipo OF
     Blanco   : FOR I := 1 TO 255 DO SeteaColor (I,I,I,I);
     Celeste  : FOR I := 1 TO 255 DO SeteaColor (I,64,I,I);
     Violeta  : FOR I := 1 TO 255 DO SeteaColor (I,I,64,I);
     Amarillo : FOR I := 1 TO 255 DO SeteaColor (I,I,I,64);
  END;
 END;
 
{--------------------------------------------------------------------------}
 
 PROCEDURE GeneroEstrellas;
  VAR  J,
       I : Integer;
  BEGIN
    FOR I := 0 TO CantStars DIV 6 DO BEGIN
       Campo [I].X := Random (320)-160;
       Campo [I].Y := Random (200)-100;
       Campo [I].Z := 0;
       Cola  [I].X1 := Campo [I]. X;
       Cola  [I].Y1 := Campo [I]. Y;
    END;
 
    FOR I := 1 TO 5 DO
      FOR J := (I * CantStars DIV 6) TO (CantStars DIV 6) * (I+1) -1
      DO BEGIN
       Campo [J].X := Random (320)-160;
       Campo [J].Y := Random (200)-100;
       Campo [J].Z := I * 10;
       Cola  [I].X1 := Campo [I]. X;
       Cola  [I].Y1 := Campo [I]. Y;
 
      END;
  END;
 
{--------------------------------------------------------------------------}
 
 PROCEDURE EscriboEstrellas ;
  VAR I : Integer;
      X,Y : Word;
      X1,Y1,Z1,
      X2,Y2,Z2,
      Xr,Yr,Zr : Integer;
 
  BEGIN
   CASE RotoZ OF
    True  : BEGIN
              FOR I := 0 to CantStars DO BEGIN
                X := Campo[I].X;
                Y := Campo[I].Y;
 
                Xr := (Coseno (AnguloZ) * X) div 256
                                  -
                      (Seno (AnguloZ) * Y) div 256;
 
                Yr := (Seno (AnguloZ) * X) div 256
                                  +
                      (Coseno (AnguloZ) * Y) div 256;
 
 
{                Campo [I].X := Xr;
                Campo [I].Y := Yr;}
 
 
                Proyecta (Xr,
                          Yr,
                          Campo[I].Z,
                          X, Y,
                          160,100);
                PutDot (X,Y,Campo[I].Z,VGA);
                Cola [I].X1 := X;
                Cola [I].Y1 := Y;
              END;
              IF AnguloZ > 1024 THEN AnguloZ := AnguloZ - 1024
                                ELSE Inc (AnguloZ,5);
            END;
    False : BEGIN
              FOR I := 0 to CantStars DO BEGIN
 
                Proyecta (Campo[I].X,
                          Campo[I].Y,
                          Campo[I].Z,
                          X, Y,
                          160,100);
                PutDot (X,Y,Campo[I].Z,VGA);
                Cola [I].X1 := X;
                Cola [I].Y1 := Y;
              END;
            END;
    END;
  END;
 
{--------------------------------------------------------------------------}
 
 PROCEDURE BorroEstrellas;
  VAR I : Integer;
 
  BEGIN
    IF Borro THEN BEGIN
     FOR I := 0 to CantStars DO BEGIN
       PutDot (Cola [I].X1, Cola [I].Y1, 0, VGA);
       PutDot (Cola [I].X2, Cola [I].Y2, 0, VGA);
     END;
     Borro := FALSE
     END ELSE Borro := True;
 
  END;
 
{--------------------------------------------------------------------------}
 
 PROCEDURE MuevoEstrellas (Creo : Boolean);
  VAR I : Integer;
  BEGIN
    FOR I := 0 TO CantStars DO BEGIN
 
      Cola [I].X2 := Cola [I].X1;
      Cola [I].Y2 := Cola [I].Y1;
 
 
{}IF Vel > 0 THEN BEGIN
      IF (Cola [I].X1 > 0) and (Cola [I].Y1 > 0) and
         (Cola [I].X1 < 320) and (Cola [I].Y1 < 200) and
         (Campo [I].Z < Obs.Z) THEN Inc (Campo[I].Z,Vel)
      ELSE BEGIN
        IF Creo THEN BEGIN
          Campo [I].X := Random (320)-160;
          Campo [I].Y := Random (200)-100
        END
        ELSE BEGIN
          Campo [I].X := 3000;
          Campo [I].Y := 3000
        END;
        Campo [I].Z := 0;
      END
{}END
  ELSE BEGIN
      IF Campo [I].Z > 0 THEN Inc (Campo[I].Z,Vel)
      ELSE BEGIN
        IF Creo THEN BEGIN
          Campo [I].X := Random (320)-160;
          Campo [I].Y := Random (200)-100
        END
        ELSE BEGIN
          Campo [I].X := 3000;
          Campo [I].Y := 3000
        END;
        Campo [I].Z := Obs.Z + 1
      END
{}END
 
    END
  END;
 
{--------------------------------------------------------------------------}
 
 PROCEDURE Bouncing; { Not really, it's the Big Bang Flower }
  Var VT : ShortInt;
      I  : Byte;
      J  : Integer;
  BEGIN
   VT := Vel;
   Vel := -1;
   FOR I := 1 to 20 do BEGIN
    FOR J := 0 to CantStars DO BEGIN
      Campo [J].Z := Campo[J].Z -1 ;
    END;
    EscriboEstrellas;
   END;
   Vel := VT;
  END;
 
{--------------------------------------------------------------------------}
 
 PROCEDURE Lluvia;  { Rain }
  VAR  J, I : Integer;
       Pant : ARRAY [0..CantStars] OF RECORD X,Y,Z : Word; END;
 
   FUNCTION HayPant : BOOLEAN;
    VAR I : Integer; Hay : Boolean;
    BEGIN
      Hay := False;
      FOR I := 0 to CantStars DO IF Pant[I].Y < 200 THEN Hay := True;
      HayPant := Hay;
    END;
 
    PROCEDURE EscriboPant;
     VAR I : Integer;
      BEGIN FOR I := 0 to CantStars do PutDot (Pant[I].X,
                                               Pant[I].Y,
                                               Pant[I].Z,
                                               VGA);
      END;
 
     PROCEDURE MuevoPant;
      VAR I : Integer;
      BEGIN FOR I := 0 to CantStars DO
           IF Pant[I].Z > 10 THEN Pant[I].Y := Pant[I].Y + Pant[I].Z div 8
                             ELSE Pant[I].Y := Pant[I].Y +1 ;
      END;
 
    PROCEDURE BorroPant (Inc : ShortInt);
     VAR I : Integer;
     BEGIN FOR I := 0 to CantStars do PutDot (Pant[I].X,
                                              Pant[I].Y+Inc,
                                              0,
                                              VGA);
     END;
 
  BEGIN
   Cls (0,VGA);
   FOR I := 0 to CantStars DO BEGIN
        Proyecta (Campo[I].X,
                  Campo[I].Y,
                  Campo[I].Z,
                  Pant[I].X,
                  Pant[I].Y,
                  160,100);
         Pant[I].Z := Campo[I].Z;
 
   END;
   WHILE HayPant DO BEGIN
     EscriboPant;
     Retraso;
     BorroPant (0);
     MuevoPant;
   END;
  END;
 
{--------------------------------------------------------------------------}
 
 PROCEDURE Help;
 
  PROCEDURE Escribo (S : String; Salto : Boolean);
   VAR I : Byte;
 
   BEGIN
     GotoXY (40 - Length (S) DIV 2, WhereY);
     FOR I := 1 TO Length (S) DO BEGIN
       TextColor (Random (15)+1);
       Write (S[I]);
     END;
     IF Salto THEN WriteLn;
   END;
 
  PROCEDURE Apagacursor; Assembler;  { Sets the cursor off }
   ASM
     MOV AH, 02h
     MOV BH, 0
     MOV DH, 80
     MOV DL, 25
     INT 10h
   END;
 
 
 BEGIN
   ModoTexto;
   REPEAT
    ClrScr;
    Escribo ('Simulador de Campo de Estrellas',True);
    Escribo ('(Starfield Simulator)',True);
    Escribo ('---------------------------------',True);
    Escribo ('1996 · Tomas Laurenzo · tlaure@lsa.lsa.com.uy',True);
    WriteLn;
    Escribo ('Teclas (keys):',True);
    WriteLn;
    Escribo (' ? : Esta pantalla          · This screen     ',True);
    Escribo (' + : Aumenta la velocidad   · Increases speed ',True);
    Escribo (' - : Disminuye la velocidad · Decreases speed ',True);
    Escribo (' 0 : Rota los colores       · Rotate colors   ',True);
    Escribo (' 1 : Lluvia                 · Rain            ',True);
    Escribo (' 5 : Modo radar             · Radar mode      ',True);
    Escribo (' 4 : Modo normal            · Normal mode     ',True);
    Escribo ('  spc : Rebote                 · Bounce             ',True);
    Escribo (' * : Flor de Big Bang ;)   · Big Bang Flower',True);
    WriteLn;
    Escribo ('Archivos (files):',True);
    Escribo ('CAMPO.EXE | CAMPO.TXT',True);
    WriteLn;
    Escribo ('Tomas Laurenzo · tlaure@lsa.lsa.com.uy · Montevideo - Uruguay',True);
    WriteLn;   Escribo (' IF Speed < -1 THEN Quite_A_Bug (ON)  a.k.a.  Good Bye mon T.V.',True);
    WriteLn;
    Escribo ('^`º:;,.,;:º''^`º:;,.,;:º''^`º:;,.,;:º''^`º:;,.,;:º''^`º:;,.,;:º''^`º:;,.,;:º''^`º:;,.',False);
    ApagaCursor;
    Delay (500);
   UNTIL keypressed;
   ReadKey;
   Modo13h;
   GeneroPaleta (Color);
  END;
 
 
 
{--------------------------------------------------------------------------
                               Principal
 --------------------------------------------------------------------------}
                                {main}
 BEGIN
   Randomize;
   MakeCosTable;
   GeneroEstrellas;
   AnguloZ := 0;
   Modo13h;
   GeneroPaleta (Blanco);
   Cls (0,VGA);
   Borro := False;
   Vel := 1;
   Termina := False;
 
   REPEAT
    EscriboEstrellas;
    Retraso;
    BorroEstrellas;
    MuevoEstrellas(True);
 
    IF KeyPressed THEN BEGIN
      Tecla := ReadKey;
      CASE Tecla OF
      '?' : Help;
      '+' : Inc (Vel);
      '-' : Dec (Vel);
      '0' : BEGIN
              IF Color = Violeta THEN Color := Blanco
                                 ELSE Inc (Color);
              GeneroPaleta (Color)
            END;
      '1' : Lluvia;
      '5' : RotoZ := True;
      '4' : RotoZ := False;
      ' ' : Vel := - Vel;
      '*' : BEGIN
              WHILE NOT KEYPRESSED DO Bouncing;
              CLS (0, VGA);
              ReadKey;
            END;
 
 
      ELSE Termina := True;
      END;
    END;
 
   UNTIL Termina;
 
   IF Vel <> 0 THEN
    FOR I := 0 TO 50 div Abs(Vel) DO BEGIN
     EscriboEstrellas;
     Retraso;
     BorroEstrellas;
     MuevoEstrellas(False);
    END;
   ModoTexto;
 END.

