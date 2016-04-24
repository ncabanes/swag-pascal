(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0257.PAS
  Description: Creating a function with multiple args
  Author: CHAMI
  Date: 05-30-97  18:17
*)

Sometimes it's necessary to pass undefined number of [different type]
variables to a function -- look at Format() function in Delphi and
*printf() functions in C/C++ for example. Once you analyze the following
code, you'll be on your way to creating mysterious variable parameter
functions...

//
// FunctionWithVarArgs()
//
// skeleton for a function that
// can accept vairable number of
// multi-type variables
//
// here are some examples on how
// to call this function:
//
// FunctionWithVarArgs(
//   [ 1, True, 3, '5', '0' ] );
//
// FunctionWithVarArgs(
//   [ 'one', 5 ] );
//
// FunctionWithVarArgs( [] );
//
procedure FunctionWithVarArgs(
  const ArgsList : array of const );
var
  ArgsListTyped :
    array[0..$FFF0 div SizeOf(TVarRec)]
      of TVarRec absolute ArgsList;
  n         : integer;
begin
  for n := Low( ArgsList ) to
           High( ArgsList ) do
  begin
    with ArgsListTyped[ n ] do
    begin
      case VType of
        vtInteger   : begin
          {handle VInteger here}      end;
        vtBoolean   : begin
          {handle VBoolean here}      end;
        vtChar      : begin
          {handle VChar here}         end;
        vtExtended  : begin
          {handle VExtended here}     end;
        vtString    : begin
          {handle VString here}       end;
        vtPointer   : begin
          {handle VPointer here}      end;
        vtPChar     : begin
          {handle VPChar here}        end;
        vtObject    : begin
          {handle VObject here}       end;
        vtClass     : begin
          {handle VClass here}        end;
        vtWideChar  : begin
          {handle VWideChar here}     end;
        vtPWideChar : begin
          {handle VPWideChar here}    end;
        vtAnsiString: begin
          {handle VAnsiString here}   end;
        vtCurrency  : begin
          {handle VCurrency here}     end;
        vtVariant   : begin
          {handle VVariant here}      end;
        else          begin
          {handle unknown type here} end;
      end;
    end;
  end;
end;

//
// example function created using
// the above skeleton
//
// AddNumbers() will return the
// sum of all the integers passed
// to it
//
// AddNumbers( [1, 2, 3] )
//   will return 6
//
//
function AddNumbers(
  const ArgsList : array of const )
    : integer;
var
  ArgsListTyped :
    array[0..$FFF0 div SizeOf(TVarRec)]
      of TVarRec absolute ArgsList;
  n         : integer;
begin
  Result := 0;
  for n := Low( ArgsList ) to
           High( ArgsList ) do
  begin
    with ArgsListTyped[ n ] do
    begin
      case VType of
        vtInteger   : Result := Result + VInteger;
      end;
    end;
  end;
end;



