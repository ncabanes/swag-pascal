(*
  Category: SWAG Title: SCREEN SCROLLING ROUTINES
  Original name: 0013.PAS
  Description: Smooth Scroll with Asm
  Author: JOHN BECK
  Date: 01-27-94  12:22
*)

{
;
; Adapted from Programmer's Guide to PC & PS/2 Video Systems (1-55615-103-9)
;
; Routine written by Richard Wilton
;
;
; Name:         ScreenOrigin
;
; Function:     Set screen origin on EGA and VGA.
;
; Caller:       Pascal:
;
;                       ScreenOrigin(x,y : integer);
;
;                       x,y                (* pixel x,y coordinates *)
;

; Pascal calling convention

ARGx            EQU     word ptr [bp+8] ; stack frame addressing
ARGy            EQU     word ptr [bp+6]

;
; C calling convention
;
; ARGx            EQU     word ptr [bp+4]
; ARGy            EQU     word ptr [bp+6]

CRT_MODE        EQU     49h             ; addresses in video BIOS data area
ADDR_6845       EQU     63h
POINTS          EQU     85h
BIOS_FLAGS      EQU     89h


DGROUP          GROUP   _DATA


_TEXT           SEGMENT byte public 'CODE'
                ASSUME  cs:_TEXT,ds:DGROUP

                PUBLIC  ScreenOrigin
ScreenOrigin    PROC    far

                push    bp              ; preserve caller registers
                mov     bp,sp
                push    si
                push    di

                mov     ax,40h
                mov     es,ax           ; ES -> video BIOS data area
                mov     cl,es:[CRT_MODE]

                mov     ax,ARGx         ; AX := pixel x-coordinate
                mov     bx,ARGy         ; BX := pixel y-coordinate

                cmp     cl,7
                ja      L01             ; jump if graphics mode

                je      L02             ; jump if monochrome alpha
                test    byte ptr es:[BIOS_FLAGS],1
                jnz     L02             ; jump if VGA
                jmp     short L03

; setup for graphics modes (8 pixels per byte)

L01:
                mov     cx,8            ; CL := 8 (displayed pixels per byte)
                                        ; CH := 0
                div     cl              ; AH := bit offset in byte
                                        ; AL := byte offset in pixel row
                mov     cl,ah           ; CL := bit offset (for Horiz Pel Pan)
                xor     ah,ah
                xchg    ax,bx           ; AX := Y
                                        ; BX := byte offset in pixel row

                mul     word ptr BytesPerRow
                                        ; AX := byte offset of start of row
                jmp     short L05

; setup for VGA alphanumeric modes and EGA monochrome alphanumeric mode
;   (9 pixels per byte)

L02:                                    ; routine for alpha modes
                mov     cx,9            ; CL := 9 (displayed pixels per byte)
                                        ; CH := 0
                div     cl              ; AH := bit offset in byte
                                        ; AL := byte offset in pixel row
                dec     ah              ; AH := -1, 0-7
                jns     L04             ; jump if bit offset 0-7
                mov     ah,8            ; AH := 8
                jmp     short L04

; setup for EGA color alphanumeric modes (8 pixels per byte)

L03:
                mov     cx,8            ; CL := 8 (displayed pixels per byte)
                                        ; CH := 0
                div     cl              ; AH := bit offset in byte
                                        ; AL := byte offset in pixel row
L04:
                mov     cl,ah           ; CL := value for Horiz Pel Pan reg
                xor     ah,ah
                xchg    ax,bx           ; AX := y
                                        ; BX := byte offset in row
                div     byte ptr es:[POINTS] ; AL := character row
                                             ; AH := scan line in char matrix
                xchg    ah,ch           ; AX := character row
                                        ; CH := scan line (value for Preset
                                        ;       Row Scan register)
                mul     word ptr BytesPerRow ; AX := byte offset of char row
                shr     ax,1            ; AX := word offset of character row
L05:
                call    SetOrigin

                pop     di              ; restore registers and exit
                pop     si
                mov     sp,bp
                pop     bp

                ret     4

ScreenOrigin    ENDP

SetOrigin       PROC    near            ; Caller: AX = offset of character row
                                        ;         BX = byte offset within row
                                        ;         CH = Preset Row Scan value
                                        ;         CL = Horizontal Pel Pan value

                add     bx,ax           ; BX := buffer offset

                mov     dx,es:[ADDR_6845] ; CRTC I/O port (3B4h or 3D4h)
                add     dl,6            ; video status port (3BAh or 3DAh)

; update Start Address High and Low registers

L20:
                in      al,dx           ; wait for start of vertical retrace
                test    al,8
                jz      L20

L21:
                in      al,dx           ; wait for end of vertical retrace
                test    al,8
                jnz     L21

                cli                     ; disable interrupts
                sub     dl,6            ; DX := 3B4h or 3D4h

                mov     ah,bh           ; AH := value for Start Address High
                mov     al,0Ch          ; AL := Start Address High reg number
                out     dx,ax           ; update this register

                mov     ah,bl           ; AH := value for Start Address Low
                inc     al              ; AL := Start Address Low reg number
                out     dx,ax           ; update this register
                sti                     ; enable interrupts

                add     dl,6            ; DX := video status port
L22:
                in      al,dx           ; wait for start of vertical retrace
                test    al,8
                jz      L22

                cli                     ; disable interrupts

                sub     dl,6            ; DX := 3B4h or 3D4h
                mov     ah,ch           ; AH := value for Preset Row Scan reg
                mov     al,8            ; AL := Preset Row Scan reg number
                out     dx,ax           ; update this register

                mov     dl,0C0h         ; DX := 3C0h (Attribute Controller
port)
                mov     al,13h OR 20h   ; AL bit 0-4 := Horiz Pel Pan reg
number
                                        ; AL bit 5   := 1
                out     dx,al           ; write Attribute Controller Address
reg
                                        ;   (The Attribute Controller address
                                        ;    flip-flop.)
                mov     al,cl           ; AL := value for Horiz Pel Pan reg
                out     dx,al           ; update this register

                sti                     ; enable interrupts
                ret

SetOrigin       ENDP

_TEXT           ENDS


_DATA           SEGMENT word public 'DATA'

                EXTRN   BytesPerRow : word  ; bytes per pixel row

_DATA           ENDS

                END

}
{$A+,B-,D+,E+,F+,G-,I+,L+,N-,O+,P+,Q+,R+,S+,T-,V+,X+,Y+}
{$M 65520,0,655360}

