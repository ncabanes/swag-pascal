(*
  Category: SWAG Title: SOUNDBLASTER/ADLIB/SPEAKER ROUTINES
  Original name: 0076.PAS
  Description: ANother PC-Speaker Disabler
  Author: KLAUS WIEGAND
  Date: 05-26-95  23:29
*)

{
>> Can anyone here make me a program that will intercept anything sent
>> to the pcspeaker so I can shut the speaker off when I am asleep. This
>> is important because I run a BBS and I am getting tired of being woke
>> up by callers who play doors that beep at 4:00 am.

(from my archive of the german pascal echo, author lost)

why should programmers open their pc case, as proposed, when a tsr will do
it as well ?? <g> savings of 1,67 $ for a screwdriver to me ;-)))))

tsr to diable/enable the pc speaker
}

program Speaker_off;

{$S-}
{$M 1048,0,0}

uses Dos, Crt;

type
     PSP  = record
              dummy  : array [0..$2b] of byte;
              EnvSeg : word;
            end;
     PSPP = ^PSP;

const TimeInt       = $1C;
      PrgID      : string  = 'SPEAKOFF V1.0';

var OldTimer      : pointer;

PROCEDURE Speaker_aus; interrupt;
BEGIN
  asm
    in al,61h
    and al,0fch
    out 61h,al
  end;
END;

function GetPtr( Adresse : pointer; PSPSeg : word ) : pointer;
begin
  GetPtr := ptr( PSPSeg + ( Seg(Adresse^)-PrefixSeg ) , Ofs(Adresse^) );
end;

function YetInstalled( var IDStr : string ) : word;
type MCB       = record
                   IdCode : char;
                   PSP : word;
                   Paras : word;
                 end;
     MCBPTR    = ^MCB;
     MCBPTRPTR = ^MCBPTR;
     STRPTR    = ^string;
var Regs     : Registers;
    AktMCB   : MCBPTR;
    PSPFound : word;
    Ende     : boolean;
    StPtr    : ^string;
begin
  Regs.AH := $52;
  MsDos( Regs );
  AktMCB := MCBPTRPTR( ptr( Regs.ES, Regs.BX-4 ) )^;
  Ende     := FALSE;
  PSPFound := 0;
  repeat
    if ( STRPTR( GetPtr( @IDStr, AktMCB^.PSP ))^ = IDStr ) and
       ( AktMCB^.PSP <> PRefixSeg ) then
      PSPFound := AktMCB^.PSP;
    if ( AktMCB^.IDCode = 'Z' ) then
      Ende := TRUE
    else
      AktMCB := ptr( Seg(AktMCB^) + AktMCB^.Paras + 1, 0 );
  until ( PSPFound <> 0 ) or Ende;
  YetInstalled := PSPFound;
end;

procedure CheckAndInit;
type ZZ  = ^pointer;
var
    Regs           : Registers;
    AktPtr         : pointer;
    PrgSeg, VioSeg : word;
    i              : byte;
    Install        : boolean;
    Parameter      : string;
begin
  Install := TRUE;
  if ( Install = TRUE ) then
    begin
      Regs.ah := 15;
      intr($10, Regs);
      PrgSeg := YetInstalled( PrgID );
      if ( PrgSeg = 0 ) then
        begin
          GetIntVec( TimeInt, OldTimer );
          SetIntVec( TimeInt, @Speaker_aus);
          writeln( 'SPEAKOFF was installed.' );
          writeln( 'a 2. call will remove it from memory.');
          Keep(0);
        end
      else
        if ( ParamCount = 0 ) then
          begin
            GetIntVec( TimeInt, AktPtr );
            if ( AktPtr = GetPtr( @Speaker_aus, PrgSeg ) ) then
              begin
                SetIntVec( TimeInt, ZZ( GetPtr( @OldTimer, PrgSeg ))^ );
                Regs.AH := $49;
                Regs.ES := PSPP( ptr( PrgSeg, 0) )^.EnvSeg;
                MsDos( Regs );
                Regs.AH := $49;
                Regs.ES := PrgSeg;
                MsDos( Regs );
                writeln( 'SPEAKOFF removed from memory.' );
              end
            else
              writeln( 'SPEAKOFF cannot be removed, another tsr ',
                       'found above.' );
          end;
    end;
end;

begin
  CheckAndInit;
end.

{ end of code }




