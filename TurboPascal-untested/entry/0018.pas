{ This is a big one... This is an (hopefully) error free, full featured, date
input routine. It accepts all known editing keys (such as left, right, del, bs
etc,etc,etc...) and validates the inserted date. Well, the parameters are:

          data(x,y:integer;ct:boolean; var inp:string; var ret:integer);

          (x,y) - coordinates of input location;
          ct    - is insert on (true) or off (false);
          inp   - where the new date will be inserted;
          ret   - return code. 1 means up was pressed, 2 means down pressed;
                  0 means esc was pressed. Any of these abort date entry,
                  although that can be easily fixed by deactivating their
                  entries in the datainput procedure;

Dates get out in the European DD/MM/YY format. This only afects the validation,
so if you want to change it, change the order of x1, x2 and x3 in vali_date to
suit your needs. For instance, to get the format MM/DD/YY, change all x1 in the
val functions to x2, and all x2 to x1. ONLY IN THE VAL, in the beggining of the
vali_date procedure.

Portuguese Freeware, 1994, Luis Evaristo Fonseca Thunderball Software Inc.
}

unit dateinp;

interface    

uses crt,top;

const
    BS        =   8;
    TAB       =   9;
    CR        =  13;
    CTRLT     =  20;
    CTRLY     =  25;
    ESC       =  27;
    HOME      = 327;
    UP        = 328;
    ENDK    
    DOWN      = 336;
    LEFT      = 331;
    RIGHT     = 333;
    INS       = 338;
    DEL       = 339;
    CTRLLEFT  = 371;
    CTRLRIGHT = 372;
    ONLYNUM=['0'..'9'];

procedure data(x,y:integer;ct:boolean; var inp:string; var ret:integer);

IMPLEMENTATION

{ lê tecla premida }
function getkey : word;
var
    ch : char;
begin
    ch := readkey;
    if ch=#0 then 
        getkey := ord(readkey)+256
    else
        getkey := ord(ch);   
end;

{ escreve a string no écran }
procedure writestr(x,y:integer;inp:string;var x1:integer);
var aux,conta:integer;
begin
    gotoxy(x,y);
    write('  /  /  ');
    gotoxy(x,y);
    aux:=x;
    for conta:=1 to ord(inp[0]) do
    begin
        case conta of
            1,2:begin
                    gotoxy(x+conta-1,y);
                    write(inp[conta]);
                end;
            3,4:begin
                    gotoxy(x+conta,y);
                    write(inp[conta]);
                end;
            5,6:begin
                    gotoxy(x+conta+1,y);
                    write(inp[conta]);
                end;
        end;
    end;
    gotoxy(x1,y);
end;

{ salta para a primeira posiçäo de cursor válida, actualiza écran }
procedure homekey(x,y:integer; var x1,posic:integer);
begin
    x1:=x;
    posic:=1;
    gotoxy(x1,y);
end;

{ salta para a última posiç╞o de cursor utilizada, actualiza écran }
procedure endkey(inp:string;x,y:integer;var x1,posic:integer);
begin
    case length(inp) of
        1:x1:=x+1;
        2:x1:=x+3;
        3:x1:=x+4;
        4:x1:=x+6;
        5:x1:=x+7;
        6:x1:=x+7;
    end;
    posic:=length(inp)+1;
    if posic>6 then
        posic:=6;
    gotoxy(x1,y);
end;

{ move o cursor uma casa para a esquerda, actualiza écran, näo ultrapassa o }
{ limite máximo de cursor à esquerda }
procedure leftkey(x,y:integer; var x1,posic:integer);
begin
    x1:=x1-1;
    posic:=posic-1;
    if (x1=x+2) or (x1=x+5) then
        x1:=x1-1;
    if x1-x<0 then
    begin
        x1:=x1+1;
        posic:=posic+1;
    end;
    gotoxy(x1,y);
end;

{ move o cursor uma casa para a direita, actualiza écran, n╞o ultrapassa a }
{ posiç╞o do último caracter escrito mais uma posiç╞o }
procedure rightkey(x,y:integer; inp:string; var x1,posic:integer);
begin
    x1:=x1+1;
    posic:=posic+1;
    if (x1=x+2)  or (x1=x+5) then
        x1:=x1+1;
    if (length(inp)+1<posic) or (x1>x+7) then
    begin
        x1:=x1-1;
        posic:=posic-1;
    end;
    gotoxy(x1,y);
end;

