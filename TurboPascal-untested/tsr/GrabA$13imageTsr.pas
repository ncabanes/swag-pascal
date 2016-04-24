(*
  Category: SWAG Title: TSR UTILITIES AND ROUTINES
  Original name: 0026.PAS
  Description: Grab A $13-Image TSR
  Author: ALWIN LOECKX
  Date: 08-24-94  13:41
*)


{$m $800,0,0 }

program catch; { just for Swag }

uses crt, dos;

const header : array[1..2] of word = (320, 200);

var cnt : byte;

{$f+}
procedure new_int; interrupt;

var imgfile : file;
    imgname : string[12];

begin
 str(cnt, imgname);
 if cnt < 10  then imgname := '0'+imgname;
 if cnt < 100 then imgname := '0'+imgname;
 imgname := 'grab.'+imgname;

 {$i-}
 assign(imgfile, imgname);
 rewrite(imgfile, 1);

 blockwrite(imgfile, header, 4);
 blockwrite(imgfile, mem[$a000:$0], 320*200);

 close(imgfile);
 {$i+}

 if ioresult <> 0 then
  begin
   sound(1000); { Error }
   delay(1000);
   nosound;
  end
 else
  begin
   sound(50); { Ok! }
   delay(50);
   nosound;
   inc(cnt);
  end;
end;
{$f-}


begin
 cnt := 1;

 setintvec($5, addr(new_int));

 writeln('Press Screen Print to grab a 320x200x256 image to "grab.###"');
 writeln('One short low beep means "No error", a long high one means trouble');
 writeln;
 writeln('Only catch when you''re sure:');
 writeln('∙Your hard-disk is not busy');
 writeln('∙You''re in a program (so not at the command-prompt)');
 writeln('∙You''re in the mcga 320x200 256 color modus ($13)');

 keep(0);
end.

Warning!
Do NOT run this program from within Tp!
Just compile it, then run it as an executable.

