{
Here a nice unit to control the DOS Printer spooler (PRINT.COM/EXE).
It's a extended/modified/debugged version of some program I found
elsewere. By controlling the DEFINE the source changes from PROGRAM
to UNIT. Just load good PRINT, Compile the demo and try to print some.
Watch your paper supply !!

{---------------------------------------------------------}
{ Original by Brian Ebarb Power Software Company -        }
{             Houston, TX (713)781-9784                   }
{                                                         }
{ Modified by G.W. van der Vegt                           }
{---------------------------------------------------------}

{ DEFINE UNIT}
{$IFDEF  UNIT}

UNIT Spooler;

INTERFACE

{$ELSE}

USES
  crt,
  dos;

{$ENDIF}

CONST
  queue_max         = 10;
  queue_namlen      = 64;

TYPE
{----Queue types}
  queue_action      = 1..5;
  queue_printer     = 1..4;
  queue_name        = STRING[queue_namlen-1];
  queue_type        = ARRAY[1..queue_max] OF queue_name;

CONST
{----Queue actions}
  queue_submit      = 1;
  queue_kill        = 2;
  queue_purge       = 3;
  queue_hold        = 4;
  queue_continue    = 5;

{----Queue results}
  queue_ok          = $00;
  queue_invfie      = $01;
  queue_nofile      = $02;
  queue_nopath      = $03;
  queue_nohandles   = $04;
  queue_noaccess    = $05;
  queue_full        = $08;
  queue_busy        = $09;
  queue_missing     = $0a; {----self defined returncode,
                                returned IF called AND NOT
                                installed.}
  queue_longname    = $0c;
  queue_nowprinting = $9e;

VAR
  queue             : queue_type;

{$IFDEF UNIT}

FUNCTION Spool(filestring : queue_name;
               theprinter : queue_printer;
               action     : queue_action) : WORD;

{---------------------------------------------------------}

IMPLEMENTATION

USES
  crt,
  dos;

{---------------------------------------------------------}

{$ENDIF}

FUNCTION Spool(filestring : queue_name;
               theprinter : queue_printer;
               action     : queue_action) : WORD;

CONST
{----MPX interrupt const}
  queue_int         = $2f;
  queue_mpx         = $01;
  queue_check       = $00;
  queue_installed   = $ff;

TYPE
  fnames  = ARRAY[1..queue_namlen] OF CHAR;
  res     = ARRAY[1..32768 DIV Sizeof(fnames)] OF fnames;

VAR
  p       : ^res;
  regs    : registers;
  fname   : fnames;
  thefile : RECORD
              prn  : BYTE;
              loc  : ARRAY[1..2] OF WORD;
            END;
  i,j     : INTEGER;

BEGIN
  Fillchar(fname, Sizeof(fname), #0);
  Move(filestring[1],fname[1],Length(filestring));

  thefile.prn    := theprinter - 1;
  thefile.loc[2] := Seg(fname);
  thefile.loc[1] := Ofs(fname);

{----Check installation}
  regs.ah := queue_mpx;
  regs.al := queue_check;

  Intr(queue_int, regs);
  IF (regs.al<>queue_installed)
  {----on return, 10 = "not installed" }
    THEN Spool:=queue_missing
    ELSE
      CASE action OF
               {----Spool a FILE, return error OR
                                  00 IF no error
                                  01 IF added TO queue OR
                                  9e IF printing           }
  queue_submit : BEGIN
                   regs.ah:=queue_mpx;
                   regs.al:=queue_submit;
                   regs.ds:=Seg(thefile);
                   regs.dx:=Ofs(thefile);

                   Intr(queue_int, regs);

                   IF ((regs.flags AND fcarry) = fcarry)
                     THEN Spool:=regs.ax
                     ELSE Spool:=regs.al;
                 END;
               {----Dequeue a file, Returns Error or ok }
    queue_kill : BEGIN
                   regs.ah:=queue_mpx;
                   regs.al:=queue_kill;
                   regs.ds:=thefile.loc[2];
                   regs.dx:=thefile.loc[1];

                   Intr(queue_int, regs);

                   IF ((regs.flags AND fcarry) = fcarry)
                     THEN Spool := regs.ax
                     ELSE Spool := queue_ok;
                 END;

               {----Deque ALL files, Returns Error or ok }
   queue_purge : BEGIN
                   regs.ah := queue_mpx;
                   regs.al := queue_purge;

                   Intr(queue_int, regs);

                   IF ((regs.flags AND fcarry) = fcarry)
                     THEN Spool := regs.ax
                     ELSE Spool := queue_ok;
                 END;

               {----Hold queue, returns error OR
                                no. OF errors since last hold (dx) ?
                                (seems TO be no. OF looks at Printer port) &
                                queue RECORD WITH first queue_max filenames}
    queue_hold : BEGIN
                   regs.ah:=queue_mpx;
                   regs.al:=queue_hold;

                   Intr(queue_int, regs);

                   IF ((regs.flags AND fcarry) = fcarry)
                     THEN Spool := regs.ax
                     ELSE
                     {----Fill & return the queue record}
                       BEGIN
                         Spool:=queue_ok; {Regs.dx}
                         p:=Ptr(regs.ds,regs.si);

                         FOR i:=1 TO queue_max DO queue[i]:='';
                         i:=1;
                         WHILE (p^[i,1]<>#00) AND (i<=queue_max) DO
                           BEGIN
                             j:=1;
                             WHILE (p^[i,j]<>#00) DO
                               BEGIN
                                 queue[i]:=queue[i]+p^[i,j];
                                 Inc(j);
                               END;
                             Inc(i);
                           END;
                       END;
                 END;

            {----Restart queue after function 4, Returns error or ok }
queue_continue : BEGIN
                   regs.ah:=queue_mpx;
                   regs.al:=queue_continue;

                   Intr(queue_int, regs);

                   IF ((regs.flags AND fcarry) = fcarry)
                     THEN Spool := regs.ax
                     ELSE Spool := queue_ok;
                 END;
      END;

END; {of Spool}

{$IFNDEF UNIT}

{---------------------------------------------------------}
{----MAIN PROGRAM                                         }
{---------------------------------------------------------}

VAR
  i : INTEGER;

BEGIN
  FOR i:=1 TO queue_max DO queue[i]:='';

  REPEAT
    Writeln('Type cmd : 1 = submit, 2 = kill, 3 = purge, 4 = hold, 5 = continue

    CASE Readkey OF
      #27 : Halt;
      '1' : Writeln('Function 1, result = ',Spool('\AUTOEXEC.BAT',1,queue_submi
      '2' : Writeln('Function 2, result = ',Spool('\AUTOEXEC.BAT',1,queue_kill
      '3' : Writeln('Function 3, result = ',Spool('',1,queue_purge   ));
      '4' : BEGIN
              Writeln('Function 4, result = ',Spool('',1,queue_hold    ));
              Writeln('Queue : ');
              FOR i:=1 TO queue_max DO
                IF (queue[i]<>'')
                  THEN Writeln(i:2,' ',queue[i]);
            END;
      '5' : Writeln('Function 5, result = ',Spool('',1,queue_continue));
    END;
  UNTIL true=false;

{$ENDIF}

END.
