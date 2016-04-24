(*
  Category: SWAG Title: TEXT FILE MANAGEMENT ROUTINES
  Original name: 0037.PAS
  Description: Text File Objects
  Author: WIM VAN DER VEGT
  Date: 08-24-94  17:50
*)

{
Here's a piece of code I wrote last year which does what wasn't
uploaded. It allows text files converted to obj format to be linked in
and being accessed as 'normal' turbo pascal text files. The 'object'
text files support reset, read, readln eof, eoln and close file
commands.

What you need to write in your program is a obj_find function which
translates filenames into pointers or returns NIL to indicate an
external file. Use Assign_text procedure instead. A sample of how to
use it is supplied in the second program/unit. Only the two linked in
files will be fetched from memory, any other name supplied will be
fetched from disk as usual.

The first unit can be the same for all projects, the second one is
project depended, because one will be using different files.

Question about this, ask them!

}
{---------------------------------------------------------}
{  Project : Object linked textfiles                      }
{  By      : Ir.G.W. van der Vegt                         }
{---------------------------------------------------------}
{  Datum .tijd  Revisie                                   }
{  930914.2200  Creatie.                                  }
{  930915.2200  Support for Settextbuffer. Bufptr used    }
{               again for addressing & pointer advancing  }
{               adjusted.                                 }
{---------------------------------------------------------}
{  Usage : Convert textfile to obj with turbo's BINOBJ    }
{          Add them to a unit as show in this sample      }
{          Create a custom filename to func address       }
{          converter as show in My_getp. This function    }
{          should return NIL if the requested file isn't  }
{          linked in. Use Obj_assign to get assign the    }
{          filevar. Reset, Read, Readln & Close are       }
{          allowed. If a file isn't found it's searched on}
{          disk. Pathnames are stripped when searching for}
{          linked-in files.                               }
{---------------------------------------------------------}

Unit Obj_01;

INTERFACE

Type
  Obj_find = Function(fn : String) : Pointer;

Var
  Obj_getp : Obj_find;

Procedure Obj_Assign(VAR tpl : Text;fn : String;decoder : Obj_find);

IMPLEMENTATION

Uses
  Dos;

{---------------------------------------------------------}
{----To simplyfy addressing inside the buffer, the segment}
{    of the pointer to the text in memmory is incremented }
{    instead of using the old Longint typecast trick      }
{---------------------------------------------------------}

Const
  para = 16;

Type
  obj_user    = Record
                  base,
                  curr    : Pointer;
                  dummy   : ARRAY[1..8] OF Byte;
                End;

{---------------------------------------------------------}
{----Ignore    handler                                    }
{---------------------------------------------------------}
{$F+}
Function Obj_ignore(VAR f : textrec) : Integer;

Begin
  Obj_ignore:=0;
End; {of Obj_ignore}
{$F-}

{---------------------------------------------------------}
{----Inoutfunc handler                                    }
{---------------------------------------------------------}
{$F+}
FUNCTION Obj_input(VAR f : textrec) : INTEGER;

VAR
  p : Pointer;

BEGIN
  WITH Textrec(f) DO
    BEGIN
    {----Advance Pointer obj_size paragraphs}
      p:=Ptr(Seg(obj_user(userdata).curr^)+(bufsize DIV para),
             Ofs(obj_user(userdata).curr^));
      obj_user(userdata).curr:=p;
      Move(obj_user(userdata).curr^,bufptr^,(bufsize DIV para)*para);
      bufpos   :=0;
      bufend   :=(bufsize DIV para)*para;
    END;
  obj_input:=0;
END; {of obj_input}
{$F-}
{---------------------------------------------------------}
{----Open func handler                                    }
{---------------------------------------------------------}
{$F+}
FUNCTION obj_open(VAR f : textrec) : INTEGER;

BEGIN
  WITH Textrec(f) DO
    BEGIN
      obj_user(userdata).curr:=obj_user(userdata).base;
      Move(obj_user(userdata).base^,bufptr^,(bufsize DIV para)*para);
      bufpos   :=0;
      bufend   :=(bufsize DIV para)*para;
    END;
  obj_open:=0;
END; {of obj_open}
{$F-}
{---------------------------------------------------------}
{----Assign a link-in file or disk file                   }
{---------------------------------------------------------}

Procedure Obj_Assign(VAR tpl : Text;fn : String;decoder : Obj_find);

VAR
  tplp    : POINTER;
  i       : Byte;

BEGIN

  If (Addr(decoder)=NIL)
    THEN tplp:=NIL
    ELSE tplp:=Decoder(fn);

  IF (tplp<>NIL)
    THEN
      WITH Textrec(tpl) DO
        BEGIN
          handle   :=$ffff;
          mode     :=fmclosed; {fminput}
          bufsize  :=SIZEOF(textbuf);
          bufpos   :=0;
          bufptr   :=@buffer;

          obj_user(userdata).base:=tplp;
          obj_user(userdata).curr:=tplp;

          openfunc :=@obj_open;
          inoutfunc:=@obj_input;
          flushfunc:=@obj_ignore;
          closefunc:=@obj_ignore;

          i:=0;
          While (i<Length(fn)) AND (i<Sizeof(name)) DO
            Begin
              name[i]:=Upcase(fn[i+1]);
              Inc(i);
            End;
          name[i]  :=#00;
        END
      ELSE Assign(tpl,Fexpand(fn));
END; {of obj_open}

END.


---------------<source part II, to link in your text files.

{---------------------------------------------------------}
{  Project : Object linked textfiles                      }
{  Unit    : Sample program                               }
{  By      : Ir.G.W. van der Vegt                         }
{---------------------------------------------------------}
{  Datum .tijd  Revisie                                   }
{  930914.2200  Creatie.                                  }
{---------------------------------------------------------}

Unit Objtext;

Interface

Procedure Assign_text(VAR tpl : Text;fn : String);

Implementation

{---------------------------------------------------------}

Uses
  Dos,
  Obj_01;

{---------------------------------------------------------}
{----SAMPLE Get_obj Function}
{$L SAMPLE_d.obj}
{$L SAMPLE_m.obj}

{---------------------------------------------------------}

FUNCTION SAMPLE_D  : Byte ; External;
FUNCTION SAMPLE_M  : Byte ; External;

{---------------------------------------------------------}
{$F+}
FUNCTION My_getp(fn : String) : Pointer;

VAR
  name : String[12];
  d    : dirstr;
  n    : namestr;
  e    : extstr;

Begin
  Fsplit(Fexpand(fn),d,n,e);

  My_getp:=NIL;

  name:=Strip(Upcasestr(n+e),true,true);

          {12345678.123}
  IF name=  'SAMPLE.D' THEN My_getp:=  @Sample_d;
  IF name=  'SAMPLE.M' THEN My_getp:=  @Sample_m;
End; {of My_getp}

{---------------------------------------------------------}

Procedure Assign_text(VAR tpl : Text;fn : String);

Begin
  Obj_assign(tpl,fn,Obj_find(Assign_decoder));
End;

{---------------------------------------------------------}


{---------------------------------------------------------}

Begin
  Assign_decoder:=@My_getp;
End.

