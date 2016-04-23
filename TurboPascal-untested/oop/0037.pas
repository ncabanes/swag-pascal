UNIT PARSER;

{  recursive descent expression Parser.

   Based on the parser by Herbert Shildt as shown in
   Advanced C
   Osborn McGraw-Hill

   Ported to Pascal by

   (C) M.Fiel 1993 Vienna - Austria
   CompuServe ID : 100041,2007

   for further infos refer to this book.

   Use freely if you find it useful.

}
{$R+}

INTERFACE

  USES
    Objects,ParTools;

  CONST
    MaxParserVars = 100; { Max Count of Variables fo PVarParser }

  TYPE

{ PMathParser evaluates expressions like (-(10*5)/27) * 128  no variables }

    PMathParser = ^TMathParser;
    TMathParser = object(TObject)

      ToParse   : PString;    { the string to parse }
      ExprPos   : Integer;    { aktuall position in the string }
      TokenType : Integer;    { Variable delimiter...}
      Token     : String;     { the aktuell token }

      Result    : Real;       { the result of the expression }

      constructor Init;
      destructor  Done; virtual;

      function    Evaluate(Expression:String) : Real;
      { expression is the string which is to be evaluated
      calls function Parse}

      function    GetNextToken : Boolean; virtual;
      function    GetPart : String; virtual;
      function    isDelimiter : Boolean; virtual;

      function    AddSub : Boolean; virtual;
      { checks for Addition or Substr and calls MulDiv }
      function    MulDiv : Boolean; virtual;
      { checks for Multiplikation or Div. and calls Unary }
      function    Unary  : Boolean; virtual;
      { checks for Unary (+/-) and calls Parant }
      function    Parant : Boolean; virtual;
      { checks for paratheses and if necessary calls Parse --> go recursive }

      function    Primitive : Boolean; virtual;
      { evaluates constatn value }

      function    Parse : Boolean; virtual;
      { parse not necessary in this version (call addsub instead) but is
        needed in descents }

    end;

{ VarParser can Handle Variables and epressions like
  A=10.78
  B=20.45
  A*(B-10)+5
  .
  .
  .
}
    PVarParser = ^TVarParser;
    TVarParser = object(TMathParser)

      Vars : PParserVarColl;{Container of Variables defined in Unit ParTools}

      constructor Init;
      destructor  Done; virtual;

      function    Primitive : Boolean; virtual;
      function    Parse : Boolean; virtual;
      { Calls Checckassign }

      function    CheckAssign : Boolean; virtual;
      { checks assignments : ex. A=12 }
      procedure   ClearVars; virtual;
      { clears all variables }

    end;

