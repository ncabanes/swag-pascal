(****************************************************************************

Hopefully you got this from SWAG :)

Anyways, this is my little fire routine that I wrote.  It didn't take me

very long and is far from being optimized... so it's kind of slow....

Runs fine on my pentium 100mhz though!!! :)



This code was written by Phire of Patd Programming.  Check out my homepage:

http://www.tripod.com/~rflynn  or email: rflynn@shelby.net

Please feel free to improve my code ;) 

(****************************************************************************)



USES CRT, DOS;



CONST

     YMAX = 50;
     YMIN = 0;
     XMAX = 317;
     XMIN = 2;
     maxc = 1;

VAR

   X,Y,Z  : WORD;
   TOTAL  : WORD;
   A,B,C  : LONGINT;
   I      : WORD;
   SCREEN : ARRAY[1..64000] OF BYTE;
   ST, ET : REAL;
   CYCLES : LONGINT;

PROCEDURE CT(VAR MOO:REAL);
VAR
   H,M,S,MS : WORD;

BEGIN
     GETTIME(H,M,S,MS);
     MOO:=H*3600+M*60+S+MS DIV 100;
END;

procedure setcolor(color,r,g,b : byte);
begin
     port[$3c8]:=color;
     port[$3c9]:=r;
     port[$3c9]:=g;
     port[$3c9]:=b;
end;
BEGIN
     RANDOMIZE;
     ASM MOV AX, 13H; INT 10H; END;
     asm
        mov dx, 03d4h
        mov al, 9
        out dx, al
        inc dx
        and al, 0e0h
        or  al, 7
        out dx, al
     end;
  for i:=0 to 63 do setcolor(i,0,0,0);
  for i:=0 to 63 do setcolor(64+i,0,0,0);
  for i:=0 to 63 do setcolor(128+i,i,i shr 1,0);
  for i:=0 to 63 do setcolor(192+i,63,32+i shr 1,0);

  FILLCHAR(SCREEN, 64000, 0);

     WHILE KEYPRESSED DO READKEY;
     CT(ST);
     CYCLES:=0;
     REPEAT
           MOVE(SCREEN, MEM[$A000:0], 64000);
           FOR Y:=YMAX DOWNTO YMIN DO
           BEGIN
                IF Y=YMAX THEN
                   BEGIN
                        FOR Z:=XMIN TO XMAX DO
                        BEGIN
                             CASE RANDOM(10) OF
                                  0,2,4 : SCREEN[Y*320+Z]:=0;
                                  1,3,5,6,7,8,9 : SCREEN[Y*320+Z]:=255;
                             END;
                        END;
                   END;

           FOR X:=XMIN TO XMAX DO
                   BEGIN
                        IF Y<YMAX THEN
                           BEGIN
                                INC(CYCLES);
                                IF CYCLES=MAXC+1 THEN CYCLES:=0;
                                IF CYCLES=0 THEN
                                BEGIN
                                TOTAL:=0;
                                SCREEN[Y*320+X]:=SCREEN[(Y+1)*320+X];
                                TOTAL:=TOTAL+SCREEN[(Y+1)*320+(X-1)];
                                TOTAL:=TOTAL+SCREEN[(Y+1)*320+(X)];
                                TOTAL:=TOTAL+SCREEN[(Y+1)*320+(X+1)];
                                TOTAL:=TOTAL+SCREEN[(Y)*320+(X-1)];
                                TOTAL:=TOTAL+SCREEN[(Y)*320+(X)];
                                TOTAL:=TOTAL+SCREEN[(Y)*320+(X+1)];
                                A:=TOTAL DIV 6;
                                END;

                                IF A>255 THEN A:=255;
                                SCREEN[Y*320+X]:=A;
                                SCREEN[Y*320+(X-1)]:=A;
                                SCREEN[Y*320+(X+1)]:=A;
                           END;
                   END;
           END;
     UNTIL (KEYPRESSED);
     asm
        mov ax, 3h
        int 10h
     end;
END.


{ --- CUT --- }

(___)        *   Digital Patd/Patd Programming

(o o)-------/    EMAIL: rflynn@shelby.net

 \_/________|    WWW  : http://www.tripod.com/~rflynn

    ||    ||     SysOp Of Hot As Fire BBS!! {704}657-9498

    ^^    ^^     Call today or you might get burned!!!     





