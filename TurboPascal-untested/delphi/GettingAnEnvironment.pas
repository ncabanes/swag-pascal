(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0189.PAS
  Description: Re: Getting an environment
  Author: MIKE CARIOTOGLOU
  Date: 11-29-96  08:17
*)



>The GetEnvironmentVariable function retrieves the value of the specified variable from the environment block
>of the calling process. The value is in the form of a null-terminated string of characters.

>DWORD GetEnvironmentVariable(

>    LPCTSTR  lpName,        // address of environment variable name 
>    LPTSTR  lpBuffer,        // address of buffer for variable value 
>    DWORD  nSize         // size of buffer, in characters
>   );        
>Parameters

>lpName

>Points to a null-terminated string that specifies the environment variable. 

>lpBuffer

Here is a simple unit I cooked for delphi 32 bit. It will give you the whole
environment in the form of a string list. then , you can access it as usual 

env:=tenvironment.create;
a:=env.values['PATH];
env.free;
etc etc

look up the values property of tstrings for more info.

-------------------------- cut here

unit uenv;

Interface

uses windows,classes;

type tenvironment=class(tstringlist)
                   constructor create;
                  end;

implementation

constructor tenvironment.create;
 var base,p:pchar;
     a:string;
 begin
  inherited create;
  base:=GetEnvironmentStrings; <--- for 16-bits, change to GetDosEnvironment.
  if base=nil then exit;
  p:=base;
  while p^<>#0 do
   begin
    a:=p; <-- for 16-bit change this to a:=strpas(p);
    add(a);
    p:=p+length(a)+1;
   end;
  FreeEnvironmentStrings(base);
 end;

