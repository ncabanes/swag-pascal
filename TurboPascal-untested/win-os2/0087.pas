unit lfn;

{
 This unit allows a Windows 3.x program to access Windows 95
 long file names.  Use the LFNFindFirst and LFNFindNext like
 you would use the corresponding ones for normal file names.
 The only two differences you should note:

   1.  The path is a standard Pascal string, not asciiz.
   2.  These are functions, they return an error code value.
       Codes are standard except 99: o/s not lfn capable.

 Constants LFNAble and WinVersion are available for the
 host application to consult.  The major version is held
 in the low-order byte with the minor version in the
 high-order byte of WinVersion.

 Be sure to LFNFindClose when you have completed the operation.

 credits:
   Duncan Murdoch - assembler code for LFNFindFirst, LFNFindNext
                    and LFNFindClose.
   Michael Feltz  - logic to check windows version and return error
                    if long file names are not supported, conversion
                    to a Pascal unit.
  }


Interface

uses winprocs;

type
  TLFNSearchRec = record
    attr         : longint;                      
    creation     : comp;                     
    lastaccess   : comp;                   
    lastmod      : comp;             
    highfilesize : longint;              
    lowfilesize  : longint;               
    reserved     : comp;                     
    name         : array[0..259] of char;        
    shortname    : array[0..13] of char;    
    handle       : word;                       
  end;                                   

const                                    
  faReadOnly      =  $01;
  faHidden        =  $02;
  faSysFile       =  $04;                
  faVolumeID      =  $08;
  faDirectory     =  $10;                
  faArchive       =  $20;                
  faAnyFile       =  $3F;
  LFNAble        : Boolean = True;   {is oper sys long file name able?}
  WinVersion     : Word = 0;         {windows version}

function LFNFindFirst (filespec:string;attr:word;var S:TLFNSearchRec):integer;
function LFNFindNext  (var S:TLFNSearchRec):integer;
function LFNFindClose (var S:TLFNSearchRec):integer;

Implementation

function LFNFindFirst(filespec:string;attr:word;var S:TLFNSearchRec):integer;
begin
  If LFNAble then
  begin
    filespec := filespec + #0;
    S.attr := attr;                                                        
    asm                                                                    
      push ds                                                              
      push ss                                                              
      pop ds                                                               
      lea dx,filespec+1
      les di,S
      mov ax,$714e                                                         
      mov cx,attr                                                          
      mov si,0
      int $21                                                              
      les di,S
      mov word ptr es:[di+TLFNSearchRec.handle], ax
      jc @1                                                                
      xor ax,ax                                                            
    @1:                                                                    
      mov @result,ax                                                       
      pop ds                                                               
    end; {asm}                                                                   
  end    {if}
  else
    LFNFindFirst := 99;
end;     {function}
                                                 
function LFNFindNext(var S:TLFNSearchRec):integer;
begin
  If LFNAble then
  asm                                            
    mov ax,$714f
    mov si,0                                     
    les di,S                                     
    mov bx,word ptr es:[di+TLFNSearchRec.Handle]
    int $21                                      
    jc @1
    xor ax,ax                                    
  @1:                                            
    mov @result,ax                               
  end  {asm}
  else
    LFNFindNext := 99;                                          
end;   {function}                                             
                                                 
function LFNFindClose(var S:TLFNSearchRec):integer;
begin
  If LFNAble then
  asm                                            
    mov ax,$71a1                                 
    les di,S                                     
    mov bx,word ptr es:[di+TLFNSearchRec.Handle]    
    int $21                                      
    jc @1
    xor ax,ax                                                            
  @1:                                                                    
    mov @result,ax
  end {asm}
  else
    LFNFindClose := 99;                                                                   
end;  {function}

begin
  WinVersion := LoWord(GetVersion);
  If ((Lo(WinVersion) =  3)  and                    {windows 95 first}
      (Hi(WinVersion) < 95)) or                     {version is 3.95 }
      (Lo(WinVersion) <  3)  then LFNAble := False;
end.  {unit}                                                                        


