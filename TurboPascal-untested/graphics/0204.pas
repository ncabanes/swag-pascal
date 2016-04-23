{This 2 procedures work with standard VGA (640x480x16). I did this about
 4 years ago to get higher speed of handling images. There are two
 restictions: 1. only NormalPut is done. (no such parameter for PutImageX8)
              2. the x-position must be X mod 8 = 0.
 For static images I use them often, because they are more than 4 times
 faster then the BGI originals. The function ImageSize can be used to get the
 required size of image.

 Dec. 13, 1995, Udo Juerss, 57078 Siegen, Germany, CompuServe [101364,526]}

procedure GetImageX8(X1,Y1,X2,Y2:Integer; var OP); assembler;
var
  XLen,YLen : Word;

asm
    push ds                              {Verwendete Segmentregister sichern}
    push es
    les  di,[OP]                                  {ES:DI = Zeiger auf Bitmap}
    mov  ax,X2
    mov  bx,X1
    and  ax,0FFF8h
    add  ax,8
    and  bx,0FFF8h
    sub  ax,bx                                 {AX = horizontale Punktanzahl}
    push ax
    stosw      {Als Information f|r GetImage diesen Wert in Bitmap speichern}
    mov  ax,Y2
    sub  ax,Y1                                   {AX = vertikale Punktanzahl}
    mov  YLen,ax                            {F|r spdteren Zdhlwert speichern}
    stosw      {Als Information f|r GetImage diesen Wert in Bitmap speichern}
    pop  ax
    shr  ax,3
    mov  XLen,ax
    mov  bx,X1
    shr  bx,3
    mov  si,Y1
    shl  si,4
    mov  cx,si
    shl  si,2
    add  si,cx
    add  si,bx                                   {SI = BPR * Y1 + (X1 shl 8)}
    mov  ds,SegA000                                   {DS = Video Basissegment}
    mov  dx,03CEh                     {DX = Graphics Controller Command Port}
    mov  al,4                                    {Read-Map Register anwdhlen}
    out  dx,al
    inc  dx                              {DX = Graphics Controller Data Port}
    mov  bx,YLen                                         {BX = Anzahl Zeilen}
    mov  cx,XLen                                         {CX = Anzahl  Bytes}

@1: mov  al,3                                       {Maske f|r Plane 3 laden}

@2: out  dx,al                            {Plane f|r Lesezugriff selektieren}
    push si                                   {Quelloffset auf Stack sichern}
    push cx                                {Repetierzdhler auf Stack sichern}
    rep  movsb                                        {Kopiervorgang starten}
    pop  cx                                      {Repetierzdhler zur|ckholen}
    pop  si                                         {Quelloffset zur|ckholen}
    dec  al                                {AL = AL - 1 ndchste untere Plane}
    jnl  @2                           {Wenn AL nicht < 0, dann weiter bei @2}
    add  si,80                         {Quelloffset auf ndchste Zeile setzen}
    dec  bx                                              {Vertikalzdhler - 1}
    jnl  @1                              {Wenn nicht < 0, dann ndchste Zeile}

    pop  es                          {Verwendete Segmentregister zur|ckholen}
    pop  ds
end;
{---------------------------------------------------------------------------}

procedure PutImageX8(XOfs,YOfs:Integer; var IP); assembler;
var
  XLen,YLen : Word;

asm
    push  ds                             {Verwendete Segmentregister sichern}
    push  es

    mov  es,SegA000                          {Basis Videosegment A000h laden}

    push ds                                                      {DS sichern}
    lds  si,[IP]                                  {DS:SI = Zeiger auf Bitmap}
    lodsw                                {1. Wort = Anzahl Punkte horizontal}
    shr  ax,3                    {AX = Anzahl Bytes von horizontalen Punkten}
    mov  XLen,ax             {Laufvariable f|r Anzahl horizontale Scanzyklen}
    lodsw                         {2. Wort = Anzahl Zeilen (Punkte vertikal)}
    mov  YLen,ax              {Laufvariable f|r Anzahl vertikaler Scanzyklen}
    mov  di,ds                                           {DS in DI speichern}
    pop  ds                         {DS zur|ckholen um Maskenarrays zu laden}
    mov  ax,YOfs
    shl  ax,4
    mov  bx,ax
    shl  ax,2
    add  ax,bx
    mov  bx,XOfs                  {CX = Offset linker Punkt vom Zeilenanfang}
    shr  bx,3
    add  ax,bx                                  {Speicheradresse von 1.Punkt}
    mov  ds,di                                       {DI wieder zur|ck in DS}
    mov  di,ax      {Zielregister auf Speicheradresse von 1.Punkt einstellen}

    mov  dx,03C4h                               {DX = Sequenzer Command Port}
    mov  al,2                                {Das Map-Mask Register anwdhlen}
    out  dx,al
    inc  dx                                        {DX = Sequnezer Data Port}

    mov  bx,YLen                                         {BX = Anzahl Zeilen}
    mov  cx,XLen                                         {CX = Anzahl  Bytes}

@1: mov  al,8                       {Maske f|r 3. Plane im Map-Mask Register}

@2: out  dx,al
    push di                                           {Quelloffset auf Stack}
    push cx                                       {Laufregister CX auf Stack}
    rep  movsb                                        {Kopiervorgang starten}
    pop  cx                                        {Laufregister zur|ckholen}
    pop  di                                         {Quelloffset zur|ckholen}
    shr  al,1                              {Maske f|r ndchste Plane erzeugen}
    jnz  @2            {Wenn AL > 0, dann die gleiche Zeile nochmal kopieren}
    add  di,80                            {Offset f|r ndchste Zeile addieren}
    dec  bx                                   {Vertikalzdhler dekrementieren}
    jnl  @1                           {Wenn BX nicht < 0, dann weiter bei @1}

    dec  dx                                     {DX = Sequenzer Command Port}
    mov  ax,0F02h         {Map-Mask Register Normalzustand alle Planes aktiv}
    out  dx,ax

    pop  es                                     {Segmentregister zur|ckholen}
    pop  ds

end;
{---------------------------------------------------------------------------}
