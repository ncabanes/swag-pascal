(*
  Category: SWAG Title: TEXT EDITING ROUTINES
  Original name: 0016.PAS
  Description: EDITLINE Unit
  Author: SWAG TEAM SUPPORT
  Date: 08-30-97  10:08
*)


Unit EditLine;
{$O+,F+}

interface

Const CrLf:string[2]=#13+#10;


Type EditorFuncFlagsType = set of (Ins,Caps,EchoDots);
     EditorExitType = (Up,Down,Enter,Tab,Esc);
     EditorExitAllowType = Set of EditorExitType;

     WriteType = Procedure (s:string);
     movexType = Procedure (x:integer);
     WhereXType = Function:byte;
     TextColorType = Procedure(c:byte);
     TextBackgroundtype = procedure(c:byte);
     ReadKeyType = function(var extend:char):char;
     GotoXYType = procedure(x,y:byte);
     ClrEolType = Procedure;

Type
 pLineEditObj = ^LineEditObj;
 LineEditObj = object
   Constructor Init(sx,sy,MLen,fg,bg,abarcolor_:byte;
               ansi_:boolean;
               instr:string;
               edf:editorfuncflagstype;
               exf:editorexitallowtype;
               Write_:WriteType;
               movex_:movextype;
               WhereX_:WhereXType;
               textcolor_:textcolortype;
               textbackground_:textbackgroundtype;
               readkey_:readkeytype;
               gotoxy_:gotoxytype;
               ClrEol_:ClrEolType;
               pstr_:string;
               psmlen_:byte;
               psc_:byte);

   Procedure AnsiPrompt;
   Function Edit: EditorExitType;
   Procedure NonAnsiPrompt;
   Function Answer:string;
   Procedure AntiBar(f:boolean);
   Destructor Done;
   Private
       startx,starty,MaxLen,FGc,BGc,abarcolor:byte;
       ansi: boolean;
       EditFlags:EditorFuncFlagsType;
       ExitFlags:EditorExitAllowType;
       movex:movextype;
       write:writetype;
       wherex:wherextype;
       textcolor:textcolortype;
       textbackground:textbackgroundtype;
       gotoxy:gotoxytype;
       readkey:readkeytype;
       clreol:clreoltype;
       s:string;
       pstr:string;
       psmlen:byte;
       psc:byte;
   end;


implementation

uses etc;

Constructor LineEditObj.Init(sx,sy,MLen,fg,bg,abarcolor_:byte;
               ansi_:boolean;
               instr:string;
               edf:editorfuncflagstype;
               exf:editorexitallowtype;
               Write_:WriteType;
               movex_:movexType;
               WhereX_:WhereXType;
               textcolor_:textcolortype;
               textbackground_:textbackgroundtype;
               readkey_:readkeytype;
               gotoxy_:gotoxytype;
               clreol_:clreoltype;
               pstr_:string;
               psmlen_:byte;
               psc_:byte);
 begin
 clreol:=clreol_;
 MaxLen:=mlen;
 abarcolor:=abarcolor_;

 psc:=psc_;

 psmlen:=psmlen_;

 fgc:=fg;
 bgc:=bg;
 ansi:=ansi_;
 EditFlags:=edf;
 ExitFlags:=exf;

 movex:=movex_;
 write:=write_;
 wherex:=wherex_;

 textcolor:=textcolor_;
 textbackground:=textbackground_;

 gotoxy:=gotoxy_;

 readkey:=readkey_;
 pstr:=pstr_;

 startx:=sx;
 starty:=sy;

 s:=instr;
 end;

Procedure LineEditObj.NonAnsiPrompt;
 begin
 write(crlf+crlf);
 write(pstr+crlf)
 end;

procedure LineEditObj.AnsiPrompt;
 begin

 gotoxy(startx,starty);
 textcolor(psc);
 write(rjustify(pstr,psmlen)+' ');

 end;

procedure LineEditObj.AntiBar(f:boolean);
 var i:word;
 begin
 if not(f) or ((not(abarcolor=fgc)) and (not(bgc=0))) then
   begin
   textcolor(abarcolor);
   textbackground(0);
   if ((startx>0) and (starty>0)) then gotoxy(startx+psmlen+1,starty);
   write(' ');

   if echodots in editflags then
     begin
     for i:=1 to length(s) do write('.');
     end
   else
    write(s);

   clreol;
   end;
 end;

destructor LineEditObj.Done;
 begin
 end;

function LineEditObj.answer:string;
 begin
 answer := s;
 end;

