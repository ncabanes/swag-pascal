(*
  Category: SWAG Title: ANSI CONTROL & OUTPUT
  Original name: 0003.PAS
  Description: ANSI Display Unit
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:33
*)

{
>How do I make an ansi and put it in my Pascal File?  I know there is an
>option to save as pascal, but it does not look like anything to me!
>Any help is appreciated!

Here is a Program that will read an ANSI File into a buffer in 2k chunks
then Write it (to screen) Character by Character. BUT - it will Write
all ANSI-escape-sequences as StringS.

   Two reasons For this:

 1) I just 'feel happier' if each ANSI escape sequence is written to
 screen as a String instead of as individual Characters. (Its just an
 irrational 'thing' I have)

 2) By assembling all the Characters in the escape sequence together,
 it make its _easy_ to FILTER OUT all ANSI sequences if you want to just
 output plain black-and-white Text. This is For those people who for
 some strange reason would rather not have ANSI.SYS installed, but
 complain about getting 'garbage' Characters on the screen.

All you have to do to filter out the escape sequences is to
un-bracket the 'if AnsiDetected then' part.

if you want me to post 'Function AnsiDetected: Boolean' just let me
know.
}

Program ansiWrite;

Const esc = chr(27);
      termnChar: SET of Char =
                 ['f','A'..'D','H','s','u','J','K','l'..'n','h'];

Var f: File;
    buf:Array[1..2048] of Char;
    Numread: Word;
    num: Integer;
    escString: String;
    escseq: Boolean;

begin
  Assign(f,'FRINGE3.ANS');
  Reset(f,1);
  escseq := False;
  escString:='';
  Repeat
    BlockRead(f,buf,Sizeof(Buf),Numread);
    { Write Block to Screen }
    For NUM := 1 to Numread DO
    begin
      if Buf[Num] = esc then escseq := True;
      if escseq=True then
      begin
        escString:= escString+buf[num];
        if Buf[num] in termnChar  then
        begin
          escseq:=False;
          {if AnsiDetected then} Write(escString);
          escString:=''
        end
      end
      else Write(Buf[num])
    end; { For }
  Until NumRead < SizeOf(Buf);
  close(f)
end.

