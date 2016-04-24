(*
  Category: SWAG Title: RECORD RELATED ROUTINES
  Original name: 0007.PAS
  Description: VARIANT.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:55
*)

{* Program that works!
** Shows use of Variant Records.
** roleplaying Type implemented.
*}
Uses Crt;
Type
  CharType = (Warrior, Wizard);
  CharacterType = Record
                    Name: String[16];
                    Health, MaxHealth: Integer;
                    Char: CharType;
                    Case CharType of
                      Warrior: ( DamagetoHit: Integer);
                      Wizard : ( Spell, MaxSpell: Integer);
                  end;

Var
  Character: CharacterType;
  S: String;

begin

  { select Character Type }
  Writeln;
  Writeln('Select Character Type:');
  Writeln(' [ 1 ] Warrior');
  Writeln(' [ 2 ] Wizard');
  Readln(S);

  With Character do
   begin
     if S = '1' then Character.Char := Warrior else
       Character.Char := Wizard;

     { set fixed Variables }
     Write('Enter Character name: ');
     Readln(Name);
     Write('Enter Character health value: ');
     Readln(MaxHealth);
     Health := MaxHealth;
     { set Variant Variables }
     Case Char of
       Warrior: begin
                  Write('Enter ', Name, '''s hit value: ');
                  Readln(Character.DamagetoHit);
                end;
       Wizard:  begin
                  Write('Enter ', Name, '''s spell value: ');
                  Readln(MaxSpell);
                  Spell := MaxSpell;
                end;
     end;
   end;

  With Character do     { display Character info }
    begin
      { fixed Variables }
      Writeln;
      Writeln('*** Your Character:');
      Writeln('    Name: ', Name);
      Writeln('  Health: ', Health,'/',MaxHealth);
      { Variant Variables }
      Case Char of
        Warrior: Writeln('     Hit: ', DamagetoHit);
        Wizard:  Writeln('   Spell: ', Spell, '/', MaxSpell);
      end;
    end;
end.

