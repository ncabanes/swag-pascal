program Instances;
{ uploaded by Ron Aaron as a demonstration of how to
  prevent multiple instances of a program in different
  VMs.  This program will work compiled for Windows, DOS
  or DPMI.
}
uses  strings,
{$IFDEF WINDOWS}
        wincrt
{$ELSE}
       crt
{$ENDIF}
;

var
   { Inter Program Area: 16 bytes set aside by IBM for
     just this sort of thing...
   }
   IPA : array[0..15] of char absolute $40:$f0;

const
   ident : PChar = 'INSTTEST';

function isrunning : boolean;
begin
     if StrComp(IPA, ident) = 0 then
        isrunning := true
     else
        isrunning := false;
end;

procedure install;
begin
     StrCopy(IPA, ident);
end;

procedure deinstall;
begin
     StrCopy(IPA,'xxxxx');
end;

begin
     if isrunning then
     begin
          writeln('Previous copy is running.');
     end
     else
     begin
          install;
          writeln('No previous copy is running.  Press any key to quit...');
          while not keypressed do
                ;
          deinstall;
     end;
end.