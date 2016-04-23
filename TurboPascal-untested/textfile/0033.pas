{
 JK> I've started out in Pascal and need some information on how
 JK> to read from a certain point in a file, say line 3.  How
 JK> would I set the pointer to line 3 to read into a variable?

 BvG> A seek does not work on textfiles.

 Here, this will assist you. originally in a Pascal Newsletter, so it must
 be PD.

---------------------------------------- CUT HERE --------------------------
}
Unit TextUtl2;  (* Version 1.0 *)

{Lets you use typed-file operators on TEXT files.  Note that I've cut out MOST}
{of the documentation so as to make it more practical for the PNL.  I strongly}
{advise that you get in touch with the author at the address below (I haven't)}
{It's called TEXTUTL2 because it's a rewrite of an earlier unit called        }
{TEXTUTIL which had some nasty limitations.                                   }

{Both files can be FREQed from 3:634/384.0 as TEXTUT*.*, and I strongly       }
{recommend that you do so.                                                    }

{I tried looking up the author's telephone number, but Telecom says the number}
{is silent.  Oh well.                                                         }

{If you're having trouble, netmail me (Mitch Davis) at 3:634/384.6            }


(*
Author: Rowan McKenzie  28/12/88
        35 Moore Ave, Croydon, Vic, Australia

These 3 routines are improvements to Tim Baldock's TEXTUTIL.PAS unit.
I can be contacted on: Eastwood, Amnet or Tardis BBS (Melbourne Australia)
*)

Interface

Uses Dos;

Procedure TextSeek     (Var F : Text; Offset : Longint);
Function  TextFileSize (Var F : Text): LongInt;
Function  TextFilePos  (Var F : Text): LongInt;

Implementation

Procedure TextSeek(Var F : Text; Offset : Longint);

{ seek char at position offset in text file f}

var BFile    : File of byte absolute F;  (* Set up File for Seek *)
    BFileRec : FileRec absolute Bfile;
    TFileRec : TextRec Absolute F;
    OldRecSize : Word;
    oldmode : word;

Begin
  With BfileRec do Begin
    oldmode:=mode;
    Mode := FmInOut;         (* Change file mode so Turbo thinks it is *)
    OldRecSize := RecSize;   (* dealing with a untyped file.           *)
    RecSize := 1;            (* Set the Record size to 1 byte.         *)
    Seek(Bfile,Offset);      (* Perform Seek on untyped file.          *)
    Mode := oldmode;         (* Change file mode back to text so that  *)
    RecSize := OldRecSize;   (* normal text operation can resume.      *)
  end;
  TfileRec.BufPos := TfileRec.BufEnd; (* Force next Readln.              *)
end; {textseek}

Function TextFileSize(Var F : Text): LongInt;

{ determine size of text file f in bytes}

var BFile:File of byte absolute F;
    BFileRec:FileRec absolute Bfile;
    OldRecSize:Word;
    oldmode:word;

Begin
  With BfileRec do Begin
    oldmode:=mode;
    Mode := FmInOut;
    OldRecSize := RecSize;
    RecSize := 1;
    TextFileSize := FileSize(Bfile);
    Mode := oldmode;
    RecSize := OldRecSize;
  end;
end; {textfilesize}


Function Textfilepos(Var F : Text): LongInt;

{ determine current position (in bytes) in text file f}

var BFile:File of byte absolute F;
    BFileRec:FileRec absolute Bfile;
    TFileRec:TextRec Absolute F;
    OldRecSize:Word;
    oldmode:word;

Begin
  With BfileRec do Begin
    oldmode:=mode;
    Mode := FmInOut;
    OldRecSize := RecSize;
    RecSize := 1;
    textfilepos := Filepos(Bfile)-tfilerec.bufend+tfilerec.bufpos;
    Mode := oldmode;
    RecSize := OldRecSize;
  end;
end; {textfilepos}

end.
