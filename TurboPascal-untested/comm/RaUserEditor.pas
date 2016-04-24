(*
  Category: SWAG Title: COMMUNICATIONS/INT14 ROUTINES
  Original name: 0086.PAS
  Description: RA User Editor
  Author: EVAN DUPUIS
  Date: 05-26-95  23:25
*)

{
Here's a simple RA user editor I wrote for my cosysop.  It's nothing fancy,
and probably contains some "no-no's", and isn't a work of art, but it
compiles and works!  You will probably have to change a path name or two and
the security levels to reflect your system etc.. Once again, you'll need
JPDoor 4.x and STRNTTT5.PAS from Technojocks Turbo Toolkit.  L8R!
}
{$R-,S+,O-,A-,E-,N-,D-,L-,V-}
{$M 32768,2048,4096}

Program Stoney;


USES
  Crt,
  Dos,
  JPGlobal,
  JPDoor40,
  StrnTTT5,
  ExitCvt;

{$I STRUCT.200}        (*      REMOTEACCESS STRUCTS!!!!!!!!!!!!!!! *)

Var
  X             : Integer;
  Temp,
  ExitPath      : String[80];
  FlagToChange  : String[2];
  ExitFile      : File Of ExitInfoRecord;
  TxtDir        : String[80];
  MainDone      : Boolean;
  Done,Done1,Done2 : Boolean;
  Ch            : Char;
  usr           : USERSrecord;
  usrf          : file of USERSrecord;
  counter,counter2,counter3,counter4 : integer;
recno : integer;

Procedure Terminate(HaltCode:byte) ;
{ This is an example procedure to handle the halt codes passed by
  TrapExit.  See the TrapExit.Pas file for more information on
  the codes returned and how they are passed to this procedure. }
Begin
  If ExitConverted Then DoConvert; { See Description Near End Of Program      }
  Case HaltCode Of              { Do Any Cleaning Up here.  TrapExit will     }
    0,                          { Describe the error on the screen as well as }
    7 : Begin                   { Logging it to disk.                         }
          ClearScreen ;
          sDisplay(0,11,0,'Returning to ') ;
          Display(0,7,0,FormatStr(SystemName)) ;
          Crlf ;
        End ;
  End ;
End;

{$I TRAPEXIT}                   { Include the TrapExit.Pas file               }


PROCEDURE GetThisNode(Counter : BYTE) ;
VAR
  Temp    : String[60];
  ErrCode : Integer;
BEGIN
  Temp := PARAMSTR(Counter) ;
  Delete(Temp,1,2);
  ThisNode := Temp;
  If Length(ThisNode) = 1 then ThisNode := '0' + ThisNode;
  MultiNode := TRUE ;
END;

procedure sdisplay_ln(latxt:string);
begin;
      if length(latxt)>1 then
      for counter := 1 to length(latxt) do
      if latxt[counter] in ['a'..'z'] then sDisplay(0,7,0,latxt[counter])
      else if latxt[counter] = #31 then charout(' ')
      else if latxt[counter] in ['A'..'Z'] then sDisplay(0,11,0,latxt[counter])
      else if latxt[counter] in ['0'..'9'] then sDisplay(0,14,0,latxt[counter])
      else sdisplay(0,3,0,latxt[counter]);
end;

procedure display_ln(latxt:string);
begin;
      if length(latxt)>1 then
      for counter := 1 to length(latxt) do
      if latxt[counter] in ['a'..'z'] then sDisplay(0,7,0,latxt[counter])
      else if latxt[counter] = #31 then charout(' ')
      else if latxt[counter] in ['A'..'Z'] then sDisplay(0,11,0,latxt[counter])
      else if latxt[counter] in ['0'..'9'] then sDisplay(0,14,0,latxt[counter])
      else sdisplay(0,3,0,latxt[counter]);
      crlf;
end;

procedure ezln(latxt:string);
begin;
      if length(latxt)>1 then
      for counter := 1 to length(latxt) do
      if latxt[counter] in ['a'..'z'] then sDisplay(0,7,0,latxt[counter])
      else if latxt[counter] in ['A'..'Z'] then sDisplay(0,11,0,latxt[counter])
      else if latxt[counter] in ['0'..'9'] then sDisplay(0,14,0,latxt[counter])
      else if latxt[counter] = '║' then sdisplay(0,8,0,latxt[counter])
      else sdisplay(0,3,0,latxt[counter]);
      crlf;