{ move o cursor para a primeira letra da palavra, ou (caso }
{ o cursor n╞o se encontre sobre nenhuma palavra, a próxima }
procedure ctrll(x,y:integer; inp:string; var x1,posic:integer);
begin
    if posic<4 then
    begin
        posic:=1;
        x1:=x;
    end
    else
    begin
        posic:=3;
        x1:=x+3;
    end;
    gotoxy(x1,y);
end;

{ move o cursor para a primeira letra da palavra seguinte }
procedure ctrlr(x,y:integer; inp:string; var x1,posic:integer);
begin
    case posic of
        1,2:if length(inp)>1 then
            begin
                posic:=3;
                x1:=x+3;
            end;
        3,4:if length(inp)>3 then
            begin
                posic:=5;
                x1:=x+6;
            end;
    end;
    gotoxy(x1,y);
end;

{ apaga tudo o que está escrito, actualiza string e ecran }
procedure ctrl_y(x,y:integer; var x1,posic:integer; var inp:string);
begin
    x1:=x;
    posic:=1;
    inp:='';
    writestr(x,y,inp,x1);
end;

{ apaga tudo o que está escrito à direita do cursor, actualiza string e ecran }
procedure ctrl_t(x,y:integer; var x1,posic:integer; var inp:string);
var conta:integer;
begin
    if length(inp)>posic then
        for conta:=posic to length(inp) do
            delete(inp,posic,1);
    writestr(x,y,inp,x1);
end;

{ liga / desliga o modo de inserçäo "overwrite" (cursor em bloco) ou normal }
procedure inskey(var ct:boolean);
begin
    if ct=true then
    begin
        bigcursor;
        ct:=false
    end
    else
    begin
        linecursor;
        ct:=true;
    end;
end;

{ apaga o caracter à direita na string, actualiza écran }
procedure delk(x,y:integer;var x1,posic:integer;var inp:string);
begin
    if length(inp)>=posic then
        delete(inp,posic,1);
    writestr(x,y,inp,x1);
end;

{ apaga o caracter à esquerda na string, actualiza écran, n╞o passa o }
{ limite máximo à esquerda }
procedure bsk(x,y:integer;var x1,posic:integer;var inp:string);
begin
    if x1-1>=x then
    begin
         delete(inp,posic-1,1);
         if (posic in [3,5]) then
             x1:=x1-2
         else
             x1:=x1-1;
         posic:=posic-1;
         writestr(x,y,inp,x1);
    end;
end;

procedure tabkey(x,y:integer;ct:boolean;var x1,posic:integer;var inp:string);
var conta:integer;
begin
    case posic of
        1,2:if length(inp)>1 then
            begin
                posic:=3;
                x1:=x+3;
            end;
        3,4:if length(inp)>3 then
            begin
                posic:=5;
                x1:=x+6;
            end;
    end;
    gotoxy(x1,y);
end;

procedure datainput(x,y:integer;var inp:string;var ct:boolean;var ret:integer);
var x1,conta,posic:integer;
    c:word;
begin
    x1:=x;
    posic:=1;
    gotoxy(x1,y);
    c:=100;
    while (c<>CR) do
    begin
        c:=getkey;
        if (c>28) and (c<256) and (chr(c) in onlynum) then
        begin
            if (x1=x+1) or (x1=x+4) then
                inc(x1);
            if ct=true then
            begin
                if length(inp)+1<=6 then
                begin
                    insert(chr(c),inp,posic);
                    if posic+1<=6 then
                    begin
                        inc(posic);
                        inc(x1);
                    end;
                end
            end
            else
            begin
                if (posic=length(inp)+1) and (length(inp)<6) then
                    inp[0]:=chr(ord(inp[0])+1);
                inp[posic]:=chr(c);
                if posic<6 then
                begin
                    inc(x1);
                    inc(posic);
                end;
            end;
        end
        else
        begin
            case c of
                BS:bsk(x,y,x1,posic,inp);
                HOME:homekey(x,y,x1,posic);
                ENDK:endkey(inp,x,y,x1,posic);
                LEFT:leftkey(x,y,x1,posic);
                RIGHT:rightkey(x,y,inp,x1,posic);
                CTRLLEFT:ctrll(x,y,inp,x1,posic);
                CTRLRIGHT:ctrlr(x,y,inp,x1,posic);
                INS:inskey(ct);
                DEL:delk(x,y,x1,posic,inp);
                TAB:tabkey(x,y,ct,x1,posic,inp);
                CTRLY:ctrl_y(x,y,x1,posic,inp);
                CTRLT:ctrl_t(x,y,x1,posic,inp);
                UP:begin
                        ret:=1;
                        exit;
                   end;
                DOWN:begin
                        ret:=2;
                        exit;
                     end;
                ESC:begin
                        ret:=0;
                        exit;
                    end;
            end;
        end;
        writestr(x,y,inp,x1);
    end;
end;

function vali_date(inp:string):boolean;
var x1,x2,x3,code:integer;
begin
    val(inp[1]+inp[2],x1,code);
    val(inp[3]+inp[4],x2,code);
    val(inp[5]+inp[6],x3,code);
    if (inp<>'') then
    begin
        if (x2>0) and (x2<13) then
        begin
            case x2 of
                 1,3,5,7,8,10,12:if (x1>0) and (x1<32) then
                                     vali_date:=true
                                 else
                                     vali_date:=false;
                 4,6,9,11       :if (x1>0) and (x1<31) then
                                     vali_date:=true
                                 else
                                     vali_date:=false;
                 2              :if (x1>0) and (x1<30) then
                                 begin
                                     if (x3+1900) mod 4 <> 0 then
                                     begin
                                         if x1<29 then
                                             vali_date:=true
                                         else
                                             vali_date:=false;
                                     end
                                     else
                                         if x1<30 then
                                             vali_date:=true
                                         else
                                             vali_date:=false;
                                 end
                                 else
                                     vali_date:=false;
             end;
        end
        else
             vali_date:=false;
    end
    else
        vali_date:=true;
end;

procedure data(x,y:integer;ct:boolean;var inp:string; var ret:integer);
var test:boolean;
begin
    gotoxy(x,y);
    test:=false;
    while test=false do
    begin
          datainput(x,y,inp,ct,ret);
          test:=vali_date(inp);
    end;
end;

begin
end.
