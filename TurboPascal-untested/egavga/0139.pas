{
> Would you please repost code of:
> "the SpriteWidth, SpriteHeight, SpriteWidthExact, and flipping functions
> you posted here quite a while ago" ?
  Scanning  through  my database resulted in the following 2 snippets of
  code  for  AniVGA V1.2 (again: it's only a quick-'n-dirty hack, use on
  your  own  risk,  no  support,  no guarantees that the next version of
  AniVGA will have these routines!):
}
{for the INTERFACE-section:}
 FUNCTION SpriteHeight(Sp:WORD):WORD;
 FUNCTION SpriteWidth(Sp:WORD):WORD;
 FUNCTION SpriteWidthExact(Sp:WORD):WORD;
 PROCEDURE ExchangeColor(Sp:WORD; oldColor,newColor:BYTE);
 PROCEDURE MirrorSpriteVertical(Sp:WORD);

{for the IMPLEMENTATION-section:}
FUNCTION SpriteHeight(Sp:WORD):WORD;
{ in: Sp = SpriteLADEnummer, dessen Hoehe ermittelt werden soll}
{out: Die Hoehe des Sprites in Zeilen oder 0, wenn gar kein Sprite geladen}
VAR ad:WORD;
BEGIN
 ad:=SPRITEAD[Sp];
 IF (ad=0)
  THEN SpriteHeight:=0  {Sprite noch nicht geladen}
  ELSE SpriteHeight:=MEMW[ad:Hoehe]
END;

FUNCTION SpriteWidth(Sp:WORD):WORD;
{ in: Sp = SpriteLADEnummer, dessen Breite ermittelt werden soll}
{out: Die Breite des Sprites in Zeilen oder 0, wenn gar kein Sprite geladen}
{rem: Der ermittelte Wert kann um bis zu 3 Punkte zu gross sein}
VAR ad:WORD;
BEGIN
 ad:=SPRITEAD[Sp];
 IF (ad=0)
  THEN SpriteWidth:=0  {Sprite noch nicht geladen}
  ELSE SpriteWidth:=MEMW[ad:Breite] SHL 2
END;

FUNCTION SpriteWidthExact(Sp:WORD):WORD;
{ in: Sp = SpriteLADEnummer, dessen Breite ermittelt werden soll}
{out: Die Breite des Sprites in Zeilen oder 0, wenn gar kein Sprite geladen}
{rem: Der ermittelte Wert ist exakt, allerdings dauert die Routine etwas}
{     laenger als SpriteWidth() }
VAR ad,i,temp,planeOFS:WORD;
BEGIN
 ad:=SPRITEAD[Sp];
 IF (ad=0)
  THEN SpriteWidthExact:=0  {Sprite noch nicht geladen}
  ELSE BEGIN
        temp:=0; planeOFS:=MEMW[ad:Right];
        FOR i:=0 TO MEMW[ad:Hoehe]-1 DO
         BEGIN
          IF MEMW[ad:planeOFS]>temp
           THEN temp:=MEMW[ad:planeOFS];
          INC(planeOFS,2)
         END;
        SpriteWidthExact:=temp+1
       END;
END;

PROCEDURE ExchangeColor(Sp:WORD; oldColor,newColor:BYTE);
{ in: Sp = SpriteLADEnummer des Sprites}
{     oldColor = auszutauschende Farbe}
{     newColor = neue Farbe}
{out: Alle oldColor Farbwerte des Sprites Sp wurden gegen newColor ersetzt}
{rem: Evtl. neue Grenzen, die sich daraus ergeben koennten, wenn eine der}
{     Farben 0 ist, werden nicht neuberechnet}
VAR ad,i,oneplanesize,planeOFS:WORD;
BEGIN
 ad:=SPRITEAD[Sp];
 IF (ad<>0)
  THEN BEGIN
        oneplanesize:=MEMW[ad:Breite]*MEMW[ad:Hoehe]; {Groesse einer
Spriteplane}        FOR i:=0 TO 3 DO
         BEGIN
          planeOFS:=MEMW[ad:i SHL 1];
          ASM
           MOV ES,ad
           MOV DI,planeOFS
           CLD
           MOV AL,oldColor
           MOV DL,newColor
           MOV CX,oneplanesize
          @goon:
           REPNE SCASB
           JNZ @nomatch
           MOV ES:[DI-1],DL
          @nomatch:
           JCXZ @done
           JMP @goon
          @done:
          END; {of ASM}
         END; {of FOR}
       END; {of IF}