IMPLEMENTATION

  CONST                { defines wich type a token is }
    tError     = 0;
    tVariable  = 1;
    tDelimiter = 2;
    tNumber    = 3;
    tConstValue = 4;

  constructor TMathParser.Init;
    begin
      if not inherited Init then FAIL;
      ExprPos:=0;
      Token:='';
    end;

  destructor TMathParser.Done;
    begin
      if (ToParse<>NIL) then DisposeStr(ToParse);
      inherited Done;
    end;

  function TMathParser.Evaluate(Expression:String) : Real;

    begin

      if (ToParse<>NIL) then DisposeStr(ToParse);
      ToParse:=NewStr(Expression);

      result:=0.00;
      ExprPos:=1;

      if GetNextToken then Parse;

      Evaluate:=result;

    end;

  function TMathParser.Parse : Boolean;
    begin
      Parse:=AddSub;
    end;

  function TMathParser.GetNextToken : Boolean;
    begin

      GetNextToken:=True;

      while ToParse^[ExprPos] = ' ' do inc(ExprPos);

      if (isDelimiter) then begin

        TokenType := tDelimiter;
        Token:=ToParse^[ExprPos];
        inc(ExprPos);

      end else begin

        case ToParse^[ExprPos] of

          '0'..'9':begin
            TokenType := tNumber;
            Token :=GetPart;
          end;

          'A'..'Z','a'..'z' : begin
            TokenType := tVariable;
            Token:=GetPart;
          end;

          else begin
            TokenType := tError;
            GetNextToken:=False;
          end;

        end;

      end;

    end;

  function TMathParser.GetPart : String;
    var
      RetVal : String;
    begin

      RetVal:='';

      while not(isDelimiter) do begin

        RetVal:=RetVal+ToParse^[ExprPos];

        if ExprPos<length(ToParse^) then
          inc(ExprPos)
        else begin
          RetVal:=Trim(RetVal);
          GetPart:=RetVal;
          Exit;
        end;

      end;

      RetVal:=Trim(RetVal);

      GetPart:=RetVal;

    end;

  function TMathParser.isDelimiter : Boolean;
    begin
      isDelimiter:=(Pos(ToParse^[ExprPos],'+-*/()=%')<>0);
    end;

  function TMathParser.AddSub : Boolean;
    var
      Hold : Real;
      OldToken : String;
    begin

      AddSub:=True;

      if (MulDiv) then begin

        while (Pos(Token,'+-') > 0) do begin

          OldToken:=Token;
          GetNextToken;

          Hold:=Result;

          if (MulDiv) then begin
            if OldToken='+' then Result:=(Hold+Result) else Result:=(Hold-Result);
          end else
            AddSub:=False;

        end;

      end else
        AddSub:=False;

    end;

  function TMathParser.MulDiv : Boolean;
    var
      Hold : Real;
      PerHelp : Real;
      OldToken : String;
    begin

      MulDiv:=True;

      if (Unary) then begin

        while (Pos(Token,'*/%') > 0) do begin

          OldToken:=Token;
          GetNextToken;
          Hold:=Result;

          if (Unary) then begin

            case OldToken[1] of
              '*':Result:=Hold*Result;

              '/':begin
                if (Result<> 0) then
                  Result:=Hold/Result
                else begin
                  OwnError('Division by zero');
                  MulDiv:=False;
                end;
              end;

              '%':begin
                PerHelp:=Hold/Result;
                Result:=Hold-(PerHelp*Result);
              end;

            end;

          end else
            MulDiv:=False;

        end;

      end else
        MulDiv:=False;

    end;

  function TMathParser.Unary : Boolean;
    var
      UnaryHelp:Boolean;
      OldToken : String;
    begin

      Unary:=True;

      UnaryHelp:=False;

      if (Pos(Token,'-+') >0) then begin
        OldToken:=Token;
        UnaryHelp:=True;
        GetNextToken;
      end;

      if (Parant) then begin
        if (UnaryHelp and (OldToken = '-')) then Result:=-(Result);
      end else
        Unary:=False;

    end;

  function TMathParser.Parant : Boolean;
    begin

      Parant:=True;

      if ((TokenType = tDelimiter) and (Token = '(')) then begin

        GetNextToken;

        if (Parse) then begin

          if (Token <> ')') then begin
            OwnError('unbalanced parantheses');
            Parant:=False;
          end;

        end else
          Parant:=False;

        GetNextToken;

      end else

        Parant:=Primitive;

    end;

  function TMathParser.Primitive : Boolean;
    var
      e:Integer;
    begin

      Primitive:=True;

      if (TokenType = tNumber) then begin

        val(Token,Result,e);

        if (e<>0) then begin
          OwnError('syntax error');
          Primitive:=False;
        end;

        GetNextToken;

      end;

    end;


{****************************************************************************}
{                          TVARPARSER                                        }
{****************************************************************************}

  constructor TVarParser.Init;
    begin
      if not inherited Init then FAIL;
      Vars:=New(PParserVarColl,Init(MaxParserVars,0));
    end;

  destructor TVarParser.Done;
    begin
      Dispose(Vars,Done);
      inherited Done;
    end;

  function TVarParser.Primitive : Boolean;
    begin

      Primitive:=True;

      if (inherited Primitive) then begin

        if (TokenType = tVariable) then begin
          result:=Vars^.GetVar(Token);
          GetNextToken;
        end;

      end else
        Primitive:=False;

    end;

 function TVarParser.Parse : Boolean;
   begin
     Parse:=CheckAssign;
   end;

 function TVarParser.CheckAssign : Boolean;
   var
     OldToken : String;
     OldType  : Integer;
   begin

     if (TokenType = tVariable) then begin

       OldToken :=Token;
       OldType := TokenType;

       GetNextToken;

       if (Token = '=') then begin

         GetNextToken;

         CheckAssign:=AddSub;
         Vars^.SetValue(OLdToken,result);

         Exit;

       end else begin

         dec(ExprPos,length(Token));
         Token:=OldToken;
         TokenType:=OldType;

       end;

     end;

     CheckAssign := AddSub;

   end;

 procedure TVarParser.ClearVars;
   begin
     Vars^.FreeAll;
   end;

