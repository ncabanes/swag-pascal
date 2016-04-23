{
RN> Hi! Does anyone know if it's possible to modify the
RN> characters in the ASCII chart using Pascal?  The reason I
RN> want to do this is to define the upper ASCII characters
RN> (128+) to implement the Cyrillic alphabet, for an
RN> application I'm developping (or will be developping if I can
RN> figure this out :-)))
}

Unit Font;

{     AX  =  $1110      (ah = $11, al = $10)
          BH  =  bytes per character
          BL  =  block to load to.  (use 0)
          CX  =  number of character defined by table
          DX  =  starting character value
          ES  =  segment of the table (use Seg())
          BP  =  offset of the table (use Ofs())                    }
Interface

Procedure DoFont(Fname: String);

Implementation

Uses DOS;
Type FontArray= Array[1..$1000] of Char;

    FontFile= Record
       Gfont_POINTS: Byte;
              Gfont: FontArray;
                End; {of record}
VAR FonF: File;
    Tfont: FontFile;
    ESr,BPr: Word;
{---------------------------------------------------------------------------}
Procedure DoFont(Fname: String);

VAR R: Registers;

Begin;
Assign (FonF,Fname+'.FON');
Reset (FonF, SizeOf(FontFile));
BlockRead (FonF, Tfont, 1);
Close (FonF);
ESr:= Seg(Tfont.Gfont);
BPr:= Ofs(Tfont.Gfont);
r.ax := $1110;
r.bh := Tfont.Gfont_Points;            (* bytes per character *)
r.bl := 0;                             (* load to block 0 *)
r.cx := 256;                           (* 256 characters *)
r.dx := 0;                             (* start with character 0 *)
r.es := Seg(Tfont.Gfont);              (* segment of table *)
r.bp := Ofs(Tfont.Gfont);              (* offset of the table *)
intr($10, r);
End; {of procedure}

End.
