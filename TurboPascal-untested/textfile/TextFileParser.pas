(*
  Category: SWAG Title: TEXT FILE MANAGEMENT ROUTINES
  Original name: 0032.PAS
  Description: Text File Parser
  Author: STEVEN KERR
  Date: 02-05-94  07:57
*)


{╔═══════════════════════════════════════════════════════════════════╗}
{║ TEMPLATE - Text File Parser                                       ║}
{║   Steven Kerr, 1994                                               ║}
{║                                                                   ║}
{║ Syntax : TEMPLATE Input Output                                    ║}
{║                                                                   ║}
{║   Where Input  = Input File                                       ║}
{║         Output = Output File                                      ║}
{╚═══════════════════════════════════════════════════════════════════╝}
{$M 8192, 0, 0}
Program Template;
Uses DOS;
Const
  Null         : String = '';
  LeftControl  : Char   = '<'; { Left hand control character  }
  RightControl : Char   = '>'; { Right hand control character }
Var
  InputFile, OutputFile : Text;
  Checked, Error        : Boolean;

Function Upper (Parameter : String) : String;
Var
  I : Integer;
begin
  for I := 1 to Length(Parameter) do
    Parameter[I] := UpCase(Parameter[I]);
  Upper := Parameter
end {Function Upper};

Function File_Exists (Filename : String) : Boolean;
Var
  Attr : Word;
  F    : File;
begin
  Assign(F, Filename);
  GetFAttr(F, Attr);
  File_Exists := (DOSError = 0)
end { Function FileExists };

Procedure Display_Error (Message : String; Filename : String);
begin
  Writeln;
  Writeln('TEMPLATE - Text File Parser');
  Writeln('  Steven Kerr, 1994');
  Writeln;
  Writeln('Syntax : TEMPLATE Input Output');
  Writeln;
  Writeln('  Where Input  = Input File');
  Writeln('        Output = Output File');
  Writeln;
  Writeln('Error : ', Message, Filename)
end { Procedure Display_Help };

Function Check_Variable (Variable : String; Position : Byte) : Byte;
Var
  Valid : Boolean;
begin
  Valid := False;
  { Add in addition variables as below. If Valid = False, the variable }
  { is ignored and written "as is".                                    }
  if Upper(Variable) = LeftControl + 'DISKFREEC' + RightControl then begin
    Valid := True;
    Write(OutputFile, DiskFree(3))
  end { DiskFreeC };
  {}
  Checked := True;
  if Valid then
    Check_Variable := Position + Length(Variable) - 1
  else
    Check_Variable := Position - 1
end { Function Check_Variable };

Function Look_Ahead (Line : String; Position : Byte) : String;
Var
  Variable : String;
begin
  Variable := Line[Position];
  While (Length(Line) <> Position) and
        (Line[Position] <> RightControl) do begin
    Inc(Position);
    Variable := Variable + Line[Position]
  end { While };
  Look_Ahead := Variable
end { Function Look_Ahead };

Procedure Parse_File;
Var
  Line     : String;
  Position : Byte;
begin
  Position := 0;
  Checked := False;
  While (not EOF(InputFile)) do begin
    Readln(InputFile, Line);
      While Position < Length(Line) do begin
        Inc(Position);
        if (Line[Position] = LeftControl) and (not Checked) then begin
          Position := Check_Variable(Look_Ahead(Line, Position), Position)
        end else begin
          Write(OutputFile, Line[Position]);
          Checked := False
        end { if }
      end { While };
      Position := 0;
      Checked := False;
      Writeln(OutputFile)
  end { While }
end { Procedure Parse_File };

Function Files_Opened (InputF : String; OutputF : String) : Boolean;
Var
  Error : Boolean;
begin
  Error := False;
  Assign(InputFile, ParamStr(1));
  Assign(OutputFile, ParamStr(2));
  {$I-} ReWrite(OutputFile); {$I+}
  if IOResult <> 0 then begin
    Display_Error('Unable to write to ', Upper(ParamStr(2)));
    Error := True
  end { if IOResult };
  if (not Error) then begin
    {$I-} Reset(InputFile); {$I+}
    if IOResult <> 0 then begin
      Display_Error('Unable to read from ', Upper(ParamStr(1)));
      Error := True
    end { if IOResult }
  end { if };
  Files_Opened := (not Error)
end { Function Files_Opened };

begin { Program Template }
  if ParamCount = 2 then begin
    if File_Exists(ParamStr(1)) then begin
      if (not File_Exists(ParamStr(2))) then begin
        if Files_Opened(ParamStr(1), ParamStr(2)) then begin
          Parse_File;
          Close(InputFile);
          Close(OutputFile)
        end
      end else
        Display_Error('Output file already exists', '')
    end else
      Display_Error('Input file not found', '')
  end else
      Display_Error('Invalid number of parameters', '')
end { Program Template }.

