{
>The subroutine opened a text file (in this case the Telix.USE file) in
>binary mode, and then searched through the file for the CR/LF pair and
>then incremented a counter.  At the end I knew the number of lines in
>the text file.  I suppose in Pascal I could open the file do a while
>loop and count the lines -- but that would require me to read every
>single line where the basic subroutine did all the searching without
>having to read the file line by line.

>I guess what I'm asking is how is a fast way to determine the number of
>lines in a text file using Pascal.

FWIW, This routine takes a little over 6 seconds on a 330K TELIX.USE on a
386/33
}

program countlines;

var
   usefile : file;
   buffer :  array[0..8191] of byte;
   counter, numw, numr : word;
   size, numlines : longint;


begin
   numlines := 0;
   counter := 0;
   fillchar(buffer, sizeof(buffer), #0);
   assign(usefile,'TELIX.USE');
   reset(usefile,1);
   size := filesize(usefile);
   repeat
      blockread(usefile,buffer,sizeof(buffer),numr);
      for counter := 0 to 8191 do
         if buffer[counter] = ord(13)
            then begin
                    inc(numlines);
                    write(round((filepos(usefile)/size)*100),'%',chr(13));
                 end;
   until numr = 0;
   close(usefile);
   writeln('Your TELIX.USE has ',numlines,' lines.');
end.
