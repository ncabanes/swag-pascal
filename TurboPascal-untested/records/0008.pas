BG>JB>A method that I have successfully used to delete records in place is
BG>JB>to...

  'Scuse me for butting in, but I have another approach which will
  preserve your record order. I will present it for a file of records
  the total size of which is less than 64K. The routine may easily be
  adapted for large files:

procedure del_rec(fname : string;target : longint;rec_size : longint);
type
  t_buf=array[1..65520] of byte;

var
  f : file;
  buf : t_buf;
  n : word;

begin
  new(buf);
  assign(f,fname);  { open your file }
  reset(f,1);
  blockread(f,buf,sizeof(buf),n);
  close(f);

  move(buf[succ(target)*rec_size],buf[target*rec_size],n-(target*rec_size));
  dec(n,rec_size);
  rewrite(f,1);
  blockwrite(f,buf,n);
  close(f);
  dispose(buf);
end;
---
 * The Right Place (tm) BBS/Atlanta - 404/476-2607 SuperRegional Hub
 * PostLink(tm) v1.05  TRP (#564) : RelayNet(tm)
---
 ■ OLX 2.1 TD ■ I just steal 'em, I don't explain 'em.
