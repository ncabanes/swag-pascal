(*
  Category: SWAG Title: MEMORY/DPMI MANAGEMENT ROUTINES
  Original name: 0055.PAS
  Description: Call Stack Reporter
  Author: WIM VAN DER VEGT
  Date: 08-24-94  13:29
*)

{---------------------------------------------------------}
{  Project : Call Stack Reporter                          }
{  Auteur  : Ir. G.W. van der Vegt                        }
{            Hondsbroek 57                                }
{            6121 XB Born                                 }
{---------------------------------------------------------}
{  Datum .tijd  Revisie                                   }
{  920713.2100  Creatie.                                  }
{  920715.2330  Trace at normal exit (exitcode=0) removed.}
{  920805.2230  Path removed from filename in trace       }
{  920806.2200  Blanks filled in, RunTime Library routines}
{               now traced to.                            }
{  921026.2000  Textmode(lastmode) added to default       }
{               Csr_report. Objects & overlay tracing     }
{               tested.                                   }
{  921118.1400  Exitcode doesn't trigger trace anymore    }
{  931114.1430  Keyboard flush in exitprocedure           }
{  940201.2200  Made independed of Routines.              }
{---------------------------------------------------------}
{  To do        Trace Virtual Methode Table (VMT)         }
{---------------------------------------------------------}

{$D+}
{$L+}

{---------------------------------------------------------}
{----This unit gives the line numbers & filenames at error}
{    The result is a list of the call stack as produced by}
{    the Turbo Pascal IDE.                                }
{                                                         }
{    The internal text mode report function can be        }
{    replaced by another one located in your program.     }
{    This could be a graphics mode or printer version. It }
{    must be compiled far (so use $F+ & $F- around it.    }
{    It's called once for each call level.                }
{                                                         }
{    This program parses the MAP file to obtain the       }
{    line numbers. It searches for the MAP file in the    }
{    programs startup directory as obtained by            }
{    PARAMSTR(0).                                         }
{---------------------------------------------------------}
{    To obtain all possible info compile with the         }
{    following setting :                                  }
{                                                         }
{    OPTIONS/LINKER/MAP FILE      = DETAILED              }
{    OPTION/COMPILE/DEBUG INFO    = ON                    }
{                                                         }
{    The last can also be forced by the $D+ compiler      }
{    directive .                                          }
{                                                         }
{    This version traces procedures, functions through    }
{    the main program and it's (overlayed) units. It also }
{    traces static methodes but not virtual methodes.     }
{    When tracing static methodes a phantom entry with    }
{    an call address located oon the heap is generated.   }
{    The trace is stopped at the first call to a virtual  }
{    methode. In a future version VMT tracing will be     }
{    added as soon as I start using virtual methodes.     }
{---------------------------------------------------------}

UNIT CSR_01;

INTERFACE

{---------------------------------------------------------}
{----TYPES                                                }
{---------------------------------------------------------}

TYPE
  Csr_repfunc  = PROCEDURE(level : Word;csr : STRING);

{---------------------------------------------------------}
{----VARIABLES                                            }
{---------------------------------------------------------}

VAR
  Csr_reporter : Csr_repfunc;

{---------------------------------------------------------}
{----PROCEDURES/FUNCTIONS                                 }
{---------------------------------------------------------}

PROCEDURE Csr_report(level : Word;csr : STRING);

{---------------------------------------------------------}

IMPLEMENTATION

Uses
  CRT,
  DOS;

VAR
  ext     : extstr;
  dir     : dirstr;
  nam     : namestr;
  mapfile : BOOLEAN;
  map     : Text;
  ft      : BOOLEAN;

CONST
  space   = #32;

{---------------------------------------------------------}
{----SUPPORT PROCEDURES & FUNCTIONS                       }
{---------------------------------------------------------}

FUNCTION Istr(i,n : INTEGER;pad : CHAR) : STRING;

VAR
  s : STRING;

BEGIN
  Str(i:n,s);
  IF (pad<>space)
    THEN
      WHILE (Pos(space,s)>0) DO
        s[Pos(space,s)]:=pad;
  Istr:=s;
END; {of Istr}

{---------------------------------------------------------}

FUNCTION  Wstr(w : WORD;n : INTEGER) : STRING;

VAR
  s : STRING;

BEGIN
  Str(w:n,s);
  Wstr:=s;
END; {of Wstr}

{---------------------------------------------------------}

FUNCTION  Sstr(s : STRING;n : INTEGER) : STRING;

VAR
  tmp : STRING;

BEGIN
  tmp:=s;
  IF n>=0
    THEN WHILE (Length(tmp)<+n) DO Insert(space,tmp,1)
    ELSE WHILE (Length(tmp)<-n) DO tmp:=tmp+space;
  Sstr:=tmp;
END; {of Sstr}

{---------------------------------------------------------}

PROCEDURE Beep;

BEGIN
  Sound(500);
  Delay(20);
  Nosound;
END; {of Beep}

{---------------------------------------------------------}

FUNCTION Word2Hex(w : Word) : STRING;

const
  hexChars : array [0..$F] of Char = '0123456789ABCDEF';

begin
  Word2Hex :=hexChars[Hi(w) shr 4]+hexChars[Hi(w) and $F]+
             hexChars[Lo(w) shr 4]+hexChars[Lo(w) and $F];
end; {of Word2Hex}

{---------------------------------------------------------}

Function Hex2Word(h : String) : word;

const
  hexChars : String[16] = '0123456789ABCDEF';

var
  f : word;

begin
  f := 0;
  while length(h) > 0 do
     begin
       if pos(Copy(h,1,1),HexChars) = 0
         then f := 0
         Else f := (f*16)+pos(H[1],Hexchars)-1;
       delete(h,1,1);
     end;
  Hex2Word:= f;
end; {of Hex2Word}

{---------------------------------------------------------}

FUNCTION Ptr2Hex(p : POINTER) : STRING;

BEGIN
  IF (p=nil)
    THEN Ptr2Hex := '   NIL   '
    else Ptr2Hex := Word2hex(Seg(P^))+':'+Word2hex(Ofs(P^));
END; {of Ptr2Hex}

{---------------------------------------------------------}

Procedure FlushKbd;

Begin
  MemW[$40:$1C]:=MemW[$40:$1A];
End; {of Fluskkbd}

{---------------------------------------------------------}
{----STACK TRACE ROUTINES START HERE                      }
{---------------------------------------------------------}

FUNCTION BPreg : WORD;

INLINE($55/$58); {Push BP, Pop AX}

{---------------------------------------------------------}

Procedure Findlineno(first,near : BOOLEAN;dep : Word;p : Pointer);

VAR
  tmp     : String[80];

  line    : Integer;
  adr     : String[9];
  ch      : Char;

  fn      : STRING[80];
  un      : STRING[80];

  errseg,
  errofs  : Word;

  s,
  lastun,
  lastpr,
  lastfn  : STRING[80];
  lastnr  : Word;
  call    : STRING[4];

BEGIN
  IF near
    THEN call:='near'
    ELSE call:='far ';

  errseg:=Hex2word(Copy(Ptr2hex(p),1,4));
  errofs:=Hex2word(Copy(Ptr2hex(p),6,4));

  lastnr:=0;
  lastfn:='';
  lastpr:='';
  lastun:='';

  Assign(map,dir+nam+'.MAP');
  {$I-} Reset(map); {$I+}
  IF (IOResult=0)
    THEN
      BEGIN
      {----Fist try on unit/program name}
        s:='';
{
 00000H 00096H 00097H VALTOREN           CODE

  Address         Publics by Value
}
        WHILE NOT(Eof(map) OR
                  (Pos('Publics by Value',s)>0) OR
                  (Pos('Line numbers'   ,s)>0)) DO
          BEGIN
            Readln(map,s);
            IF (Length(s)>=45) AND (s[7]='H')
              THEN
                BEGIN
                  IF (Errseg=Hex2Word(Copy(s,2,4))) {AND
                     (Copy(s,42,4)='CODE')}
                    THEN lastun:=Copy(s,23,18);
                END;
          END;

      {----Strip Trailing Blanks}
        WHILE (Length(lastun)>0) AND
              (lastun[Length(lastun)]=#32) DO
          Delete(lastun,Length(lastun),1);

      {----Second Try to find procedure name}
        s:='';
{
  Address         Publics by Value

 0000:0000       @
 000A:00CB       MENU_INIT
}
        WHILE NOT(Eof(map) OR
                  (Pos('Line numbers',s)>0)) DO
          BEGIN
            Readln(map,s);
            IF (Length(s)>=18) AND (s[6]=':')
              THEN
                BEGIN
                  IF (Errseg=Hex2Word(Copy(s,2,4)))
                    THEN
                      BEGIN
                        IF (lastpr='')
                          THEN lastpr:=Copy(s,18,Length(s)-17)
                          ELSE
                            IF (Errofs>=Hex2Word(Copy(s,7,4)))
                              THEN lastpr:=Copy(s,18,Length(s)-17);
                      END;
                END;
          END;

      {----Strip Trailing Blanks}
        WHILE (Length(lastpr)>0) AND
              (lastpr[Length(lastpr)]=#32) DO
          Delete(lastpr,Length(lastpr),1);

      {----Third try on line numbers & sourcefile names}
        REPEAT
{
  Line numbers for TEST_ERROR(TEST_ERR.PAS) segment TEST_ERROR
}
          IF (Pos('Line numbers',s)>0)
            THEN
              BEGIN
                Delete(s,1,17);
                un:=Copy(s,1,Pos('(',s)-1);
                Delete(s,1,Pos('(',s));
                fn:=Copy(s,1,Pos(')',s)-1);

                While Pos('\',fn)>0 DO Delete (fn,1,Pos('\',fn));

                Readln(map);
                REPEAT
{
  15 0000:0008    16 0000:0017    18 0000:00C4    28 0000:00D2
}
                  Read(map,line);
                  Read(map,ch);
                  Read(map,adr);
                  IF (Errseg=Hex2Word(Copy(adr,1,4)))
                    THEN
                      BEGIN
                        lastfn:=fn;
                        IF (Errofs>=Hex2Word(Copy(adr,6,4)))
                          THEN lastnr:=line;
                      END;

                  If Eoln(map)
                    Then Readln(map);

                UNTIL Eoln(map);
              END;

            IF NOT(eof(map))
              THEN Readln(map,s);

          UNTIL Eof(map) OR ((lastnr<>0) OR (lastfn<>''));

        Close(map);

        Beep;

        IF (lastfn<>'') AND ((errseg<>0) OR (errofs<>0))
          THEN
          {----Report Line Number & Source File}
            BEGIN
              WHILE (length(lastfn)<12) DO Insert(#32,lastfn,1);
              If first
                THEN
                  Csr_reporter(dep,'Runtime error '+Istr(exitcode,3,'0')+
                                                  ' in line '+Wstr(lastnr,4)+
                                                  ' of '+lastfn+
                                                  ' at '+Word2hex(errseg)+':'+Word2Hex(errofs)+'.')
                ELSE
                  Csr_reporter(dep,'    Called '+call+' from line '+Wstr(lastnr,4)+
                                                      ' of '+lastfn+
                                                      ' at '+Word2hex(errseg)+':'+Word2Hex(errofs)+'.');
            END
          ELSE
            BEGIN
              IF (lastun<>'') OR (lastpr<>'')
                THEN
                {----Report Unit/Program Name & Procedure name}
                  BEGIN
                    IF (Pos('@',lastpr)>0)
                      THEN s:=lastun+'.MAIN'
                      ELSE s:=lastun+'.'+lastpr;

                    WHILE (Length(s)>25) DO
                      Delete(s,Length(s),1);

                    If first
                      THEN
                        Csr_reporter(dep,'Runtime error '+Istr(exitcode,3,'0')+
                                                        ' in '+Sstr(s,25)+
                                                        ' at '+Word2hex(errseg)+':'+Word2Hex(errofs)+'.')
                      ELSE
                        Csr_reporter(dep,'    Called '+call+' from '+Sstr(s,25)+
                                                            ' at '+Word2hex(errseg)+':'+Word2Hex(errofs)+'.');
                  END
                ELSE
                {----Report Error Address Only}
                  BEGIN
                    If first
                      THEN
                        Csr_reporter(dep,'Runtime error '+Istr(exitcode,3,'0')+
                                                        '             '+
                                                        '                '+
                                                        ' at '+Word2hex(errseg)+':'+Word2Hex(errofs)+'.')
                      ELSE
                        Csr_reporter(dep,'    Called '+call+' from line     '+
                                                           '                '+
                                                           ' at '+Word2hex(errseg)+':'+Word2Hex(errofs)+'.');
                  END;
            END;
      END
    ELSE
    {----Report Error Addres Only}
      Csr_reporter(dep,'Runtime error '+Istr(exitcode,0,'0')+
                                      ' at '+Word2hex(errseg)+':'+Word2Hex(errofs)+'.')
END; {of Findlineno}

{---------------------------------------------------------}
{$F+}

VAR
  exitsave : POINTER;

PROCEDURE Myexit;

VAR
  ch  : Char;
  cdiv,
  csmin,
  cs,
  sp,
  ss  : WORD;
  p   : Pointer;
  dep : WORD;
  j   : INTEGER;

BEGIN
  Flushkbd;

  Exitproc:=exitsave;

  IF (exitcode=0) OR (erroraddr=NIL) THEN Exit;

  sp:=BPreg;
  ss:=SSeg;

{----Calculate calling depth}
  dep:=0;
  p:=Ptr(ss,sp);
  WHILE MemW[ss:Ofs(p^)]<>0 DO
    BEGIN
      IF (Mem[cs:MemW[ss:Ofs(p^)+2]-3]<>$E8)
        THEN cs:=MemW[ss:Ofs(p^)+4];

      p:=Ptr(ss,MemW[ss:Ofs(p^)]);
      Inc(dep);
    END;

  p:=Ptr(ss,sp);
  cdiv :=Cseg-cs;
  csmin:=cs;
  cs   :=Cseg;

{----Report Runtime address}
  Findlineno(true,true,dep,erroraddr);
  Dec(dep);

{----Calculate cseg at runtime error}
  cs:=csmin+Seg(erroraddr^);

{----Prevent Turbo Pascal from reporting}
  Erroraddr:=NIL;

  If NOT(mapfile) THEN Exit;

{----Skip Runtime error handler entry}
  IF (MemW[ss:Ofs(p^)]<>0)
    THEN p:=Ptr(ss,MemW[ss:Ofs(p^)]);

{----Report Call Stack}
  WHILE MemW[ss:Ofs(p^)]<>0 DO
    BEGIN
    {----Test for near call instruction 3 bytes before return address}
      IF (Mem[cs:MemW[ss:Ofs(p^)+2]-3]=$E8)
      {----Trace a near call}
        THEN Findlineno(false,true,dep,Ptr(WORD(Cs+Cdiv-Cseg),MemW[ss:Ofs(p^)+2]-3))
        ELSE
        {----Trace a far call}
          BEGIN
            Cs:=MemW[ss:Ofs(p^)+4];
            Findlineno(false,false,dep,Ptr(WORD(Cs+Cdiv-Cseg),MemW[ss:Ofs(p^)+2]-3));
          END;

    {----Increment stackpointer}
      p:=Ptr(ss,MemW[ss:Ofs(p^)]);
      Dec(dep);
    END;

END; {of Myexit}

{---------------------------------------------------------}

PROCEDURE Csr_report(level : Word;csr : STRING);

BEGIN
  IF ft
    THEN
      BEGIN
        Textmode(lastmode);
        ft:=false;
      END;
  Writeln(csr+' (',level,')');
END; {of Csr_report}
{$F-}
{---------------------------------------------------------}

BEGIN
  exitsave:=Exitproc;
  exitproc:=@Myexit;
  csr_reporter:=Csr_report;

  Fsplit(Paramstr(0),dir,nam,ext);
  Assign(map,dir+nam+'.MAP');
  {$I-} Reset(map); {$I+}
  IF (IOResult=0)
    THEN
      BEGIN
        mapfile:=true;
        Close(map);
      END
    ELSE mapfile:=false;

  ft:=true;
END.

{  STACK UNIT NEEDED FOR CRS_01}

UNIT Stack1;

INTERFACE

PROCEDURE test2(VAR i : Integer);

IMPLEMENTATION

VAR
  i : INTEGER;

{---------------------------------------------------------}

PROCEDURE test2(VAR i : Integer);

PROCEDURE test4(i : INTEGER);

VAR
  tmp : Integer;

BEGIN
  tmp:=0;
  i:=1 div tmp;
END;

BEGIN
  test4(i);
END;

{---------------------------------------------------------}

BEGIN
  i:=1;
END.


{ -------------------------------   DEMO ------------------------}
{---------------------------------------------------------}
PROGRAM Csrtst;

USES
  CRT,
  Csr_01,
  Stack1;

{---------------------------------------------------------}

PROCEDURE test3;

VAR
  i : INTEGER;

BEGIN
  test2(i);
END;

{---------------------------------------------------------}

PROCEDURE test4;

BEGIN
  test3
END;

{---------------------------------------------------------}

BEGIN
  clrscr;
  test4;
END.

