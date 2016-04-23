

PROGRAM TEXT_AMI_BIOS_PASSWORD_FINDER;

{

  Eduardo Motta Buhrnheim (Mingo)
  MAY/1997

  mingo@n3.com.br
  buhrn@dadosnet.com.br
  mingus@n3.com.br

  Mingus Production
  P.O.Box, 3159,
  Manaus, Amazonas,
  Brazil,
  69001-970.

}


USES DOS,CRT;

VAR
BYTEBUFFER:ARRAY [0..6] OF BYTE;
SENHA:STRING[6];
A,I,CARAC,PREVIO,TMPA,TMPB:WORD;

BEGIN
WRITELN;
TEXTBACKGROUND(1);TEXTCOLOR(15);
WRITE(' TEXT_AMI_BIOS_PASSWORD_FINDER by Eduardo Motta Buhrnheim (Mingo) in
MAY/1997! ');
TEXTBACKGROUND(0);TEXTCOLOR(7);
WRITELN;WRITELN;
SENHA:='';
FOR A:=$37 TO ($3D) DO
   BEGIN
   PORT[$70]:=A;
   BYTEBUFFER[A-$37]:=PORT[$71];
   END;
SENHA:='';
BYTEBUFFER[0]:=BYTEBUFFER[0] AND $F0;
I:=1;
WHILE (I<7) AND (BYTEBUFFER[I]<>0) DO
   BEGIN
   CARAC:=0;
   PREVIO:=BYTEBUFFER[I-1];
   WHILE (PREVIO<>BYTEBUFFER[I]) DO
      BEGIN
      INC(CARAC);
      TMPA:=0;
      TMPB:=0;
      IF (PREVIO AND $80>0) THEN
         INC(TMPA);
      IF (PREVIO AND $40)>0 THEN
         INC(TMPA);
      IF (PREVIO AND $02)>0 THEN
         INC(TMPA);
      IF (PREVIO AND $01)>0 THEN
         INC(TMPA);
      WHILE TMPB<TMPA DO
         INC(TMPB,2);
      PREVIO:=PREVIO DIV 2;
      DEC(TMPB,TMPA);
      IF TMPB=1 THEN
         INC(PREVIO,$80);
      END;
   SENHA:=SENHA+CHR(CARAC);
   INC(I);
   END;
IF I=1 THEN
   WRITELN(' No password defined.')
ELSE
   BEGIN
   WRITE(' Current password is "');
   TEXTCOLOR(15);
   WRITE(SENHA);
   TEXTCOLOR(7);
   WRITELN('".');
   END;
WRITELN;
WRITE(' If you wanna contact, write to: ');
TEXTCOLOR(15);
WRITELN('Mingus Production');
TEXTCOLOR(7);
WRITELN('                                 P.O.Box, 3159,');
WRITELN(' mingo@n3.com.br                 Manaus, Amazonas,');
WRITELN(' buhrn@dadosnet.com.br           Brazil,');
WRITELN(' mingus@n3.com.br                69001-970.');
END.
