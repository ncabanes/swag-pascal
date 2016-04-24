(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0157.PAS
  Description: Re: TEdit and numbers
  Author: RAY LISCHNER
  Date: 08-30-96  09:35
*)

{
>I want the user to enter numbers and sometime I want to view numbers on
>screen.
>I use TEdit and must convert the data everytime.
>Is there any other component to use, so I can have the data directly
>to integers and real?
Just create a custom component that adds a property to do the
conversion for you, e.g.,
}
type
  TIntegerEdit = class(TEdit)
  private
    function GetInt: LongInt;
    procedure SetInt(Value: LongInt);
  public
    property IntValue: LongInt read GetInt write SetInt;
  end;
function TIntegerEdit.GetInt: LongInt;
begin
  Result := StrToInt(Text)
end;
procedure TIntegerEdit.SetInt(Value: LongInt);
begin
  Text := IntToStr(Value)
end;


