
{ code to allow input of strings that are wider than the crt or
  the current window.  Will scroll the window to allow continued input

This is for entering large strings in a smaller
screen (do you have a monitor that's 255 chars wide???). In any case, I'll
give it to you now. So long as you make the viewport larger than the
length limit of the string, you will have no scrolling and no problem. I
will simply have to fix the scrolling later. Modify as you wish, you may
find it useful. CRT.TPU is required. }


uses crt;
const     ksins = 128; {insert mode on}
var       kbshift :    byte absolute $40:$17; {shift key status}
Function Getkey:word;
assembler; asm
 xor ah,ah
 int $16
end;
Procedure Beep(Hz,Ms:word);
begin
 sound(hz);
 delay(ms);
 nosound;
end;
function edstr(var instring;x,y,viewport,color,limit:byte):boolean;
var
 wmax,wmin:word;
 showpos,xmax,ymax,editpos,viewpos,oldx,oldy,oldcolor:byte;
 update,insmode:boolean;
 editstr:string absolute instring;
 key:record
  ch,scan:byte;
 end;
begin
  wmax:=windmax; {store window}
  wmin:=windmin; {store window}
  oldcolor:=textattr; {store color}
  oldx:=wherex; {store cursor}
  oldy:=wherey; {store cursor}
  window(1,1,80,25);
  window(1,1,80,50);
  xmax:=windmax and 255 + 1;
  ymax:=windmax shr 8 + 1;
  {verify viewport dimensions}
  if (y<=ymax) and (x+viewport-1<=xmax) and (viewport<>0) then begin
  edstr:=true;
  window(x,y,x+viewport-1,y); {set window}
  textattr:=color; {set new color}
  viewpos:=1; {init view pos}
  editpos:=1; {init edit pos}
  clrscr; {clear window}
  kbshift:=kbshift or ksins; {force insert}
  update:=true;
  if editstr[0]>char(limit) then editstr[0]:=char(limit);
  repeat {loop until Enter pressed}
   {update display}
   if update then begin
    gotoxy(1,1);
    inc(windmax); {prevents CRT scrolling}
    showpos:=viewpos;
    while (showpos<=length(editstr)) and (showpos<=viewpos+viewport-1) do
    begin
     write(editstr[showpos]);
     inc(showpos);
    end;
    dec(windmax); {restore window after temporary anti-scroll}
    clreol;
   end;
   update:=true;
   gotoxy((editpos-1) mod viewport+1,1); {proper cursor edit pos}
   word(key):=getkey; {get key}
   insmode:=kbshift and ksins<>0; {check insert mode}
   {if insert then flat cursor else block cursor}
   case key.ch of {check key char}
    0:case key.scan of {check key scan code}
     $47:editpos:=1; {home}
     $4B:if editpos<>1 then dec(editpos); {left}
     $4D:if (editpos<>limit) and (editpos<>length(editstr)+1) then
         inc(editpos); {right}
     $4F:if length(editstr)=limit then editpos:=limit
         else editpos:=length(editstr)+1; {end}
     $53:delete(editstr,editpos,1); {del}
     $77:{^Home, del till start of line}
         begin
          delete(editstr,1,editpos-1);
          editpos:=1;
         end;
     $75:delete(editstr,editpos,255); {^End, del till end of line}
     $73:{^Left, seek word left}
         if editpos=1 then update:=false
         else repeat
          dec(editpos);
         until (editpos=1) or (editstr[editpos-1]=' ');
     $74:{^Right, seek word right}
         if (editpos=limit) or (editpos=length(editstr)+1) then
          update:=false
         else repeat
          inc(editpos);
         until (editstr[editpos-1]=' ') or (editpos=limit)
          or (editpos=length(editstr)+1);
     else update:=false; {do not waste time updating screen}
    end; {check key scan code}
    8:if editpos>1 then begin {backspace}
     dec(editpos);
     delete(editstr,editpos,1);
    end
    else update:=false;
    32..255:begin {valid chars}
     if insmode or (length(editstr)+1=editpos) then
      {inserted if using insert mode OR if overstrike AND at string end}
      if (length(editstr)<>limit) then insert(char(key.ch),editstr,editpos)
      else beep(5000,10) {error: string full}
     else editstr[editpos]:=char(key.ch); {overstrike char}
     if editpos<>limit then inc(editpos); {inc pos within limit}
    end; {valid chars}
    else update:=false; {do not waste time updating screen}
   end; {check key char}

   {update scroll window}
   while editpos<viewpos do dec(viewpos,viewport); {left}
   while editpos>=viewpos+viewport do inc(viewpos,viewport); {right}
  until key.ch=13; {enter ends loop/input}
  textattr:=oldcolor; {minimal screen clean up}
  clrscr;
 end {valid viewport}
 else edstr:=false; {invalid viewport}
 windmin:=wmin; {restore window}
 windmax:=wmax; {restore window}
 textattr:=oldcolor; {restore color}
 gotoxy(oldx,oldy); {restore cursor}
end; {edstr}

VAR
     aStr : STRING;

BEGIN
    IF edstr(aStr,   { the value to edit }
             10,     { Col (x) }
             10,     { Row (y) }
             50,     { window width max }
             31,     { input color }
             100)    { maximum length of input }
         THEN WriteLn(aStr);
END.

