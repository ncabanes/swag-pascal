(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0087.PAS
  Description: Fuzzy logic unit (German)
  Author: WIM VAN DER VEGT
  Date: 02-03-94  10:57
*)

{
---------------------------------------------------------------------------
KW>WV>Got some german pascal code on this subject. It seems to implement a
  >  >.... (Bit large to send if nobody's interested).

KW>Can you extract the specifically fuzzy logic parts?
  >---
No (didnt know where to look, how doesfuzzy pascal look :-) ) so here's
the complete program taken from a german magazine
}

UNIT Fuzzy;
INTERFACE

Uses Graph,Crt,Dos;

CONST
  Infinity  = 1.7e38;
  NoRules   = NIL;
  ValueCol  = LightMagenta;

TYPE
  NameStr       = String[20];
  (* verschiedene Operatortypen *)
  Inference     = FUNCTION(Set1,Set2,Set3:Real):real;

  FuzzySetList  = ^FuzzySet;
  FuzzyVarList  = ^FuzzyVar;
  FuzzyRuleList = ^FuzzyRule;

  FuzzySet      = Object
                    SetName : NameStr;       (* Mengenbenzeichner    *)
                    StartAt,                 (* Startwert            *)
                    HighAt,                  (* Maximum bei ...      *)
                    EndAt   : Real;          (* Endwert              *)
                    Next    : FuzzySetList;
                    Color   : Byte;
                    MemberShip : Real;       (* aktueller Wert der   *)
                                             (* Zugehörigkeit        *)
                    Rules   : FuzzyRuleList; (* Regelliste für diese *)
                                             (* unscharfe Menge      *)
                    Constructor Init( InitName : NameStr;
                                      InitStart, InitHigh,
                                      InitEnd  : Real;
                                      InitColor: Byte);
                    PROCEDURE Append( InitName : NameStr;
                                      InitStart, InitHigh,
                                      InitEnd  : Real;
                                      InitColor: Byte);
                    FUNCTION  GetMemberShip(LingVal : Real):Real;
                    PROCEDURE DefineRule( InfType : Inference;
                                          Var1    : FuzzyVarList;
                                          SetName1: NameStr;
                                          Var2    : FuzzyVarList;
                                          SetName2: NameStr);
                  END;

  FuzzyVar        = Object
                    VarName   : NameStr;       (* Variablenname        *)
                    PosX,PosY : WORD;          (* Bildschirmkoordinaten*)
                    StartValue,                (* Anfang und Ende des  *)
                    EndValue,                  (* Koordinatensystems   *)
                    Scale     : Real;          (* Maßstabsfaktor       *)
                    UnitStr   : NameStr;       (* Einheit, z.B. °C     *)
                    CurrentVal: Real;          (* aktueller Wert       *)
                    FuzzySets : FuzzySetList;  (* Liste der unscharfen *)
                                               (* Mengen               *)
                    Result,BackGround :
                       ARRAY[1..5] OF PointType;
                    Constructor Init( InitName    : NameStr;
                                      InitX,InitY : WORD;
                                      Sections    : Byte;
                                      InitStart,InitEnd,
                                      InitValue   : Real;
                                      InitUnit    : NameStr);
                    PROCEDURE  CoordSystem(Sections : Byte);
                    FUNCTION   RealToCoord(r:Real):WORD;
                    PROCEDURE  DisplaySets;
                    PROCEDURE  DisplayValue(TextColor:WORD);
                    PROCEDURE  DisplayResultSets;
                    PROCEDURE  Change(Diff : Real);
                    FUNCTION   GetMemberShipOf(Name : NameStr):Real;
                    PROCEDURE  Infer;
                    PROCEDURE  DeFuzzy;
                    PROCEDURE  DefineSet( InitName : NameStr;
                                          InitStart, InitHigh,
                                          InitEnd  : Real;
                                          InitColor: Byte);
                    PROCEDURE  DefineRule(SetName  : NameStr;
                                          InfType  : Inference;
                                          Var1     : FuzzyVarList;
                                          SetName1 : NameStr;
                                          Var2     : FuzzyVarList;
                                          SetName2 : NameStr);
                  END;

  FuzzyRule       = Object
                    Inf_Type   : Inference;       (* Operatortyp       *)
                    Var1, Var2 : FuzzyVarList;    (* Eingangsvariablen *)
                    SetName1, SetName2 : NameStr; (* Eingangsmengen    *)
                    Next       : FuzzyRuleList;
                    Constructor Init( InitInf    : Inference;
                                      InitVar1   : FuzzyVarList;
                                      InitName1  : NameStr;
                                      InitVar2   : FuzzyVarList;
                                      InitName2  : NameStr);
                    PROCEDURE Append( InitInf    : Inference;
                                      InitVar1   : FuzzyVarList;
                                      InitName1  : NameStr;
                                      InitVar2   : FuzzyVarList;
                                      InitName2  : NameStr);
                    FUNCTION Infer(HomeSetValue:Real):Real;
                  END;

