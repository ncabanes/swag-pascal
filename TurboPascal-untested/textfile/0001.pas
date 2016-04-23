 GB>Could you Write a MCSEL ;-) wich gives us some hints For making Text i/o
 GB>_much_ faster ? I read that about the SetTextBuf although I never tried
 GB>it. What are other examples? Some little example-sources ?

Type BBTYP   = ^BIGBUF;
     BIGBUF  = Array[0..32767] of Char;

Var BUFFin   : BBTYP;        { general-use large Text I/O buffer }
Var BUFFOUT  : BBTYP;
    F        : Text;
    S        : String;

Procedure BBOPEN (Var F : Text; FN : String; OMODE : Char;
                  Var BP : BBTYP);
Var S : String;
begin
{$I-}
  Assign (F,FN); New (BP); SetTextBuf (F,BP^);
  Case UpCase(OMODE) of
    'R' : begin
            Reset (F); S := 'Input'
          end;
    'W' : begin
            ReWrite (F); S := 'Output'
          end;
    'A' : begin
            Append (F); S := 'Extend'
          end
    else
  end;
{$I+}
  if Ioresult <> 0 then
    begin
      Dispose (BP); FATAL ('Cannot open '+FN+' For '+S+' - Terminating')
    end
end;  { BBOPEN }

to use:

  BBOPEN (F,'myFile.txt',r,BUFFin);
  While not Eof (F) do
    begin
      readln (F,S);
      etc.
    end;
  Close (F); Dispose (BUFFin)
