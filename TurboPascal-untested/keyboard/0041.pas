{ ROB PERELMAN }

Unit KeyStats;

Interface

Function RightShift : Boolean;
Function LeftShift  : Boolean;
Function Control    : Boolean;
Function Alt        : Boolean;
Function ScrollLock : Boolean;
Function NumLock    : Boolean;
Function CapsLock   : Boolean;
Function Insert     : Boolean;

Implementation

Uses
  Dos;

Function ShiftState : Byte;
Var
  Regs : Registers;
begin
  Regs.Ah := 2;
  Intr($16, Regs);
  ShiftState := Regs.Al;
end;

Function RightShift : Boolean;
begin
  RightShift := (ShiftState and 1) <> 0;
end;

Function LeftShift : Boolean;
begin
  LeftShift := (ShiftState and 2) <> 0;
end;

Function Control : Boolean;
begin
  Control := (ShiftState and 4) <> 0;
end;

Function Alt : Boolean;
begin
  Alt := (ShiftState and 8) <> 0;
end;

Function ScrollLock : Boolean;
begin
  ScrollLock := (ShiftState and 16) <> 0;
end;

Function NumLock : Boolean;
begin
  NumLock := (ShiftState and 32) <> 0;
end;

Function CapsLock : Boolean;
begin
  CapsLock := (ShiftState and 64) <> 0;
end;

Function Insert : Boolean;
begin
  Insert := (ShiftState and 128) <> 0;
end;

end.