Procedure Buzz;
procedure error(message : string);

function Max( A, B: Real ): Real;
function Min( A, B: Real ): Real;

FUNCTION AND_MaxMin(Set1,Set2,Set3:Real):Real;
FUNCTION OR_MaxMax(Set1,Set2,Set3:Real):Real;

VAR
  DisplayOn : BOOLEAN; (* Anzeige der unscharfen Mengen ein/aus *)
  Regs : Registers;
  ResultCol : WORD;

Implementation

CONST OffSet = 20;

VAR   Buffer : String;

PROCEDURE Buzz;
BEGIN sound(30); Delay(100); NoSound; END;

procedure error(message : string);
begin
  CloseGraph; writeln(message); halt
end;

function Max( A, B: Real ): Real;
begin
  if A < B then Max := B else Max := A;
end;

function Min( A, B: Real ): Real;
begin
  if A > B then Min := B else Min := A;
end;

(* MaxMin-Operator für UND *)
FUNCTION AND_MaxMin(Set1,Set2,Set3:Real):Real;
BEGIN
  AND_MaxMin:=Max(Set1,Min(Set2,Set3))
END;

(* MaxMax-Operator für ODER *)
FUNCTION OR_MaxMax(Set1,Set2,Set3:Real):Real;
BEGIN
  OR_MaxMax:=Max(Set1,Max(Set2,Set3))
END;

CONSTRUCTOR FuzzySet.Init;

BEGIN
  SetName := InitName;
  StartAt := InitStart;
  HighAt  := InitHigh;
  EndAt   := InitEnd;
  Color   := InitColor;
  Next    := NIL;
  Rules:= NoRules;
  MemberShip := 0;
END;

PROCEDURE FuzzySet.Append;
BEGIN
  IF Next=NIL
  THEN New(Next,Init(InitName,InitStart,InitHigh,InitEnd,InitColor))
  ELSE Next^.Append(InitName,InitStart,InitHigh,InitEnd,InitColor)
END;

FUNCTION FuzzySet.GetMemberShip;
BEGIN
  IF (LingVal<=StartAt) THEN GetMemberShip:=0
  ELSE IF (LingVal>=EndAt) THEN GetMemberShip:=0
  ELSE
  BEGIN
    IF ((StartAt=-Infinity) AND (LingVal<=HighAt))
    OR ((EndAt=Infinity) AND (LingVal>=HighAt)) THEN GetMemberShip:=1
    ELSE IF (LingVal<=HighAt)
         THEN GetMemberShip:=(LingVal-StartAt)/(HighAt-StartAt)
    ELSE GetMemberShip:=1-(LingVal-HighAt)/(EndAt-HighAt)
  END
END;

PROCEDURE FuzzySet.DefineRule;
BEGIN
  IF Rules=NoRules THEN
     Rules:= new(FuzzyRuleList,
             Init(InfType,Var1,SetName1,Var2,SetName2))
  ELSE Rules^.Append(InfType,Var1,SetName1,Var2,SetName2)
END;

