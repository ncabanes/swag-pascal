{
A much better more reliable method is just to set the CURRENT cursor's bit
5 to disable it, then mask it back off again...
}
unit cursor; {Public domain, by Sean Palmer}

interface

var maxSize:byte;

 procedure cursorOn;
 procedure cursorOff;
 procedure setSize(scans:byte);  {set size from bottom, or 0 for off}
 procedure detect;     {get max scan lines by reading current cursor}

implementation

procedure cursorOn;assembler;asm
 mov ah,3; mov bh,0; int $10; and ch,not $20; mov ah,1; int $10;
 end;

procedure cursorOff;assembler;asm
 mov ah,3; mov bh,0; int $10; or ch,$20; mov ah,1; int $10;
 end;

procedure setSize(scans:byte);var t:byte;begin
 if scans=0 then t:=$20 else t:=maxSize-scans;
 asm mov ah,1; mov bh,0; mov ch,t; mov cl,maxSize; dec cl; int $10; end;
 end;

{call whenever you change text cell height}
procedure detect;assembler;asm  {do NOT call while cursor's hidden}
 mov ah,3; mov bh,0; int $10; inc cl; mov maxSize,cl;
 end;

begin
 detect;
 end.
