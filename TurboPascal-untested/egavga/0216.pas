{
From: JUSTIN GREER

> I have recently coded a program that gives a three layer starfield
> moving only accross the monitor.  I am looking for some code that
> will give a 'warp' kinda feeling. (The stars coming at you, like that
> windows screen saver.)  Any help, even just some mathematics would be
> greatly appriciated.
> Thanks

Well, a while ago I wrote one of these that seems to work real well...
I just spent a half-hour or so doing it, because the only ones I had
were in future crew type demos, and I wanted a screen saver one... Here
ya' go:

Here's a program I've been working on a little lately--It shows
a 3D star field with 256 colors used.  I haven't seen this particular
type of star program anywhere outside of demos and things, and I thought
it might be helpful.  I haven't had time to really optimize it yet,
and it is pretty math-intensive, so it's not the fastest thing in the
world (even though it's a little too fast on my 486dx2/66 =|).
You can shange most of the variables in the program for different
effects--Things like the maximum stars and stuff.  I am running TP7, and
I have not tried this with other versions, but it should work fine
as far as I know.
}

{$G+,N+}
PROGRAM TPSTARS;
USES CRT;
VAR
  STD,SCRNX,SCRNY,SCRNC,Z:ARRAY [1..200] OF WORD;
  X,Y:ARRAY [1..200] OF INTEGER;
  I:WORD;


PROCEDURE INIT;
BEGIN
  FOR I := 1 TO 200 DO
    BEGIN
      X [I] := RANDOM(1000)-500;
      Y [I] := RANDOM(800)-400;
      Z [I] := RANDOM(1846)+202;
      STD [I] := ROUND(SQR(X[I])+SQR(Y[I]));
    END;
  ASM
    MOV AX,013H
    INT 10H
  END;
  PORT[$3C8]:=1;
  FOR I := 1 TO 255 DO
    BEGIN
      PORT[$3C9]:=ROUND((256-I)/4);
      PORT[$3C9]:=ROUND((256-I)/4);
      PORT[$3C9]:=ROUND((256-I)/4);
    END;
END;
PROCEDURE RESETSTAR;
 BEGIN
  Z[I]:=2048;
  X[I]:=RANDOM(1000)-500;
  Y[I]:=RANDOM(800)-400;
  STD [I] := ROUND(SQR(X[I])+SQR(Y[I]));
END;
PROCEDURE CLOSEDOWN;ASSEMBLER;
ASM
  MOV AX,003H
  INT 10H
END;
PROCEDURE MOVESTARS;
BEGIN
  repeat
  FOR I := 1 TO 200 DO
    BEGIN
      mem [$a000:(scrny[i] shl 8+ scrny[i] shl 6)+scrnx[i]]:=0;
      dec(Z[I]);{:=Z[I]-1;}
      IF Z[I] < 2 THEN RESETSTAR;
      SCRNX[I]:=(300*X[I]) DIV Z[I]+160;
      SCRNY[I]:=(300*Y[I]) DIV Z[I]+100;
      IF SCRNX[I] > 319 THEN RESETSTAR;
      IF SCRNY[I] > 199 THEN RESETSTAR;
       IF SCRNX[I] < 0 THEN RESETSTAR;
      IF SCRNY[I] < 0 THEN RESETSTAR;
      SCRNC[I]:=Round(SQRT(SQR(Z[I])+STD[I]) / 9)+1;
      mem [$a000:(scrny[i] shl 8+ scrny[i] shl 6)+scrnx[i]]:=scrnc[i];
    END;
  UNTIL Keypressed;
END;
BEGIN
  INIT;
  MOVESTARS;
  CLOSEDOWN;
END.