CONSTRUCTOR FuzzyVar.Init;
BEGIN
  VarName:=InitName;
  PosX:=InitX;
  PosY:=InitY;
  StartValue:=InitStart;
  EndValue  :=InitEnd;
  Scale     :=210/(EndValue-StartValue);
  UnitStr   :=InitUnit;
  CurrentVal:=InitValue;
  CoordSystem(Sections);
  FuzzySets      :=NIL;
  BackGround[1].x:=PosX+1;   BackGround[1].y:=PosY+100;
  BackGround[2].x:=PosX+1;   BackGround[2].y:=PosY+20;
  BackGround[3].x:=PosX+250; BackGround[3].y:=PosY+20;
  BackGround[4].x:=PosX+250; BackGround[4].y:=PosY+100;
  BackGround[5]:=BackGround[1];
END;

FUNCTION FuzzyVar.RealToCoord(r:Real):WORD;
BEGIN
  RealToCoord:=PosX+OffSet+Round((r-StartValue)*Scale);
END;

PROCEDURE FuzzyVar.CoordSystem(Sections: BYTE);
(* zeichnet ein Koordinatensystem            *)
(* PosX, PosY bestimmen die linke obere Ecke *)
VAR N         : Byte;
    MarkerX   : WORD;
    Increment : Real;
BEGIN
  SetColor(White);
  SetTextJustify(CenterText,CenterText);
  Line( PosX, PosY, PosX, PosY+103 );
  Line( PosX-3, PosY+100, PosX+250, PosY+100 );
  Line( PosX, PosY+20, PosX-3, PosY+20 );
  OutTextXY( PosX-15, PosY+20,  '1' );
  OutTextXY( PosX-15, PosY+100, '0' );
  Increment :=(EndValue-StartValue)/(Sections-1);
  for N := 0 to Sections-1 do
  begin
    MarkerX:=RealToCoord(StartValue+N*Increment);
    Line(MarkerX,PosY+101,MarkerX,PosY+103);
    Str(Round(StartValue + N * Increment), Buffer );
    OutTextXY(MarkerX, PosY+113, Buffer );
  end;
  OutTextXY( PosX + 270, PosY + 113, '['+UnitStr+']');
  SetColor(Red);
  SetTextJustify(LeftText,CenterText);
  OutTextXY( PosX + 20, PosY + 140,VarName+' = ');
  OutTextXY( PosX + 200,PosY + 140,UnitStr);
END;

PROCEDURE FuzzyVar.DisplayValue;

BEGIN
  SetWriteMode(XORPut);
  SetColor(ValueCol);
  IF (CurrentVal>=StartValue) AND (CurrentVal<=EndValue)
  THEN Line(RealToCoord(CurrentVal),PosY+20,
       RealToCoord(CurrentVal),PosY+100);
  SetColor(TextColor);
  SetTextJustify(RightText,CenterText);
  Str(CurrentVal : 7 : 2, Buffer );
  OutTextXY( PosX+190, PosY + 140 , Buffer );
END;

PROCEDURE FuzzyVar.Change;
BEGIN
  IF (CurrentVal+Diff>=StartValue) AND (CurrentVal+Diff<=EndValue)
  THEN
  BEGIN
    DisplayValue(0);
    CurrentVal:=CurrentVal+Diff;
    DisplayValue(ValueCol);
  END
  ELSE (* Bereichsgrenzen überschritten *)
  Buzz;
END;

PROCEDURE FuzzyVar.DisplaySets;
(* zeigt die unscharfen Mengen einer Variablen an *)
VAR SetPtr : FuzzySetList;
BEGIN
  SetPtr:=FuzzySets;
  WHILE SetPtr<>NIL DO WITH SetPtr^ DO
  BEGIN
    SetColor(Color);
    IF StartAt=-Infinity THEN SetTextJustify(RightText,CenterText)
    ELSE IF EndAt=Infinity THEN SetTextJustify(LeftText,CenterText)
    ELSE SetTextJustify(CenterText,CenterText);
    OutTextXY(RealToCoord(HighAt),PosY+10,SetName);
    IF StartAt=-Infinity
    THEN Line(PosX,PosY+20,RealToCoord(HighAt),PosY+20)
    ELSE Line( RealToCoord(StartAt),PosY+100,
               RealToCoord(HighAt),PosY+20);
    IF EndAt=Infinity
    THEN Line(RealToCoord(HighAt),PosY+20,PosX+250,PosY+20)
    ELSE Line(RealToCoord(HighAt),PosY+20,RealToCoord(EndAt),PosY+100);
    SetPtr:=Next
  END
