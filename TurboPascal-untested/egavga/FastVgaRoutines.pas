(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0080.PAS
  Description: Fast VGA Routines
  Author: PEDER HERBORG
  Date: 01-27-94  12:00
*)

{
I've must say that im not exactly the perfect programmer, but I think I've an
answer to some of your questions.

1. Well to post a whole program who does that is quite complicated. But
   if you use the Pelpanning register it's possible to create really fast
   scrollers even on slow 286 and XT's. Here comes a simple proc just to
   get the Idea:

}

const Crtadress:word=$3d4;
      Inputstatus:word=$3DA;


Procedure Pan(X,Y: Word);assembler;    { This pans the screen } asm
    mov    bx,320
    mov    ax,y
    mul    bx
    add    ax,x
    push   ax
    pop    bx
    mov    dx,INPUTSTATUS
@WaitDE:
    in     al,dx
    test   al,01h
    jnz    @WaitDE       {display enable is active?}
    mov    dx,Crtadress
    mov    al,$0C
    mov    ah,bh

    out    dx,ax
    mov    al,$0D
    mov    ah,bl
    out    dx,ax
    MOV    dx,inputstatus
@wait:
    in      al,dx
    test    al,8                    {?End Vertical Retrace?}
    jz     @wait
End;

{
If you use this, you should realize that if you increase x by one the screen
moves four pixels. This procedure move the whole screen, so if you want a logo
or something at the screen too you have to use this little procedure, it resets
the scanlines at the screen soo it is only the top of the screen that moves.
}

procedure vgasplit(whatline:word);
begin
  asm
{VGASplit        Proc    Near}
                 Mov     BX,whatline
                 Mov     DX,3DAh-6           {; Port = 3D4H}
                 Mov     AX,BX
                 Mov     BH,AH
                 Mov     BL,BH
                 And     BX,0201H
                 Mov     CL,4
                 Shl     BX,CL
                 Shl     BH,1
                 Mov     AH,AL
                 Mov     AL,18H
                 Out     DX,AX

                 Mov     AL,7
                 Out     DX,AL

                 Inc     DX
                 In      AL,DX

                 Dec     DX
                 Mov     AH,AL
                 And     AH,11101111B
                 Or      AH,BL
                 Mov     AL,7
                 Out     DX,AX

                 Mov     AL,9
                 Out     DX,AL

                 Inc     DX
                 In      AL,DX

                 Dec     DX
                 Mov     AH,AL
                 And     AH,10111111B
                 Or      AH,BH
                 Mov     AL,9
                 Out     DX,AX

               End;
end;

{
2. There are several unit's out there that comes with source so i suggest
   that you have another look at one of them, There is a really nice one
   called ANIVGA.

3. Well its almost the same as the first question. Just dont set the vgasplit
   rutine. And increase the y parameter instead of x.


All of the rutines have been written for mode X, but it's also possible to use
them with standard Vgamode $13.
Thats it. I really hope it helped you or/and somebody else a little bit,if you
or anyone else have any questions. Please feel free to write me a Letter.

}