Function LineEditObj.Edit:EditorExitType;
   var
       extended: char;
       tempkey : char;
       done_   : boolean;
       index   : byte;
       answ    : string;
       baseX   : byte;
       i       : byte;
       insmode : boolean;
  stringtempkey: string[1];

   begin
   if ansi then if ((startx>0) and (starty>0))
       then gotoxy(startx+psmlen+1,starty);

   InsMode:= (Ins in EditFlags);

   done_ := false;
   index := 0;
   answ := '';
   if length(s) <> 0 then
      begin
      answ := s;
      index := length(s);
      end;

   if ansi then begin
   TextColor(fgc);
   TextBackground(bgc);
   end;

   write(' ');
   if echodots in editflags then
    begin
    for i:=1 to length(s) do write('.')
    end
   else Write(s);

   if ANSI and (not(fgc=abarcolor) or not(bgc=0)) then
     begin
     for i:=length(s)+1 to maxlen+1 do Write(' ');
     movex(-maxlen+length(answ)-1);
     end;

   { functions ... backspace, right, left, overwrite mode for L, R }
   {               enter, delete                                   }

   repeat
      tempkey := readkey(extended);
      case tempkey of
        ^U: if ansi then
               begin
               answ:=s;
               movex(-index);
               if echodots in editflags then
                 begin
                 for i:=1 to length(answ) do write('.')
                 end
               else Write(answ);
               for i:=length(answ)+1 to maxlen do write(' ');
               index:=length(answ);
               movex(-maxlen+length(answ));
               end
            else
               begin
               for i:=1 to length(answ) do write(#8+' '+#8);
               answ:=s;
               if echodots in editflags then
                 begin
                 for i:=1 to length(answ) do write('.')
                 end
               else Write(answ);
               index:=length(answ);
               end;

        #27,^Z: if esc in exitflags then
              begin
              done_:=true;
              edit:=esc;
              end;

        #09: if ansi and (tab in exitflags) then
              begin
              done_:=true;
              edit:=tab;
              end;


        #32,

             {'A'..'Z', 'a'..'z','0'..'9', ',' , '.':}

             ' '..'~':

             begin
              if ord(answ[0]) < maxlen then
               begin
               inc(index);
               if index <= maxlen then
               begin
               if (Caps in EditFlags) then
   {for upcase} if (answ[index-1] = #32) or (answ[index-1] = #0) then
   {checking}     begin
                  tempkey := upcase(tempkey);
                  end
                else tempkey := lowcase (tempkey);

               if (Insmode) and ansi then
                  begin
                  if ord(answ[0]) < maxlen then
                    begin
                    stringtempkey := tempkey;
                    insert(stringtempkey, answ, index);
                    if (Caps in EditFlags) then answ := CaseStr(answ);
                    if index <> ord(answ[0]) then
                     begin
                     if echodots in editflags then
                      begin
                      for i:=index to length(answ)-index+3 do write('.');
                      write(' ');
                      end
                     else
                      begin
                      write( copy(answ,index,length(answ)-index+1)+' ' );
                      end;
                     movex(-length(answ)-1+index);
                     end
                    else if echodots in editflags then write('.') else Write(tempkey);
                    end;
                  end
               else
                  begin
                  if index < ord(answ[0])+1 then answ[index] := tempkey
                  else answ := answ + tempkey;
                  if echodots in editflags then write('.') else Write(tempkey)
                  end;
               end;
              end;
             end;
        #13: if Enter in ExitFlags then
             begin
             done_ := true;
             edit := Enter;
             end;

        ^V: if (ins in editflags) then insmode := not insmode;

        #8:
             begin

             if (index > 0)  then
              begin
              delete(answ, Index, 1);
              if ANSI then
               begin
               if (index=length(answ)+1) then
                 begin
                 movex(-1);
                 write(' ');
                 movex(-1);
                 end
               else
                 begin
                 movex(-1);
                 if echodots in editflags then
                  begin
                  for i:=index to length(answ)-index+1 do write('.');
                  write(' ');
                  end
                 else
                  write( copy(answ,index,length(answ)-index+1)+' ' );
                 movex(-length(answ)-1+index-1);
                 end;
               end
              else Write(#8+' '+#8);
              dec(index);
              end;
             end;
        #0:                         { test for extended characters }
             begin
             case extended of        { poll for extended part }
               #60:  if ansi then
                      begin
                      answ:=s;
                      movex(-index);
                      if echodots in editflags then
                       begin
                       for i:=1 to length(answ) do write('.');
                       end
                      else
                       Write(answ);

                      for i:=length(answ)+1 to maxlen do write(' ');
                      index:=length(answ);
                      movex(-maxlen+length(answ));
                      end
                     else
                      begin
                      for i:=1 to length(answ) do write(#8+' '+#8);
                      answ:=s;
                      if echodots in editflags then
                       begin
                       for i:=1 to length(answ) do write('.');
                       end
                      else
                       write(answ);
                       index:=length(answ);
                      end;

               #80: if ansi and (down in exitflags) then
                    begin
                    done_:=true;
                    edit:=down;
                    end;

               #72: if ansi and (up in exitflags) then
                    begin
                    done_:=true;
                    edit:=up;
                    end;

               #75:                 { left arrow }
                   begin
                   if ANSI then
                    begin
                    if index >= 1 then
                     begin
                     dec(index);
                     movex(-1);
                     end;
                    end;
                   end;
               #77:                 { right arrow }
                  begin
                  if ANSI then
                   begin
                   if index < ord(answ[0]) then
                     begin
                     inc(index);
                     if echodots in editflags then write('.') else write(answ[index]);
                     end;
                   end;
                  end;
               #71:                 { home }
                  begin
                  if ANSI then
                     begin
                     movex(-index);
                     index:=0;
                     end;
                  end;

               #79: IF ANSI then { end }
                  begin
                  movex(length(answ)-index);
                  index := ord(answ[0]);
                  end;

               #82:      { ins }
                if (ins in editflags) then insmode := not insmode;

               #83:         { del }
                  begin
                  if ANSI then
                    begin
                    delete(answ,index+1,1);
                    If (Caps in EditFlags) then answ := CaseStr(answ);
                    if echodots in editflags then
                     begin
                     for i:=index+1 to length(answ)-index do write('.');
                     write(' ');
                     end
                    else
                     write( copy(answ,index+1,length(answ)-index)+' ' );
                     movex(-length(answ)-1+index);
                     end;
                  end;

               end;                           { end of 'case readkey of' }
             end;                             { end of '#0: begin' }
        end;                                  { end of 'case tempkey of' }
   until done_;
   s := answ;
   end;

end.