END;

FUNCTION FuzzyVar.GetMemberShipOf;
VAR SetPtr : FuzzySetList;
BEGIN
  SetPtr:=FuzzySets;
  WHILE (SetPtr<>NIL) AND (SetPtr^.SetName<>Name) DO SetPtr:=SetPtr^.Next;
  IF SetPtr=NIL THEN error( 'Menge '+Name+' ist in der Ling. Variablen '
                            +VarName+' nicht definiert!')
  ELSE GetMemberShipOf:=SetPtr^.GetMemberShip(CurrentVal)
END;

PROCEDURE  FuzzyVar.DisplayResultSets;
VAR SetPtr : FuzzySetList;
BEGIN
  SetWriteMode(CopyPut);
  SetColor(ResultCol);
  SetPtr:=FuzzySets;
  WHILE SetPtr<>NIL DO WITH SetPtr^ DO
  BEGIN
    IF MemberShip>0 THEN
    BEGIN
      IF StartAt<=StartValue THEN Result[1].x := RealToCoord(StartValue)
      ELSE Result[1].x := RealToCoord(StartAt);
      Result[1].y := PosY+99;
      Result[2].x := RealToCoord(HighAt);
      Result[2].y := PosY+99 - Round(MemberShip*79);
      IF EndAt>=EndValue THEN Result[3].x := RealToCoord(EndValue)
      ELSE Result[3].x:= RealToCoord(EndAt);
      Result[3].y := PosY+99;
      Result[4]   := Result[1];
      FillPoly( 4, Result )
    END;
    SetPtr:=next
  END
END;

PROCEDURE FuzzyVar.Infer; (* alle Regeln antriggern *)
VAR
  SetPtr : FuzzySetList;
  RulePtr: FuzzyRuleList;
BEGIN
  SetPtr:=FuzzySets;
  WHILE SetPtr<>NIL DO WITH SetPtr^ DO
  BEGIN
    RulePtr:=Rules;
    MemberShip:=0;
    WHILE RulePtr<>NIL DO
    BEGIN
      MemberShip:=RulePtr^.Infer(MemberShip);
      RulePtr:=RulePtr^.Next
    END;
    SetPtr:=Next
  END
END; (* FuzzyVar.Infer *)

PROCEDURE FuzzyVar.Defuzzy;
(* Bestimmung des Flächenschwerpunktes der unscharfen *)
(* Ergebnismenge durch Auszählen der Pixel            *)

(* Raster der Rechnergeschwindigkeit anpassen *)
(* größte Rechengenauigkeit bei Raster=1      *)
CONST Raster = 16;
VAR
  X,Y,XOffSet : WORD;
  Zaehler, Nenner: Real;
BEGIN
  DisplayValue(Black);
  SetFillStyle(SolidFill, Black);
  SetColor(Black);
  FillPoly(5, BackGround);
  SetFillStyle(SolidFill, ResultCol);
  IF DisplayOn
  THEN DisplaySets; (* verzerrt das Ergebnis auf Hercules *)
  DisplayResultSets;
  Zaehler :=0;
  Nenner :=0;
  XOffset :=PosX+20;
  for X := 0 TO 210 DIV Raster DO (* Flächenschwerpunkt bestimmen *)
   for Y := PosY + 20 to PosY + 100 do
   if GetPixel(Raster*X+XOffSet,Y) = ResultCol then
   begin
     Nenner:=Nenner+1;
     Zaehler:=Zaehler+Raster*X;
   end;
  IF Nenner=0 THEN CurrentVal:=0
  ELSE CurrentVal :=Zaehler/Nenner/Scale+StartValue;
  DisplayValue(ResultCol)
end;

