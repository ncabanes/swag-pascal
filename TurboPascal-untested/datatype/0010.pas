 ->> You could also open the File as unTyped :-), and use blockRead to
 ->> read big chunks Until you've read (recSize * number of Records beFore

 PW>       Can I do this even if the File is a Typed File to begin with?  How
 PW> would I do it?  Thanks For the info.


You can close it and reopen it, just use two Variables:

  Var
    uf:   File;
    tf:   File of gummi_bear;


  begin
    assign(tf, 'TEST.FIL');
    reset(tf);
    .
    .                   (* do whatever you need the Typed File For *)
    .
    close(tf);
    assign(uf, 'TEST.FIL');
    reset(uf, 1);       (* tell runtime lib that rec size is one Byte *)
    .
    .                   (* now it's unTyped, you can use blockread to *)
    .                   (* read an arbitrary number of Bytes *)
    close(uf);
  end;