END;

PROCEDURE RevertWordArray(p:POINTER; len:WORD); ASSEMBLER;
{ in: p = Anfangsadresse eines Speicherbereichs,}
{     len = Laenge dieses Bereichs in Worten}
{out: Die Reihenfolge der Worte p[0*2]..p[(len-1)*2] wurde gespiegelt}
ASM
  MOV CX,len
  MOV BX,CX
  DEC BX
  SHL BX,1
  SHR CX,1
  JCXZ @fertig
  LDS SI,p
  MOV DI,DS
  MOV ES,DI
  MOV DI,SI
  ADD DI,BX
  {DS:SI = 1.Word des Arrays, ES:DI = letztes Word des Arrays}
  STD
 @oneword:
  MOV AX,ES:[DI]
  XCHG AX,[SI]
  STOSW
  INC SI
  INC SI
  LOOP @oneword
  CLD
  MOV AX,SEG @Data
  MOV DS,AX
 @fertig:
END;

PROCEDURE RevertByteGroups(p:POINTER; GroupsCount, GroupLen:WORD); ASSEMBLER;
{ in: p = Anfangsadresse eines Speicherbereichs,}
{     GroupsCount = Anzahl Gruppen innerhalb dieses Bereichs,}
{     GroupLen = Laenge einer einzelnen Gruppe in Bytes}
{out: Die Reihenfolge der Gruppen wurde gespiegelt}
{rem: Bsp.: 4 Gruppen a 3 Bytes: 01,02,03, 04,05,06, 07,08,09, 10,11,12}
{           nach dem Aufruf    : 10,11,12, 07,08,09, 04,05,06, 01,02,03}
ASM
  MOV CX,GroupsCount
  MOV AX,CX
  SHR CX,1
  JCXZ @fertig
  DEC AX
  MOV BX,GroupLen
  MUL BX
  LDS SI,p
  MOV DI,DS
  MOV ES,DI
  MOV DI,SI
  ADD DI,AX
  {DS:SI = 1.Byte der 1.Gruppe, ES:DI = 1.Byte der letzten Gruppe,}
  {BX = Breite einer Gruppe, CX = Anzahl Gruppen}
  CLD
 @outer:
  MOV DX,BX
 @inner:
  MOV AL,ES:[DI]
  XCHG AL,[SI]
  STOSB
  INC SI
  DEC DX
  JNZ @inner
  SUB DI,BX
  SUB DI,BX
  LOOP @outer
  MOV AX,SEG @Data
  MOV DS,AX
 @fertig:
END;