PROCEDURE FuzzyVar.DefineRule;
VAR SetPtr : FuzzySetList;
BEGIN
  SetPtr:=FuzzySets;
  WHILE (SetPtr<>NIL) AND (SetPtr^.SetName<>SetName)
  DO SetPtr:=SetPtr^.Next;
  IF SetPtr=NIL THEN error( 'Menge '+SetName+' ist in der Ling. '+
                            'Variablen '+VarName+' nicht definiert!')
  ELSE SetPtr^.DefineRule(InfType,Var1,SetName1,Var2,SetName2)
END;

PROCEDURE FuzzyVar.DefineSet;
BEGIN
  IF FuzzySets = NIL
  THEN FuzzySets:= new(FuzzySetList,
                   Init(InitName,InitStart,InitHigh,InitEnd,InitColor))
  ELSE FuzzySets^.Append(InitName,InitStart,InitHigh,InitEnd,InitColor)
END;

CONSTRUCTOR FuzzyRule.Init;
BEGIN
  Inf_Type :=InitInf;
  Var1     :=InitVar1;
  Var2     :=InitVar2;
  SetName1 :=InitName1;
  SetName2 :=InitName2;
  Next     :=NIL
END;

PROCEDURE FuzzyRule.Append;
BEGIN
  IF Next=NIL
  THEN New(Next,Init(InitInf,InitVar1,InitName1,InitVar1,InitName2))
  ELSE Next^.Append(InitInf,InitVar1,InitName1,InitVar2,InitName2)
END;

FUNCTION FuzzyRule.Infer; (* einzelne Regel abarbeiten *)
BEGIN
  Infer:=Inf_Type(HomeSetValue, Var1^.GetMemberShipOf(SetName1),
                                Var2^.GetMemberShipOf(SetName2));
END;

