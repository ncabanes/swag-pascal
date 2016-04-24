(*
  Category: SWAG Title: MATH ROUTINES
  Original name: 0023.PAS
  Description: Math Conversion Unit
  Author: GAYLE DAVIS
  Date: 07-17-93  07:28
*)

{ MATH Unit for various conversions }
{$DEFINE Use8087}  { define this for EXTENDED 8087 floating point math }

UNIT MATH;

{$IFDEF Use8087}
{$N+}
{$ELSE
{$N-}
{$ENDIF}

INTERFACE

TYPE
    {$IFDEF Use8087}
    FLOAT = EXTENDED;
    {$ELSE}
    FLOAT = REAL;
    {$ENDIF}

FUNCTION  FahrToCent(FahrTemp: FLOAT): FLOAT;
FUNCTION  CentToFahr(CentTemp: FLOAT): FLOAT;
FUNCTION  KelvToCent(KelvTemp: FLOAT): FLOAT;
FUNCTION  CentToKelv(CentTemp: FLOAT): FLOAT;
PROCEDURE InchToFtIn(Inches: FLOAT; VAR ft,ins: FLOAT);
FUNCTION  FtInToInch(ft,ins: FLOAT): FLOAT;
FUNCTION  InchToYard(Inches: FLOAT): FLOAT;
FUNCTION  YardToInch(Yards: FLOAT): FLOAT;
FUNCTION  InchToMile(Inches: FLOAT): FLOAT;
FUNCTION  MileToInch(Miles: FLOAT): FLOAT;
FUNCTION  InchToNautMile(Inches: FLOAT): FLOAT;
FUNCTION  NautMileToInch(NautMiles: FLOAT): FLOAT;
FUNCTION  InchToMeter(Inches: FLOAT): FLOAT;
FUNCTION  MeterToInch(Meters: FLOAT): FLOAT;
FUNCTION  SqInchToSqFeet(SqInches: FLOAT): FLOAT;
FUNCTION  SqFeetToSqInch(SqFeet: FLOAT): FLOAT;
FUNCTION  SqInchToSqYard(SqInches: FLOAT): FLOAT;
FUNCTION  SqYardToSqInch(SqYards: FLOAT): FLOAT;
FUNCTION  SqInchToSqMile(SqInches: FLOAT): FLOAT;
FUNCTION  SqMileToSqInch(SqMiles: FLOAT): FLOAT;
FUNCTION  SqInchToAcre(SqInches: FLOAT): FLOAT;
FUNCTION  AcreToSqInch(Acres: FLOAT): FLOAT;
FUNCTION  SqInchToSqMeter(SqInches: FLOAT): FLOAT;
FUNCTION  SqMeterToSqInch(SqMeters: FLOAT): FLOAT;
FUNCTION  CuInchToCuFeet(CuInches: FLOAT): FLOAT;
FUNCTION  CuFeetToCuInch(CuFeet: FLOAT): FLOAT;
FUNCTION  CuInchToCuYard(CuInches: FLOAT): FLOAT;
FUNCTION  CuYardToCuInch(CuYards: FLOAT): FLOAT;
FUNCTION  CuInchToCuMeter(CuInches: FLOAT): FLOAT;
FUNCTION  CuMeterToCuInch(CuMeters: FLOAT): FLOAT;
FUNCTION  FluidOzToPint(FluidOz: FLOAT): FLOAT;
FUNCTION  PintToFluidOz(Pints: FLOAT): FLOAT;
FUNCTION  FluidOzToImpPint(FluidOz: FLOAT): FLOAT;
FUNCTION  ImpPintToFluidOz(ImpPints: FLOAT): FLOAT;
FUNCTION  FluidOzToGals(FluidOz: FLOAT): FLOAT;
FUNCTION  GalsToFluidOz(Gals: FLOAT): FLOAT;
FUNCTION  FluidOzToImpGals(FluidOz: FLOAT): FLOAT;
FUNCTION  ImpGalsToFluidOz(ImpGals: FLOAT): FLOAT;
FUNCTION  FluidOzToCuMeter(FluidOz: FLOAT): FLOAT;
FUNCTION  CuMeterToFluidOz(CuMeters: FLOAT): FLOAT;
PROCEDURE OunceToLbOz(Ounces: FLOAT; VAR lb,oz: FLOAT);
FUNCTION  LbOzToOunce(lb,oz: FLOAT): FLOAT;
FUNCTION  OunceToTon(Ounces: FLOAT): FLOAT;
FUNCTION  TonToOunce(Tons: FLOAT): FLOAT;
FUNCTION  OunceToLongTon(Ounces: FLOAT): FLOAT;
FUNCTION  LongTonToOunce(LongTons: FLOAT): FLOAT;
FUNCTION  OunceToGram(Ounces: FLOAT): FLOAT;
FUNCTION  GramToOunce(Grams: FLOAT): FLOAT;



IMPLEMENTATION

{ Temperature conversion }

FUNCTION FahrToCent(FahrTemp: FLOAT): FLOAT;

    BEGIN
        FahrToCent:=(FahrTemp+40.0)*(5.0/9.0)-40.0;
    END;


FUNCTION CentToFahr(CentTemp: FLOAT): FLOAT;

    BEGIN
        CentToFahr:=(CentTemp+40.0)*(9.0/5.0)-40.0;
    END;


FUNCTION KelvToCent(KelvTemp: FLOAT): FLOAT;

    BEGIN
        KelvToCent:=KelvTemp-273.16;
    END;


FUNCTION CentToKelv(CentTemp: FLOAT): FLOAT;

    BEGIN
        CentToKelv:=CentTemp+273.16;
    END;



{ Linear measurement conversion }

PROCEDURE InchToFtIn(Inches: FLOAT; VAR ft,ins: FLOAT);

    BEGIN
        ft:=INT(Inches/12.0);
        ins:=Inches-ft*12.0;
    END;


FUNCTION FtInToInch(ft,ins: FLOAT): FLOAT;

    BEGIN
        FtInToInch:=ft*12.0+ins;
    END;


FUNCTION InchToYard(Inches: FLOAT): FLOAT;

    BEGIN
        InchToYard:=Inches/36.0;
    END;


FUNCTION YardToInch(Yards: FLOAT): FLOAT;

    BEGIN
        YardToInch:=Yards*36.0;
    END;


FUNCTION InchToMile(Inches: FLOAT): FLOAT;

    BEGIN
        InchToMile:=Inches/63360.0;
    END;


FUNCTION MileToInch(Miles: FLOAT): FLOAT;

    BEGIN
        MileToInch:=Miles*63360.0;
    END;


FUNCTION InchToNautMile(Inches: FLOAT): FLOAT;

    BEGIN
        InchToNautMile:=Inches/72960.0;
    END;


FUNCTION NautMileToInch(NautMiles: FLOAT): FLOAT;

    BEGIN
        NautMileToInch:=NautMiles*72960.0;
    END;


FUNCTION InchToMeter(Inches: FLOAT): FLOAT;

    BEGIN
        InchToMeter:=Inches*0.0254;
    END;


FUNCTION MeterToInch(Meters: FLOAT): FLOAT;

    BEGIN
        MeterToInch:=Meters/0.0254;
    END;



{ Area conversion }

FUNCTION SqInchToSqFeet(SqInches: FLOAT): FLOAT;

    BEGIN
        SqInchToSqFeet:=SqInches/144.0;
    END;


FUNCTION SqFeetToSqInch(SqFeet: FLOAT): FLOAT;

    BEGIN
        SqFeetToSqInch:=SqFeet*144.0;
    END;


FUNCTION SqInchToSqYard(SqInches: FLOAT): FLOAT;

    BEGIN
        SqInchToSqYard:=SqInches/1296.0;
    END;


FUNCTION SqYardToSqInch(SqYards: FLOAT): FLOAT;

    BEGIN
        SqYardToSqInch:=SqYards*1296.0;
    END;


FUNCTION SqInchToSqMile(SqInches: FLOAT): FLOAT;

    BEGIN
        SqInchToSqMile:=SqInches/4.0144896E9;
    END;


FUNCTION SqMileToSqInch(SqMiles: FLOAT): FLOAT;

    BEGIN
        SqMileToSqInch:=SqMiles*4.0144896E9;
    END;


FUNCTION SqInchToAcre(SqInches: FLOAT): FLOAT;

    BEGIN
        SqInchToAcre:=SqInches/6272640.0;
    END;


FUNCTION AcreToSqInch(Acres: FLOAT): FLOAT;

    BEGIN
        AcreToSqInch:=Acres*6272640.0;
    END;


FUNCTION SqInchToSqMeter(SqInches: FLOAT): FLOAT;

    BEGIN
        SqInchToSqMeter:=SqInches/1550.016;
    END;


FUNCTION SqMeterToSqInch(SqMeters: FLOAT): FLOAT;

    BEGIN
        SqMeterToSqInch:=SqMeters*1550.016;
    END;



{ Volume conversion }

FUNCTION CuInchToCuFeet(CuInches: FLOAT): FLOAT;

    BEGIN
        CuInchToCuFeet:=CuInches/1728.0;
    END;


FUNCTION CuFeetToCuInch(CuFeet: FLOAT): FLOAT;

    BEGIN
        CuFeetToCuInch:=CuFeet*1728.0;
    END;


FUNCTION  CuInchToCuYard(CuInches: FLOAT): FLOAT;

    BEGIN
        CuInchToCuYard:=CuInches/46656.0;
    END;


FUNCTION  CuYardToCuInch(CuYards: FLOAT): FLOAT;

    BEGIN
        CuYardToCuInch:=CuYards*46656.0;
    END;


FUNCTION  CuInchToCuMeter(CuInches: FLOAT): FLOAT;

    BEGIN
        CuInchToCuMeter:=CuInches/61022.592;
    END;


FUNCTION  CuMeterToCuInch(CuMeters: FLOAT): FLOAT;

    BEGIN
        CuMeterToCuInch:=CuMeters*61022.592;
    END;


{ Liquid measurement conversion }

FUNCTION FluidOzToPint(FluidOz: FLOAT): FLOAT;

    BEGIN
        FluidOzToPint:=FluidOz/16.0;
    END;


FUNCTION PintToFluidOz(Pints: FLOAT): FLOAT;

    BEGIN
        PintToFluidOz:=Pints*16.0;
    END;


FUNCTION FluidOzToImpPint(FluidOz: FLOAT): FLOAT;

    BEGIN
        FluidOzToImpPint:=FluidOz/20.0;
    END;


FUNCTION ImpPintToFluidOz(ImpPints: FLOAT): FLOAT;

    BEGIN
        ImpPintToFluidOz:=ImpPints*20.0;
    END;


FUNCTION FluidOzToGals(FluidOz: FLOAT): FLOAT;

    BEGIN
        FluidOzToGals:=FluidOz/128.0;
    END;


FUNCTION GalsToFluidOz(Gals: FLOAT): FLOAT;

    BEGIN
        GalsToFluidOz:=Gals*128.0;
    END;


FUNCTION FluidOzToImpGals(FluidOz: FLOAT): FLOAT;

    BEGIN
        FluidOzToImpGals:=FluidOz/160.0;
    END;


FUNCTION ImpGalsToFluidOz(ImpGals: FLOAT): FLOAT;

    BEGIN
        ImpGalsToFluidOz:=ImpGals*160.0;
    END;


FUNCTION  FluidOzToCuMeter(FluidOz: FLOAT): FLOAT;

    BEGIN
         FluidOzToCuMeter:=FluidOz/33820.0;
    END;


FUNCTION CuMeterToFluidOz(CuMeters: FLOAT): FLOAT;

    BEGIN
        CuMeterToFluidOz:=CuMeters*33820.0;
    END;


{ Weight conversion }

PROCEDURE OunceToLbOz(Ounces: FLOAT; VAR lb,oz: FLOAT);

    BEGIN
        lb:=INT(Ounces/16.0);
        oz:=Ounces-lb*16.0;
    END;


FUNCTION LbOzToOunce(lb,oz: FLOAT): FLOAT;

    BEGIN
        LbOzToOunce:=lb*16.0+oz;
    END;


FUNCTION OunceToTon(Ounces: FLOAT): FLOAT;

    BEGIN
        OunceToTon:=Ounces/32000.0;
    END;


FUNCTION TonToOunce(Tons: FLOAT): FLOAT;

    BEGIN
        TonToOunce:=Tons*32000.0;
    END;


FUNCTION OunceToLongTon(Ounces: FLOAT): FLOAT;

    BEGIN
        OunceToLongTon:=Ounces/35840.0;
    END;


FUNCTION LongTonToOunce(LongTons: FLOAT): FLOAT;

    BEGIN
        LongTonToOunce:=LongTons*35840.0;
    END;


FUNCTION OunceToGram(Ounces: FLOAT): FLOAT;

    BEGIN
        OunceToGram:=Ounces*28.35;
    END;


FUNCTION GramToOunce(Grams: FLOAT): FLOAT;

    BEGIN
        GramToOunce:=Grams/28.35;
    END;


END.


