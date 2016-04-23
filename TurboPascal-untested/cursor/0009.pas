(*
===========================================================================
 BBS: Canada Remote Systems
Date: 05-28-93 (05:36)             Number: 8641
From: LOU DUCHEZ                   Refer#: NONE
  To: KURT TAN                      Recvd: NO
Subj: CURSOR CONTROL                 Conf: (58) PASCAL
---------------------------------------------------------------------------
KT>Can someone tell me how to make the cursor in Turbo Pascal disappear and
KT>appear?

Whah, sher, li'l pardner.  There is *no* function to turn off the cursor
per se in Pascal or among the BIOS interrupts.  However, you can change
the appearance of the cursor, making it span 0 pixels (as opposed to the
usual 2).  And to this purpose, I've included some of my favorite cursor
routines, stored in a prize Unit of mine.

To define a cursor, you need to store the format in a word.  The standard
cursor for, say, CGA is $8786 (I think); the "6" and "7" say that the
cursor starts at pixel 7 and ends at pixel 6.  The eights mean that there
are eight pixels to be messing with -- honestly that's a guess, I've
never seen it in a book anywhere.  For VGA and Hercules, I'm pretty sure
you have 15 pixels to work with; the normal cursor there is something like
$fefc (something like that -- I'm working off CGA, so it's hard for me to
test that theory).  In either case, no matter the graphics system, a good
way to turn off the cursor is to set it to $ffff.
*)

procedure cursoff;
const ffff: word = $ffff;

{ Turns the cursor off.  Stores its format for later redisplaying. }

begin
  asm
    mov ah, 03h
    mov bh, 00h
    int 10h
    mov crstyp, cx   { global variable -- for later retrieval }
    mov ah, 01h
    mov cx, ffff
    int 10h
    end;
  end;


procedure curson;

{ Turns the cursor back on, using the cursor display previously stored. }

begin
  asm
    mov ah, 01h
    mov cx, crstyp   { previously-stored cursor format }
    int 10h
    end;
  end;


function getcursor: word;

{ Returns the cursor format. }

var tempword: word;
begin
  asm
    mov ah, 03h
    mov bh, 00h
    int 10h
    mov tempword,cx
    end;
  getcursor := tempword;
  end;


procedure setcursor(curstype: word);

{ Sets the cursor format. }

var tempword: word;
begin
  tempword := curstype;
  asm
    mov ah, 01h
    mov cx,tempword
    int 10h
    end;
  end;