PROCEDURE MirrorBoundaries(p:POINTER; len,m:WORD); ASSEMBLER;
{ in: p = Zeiger auf Anfang eines Wort-Bereiches,}
{     len = Anzahl zu bearbeitende Worte,}
{     m = Maximalwert, um den gespiegelt werden soll}
{out: Die Werte des Bereichs wurden um (m-0)/2 gespiegelt;}
{     Bsp.: [....a...b.] mit m=9 sollte gespiegelt (bei (9-0)/2 = 4.5) so aus-}
{            0123456789
{     sehen:[.b...a....]}
{     Dadurch veraendern sich die Grenzen: Ist m der Maximalwert, so gilt fuer}
{     die neuen Grenzen: neu:=(m-0)-alt}
{rem: Die Sentinelwerte *16000 werden nicht veraendert!}
ASM
  MOV CX,len
  JCXZ @fertig
  CLD
  MOV DX,m
  LES DI,p
  LDS SI,p
 @oneword:
  LODSW
  CMP AX,+16000
  JE @next
  CMP AX,-16000
  JE @next
  NEG AX
  ADD AX,DX
  STOSW
 @next:
  LOOP @oneword
  MOV AX,SEG @Data
  MOV DS,AX
 @fertig:
END;

PROCEDURE MirrorSpriteVertical(Sp:WORD);
{ in: Sp = SpriteLADEnummer, das vertikal gespiegelt werden soll}
{out: Das Sprites Sp wurde vertikal gespiegelt}
VAR ad,i,zeilen,spalten:WORD;
BEGIN
 ad:=SPRITEAD[Sp];
 IF (ad<>0)
  THEN BEGIN
        zeilen :=MEMW[ad:Hoehe];
        spalten:=MEMW[ad:Breite];
        {Zeilendaten per "Butterfly" vertauschen, fuer alle 4 Ebenen:}
        FOR i:=0 TO 3 DO
         RevertByteGroups(PTR(ad,MEMW[ad:i SHL 1]),zeilen,spalten);

        {Grenzdaten des oberen und unteren Spriterandes korrigieren:}
        MirrorBoundaries(PTR(ad,MEMW[ad:Top]),spalten SHL 2,zeilen-1);
        MirrorBoundaries(PTR(ad,MEMW[ad:Bottom]),spalten SHL 2,zeilen-1);

        {nun obere gegen untere Grenzdaten austauschen:}
        i:=MEMW[ad:Top]; MEMW[ad:Top]:=MEMW[ad:Bottom]; MEMW[ad:Bottom]:=i;

        {Grenzdaten des linken und rechten Spriterandes mittauschen:}
        RevertWordArray(PTR(ad,MEMW[ad:Left]),zeilen);
        RevertWordArray(PTR(ad,MEMW[ad:Right]),zeilen);
       END;
END;


{___snippet two___}

{The difference between the two routines is solely *where* the mirroring
takes place: as default, the axis will be placed exactly in the midst of
the sprite. However, as sprites are stored in multiples of 4 pixels in
the X-direction, this "slack" of up to 3 pixels may be used to shift the
mirror axes a bit to the right. --Don't think much about it: just use a
sprite with a width of 5 pixels. (This will be rounded up to 2*4=8 pixels
by MAKES automatically). Then run a small demo program and use Xshift
values 0..3 to see what happens}


{for the INTERFACE-section:}

 PROCEDURE MirrorSpriteHorizontalWithXShift(Sp,Xshift:WORD);
 PROCEDURE MirrorSpriteHorizontal(Sp:WORD);

{for the IMPLEMENTATION-section:}

PROCEDURE RevertByteArray(p:POINTER; len:WORD); ASSEMBLER;
{ in: p = Anfangsadresse eines Speicherbereichs,}
{     len = Laenge dieses Bereichs in Bytes}
{out: Die Reihenfolge der Bytes p[0]..p[len-1] wurde gespiegelt}
ASM
  MOV CX,len
  MOV BX,CX
  DEC BX
  SHR CX,1
  JCXZ @fertig
  LDS SI,p
  MOV DI,DS
  MOV ES,DI
  MOV DI,SI
  ADD DI,BX
  {DS:SI = 1.Byte des Arrays, ES:DI = letztes Byte des Arrays}
  STD
 @onebyte:
  MOV AL,ES:[DI]
  XCHG AL,[SI]
  STOSB
  INC SI
  LOOP @onebyte
  CLD
  MOV AX,SEG @Data
  MOV DS,AX
 @fertig:
END;

PROCEDURE MirrorSpriteHorizontalWithXShift(Sp,Xshift:WORD);
{ in: Sp = SpriteLADEnummer, das horizontal gespiegelt werden soll}
{     Xshift = Offset, um die Spiegelachse zusaetzlich verschoben werden soll}
{out: Das Sprite Sp wurde horizontal gespiegelt}
{rem: Normalerweise wird das Sprite um seine _tatsaechliche_ Mitte gespiegelt}
{     (=per SpriteSpriteWidthExact() ermittelt). Da das Sprite jedoch in X- }
{     Richtung als Vielfaches von 4 gespeichert wird, kann das Zentrum der  }
{     Spiegelung noch geringfuegig verschoben werden!}
{     Bsp.: Sprite ist 5 Punkte breit -> abgespeichert in 2 4er-Gruppen ->  }
{           Spiegelung kann so erfolgen, als ob es 5,6,7 oder 8 Punkte breit}
{           waere; XShift kann somit die Werte 5-5=0 .. 8-5=3 annehmen!}
TYPE ByteAt=ARRAY[0..65534] OF BYTE;
VAR ad,i,j,index,zeilen,spalten,exBreite,plane0,plane1,plane2,plane3:WORD;
    p:POINTER;
BEGIN
 ad:=SPRITEAD[Sp];
 IF (ad<>0)
  THEN BEGIN
        zeilen :=MEMW[ad:Hoehe];
        spalten:=MEMW[ad:Breite];
        exBreite:=SpriteWidthExact(Sp)+Xshift;
        {Xshift-Addition darf nicht dazu fuehren, dass Sprite "aus dem }
        {Rahmen" faellt:}
        IF exBreite>spalten SHL 2
         THEN exBreite:=spalten SHL 2;
        GetMem(p,spalten SHL 2);  {Speicher fuer 1 Zeile}
        plane0:=MEMW[ad: 0 SHL 1];
        plane1:=MEMW[ad: 1 SHL 1];
        plane2:=MEMW[ad: 2 SHL 1];
        plane3:=MEMW[ad: 3 SHL 1];
        index:=0; {Invariante: index = i*spalten + j}

        FOR i:=0 TO zeilen-1 DO
    BEGIN
          {Zeile expandieren:}
          FOR j:=0 TO spalten-1 DO
      BEGIN
            ByteAt(p^)[j SHL 2 +0]:=MEM[ad:plane0 +index];
            ByteAt(p^)[j SHL 2 +1]:=MEM[ad:plane1 +index];
            ByteAt(p^)[j SHL 2 +2]:=MEM[ad:plane2 +index];
            ByteAt(p^)[j SHL 2 +3]:=MEM[ad:plane3 +index];
            INC(index)
           END;
          {Zeile spiegeln:}
          RevertByteArray(p,exBreite);
          {Zeile zurueckspeichern:}
          DEC(index,spalten);  {auf Anfang der Zeile positionieren}
          FOR j:=0 TO spalten-1 DO
      BEGIN
            MEM[ad:plane0 +index]:=ByteAt(p^)[j SHL 2 +0];
            MEM[ad:plane1 +index]:=ByteAt(p^)[j SHL 2 +1];
            MEM[ad:plane2 +index]:=ByteAt(p^)[j SHL 2 +2];
            MEM[ad:plane3 +index]:=ByteAt(p^)[j SHL 2 +3];
            INC(index)
           END;
         END;

        FreeMem(p,spalten SHL 2);

        {Grenzdaten des linken und rechten Spriterandes korrigieren:}
        MirrorBoundaries(PTR(ad,MEMW[ad:Left]),zeilen,exBreite-1);
        MirrorBoundaries(PTR(ad,MEMW[ad:Right]),zeilen,exBreite-1);

        {nun linke gegen rechte Grenzdaten austauschen:}
        i:=MEMW[ad:Left]; MEMW[ad:Left]:=MEMW[ad:Right]; MEMW[ad:Right]:=i;

        {Grenzdaten des oberen und unteren Spriterandes mittauschen:}
        RevertWordArray(PTR(ad,MEMW[ad:Top]),exBreite);
        RevertWordArray(PTR(ad,MEMW[ad:Bottom]),exBreite);
       END;
END;

PROCEDURE MirrorSpriteHorizontal(Sp:WORD);
{ in: Sp = SpriteLADEnummer, das horizontal gespiegelt werden soll}
{out: Das Sprites Sp wurde horizontal gespiegelt}
BEGIN
 MirrorSpriteHorizontalWithXShift(Sp,0)
END;


