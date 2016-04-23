
UNIT  uMCursor;                               { (c) 1994 by NEBULA-Soft. }
      { Mausroutinen für Textmodus          } { Olaf Bartelt & Oliver Carow }
{ ═════════════════════════════ } INTERFACE { ═════════════════════════════ }
USES  DOS, video;                             { Einbinden der Units         }

{ The unit VIDEO is also included in the SWAG distribution in the CRT.SWG   }

{ ─ Konstantendeklarationen ─────────────────────────────────────────────── }
CONST cLinke_taste                 = 1;       { linke Maustaste             }
      cRechte_taste                = 2;       { rechte Maustaste            }
      cMittlere_taste              = 4;       { mittlere Maustaste (bei 3)  }

      cursor_location_changed      = 1;
      left_button_pressed          = 2;
      left_button_released         = 4;
      right_button_pressed         = 8;
      right_button_released        = 16;
      middle_button_pressed        = 32;
      middle_button_released       = 64;

      lastmask                     : WORD    = 0;
      lasthandler                  : POINTER = NIL;

      click_repeat                 = 10;
      mousetextscale               = 8;
      vgatextgraphiccursor         : BOOLEAN = FALSE;


{ ─ Typendeklarationen ──────────────────────────────────────────────────── }
TYPE  mousetype                    = (twobutton, threebutton, another);
      buttonstate                  = (buttondown, buttonup);
      direction                    = (moveright, moveleft, moveup, movedown,
nomove);

{ ─ Variablendeklarationen ──────────────────────────────────────────────── }
VAR   mouse_present                : BOOLEAN;
      mouse_buttons                : mousetype;
      eventx, eventy, eventbuttons : WORD;
      eventhappened                : BOOLEAN;
      xmotions, ymotions           : WORD;
      mousecursorlevel             : INTEGER;
      fontpoints                   : BYTE;

      maxmousex             : INTEGER;
      maxmousey                    : INTEGER;


{ ─ exportierte Prozeduren und Funktionen ───────────────────────────────── }
PROCEDURE set_graphic_mouse_cursor;        { graphischen Mousecursor setzen }
PROCEDURE showmousecursor;

{ ══════════════════════════ } IMPLEMENTATION { ═══════════════════════════ }
{$IFDEF VER60}                                { in TP 6.0 gibt es SEGxxxx   }
CONST SEG0040 = $0040;                        { noch nicht! => definieren!  }
      SEGB800 = $B800;
      SEGA000 = $A000;
{$ENDIF}

{ ─ Typendeklarationen ──────────────────────────────────────────────────── }
TYPE  pTextgraphikcursor = ^tTextgraphikcursor;  { Zeiger auf Array         }
      tTextgraphikcursor = ARRAY[0..31] OF LONGINT;

      box                = RECORD
                             left, top, right, bottom : WORD;
                           END;
      pChardefs          = ^tChardefs;
      tChardefs          = ARRAY[0..(32*8)] OF BYTE;

