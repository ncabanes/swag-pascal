{
From: terjem@hda.hydro.com (Terje Mathisen)

>I need the source code to (in TP and/or Assembly) setup a processor
>independant delay.  The one I have is way faster on a 486 than on a 386.
>I need something that tests the machines speed when a unit is initialized
>and saves a number to a variable and then a delay procedure that uses
>that number.

Well, the Delay() procedure in the Crt unit is designed to do exactly this,
but if you cannot use Crt, try this replacement which I wrote almost
10 years ago, and later converted to a Unit.
}

{$R-,S-}
Unit Delays;

INTERFACE

CONST loop_count : WORD = 250;

PROCEDURE Delay(ms : WORD);

IMPLEMENTATION

PROCEDURE Delay(ms : Word);
BEGIN
Inline(
  $8B/$76/<MS            {    mov si,[bp<ms]}
  /$09/$F6               {    or si,si}
  /$74/$09               {    jz d2}
  /$8B/$0E/>LOOP_COUNT   {d0: mov cx,[>loop_count]}
  /$E2/$FE               {d1: loop d1}
  /$4E                   {    dec si}
  /$75/$F7               {    jnz d0}
);                       {d2:}
END;

BEGIN
InLine(
  $B8/$40/$00            {    mov ax,$40}
  /$8E/$C0               {    mov es,ax}
  /$BB/$6C/$00           {    mov bx,$6C}
  /$26/$8B/$37           {d3: es: mov si,[bx]}
  /$31/$FF               {    xor di,di}
  /$26/$3B/$37           {d4: es: cmp si,[bx]}
  /$74/$FB               {    je d4}
  /$26/$8B/$37           {    es: mov si,[bx]}
  /$8B/$0E/>LOOP_COUNT   {d5: mov cx,[>loop_count]}
  /$E2/$FE               {d6: loop d6}
  /$47                   {    inc di}
  /$26/$3B/$37           {    es: cmp si,[bx]}
  /$74/$F4               {    je d5}
  /$A1/>LOOP_COUNT       {    mov ax,[>loop_count]}
  /$F7/$E7               {    mul di}
  /$B9/$37/$00           {    mov cx,55}
  /$F7/$F1               {    div cx}
  /$A3/>LOOP_COUNT       {    mov [>loop_count],ax}
  /$81/$FF/$1E/$00       {    cmp di,30}
  /$72/$D4               {    jb d3}
);
END.

