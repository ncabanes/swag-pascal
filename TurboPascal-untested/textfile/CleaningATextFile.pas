(*
  Category: SWAG Title: TEXT FILE MANAGEMENT ROUTINES
  Original name: 0016.PAS
  Description: Cleaning a Text file
  Author: MATT GIWER
  Date: 08-27-93  20:22
*)

{
MATT GIWER

It is designed to clean up Files you might wish to capture from Real time
chat.  It gets rid of all those back spaces and recreates a readable File
that appears as though no typos were made by anyone.

{$M 65520,0,655360 }
Program capture_strip;

Uses
  Dos, Crt;

Const
  copyright : String[80] =
                'copyright 1988 and 1991 by Matt Giwer, all rights reserved';
  name : String[20] = 'CAPture CLeaN ';
  ver  : String[5]  = '1.2';

Var
  in_File,
  out_File    : Text;
  in_name,
  out_name    : String[30];
  in_String,
  out_String  : String[250];
  i, k, l     : Integer;
  ch          : Char;
  count       : Integer;
  Files       : Array[1..50] of String[20];
  in_Array,
  out_Array   : Array[1..100] of String[250];
  Array_count : Byte;

Procedure clear_Strings;
Var
  i : Byte;
begin
  for i := 1 to 100 do
  begin
    in_Array[i]  := '';
    out_Array[i] := '';
  end;
end;

Procedure strip_File;
begin
  For l := 1 to Array_count do
  begin
    out_String := '';
    in_String  := in_Array[l];
    For i := 1 to length(in_String) do
    {if it is any except a backspace then add it to the output String}
    begin
      if ord(in_String[i]) <> 8  then
        out_String := out_String + in_String[i];
      {if it is a backspace than the intention was to remove the last Character
      in the String that was added above.  Thus the BS is a signal to remove the
      last Character added above.}
      if ord(in_String[i]) = 8 then
        delete(out_String, length(out_String), 1);
    end;
    While (out_String[length(out_String)] = ' ') do
      delete(out_String, length(out_String), 1);
    out_Array[l] := out_String;
  end;
end;

Procedure fill_Array;
begin
  While not eof(in_File) do
  begin
    clear_Strings;
    Array_count := 1;
    While (not eof(in_File) and (Array_count < 100) ) do
    begin
      readln(in_File, in_Array[Array_count]);
      Array_count := Array_count + 1;
    end;
    strip_File;
    For l := 1 to Array_count do
      Writeln(out_File, out_Array[l]);
  end;
end;

begin
  Writeln(name,ver);
  Writeln(copyright);
  For count := 1 to 50 do
    Files[count] := '                    ';
  clear_Strings;
  Writeln;
  if paramcount < 1 then {if command line empty}
  begin
    Writeln('Only Filenames are accepted, no extenders');
    Writeln('Output File will be  .CLN');
    Write('Enter File name.  '); readln(in_name);
  end
  else   {else get an Array of the parameters}
  begin
    For i := 1 to paramcount do
      Files[i] := paramstr(i)  {! count vice i}
  end;
  if paramcount < 1 then
  begin
    assign(in_File, in_name);
    reset(in_File);
    assign(out_File, in_name + '.CLN');
    reWrite(out_File);
    Write('Working on ', in_name:20);
    fill_Array;
    Writeln;
  end
  else
  begin
    For count := 1 to paramcount do
    begin
      in_name := paramstr(count);
      assign(in_File, in_name);
      reset(in_File);
      assign(out_File, in_name + '.CLN');
      reWrite(out_File);
      Write('Working on ', paramstr(count):20);
      fill_Array;
      Writeln;
      close(in_File);
      close(out_File);
    end;
  end;
end.
