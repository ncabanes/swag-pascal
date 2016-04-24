(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0097.PAS
  Description: Graphical Fades and Palet
  Author: MIRKO HOLZER
  Date: 02-05-94  07:55
*)

{
here are some routines, with which you can fade the screen in/out.
How to use:

  Fade out: Get the original palette with the GetPal(0,255,pal) command.
            (Of course you have to allocate 768 Bytes Memory for the pal
             pointer first).
            Then call FadePal(Pal,true,steps) and the screen will be
            faded out.

  Fade in: Just pass the target-pal. to the Fade-Routine:

             FadePal(Targetpal,false,steps).

Note: Low step-rates mean high fading speed. }


Procedure SetPal(Start: byte; Anz: word; pal: pointer); assembler;
asm
  push ds
  cld
  lds si,pal
  mov dx,3c8h
  mov al,start
  out dx,al
  inc dx
  mov ax,anz
  mov cx,ax
  add cx,ax
  add cx,ax
  rep outsb
  pop ds
end;


Procedure GetPal(Start: byte; Anz: word; pal: pointer); assembler;
asm
  les di,pal
  mov al,start
  mov dx,3c7h
  out dx,al
  inc dx
  mov ax,anz
  mov cx,ax
  add cx,ax
  add cx,ax

  mov dx,3c9h
  cld
  rep insb
end;


Procedure FadePal(OrigPal : pPal; FadeOut : Boolean; steps: byte);
Var
  r,g,b   : byte;
  Fade    : word;
  Pct     : real;
  I       : byte;
begin
  For Fade := 0 to Steps do begin
    Pct := Fade / Steps;
    If FadeOut then Pct := 1 - Pct;
    For I := 0 to 255 do begin
      r := Round(OrigPal[I].R * Pct);
      g := Round(OrigPal[I].G * Pct);
      b := Round(OrigPal[I].B * Pct);
      asm
        mov dx,3c8h
        mov al,i
        out dx,al
        mov dx,3c9h
        mov al,r
        out dx,al
        mov al,g
        out dx,al
        mov al,b
        out dx,al
      end;
    end;
  end;
end;