{ ─ Konstantendeklarationen ─────────────────────────────────────────────── }
CONST pfeil                  : tTextgraphikcursor =
{ Maske:  } ($3FFFFFFF, $1FFFFFFF, $0FFFFFFF, $07FFFFFF, $03FFFFFF, $01FFFFFF,
             $00FFFFFF, $007FFFFF, $003FFFFF, $007FFFFF, $01FFFFFF, $10FFFFFF,
             $B0FFFFFF, $F87FFFFF, $F87FFFFF, $FcFFFFFF,
{ Cursor: }  $00000000, $40000000, $60000000, $70000000, $78000000, $7C000000,
             $7E000000, $7F000000, $7F800000, $7F000000, $7C000000, $46000000,
             $06000000, $03000000, $03000000, $00000000);

      sanduhr : tTextgraphikcursor =        ($0001FFFF,  { 0000000000000001 }
                { Cursorform:      }         $0001FFFF,  { 0000000000000001 }
                                             $8003FFFF,  { 1000000000000011 }
                                             $C7C7FFFF,  { 1100011111000111 }
                                             $E38FFFFF,  { 1110001110001111 }
                                             $F11FFFFF,  { 1111000100011111 }
                                             $F83FFFFF,  { 1111100000111111 }
                                             $FC7FFFFF,  { 1111110001111111 }
                                             $F83FFFFF,  { 1111100000111111 }
                                             $F11FFFFF,  { 1111000100011111 }
                                             $E38FFFFF,  { 1110001110001111 }
                                             $C7C7FFFF,  { 1100011111000111 }
                                             $8003FFFF,  { 1000000000000011 }
                                             $0001FFFF,  { 0000000000000001 }
                                             $0001FFFF,  { 0000000000000001 }
                                             $0000FFFF,  { 0000000000000000 }
                                                { ^^^^ immer! (Textmodus)   }
                { Bildschirmmaske: }         $00000000,  { 0000000000000000 }
                                             $7FFC0000,  { 0111111111111100 }
                                             $20080000,  { 0010000000001000 }
                                             $10100000,  { 0001000000010000 }
                                             $08200000,  { 0000100000100000 }
                                             $04400000,  { 0000010001000000 }
                                             $02800000,  { 0000001010000000 }
                                             $01000000,  { 0000000100000000 }
                                             $02800000,  { 0000001010000000 }
                                             $04400000,  { 0000010001000000 }
                                             $08200000,  { 0000100000100000 }
                                             $10100000,  { 0001000000010000 }
                                             $20080000,  { 0010000000001000 }
                                             $7FFC0000,  { 0111111111111100 }
                                             $00000000,  { 0000000000000000 }
                                             $00000000); { 0000000000000000 }
                                                { ^^^^ immer! (Textmodus)   }

      vgatextgraphicptr      : pTextgraphikcursor = @pfeil;
                                                  { @sanduhr                }
{ ─ Variablendeklarationen ──────────────────────────────────────────────── }
VAR   hidebox                : box;
      regs                   : REGISTERS;
      vgastoredarray         : ARRAY[1..3, 1..3] OF BYTE;
      lasteventx, lasteventy : WORD;
      hasstoredarray         : BOOLEAN;
      oldexitproc            : POINTER;

CONST chardefs               : pChardefs = NIL;
      charheight             = 16;
      defchar                = $D0;


{ ─ exportierte Prozeduren und Funktionen ───────────────────────────────── }
procedure swap(var a,b : word);
var c : word;
begin
 c := a;
 a := b;
 b := c; {swap a and b}
end; {swap}

procedure setMouseCursor(x,y : word);
begin
 with regs do begin
  ax := 4;
  cx := x;
  dx := y; {prepare parameters}
  INTR($33, regs);
 end; {with}
end; {setMouseCursor}

FUNCTION x : WORD;
BEGIN
  regs.AX := 3;
  INTR($33, regs);
  x := regs.CX;
END;

FUNCTION y : WORD;
BEGIN
  regs.AX := 3;
  INTR($33, regs);
  y := regs.DX;
END;

procedure mouseBox(left,top,right,bottom : word);
begin
 if (left > right) then swap(left,right);
 if (top > bottom) then swap(top,bottom); {make sure they are ordered}
 regs.ax := 7;
 regs.cx := left;
 regs.dx := right;
 INTR($33, regs); {set x range}
 regs.ax := 8;
 regs.cx := top;
 regs.dx := bottom;
 INTR($33, regs); {set y range}
end; {mouseBox}


PROCEDURE initmouse;
VAR overridedriver : BOOLEAN;                 { wegen Hercules-Karten       }
    tempvideomode  : BYTE;                    { Zwischenspeicher für Modus  }
