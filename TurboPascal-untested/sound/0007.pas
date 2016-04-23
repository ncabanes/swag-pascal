{ JR> Well, Can you post the sorce code on how to play to the Sound blaster
 JR> Byte by Byte? I could probley find out after that!
 JR> James

Sure thing... this Program will load a File into memory then play it a Byte
at a time... It should be pretty self-explanatory.
}

Program rawdemo;

Uses Crt;

{$I-}

Const
   fname = 'NELLAF.VOC';               { Can be any raw data File }
   resetport  = $226;
   readport   = $22A;
   Writeport  = $22C;
   statusport = $22E;
   dac_Write  = $10;
   adc_read   = $20;
   midi_read  = $30;
   midi_Write = $38;
   speakeron  = $D1;
   speakeroff = $D3;

Function reset_dsp : Boolean;
Var
   count, bdum : Byte;
begin
   reset_dsp := False;
   port[resetport] := 1;
   For count := 1 to 6 do
      bdum := port[statusport];
   port[resetport] := 0;
   For count := 1 to 6 do
      bdum := port[statusport];
   Repeat Until port[statusport] > $80;
    if port[readport] = $AA then
      reset_dsp := True;
end;

Procedure spk_on;
begin
   Repeat Until port[Writeport] < $80;
   port[Writeport] := $D1;
end;

Procedure spk_off;
begin
   Repeat Until port[Writeport] < $80;
   port[Writeport] := $D3;
end;

Procedure generic(reg,cmd:Integer; data:Byte);
begin
   Repeat Until port[Writeport] < $80;
   port[reg] := cmd;
   Repeat Until port[Writeport] < $80;
   port[reg] := data;
end;

Procedure Write_dsp(data:Byte); Assembler;
Asm
   mov   dx,$22C
   mov   cx,6                          { Change either value of CX For }
@1:
   in    al,dx
   loop  @1

   mov   al,10h
   out   dx,al
   mov   cx,36                         { faster or slower playing. }
@2:
   in    al,dx
   loop  @2

   mov   al,data
   out   dx,al
end;

Function read_dsp : Byte;
begin
   Repeat Until port[Writeport] < $80;
     port[Writeport] := $20;
   Repeat Until port[statusport] > $80;
   read_dsp := port[readport];
end;

Procedure Write_midi(data:Byte);
begin
   Repeat Until port[Writeport] < $80;
   port[Writeport] := $38;
   Repeat Until port[Writeport] < $80;
   port[Writeport] := data;
end;

Function read_midi : Byte;
begin
   Repeat Until port[Writeport] < $80;
   port[Writeport] := $30;
   Repeat Until port[statusport] > $80;
   read_midi := port[readport];
end;

Function loadFile(Var buffer:Pointer; Filename:String) : Word;
Var
   fromf : File;
   size : LongInt;
   errcode : Integer;
begin
   assign(fromf,Filename);
   reset(fromf,1);
   errcode := ioresult;
   if errcode = 0 then
   begin
      size := Filesize(fromf);
      Writeln(size);
      getmem(buffer,size);
      blockread(fromf,buffer^,size);
   end
   else size := 0;
   loadFile := size;
   close(fromf);
end;

Procedure unload(buffer:Pointer; size:Word);
begin
   freemem(buffer,size);
end;

Var
   ch : Char;
   buf : Pointer;
   index, fsize : Word;

begin
   ClrScr;
   Writeln;
   Writeln;
   if not reset_dsp then
   begin
      Writeln('Unable to initialize SoundBlaster.');
      halt(1);
   end;
   fsize := loadFile(buf,fname);
   if (fsize <= 0) then
   begin
      Writeln(fname, ' not found.');
      halt(2);
   end;
{   For index := 1 to fsize do
      dec(mem[seg(buf^):ofs(buf^)+index-1],80);}       { For MOD samples }
   spk_on;
   Writeln('Playing...');
   For index := 1 to fsize do
      Write_dsp(mem[seg(buf^):ofs(buf^)+index-1]);
   spk_off;
   unload(buf,fsize);
   Writeln('Done.');
   ch := ReadKey;
end.

