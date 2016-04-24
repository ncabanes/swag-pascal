(*
  Category: SWAG Title: DOS & ENVIRONMENT ROUTINES
  Original name: 0066.PAS
  Description: File There ??
  Author: MARIUS ELLEN
  Date: 08-24-94  13:37
*)


{ Try the DOS GetAttr function (Also faster than findfirst) }

  { test to see if file exists }
  function fIsFileP(SrcPath:pchar):boolean;
  inline({get fattr, dos 2.0+}
    $5A/                        { pop   dx             }
    $58/                        { pop   ax             }
    $1E/                        { push  ds             }
    $8E/$D8/                    { mov   ds,ax          }
    $B8/$00/$43/                { MOV   AX,4300h       }
    $CD/$21/                    { int   21h            }
    $1F/                        { pop   ds             }
    $72/$08/                    { JC    +8             }
    $B8/$01/$00/                { MOV   AX,1           }
    $F6/$C1/$10/                { TEST  CL,faDirectory }
    $74/$02/                    { JE    +2             }
    $31/$C0);                   { xor   ax,ax          }

BEGIN
  WriteLn(FisFIleP('\turbo\bp.exe'));
END.