END.

{ -------------------------------- CUT HERE -----------------------}

UNIT PARTOOLS;

{
   (C) M.Fiel 1993 Vienna - Austria
   CompuServe ID : 100041,2007

   Use freely if you find it useful.
}

INTERFACE

  USES
    Objects;

  TYPE

    {Object to hold variable data for the TVarParser defined in Unit Parser}

    PParserVar = ^TParserVar;
    TParserVar = object(TObject)

      Name : PString;
      Value : Real;

      constructor Init(aName:String;aValue:Real);
      destructor  Done; virtual;

      function    GetName : String; virtual;
      function    GetValue : Real; virtual;
      procedure   SetValue(NewValue : Real); virtual;

    end;

    {Container to hold TParserVar objects }

    PParserVarColl = ^TParserVarColl;
    TParserVarColl = object(TCollection)

      procedure FreeItem(Item:Pointer); virtual;
      function  GetVarIndex(Name:String) : Integer; virtual;
      function  GetVar(Name:String) : Real; virtual;
      procedure SetValue(Name:String;NewValue:Real); virtual;

    end;

   PStrColl = ^TStrColl;  { Container for Strings }
   TStrColl = object(TCollection)
     procedure  FreeItem(Item: Pointer); virtual;
   end;

  procedure OwnError(S:String); { Shows a MsgBox with S }
  function Trim(Line:String) : String; { Pads a String from End }
  function MkStr(Len,Val:Byte): String;
  { makes a String of length len and fills it with val }

IMPLEMENTATION

  USES
    MsgBox;

  constructor TParserVar.Init(aName:String;aValue:Real);
    begin
      inherited Init;
      Name:=NewStr(aName);
      Value:=aValue;
    end;

  destructor TParserVar.Done;
    begin
      DisposeStr(Name);
      inherited Done;
    end;

  function TParserVar.GetName : String;
    begin
      if Name<>NIL then GetName:=Name^ else GetName:='';
    end;

  function TParserVar.GetValue : Real;
    begin
      GetValue:=Value;
    end;

  procedure TParserVar.SetValue(NewValue : Real);
    begin
      Value:=NewValue;
    end;

  procedure TParserVarColl.FreeItem(Item:Pointer);
    begin
      if (Item <> NIL) then Dispose(PParserVar(Item),Done);
    end;


  function TParserVarColl.GetVar(Name:String) : Real;
    var
      Index:Integer;
    begin
      Index:=GetVarIndex(Name);

      if (Index<>-1) then
        GetVar:=PParserVar(At(Index))^.GetValue
      else begin
        OwnError('invalid variable');
        GetVar:=0;
      end;

    end;

  function TParserVarColl.GetVarIndex(Name:String) : Integer;

    function isName(P:PParserVar):Boolean;
      begin
        isName:=(P^.GetName = Name);
      end;

    begin
      GetVarIndex:=IndexOf(FirstThat(@isName));
    end;

  procedure TParserVarColl.SetValue(Name:String;NewValue:Real);
    var
      Index : Integer;

    begin

      Index:=GetVarIndex(Name);

      if (Index <> -1) then
        PParserVar(At(Index))^.SetValue(NewValue)
      else
        Insert(New(PParserVar,Init(Name,NewValue)));

    end;

  procedure OwnError(S:String);
    begin
       MessageBox(S,nil,mfError + mfOkButton);
    end;

  function Trim(Line:String) : String;
    var
      Len: BYTE ABSOLUTE Line;
    begin
      while (Len > 0) AND (Line[Len] = ' ') DO Dec(Len);
      Trim := Line;
    end ;

  function MkStr (Len,Val:Byte): String;
    var
      S:String;
    begin
       S[0]:=chr(Len);
       fillchar (S[1],Len,Val);
       MkStr:=s;
    end;

 procedure TStrColl.FreeItem(Item: Pointer);
   begin
     if Item<>Nil then DisposeStr(Item);
   end;

