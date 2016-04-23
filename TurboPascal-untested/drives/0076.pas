{
 -=> Quoting Christian Proehl to All <=-

 CP> Subject: Disk-detecting routines without DOS (and

 CP> Muelheim, den 20.05.94

 CP> Hello!

 CP> I have problem I don't know how to solve it.
 CP> Perhaps someone around the world knows more, please help me!

 use the bios call

  function $16, int $13
}

function DiskChange( DriveNmber :Byte) :Boolean;
Begin
 ASm
   Mov AH, $16
   Mov DL, driveNmber
   Int $13
   Mov AL,AH;  { use AL & AH as a Return Value }
 End;
End;

Begin
  If DiskChange(0) then Write(' Disk has Changed in Drive ''A'' ')
   Else
     Write(' Disk Has changed ');
end.