(****************************************************************************)
 {                                                                          }
 { MODULE       : SCROLL                                                    }
 {                                                                          }
 { DESCRIPTION  : Generic unit for perform smooth scrolling.                }
 {                                                                          }
 { AUTHOR       : John M. Beck                                              }
 {                                                                          }
 { MODIFICATIONS: None                                                      }
 {                                                                          }
 { HISTORY      : 29-Dec-1993  Coded.                                       }
 {                                                                          }
(****************************************************************************)

unit scroll;

interface

const
   charwidth  = 8;
   charheight = 14;  { depends on adapter }

var
   screenseg    : word;
   bytesperrow  : word;

function getvideomode : byte;

procedure smoothscroll;

procedure gotoxy (x,y : byte);
procedure wherexy(var x,y : byte);

procedure cursoroff;
procedure setcursor(top,bot : byte);
procedure getcursor(var top,bot : byte);

procedure clearline(line : word);
procedure setvideomode(mode : byte);
procedure panscreen(x0,y0,x1,y1 : integer);

implementation

{$L SCRORG.OBJ}

{
;
; Name:         ScreenOrigin
;
; Function:     Set screen origin on EGA and VGA.
;
; Caller:       Pascal:
;
;                       procedure ScreenOrigin(x,y : integer);
;
;                       x,y               (* pixel x,y coordinates *)
;
}

procedure screenorigin(x,y : integer);  external;

function getvideomode : byte; assembler;
   asm
      mov  ax,0F00h
      int  10h
   end;

procedure cursoroff; assembler;
   asm
      mov  cx,2000h
      mov  ah,1
      int  10h
   end;

procedure gotoxy(x,y : byte); assembler;
   asm
      mov  ah,2
      xor  bx,bx
      mov  dl,x
      dec  dl
      mov  dh,y
      dec  dh
      int  10h
   end;

procedure wherexy(var x,y : byte); assembler;
   asm
      mov  ax,0300h
      xor  bx,bx
      int  10h
      xchg dx,ax
      les  di,x
      stosb
      mov  al,ah
      les  di,y
      stosb
   end;

procedure setvideomode(mode : byte); assembler;
   asm
      mov  ah,00
      mov  al,mode
      int  10h
   end;

procedure setcursor(top,bot : byte); assembler;
   asm
      mov  ax,0100h
      mov  ch,top
      mov  cl,bot
      int  10h
   end;

