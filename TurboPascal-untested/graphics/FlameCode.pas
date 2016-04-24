(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0138.PAS
  Description: Flame Code
  Author: DEGRACE KEITH
  Date: 11-26-94  05:01
*)

{ From: 9308920@info.umoncton.ca (DEGRACE KEITH) }

var
  c, x, y : byte;

procedure setrgb(c, r, g, b : byte);
begin
  port[$3c8] := c;   { g'day, this is a probably the most simple version   }
  port[$3c9] := r;   { of fire that you will ever see in pascal. i wrote   }
  port[$3c9] := g;   { the code in pascal so it's slow and choppy, i have  }
  port[$3c9] := b;   { another version in asm. and it's faster. anyways if }
end;                 { you have any critics or question on this code, just }
                     { e-mail me at ekd0840@bosoleil.ci.umoncton.ca. or    }
begin                {              9323767@info.umoncton.ca               }
  randomize;         {  note : I have code for all kinds of stuff (that I  }
  asm   mov ax, 13h  {         wrote of course), if you want something     }
        int 10h      {         e-mail me (i never get mail), maybe i have  }
  end;               {         what you want.                              }
  for x := 1 to 32 do{                               keith degrâce         }
   begin             {                               moncton, n.-b. canada }
    setrgb(x, (x shl 1)-1, 0, 0 );
    setrgb(x+32, 63, (x shl 1)-1, 0 );
    setrgb(x+64, 63, 63, (x shl 1)-1 );
    setrgb(x+96, 63, 63, 63 );
   end;
  repeat
   for x := 0 to 159 do
    begin
     for y := 30 to 101 do
      begin
       c := (mem[$a000:(y shl 1)*320+(x shl 1)]+
             mem[$a000:(y shl 1)*320+((x+1) shl 1)]+
             mem[$a000:(y shl 1)*320+((x-1) shl 1)]+
             mem[$a000:((y+1) shl 1)*320+((x+1) shl 1)]) shr 2;
       if c <> 0 then dec(c);
       memw[$a000:(((y-1) shl 1)*320+(x shl 1))] := (c shl 8) + c;
       memw[$a000:(((y shl 1)-1)*320+(x shl 1))] := (c shl 8) + c;
      end;
     mem[$a000:(y shl 1)*320+(x shl 1)] := random(2)*160;
    end;
  until port[$60] < $80;
  asm  mov ax, 3
       int 10h
  end;
end.



