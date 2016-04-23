{*******************************************************}
{                                                       }
{       Turbo Pascal Version 6.0                        }
{       Optional FormLine Unit                          }
{       for use with Turbo Vision                       }
{                                                       }
{       Copyright (c) 1991  J. John Sprenger            }
{                                                       }
{*******************************************************}

unit FormLine;

{$O+,F+,S+}

interface

uses

  {Turbo Pascal Run-Time Library Units}

  Crt,

  {Turbo Vision Standard Units}

  Objects, Drivers, Views, Dialogs, App,

  {Turbo Vision Accessory Units}

  StdDlg, MsgBox;

const

  { flError, flCharOk and flFormatOK are constants used  }
  { by tFormatLine.CheckPicture.  flError is returned    }
  { when an error is found.  flCharOk when an character  }
  { is found to be appropriate.  And flFormatOk when the }
  { entire input string is found acceptable.             }

  flError    = $0000;
  flCharOK   = $0001;
  flFormatOK = $0002;

  { flCharError is passed to tFormatLine.ReportError     }
  { when a character does not fit the proper form.       }
  { flFormatError is used when the format is not         }
  { satisfied even though input so far is acceptable.    }

  flCharError   = 1;
  flFormatError = 2;

  { CommandSet represents the characters used in Format  }
  { Line Pictures.  These match those used by Paradox.   }

  CommandSet = ['[','{','?','&','@','!','#','{',',',']',
  '}','*'];

