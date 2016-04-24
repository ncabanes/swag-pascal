(*
  Category: SWAG Title: SEARCH/FIND/REPLACE ROUTINES
  Original name: 0011.PAS
  Description: SEARCH.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:46
*)

Program search;                                 
{$A+,B-,D-,E+,F-,I+,L-,N-,O-,R-,S-,V-}
{$M 16384,0,655360}


 { Copyright 1990 Trevor J Carlsen Version 1.05  24-07-90                    }
 { This Program may be used and distributed as if it was in the Public Domain}
 { With the following exceptions:                                            }
 {    1.  if you alter it in any way, the copyright notice must not be       }
 {        changed.                                                           }
 {    2.  if you use code excerpts in your own Programs, due credit must be  }
 {        given, along With a copyright notice -                             }
 {        "Parts Copyright 1990 Trevor J Carlsen"                            }
 {    3.  No Charge may be made For any Program using code from this Program.} 

 { SEARCH will scan a File or group of Files and report on all occurrences   }
 { of a particular String or group of Characters. if found the search String }
 { will be displayed along With the 79 Characters preceding it and the 79    }
 { Characters following the line it is in.  Wild cards may be used in the    }
 { Filenames to be searched.                                                 }
 
 { if you find this Program useful here is the author's contact address -    }          
         
 {      Trevor J Carlsen                                                     }          
 {      PO Box 568                                                           }          
 {      Port Hedland Western Australia 6721                                  }          
 {      Voice 61 [0]91 72 2026                                               }          
 {      Data  61 [0]91 72 2569                                               }          


 
Uses
  Dos,
  tpString,  { Turbo Power's String handling library.  Procedures and        }
             { Functions used from this Unit are -                           }
             {       BMSearch       THESE ARE in THE SOURCE\MISC DIRECtoRY   }
             {       BMSearchUC                                              }
             {       BMMakeTable                                             }
             {       StUpCase                                                }
  tctimer;   { A little timing routine - not needed if lines (**) removed.   }
  
Const
  bufflen     = 65000;  { Do not increase this buffer size . Ok to decrease. }
  searchlen   = bufflen;
  copyright1  = 'SEARCH - version 1.05 Copyright 1990 Trevor Carlsen';
  copyright2  = 'All rights reserved.';

Type
  str79       = String[79];
  bufferType  = Array[0..bufflen] of Byte;
  buffptr     = ^bufferType;

Const
  space       = #32;
  quote       = #34;
  comma       = #44;
  CaseSensitive : Boolean = True;       { default is a Case sensitive search }
Var
  table       : BTable;                           { Boyer-Moore search table }
  buffer      : buffptr;                             { Pointer to new buffer }
  f           : File;
  DisplayStr  : Array[0..3] of str79;
  Filename,
  SrchStr     : String;
  Slen        : Byte Absolute SrchStr;
  
Procedure Asc2Str(Var s, ns; max: Byte);

  { Converts an Array of asciiz Characters to a turbo String                 }
  { For speed the Variable st is  effectively global and it is thereFore     }
  { vitally important that max is no larger than the ns unTyped parameter    }
  { Failure to ensure this can result in unpredictable Program behaviour     }
  
  Var stArray : Array[0..255] of Byte Absolute s;
      st      : String Absolute ns;
      len     : Byte Absolute st;
      
  begin
    move(stArray[0],st[1],max);
    len := max;
  end; { Asc2Str }

Procedure ReportError(e : Byte);
  { Displays a simple instruction screen in the event of insufficient        }
  { parameters or certain other errors                                       }
  begin
    Writeln('SYNTAX:');
    Writeln('SEARCH [-c] [path]Filename searchstr');
    Writeln(' eg:  SEARCH c:\comm\telix\salt.doc "color"');
    Writeln(' or');
    Writeln('      SEARCH c:\comm\telix\salt.doc 13,10,13,10,13,10,13,10');
    Writeln(' or');
    Writeln('      SEARCH -c c:\*.* "MicroSoft"');
    Writeln;
    Writeln('if the -c option is used then a Case insensitive search is used.');
    Writeln('When used the -c option must be the first parameter.');
    halt(e);
  end; { ReportError }

Procedure ParseCommandLine;
  { This Procedure is Really the key to everything as it parses the command  }
  { line to determine what the String being searched For is.  Because the    }
  { wanted String can be entered in literal Form or in ascii codes this will }
  { disect and determine the method used.                                    }
  
  Var
    parstr      : String;                        { contains the command line }
    len         : Byte Absolute parstr;{ will contain the length of cmd line }
    cpos, qpos,
    spos, chval : Byte;
    error       : Integer;
    
  begin { ParseCommandLine}
    parstr    := String(ptr(PrefixSeg,$80)^);         { Get the command line }
    if parstr[1] = space then
      delete(parstr,1,1);  { if the first Character is a space get rid of it }
    spos      := pos(space,parstr);                   { find the first space }
    if spos    = 0 then                   { No spaces which must be an error }
      ReportError(1);   
    
    Filename  := StUpCase(copy(parstr,1,spos-1));  { Filename used as a temp }
    if pos('-C',Filename) = 1 then begin  { Case insensitive search required }
      CaseSensitive := False;
      delete(parstr,1,spos);                   { Get rid of the used portion }
    end; { if pos('-C' }
    spos      := pos(space,parstr);                        { find next space }
    if spos    = 0 then                   { No spaces which must be an error }
      ReportError(1);                     
    Filename  := StUpCase(copy(parstr,1,spos-1));        { Get the File mask }
    delete(parstr,1,spos);                     { Get rid of the used portion }
    
    qpos      := pos(quote,parstr);          { look For the first quote Char }
    if qpos   <> 0 then begin    { quote Char found - so must be quoted Text }
      if parstr[1] <> quote then ReportError(2);  { first Char must be quote }
      delete(parstr,1,1);                       { get rid of the first quote }
      qpos      := pos(quote,parstr);              { and find the next quote }
      if qpos = 0 then ReportError(3);  { no more quotes - so it is an error }
      SrchStr   := copy(parstr,1,qpos-1);        { search String now defined }
    end  { if qpos <> 0 }
    
    else begin                                   { must be using ascii codes }
      Slen      := 0;     
      cpos      := pos(comma,parstr);                     { find first comma }
      if cpos = 0 then cpos := succ(len);{ No comma - so only one ascii code }
      Repeat                                      { create the search String }
        val(copy(parstr,1,pred(cpos)),chval,error);
        if error <> 0 then ReportError(7);   { there is an error so bomb out }
        inc(Slen);
        SrchStr[Slen] := Char(chval);        { add Char to the search String }
        delete(parstr,1,cpos);           { get rid of used portion of parstr }
        cpos  := pos(comma,parstr);                    { find the next comma }
        if cpos = 0 then cpos := succ(len);    { no more commas so last Char }
      Until len = 0;              { Until whole of command line is processed }
    end; { else}
    
    if not CaseSensitive then       { change the Search String to upper Case }
      SrchStr := StUpCase(SrchStr);
  end; { ParseCommandLine }

Function OpenFile(ofn : String): Boolean;  { open a File For BlockRead/Write }
  Var
    error : Word;
  begin { OpenFile}
    assign(f,ofn);
    {$I-} reset(f,1); {$I+}
    error := Ioresult;
    if error <> 0 then
      Writeln('Cannot open ',ofn);
    OpenFile := error = 0;
  end; { OpenFile }

Procedure CloseFile;
  begin
    {$I-}
    Close(f);
    if Ioresult <> 0 then;    { don't worry too much if an error occurs here }
    {$I+}
  end; { CloseFile }

Procedure SearchFile(Var Filename: String);
  { Reads a File into the buffer and then searches that buffer For the wanted}
  { String or Characters.                                                    }
  Var
    x,y,
    count,
    result,
    bufferpos   : Word;
    abspos      : LongInt;
    finished    : Boolean;
    
  begin  { SearchFile}
    BMMakeTable(SrchStr,table);          { Create a Boyer-Moore search table }
    new(buffer);                     { make room on the heap For the buffers }
    {$I-} BlockRead(f,buffer^,searchlen,result); {$I+}  { Fill buffer buffer }
    if Ioresult <> 0 then begin      { error occurred While reading the File }
      CloseFile;
      ReportError(11);
    end; { if Ioresult }
    abspos       := 0;        { Initialise the Absolute File position marker }
    Repeat
      bufferpos      := 0;               { position marker in current buffer }
      count          := 0;               { offset from search starting point }
      finished := (result < searchlen);    { if buffer <> full no more reads }
      
      Repeat                              { Do a BM search For search String }
        if CaseSensitive then                   { do a Case sensitive search }
          count:=BMSearch(buffer^[bufferpos],result-bufferpos,table,SrchStr)
        else                                  { do a Case insensitive search }
          count:=BMSearchUC(buffer^[bufferpos],result-bufferpos,table,SrchStr);
        
        if count <> $FFFF then begin                   { search String found }
          inc(bufferpos,count);        { starting point of SrchStr in buffer }
          DisplayStr[0] := HexL(abspos+bufferpos) +    { hex and decimal pos }
                           Form('  @######',(abspos+bufferpos) * 1.0);
          if bufferpos > 79 then          { there is a line available beFore }
            Asc2Str(buffer^[bufferpos - 79],DisplayStr[1],79)
          else                          { no line available beFore the found }
            DisplayStr[1] := '';               { position so null the String }
          if (bufferpos + 79) < result then       { at least 79 Chars can be }
            Asc2Str(buffer^[bufferpos],DisplayStr[2],79)         { displayed }
          else                         { only display what is left in buffer }
            Asc2Str(buffer^[bufferpos],DisplayStr[2],result - bufferpos);
          if (bufferpos + 158) < result then    { display the line following }
            Asc2Str(buffer^[bufferpos + 79],DisplayStr[3],79)
          else                          { no line following the found String }
            DisplayStr[3] := '';                { so null the display String }
          Writeln;
          Writeln(DisplayStr[0],'   ',Filename);{ display the File locations }
          
          For x := 1 to 3 do begin
            For y := 1 to length(DisplayStr[x]) do{ filter out non-printables}
              if ord(DisplayStr[x][y]) < 32 then DisplayStr[x][y] := '.';
            if length(DisplayStr[x]) <> 0 then   { only display Strings With }
               Writeln(DisplayStr[x]);                       { valid content }
          end; { For x }
          
          inc(bufferpos,Slen);         { no need to check buffer in found st }
        end;  { if count <> $ffff }
        
      Until (bufferpos >= (result-length(SrchStr))) or (count = $ffff);
      
      if not finished then begin       { Fill 'er up again For another round }
        inc(abspos,result - Slen);      { create overlap so no String missed }
        {$I-} seek(f,abspos);
        BlockRead(f,buffer^,searchlen,result); {$I+}
        if Ioresult <> 0 then begin
          CloseFile;
          ReportError(13);
        end;
      end; { if not finished}
    Until finished;
    dispose(buffer);
  end; { SearchFile }

Procedure SearchForFiles;
  Var
    dirinfo : SearchRec;
    FullName: PathStr;
    DirName : DirStr;
    FName   : NameStr;
    ExtName : ExtStr;
    found   : Boolean;
  begin
    FindFirst(Filename,AnyFile,dirinfo);
    found := DosError = 0;
    if not found then begin
      Writeln('Cannot find ',Filename);
      ReportError(255);
    end;
    FSplit(Filename,DirName,FName,ExtName);
    While found do begin
      if (dirinfo.Attr and 24) = 0 then begin
        FullName := DirName + dirinfo.name;
        if OpenFile(FullName) then begin
          SearchFile(FullName);
          CloseFile;
        end;
      end;
      FindNext(dirinfo);
      found := DosError = 0;
    end;
  end; { SearchForFiles }

begin { main}
  (**) StartTimer;
  Writeln(copyright1);
  Writeln(copyright2);
  ParseCommandLine;
  SearchForFiles;
  (**) WriteElapsedTime;
end.