BEGIN (* Fuzzy-Logic-Unit *)
  (* Test auf Herculeskarte wg. Farbe für Ergebnismengen *)
  Regs.ah:=15;
  Intr($10,Regs);
  IF Regs.AL=7 THEN (* Hercules-Karte *)
  BEGIN
    ResultCol :=Blue;
    DisplayOn :=FALSE; (* siehe Artikel c't 3/91 *)
  END
  ELSE (* EGA-/VGA-Karte *)
  BEGIN
    ResultCol :=LightGray;
    DisplayOn :=TRUE
  END
END.

{ --------------------------    DEMO PROGRAM   ------------------------ }
{             I HOPE THAT YOU CAN READ GERMAN !!                        }

program fuzzy_inf_demo; (* c't 3/91 / it / C.v.Altrock, RWTH Aachen *)
uses Graph, Crt, Fuzzy;
type InputType = (temp,press,valve);
var
  GraphDriver, GraphMode, RK : Integer;
  StepWidth     : Array[InputType] OF Real;
  i,Input       : InputType;
  Ch            : Char;
  FuzzyVars     : ARRAY[InputType] of FuzzyVarList;

PROCEDURE InitGrafix;
(* Grafikmodus initialisieren und Hilfetexte schreiben *)
BEGIN
  GraphDriver := Detect;
  InitGraph(GraphDriver,GraphMode,'\turbo\tp');
  SetTextJustify(CenterText,CenterText);
  OutTextXY( GetMaxX DIV 2, 10, 'Demonstration der MAX-PROD-'
             +'Inferenz (c''t 3/91 / C.v.Altrock, RWTH Aachen)');
  OutTextXY( 500, 50, 'Eingabe Temperatur: ['+Chr(24)+']' );
  OutTextXY( 500, 65, 'Eingabe Druck: ['+Chr(25)+']' );
  OutTextXY( 500, 80, 'Erhöhen: ['+Chr(26)+']' );
  OutTextXY( 500, 95, 'Vermindern: ['+Chr(27)+']' );
  OutTextXY( 500, 110, 'Schrittweite: [Bild'+Chr(24)+Chr(25)+']' );
  Rectangle(400,40,600,120);
END; (* InitGrafix *)

begin (* main *)
  InitGrafix;

  (* Definition der linguistischen Variablen "Temperatur" *)
  FuzzyVars[temp]:= new(FuzzyVarList,
                    Init('Temperatur',20,30,7,400,1000,650,'°C'));
  WITH FuzzyVars[temp]^ DO
  BEGIN
    (* Definition und Anzeige der Fuzzy Sets *)
    DefineSet('niedrig',-Infinity,500,650,Blue);
    DefineSet('mittel',500,650,800,LightGreen);
    DefineSet('hoch',650,800,950,Red);
    DefineSet('sehr_hoch',800,950,Infinity,Yellow);
    DisplaySets; DisplayValue(ValueCol);
  END;

  (* Definition der linguistischen Variablen "Druck" *)
  FuzzyVars[press]:= new(FuzzyVarList,
                     Init('Druck',20,210,4,38,41,40,'bar'));
  WITH FuzzyVars[press]^ DO
  BEGIN
    (* Definition und Anzeige der Fuzzy Sets *)
    DefineSet('unter_normal',-Infinity,39,40,Blue);
    DefineSet('normal',39,40,41,LightGreen);
    DefineSet('über_normal',40,41,Infinity,Red);
    DisplaySets; DisplayValue(ValueCol);
  END;

  (* Definition der linguistischen Variablen "Methanventil" *)
  FuzzyVars[valve]:= new(FuzzyVarList,
                     Init('Methanventil',340,170,7,0,12,0,'m3/h'));
  WITH FuzzyVars[valve]^ DO
  BEGIN
    (* Definition der Fuzzy Sets *)
    DefineSet('gedrosselt',-Infinity,0,4,Blue);
    DefineSet('halboffen',0,4,8,Green);
    DefineSet('mittel',4,8,12,LightGreen);
    DefineSet('offen',8,12,Infinity,Yellow);
    (* Definition der Inferenzregeln *)
    (* 1 IF Temperatur ist niedrig OR Druck ist unter_normal
         THEN Methanventil ist offen                         *)
    DefineRule('offen',OR_MaxMax, FuzzyVars[temp],'niedrig',
                                  FuzzyVars[press],'unter_normal');
    (* 2 IF Temperatur ist sehr_hoch OR Druck ist über_normal
         THEN Methanventil ist gedrosselt                    *)
    DefineRule('gedrosselt',OR_MaxMax, FuzzyVars[temp],'sehr_hoch',
                                       FuzzyVars[press],'über_normal');
    (* 3 IF Temperatur ist hoch AND Druck ist normal
         THEN Methanventil ist halboffen                     *)
    DefineRule('halboffen',AND_MaxMin, FuzzyVars[temp],'hoch',
                                       FuzzyVars[press],'normal');
    (* 4 IF Temperatur ist mittel AND Druck ist normal
         THEN Methanventil ist mittel                        *)
    DefineRule('mittel',AND_MaxMin, FuzzyVars[temp],'mittel',
                                       FuzzyVars[press],'normal');
    IF DisplayOn THEN DisplaySets;
    DisplayValue(ValueCol);
    Infer;
    Defuzzy;
  END;

  SetColor( Red );
  OutTextXY( 540, 330, '(Resultat der Inferenz)' );
  (* Schrittweiten für Druck und Temperatur intitialisieren *)
  StepWidth[temp]:=25;
  StepWidth[press]:=0.25;

  Input:= temp;
  Ch := ReadKey;
  while Ch = #0 do
  begin
    RK := ord(ReadKey);
    if RK = 72 then input := temp
    else if RK = 80 then input := press
    else if (RK=73) then StepWidth[input]:=StepWidth[input] * 2
    else if (RK=81) then Stepwidth[input]:= StepWidth[input] / 2
    else if (RK=75) OR (RK=77) then
    begin
      (* 1. Eingangsvariable ändern *)
      if (RK=75) then FuzzyVars[Input]^.Change(-StepWidth[input])
      ELSE FuzzyVars[Input]^.Change(StepWidth[input]);
      (* 2. Inferenz durchführen *)
      FuzzyVars[valve]^.Infer;
      (* 3. Ergebnismenge defuzzifizieren *)
      FuzzyVars[valve]^.Defuzzy
    end;
    Ch := ReadKey
  end;
  CloseGraph
end.

