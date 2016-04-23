{
STEVE ROGERS

>A method that I have successfully used to delete Records in place is to...

  'Scuse me For butting in, but I have another approach which will
  preserve your Record order. I will present it For a File of Records
  the total size of which is less than 64K. The routine may easily be
  adapted For large Files:
}

Procedure del_rec(fname : String; target : LongInt; rec_size : LongInt);
Type
  t_buf = Array[1..65520] of Byte;
Var
  f   : File;
  buf : ^t_buf;
  n   : Word;
begin
  new(buf);
  assign(f, fname);  { open your File }
  reset(f, 1);
  blockread(f, buf^, sizeof(buf^), n);
  close(f);

  move(buf^[succ(target) * rec_size],
       buf^[target * rec_size], n - (target * rec_size));
  dec(n, rec_size);
  reWrite(f, 1);
  blockWrite(f, buf^, n);
  close(f);
  dispose(buf);
end;
