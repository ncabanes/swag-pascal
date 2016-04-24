(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0043.PAS
  Description: Create Chars in Graphics
  Author: MICHAEL HOENIE
  Date: 11-21-93  09:28
*)


  { This program allows you to create characters using the GRAPHICS unit
    supplied otherwise with the SWAG routines. If you have any questions
    on these routines, please let me know.

    MICHAEL HOENIE - Intelec Pascal Moderator.  }

  program charedit;

  uses dos, crt;

  const numnewchars=1;

  type
    string80=string[80];

  var { all variables inside of the game }
    char_map:array[1..16] of string[8];
    xpos,ypos,x,y,z:integer;
    out,incom:string[255];
    charout:char;
    outfile:text;
    char:array[1..16] of byte;

    procedure loadchar;
    type
      bytearray=array[0..15] of byte;
      chararray=record
        charnum:byte;
        chardata:bytearray;
      end;
    var
      regs:registers;
      newchars:chararray;
    begin
      with regs do
        begin
          ah:=$11;   { video sub-Function $11 }
          al:=$0;    { Load Chars to table $0 }
          bh:=$10;   { number of Bytes per Char $10 }
          bl:=$0;    { Character table to edit }
          cx:=$1;    { number of Chars we're definig $1}
          dx:=176;
          for x:=0 to 15 do newchars.chardata[x]:=char[x+1];
          es:=seg(newchars.chardata);
          bp:=ofs(newchars.chardata);
          intr($10,regs);
        end;
    end;

  Procedure FastWrite(Col,Row,Attrib:Byte; Str:string80);
  begin
    inline
      ($1E/$1E/$8A/$86/row/$B3/$50/$F6/$E3/$2B/$DB/$8A/$9E/col/
      $03/$C3/$03/$C0/$8B/$F8/$be/$00/$00/$8A/$BE/attrib/
      $8a/$8e/str/$22/$c9/$74/$3e/$2b/$c0/$8E/$D8/$A0/$49/$04/
      $1F/$2C/$07/$74/$22/$BA/$00/$B8/$8E/$DA/$BA/$DA/$03/$46/
      $8a/$9A/str/$EC/$A8/$01/$75/$FB/$FA/$EC/$A8/$01/$74/$FB/
      $89/$1D/$47/$47/$E2/$Ea/$2A/$C0/$74/$10/$BA/$00/$B0/
      $8E/$DA/$46/$8a/$9A/str/$89/$1D/$47/$47/$E2/$F5/$1F);
  end;

  procedure initalize;

  begin
    for x:=1 to 16 do char[x]:=0;
    xpos:=1;
    ypos:=1;
    for x:=1 to 16 do char_map[x]:='        '; { clear it out }
  end;

  procedure display_screen;
  begin
    loadchar;
     fastwrite(1,1,$1F,'         CHAREDIT - By Michael S. Hoenie         ');
     fastwrite(1,2,$7,'      12345678   ┌─────Data');
     fastwrite(1,3,$7,'     ▄▄▄▄▄▄▄▄▄▄  │');
     fastwrite(1,4,$7,'   1 █        █ 000');
     fastwrite(1,5,$7,'   2 █        █ 000 Single:  ░');
     fastwrite(1,6,$7,'   3 █        █ 000');
     fastwrite(1,7,$7,'   4 █        █ 000 Multiple:');
     fastwrite(1,8,$7,'   5 █        █ 000');
     fastwrite(1,9,$7,'   6 █        █ 000     ░░░░░░');
    fastwrite(1,10,$7,'   7 █        █ 000     ░░░░░░');
    fastwrite(1,11,$7,'   8 █        █ 000     ░░░░░░');
    fastwrite(1,12,$7,'   9 █        █ 000                    U            ');
    fastwrite(1,13,$7,'  10 █        █ 000 f1=paint spot      │    MOVEMENT');
    fastwrite(1,14,$7,'  11 █        █ 000 f2=erase spot   L──┼──R         ');
    fastwrite(1,15,$7,'  12 █        █ 000  S=save char       │            ');
    fastwrite(1,16,$7,'  13 █        █ 000  Q=quit editor     D');
    fastwrite(1,17,$7,'  14 █        █ 000  C=reset char    r=scroll-right');
    fastwrite(1,18,$7,'  15 █        █ 000  l=scroll-left');
    fastwrite(1,19,$7,'  16 █        █ 000  r=scroll-right');
    fastwrite(1,20,$7,'     ▀▀▀▀▀▀▀▀▀▀      u=scroll-up');
  end;

  procedure calculate_char;
  begin
    for x:=1 to 16 do char[x]:=0;
    for x:=1 to 16 do
      begin
        fastwrite(7,x+3,$4F,char_map[x]);
        incom:=char_map[x];
        y:=0;
        if copy(incom,1,1)='█' then y:=y+1;
        if copy(incom,2,1)='█' then y:=y+2;
        if copy(incom,3,1)='█' then y:=y+4;
        if copy(incom,4,1)='█' then y:=y+8;
        if copy(incom,5,1)='█' then y:=y+16;
        if copy(incom,6,1)='█' then y:=y+32;
        if copy(incom,7,1)='█' then y:=y+64;
        if copy(incom,8,1)='█' then y:=y+128;
        char[x]:=y;
      end;
    for x:=1 to 16 do
      begin
        str(char[x],incom);
        while length(incom)<3 do insert(' ',incom,1);
        fastwrite(17,x+3,$4E,incom);
      end;
    loadchar;
  end;

  procedure do_online;
  var
    done:boolean;
    int1,int2,int3:integer;
  begin


    done:=false;
    int1:=0;
    int2:=0;
    int3:=0;
    while not done do
      begin
        incom:=copy(char_map[ypos],xpos,1);
        int1:=int1+1;
        if int1>150 then int2:=int2+1;
        if int2>4 then
          begin
            int1:=0;
            int3:=int3+1;
            if int3>2 then int3:=1;
            case int3 of
              1:fastwrite(xpos+6,ypos+3,$F,incom);
              2:fastwrite(xpos+6,ypos+3,$F,'');
            end;
          end;

{ this section moved over to be transferred across the network. }

if keypressed then
  begin
    charout:=readkey;
    out:=charout;
    if ord(out[1])=0 then
      begin
        charout:=readkey;
        out:=charout;
        fastwrite(60,2,$2F,out);
        case out[1] of
          ';':begin { F1 }
                delete(char_map[ypos],xpos,1);
                insert('█',char_map[ypos],xpos);
                calculate_char;
              end;
          '<':begin { F2 }
                delete(char_map[ypos],xpos,1);
                insert(' ',char_map[ypos],xpos);
                calculate_char;
              end;
          'H':begin { up }
                ypos:=ypos-1;
                if ypos<1 then ypos:=16;
                calculate_char;
              end;
          'P':begin { down }
                ypos:=ypos+1;
                if ypos>16 then ypos:=1;
                calculate_char;
              end;
          'K':begin { left }
                xpos:=xpos-1;
                if xpos<1 then xpos:=8;
                calculate_char;
              end;
          'M':begin { right }
                xpos:=xpos+1;
                if xpos>8 then xpos:=1;
                calculate_char;
              end;
        end;
      end else


        begin { regular keys }
          case out[1] of
            'Q','q':begin { done }
                      clrscr;
                      write('Are you SURE you want to quit? (Y/n) ? ');
                      readln(incom);
                      case incom[1] of
                        'Y','y':done:=true;
                      end;
                      clrscr;
                      display_screen;
                      calculate_char;
                    end;
            'S','s':begin { save }
                      assign(outfile,'chardata.txt');
                      {$i-} reset(outfile) {$i+};
                      if (ioresult)>=1 then rewrite(outfile);
                      append(outfile);
                      writeln(outfile,'Character Char:');
                      writeln(outfile,'');
                      writeln(outfile,'       12345678');
                      for x:=1 to 16 do
                        begin
                          str(x,out);
                          while length(out)<6 do insert(' ',out,1);
                          writeln(outfile,out+char_map[x]);
                        end;
                      writeln(outfile,'');
                      write(outfile,'Chardata:');
                      for x:=1 to 15 do
                        begin
                          str(char[x],incom);
                          write(outfile,incom+',');
                        end;
                      str(char[16],incom);
                      writeln(outfile,incom);
                      writeln(outfile,'-----------------------------');
                      close(outfile);
                      clrscr;
                      writeln('File was saved under CHARDATA.TXT.');
                      writeln;
                      write('Press ENTER to continue ? ');
                      readln(incom);
                      clrscr;
                      display_screen;
                      calculate_char;
                    end;
            'U','u':begin { move entire char up }
                     incom:=char_map[1];
                     for x:=2 to 16 do char_map[x-1]:=char_map[x];
                     char_map[16]:=incom;
                     calculate_char;
                    end;
            'R','r':begin { move entire char to the right }
                      for x:=1 to 16 do
                        begin
                          out:=copy(char_map[x],8,1);
                          incom:=copy(char_map[x],1,7);
                          char_map[x]:=out+incom;
                        end;
                      calculate_char;
                    end;
            'L','l':begin { move entire char to the left }
                      for x:=1 to 16 do


                        begin
                          out:=copy(char_map[x],1,1);
                          incom:=copy(char_map[x],2,7);
                          char_map[x]:=incom+out;
                        end;
                      calculate_char;
                    end;
            'D','d':begin { move entire char down }
                      incom:=char_map[16];
                      for x:=16 downto 2 do char_map[x]:=char_map[x-1];
                      char_map[1]:=incom;
                      calculate_char;
                    end;
            'C','c':begin { reset }
                      clrscr;
                      write('Are you SURE you want to clear it? (Y/n) ? ');
                      readln(incom);
                      case incom[1] of
                        'Y','y':initalize;
                      end;
                      clrscr;
                      display_screen;
                      calculate_char;
                    end;
          end;
        end;
  end;
      end;
  end;

  begin
    textmode(c80);
    initalize;
    display_screen;
    calculate_char;
    do_online;
    clrscr;
    writeln('Thanks for using CHAREDIT!');
  end.


