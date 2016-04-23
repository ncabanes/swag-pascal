
{ The following remains the fastest all-purpose UpperCase routine (using only 32
bytes): }

  procedure Upper4(var Str: String);
  InLine(
    $8C/$DA/               {      mov   DX,DS               }
    $5E/                   {      pop   SI                  }
    $1F/                   {      pop   DS                  }
    $FC/                   {      cld                       }
    $AC/                   {      lodsb                     }
    $30/$E4/               {      xor   AH,AH               }
    $89/$C1/               {      mov   CX,AX               }
    $E3/$12/               {      jcxz  @30                 }
    $BB/Ord('a')/Ord('z')/ {      mov   BX,'za'             }
    $AC/                   { @15: lodsb                     }
    $38/$D8/               {      cmp   AL,BL               }
    $72/$08/               {      jb    @28                 }
    $38/$F8/               {      cmp   AL,BH               }
    $77/$04/               {      ja    @28                 }
    $80/$6C/$FF/$20/       {      sub   BYTE PTR [SI-1],$20 }
    $E2/$F1/               { @28: loop  @15                 }
    $8E/$DA);              { @30: mov   DS,DX               }

{ >    *30,000 times on a 40 MHz 386 Tested on a 33 Mhz 386. }

