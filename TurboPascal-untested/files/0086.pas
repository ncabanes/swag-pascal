{
>>Has anyone done anything to address Win95 long file names yet?
>>I just need to be able to read them 4 now.

>I haven't done anything with it, but the current version of Ralf Brown's
>interrupt list describes the way for a DOS program to deal with them.
>(Search for Windows95 *and* Chicago.)  I don't know if that's the best way for
>a Win16 program to deal with them, but it's certainly a possibility.

There's actually a typo in release 47 of the list, as I've found out this
evening while trying to handle these in BP (hence the cross-post to
comp.lang.pascal.borland).

Here's my BP code for a little program that prints both the short and
long version of any longnamed file on C:.  it'll be pretty similar in Delphi,
if the INT 21 approach is what you're supposed to use in Win16.
}

USES Strings;

type
  TSearchRec = record                    
    attr : longint;                      
    creation : comp;                     
    lastaccess : comp;                   
    lastmodification : comp;             
    highfilesize : longint;              
    lowfilesize : longint;               
    reserved : comp;                     
    name : array[0..259] of char;        
    shortname : array[0..13] of char;    
    handle : word;                       
  end;                                   

const                                    
  faReadOnly      =  $01;                
  faHidden        =  $02;
  faSysFile       =  $04;                
  faVolumeID      =  $08;
  faDirectory     =  $10;                
  faArchive       =  $20;                
  faAnyFile       =  $3F;                

function findfirst(filespec:string;attr:word;var S:TSearchRec):integer;  
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
    mov word ptr es:[di+TSearchRec.handle], ax                           
    jc @1                                                                
    xor ax,ax                                                            
  @1:                                                                    
    mov @result,ax                                                       
    pop ds                                                               
  end;                                                                   
end;                                                                     

                                                 
function FindNext(var S:TSearchRec):integer;     
begin                                            
  asm                                            
    mov ax,$714f
    mov si,0                                     
    les di,S                                     
    mov bx,word ptr es:[di+TSearchRec.Handle]
    int $21                                      
    jc @1
    xor ax,ax                                    
  @1:                                            
    mov @result,ax                               
  end;                                           
end;                                             
                                                 
function FindClose(var S:TSearchRec):integer;    
begin                                            
  asm                                            
    mov ax,$71a1                                 
    les di,S                                     
    mov bx,word ptr es:[di+TSearchRec.Handle]    
    int $21                                      
    jc @1
    xor ax,ax                                                            
  @1:                                                                    
    mov @result,ax
  end;                                                                   
end;
                                                                         
procedure ShowLongNames(const path:string);                              
var                                                                      
  S : TSearchRec;                                                        
  Res : Integer;                                                         
begin                                                                    
  Res := findfirst(path+'\*.*',faAnyFile-faVolumeID,S);                  
  while Res = 0 do                                                       
  begin                                                                  
    with S do                                                            
    begin                                                                
      if (S.Attr and faDirectory) <> 0 then                              
      begin                                                              
        if (StrComp(Name,'.') <> 0) and (StrComp(Name,'..') <> 0) then
        begin                                                            
          if ShortName[0] <> #0 then                                     
            ShowLongNames(path+'\'+StrPas(ShortName))
          else                                                           
            ShowLongNames(path+'\'+StrPas(Name));
        end;                                                             
      end;                                                               
      if ShortName[0] <> #0 then                                         
        writeln('ren ',path+'\'+StrPas(ShortName),' "',name,'"');        
    end;                                                                 
    Res := FindNext(S);                                                  
  end;                                                                   
  FindClose(S);                                                          
end;                                                                     
                                                                         
var                                                                      
  x : integer;                                                           
begin                                                                    
  showlongnames('D:');
end.

