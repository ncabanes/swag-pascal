{
STEVE ROGERS

> Also, does anyone know how PKware wrote the ZIP2EXE Program? I'm also
>writing an encryption Program, and I thought a 'self-decrypting' File
>would be neat, so I had some ideas on how to do it. Could you just
>append the encrypted data to the end of a short 'stub' Program, which
>just seeks in how ever many Bytes and  reads from there? Or would I
>have to somehow assign all the data to a few Typed Constants?

Just so happens I have been dealing With the same problem. I have
written a Procedure to show the "True" size of an EXE File. Knowing this
you can easily get to your "data area" by seeking past the "True" size.

( Acknowledgements to Andy McFarland and Ray Duncan )
}

Function exesize(fname : String) : LongInt;
Type
  t_size = Record
    mz : Array [1..2] of Char;
    remainder,
    pages : Word;
  end;

Var
  f  : File of t_size;
  sz : t_size;

begin
  assign(f,fname);
  {$i-}
  reset(f);
  {$i+}   { io checking should be off }
  if (ioresult <> 0) then
    exesize:= 0
  else
  begin
    read(f,sz);
    close(f);
    With sz do
      exesize := remainder + (pred(pages) * 512);
  end;
end;


{
This thing reads the header of an EXE File and gets the info there. I
was amazed when I ran this on a bunch of progs and found how many have
data appended. Hope it helps. :)
}