BEGIN
  overridedriver := FALSE;                    { erstmal nicht override!     }

  IF (FALSE AND (MEM[SEG0040:$0049] = 7)) THEN  { doch overriden?           }
  BEGIN
    MEM[SEG0040:$0049] := 6;                  { Ja: Videomodus vortäuschen  }
    overridedriver := TRUE;                   {     und override setzen!    }
  END;

  IF vgatextgraphiccursor = TRUE THEN         { Graphikcursor im Textmodus? }
  BEGIN
    tempvideomode := MEM[SEG0040:$0049];      { Videomodus zwischenspeichern}
    MEM[SEG0040:$0049] := 6;                  { anderen Modus vortäuschen   }
  END;

  WITH regs DO                                { Maustyp ermitteln           }
  BEGIN                                       { und Anzahl der Tasten auch  }
    AX := 0; BX := 0;                         { Maus initialisieren (00h)   }
    INTR($33, regs);                          { Mausinterrupt aufrufen      }

    mouse_present := (AX <> 0);               { überhaupt Maus vorhanden?   }
    IF (BX AND 2) <> 0 THEN mouse_buttons := twobutton  { Maustasten ermitt.}
                       ELSE IF (BX AND 3) > 0 THEN mouse_buttons := threebutton
                                              ELSE mouse_buttons := another;
  END;

  IF overridedriver = TRUE THEN MEM[SEG0040:$0049] := 7;  { override?       }
  IF vgatextgraphiccursor = TRUE THEN         { Graphikcursor im Textmodus? }
    MEM[SEG0040:$0049] := tempvideomode;      { Ja: Modus restaurieren!     }

  IF (NOT vgatextgraphiccursor) THEN fontpoints := mousetextscale
                                ELSE fontpoints := MEM[SEG0040:$0085];
  maxmousex := maxx * mousetextscale;         { Mausgrenzen ausrechnen      }
  maxmousey := maxy * fontpoints;

  mousebox(0, 0, (visiblex * mousetextscale)-1, (visibley * fontpoints)-1);
  eventbuttons := 0; eventhappened := FALSE;  { noch kein Event gewesen!    }

  xmotions := 8; ymotions := 16; mousecursorlevel := 0;  { Cursor nicht s.  }
  hasstoredarray := FALSE;                    { noch keine Daten im Array   }

  setmousecursor(visiblex * mousetextscale DIV 2, visibley * fontpoints DIV 2);
  eventx := x; eventy := y; lasteventx := eventx; lasteventy := eventy;
END;

PROCEDURE vgascreen2array(newposition, s2a, defaultrange : BOOLEAN);
VAR x, y : WORD;
    w, h : WORD;
    o, l : WORD;
    i, j : BYTE;
BEGIN
  IF (newposition = TRUE) THEN
  BEGIN
    x := eventx DIV mousetextscale;
    y := eventy DIV fontpoints;
  END
  ELSE
  BEGIN
    x := lasteventx DIV mousetextscale;
    y := lasteventy DIV fontpoints;
  END;

  w := visiblex - x; IF (w > 3) THEN w := 3;
  h := visibley - y; IF (h > 3) THEN h := 3;
  o := 2 * x + 2 * visiblex * y;
  l := 2 * visiblex - 2 * w;

  IF (defaultrange = TRUE) THEN
  BEGIN
    FOR i := 0 TO h - 1 DO
    BEGIN
      FOR j := 0 TO w - 1 DO
      BEGIN
        MEM[SEGB800:o] := defchar + i * 3 + j;
        INC(o, 2);
      END;
      INC(o, l);
    END;
  END
  ELSE
    IF (s2a = TRUE) THEN
    BEGIN
      FOR i := 1 TO h DO
      BEGIN
        FOR j := 1 TO w DO
        BEGIN
          vgastoredarray[i, j] := MEM[SEGB800:o];
          INC(o, 2)
        END;
        INC(o, l);
      END;
    END
    ELSE
    BEGIN
      FOR i := 1 TO h DO
      BEGIN
        FOR j := 1 TO w DO
        BEGIN
          MEM[SEGB800:o] := vgastoredarray[i, j];
          INC(o, 2);
        END;
        INC(o, l);
      END;
    END;
END;

PROCEDURE drawvgatextgraphiccursor;
TYPE  lp = ^LONGINT;
CONST sequencerport     = $3C4;
      sequenceraddrmode = $704;
      sequenceraddrnrml = $302;
      vgacontrolerport  = $3CE;
      cpureadmap2       = $204;
      cpuwritemap2      = $402;
      mapstartaddrA000  = $406;
      mapstartaddrB800  = $E06;
      oddevenaddr       = $304;
VAR   o, s              : WORD;
      i, j              : INTEGER;
      s1, s2, s3        : WORD;
      a                 : LONGINT;
      d, mc, ms         : lp;

