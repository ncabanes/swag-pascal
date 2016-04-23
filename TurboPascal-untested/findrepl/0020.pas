Function TrimL(strn : string) : string;
var
   st : string;
begin
   move(strn,st,length(strn)+1);
   st := strn;
   while (length(st) > 0) and (st[1] = ' ') do delete(st, 1, 1);

   TrimL := st;
end;

Function TrimR(strn : string) : string;
var
   l  : Integer;
   st : string;
begin
   l := length(strn);
   move(strn,st,l+1);
   st[0] := '*';

   while st[l] = ' ' do dec(l);
   st[0] := chr(l);
   TrimR := st;
end;




Function Trim(strn:String) : String;
Begin;
   Trim:=Triml(trimr(Strn));
end;




Function Search_it(FindMe, SearchMe : String; Sensity : Boolean) : Boolean;
Var
  Gefunden        : Boolean;
  SStat           : Byte;
  Lauf, Durchlauf : Byte;
  GanzString      : String;

Begin;
  Gefunden:=TRUE;
  If Trim(FindMe) <> '' then Begin;
  {How many OR ?}
  FindMe:=TrimR( FindMe );
  Durchlauf :=1;
  For Lauf := 1 To Length( FindMe ) Do If FindMe[ Lauf ] = ';' Then Inc( DurchLauf );
  FindMe:=TrimR( FindMe );
  GanzString := FindMe;
  Gefunden:=FALSE;
  For Lauf := 1 To DurchLauf Do begin;
   If Gefunden = FALSE Then Begin;
    Gefunden := TRUE;
    If Pos( ';', GanzString) > 0 Then Begin;
      FindMe := Trim( Copy( GanzString, 1, Pos( ';', GanzString) - 1 ));
      Delete( GanzString, 1, Pos( ';', GanzString ));
    End Else Begin
      FindMe := GanzString;
    End;

    sstat    := 0;
    FindMe   := TrimR( FindMe );
    SearchMe := TrimR( SearchMe );

    {*** Use this if you need case sensity search
    If sensity = FALSE Then Begin;
      searchme := Up( searchme );
      Findme   := Up( findme );
    End;
    }

    {Check for .. < or / or /.. etc and extract search string}
    if pos( '/', findme ) = 1 Then Begin;
      {Oposite ?}
      findme := copy( findme, 2, length( findme ) - 1);
      sstat  := sstat+4;
    End;

    If pos( '..', findme) > 0 Then Begin;
      {x.. or ..x or ..x..}

      If pos( '..', findme) = 1 Then Begin;
        {..x or ..x..}
        findme:=copy(findme,3,length(findme)-2);
        sstat:=sstat+1;
      End;
      if pos('..',findme)>1 then Begin;
        {..x.. or x..}
        findme:=copy(findme,1,length(findme)-2);
        sstat:=sstat+2;
      End;
    End;

    {= equals EMPTY}
    if findme='=' then findme:='';

    if ((pos('>',findme)=1) or (pos('<',findme)=1)) then Begin;
      { > or < }
      if sstat=0 then Begin;
        if pos('>',findme)=1 then Begin;
          sstat:=sstat+9;
          findme:=copy(findme,2,length(findme)-1);
        end else begin
          sstat:=sstat+10;
          findme:=copy(findme,2,length(findme)-1);
        End;
        if pos('=',findme)=1 then Begin;
          {>= or <=}
          sstat:=sstat+2;
          findme:=copy(findme,2,length(findme)-1);
        End;
      End;
    End;

    if sstat=4 then sstat:=8;
    if sstat=0 then sstat:=4;

    If ((Sstat>=9) and (Sstat<=12)) then begin;
      if searchme='' then Gefunden:=FALSE;
    End;

    case sstat of
      1  : if ((pos(findme,searchme)<>length(searchme)-length(findme)+1)
               or (pos(findme,searchme)=0)) then gefunden:=FALSE;{1  ..x}
      2  : if pos(findme,searchme)<>1 then gefunden:=FALSE;{2  x..}
      3  : if pos(findme,searchme)=0 then gefunden:=FALSE;{3  ..x..}
      4  : if findme<>searchme then gefunden:=FALSE;{4  x}


      5  : if pos(findme,searchme)=length(searchme)-length(findme)+1
              then gefunden:=FALSE;{5  /..x}
      6  : if pos(findme,searchme)=1 then gefunden:=FALSE;{6  /x..}
      7  : if pos(findme,searchme)<>0 then gefunden:=FALSE;{7  /..x..}
      8  : if findme=searchme then gefunden:=FALSE;{8  /x}


      9  : if searchme<=findme then gefunden:=FALSE;{9  >x}
      10 : if searchme>=findme then gefunden:=FALSE;{10 <x}
      11 : if searchme<findme then gefunden:=FALSE;{11 >=x}
      12 : if searchme>findme then gefunden:=FALSE;{12 <=x}
    End;
   End;
  End;
  Search_It:=Gefunden;
End;
