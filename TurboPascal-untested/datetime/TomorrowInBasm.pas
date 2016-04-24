(*
  Category: SWAG Title: DATE & TIME ROUTINES
  Original name: 0029.PAS
  Description: TOMORROW in BASM
  Author: ERIK HJELME
  Date: 11-02-93  16:49
*)

{
From: ERIK HJELME
Subj: date of tomorrow

I know you've got answers about how to calculate the date of
tomorrow, but as DOS take care of almost anything in life it
will offer to do this for you too : }

var
  yy           : word;
  mm,dd,ww     : byte;

begin   asm
        mov     ah,$2A
        int     $21     { request todays date }
        push    dx      { store todays date   }
        push    cx      { store todays year   }

        mov     ax,$40  { pretend midnight has been passed }
        mov     es,ax
        inc     byte ptr es:[$0070]

        mov     ah,$2A
        int     $21     { request todays date, DOS will calculate
                          the next available date ie tomorrow    }

        mov     yy,cx   { year  }
        mov     mm,dh   { month }
        mov     dd,dl   { date  }
        mov     ww,al   { day_of_week }

        mov     ah,$2b
        pop     cx      { retrieve year }
        pop     dx      { retrieve date }
        int     $21     { restore date  }
        end;
end;