BEGIN
  ASM
    PUSHF
    CLI
    MOV DX, sequencerport
    MOV AX, sequenceraddrmode
    OUT DX, AX
    MOV DX, vgacontrolerport
    MOV AX, cpureadmap2
    OUT DX, AX
    MOV AX, 5
    OUT DX, AX
    MOV AX, mapstartaddrA000
    OUT DX, AX
    POPF
  END;

   o := 0;
   FOR i := 1 TO 3 DO
   BEGIN
     s1 := vgastoredarray[i, 1] * 32;
     s2 := vgastoredarray[i, 2] * 32;
     s3 := vgastoredarray[i, 3] * 32;

     FOR j := 1 TO fontpoints DO
     BEGIN
       INC(o); chardefs^[o] := MEM[SEGA000:s3];
       INC(o); chardefs^[o] := MEM[SEGA000:s2];
       INC(o); chardefs^[o] := MEM[SEGA000:s1];
       INC(o); INC(s1); INC(s2); INC(s3);
     END;
   END;

   s := eventx MOD mousetextscale;
   a := $FF000000 SHL (mousetextscale - s);

   d  := @chardefs^[(eventy MOD fontpoints) * SIZEOF(LONGINT)];
   ms := @vgatextgraphicptr^;
   mc := @vgatextgraphicptr^[charheight];

   FOR i := 1 TO charheight DO
   BEGIN
     d^ := (d^ and ((ms^ shr s) or a)) or (mc^ shr s);
     INC(WORD(d), SIZEOF(LONGINT));
     INC(WORD(mc), SIZEOF(LONGINT));
     INC(WORD(ms), SIZEOF(LONGINT));
   END;

   ASM
     MOV DX, sequencerport
     MOV AX, cpuwritemap2
     OUT DX, AX
   END;

   o := 0;
   for i := 0 to 2 do begin
      s1 := (defChar + 3 * i    ) * 32;
      s2 := (defChar + 3 * i + 1) * 32;
      s3 := (defChar + 3 * i + 2) * 32;
      for j := 1 to fontPoints do begin
         inc(o); { skip 4th byte }
         mem[segA000:s3] := charDefs^[o];
            { this code is changed to minimize DS variable space ! - RL }
         inc(o);
         mem[segA000:s2] := charDefs^[o];
         inc(o);
         mem[segA000:s1] := charDefs^[o];
         inc(o);
         inc(s1);
         inc(s2);
         inc(s3);
      end; { for j }
   end; { for i }

   (* now we will return the graphic adapter back to normal *)

   asm
      pushf;
      cli; { disable intr .. }
      mov dx, sequencerPort;
      mov ax, sequencerAddrNrml;
      out dx, ax;
      mov ax, oddEvenAddr;
      out dx, ax;

      mov dx, vgaControlerPort;
      mov ax, 4; { map 0 for cpu reads }
      out dx, ax;
      mov ax, $1005;
      out dx, ax;
      mov ax, mapStartAddrB800;
      out dx, ax
      popf;
   end; { asm }

   vgaScreen2Array(true, false, true); { go ahead and paint it .. }

end; {drawVGATextGraphicCursor}

(******************************************************************************
*                               showMouseCursor                               *
******************************************************************************)
procedure showMouseCursor;

begin
 inc(mouseCursorLevel);
   if (not vgaTextGraphicCursor) then begin
    regs.ax:=1; {enable cursor display}
    INTR($33, regs);
   end else if ((mouseCursorLevel = 1) and mouse_present) then begin
      vgaScreen2Array(true, true, false);
      hasStoredArray := true;
      drawVGATextGraphicCursor;
   end;
end; {showMouseCursor}

(******************************************************************************
*                               hideMouseCursor                               *
******************************************************************************)
procedure hideMouseCursor;

begin
 dec(mouseCursorLevel);
   if (not vgaTextGraphicCursor) then begin
    regs.ax:=2; {disable cursor display}
    INTR($33, regs);
   end else if ((mouseCursorLevel = 0) and (hasStoredArray)) then begin
      vgaScreen2Array(false, false, false);
      hasStoredArray := false;
   end;
end; {hideMouseCursor}


(******************************************************************************
*                                  getButton                                  *
******************************************************************************)
function getButton(Button : Byte) : buttonState;

begin
        regs.ax := 3;
        INTR($33, regs);
        if ((regs.bx and Button) <> 0) then
                getButton := buttonDown
                {bit 0 = left, 1 = right, 2 = middle}
        else getButton := buttonUp;
