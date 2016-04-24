(*
  Category: SWAG Title: STRING HANDLING ROUTINES
  Original name: 0076.PAS
  Description: LONG String Arrays
  Author: WIM VAN VOLLENHOVEN
  Date: 05-25-94  08:17
*)


{
GV> Hi Wim,
Hi Greg...

GV> It wouldn't be difficult to write Pos, Copy, Assign, etc., which
GV> operate on an ARRAY OF CHAR -- using the ASCIIZ scheme, or a length
GV> WORD (rather than length byte) at array elements [0] and [1].

As you can see in a other message has wim van der vegt written a
complete unit with these functions :-)

it was a 'little' bit reprogramming to implement these new functions but
it was worth while <g>

GV> Greg_
Thanx for your answer, Wim

here is the code :
}

Unit MyStr;

INTERFACE


Const
  maxlength  = 512;
  nul        = #00;
  cr         = #13;
  lf         = #10;
  sp         = #32;

Type
  indexrange = 0..maxlength;
  stringtype = Record
                 length : indexrange;
                 chars  : Array[1..maxlength] Of char;
               End;


Function  Long_Length(s : stringtype) : indexrange;
Procedure Long_Readln(Var f : text;var l : stringtype);
Procedure Long_Write(Var f : text;var l : stringtype);
Procedure Long_Writeln(Var f : text;var l : stringtype);
Procedure Long_Copy(s : stringtype;Var d : stringtype; index,count : indexrange);
Procedure Long_Concat(Var d : stringtype;s : String);

IMPLEMENTATION
{---------------------------------------------------------}
{  Author  : Ir. G.W. van der Vegt                        }
{  Project : Longer strings                               }
{  Source  : Pascal + Data Structures by Dale/Lilly       }
{            ISBN 0-669-07239-7                           }
{---------------------------------------------------------}
{  Modified to give less errors and act more like TP's    }
{  functions. Can be made more efficient by using move,   }
{  moving the inc of length's out of the for loops and    }
{  not using the Length function to calc the length but   }
{  use the field in the record. etc.                      }
{---------------------------------------------------------}
{  Because Turbo Pascal's Functions won't return records  }
{  most of the Turbo Pascal String functions equivalents  }
{  can only be procedures.                                }
{---------------------------------------------------------}
{  The code hasn't been tested well yet so expect some    }
{  errors to be in it. All I have detected are fixed.     }
{  For testing set maxlength at 20 or 30.                 }
{---------------------------------------------------------}


Function Long_Length(s : stringtype) : indexrange;

Begin
  Long_Length:=s.length;
End;

Procedure Long_Readln(Var f : text;var l : stringtype);

Begin
  l.length:=0;
  Fillchar(l.chars,maxlength,sp);
  While NOT(Eoln(f) OR Eof(f)) AND (l.length<maxlength) Do
    Begin
      Inc(l.length,1);
      System.Read(f,l.chars[l.length]);
    End;

  IF Not(eof(f)) Then System.readln(f);
End;

Procedure Long_Write(Var f : text;var l : stringtype);

Var
  pos : indexrange;

Begin
  For pos:=1 To Long_Length(l) DO
    System.Write(f,l.chars[pos]);
End;

Procedure Long_Writeln(Var f : text;var l : stringtype);

Var
  pos : indexrange;

Begin
  For pos:=1 To Long_Length(l) DO
    System.Write(f,l.chars[pos]);
  System.Write(f,cr,lf);
End;

Procedure Long_Copy(s : stringtype;Var d : stringtype; index,count : indexrange);

Var
  poss,
  posd : indexrange;

Begin
  d.length:=0;
  Fillchar(d.chars,maxlength,sp);

  posd:=0;
  poss:=index;

  WHILE (posd<count) AND (poss<=maxlength) Do
    Begin
      Inc(d.length,1);
      Inc(posd,1);
      d.chars[posd]:=s.chars[poss];
      Inc(poss,1);
    End;
End;

Procedure Long_Concat(Var d : stringtype;s : String);

Var
  posd,
  poss : indexrange;
Begin
  posd:=Long_Length(d);
  poss:=0;
  While (posd<maxlength) AND (poss<Length(s)) Do
    Begin
      Inc(poss,1);
      Inc(posd,1);
      d.chars[posd]:=s[poss];
      Inc(d.length,1);
    End;
End;



(*
Var
  inf : text;
  s,d : stringtype;

Begin
  Assign(inf,'LSTRING.PAS');
  Reset(inf);
  While NOT(eof(inf)) Do
    Begin
      Readln(inf,s);
      Copy(s,d,1,4);
      Writeln(output,s);
      Writeln(output,d);
      Concat(d,s);
      Writeln(output,d);
    End;
*)

End.

