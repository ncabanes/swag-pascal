(*
  Category: SWAG Title: STRING HANDLING ROUTINES
  Original name: 0104.PAS
  Description: Super FAST upcase
  Author: OSCAR N. VERZAAL
  Date: 11-26-94  05:04
*)


{
  To SWAG (group STRINGS.SWG)

  Jose Campione claimed that he had the fastest upperstring, 
  I proved otherwise. Look at the difference in speed
  between TXLat5 of Jose Campione and mine.

   The following benchmarking was done in a 486/DX 60 MHz using
   Neil Rubenking's TimeTick unit while upcasing a full string
   (255 chars) 400,000 times (100 million characters):

   For-Do loop using TP7 UpCase() .......... 315.5 secs.
   UpperCase (Assembler classical approach)   53.9 secs. (1)
   My old TXlat3 ...........................  28.3 secs. (2)
   Translate ...............................  26.8 secs. (3)
   TXlat5 ..................................  21.2 secs.

   SUPERFASTUPSTRING .......................  17.1 secs. (!)

   Oscar N. Verzaal (bkverzaa@sus.edu.eur.nl)

}

Program UpString;

uses Crt, Dos;

type
  ByteArray        = array[0..255] of byte;

var
  Source1,
  Source           : string;
  Table            : ByteArray;
  k, nr            : longint;
  u, m, s, s100    : word;
  tm1, tm2, t1, t2 : real;

    Procedure TXlat5(var Source: string; var Table: ByteArray);assembler;
    asm
        mov  dx, ds       { save ds }
        lds  bx,Table     { load ds:bx with Table address }
        les  di,Source    { load es:di with Source address }
        seges             { override ds segment}
        mov  al,[di]      { load al with length of source }
        xor  ah, ah       { set ah to zero, we need a word for cx }
        mov  cx,ax         { assign length of source to counter }
        jcxz @end         { if cx = 0 exit}
        inc  di           { increment di & skip length byte on 1st pass }
      @filter:
        mov  al,[di]      { load byte in ax from es:di }
        xlat              { tan-xlat-e... }
        mov  [di],al      { send byte to es:di }
        inc  di           { increment di }
        loop @filter      { decrement cx and loop back if cx > 0 }
      @end: mov  ds, dx   { restore ds }
    end;

    Procedure SuperFastUpString(var Source, Table);
      inline($8C/$DA/           { mov   dx, ds                  }
             $5B/               { pop   bx   | lds bx, Table    }
             $1F/               { pop   ds   |                  }
             $5F/               { pop   di   | les di, Source   }
             $07/               { pop   es   |                  }
             $8A/$0D/           { mov   cl, [di]                }
             $08/$C9/           { or    cl, cl                  }
             $74/$0F/           { jz    @end                    }
             $30/$ED/           { xor   ch, ch                  }
             $47/               { inc   di                      }
                                { @loop:                        }
             $8A/$05/           { mov   al, [di]                }
             $D7/               { xlat                          }
             $88/$05/           { mov   [di], al                }
             $47/               { inc   di                      }
             $49/               { dec   cx                      }
             $75/$F7/           { jnz   @loop                   }
                                { @end:                         }
             $8E/$DA);          { mov   ds, dx                  }

begin
  ClrScr;
  nr:=400000;
  writeln('Number of times ',nr:6);
  writeln('----------------------');

  for k:= 0 to 255 do
    if k in [$61..$7A] then Table[k]:= k - $20 else Table[k]:= k;

  Source1:= 'this string is to be upcased this string is to be upcased this string is to be upcased '+
            'this string is to be upcased this string is to be upcased this string is to be upcased '+
            'this string is to be upcased this string is to be upcased this string is to be u.';

  Source := Source1;
  GetTime(u, m, s, s100);
  t1 := (u*3600) + (m*60) + s + (s100/100);
  for k:=1 to nr do TXLat5(Source, Table);
  GetTime(u, m, s, s100);
  t2 := (u*3600) + (m*60) + s + (s100/100);
  tm1 := t2 - t1;
  writeln('TXLat5            took ',tm1:5:2,'sec');

  Source := Source1;
  GetTime(u, m, s, s100);
  t1 := (u*3600) + (m*60) + s + (s100/100);
  for k:=1 to nr do SuperFastUpString(Source, Table);
  GetTime(u, m, s, s100);
  t2 := (u*3600) + (m*60) + s + (s100/100);
  tm2 := t2 - t1;
  writeln('SuperFastUpString took ',tm2:5:2,'sec');

  writeln;
  writeln('Speed advantage of SuperFastUpString over TXlat5 is ',100*((tm1 - tm2) / tm1):6:2,'%');

end.

