(*
  Category: SWAG Title: TEXT FILE MANAGEMENT ROUTINES
  Original name: 0021.PAS
  Description: TEXT TO EXE
  Author: WALKING-OWL ???
  Date: 10-28-93  11:39
*)

{
From: WALKING-OWL
Subj: Re: TXT2COM
}

program MakeMessage;
const loader: array [0..14] of byte =
      ($BE,$0F,$01,
       $B9,$00,$00,
       $FC,$AC,$CD,$29,$49,$75,$FA,$CD,$20);
var fin,fout: file;
    nin,nout: string;
    buffer: array [0..4095] of byte;
    i: word;

begin
  writeln('"MakeMsg" v0.00');
  if ParamCount<>2
    then writeln('Usage: MAKEMSG textfile execfile')
    else begin
      nin:=ParamStr(1);
      nout:=ParamStr(2);
      Assign(fin,nin); reset(fin,1);
      Assign(fout,nout); rewrite(fout,1);
      i:=filesize(fin);
      loader[4]:=lo(i);
      loader[5]:=hi(i);
      BlockWrite(fout,loader[0],15);
      repeat
        BlockRead(fin,Buffer[0],4096,i);
        BlockWrite(fout,Buffer[0],i)
      until i=0;
      close(fin);
      close(fout);
      writeln('Done.')
      end
end.

