(*
  Category: SWAG Title: CURSOR HANDLING ROUTINES
  Original name: 0017.PAS
  Description: CURSOR Control
  Author: LIM FUNG
  Date: 10-28-93  11:29
*)

{===========================================================================
Date: 08-27-93 (14:17)
From: LIM FUNG
Subj: cursor control

WD>Hi All,
WD>   Hey, someone put a couple of little proc. on here which control the
WD>cursor (turn it on/off) and they were written in assembler.  I had a
WD>brain fade and forgot to save the name of the person who created these
WD>routines.  I was wondering if they might know how to get a big cursor
WD>also using assembler.  Also, do they work on monochrome monitors, or was
WD>that what you meant about the 8x8 scan lines?

Okay, a simple procedure to turn on and off the cursor would be as
follows: }


Uses DOS;

Procedure CursorOn;
Begin
        asm
                mov        ax,0100h
                mov        cx,0607h
                int        10h
        end;
end;

Procedure CursorOff;
Begin
        asm
                mov        ax,0100h
                mov        cx,2020h
                int        10h
        end;
end;

end.

===========================================================================
 BBS: Canada Remote Systems
Date: 10-23-93 (07:59)             Number: 9355
From: LOU DUCHEZ                   Refer#: NONE
  To: JESSE MACGREGOR               Recvd: NO  
Subj: help                           Conf: (1617) L-Pascal
---------------------------------------------------------------------------
JM>I need help I need a function that when I give it a screen coordiante
JM>and it returns the charachter at that coordinate on a text screen
JM>(80x25) and possibly the color...

Try this:

-------------------------------------------------------------------------------

type  videolocation = record                  { video memory locations }
          videodata: char;                    { character displayed }
          videoattribute: byte;               { attributes }
          end;

---------------

procedure getvideodata(x, y: byte; var result: videolocation);

{ Returns the attribute byte of a video character. }

var vidptr: ^videolocation;
begin
  if memw[$0040:$0049] = 7 then vidptr := ptr($b000, 2*(80*(y-1) + (x-1)))
                           else vidptr := ptr($b800, 2*(80*(y-1) + (x-1)));
  result := vidptr^;
  end;

-------------------------------------------------------------------------------


JM>also, a procedure to make that icky
JM>cursor go away would be greatly appreciated...

There's not really a procedure to make it "go away", just to change it.
You CAN change it so that it's undisplayable, but you'll want to store
the previous config first.  Like so:

-------------------------------------------------------------------------------

var crstyp: word;

---------------

procedure cursoff;
const ffff: word = $ffff;

{ Turns the cursor off.  Stores its format for later redisplaying. }

begin
  asm
    mov ah, 03h
    mov bh, 00h
    int 10h
    mov crstyp, cx
    mov ah, 01h
    mov cx, ffff
    int 10h
    end;
  end;

---------------

procedure curson;

{ Turns the cursor back on, using the cursor display previously stored. }

begin
  asm
    mov ah, 01h
    mov cx, crstyp
    int 10h
    end;
  end;

-------------------------------------------------------------------------------

How's that, o evil masters?
---
 ■ KingQWK 1.05 # 182 ■ "Bob" -- the Doc Savage of holy men
 ■ RoseMail 2.10ß: ILink: PC-Ohio * Cleveland, OH * 216-381-3320