end;



Procedure GetParams;
Var
  Counter   : Byte;
Begin
  For Counter := 1 to ParamCount do
  Begin
    Temp := ChangeCase(ParamStr(Counter));
    If Temp[1] = '/' then
    Begin
      Case Temp[2] of
        'N' : GetThisNode(Counter);  { Update ThisNode variable with node #   }
        'D' : JP_Debug := True;      { See Note at end of program             }
        'S' : ShowWindow := True;    { Show the exploding window at startup   }
      End;
    End;
  End;
End;

procedure drawscreen;
begin;
  clearscreen;
  done := false;
  sdisplay(0,8,0,'╔════════');
  sdisplay(0,7,0,'═════════');
  sdisplay(0,15,0,'══════════');
  sdisplay(0,7,0,'═════════');
  display(0,8,0,'════════╗');
  sdisplay(0,8,0,'║');
  sdisplay_ln(' Stoney''s User Editor (Version 0.00 *BETA*) ');
  display(0,8,0,'║');
  sdisplay(0,8,0,'╠════════');
  sdisplay(0,7,0,'═════════');
  sdisplay(0,15,0,'══════════');
  sdisplay(0,7,0,'═════════');
  display(0,8,0,'════════╣');
  ezln('║ User Number..:                             ║');
  ezln('║ Real Name....:                             ║');
  ezln('║ Alias........:                             ║');
  ezln('║ Calling From.:                             ║');
  ezln('║ Security.....:                             ║');
  ezln('║ Sex..........:                             ║');
  ezln('║ Date of Birth:                             ║');
  ezln('║ Phone Number.:                             ║');
  ezln('║ Uploads......:                             ║');
  ezln('║ Downloads....:                             ║');
  ezln('║ Number Calls.:                             ║');
  sdisplay(0,8,0,'╚════════');
  sdisplay(0,7,0,'═════════');
  sdisplay(0,15,0,'══════════');
  sdisplay(0,7,0,'═════════');
  display(0,8,0,'════════╝');
  crlf;
end;


procedure listem;
begin;
          clearscreen;
          counter2 := 0;
          counter3 := 1;
          for counter2 := 0 to filesize(usrf)-1 do
            begin;
            {$I-}
            seek(usrf,counter2);
            read(usrf,usr);
            {$I+}
              inc(counter3);
              sdisplay_ln(rjust(commastr(counter2),3));
              sdisplay_ln(' '+ljust(usr.name+' ',25));
              counter4 := str_to_int(copy(usr.birthdate,7,2));
              counter4 := 95-counter4;
              sdisplay_ln(' '+rjust(commastr(counter4),4));
              sdisplay_ln(' ');
              sdisplay_ln(rjust(usr.voicephone,14));
              display_ln(rjust(usr.location,30));
              if counter3 = 23 then
                begin;
                sdisplay_ln('░▒▓ Hit A Key For More, (:) Set Current Record #,
(N) No More List! ▓▒░');                ch := upcase(getchar);
                case ch of
                ':' : begin;
                      crlf;
                      sdisplay_ln('Jump to Record #');
                      temp := getinput('',0,5);
                      counter4 := str_to_int(temp);
                      if (counter4 < 0) or (counter4 > (filesize(usrf)-1)) then
                        charout(#7)
                      else
                        begin;
                        {$I-}
                        seek(usrf,counter4);
                        read(usrf,usr);
                        recno := counter4;
                        drawscreen;
                        exit;
                        {$I+};
                        end;
                      end;
                'N' : begin;
                      drawscreen;
                      exit;
                      end;
                else crlf;
                end;
                counter3 := 1;
                end;
            end;
          {$I-}
          seek(usrf,recno);
          read(usrf,usr);
          {$I+}
          more('░▒▓ That''s All Folks - Hit Any Key to Continue! ▓▒░',12);
          drawscreen;
end;


Procedure EditUser;
Begin;
  recno := 0;
  {$I-}
  assign(usrf,'c:\ra\msgbase\users.bbs');
  reset(usrf);
  seek(usrf,0);
  read(usrf,usr);
  {$I+}
  if IOresult <> 0 then begin;
    display_ln('OH SHIT!!!!!  I Can''t Open The USERFILE!!');
    crlf;
    more('Major bad bug man!!!  Hit a key to resume!!:',14);
    halt(0);
    end;

  drawscreen;

  repeat
    done:=false;
    cursorpos(4,18);
    sdisplay_ln(ljust('#'+commastr(recno)+'/'+commastr(filesize(usrf)-1),28));
    cursorpos(5,18);
    sdisplay_ln(ljust(usr.name,28));
    cursorpos(6,18);
    sdisplay_ln(ljust(usr.handle,28));
    cursorpos(7,18);
    sdisplay_ln(ljust(usr.location,28));
    cursorpos(8,18);
    sdisplay_ln(ljust(commastr(usr.security),28));
    cursorpos(10,18);
    sdisplay_ln(ljust(usr.birthdate,28));
    cursorpos(11,18);
    sdisplay_ln(ljust(usr.voicephone,28));
    cursorpos(12,18);
    sdisplay_ln(ljust(commastr(usr.uploads),28));
    cursorpos(13,18);
    sdisplay_ln(ljust(commastr(usr.downloads),28));
    cursorpos(14,18);
    sdisplay_ln(ljust(commastr(usr.nocalls),28));
    cursorpos(9,18);

     if usr.sex = 1 then sdisplay_ln(ljust('Male',28))
else if usr.sex = 2 then sdisplay_ln(ljust('Female',28))
                    else sdisplay_ln(ljust('?! THEY DIDN''T KNOW !?:
'+commastr(usr.sex),28));

  cursorpos(22,1);
  display_ln('GENCMDS: (+)Next, (-)Prev, (Q) Quit, (:) JUMP TO #, CHANGE:
(S)ecurity'); sdisplay_ln('LIST BY: (F)emales, (L)IST ALL, Command..? ');
  repeat ch := upcase(getchar) until ch in ['L','+','F','-','Q','C','S',':'];
  case ch of
    '+' : begin;
          if recno+1 < filesize(usrf) then inc(recno);
          {$I-}
          seek(usrf,recno);
          read(usrf,usr);
          {$I+}
          end;
    'F' : begin;
          clearscreen;
          counter2 := 0;
          counter3 := 1;
          for counter2 := 0 to filesize(usrf)-1 do
            begin;
            {$I-}
            seek(usrf,counter2);
            read(usrf,usr);
            {$I+}
            if usr.sex = 2 then
              begin;
              inc(counter3);
              sdisplay_ln(rjust(commastr(counter2),3));
              sdisplay_ln(' '+ljust(usr.name+' ',25));
              counter4 := str_to_int(copy(usr.birthdate,7,2));
              counter4 := 95-counter4;
              sdisplay_ln(' '+rjust(commastr(counter4),4));
              sdisplay_ln(' ');
              sdisplay_ln(rjust(usr.voicephone,14));
              display_ln(rjust(usr.location,30));
              if counter3 = 22 then
                begin;
                more('░▒▓ Hit A Key For More Puss, Man! ▓▒░',12);
                counter3 := 1;
                end;
              end;
            end;
          {$I-}
          seek(usrf,recno);
          read(usrf,usr);
          {$I+}
          more('░▒▓ No More Puss Left - Hit Any Key to Continue! ▓▒░',12);
          drawscreen;
          end;
    'L' : begin;
          listem;
          end;
    'S' : begin;
          sdisplay_ln('Change Security Level..');
          cursorpos(18,1);
          sdisplay(0,8,0,'╔═══════════════');
          sdisplay(0,7,0,'════════════════');
          sdisplay(0,15,0,'═══════════════');
          sdisplay(0,7,0,'════════════════');
          display(0,8,0,'═══════════════╗');
          sdisplay(0,8,0,'║ ');
          sdisplay_ln('Levels: Lockout, Unval, Reg, Special, Elite, Awesome,
sYsop. Which One...? ');          display(0,8,0,' ║');
          sdisplay(0,8,0,'╚═══════════════');
          sdisplay(0,7,0,'════════════════');
          sdisplay(0,15,0,'═══════════════');
          sdisplay(0,7,0,'════════════════');
          display(0,8,0,'═══════════════╝');
          cursorpos(19,77);
          repeat ch := upcase(getchar) until ch in
['L','U','R','S','E','A','Y'];          case ch of
          'L' : usr.security := 0;
          'U' : usr.security := 50;
          'R' : usr.security := 150;
          'S' : usr.security := 200;
          'E' : usr.security := 1000;
          'A' : usr.security := 2000;
          'Y' : usr.security := 65535;
          end;
          {$I-}
          seek(usrf,recno);
          write(usrf,usr);
          {$I+}
          cursorpos(18,1);
          sdisplay(0,8,0,'╔═══════════════');
          sdisplay(0,7,0,'════════════════');
          sdisplay(0,15,0,'═══════════════');
          sdisplay(0,7,0,'════════════════');
          display(0,8,0,'═══════════════╗');
          sdisplay(0,8,0,'║ ');
          sdisplay_ln('Writing User File - C:\RA\MSGBASE\USERS.BBS, One
Moment..................  ');          display(0,8,0,' ║');
          sdisplay(0,8,0,'╚═══════════════');
          sdisplay(0,7,0,'════════════════');
          sdisplay(0,15,0,'═══════════════');
          sdisplay(0,7,0,'════════════════');
          display(0,8,0,'═══════════════╝');
          cursorpos(19,77);
          delay(490);
          cursorpos(18,1);
          display(0,c_fore,0,'
');          display(0,c_fore,0,'
');          display(0,c_fore,0,'
');          cursorpos(23,46);
          sdisplay(0,c_fore,0,'                           ');
          end;
    '-' : begin;
          if recno-1 > -1 then dec(recno);
          {$I-}
          seek(usrf,recno);
          read(usrf,usr);
          {$I+}
          end;
    ':' : begin;
          cursorpos(17,1);
          SDISPLAY_LN('Number to Jump To..? #');
          temp := getinput('',0,14);
          counter3 := str_to_int(temp);
          if (counter3 < 0) or (counter3 > (filesize(usrf)-1)) then
           begin;
           charout(#7);
           charout(#7);
           charout(#7);
           charout(#7);
           end else begin;
                    {$I-}
                    seek(usrf,counter3);
                    read(usrf,usr);
                    recno := counter3;
                    {$I+};
                    end;
          end;
    'Q' : BEGIN;
          done:=true;
          {$I-}
          close(usrf);
          {$I+}
          end;
  end;
  until done;
end;



Begin

  ShowWindow := False;          { Do Not Show The Exploding Window At Startup }
  ThisNode := '01';             { Default to Node 1 on single node systems    }

  JPLogName := 'STONEY';          { See note following program code
}
  ProductName := 'Stoney';    { Name Of Door, used on StatusLine            }

  DoorExit := TrapExit ;        { Assign ExitProcedure For The Door. TrapExit }
                                { handles all the error logging, etc.         }

  ForceNode := True;            { Always Read Dorinfo1.Def rather than        }
                                { Dorinfo2.Def                                }

  CkExitInfo:=False ;

  GetDorInfo(ThisNode,'') ;     { Read In the Exitinfo.BBS from the current   }
                                { directory. It is ASSUMED that this will be  }
                                { an RA 2.0 type ExitInfo.Bbs, so if your     }
                                { door 'might' be run on one of the versions  }
                                { mentioned in DoConvert, then make sure you  }
                                { Call DoConvert BEFORE this.                 }

  SetColor(0,15,0) ;            { Initialize the Screen Colors                }

  If Not Local Then             { This Simple ensures that a fossil driver IS }
  Begin                         { Loaded. If Not, it exits back to the BBS    }
    If Not SetFossil Then       { A Fossil Driver is NOT needed in Local Mode }
    Begin
      WriteLn(#7,'Fossil not installed');
      Halt(0);
    End Else WriteLn('Fossil Active');
  End;



  FossilHot := TRUE ;
  StatusLineOn := TRUE ;

  edituser;
  clearscreen;
  display_ln('Later, '+Username+'!');
  crlf;
  delay(1000);
  Halt(0);
END.