end; {getButton}

(******************************************************************************
*                                buttonPressed                                *
******************************************************************************)
function buttonPressed : boolean;

begin
        regs.ax := 3;
        INTR($33, regs);
        if ((regs.bx and 7) <> 0) then
                buttonPressed := True
        else buttonPressed := False;
end; {buttonPressed}


(******************************************************************************
*                                 lastXPress                                  *
******************************************************************************)
function lastXPress(Button : Byte) : word;

begin
        regs.ax := 5;
        regs.bx := Button;
        INTR($33, regs);
        lastXPress := regs.cx;
end; {lastXpress}

(******************************************************************************
*                                 lastYPress                                  *
******************************************************************************)
function lastYPress(Button : Byte) : word;

begin
        regs.ax := 5;
        regs.bx := Button;
        INTR($33, regs);
        lastYPress := regs.dx;
end; {lastYpress}

(******************************************************************************
*                                buttonPresses                                *
******************************************************************************)
function buttonPresses(Button : Byte) : word; {from last check}

begin
        regs.ax := 5;
        regs.bx := Button;
        INTR($33, regs);
        buttonPresses := regs.bx;
end; {buttonPresses}

(******************************************************************************
*                                lastXRelease                                 *
******************************************************************************)
function lastXRelease(Button : Byte) : word;

begin
        regs.ax := 6;
        regs.bx := Button;
        INTR($33, regs);
        lastXRelease := regs.cx;
end; {lastXRelease}

(******************************************************************************
*                                lastYRelease                                 *
******************************************************************************)
function lastYRelease(Button : Byte) : word;

begin
        regs.ax := 6;
        regs.bx := Button;
        INTR($33, regs);
        lastYRelease := regs.dx;
end; {lastYRelease}

(******************************************************************************
*                               buttonReleases                                *
******************************************************************************)
function buttonReleases(Button : Byte) : word; {from last check}

begin
        regs.ax := 6;
        regs.bx := Button;
        INTR($33, regs);
        buttonReleases := regs.bx;
end; {buttonReleases}

(******************************************************************************
*                             HardwareTextCursor                              *
******************************************************************************)
procedure HardwareTextCursor(fromLine,toLine : byte);

{set text cursor to text, using the scan lines from..to,
        same as intr 10 cursor set in bios :
        color scan lines 0..7, monochrome 0..13 }

begin
        regs.ax := 10;
        regs.bx := 1; {hardware text}
        regs.cx := fromLine;
        regs.dx := toLine;
        INTR($33, regs);
end; {hardwareTextCursor}

(******************************************************************************
*                             softwareTextCursor                              *
******************************************************************************)
procedure softwareTextCursor(screenMask,cursorMask : word);

{ when in this mode the cursor will be achived by ANDing the screen word
        with the screen mask (Attr,Char in high,low order) and
        XORing the cursor mask, ussually used by putting the screen attr
        we want preserved in screen mask (and 0 into screen mask character
        byte), and character + attributes we want to set into cursor mask}

begin
        regs.ax := 10;
        regs.bx := 0;        {software cursor}
        regs.cx := screenMask;
        regs.dx := cursorMask;
        INTR($33, regs);
end; {softwareMouseCursor}

(******************************************************************************
*                               recentXmovement                               *
******************************************************************************)
function recentXmovement : direction;

{from recent call to which direction did we move ?}

var d : integer;

begin
        regs.ax := 11;
        INTR($33, regs);
        d := regs.cx;
        if (d > 0)
                then recentXmovement := moveRight
        else if (d < 0)
                then recentXmovement := moveLeft
        else recentXmovement := noMove;
end; {recentXmovement}

(******************************************************************************
*                               recentYmovement                               *
******************************************************************************)
function recentYmovement : direction;

{from recent call to which direction did we move ?}

var
   d : integer;
begin
        regs.ax := 11;
        INTR($33, regs);
        d := regs.dx;
        if (d > 0)
                then recentYmovement := moveDown
        else if (d < 0)
                then recentYmovement := moveUp
        else recentYmovement := noMove;
end; {recentYmovement}


(******************************************************************************
*                               setEventHandler                               *
******************************************************************************)
procedure setEventHandler(mask : word; handler        : pointer);

