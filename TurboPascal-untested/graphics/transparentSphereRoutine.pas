(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0285.PAS
  Description: transparent sphere routine
  Author: SCOTT TUNSTALL
  Date: 01-02-98  07:34
*)

{
=================================================================

PROGRAM NAME : NEWLENS.PAS

AUTHOR       : Bas Van Gaalen (originally for GFXFX2)
               Scott Tunstall (for KOJAKVGA 3.3) in August 1997.

NOTES        :

This is Bas Van Gaalen's LENS.PAS "transparent sphere" routine
converted to KOJAKVGA 3.3. Only the data tables and
initialisation code remain from the GFXFX2 version.

The rest of the graphics code has been changed to suit my unit.

Why did I convert it? 'Cos I like the sphere!

The lens draw routine is now converted to 90% assembler; I HATE
slow Pascal routines!


What you do is specify your 320 x 200 x 256 colour PCX file name
as the command line parameter and watch the sphere bounce around.
Hope you enjoy it...
     Scott.


P.S.
    You can get my KOJAKVGA 3.3 unit from June 97's GRAPHICS
    section.


DISCLAIMER:
There's no way this should damage your PC -unless you have a
286 processor or an EGA graphics card. However, use this at your
own risk!

-----------------------------------------------------------------
}






program Newlens;

{ Lens effect (Wierd? Yeah!) By Bas van Gaalen,
  Update by Scott Tunstall.
  If you have a fast computer, try using a transparent sprite... }

uses KOJAKVGA,crt;

const
  radius=30; { sphere radius }
  maxpoints=3000; { maximum number of points }
  xs=60;
  ys=60; { size is two times sphere-radius }

  ptab:array[0..255] of byte=( { parabole table for bounce }
    123,121,119,117,115,114,112,110,108,106,104,103,101,99,97,96,94,92,91,
    89,87,86,84,82,81,79,78,76,75,73,72,70,69,67,66,64,63,62,60,59,58,56,
    55,54,52,51,50,49,48,46,45,44,43,42,41,39,38,37,36,35,34,33,32,31,30,
    29,28,27,26,26,25,24,23,22,21,21,20,19,18,17,17,16,15,15,14,13,13,12,
    12,11,10,10,9,9,8,8,7,7,6,6,5,5,5,4,4,4,3,3,3,2,2,2,2,1,1,1,1,1,1,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,2,2,2,2,3,3,3,3,4,4,4,5,5,6,6,
    7,7,7,8,8,9,9,10,11,11,12,12,13,14,14,15,16,16,17,18,19,19,20,21,22,
    23,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,
    46,47,48,49,51,52,53,54,56,57,58,60,61,62,64,65,67,68,69,71,72,74,75,
    77,78,80,82,83,85,86,88,90,91,93,95,96,98,100,102,103,105,107,109,111,
    113,114,116,118,120,122,124,126);

type
  parastruc=array[0..xs-1,0..ys-1] of shortint;

var
  para:parastruc;
  pal:paletteType;
  virscr,bckscr:pointer;

const
  paraptr:pointer=@para;


procedure initialize;
const
  step=0.035; { working step-size for a radius of 30 }
var
  alpha,beta:real;
  r,x,y,z:integer;
begin
  writeln('Calculating hemi-sphere data. Can take a few secs...');
  fillchar(para,sizeof(para),0);
  alpha:=pi;
  while alpha>0 do begin
    beta:=pi;
    while beta>0 do begin
      x:=radius+round(radius*cos(alpha)*sin(beta));
      y:=radius+round(0.833*radius*cos(beta));
      z:=round(radius*sin(alpha)*sin(beta));
      para[x,y]:=(radius-z) shr 1;
      beta:=beta-step;
    end;
    alpha:=alpha-step;
  end;
end;


{ Bas said: Anyone brainy enough could rewrite this to assembler,
  that would speed up things considerably.


  So (ahem) seeing as I'm sad enough to do things like that..
  I did. ;)

  Sickening isn't it: all that assembler!

}



{ Bas's original code: }

{procedure displaypara(x,y:word);
var p:parastruc; i,j:word;
begin
  for i:=x to x+xs-1 do for j:=y to y+ys-1 do
    mem[seg(virscr^):j*320+i]:=
    mem[seg(virscr^):(j-para[i-x,j-y])*320+i+para[i-x,j-y]];
end;}



{ And the (mostly) assembler equivalent : }

procedure displaypara(x,y:word);
var p:parastruc;
    short: shortint;
    i,j:word;

begin
     for i:=x to x+xs-1 do
     for j:=y to y+ys-1 do
         begin

         short:=para[i-x,j-y];
         asm
         les di,virscr
         mov dx,es          { Save ES in DX }

         mov ax,j
         mov cx,ax
         shl ax,8           { J * 256 }
         shl cx,6           { J * 64 }
         add ax,cx          { = J * 320 }
         add ax,i           { + I }
         mov di,ax          { DI = AX }

         push es        { Got to save es and di onto the stack }
         push di        { as they will be corrupted }

         mov ax,j       { AX = J }
         xor bh,bh
         mov bl,short
         sub ax,bx      { J - Para[i-x,j-y] }

         mov cx,ax      { J * 320, see above please }
         shl ax,8
         shl cx,6
         add ax,cx
         add ax,i       { Add I too }

         add ax,bx      { Mind take into account Para[i-x,j-y] ! }
         xchg ax,bx     { I want BX to be the offset }

         mov es,dx        { Restore ES }
         mov al,[es:bx]   { Read byte from screen }

         pop di           { And now restore the screen pointer }
         pop es

         mov [es:di],al   { Store new byte. }


         end
     end;
end;








var di:shortint; i:integer; idx:byte;
begin
  initialize;

  initVGAMode;
  bckscr:=New64KBitmap;
  UseBitmap(bckscr);
  Cls;

  LoadPCX(paramstr(1),pal);
  UsePalette(pal);

  ShowAllBitmap(bckscr);

  VirScr:=New64KBitmap;
  UseBitmap(VirScr);
  Cls;


  i:=30;
  idx:=128;
  di:=2;

  repeat
    CopyBitmap(bckscr,virscr);
    UseBitmap(virscr);
    displaypara(i,15+ptab[idx]); inc(idx,3);

    inc(i,di);
    if (i<25) or (i+xs>295) then
       di:=-di;

{ Removing the VWAIT could cause faster computers (P200s)
  to spout flames <grin> as the sphere will be drawn VERY quickly!
}

    Vwait(1);
    CopyBitmap(virscr,ptr($a000,0));
  until keypressed;

  freebitmap(virscr);
  freebitmap(bckscr);

end.