type

  { tFormatLine }

  { tFormatLine is the improved tInputLine object which  }
  { accepts Paradox-form Picture strings to ensure that  }
  { data will be entered in an acceptable form.          }

  pFormatLine = ^tFormatLine;
  tFormatLine = object( tInputLine)
    Picture : string;
    constructor Init(var Bounds : tRect; AMaxLen
      : integer; Pic : string);
    function Valid(command : word) : boolean; virtual;
    procedure HandleEvent(var Event : tEvent); virtual;
    function CheckPicture(var s, Pic : string;
      var CPos : integer):word;
    procedure ReportError( kind : word); virtual;
  end;

  { tMoneyFormatLine }

  { tMoneyFormatLine is an input line intended for use   }
  { real number fields associated with money.  Input is  }
  { preceded with a "$" sign and terminated with a "."   }
  { followed by the appropriate fractional value.        }

  pMoneyFormatLine = ^tMoneyFormatLine;
  tMoneyFormatLine = object( tFormatLine )
    constructor Init(var Bounds : tRect; AMaxlen :
      integer);
    procedure SetData(var Rec); virtual;
    procedure GetData(var Rec); virtual;
    function DataSize : word; virtual;
  end;

  { tPhoneFormatLine }

  { tPhoneFormatLine is for phone number fields. Normal  }
  { 10-digit numbers are entered in the following form   }
  { (###) ###-####.  International numbers are entered   }
  { digit after digit with spaces and hyphens where the  }
  { user deems appropriate.                              }

  pPhoneFormatLine = ^tPhoneFormatLine;
  tPhoneFormatLine = object( tFormatLine )
    constructor Init(var Bounds : tRect; AMaxLen :
      integer);
    procedure SetData(var Rec); virtual;
    procedure GetData(var Rec); virtual;
  end;

  { tRealFormatLine }

  { tRealFormatLine is used for real number fields.  It  }
  { can handle both decimal and scientific notations.    }

  pRealFormatLine = ^tRealFormatLine;
  tRealFormatLine = object ( tFormatLine )
    constructor Init(var Bounds : tRect; AMaxLen :
      integer);
    procedure SetData(var Rec); virtual;
    procedure GetData(var Rec); virtual;
    function DataSize : word; virtual;
  end;

  { tIntegerFormatLine }

  { tIntegerFormatLine is used for integer fields.  It   }
  { accepts signed integers.                             }

  pIntegerFormatLine = ^tIntegerFormatLine;
  tIntegerFormatLine = object( tFormatLine )
    constructor Init(var Bounds : tRect; AMaxLen :
      integer);
    procedure SetData(var Rec); virtual;
    procedure GetData(var Rec); virtual;
    function DataSize : word; virtual;
  end;

  { tNameFormatLine }

  { tNameFormatLine accepts words and capitalizes the    }
  { first character of each word.  This would be used    }
  { proper names and addresses.                          }

  pNameFormatLine = ^tNameFormatLine;
  tNameFormatLine = object( tFormatLine )
    constructor Init(var Bounds : tRect; AMaxLen :
      integer);
  end;

  { tZipFormatLine }

  { tZipFormatLine is used for ZIP and Postal Code       }
  { fields.  It handles U.S. and Canadian format codes.  }

  pZipFormatLine = ^tZipFormatLine;
  tZipFormatLine = object( tFormatLine )
    constructor Init(var Bounds : tRect; AMaxLen :
      integer);
    end;

implementation


{ Function Copy represents a bit of syntatic sugar for   }
{ the benefit of the author.  It changes the Copy func.  }
{ so that its parameters represent start and end points  }
{ rather than a start point followed by a quantity.      }

function Copy(s : string; start, stop : integer) : string;
begin
  if stop < start then Copy:=''
  else Copy:=System.Copy(s,start,stop-start+1);
end;



{ Function FindMatch recursively locates the matching   }
{ grouping characters for "{" and "[".                  }

function FindMatch(P : string) : integer;
var
  i:integer;
  match:boolean;
  c:char;
begin
  i:=2;
  match:=false;
  while (i<=length(P)) and not match do
    begin
      if ((p[i]=']') and (p[1]='[')) or ((p[i]='}') and
        (p[1]='{')) then
        match:=true;
      if p[i]='{' then
        i:=i+FindMatch(Copy(p,i,length(p)))
      else if p[i]='[' then
        i:=i+FindMatch(Copy(p,i,length(P)))
      else inc(i);
    end;
  FindMatch:=i-1;
end;



{ tFormatLine.ReportError handles errors found when the  }
{ user keys inappropriate characters or presses ENTER    }
{ when input is incomplete.                              }

procedure tFormatLine.ReportError(kind:word);
var
  w   : word;
  Pic : pstring;
begin
  Pic:=newstr(Picture);
  case kind of
    flCharError :
      begin
        sound(220);
        delay(200);
        nosound;
      end;
    flFormatError :
      begin
        w:=MessageBox('Error in Formatted Input Line'+
          '                      '+
          '%s'+
          '                      '+
          '(Using Paradox Picture Format)',
          @Pic,mfError+mfOkButton);
      end;
    end;
  DisposeStr(Pic);
end;


{ tFormatLine.Valid overrides TView's Valid and reports  }
{ any format errors if the user accepts the input string }
{ before the entire format requirements have been met.   }

function tFormatLine.Valid(command: word):boolean;
var
  result:word;
begin
  result:=CheckPicture(Data^,Picture,CurPos);
  if (result and flFormatOK)=0 then
    begin
      ReportError(flFormatError);
      Select;
      DrawView;
      Valid:=false;
    end
  else Valid:=true;
end;


{ tFormatLine.CheckPicture is the function that inspects }
{ the input string passed as S against the Pic string    }
{ which holds the Paradox-form Picture.  If an error is  }
{ found the position of the error is placed in CPos.     }

function tFormatLine.CheckPicture(var s, Pic : string;
  var CPos : integer) : word;
var
  Resolved  : integer;
  TempIndex : integer;


{ Function CP is the heart of tFormatLine.  It           }
{ determines if the string, s passed to it fits the      }
{ requirements of the picture, Pic.  The number of       }
{ characters successful resolved is returned in the      }
{ parameter resolved. When groups or repetitions are     }
{ encountered CP will call itself recursively.           }

function CP(var s : string; Pic : string; var CPos :
  integer; var Resolved : integer) : word;
const
   CharMatchSet = ['#','?','&','@','!'];
var
  i          : integer;
  index      : integer;
  result     : word;
  commit     : boolean;
  Groupcount : integer;

{ Procedure Succeed resolves defaults and <Space>        }
{ default requests                                       }

  procedure Succeed;
  var
    t     : integer;
    found : boolean;
  begin
  if (s[i]=' ') and (Pic[index]<>' ') and
    (Pic[index]<>',') then
    begin
      t:=index;
      found:=false;
      while (t<=length(pic)) and not found do
        begin
        if not (Pic[t] in (CharMatchSet+
          ['*','[','{',',',']','}'])) then
          begin
            if pic[t]=';' then inc(t);
            s[i]:=Pic[t];
            found:=true;
          end;
          inc(t);
        end;
    end;
  if (i>length(s)) then
    while not (Pic[index] in
      (CharMatchSet+['*','[','{',',',']','}'])) and
      (index<=length(Pic)) and
      not(Pic[index-1] in ['}',',',']']) do
      begin
        if Pic[index]=';' then inc(index);
        s[i]:=Pic[index];
        if i>length(s) then
          begin
            CPos:=i;
            s[0]:=char(i);
          end;
        inc(i);
        inc(index);
      end;
  end;


{ Function AnyLeft returns true if their are no required }
{ characters left in the Picture string.                 }

  function AnyLeft : boolean;
  var TempIndex : integer;
  begin
    TempIndex:=index;
    while ((Pic[TempIndex]='[') or (Pic[TempIndex]='*'))
      and (TempIndex<=Length(Pic)) and
      (Pic[TempIndex]<>',') do
      begin
        if Pic[TempIndex]='[' then
          Tempindex:=Tempindex+FindMatch(Copy(Pic,index,
            Length(Pic)))
        else begin
          if not (Pic[TempIndex+1] in ['0'..'9']) then
            begin
              inc(TempIndex);
              if Pic[TempIndex] in ['{','['] then
                tempIndex:=TempIndex+
                  FindMatch(Copy(pic,index,length(pic)))
              else inc(TempIndex);
            end;
        end;
      end;
    AnyLeft:=(TempIndex<=length(Pic)) and
     (Pic[TempIndex]<>',');
  end;


{ Function CharMatch determines if the current character }
{ matches the corresponding character mask in the        }
{ Picture string. Alters the character if necessary.     }

  function CharMatch : word;
  var result : word;
  begin
    result:=flError;
    case Pic[index] of
      '#': if s[i] in ['0'..'9'] then result:=flCharOk;
      '?': if s[i] in ['A'..'Z','a'..'z'] then
        result:=flCharOk;
      '&': if s[i] in ['A'..'Z','a'..'z'] then
        begin
          result:=flCharOk;
          s[i]:=upcase(s[i]);
        end;
      '@': result:=flCharOk;
      '!':
        begin
         result:=flCharOk;
         s[i]:=upcase(s[i]);
        end;
      end;
    if result<>flError then commit:=true;
    CharMatch:=result;
  end;

{ Function Literal handles characters which are needed   }
{ by the picture by otherwise used as format specifiers. }
{ All such characters are preceded by the ';' in the     }
{ picture string.                                        }

  function Literal : word;
  var result : word;
  begin
    inc(index);
    if s[i]=Pic[index] then result:=flCharOk
    else result:=flError;
    if result<>flError then commit:=true;
    Literal:=result;
  end;


{ Function Group handles required and optional groups    }
{ in the picture string.  These are designated by the    }
(* "{","}" and "[","]" character pairs.                 *)

  function Group:word;
  var
    result: word;
    TempS: string;
    TempPic: string;
    TempCPos: integer;
    PicEnd: integer;
    TempIndex: integer;
    SwapIndex:integer;
    SwapPic : string;
  begin
    TempPic:=Copy(Pic,index,length(Pic));
    PicEnd:=FindMatch(TempPic);
    TempPic:=Copy(TempPic,2,PicEnd-1);
    TempS:=Copy(s,i,length(s));
    TempCPos:=1;

    result:=CP(TempS,TempPic,TempCPos,TempIndex);

    if result=flCharOK then inc(GroupCount);
    if (result=flFormatOK) and (groupcount>0) then
      dec(GroupCount);
    if result<>flError then result:=flCharOk;

    SwapIndex:=index;
    index:=TempIndex;
    SwapPic:=Pic;
    Pic:=TempPic;
    if not AnyLeft then result:=flCharOk;
    pic:=SwapPic;
    index:=SwapIndex;

    if i>1 then s:=copy(s,1,i-1)+TempS else s:=TempS;

    CPos:=Cpos+TempCPos-1;
    if Pic[index]='[' then
      begin
      if result<>flError then
         i:=i+TempCPos-1
      else dec(i);
      result:=flCharOK;
      end
    else i:=i+TempCPos-1;
    index:=index+PicEnd-1;
    Group:=result;
  end;


{ Function Repetition handles repeated that may be       }
{ repeated in the input string.  The picture string      }
{ indicates this possiblity with "*" character.          }

  function Repetition:word;
  var
    result:word;
    count:integer;
    TempPic:string;
    TempS:string;
    TempCPos:integer;
    TempIndex:integer;
    SwapIndex:integer;
    SwapPic:string;
    PicEnd:integer;
    commit:boolean;

    procedure MakeCount;
    var nstr:string;
        code:integer;
    begin
      if Pic[index] in ['0'..'9'] then
        begin
          nstr:='';
          repeat
            nstr:=nstr+Pic[index];
            inc(index);
          until not(Pic[index] in ['0'..'9']);
          val(nstr,count,code);
        end
      else count:=512;
    end;

    procedure MakePic;
    begin
    if Pic[index] in ['{','['] then
      begin
        TempPic:=copy(Pic,index,length(Pic));
        PicEnd:=FindMatch(TempPic);
        TempPic:=Copy(TempPic,2,PicEnd-1);
      end
    else
      begin
        if Pic[index]<>';' then
          begin
            TempPic:=''+Pic[index];
            PicEnd:=3;
            if index=1 then pic:='{'+pic[index]+'}'+
              copy(pic,index+1,length(pic))
            else pic:=copy(pic,1,index-1)+
              '{'+pic[index]+'}'+
              copy(pic,index+1,length(pic));
          end
        else
          begin
            TempPic:=Pic[index]+Pic[index+1];
            PicEnd:=4;
            if index=1 then pic:='{'+pic[index]+
              pic[index+1]+'}'+
              copy(pic,index+1,length(pic))
            else pic:=copy(pic,1,index-1)+'{'+pic[index]+
              pic[index+1]+'}'+copy(pic,index+1,
              length(pic));
          end;
        end;
    end;

  begin
    inc(index);
    MakeCount;
    MakePic;
    result:=flCharOk;
    while (count<>0) and (result<>flError) and
      (i<=length(s)) do
      begin
        commit:=false;
        TempS:=Copy(s,i,length(s));
        TempCPos:=1;

        result:=CP(TempS,TempPic,TempCPos,TempIndex);

        if result=flCharOK then inc(GroupCount);
        if (result=flFormatOK) and
           (groupcount > 0)  then dec(GroupCount);
        if result<>flError then result:=flCharOk;

        SwapIndex:=Index;
        Index:=TempIndex;
        SwapPic:=Pic;
        Pic:=TempPic;
        if (not AnyLeft) then result:=flCharOk;
        Pic:=SwapPic;
        index:=SwapIndex;
        if i>1 then s:=copy(s,1,i-1)+TempS else s:=TempS;
        Cpos:=Cpos+TempCpos-1;
        if (count>255) then
           begin
           if result<>flError then
              begin
              i:=i+TempCpos-1;
              if not commit then commit:=true;
              result:=flCharOk;
              end
           else dec(i);
           end
        else i:=i+TempCPos-1;
        inc(i);
        dec(count);
      end;
    dec(i);
    index:=index+PicEnd-1;
    if result=flError then
       if (count>255) and not commit
         then result:=flCharOk;
    repetition:=result;
  end;

  begin{ of function CP}
    i:=1;
    index:=1;
    result:=flCharOk;
    commit:=false;
    Groupcount:=0;
    while (i<=length(s)) and (result<>flError) do
      begin
        if index>length(Pic) then result:=flError else
          begin
            if s[i]=' ' then Succeed;
            if Pic[index] in CharMatchSet then
              result:=CharMatch else
            if Pic[index]=';' then
              result:=Literal else
            if (Pic[index]='{') or (Pic[index]='[') then
              result:=Group else
            if Pic[index]='*' then
              result:=Repetition else
            if Pic[index] in [',','}',']'] then
              result:=flError else
            if Pic[index]=s[i] then
              begin
                result:=flCharOk;
                commit:=true;
              end
            else result:=flError;
            if (result = flError) and not commit then
              begin
                TempIndex:=Index;
                while (TempIndex<=length(Pic)) and
                  ((Pic[TempIndex]<>',') and
                  (Pic[TempIndex-1]<>';'))  do
                  begin
                   if (Pic[TempIndex]='{') or
                     (Pic[TempIndex]=']')
                   then Index:=FindMatch( Copy( Pic,
                     TempIndex,length(Pic)))+TempIndex-1;
                   inc(TempIndex);
                 end;
               if Pic[TempIndex]=',' then
                 begin
                   if Pic[TempIndex-1]<>';' then
                     begin
                       result:=flCharOk;
                       index:=TempIndex;
                       inc(index);
                     end;
                 end;
              end
            else if result<>flError then
              begin
                inc(i);
                inc(index);
                Succeed;
              end;

          end;
      end;
    Resolved:=index;

    if (result=flCharOk) and
      (GroupCount=0) and
      (not AnyLeft or ((Pic[index-1]=',') and
      (Pic[index-2]<>';')))
    then result:=flFormatOk;

    CPos:=i-1;
    CP:=result;
  end;

begin{ of function CheckPicture}
Resolved:=1;
CheckPicture:=CP(s,Pic,CPos,Resolved);
end;

{ tFormatLine.Init simply sets up the inputline and then }
{ sets up the Picture string for use by CheckPicture.    }

constructor tFormatLine.Init(var Bounds: tRect;
  AMaxLen: integer; Pic : string);
begin
  tInputLine.Init(Bounds,AMaxLen);
  Picture:=Pic;
end;

{ tFormatLine.HandleEvent intercepts character key       }
{ presses and handles inserting these characters into    }
{ Data field.  Insertion only occures if a call to       }
{ tFormatLine.CheckPicture is successful else            }
{ tFormatLine.ReportError is called.  All other events   }
{ are passed on to tInputLine.HandleEvent.               }

procedure TFormatLine.HandleEvent(var Event: TEvent);
var TempData   : string;
    TempCurPos : integer;
    I          : integer;
begin
if State and sfSelected <> 0 then
   if Event.What=evKeyDown then
      if Event.CharCode in [' '..#255] then
         begin
         TempData:=Data^;
         if State and sfCursorIns<>0 then
            Delete(TempData,CurPos+1,1)
         else begin
              if SelStart<>SelEnd then
                 begin
                 Delete(TempData,SelStart+1
                   ,SelEnd-SelStart);
                 CurPos:=SelStart;
                 end;
              end;
         if Length(TempData)<MaxLen then
            begin
            inc(CurPos);
            insert(Event.CharCode,TempData,CurPos);
            if CheckPicture(TempData,Picture,CurPos)=flError then
               ReportError(flCharError)
            else Data^:=TempData;
            SelStart:=0;
            SelEnd:=0;
            if FirstPos> CurPos then FirstPos:=CurPos;
            I:=CurPos-Size.X+2;
            if FirstPos<I then FirstPos:=I;
            DrawView;
            ClearEvent(Event);
            end;
         end;
tInputLine.HandleEvent(Event);
end;


constructor tMoneyFormatLine.Init;
begin
tFormatLine.Init(Bounds,AMaxLen,'$#[#][#]*{;,###}.##');
end;

procedure tMoneyFormatLine.GetData;
var Figure : real absolute Rec;
    TempData : string;
    i : integer;
    code : integer;
begin
  TempData:=Data^;
  for i:=length(TempData) downto 1 do
      if TempData[i] in ['$',','] then
        Delete(TempData,i,1);
  val(TempData,Figure,code);
  if code<>0 then ReportError(flFormatError);
end;

procedure tMoneyFormatLine.SetData;
var Figure : real absolute Rec;
    TempData : string;
    i,decimal, count : integer;
begin
  str(Figure:0:2,TempData);
  i:=pos('.',TempData);
  count:=0;
  while (i<>1) do
    begin
    inc(count);
    dec(i);
    if count=3 then
      begin
      insert(',',TempData,i);
      count:=0;
      end;
    end;
  if TempData[1]=',' then delete(TempData,1,1);
  Data^:='$'+TempData;
end;

function tMoneyFormatLine.DataSize : word;
begin
DataSize:=sizeof(real);
end;

constructor tPhoneFormatLine.Init;
begin
tFormatLine.Init(Bounds,AMaxLen,
  '(###) ###-####,#*{#, ,-#}');
end;

procedure tPhoneFormatLine.GetData;
var i : integer;
    Default : string absolute Rec;
begin
  for i:=length(Data^) downto 1 do
    if Data^[i] in [' ','-','(',')'] then Delete(Data^,i,1);
Default:=Data^;
end;

procedure tPhoneFormatLine.SetData;
var i:integer;
    Default : string absolute Rec;
begin
if length(Default)=10 then
  Default:='('+Copy(Default,1,3)+') '+Copy(Default,4,6)+
    '-'+Copy(Default,7,10);
Data^:=Default;
end;

constructor tRealFormatLine.Init;
begin
tFormatLine.Init(Bounds, AMaxLen,
  '[+,-]#*#[[.*#][{E,e}[+,-]#[#][#][#]]]');
end;

procedure tRealFormatLine.GetData;
var Result : real absolute Rec;
    code : integer;
begin
  val(Data^, Result, code);
  if code<>0 then ReportError(flFormatError);
end;

procedure tRealFormatLine.SetData;
var Default : real absolute Rec;
begin
  if Default>1E6 then
    str(Default,Data^)
  else str(Default:0:8,Data^);
end;

function tRealFormatLine.DataSize : word;
begin
DataSize:=sizeof(Real);
end;

constructor tIntegerFormatLine.Init;
begin
tFormatLine.Init(Bounds,AMaxLen,'[+,-]#*#');
end;

procedure tIntegerFormatLine.SetData;
var Default : integer absolute Rec;
begin
str(Default,Data^);
end;

procedure tIntegerFormatLine.GetData;
var Result : integer absolute Rec;
    code : integer;
begin
val(Data^,Result,code);
if code<>0 then ReportError(flFormatError);
end;

function tIntegerFormatLine.DataSize : word;
begin
DataSize:=sizeof(integer);
end;

constructor tNameFormatLine.Init;
begin
tFormatLine.Init(Bounds,AMaxLen,'*[![*?][@][ ]]');
end;

constructor tZipFormatLine.Init;
begin
tFormatLine.Init(Bounds,AMaxLen,'#####[-####],&#& #&#');
end;

end.