{handler must be a far interrupt routine }

begin
        regs.ax := 12; {set event handler function in mouse driver}
        regs.cx := mask;
        regs.es := seg(handler^);
        regs.dx := ofs(handler^);
        INTR($33, regs);
        lastMask := mask;
        lastHandler := handler;
end; {set event Handler}

(******************************************************************************
*                               defaultHandler                                *
******************************************************************************)
{$F+} procedure defaultHandler; assembler; {$F-}
asm
   push ds; { save TP mouse driver }
   mov ax, SEG @data;
   mov ds, ax; { ds = TP:ds, not the driver's ds }
   mov eventX, cx; { where in the x region did it occur }
   mov eventY, dx;
   mov eventButtons, bx;
   mov eventHappened, 1; { eventHapppened := true }
   pop ds; { restore driver's ds }
   ret;
end;

{   this is the default event handler , it simulates :

      begin
               eventX := cx;
               eventY := dx;
               eventButtons := bx;
               eventhappened := True;
      end;

}

(******************************************************************************
*                                doPascalStuff                                *
* this is the pascal stuff that is called when vgaTextGraphicCursor mode has  *
* to update the screen.                                                       *
******************************************************************************)
procedure doPascalStuff; far;
begin
   if (mouseCursorLevel > 0) then begin
      if (hasStoredArray) then begin
         VGAscreen2Array(false, false, false); { move old array to screen -
restore }
         hasStoredArray := false;
      end;
      if (mouseCursorLevel > 0) then begin
         VGAscreen2Array(true, true, false); { move new - from screen to array
}
         hasStoredArray := true; { now we have a stored array }
         drawVGATextGraphicCursor; { do the low level stuff here }
         lastEventX := eventX;
         lastEventY := eventY; { this is the old location }
      end; { go ahead and draw it ... }
   end; { cursorLevel > 0 }
end; {doPascalStuff}

(******************************************************************************
*                            vgaTextGraphicHandler                            *
* this is the same as default handler, only we do the mouse location movement *
* ourself. Notice - if you use another handler, for mouse movement with       *
* VGA text graphic cursor - do the same !!!                                   *
******************************************************************************)
procedure vgaTextGraphicHandler; far; assembler;
label
   noCursorMove;
asm
   push ds; { save TP mouse driver }
   push ax;
   mov ax, SEG @data;
   mov ds, ax; { ds = TP:ds, not the driver's ds }
   pop ax; { ax has the reason .. }
   mov eventX, cx; { where in the x region did it occur }
   mov eventY, dx;
   mov eventButtons, bx;
   mov eventHappened, 1; { eventHapppened := true }
   and ax, CURSOR_LOCATION_CHANGED; { o.k., do we need to handle mouse movement? }
   jz noCursorMove;
   call doPascalStuff;
   mov eventHappened, 0;
   { NOTICE - no movement events are detected in the out world ! - this is a
     wintext consideration - It might be needed to track mouse movements,
     and then it should be changed ! - but this is MY default handler ! }
noCursorMove: { no need for cursor movement handling }
   pop ds; { restore driver's ds }
end; {vgaTextGraphicHandler}

(******************************************************************************
*                                GetLastEvent                                 *
******************************************************************************)
function GetLastEvent(var x,y : word;
        var left_button,right_button,middle_button : buttonState) : boolean;

begin
        getLastEvent := eventhappened; {indicate if any event happened}
        eventhappened := False; {clear to next read/event}
        x := eventX;
        y := eventY;
        if ((eventButtons and cLinke_taste) <> 0) then
                left_button := buttonDown
        else left_button := buttonUp;
        if ((eventButtons and cRechte_taste) <> 0) then
                right_button := buttonDown
        else right_button := buttonUp;
        if ((eventButtons and cMittlere_taste) <> 0) then
                middle_button := buttonDown
        else middle_button := buttonUp;
end; {getLastEvent}

(******************************************************************************
*                              setDefaultHandler                              *
******************************************************************************)
procedure setDefaultHandler(mask : WORD);

{get only event mask, and set event handler to defaultHandler}

begin
   if (vgaTextGraphicCursor) then begin
      mask := mask or CURSOR_LOCATION_CHANGED; { we MUST detect cursor movement
}
           setEventHandler(mask,@vgaTextGraphicHandler);
   end else
           setEventHandler(mask,@defaultHandler);
end; {setDefaultHandler}

(******************************************************************************
*                              defineSensetivity                              *
******************************************************************************)
procedure defineSensetivity(x,y : word);

begin
        regs.ax := 15;
        regs.cx := x; {# of mouse motions to horizontal 8 pixels}
        regs.dx := y; {# of mouse motions to vertical 8 pixels}
        INTR($33, regs);
        XMotions := x;
        YMotions := y; {update global unit variables}
end; {defineSensetivity}

(******************************************************************************
*                              setHideCursorBox                               *
******************************************************************************)
procedure setHideCursorBox(left,top,right,bottom : word);

begin
        regs.ax := 16;
        regs.es := seg(HideBox);
        regs.dx := ofs(HideBox);
        HideBox.left := left;
        HideBox.right := right;
        HideBox.top := top;
        HideBox.bottom := bottom;
        INTR($33, regs);
end; {setHideCursorBox}

(******************************************************************************
*                               waitForRelease                                *
* Wait until button is release, or timeOut 1/100 seconds pass. (might miss a  *
* tenth (1/10) of a second.                                                                                                                     *
******************************************************************************)
procedure waitForRelease(timeout : WORD);
var
    sHour, sMinute, sSecond, sSec100 : word;        { Time at start }
    cHour, cMinute, cSecond, cSec100 : word;        { Current time        }
    stopSec                             : longInt;
    currentSec                          : longInt;
    Delta                             : longInt;
begin
    getTime(sHour, sMinute, sSecond, sSec100);
    stopSec := (sHour*36000 + sMinute*600 + sSecond*10 + sSec100 + timeOut) mod
                    (24*360000);
    repeat
           getTime(cHour, cMinute, cSecond, cSec100);
           currentSec := (cHour*36000 + cMinute*600 + cSecond*10 + cSec100);
           Delta := currentSec - stopSec;
    until (not ButtonPressed) or (Delta >=0) and (Delta < 36000);
end; {waitForRelease}

(******************************************************************************
*                              swapEventHandler                               *
* handler is a far routine.                                                   *
******************************************************************************)
procedure swapEventHandler(mask : WORD; handler : POINTER);
begin
   regs.ax := $14;
   regs.cx := mask;
        regs.es := seg(handler^);
        regs.dx := ofs(handler^);
        INTR($33, regs);
   lastMask := regs.cx;
   lastHandler := ptr(regs.es,regs.dx);
end; {swapEventHandler}

(******************************************************************************
*                            getMouseSaveStateSize                            *
******************************************************************************)
function getMouseSaveStateSize : WORD;
begin
   regs.ax := $15;
   INTR($33, regs);
   getMouseSaveStateSize := regs.bx;
end; {getMouseSaveStateSize}

(******************************************************************************
*                           setVgaTextGraphicCursor                           *
******************************************************************************)
procedure setVgaTextGraphicCursor;
begin
   vgaTextGraphicCursor := false; { assume we can not .. }
   if (queryAdapterType <> vgaColor) then
      exit;
   vgaTextGraphicCursor := true;
end; {setVgaTextGraphicCursor}

(******************************************************************************
*                          resetVgaTextGraphicCursor                          *
******************************************************************************)
PROCEDURE resetvgatextgraphiccursor;
BEGIN
  vgatextgraphiccursor := FALSE;
END;

PROCEDURE myexitproc; FAR;
BEGIN
  EXITPROC := oldexitproc;
  IF (vgatextgraphiccursor AND hasstoredarray) THEN
    vgascreen2array(FALSE, FALSE, FALSE);
  DISPOSE(chardefs);
  resetvgatextgraphiccursor;
  initmouse;
END;

PROCEDURE set_graphic_mouse_cursor;         { graphischen Mauscursor setzen }
BEGIN
  setvgatextgraphiccursor; initmouse; setdefaulthandler(left_button_pressed);
END;

{ ─ Hauptprogramm der Unit ──────────────────────────────────────────────── }
BEGIN
   eventx := 0; eventy := 0; eventhappened := FALSE;
   NEW(chardefs); initmouse;
   oldexitproc := EXITPROC;
   EXITPROC    := @myexitproc;
END.

