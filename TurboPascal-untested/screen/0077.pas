{ Here's a fancy little program! Give it a try and modify it if you like! }

program hypno; { very hypnotic! }

uses crt;

const
  max_hypno=100;

type
  string80=string[80];

  Procedure FastWrite(col,row,Attrib:Byte; Str:string80);
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

var
  x_speed,
  x_speed_count,
  x_xpos,
  x_color,
  x_alive,
  x_dir,
  x_ypos:array[1..max_hypno] of integer;
  x_type:array[1..max_hypno] of string[1];
  color1,color2,x,i,j,k,g:integer;

procedure setup;
begin
  for x:=1 to max_hypno do
    begin
      x_speed[x]:=1;
      x_speed_count[x]:=0;
      case random(3)+1 of
        1:x_type[x]:='';
        2:x_type[x]:='';
        3:x_type[x]:='';
      end;
      x_xpos[x]:=random(80)+1;
      x_dir[x]:=random(2)+1;
      x_alive[x]:=0;
      x_ypos[x]:=50;
      x_color[x]:=random(15)+1;
      color1:=random(255)+1;
      color2:=random(255)+1;
    end;
end;

var
  counter:integer;

procedure move_hypnos;
var
  oldx,oldy:integer;
  moved:boolean;
begin
  if random(32767)=1 then
    begin
      color1:=random(255)+1;
      color2:=random(255)+1;
    end;
  counter:=counter+1;
  if counter>max_hypno then counter:=1;
  oldx:=x_xpos[counter];
  oldy:=x_ypos[counter];
  moved:=false;
  if x_alive[counter]=0 then if random(1100)=500 then
    x_alive[counter]:=1;
  if x_alive[counter]=1 then
    begin
      x_speed_count[counter]:=x_speed_count[counter]+1;
      if x_speed_count[counter]>=x_speed[counter] then
        begin

          case random(5)+1 of
            1:begin
                x_ypos[counter]:=x_ypos[counter]+1;
                if x_ypos[counter]>50 then x_ypos[counter]:=1;
              end;
            2:begin
                x_ypos[counter]:=x_ypos[counter]-1;
                if x_ypos[counter]<0 then x_ypos[counter]:=50;
              end;
          end;
          x_speed_count[counter]:=0;
          case x_dir[counter] of
            1:begin
                x_xpos[counter]:=x_xpos[counter]-1;
                if x_xpos[counter]<0 then
                  begin
                    x_speed[counter]:=random(5)+1;
                    x_speed_count[counter]:=0;
                    x_xpos[counter]:=80;
                    x_ypos[counter]:=random(50)+1;
                    x_dir[counter]:=random(2)+1;
                  end;
              end;
            2:begin
                x_xpos[counter]:=x_xpos[counter]+1;
                if x_xpos[counter]>80 then
                  begin
                    x_speed[counter]:=random(5)+1;
                    x_speed_count[counter]:=0;
                    x_xpos[counter]:=0;
                    x_ypos[counter]:=random(50)+1;
                    x_dir[counter]:=random(2)+1;
                  end;
              end;
          end;
        end;
    end;
  moved:=false;
  if x_xpos[counter]<>oldx then moved:=true;
  if x_ypos[counter]<>oldy then moved:=true;
  if moved=true then
    begin
      if x_dir[counter]=1 then fastwrite(oldx,oldy,color2,' ')
        else fastwrite(oldx,oldy,color1,' ');
      fastwrite(x_xpos[counter],x_ypos[counter],
        x_color[counter],x_type[counter]);
    end;
end;

begin
  randomize;
  setup;
  counter:=0;
  while not keypressed do move_hypnos;
end.
