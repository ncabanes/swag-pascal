(*
  Category: SWAG Title: TEXT FILE MANAGEMENT ROUTINES
  Original name: 0036.PAS
  Description: Faster READLN
  Author: JOSE CAMPIONE
  Date: 08-24-94  13:54
*)

{
  I have been exploring a faster way to read lines from text
   files. This one seems to be 30% faster than readln even with
   a full settextbuffer of $FFFF. However, it only works for
   files smaller than 64K ($FFF1) and all lines, including the
   last one, must end in the CR/LF word (readln recognizes the
   EOF (01Ah) char also as an end of line). Please repost any
   improvements. }

   program readtext;

   Uses CRT;

   const 
     maxsize = $FFF0;
   
   type
     barr    = array[0..maxsize] of byte;
     ptrbarr = ^barr;

   var
     f : file;
     s : string;
     p : longint;
     fsiz : longint;
     fbuf : ptrbarr;
   
   function pos13(pnt:pointer): word; assembler;
   asm
     les di,[pnt]              {load pointer in es:di}
     mov cx,$00FF              {load maximum size to scan in cx}
     mov bx,cx                 {save maximum size to scan in bx}
     mov al,$0D                {load in al byte to match = 0Dh}
     cld                       {increment di}
     repne scasb               {search loop}
     je  @found                {jump if found}
     mov ax,0                  {if not found report result = 0}
     jmp @fin                  {goto end}
     @found:                   {if found...}
     sub bx,cx                 {get position matched}
     mov ax,bx                 {report result = position matched}
     @fin:
   end;
   
   procedure readx(fbuf:ptrbarr;var s:string;var p:longint);
   var
     q : word;
     b : ptrbarr;
   begin
     b:= addr(fbuf^[p]);       {point to first byte in remaining block}
     q:= pos13(b);             {get position of first $0D occurence}
     move(b^,s[1],pred(q));    {transfer preceeding bytes to string}
     s[0]:= char(pred(q));     {assign size byte to Pascal string}
     inc(p,succ(q));           {adjust pointer skipping 1 byte ($0A)}
   end;

   begin
     ClrScr;
     if paramcount = 0 then
        BEGIN
        writeLn( 'Enter FILENAME on commandline');
        halt;
        END;
     assign(f,paramstr(1));
     reset(f,1);
     fsiz:= filesize(f);
     if fsiz > maxsize then halt;
     getmem(fbuf,fsiz);
     blockread(f,fbuf^,fsiz);
     close(f);
     p := 0;                   {initialize pointer to position in fbuf^}
     while p < fsiz do begin
       readx(fbuf,s,p);
       writeln(s);
     end;
     dispose(fbuf);
   end.