procedure getcursor(var top,bot : byte); assembler;
   asm
      mov  ax,0300h
      xor  bx,bx
      int  10h
      xchg cx,ax
      les  di,bot
      stosb
      mov  al,ah
      les  di,top
      stosb
   end;

procedure clearline(line : word); assembler;
   asm
      mov   ax,screenseg     { ; AX := screen segment              }
      mov   es,ax            { ; ES := AX                          }

      mov   ax,bytesperrow   { ; AX := # chars per row * 2         }
      push  ax               { ; preserve this value               }
      mov   cx,line          { ; CX := Line                        }
      dec   cx               { ; CX-- (zero based)                 }
      mul   cx               { ; AX := bytesperrow * 25            }
      mov   di,ax            { ; ES:DI -> 25th line                }
      pop   cx               { ; CX := bytesperrow                 }
      shr   cx,1             { ; CX := CX / 2 (word moves)         }
      mov   ax,1824          { ; AH := 7 (white on black)          }
                             { ; AL := 32 (space)                  }
      rep   stosw            { ; clear line                        }
   end;

procedure panscreen(x0,y0,x1,y1 : integer);
{
   Routine originally in Microsoft C by Richard Wilton
}
   var
      i,j   : integer;
      xinc,
      yinc  : integer;
   begin
      i := x0; j := y0;

      if (x0 < x1) then
         xinc := 1
      else
         xinc := -1;

      if (y0 < y1) then
         yinc := 1
      else
         yinc := -1;

      while (i <> x1) or (j <> y1) do
         begin
            if i <> x1 then inc(i,xinc);
            if j <> y1 then inc(j,yinc);
            screenorigin(i,j);
         end;
   end;

procedure smoothscroll;
{
   Smooth scrolls one line up and puts cursor on bottom line.
}
   var
      top,bot : byte;

   begin
      clearline(26);               { blank 26th line             }
      panscreen(0,0,0,charheight); { smooth scroll one line down }
      screenorigin(0,0);           { restore screen origin       }

      asm
         push  ds               { ; preserve data segment             }

         mov   ax,screenseg     { ; AX := 0B000h or 0B800             }

         mov   ds,ax            { ; DS := screen segment              }
         mov   si,160           { ; SI := offset of (0,1)             }
                                { ; DS:SI -> (0,1) of video buffer    }

         mov   es,ax            { ; ES := screen segment              }
         xor   di,di            { ; DI := offset of (0,0)             }

         mov   cx,1920          { ; CX := bytesperrow * 24 / 2        }

         rep   movsw            { ; move screen one line up           }

         pop   ds               { ; restore data segment              }
      end;

      getcursor(top,bot);  { save cursor settings  }
      clearline(25);       { blank new bottom line }
      gotoxy(1,25);        { goto last line        }
   end;

begin
   if getvideomode = 7 then
      screenseg := $B000
   else
      screenseg := $B800;

   bytesperrow := 80*2;        { 80 bytes for text and attributes }
end.

{$A+,B-,D+,E+,F+,G-,I+,L+,N-,O+,P+,Q+,R+,S+,T-,V+,X+,Y+}
{$M 65520,0,655360}

(****************************************************************************)
 {                                                                          }
 { PROGRAM      : PANTEST                                                   }
 {                                                                          }
 { DESCRIPTION  : Tests the scroll unit.                                    }
 {                                                                          }
 { AUTHOR       : John M. Beck                                              }
 {                                                                          }
 { MODIFICATIONS: None                                                      }
 {                                                                          }
 { HISTORY      : 29-Dec-1993  Coded.                                       }
 {                                                                          }
(****************************************************************************)

program pantest;

uses crt, scroll;

var
   count : byte;

begin
   clrscr;
   gotoxy(1,1);
   textattr := (black shl 4) or lightgray;
   for count := 1 to 24 do writeln('Hello ',count);

   write('Press any key to smooth scroll up one line ... ');
   readkey;

   smoothscroll;

   write('Press any key to pan demonstration ... ');
   readkey;

   clrscr;
   gotoxy(65,25);
   textattr := (black shl 4) or lightgreen;
   write('... Groovy ...');
   panscreen(0,0,65 * charwidth,25 * charheight);
   panscreen(65 * charwidth,25 * charheight,0,0);
   gotoxy(1,25);
   textattr := (black shl 4) or lightblue;
   write('Any key to exit ... ');
   readkey;
end.