END.

{ -------------------------------- DEMO PROGRAM -----------------------}

PROGRAM PARDEMO;

{
   (C) M.Fiel 1993 Vienna - Austria
   CompuServe ID : 100041,2007

   Use freely if you find it useful.

   Demonstration of a Recursive descent Parser and a new Screensaver
   object.

   Infos watch the units and the parser.txt file

   if problems or comments leave me a message or mail me.

}



USES
  Objects,Drivers,Menus,Views,App,Dialogs,ScrSaver,TVParser;

  { NOTE  -  SCRSAVER UNIT CAN BE FOUND IN SWAG DISTRIBUTION ALSO !!}
  {          AND WILL BE NEED BY THIS MODULE                        }

CONST
  cmParser = 1001;
  cmScreenSave = 1002;

TYPE

   PApp = ^Tapp;
   TApp = object(TApplication)

      ScreenSaver : PScreenSaver; { defined in unit ScrSav }
      {add the screensaver object to the application}

      constructor Init;

      procedure   HandleEvent (var event:Tevent); virtual;
      procedure   InitMenuBar; virtual;
      procedure   InitStatusLine; virtual;
      procedure   ShowParser;
      procedure   GetEvent(var Event: TEvent); virtual;

   end;

  VAR
    XApplic: TApp;

   constructor TApp.Init;
     begin
       if not inherited Init then FAIL;

       ScreenSaver:=New(PScreenSaver,Init('I''m the Screensaver',180));
       Insert(ScreenSaver);

     end;

  procedure TApp.GetEvent(var Event: TEvent);
    begin
      inherited GetEvent(Event);
      ScreenSaver^.GetEvent(Event);  { don't forget this line }
    end;

   procedure Tapp.InitStatusLine;

     var
       R: TRect;
     begin

       GetExtent(r);
       R.A.Y := R.B.Y - 1;

       StatusLine:=New(PStatusLine, Init(R,

          NewStatusDef (0, 1000,
             newstatuskey ('~F10~-Menu',kbF10,cmmenu,
             newstatuskey ('~Alt-X~ Exit', kbaltx, cmQuit,
          NIL)),

       NIL)));

     end;

   procedure Tapp.InitMenuBar;

     var
       R : TRect;
     begin

        GetExtent(R);
        R.B.Y := R.A.Y + 1;

        MenuBar:=New(PMenuBar,Init(R,NewMenu(

           NewSubMenu('~≡~ ',hcNoContext,NewMenu(
             NewItem('~Alt-X~ Exit','',kbAltX,cmQuit,hcNoContext,
           NIL)),

           NewItem('~P~arser','',0,cmParser,hcNoContext,
           NewItem('~S~creensave','',0,cmScreenSave,hcNoContext,

        Nil))))));
    end;

  procedure TApp.ShowParser;
    var
      Parser:PVisionParser;
    begin
      Parser:=New(PVisionParser,Init);
      if Parser<>NIL then begin
        DeskTop^.ExecView(Parser);
        Dispose(Parser,Done);
      end;
    end;


  procedure Tapp.HandleEvent (var Event:TEvent);
    begin

      case Event.What of

        evCommand : begin

          case (Event.Command) of

            cmParser : ShowParser;
            cmScreenSave : begin
              DoneVideo;
              ScreenSaver^.Activ:=True;
            end;
            else inherited HandleEvent (Event);

          end;

        end;

        else inherited HandleEvent (Event);

      end;

    end;


begin

   XApplic.Init;
   XApplic.Run;
   XApplic.Done;

end.
