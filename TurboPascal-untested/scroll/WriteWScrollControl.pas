(*
  Category: SWAG Title: SCREEN SCROLLING ROUTINES
  Original name: 0005.PAS
  Description: Write w/ Scroll Control
  Author: LOU DUCHEZ
  Date: 06-08-93  08:17
*)

(*
===========================================================================
 BBS: Canada Remote Systems
Date: 06-01-93 (06:21)             Number: 24456
From: LOU DUCHEZ                   Refer#: NONE
  To: MICHAEL DEAKINS               Recvd: NO  
Subj: ANSI, BATCH FILE EXEC'ING      Conf: (1221) F-PASCAL
---------------------------------------------------------------------------
MD>I have two questions. First, How can I display ANSI files from a Pascal
MD>program by using the CON driver (read: ANSI.SYS) instead of going to the
MD>trouble of writing a terminal emulator, and still remain
MD>window-relative? I used TP5.5's WRITE procedure to write to a file
MD>assigned to the CON device instead of the CRT unit's standard OutPut,
MD>but this obliterated my status line at the bottom of the screen when the
MD>ANSI file scrolled. Is there an easy way to write to the CON device
MD>while remaining window-relative without having to modify ANSI.SYS or
MD>write a terminal emulation procedure?
MD> My second question: How can I call a batch file from within a Pascal
MD>program and pass %1-%9 parameters to it? I'm aware of the EXEC
MD>procedure, but doesn't that only work on executables?

Second question first: you're right about EXEC calling only executables.
So try calling "COMMAND.COM" as your program, and give it parameters of
"/C " plus the batch file name plus whatever arguments you intend to pass.
(That tells the system to run a single command out of DOS.)  Look up
ParamCount and ParamStr() to see how Pascal uses command-line parameters.

First question second: you know, I addressed this problem just yesterday
trying to write a program.  I concluded that, if you're going to bypass
CRT, you need to do a lot of "manual" work yourself to keep a window
going.  Let me show you the tools I devised:
*)


{---PROCEDURE ATSCROLL: SCROLLS A SCREEN REGION UP OR DOWN (negative or
   positive number in LINESDOWN, respectively) }

procedure atscroll(x1, y1, x2, y2: byte; linesdown: integer);
var tmpbyte, intbyte, clearattrib: byte;
begin
  if linesdown <> 0 then begin
    clearattrib := foxfore + foxback shl 4;
    x1 := x1 - 1;
    y1 := y1 - 1;
    x2 := x2 - 1;
    y2 := y2 - 1;
    if linesdown > 0 then intbyte := $07 else intbyte := $06;
    tmpbyte := abs(linesdown);
    asm
      mov ah, intbyte
      mov al, tmpbyte
      mov bh, clearattrib
      mov ch, y1
      mov cl, x1
      mov dh, y2
      mov dl, x2
      int 10h
      end;
    end;
  end;



{---FUNCTION YPOS: Returns the line the cursor is on.  I wrote it because
   I don't always trust WHEREY (or WHEREX): they report, for example, the
   cursor position relative to a text window.  So I had it lying around,
   and I opted to use it in my routines.                                 }

function ypos: byte;
var tmpbyt: byte;
begin
  asm
    mov ah, 03h
    mov bh, 0
    int 10h
    mov tmpbyt, dh
    end;
  ypos := tmpbyt + 1;
  end;



{--- PROCEDURE WRITEANDFIXOVERHANG: I use it in place of WRITELN in my
    program: before writing a line of text, it checks if there's room
    at the bottom of the screen.  If not, it scrolls the screen up
    before writing.  Keep in mind that this program is bent on preserving
    the top three or four screen lines, not the bottom lines. }

procedure writeandfixoverhang(strin: string);
const scrollat: byte = 24;
var overhang: byte;
begin
  if ypos >= scrollat then begin
    overhang := ypos - scrollat + 1;
    atscroll(0, 4 + overhang, 0, 80, 25, -overhang);
    movecursor(1, ypos - overhang);
    end;
  writeln(strin);
  end;

{
So assuming your text lines don't get too long (line longer than 160 chars),
these routines will keep the top of your screen from getting eaten.  If you
want to preserve space at the bottom of the screen instead (or both top and
bottom), change WRITEANDFIXOVERHANG.

BTW, if there are any compiling problems, let me know.  I took out all the
stuff that applied specifically to my application -- I might have stupidly
changed something you need ... }

