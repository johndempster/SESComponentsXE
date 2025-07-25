unit Maths;
{ =====================================================
  Mathematical function library (c) J. Dempster 1998-99
  =====================================================
 16/8/98 TProb & ZProb added
 V2.0 19/1/99 ... MathFunc object now includes curve fitting
 2/8/99 ... Exponential3,EPC,HHK,HHNa functions added
 2/9/99 ... x/y axis scaling for FitCurve disabled for exponential prob. density functions
 21/3/00 GetEquation Now returns ParFixed state correctly
 22/3/00 Exponential function time constants now forced positive in equation
 8/8/00  Bug in MINV fixed which was returning incorrect parameter SDs
 19/1/01 Residual standard deviation now scaled correctly
 22/1/01 Decaying exponential functions added to curve fitter
 18/6/01 Module now shared with WinWCP and located in Components folder
         4 and 5 exponential PDF functions added
 17/7/01 SSQMIN workspace increased and exceed check established
 8/8/01 ExtractFloat added
 22/3/02 SSQMIN now allocates work buffer of appropriate size
 23/7/03 HTMLColorString function added
 8/9/03 Minor change to LinearRegression zero divide limit
 15/11/03 Special characters removed from curve fit parameter names
 13/9/04  MathFunc.CopyResultsToRichEdit temp file now saved in prog. dir.
 15/4/10 EPC2EXP function added
 20/4/11 Initial guesses for gaussian fits improved (usinfg GaussianGuess function)
 9/7/14 Temporary file name now created using TPath.GetTempFileName()
 5/1/18 RoundToNearestMultiple() function added
 29.05.25 SSQMIN: GoodFit=False if if any best fit parameters is NAN or INF
          TMathFunc.Value() Now returns zero if any parameter NAN or INF
 }



interface

uses classes, comctrls, graphics, math, strutils, system.ioutils, Printers, windows, VCL.grids ;

const
     ChannelLimit = 15 ;
     LastParameter = 10 ;
     MaxBuf = 32768 ;
     MaxWork = 9999999 ;

type
    TWorkArray = Array[0..MaxWork] of Single ;

    TBin = record
         Lo : Single ;
         Mid : Single ;
         Hi :  Single ;
         y : Single ;
         end ;

THistogram = class(TObject)
              StartAt : LongInt ;
              EndAt : LongInt ;
              RecordStart : LongInt ;
              RangeLo : single ;
              RangeHi : Single ;
              NumBins : Integer ;
              NumLogBinsPerDecade : Integer ;
              MaxBin : Integer ;
              Bins : Array[0..2048] of TBin ;
              TotalCount : single ;
              Available : Boolean ;
            {  Equation : TEquation ;}
{              UnitCursor : THistCursorPos ;}
              yHi : Single ;
              BinWidth : single ;
              BinScale : single ;
              TMin : single ;
              NewPlot : Boolean ;
              end ;


    TEqnType = ( None,
                 Lorentzian,
                 Lorentzian2,
                 LorAndOneOverF,
                 Linear,
                 Parabola,
                 Exponential,
                 Exponential2,
                 Exponential3,
                 MEPCNoise,
                 EPC,
                 HHK,
                 HHNa,
                 Gaussian,
                 Gaussian2,
                 Gaussian3,
                 PDFExp,
                 PDFExp2,
                 PDFExp3,
                 PDFExp4,
                 PDFExp5,
                 Quadratic,
                 Cubic,
                 DecayingExp,
                 DecayingExp2,
                 DecayingExp3,
                 Boltzmann,
                 DecayingExp2A,
                 DecayingExp3A,
                 EPC2EXP ) ;

    TXYData = record
        x : Array[0..MaxBuf] of Single ;
        y : Array[0..MaxBuf] of Single ;
        BinWidth : Array[0..MaxBuf] of Single ;
        end ;
    PXYData = ^TXYData ;
    TEquation = packed record
          Available : Boolean ;
          EqnType : TEqnType ;
          Channel : Integer ;
          Par : Array[0..LastParameter] of Single ;
          ParSD : Array[0..LastParameter] of Single ;
          ParFixed : Array[0..LastParameter] of Boolean ;
          ParametersSet : Boolean ;
          Cursor0 : Integer ;
          Cursor1 : Integer ;
          TZeroCursor : Integer ;
          ResidualSD : Single ;
          DegreesFreedom : Integer ;
          NumIterations : Integer ;
          UseBinWidths : Boolean ;
          Average : Array[0..ChannelLimit] of Single ;
          end ;

    TPars = record
          Value : Array[0..LastParameter+1] of Single ;
          SD : Array[0..LastParameter+1] of Single ;
          Map : Array[0..LastParameter+1] of Integer ;
          end ;

    TMathFunc = Class(TObject)
              private
                  XUnits : string ;
                  YUnits : string ;
                  FEqnType : TEqnType ;
                  Pars : Array[0..LastParameter] of single ;

                  { Curve fitting }
                  AbsPars : Array[0..LastParameter] of boolean ;
                  LogPars : Array[0..LastParameter] of boolean ;
                  FixedPars : Array[0..LastParameter] of boolean ;
                  ParameterScaleFactors : Array[0..LastParameter] of single ;
                  ResidualSDScaleFactor : single ;
                  ParSDs : Array[0..LastParameter] of single ;
                  ParsSet : Boolean ;              { Initial parameters set for fit }
                  Normalised : boolean ;           { Data normalised }
                  UseBinWidthsFlag : Boolean ;     { Use histogram bin widths in fit }
                  ResidualSDValue : single ;       { Residual standard deviation }
                  RValue : single ;                { Hamilton's R }
                  DegreesOfFreedomValue : Integer ; { Statistical deg's of freedom }
                  IterationsValue : Integer ;    { No. of iterations for fit }
                  GoodFitFlag : Boolean ;
                  function GetNumParameters : Integer ;
                  function GetParameter(
                           Index : Integer
                           ) : single ;
                  function GetParameterSD(
                           Index : Integer
                           ) : single ;

                  function GetLogParameter(
                           Index : Integer
                           ) : boolean ;
                  procedure SetParameter(
                            Index : Integer ;
                            Value : single
                            ) ;
                  procedure SetFixed(
                            Index : Integer ;
                            Fixed : Boolean
                            ) ;
                  function GetFixed(
                           Index : Integer
                           ) : Boolean ;

                  function GetParName (
                           Index : Integer
                           ) : string ;
                  function GetParUnits(
                           Index : Integer
                           ) : string ;
                  function GetEquationType : TEqnType ;
                  function GetName : string ;
                  procedure ScaleData(
                            var Data : TXYData ;
                            nPoints : LongInt
                            );
                  procedure UnScaleParameters ;
                  procedure FitFunc(
                            Const FitPars :TPars ;
                            nPoints : Integer ;
                            nPars : Integer ;
                            Var Residuals : Array of Single ;
                            iStart : Integer ;
                            Const Data : TXYData
                            ) ;
                  function SSQCAL(
                           const Pars : TPars ;
                           nPoints : Integer ;
                           nPars : Integer ;
                           var Residuals : Array of Single ;
                           iStart : Integer ;
                           const W : Array of Single ;
                           const Data : TXYData
                           ) : Single ;
                  procedure STAT(
                            nPoints : Integer ;
                            nPars : Integer ;
                            var F : Array of Single ;
                            var Y : Array of Single ;
                            var W : Array of Single ;
                            var SLT : Array of Single ;
                            var SSQ : Single;
                            var SDPars : Array of Single ;
                            var SDMIN : Single ;
                            var R : Single ;
                            var XPAR : Array of Single
                            ) ;
                  procedure SsqMin (
                            var Pars : TPars ;
                            nPoints,nPars,ItMax,NumSig,NSiqSq : LongInt ;
                            Delta : Single ;
                            var W,SLTJJ : Array of Single ;
                            var ICONV,ITER : LongInt ;
                            var SSQ : Single ;
                            var F : Array of Single ;
                            Const Data : TXYData
                            ) ;
                  procedure GaussianGuess(
                  const X : Array of Single ;
                  const Y : Array of Single ;
                  NumPoints : Integer ;
                  NumGaussians : Integer ;
                  var Guess : Array of Single ) ;

              published
                  property Equation : TEqnType Read GetEquationType ;
                  Property NumParameters : Integer Read GetNumParameters ;
                  Property ParametersSet : Boolean read ParsSet write ParsSet ;
                  property GoodFit : Boolean read GoodFitFlag ;
                  property DegreesOfFreedom : Integer
                           read DegreesOfFreedomValue ;
                  property R : single read RValue;
                  property Iterations : Integer
                           read IterationsValue ;
                  property ResidualSD : single
                           read ResidualSDValue ;
                  property UseBinWidths : Boolean
                           read UseBinWidthsFlag write UseBinWidthsFlag ;
                  property Name : string
                           read GetName ;
              public

                  property Parameters[i : Integer] : single
                           read GetParameter write SetParameter ;
                  property ParameterSDs[i : Integer] : single
                           read GetParameterSD ;

                  property IsLogParameters[i : Integer] : boolean
                           read GetLogParameter ;
                  property FixedParameters[i : Integer] : boolean
                           read GetFixed write SetFixed ;

                  property ParNames[i : Integer] : string
                           read GetParName ;
                  property ParUnits[i : Integer] : string
                           read GetParUnits ;

              procedure Setup(
                        NewEqnType : TEqnType ;
                        NewXUnits : string ;
                        NewYUnits : string
                        ) ;
              Procedure SetupNormalisation(
                        xScale : single ;
                        yScale : single
                        ) ;
              function NormaliseParameter(
                       Index : Integer ;
                       Value : single
                       ) : single ;
              function DenormaliseParameter(
                       Index : Integer ;
                       Value : single
                       ) : single ;
              function InitialGuess(
                        const Data : TXYData ;   { Data set to be fitted }
                        nPoints : Integer ;      { No. of points }
                        Index : Integer          { Function parameter No. }
                        ) : single ;
              function Value(
                       X : Single                   { X (IN) }
                       ) : Single ;                 { Return f(X) }
              procedure FitCurve(
                        var Data : TXYData ;         { Data to be fitted to }
                        nPoints : LongInt            { No. of data points }
                        ) ;
              function GetEquation : TEquation ;
              procedure SetEquation( NewEquation : TEquation ) ;
              procedure CopyResultsToRichEdit(
                        Results : TStringList ;
                        RE : TRichEdit ) ;

              end ;


function ExtractFloat ( CBuf : string ; Default : Single) : single ;
function ExtractDouble ( CBuf : string ; Default : Double ) : Double ;
function MinInt( const Buf : array of LongInt ) : LongInt ;
function MinFlt( const Buf : array of Single ) : Single ;
function MaxInt( const Buf : array of LongInt ) : LongInt ;
function MaxFlt( const Buf : array of Single ) : Single ;
function Log10( const x : Single ) : Single;
function AntiLog10( const x : single ) : Single ;
function GaussianRandom( var GSet : Single ) : Single ;
function Power( x,y : Single ) : Single ;
function IntLimitTo( Value, LowerLimit, UpperLimit : Integer ) : Integer ;
function LongIntLimitTo( Value, LowerLimit, UpperLimit : LongInt ) : LongInt ;
function FloatLimitTo( Value, LowerLimit, UpperLimit : Single ) : Single ;
function MakeMultiple( Value, Factor,Step : Integer ) : Integer ;
procedure RealFFT( var Data : Array of single ; n : Integer ; ISign : Integer ) ;
procedure Fourier1( var Data : Array of Single ; NN : Integer ; ISign : Integer ) ;
procedure Sort( var SortBuf, LinkedBuf : Array of single ; nPoints : Integer ) ;
function FProb( F : single ; m : Integer ; n : Integer ) : single ;
function ZProb( ZIn : single ) : single ;
function TProb( T : single ; Nf : Integer ) : single ;
function SafeExp( x : single ) : single ;
function FindNearest( const Buf : Array of Single ;
                      nPoints : Integer ;
                      TargetValue : single ) : Integer ;
function Erf(x : Single ) : Single ;
procedure MINV(
          var A : Array of Single ;
          N : LongInt ;
          var D : Single ;
          var L,M : Array of LongInt
          ) ;
FUNCTION SQRT1 (
         R : single
         ) : single ;
function LinearRegression(
         x : Array of Single ;    // X data points (IN)
         y : Array of Single ;    // Y data points (IN)
         n : Integer ;            // No. of (X,Y) data points in line
         var Slope : Single ;     // Slope of line (OUT)
         var YIntercept : Single  // Y intercept (OUT)
         ) : Boolean ;


procedure PDFExpNames(
          var ParNames : Array of String ;
          nExp : Integer ) ;

procedure PDFExpUnits(
          var ParUnits : Array of String ;
          XUnits : String ;
          nExp : Integer ) ;

procedure PDFExpScaling(
          var AbsPars : Array of Boolean ;
          var LogPars : Array of Boolean ;
          var ParameterScaleFactors : Array of Single ;
          yScale : Single ;
          nExp : Integer ) ;

function PDFExpFunc(
         Pars : Array of single ;
         nExp : Integer ;
         X : Single ) : Single ;

function GaussianFunc(
         Pars : Array of single ;
         nGaus : Integer ;
         X : Single ) : Single ;

function HTMLColorString( Color : TColor ) : String ;

procedure Spline(
         var X : Array of Single ;
         var Y : Array of Single ;
         N : Integer ;
         var Y2 : Array of Single
         ) ;

procedure Splint(
          var XA : Array of Single ;
          var YA : Array of Single ;
          var Y2A : Array of Single ;
          N : Integer ;
          X : Single ;
          Y : Single ) ;

function RoundToNearestMultiple(
         Value : Double ;
         Factor : Double ) : Double ;

  function ExtractListOfFloats (
           const CBuf : string ;
           var Values : Array of Single ;
           PositiveOnly : Boolean
           ) : Integer ;
  function ExtractInt (
           CBuf : string
           ) : LongInt ;
  function VerifyInt(
           text : string ;
           LoLimit,HiLimit : LongInt
           ) : string ;

function PrinterPointsToPixels(
         PointSize : Integer
         ) : Integer ;
function PrinterCmToPixels(
         const Axis : string ;
         cm : single
         ) : Integer ;


implementation

uses SysUtils,dialogs ;



  const
     MaxSingle = 1E38 ;


function ExtractFloat (
         CBuf : string ;     { ASCII text to be processed }
         Default : Single    { Default value if text is not valid }
         ) : single ;
{ -------------------------------------------------------------------
  Extract a floating point number from a string which
  may contain additional non-numeric text
  28/10/99 ... Now handles both comma and period as decimal separator
  -------------------------------------------------------------------}

var
   CNum,dsep : string ;
   i : integer ;
   Done,NumberFound : Boolean ;
begin
     { Extract number from othr text which may be around it }

     if CBuf = '' then begin
        Result := Default ;
        Exit ;
        end ;

     CNum := '' ;
     Done := False ;
     NumberFound := False ;
     i := 1 ;
     repeat
         if CBuf[i] in ['0'..'9', 'E', 'e', '+', '-', '.', ',' ] then begin
            CNum := CNum + CBuf[i] ;
            NumberFound := True ;
            end
         else if NumberFound then Done := True ;
         Inc(i) ;
         if i > Length(CBuf) then Done := True ;
         until Done ;

     { Correct for use of comma/period as decimal separator }
     {$IF CompilerVersion > 7.0} dsep := formatsettings.DECIMALSEPARATOR ;
     {$ELSE} dsep := DECIMALSEPARATOR ;
     {$IFEND}
     if dsep = '.' then CNum := ANSIReplaceText(CNum ,',',dsep);
     if dsep = ',' then CNum := ANSIReplaceText(CNum, '.',dsep);

     if not TryStrToFloat(cNum,Result) then Result := Default ;

     { Convert number from ASCII to real }
{     try
        if Length(CNum)>0 then ExtractFloat := StrToFloat( CNum )
                          else ExtractFloat := Default ;
     except
        on E : EConvertError do ExtractFloat := Default ;
        end ;}
     end ;


function ExtractDouble (
         CBuf : string ;     { ASCII text to be processed }
         Default : Double    { Default value if text is not valid }
         ) : Double ;
{ -------------------------------------------------------------------
  Extract a floating point number from a string which
  may contain additional non-numeric text and store in double variable
  28/10/99 ... Now handles both comma and period as decimal separator

  -------------------------------------------------------------------}

var
   CNum,dsep : string ;
   i : integer ;
   Done,NumberFound : Boolean ;
begin
     { Extract number from othr text which may be around it }

     if CBuf = '' then begin
        Result := Default ;
        Exit ;
        end ;

     CNum := '' ;
     Done := False ;
     NumberFound := False ;
     i := 1 ;
     repeat
         if CBuf[i] in ['0'..'9', 'E', 'e', '+', '-', '.', ',' ] then begin
            CNum := CNum + CBuf[i] ;
            NumberFound := True ;
            end
         else if NumberFound then Done := True ;
         Inc(i) ;
         if i > Length(CBuf) then Done := True ;
         until Done ;

     { Correct for use of comma/period as decimal separator }
     {$IF CompilerVersion > 7.0} dsep := formatsettings.DECIMALSEPARATOR ;
     {$ELSE} dsep := DECIMALSEPARATOR ;
     {$IFEND}
     if dsep = '.' then CNum := ANSIReplaceText(CNum ,',',dsep);
     if dsep = ',' then CNum := ANSIReplaceText(CNum, '.',dsep);

     if not TryStrToFloat(cNum,Result) then Result := Default ;

     { Convert number from ASCII to real }
{     try
        if Length(CNum)>0 then ExtractFloat := StrToFloat( CNum )
                          else ExtractFloat := Default ;
     except
        on E : EConvertError do ExtractFloat := Default ;
        end ;}
     end ;



{ -------------------------------------------
  Return the smallest value in the array 'Buf'
  -------------------------------------------}
function MinInt(
         const Buf : array of LongInt { List of numbers (IN) }
         ) : LongInt ;                { Returns Minimum of Buf }
var
   i,Min : LongInt ;
begin
     Min := High(Min) ;
     for i := 0 to High(Buf) do
         if Buf[i] < Min then Min := Buf[i] ;
     Result := Min ;
     end ;


{ ---------------------------------------------------------
  Return the smallest value in the floating point  array 'Buf'
  ---------------------------------------------------------}
function MinFlt(
         const Buf : array of Single { List of numbers (IN) }
         ) : Single ;                 { Returns minimum of Buf }
var
   i : Integer ;
   Min : Single ;
begin
     Min := MaxSingle ;
     for i := 0 to High(Buf) do
         if Buf[i] < Min then Min := Buf[i] ;
     Result := Min ;
     end ;


{ ---------------------------------------------------------
  Return the largest long integer value in the array 'Buf'
  ---------------------------------------------------------}
function MaxInt(
         const Buf : array of LongInt  { List of numbers (IN) }
         ) : LongInt ;                 { Returns maximum of Buf }
var
   Max : LongInt ;
   i : Integer ;
begin
     Max:= -High(Max) ;
     for i := 0 to High(Buf) do
         if Buf[i] > Max then Max := Buf[i] ;
     Result := Max ;
     end ;


{ ---------------------------------------------------------
  Return the largest floating point value in the array 'Buf'
  ---------------------------------------------------------}
function MaxFlt(
         const Buf : array of Single { List of numbers (IN) }
         ) : Single ;                { Returns maximum of Buf }
var
   i : Integer ;
   Max : Single ;
begin
     Max:= -MaxSingle ;
     for i := 0 to High(Buf) do
         if Buf[i] > Max then Max := Buf[i] ;
     Result := Max ;
     end ;


function Log10(
         const x : Single
         ) : Single ;
{ -----------------------------------
  Return the logarithm (base 10) of x
  -----------------------------------}
begin
     Log10 := ln(x) / ln(10. ) ;
     end ;


function AntiLog10(
         const x : single
         )  : Single ;
{ ---------------------------------------
  Return the antilogarithm (base 10) of x
  ---------------------------------------}
begin
     AntiLog10 := exp( x * ln( 10. ) ) ;
     end ;


function GaussianRandom
         ( var GSet : Single
         ) : Single ;
{ -------------------------------------------------------------
  Return a random variable (-1..1) from a gaussian distribution
  -------------------------------------------------------------}
var
        v1,v2,r,fac : Single ;
begin
	if GSet = 1. then begin
            repeat
	          v1 := 2.0*random - 1.0 ;
	          v2 := 2.0*random - 1.0 ;
	          r := v1*v1 + v2*v2 ;
                  until r < 1.0 ;
	    fac := sqrt( -2.0*ln(r)/r);
	    gset := v1*fac ;
	    GaussianRandom := v2*fac ;
            end
	else begin
             GaussianRandom := gset ;
             gset := 1.0 ;
             end ;
	end ;


function Power(
         x,y : Single
         ) : Single ;
{ ----------------------------------
  Calculate x to the power y (x^^y)
  ----------------------------------}
begin
     if x > 0. then Power := exp( ln(x)*y )
               else Power := 0. ;
     end ;


{ -------------------------------------------------------------------
  Make sure Value is kept within the limits LowerLimit and UpperLimit
  -------------------------------------------------------------------}
function FloatLimitTo(
         Value : single ;      { Value to be tested (IN) }
         LowerLimit : Single ; { Lower limit (IN) }
         UpperLimit : Single   { Upper limit (IN) }
         ) : Single ;          { Return limited Value }
begin
     if Value < LowerLimit then Value := LowerLimit ;
     if Value > UpperLimit then Value := UpperLimit ;
     Result := Value ;
     end ;


{ -------------------------------------------------------------------
  Make sure Value is kept within the limits LowerLimit and UpperLimit
  -------------------------------------------------------------------}
function IntLimitTo(
         Value : Integer ;       { Value to be tested (IN) }
         LowerLimit : Integer ;  { Lower limit (IN) }
         UpperLimit : Integer    { Upper limit (IN) }
         ) : Integer ;           { Return limited Value }
begin
     if Value < LowerLimit then Value := LowerLimit ;
     if Value > UpperLimit then Value := UpperLimit ;
     Result := Value ;
     end ;


function LongIntLimitTo( Value, LowerLimit, UpperLimit : LongInt ) : LongInt ;
{ -------------------------------------------------------------------
  Make sure Value is kept within the limits LowerLimit and UpperLimit
  -------------------------------------------------------------------}
begin
     if Value < LowerLimit then Value := LowerLimit ;
     if Value > UpperLimit then Value := UpperLimit ;
     Result := Value ;
     end ;

function MakeMultiple( Value, Factor,Step : Integer ) : Integer ;
{ -------------------------------------------------------
  Return nearest (and smaller) integer to "Value" which is
  a multiple of "Factor"
  -------------------------------------------------------}
begin
     Result := (((Value-1) div Factor)+Step)*Factor ;
     end ;


procedure RealFFT(
          var Data : Array of single ; { Data to be transformed (In/Out)}
          n : Integer ;                { No. of data points (IN) }
          ISign : Integer              { 1=FTT, -1,Reverse FFT (IN) }
          ) ;
{
C	Calculates the FFT of a set of 2N real data points. Replaces
C	this data (in array DATA) by the positive frequency half of its
C	complex Fourier Transform. The real-valued first and last components
C	of the complex transform are returned as elements DATA(1) and DATA(2)
C	respectively. N must be a power of 2.
C	from page 400 ... Numerical Recipes
C}
var
   WR,WI,WPR,WPI,WTEMP,Theta,C1,C2,WRS,WIS,H1R,H1I,H2R,H2I : double ;
   I,I1,I2,I3,I4,N2P3 : Integer ;
begin

     Theta := ( 6.28318530717959/2.0 )/ N ;
     C1 := 0.5 ;

     IF ISign = 1  THEN begin
        { Set up for forward transform }
        C2 := -0.5 ;
        Fourier1( Data, N, 1) ;
        end
     ELSE begin
        { Set up for inverse transform }
        C2 := 0.5 ;
        Theta := -Theta ;
        end ;

     WPR := SIN( 0.5 * Theta ) ;
     WPR := -2.0*WPR*WPR ;
     WPI := SIN( Theta ) ;
     WR := 1. + WPR ;
     WI := WPI ;
     N2P3 := 2*N + 3 ;

     for I := 2 to ( (N div 2) + 1) do begin
           I1 := 2*I - 1 ;
           I2 := I1 + 1 ;
           I3 := N2P3 - I2 ;
           I4 := I3 + 1 ;

           WRS := (WR) ;
           WIS := (WI) ;

           H1R :=  C1*( Data[I1] + Data[I3] ) ;
           H1I :=  C1*( Data[I2] - Data[I4] ) ;
           H2R := -C2*( Data[I2] + Data[I4] ) ;
           H2I :=  C2*( Data[I1] - Data[I3] ) ;

           Data[I1] :=  H1R + WRS*H2R - WIS*H2I ;
           Data[I2] :=  H1I + WRS*H2I + WIS*H2R ;
           Data[I3] :=  H1R - WRS*H2R + WIS*H2I ;
           Data[I4] := -H1I + WRS*H2I + WIS*H2R ;

           WTEMP := WR ;
           WR := WR*WPR - WI*WPI + WR ;
           WI := WI*WPR + WTEMP*WPI + WI ;
           end ;

     IF ISign = 1 THEN begin
        H1R := Data[1] ;
        Data[1] := H1R + Data[2] ;
        Data[2] := H1R - Data[2] ;
        end
     ELSE begin
        H1R := Data[1] ;
        Data[1] := C1*(H1R + Data[2]) ;
        Data[2] := C1*(H1R - Data[2]) ;
        Fourier1( Data, N, -1 ) ;
        end ;
     end ;


procedure Fourier1(
          var Data : Array of Single ;
          NN : Integer ;
          ISign : Integer
          ) ;

{	Replace Data by its discrete Fourier transform, if ISIGN
C	is input as 1, or replaces Data by NN times its inverse DFT
C	if ISIGN is input as -1. Data is a complex array of length NN
C	or, equivalently a REAL array of length 2*NN. NN must be an
C	integer power of 2 }
var
	WR,WI,WPR,WPI,WTEMP,Theta, TempR, TempI : double ;
        I,J,N,M,MMax,IStep : Integer ;
begin
	N := 2*NN ;

	{ Do bit-reversal }
	J := 1 ;
        i := 1 ;
        while i <= n do begin
            IF J > I  THEN begin
               { Exchange complex numbers }
               TEMPR := Data[J] ;
               TEMPI := Data[J+1] ;
               Data[J] := Data[I] ;
               Data[J+1] := Data[I+1] ;
               Data[I] := TEMPR ;
               Data[I+1] := TEMPI ;
               end ;
            M := N div 2 ;

            while (M >= 2) and (J > M) do begin
                  J := J - M ;
                  M := M div 2 ;
                  end ;
            J := J + M ;
            i := i + 2 ;
            end ;

	MMAX := 2 ;
	while  N > MMAX  do begin
               ISTEP := 2*MMAX ;
               Theta := 6.28318530717959 / (ISIGN*MMAX) ;
               WPR := SIN(0.5*Theta) ;
               WPR := -2.0*WPR*WPR ;
               WPI := SIN(Theta) ;
               WR := 1.0 ;
               WI := 0.0 ;
               M := 1 ;
               while M <= MMAX do begin
                        I := M ;
                        while I <= N do begin
				J := I + MMAX ;
				TEMPR := WR*Data[J] - WI*Data[J+1] ;
				TEMPI := WR*Data[J+1] + WI*Data[J] ;
				Data[J] := Data[I] - TEMPR ;
				Data[J+1] := Data[I+1] - TEMPI ;
				Data[I] := Data[I] + TEMPR ;
				Data[I+1] := Data[I+1] + TEMPI ;
                                I := I + ISTEP ;
                                end ;
			WTEMP := WR ;
			WR := WR*WPR - WI*WPI + WR ;
			WI := WI*WPR + WTEMP*WPI + WI ;
                        M := M + 2 ;
                        end ;
               MMAX := ISTEP ;
               end ;
        end ;


{ -------------------------------------------------------------
  Sort array "SortBuf" containing "nPoints" data points
  into ascending order. Move matching samples in "LinkedBuf"
  to same array positions
  -------------------------------------------------------------}
procedure Sort(
          var SortBuf, LinkedBuf : Array of single ;
          nPoints : Integer
          ) ;
var
   Current,Last : Integer ;
   Temp : single ;
begin
     for Last := (nPoints-1) DownTo 1 do begin
         for Current := 0 to Last-1 do begin
             if SortBuf[Current] >  SortBuf[Current+1] then begin
                Temp := SortBuf[Current] ;
                SortBuf[Current] := SortBuf[Current+1] ;
                SortBuf[Current+1] := Temp ;
                Temp := LinkedBuf[Current] ;
                LinkedBuf[Current] := LinkedBuf[Current+1] ;
                LinkedBuf[Current+1] := Temp ;
                end ;
             end ;
         end ;
     end ;


function FProb(
         F : single ;    // F statistics
         m : Integer ;   // Numerator degrees of freedom
         n : Integer     // Denominator degrees of freedom
         ) : single ;
//
// Calculate F distribution tail probability of F >= F(m,n)
// Added 7/7/01
var
   Z,p,q,TwoThirds,c,A,B : Single ;
   NN,S,T : Integer ;
begin

    // Compute equivalent normal distribution Z score with same tail probability as F
    // (Using Peizer-Pratt approximation from
    // page 344, Elements of Statistical Computing R.A. Thistead, Chapman & Hall, 1988)

    if F < 0.1 then F := 0.1 ;
    TwoThirds := 2.0 / 3.0 ;
    S := n - 1 ;
    T := m - 1 ;
    NN := S + T ;
    p := n / (m*F + n) ;
    q := 1.0 - p ;
    c := 0.08*( q/n + p/m + (q-0.5)/(n+m) ) ;
    A := (n - TwoThirds - (NN + TwoThirds)*p + c) / Abs( S - NN*p) ;
    B := ((3*NN)/(3*NN+1))*(S*ln(S/(NN*p)) + T*ln(T/(NN*q))) ;
    Z := A*sqrt(B) ;

    // Compute tail probability
    if Z > 0.0 then Result := ZProb(Z)
               else Result := 1.0 - ZProb(-Z) ;

    end ;


function ZProb( ZIn : single ) : single ;
{ ---------------------------------------------------------------------
  Calculate probability p(z>=ZIn) for normal probability density function
  using Applied Statistics algorithm AS66 (I.D. Hill, 1985)
  Enter with : ZIn = Z value
  ---------------------------------------------------------------------}
var
   b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12 : double ;
   dz,Temp,Prob : Double ;
begin
     { Constants used in approximation equation }
     b1 := 0.398942280385 ;
     b2 := 3.8052E-8 ;
     b3 := 1.00000615302 ;
     b4 := 3.98064794E-4 ;
     b5 := 1.98615381364 ;
     b6 := 0.151679116635 ;
     b7 := 5.29330324926 ;
     b8 := 4.8385912808 ;
     b9 := 15.1508972451 ;
     b10 := 0.742380924027 ;
     b11 := 30.789933034 ;
     b12 := 3.99019417011 ;
     { Calculate probabilty }
     dz := ZIn ;
     Temp := b11 / ( dz + b12 ) ;
     Temp := b9  / ( dz + b10 + Temp ) ;
     Temp := b7  / ( dz + b8 - Temp ) ;
     Temp := b5  / ( dz - b6 + Temp ) ;
     Temp := b3  / ( dz + b4 + Temp ) ;
     Prob := (b1*exp( -dz*dz*0.5 ) ) / ( dz - b2 + Temp ) ;
     Result := Prob ;
     end ;


function TProb( T : single ; Nf : Integer ) : single ;
{ ---------------------------------------------------------------------
  Calculate probability p(t>=TIn,Nf) for T probability density function
  Enter with : TIn = T value
               Nf = degrees of freedom
  ---------------------------------------------------------------------}
var
   dbT, dbNf : double ;
   Z, Prob : single ;
begin
     dbT := T ;
     dbNf := Nf ;
     Z := ( dbNf - (2./3. ) + (0.1/dbNf) ) *
            sqrt( (1./(dbNf - 5./6. )) * ln( 1. + (dbT*dbT)/dbNf ) );
     Prob := ZProb( Z ) ;
     Result := Prob ;
     end ;


function SafeExp( x : single ) : single ;
{ -------------------------------------------------------
  Exponential function which avoids underflow errors for
  large negative values of x
  -------------------------------------------------------}
const
     MinSingle = 1.5E-45 ;
var
   MinX : single ;
begin
     MinX := ln(MinSingle) + 1.0 ;
     if x < MinX then SafeExp := 0.0
                 else SafeExp := exp(x) ;
     end ;


function FindNearest( const Buf : Array of Single ;      { Array to be searched }
                      nPoints : Integer ;                { No. of points in Buf}
                      TargetValue : single ) : Integer ; { Search value }

{ ---------------------------------------------------------
  Find the nearest value in array "Buf" (size "nPoints")
  to "TargetValue". Return its index as the function result
  ---------------------------------------------------------}
var
   MinDiff : single ;
   i,NearestIndex : Integer ;
begin
     MinDiff := 1E30 ;
     NearestIndex := 0 ;
     for i := 0 to nPoints-1 do begin
         if Abs(Buf[i] - TargetValue) <= MinDiff then begin
            NearestIndex := i ;
            MinDiff := Abs(Buf[i] - TargetValue) ;
            end ;
         end ;
     Result := NearestIndex ;
     end ;

{ ------------------------------
  Select the equation to be used
  ------------------------------}
procedure TMathFunc.Setup(
          NewEqnType : TEqnType ;  { Equation type }
          NewXUnits : string ;     { X units }
          NewYUnits : string       { Y units }
          ) ;
begin
     FEqnType := NewEqnType ;
     XUnits := NewXUnits ;
     YUnits := NewYUnits ;
     end ;


{ -------------------------------
  Get the formula of the equation
  -------------------------------}
function TMathFunc.GetName ;
var
   Name : string ;
begin
     Case FEqnType of
          Lorentzian : Name := ' y(f) = S^-0/(1 + (f/f^-c)^+2 )' ;
          Lorentzian2 : Name := ' y(f) = S^-1/(1 + (f/f^-c^-1)^+2 + S^-2/(1 + (f/f^-c^-2)^+2)' ;
          LorAndOneOverF : Name := ' y(f) = S^-1/(1 + (f/F^-c^-1)^+2 + S^-/(f^+2) )' ;
          Linear : Name := ' y(x) = Mx + C' ;
          Parabola : Name := ' y(x) = V^-b + I^-ux - x^+2/N^-c ' ;
          Exponential : Name := ' y(t) = Aexp(-t/^st) + Ss ' ;
          Exponential2 : Name := ' y(t) = A^-1exp(-t/^st^-11) + A^-2exp(-t/^st^-2) + Ss ' ;
          Exponential3 : Name :=
          'y(t) = A^-1exp(-t/^st^-11) + A^-2exp(-t/^st^-2) + A^-3exp(-t/^st^-3)+ Ss ' ;
          EPC : Name := ' y(t) = A0.5(1+erf(x-x^-0)/^st^-R)exp(-(x-x^-0)/^st^-D))' ;
          EPC2EXP : Name := ' y(t) = (1+erf(x-x^-0)/^st^-R)(A^-1exp(-(x-x^-0)/^st^-1)A^-2exp(-(x-x^-0)/^st^-2)))' ;
          MEPCNoise : Name := ' y(f) = A/[1+(f^+2(1/F^-r^+2 + 1/F^-d^+2))+f^+4/(F^-r^+2F^-d^+2)]' ;
          HHK : Name := ' y(t) = A(1 - exp(-t/^st^-M)^+P' ;
          HHNa : Name := ' y(t) = A[(1 - exp(-t/^st^-M)^+P][H^-i^-n^-f - (H^-i^-n^-f-1)exp(-t/^st^-H)]' ;
          Gaussian : Name := ' y(x) = Pkexp(-(x-^sm)^+2/(2^ss^+2) )' ;
          Gaussian2 : Name := ' y(x) = ^sS^-i^-=^-1^-.^-.^-2 Pk^-iexp(-(x-^sm^-i)^+2/(2^ss^-i^+2) )' ;
          Gaussian3 : Name := ' y(x) = ^sS^-i^-=^-1^-.^-.^-3 Pk^-iexp(-(x-^sm^-i)^+2/(2^ss^-i^+2) )' ;
          PDFExp : Name := ' y(t) = (A/^st)exp(-t/^st)' ;
          PDFExp2 : Name := ' p(t) = ^sS^-i^-=^-1^-.^-.^-2 (A^-i/^st^-i)exp(-t/^st^-i)' ;
          PDFExp3 : Name := ' p(t) = ^sS^-i^-=^-1^-.^-.^-3 (A^-i/^st^-i)exp(-t/^st^-i)' ;
          PDFExp4 : Name := ' p(t) = ^sS^-i^-=^-1^-.^-.^-4 (A^-i/^st^-i)exp(-t/^st^-i)' ;
          PDFExp5 : Name := ' p(t) = ^sS^-i^-=^-1^-.^-.^-5 (A^-i/^st^-i)exp(-t/^st^-i)' ;
          Quadratic : Name := ' y(x) = Ax^+2 + Bx + C' ;
          Cubic : Name := 'y (x) = Ax^+3 + Bx^+2 + Cx + D' ;
          DecayingExp : Name := ' y(t) = Aexp(-t/^st)' ;
          DecayingExp2 : Name := ' y(t) = A^-1exp(-t/^st^-1) + A^-2exp(-t/^st^-2)' ;
          DecayingExp3 : Name :=
          ' y(t) = A^-1exp(-t/^st^-11) + A^-2exp(-t/^st^-2) + A^-3exp(-t/^st^-3)' ;
          Boltzmann : Name :=  'y(x) = y^-a^-m^-p / (1 + exp( -(x-x^-1^-/^-2)/x^-s^-l^-p)) + y^-m^-i^-n' ;
          DecayingExp2A : Name := ' y(t) = A[B^-1exp(-t/^st^-1) + (1-B^-1)exp(-t/^st^-2)]' ;
          else Name := 'None' ;
          end ;
     Result := Name ;
     end ;


procedure TMathFunc.CopyResultsToRichEdit(
          Results : TStringList ;
          RE : TRichEdit ) ;
var
   OutList : TStringList ;
   i,j : Integer ;
   InText,OutText,FontTable : string[255] ;
   Done : Boolean ;
   TempFileName : String ;
begin

     OutList := TStringList.Create ;

     try

        OutList.Add( '{\rtf1\ansi\deff0' ) ;

        // Create RTF font table
        FontTable := '{\fonttbl'
                  + format('{\f0\fcharset0 %s;}',[RE.DefAttributes.Name])
                  + '{\f1\fs24\fcharset2 Symbol;}'
                  + '}' ;
        OutList.Add( FontTable ) ;

        // Set default font size
        OutList.Add( format('\viewkind4\uc1\pard\fs%d',[2*RE.DefAttributes.Size]) ) ;

        for i := 0 to Results.Count-1 do begin
            Done := False ;
            j := 1 ;
            InText := Results.Strings[i] ;
            OutText := '{' ;
            while not Done do begin
                if InText[j] = '^' then begin
                   OutText := OutText + '}{' ;
                   Inc(j) ;
                   case InText[j] of
                     // Bold
                     'b' : begin
                         OutText := OutText + '\b ' + InText[j+1] + '}{';
                         Inc(j) ;
                         end ;
                     // Italic
                     'i' : begin
                         OutText := OutText + '\i ' + InText[j+1] + '}{';
                         Inc(j) ;
                         end ;
                     // Subscript
                     '-' : begin
                         OutText := OutText + '\sub ' + InText[j+1] + '}{';
                         Inc(j) ;
                         end ;
                     // Superscript
                     '+' : begin
                         OutText := OutText + '\super ' + InText[j+1] + '}{';
                         Inc(j) ;
                         end ;
                     // Superscripted 2
                     '2' : begin
                         OutText := OutText + '\super 2}{';
                         end ;

                     // Greek letter from Symbol character set
                     's' : begin
                         OutText := OutText + '\f1 ' + InText[j+1] + '}{';
                         Inc(j) ;
                         end ;
                     // Square root symbol
                     '!' : begin
                         OutText := OutText + '\f1\''d6}{';
                         end ;
                     // +/- symbol
                     '~' : begin
                         OutText := OutText + '\f1\''b1}{';
                         end ;

                     end ;
                   end
                else OutText := OutText + InText[j] ;
                Inc(j) ;
                if j > Length(InText) then Done := True ;
                end ;

            OutText := OutText + '\par}' ;
            OutList.Add(OutText) ;
            end ;

        // Add last line and closing bracket
        OutList.Add('\par}') ;
//        TempFileName := ExtractFilePath(ParamStr(0)) + 'temp.rtf' ;
        TempFileName := TPath.GetTempFileName ;
        OutList.SaveToFile( TempFileName ) ;
        RE.Lines.LoadFromFile( TempFileName ) ;

     finally
        OutList.Free ;
        end ;

     end ;


{ -------------------------------
  Get the type of equation in use
  -------------------------------}
function TMathFunc.GetEquationType : TEqnType ;
begin
     Result := FEqnType ;
     end ;


function TMathFunc.GetNumParameters ;
{ ------------------------------------
  Get number of parameters in equation
  ------------------------------------}
var
   nPars : Integer ;
begin
     Case FEqnType of
          Lorentzian : nPars := 2 ;
          Lorentzian2 : nPars := 4 ;
          LorAndOneOverF : nPars := 3 ;
          Linear : nPars := 2 ;
          Parabola : nPars := 3 ;
          Exponential : nPars := 3 ;
          Exponential2 : nPars := 5 ;
          Exponential3 : nPars := 7 ;
          EPC : nPars := 4 ;
          EPC2EXP : nPars := 6 ;
          HHK : nPars := 3 ;
          HHNa : nPars := 5 ;
          MEPCNoise : nPArs := 3 ;
          Gaussian : nPars := 3 ;
          Gaussian2 : nPars := 6 ;
          Gaussian3 : nPars := 9 ;
          PDFExp : nPars := 2 ;
          PDFExp2 : nPars := 4 ;
          PDFExp3 : nPars := 6 ;
          PDFExp4 : nPars := 8 ;
          PDFExp5 : nPars := 10 ;
          Quadratic : nPars := 3 ;
          Cubic : nPars := 4 ;
          DecayingExp : nPars := 2 ;
          DecayingExp2 : nPars := 4 ;
          DecayingExp3 : nPars := 6 ;
          Boltzmann : nPars := 4 ;
          DecayingExp2A : nPars := 4 ;

          else nPars := 0 ;
          end ;
     Result := nPars ;
     end ;

{ ----------------------------
  Get function parameter value
  ----------------------------}
function TMathFunc.GetParameter(
         Index : Integer
         ) : single ;
begin
     Index := IntLimitTo(Index,0,GetNumParameters-1) ;
     Result := Pars[Index] ;
     end ;


{ -----------------------------------------
  Get function parameter standard deviation
  -----------------------------------------}
function TMathFunc.GetParameterSD(
         Index : Integer
         ) : single ;
begin
     Index := IntLimitTo(Index,0,GetNumParameters-1) ;
     Result := ParSDs[Index] ;
     end ;


{ --------------------------------------
  Read the parameter log transform array
  --------------------------------------}
function TMathFunc.GetLogParameter(
         Index : Integer
         ) : boolean ;
begin
     Index := IntLimitTo(Index,0,GetNumParameters-1) ;
     Result := LogPars[Index] ;
     end ;


{ --------------------------------------
  Read the parameter fixed/unfixed array
  --------------------------------------}
function TMathFunc.GetFixed(
         Index : Integer
         ) : boolean ;
begin
     Index := IntLimitTo(Index,0,GetNumParameters-1) ;
     Result := FixedPars[Index] ;
     end ;

{ --------------------------------------
  Set the parameter fixed/unfixed array
  --------------------------------------}
procedure TMathFunc.SetFixed(
         Index : Integer ;
         Fixed : Boolean
         ) ;
begin
     Index := IntLimitTo(Index,0,GetNumParameters-1) ;
     FixedPars[Index] := Fixed ;
     end ;



{ -----------------------------
  Set function parameter value
  -----------------------------}
procedure TMathFunc.SetParameter(
          Index : Integer ;
          Value : single
          ) ;
begin
     Index := IntLimitTo(Index,0,GetNumParameters-1) ;
     Pars[Index] := Value ;
     end ;


{ ---------------------------
  Get the name of a parameter
  ---------------------------}
function TMathFunc.GetParName(
         Index : Integer  { Parameter index number (IN) }
         ) : string ;
var
   ParNames : Array[0..LastParameter] of string ;
begin
     Case FEqnType of
          Lorentzian : begin
                 ParNames[0] := 'S0' ;
                 ParNames[1] := 'fc' ;
                 end ;
          Lorentzian2 : begin
                 ParNames[0] := 'S0.1' ;
                 ParNames[1] := 'fc.1' ;
                 ParNames[2] := 'S0.2' ;
                 ParNames[3] := 'fc.2' ;
                 end ;
          LorAndOneOverF : begin
                 ParNames[0] := 'S0.1' ;
                 ParNames[1] := 'fc.1' ;
                 ParNames[2] := 'S0.2' ;
                 end ;
          Linear : begin
                 ParNames[0] := 'C' ;
                 ParNames[1] := 'M' ;
                 end ;
          Parabola : begin
                 ParNames[0] := 'I.u' ;
                 ParNames[1] := 'N.c' ;
                 ParNames[2] := 'V.b' ;
                 end ;
          Exponential : begin
                 ParNames[0] := 'A' ;
                 ParNames[1] := 'tau' ;
                 ParNames[2] := 'Ss' ;
                 end ;
          Exponential2 : begin
                 ParNames[0] := 'A.1' ;
                 ParNames[1] := 'tau.1' ;
                 ParNames[2] := 'A.2' ;
                 ParNames[3] := 'tau.2' ;
                 ParNames[4] := 'Ss' ;
                 end ;
          Exponential3 : begin
                 ParNames[0] := 'A.1' ;
                 ParNames[1] := 'tau.1' ;
                 ParNames[2] := 'A.2' ;
                 ParNames[3] := 'tau.2' ;
                 ParNames[4] := 'A.3' ;
                 ParNames[5] := 'tau.3' ;
                 ParNames[6] := 'Ss' ;
                 end ;
          EPC : begin
                 ParNames[0] := 'A' ;
                 ParNames[1] := 'x.0' ;
                 ParNames[2] := 'tau.r' ;
                 ParNames[3] := 'tau.d' ;
                 end ;
          EPC2EXP : begin
                 ParNames[0] := 'x.0' ;
                 ParNames[1] := 'tau.r' ;
                 ParNames[2] := 'A.1' ;
                 ParNames[3] := 'tau.1' ;
                 ParNames[4] := 'A.2' ;
                 ParNames[5] := 'tau.2' ;
                 end ;
          HHK : begin
                 ParNames[0] := 'A' ;
                 ParNames[1] := 'tau.m' ;
                 ParNames[2] := 'P' ;
                 end ;
          HHNa : begin
                 ParNames[0] := 'A' ;
                 ParNames[1] := 'tau.m' ;
                 ParNames[2] := 'P' ;
                 ParNames[3] := 'h.inf' ;
                 ParNames[4] := 'tau.h' ;
                 end ;
          MEPCNoise : begin
                 ParNames[0] := 'A' ;
                 ParNames[1] := 'F.d' ;
                 ParNames[2] := 'F.r' ;
                 end ;
          Gaussian : begin
                 ParNames[0] := 'Mean' ;
                 ParNames[1] := 's.d.' ;
                 ParNames[2] := 'Peak' ;
                 end ;
          Gaussian2 : begin
                 ParNames[0] := 'Mean.1' ;
                 ParNames[1] := 's.d.1' ;
                 ParNames[2] := 'Peak.1' ;
                 ParNames[3] := 'Mean.2' ;
                 ParNames[4] := 's.d.2' ;
                 ParNames[5] := 'Peak.2' ;
                 end ;
          Gaussian3 : begin
                 ParNames[0] := 'Mean.1' ;
                 ParNames[1] := 's.d.1' ;
                 ParNames[2] := 'Peak.1' ;
                 ParNames[3] := 'Mean.2' ;
                 ParNames[4] := 's.d.2' ;
                 ParNames[5] := 'Peak.2' ;
                 ParNames[6] := 'Mean.3' ;
                 ParNames[7] := 's.d.3' ;
                 ParNames[8] := 'Peak.3' ;
                 end ;

          PDFExp : PDFExpNames( ParNames, 1 ) ;

          PDFExp2 : PDFExpNames( ParNames, 2 ) ;

          PDFExp3 : PDFExpNames( ParNames, 3 ) ;

          PDFExp4 : PDFExpNames( ParNames, 4 ) ;

          PDFExp5 : PDFExpNames( ParNames, 5 ) ;

          Quadratic : begin
                 ParNames[0] := 'C' ;
                 ParNames[1] := 'B' ;
                 ParNames[2] := 'A' ;
                 end ;
          Cubic : begin
                 ParNames[0] := 'D' ;
                 ParNames[1] := 'C' ;
                 ParNames[2] := 'B' ;
                 ParNames[3] := 'A' ;
                 end ;

          DecayingExp : begin
                 ParNames[0] := 'A' ;
                 ParNames[1] := 'tau' ;
                 end ;
          DecayingExp2 : begin
                 ParNames[0] := 'A.1' ;
                 ParNames[1] := 'tau.1' ;
                 ParNames[2] := 'A.2' ;
                 ParNames[3] := 'tau.2' ;
                 end ;
          DecayingExp3 : begin
                 ParNames[0] := 'A.1' ;
                 ParNames[1] := 'tau.1' ;
                 ParNames[2] := 'A.2' ;
                 ParNames[3] := 'tau.2' ;
                 ParNames[4] := 'A.3' ;
                 ParNames[5] := 'tau.3' ;
                 end ;

          Boltzmann : begin
                 ParNames[0] := 'y^-a^-m^-p' ;
                 ParNames[1] := 'x^-1^-/^-2' ;
                 ParNames[2] := 'x^-s^-l^-p' ;
                 ParNames[3] := 'y^-m^-i^-n' ;
                 end ;

          DecayingExp2A : begin
                 ParNames[0] := 'A' ;
                 ParNames[1] := 'tau.1' ;
                 ParNames[2] := 'B.1' ;
                 ParNames[3] := 'tau.2' ;
                 end ;

          else begin
               end ;
          end ;
     if (Index >= 0) and (Index < GetNumParameters) then begin
        Result := ParNames[Index] ;
        end
     else Result := '?' ;
     end ;


procedure PDFExpNames(
          var ParNames : Array of String ;
          nExp : Integer ) ;
{ --------------------------------
  Exponential PDF parameter names
  -------------------------------- }
var
   i : Integer ;
begin
     for i := 0 to nExp-1 do begin
         ParNames[2*i] := format('A^-%d',[i+1]) ;
         ParNames[2*i+1] := format('^st^-%d',[i+1]) ;
         end ;
     end ;

{ ---------------------------
  Get the units of a parameter
  ---------------------------}
function TMathFunc.GetParUnits(
         Index : Integer  { Parameter index number (IN) }
         ) : string ;
var
   ParUnits : Array[0..LastParameter] of string ;
begin
     Case FEqnType of
          Lorentzian : begin
                 ParUnits[0] := YUnits + '^2' ;
                 ParUnits[1] := XUnits  ;
                 end ;
          Lorentzian2 : begin
                 ParUnits[0] := YUnits + '^2';
                 ParUnits[1] := XUnits  ;
                 ParUnits[2] := YUnits + '^2';
                 ParUnits[3] := XUnits  ;
                 end ;
          LorAndOneOverF : begin
                 ParUnits[0] := YUnits + '^2';
                 ParUnits[1] := XUnits  ;
                 ParUnits[2] := YUnits + '^2';
                 end ;
          Linear : begin
                 ParUnits[0] := YUnits  ;
                 ParUnits[1] := YUnits + '/' + XUnits ;
                 end ;
          Parabola : begin
                 ParUnits[0] := YUnits ;
                 ParUnits[1] := ' ' ;
                 ParUnits[2] := YUnits ;
                 end ;
          Exponential : begin
                 ParUnits[0] := YUnits ;
                 ParUnits[1] := XUnits  ;
                 ParUnits[2] := YUnits ;
                 end ;
          Exponential2 : begin
                 ParUnits[0] := YUnits ;
                 ParUnits[1] := XUnits  ;
                 ParUnits[2] := YUnits ;
                 ParUnits[3] := XUnits  ;
                 ParUnits[4] := YUnits ;
                 end ;
          Exponential3 : begin
                 ParUnits[0] := YUnits ;
                 ParUnits[1] := XUnits  ;
                 ParUnits[2] := YUnits ;
                 ParUnits[3] := XUnits  ;
                 ParUnits[4] := YUnits  ;
                 ParUnits[5] := XUnits ;
                 ParUnits[6] := YUnits ;
                 end ;
          EPC : begin
                 ParUnits[0] := YUnits ;
                 ParUnits[1] := XUnits ;
                 ParUnits[2] := XUnits ;
                 ParUnits[3] := XUnits ;
                 end ;
          EPC2EXP : begin
                 ParUnits[0] := XUnits ;
                 ParUnits[1] := XUnits ;
                 ParUnits[2] := YUnits ;
                 ParUnits[3] := XUnits ;
                 ParUnits[4] := YUnits ;
                 ParUnits[5] := XUnits ;
                 end ;
          HHK : begin
                 ParUnits[0] := YUnits ;
                 ParUnits[1] := XUnits ;
                 ParUnits[2] := '' ;
                 end ;
          HHNa : begin
                 ParUnits[0] := YUnits ;
                 ParUnits[1] := XUnits ;
                 ParUnits[2] := '' ;
                 ParUnits[3] := '' ;
                 ParUnits[4] := XUnits ;
                 end ;
          MEPCNoise : begin
                 ParUnits[0] := YUnits ;
                 ParUnits[1] := XUnits  ;
                 ParUnits[2] := XUnits ;
                 end ;
          Gaussian : begin
                 ParUnits[0] := XUnits ;
                 ParUnits[1] := XUnits  ;
                 ParUnits[2] := YUnits ;
                 end ;
          Gaussian2 : begin
                 ParUnits[0] := XUnits ;
                 ParUnits[1] := XUnits  ;
                 ParUnits[2] := YUnits ;
                 ParUnits[3] := XUnits ;
                 ParUnits[4] := XUnits  ;
                 ParUnits[5] := YUnits ;
                 end ;
          Gaussian3 : begin
                 ParUnits[0] := XUnits ;
                 ParUnits[1] := XUnits  ;
                 ParUnits[2] := YUnits ;
                 ParUnits[3] := XUnits ;
                 ParUnits[4] := XUnits  ;
                 ParUnits[5] := YUnits ;
                 ParUnits[6] := XUnits ;
                 ParUnits[7] := XUnits  ;
                 ParUnits[8] := YUnits ;
                 end ;

          PDFExp : PDFExpUnits( ParUnits, XUnits, 1 ) ;

          PDFExp2 : PDFExpUnits( ParUnits, XUnits, 2 ) ;

          PDFExp3 : PDFExpUnits( ParUnits, XUnits, 3 ) ;

          PDFExp4 : PDFExpUnits( ParUnits, XUnits, 4 ) ;

          PDFExp5 : PDFExpUnits( ParUnits, XUnits, 5 ) ;

          Quadratic : begin
                 ParUnits[0] := YUnits ;
                 ParUnits[1] := YUnits + '/' + XUnits ;
                 ParUnits[2] := YUnits + '/' + XUnits + '^2';
                 end ;

          Cubic : begin
                 ParUnits[0] := YUnits ;
                 ParUnits[1] := YUnits + '/' + XUnits ;
                 ParUnits[2] := YUnits + '/' + XUnits + '^2';
                 ParUnits[3] := YUnits + '/' + XUnits + '^3';
                 end ;

          DecayingExp : begin
                 ParUnits[0] := YUnits ;
                 ParUnits[1] := XUnits  ;
                 end ;

          DecayingExp2 : begin
                 ParUnits[0] := YUnits ;
                 ParUnits[1] := XUnits  ;
                 ParUnits[2] := YUnits ;
                 ParUnits[3] := XUnits  ;
                 end ;

          DecayingExp3 : begin
                 ParUnits[0] := YUnits ;
                 ParUnits[1] := XUnits  ;
                 ParUnits[2] := YUnits ;
                 ParUnits[3] := XUnits  ;
                 ParUnits[4] := YUnits  ;
                 ParUnits[5] := XUnits ;
                 end ;

          Boltzmann : begin
                 ParUnits[0] := YUnits ;
                 ParUnits[1] := XUnits  ;
                 ParUnits[2] := XUnits ;
                 ParUnits[3] := YUnits  ;
                 end ;

          DecayingExp2A : begin
                 ParUnits[0] := YUnits ;
                 ParUnits[1] := XUnits  ;
                 ParUnits[2] := '' ;
                 ParUnits[3] := XUnits  ;
                 end ;


          else begin
               end ;
          end ;
     if (Index >= 0) and (Index < GetNumParameters) then begin
        Result := ParUnits[Index] ;
        end
     else Result := '?' ;
     end ;


procedure PDFExpUnits(
          var ParUnits : Array of String ;
          XUnits : String ;
          nExp : Integer ) ;
{ --------------------------------
  Exponential PDF parameter units
  -------------------------------- }
var
   i : Integer ;
begin
     for i := 0 to nExp-1 do begin
         ParUnits[2*i] := '%' ;
         ParUnits[2*i+1] := XUnits ;
         end ;
     end ;



Function TMathFunc.GetEquation : TEquation ;
{ ---------------------------------------------------
  Get the parameters of the equation currently in use
  ---------------------------------------------------
  21/3/00 Now returns ParFixed state }
var
   i : Integer ;
begin
     Result.EqnType := FEqnType ;
     for i := 0 to GetNumParameters-1 do begin
         Result.Par[i] := Pars[i] ;
         Result.ParSD[i] := ParSDs[i] ;
         Result.ParFixed[i] := FixedPars[i] ;
         end ;
     end ;


Procedure TMathFunc.SetEquation(
          NewEquation : TEquation
          ) ;
{ ---------------------------------------------------
  Get the parameters of the equation currently in use
  --------------------------------------------------- }
var
   i : Integer ;
begin
     FEqnType := NewEquation.EqnType ;
     for i := 0 to GetNumParameters-1 do begin
         Pars[i] := NewEquation.Par[i] ;
         ParSDs[i] := NewEquation.ParSD[i] ;
         end ;
     end ;


Function TMathFunc.Value(
         X : Single                   { X (IN) }
         ) : Single ;                 { Return f(X) }
{ ---------------------
  Mathematical function
  ---------------------}
var
   Y,A,A1,A2,Theta1,Theta2 : Single ;
   iPar: Integer;
begin

     // Exit returning zero if any parameter is NAN or INF

     for iPar := 0 to GetNumParameters-1 do
         begin
           if IsNAN(Pars[iPar]) or IsInfinite(Pars[iPar]) then
              begin
              Result := 0.0 ;
              Exit ;
              end;

         end;

     Case FEqnType of

          Lorentzian : begin
             if Pars[1] <> 0.0 then begin
                A := X/Pars[1] ;
                Y := Pars[0] /( 1.0 + (A*A)) ;
                end
             else Y := 0.0 ;
             end ;

          Lorentzian2 : begin
             if (Pars[1] <> 0.0) and (Pars[3] <> 0.0)then begin
                A1 := X/Pars[1] ;
                A2 := X/Pars[3] ;
                Y := (Pars[0]/(1.0 + (A1*A1)))
                     + (Pars[2]/(1.0 + (A2*A2))) ;
                end
             else Y := 0.0 ;
             end ;

          LorAndOneOverF : begin
             if Pars[1] <> 0.0 then begin
                A := X/Pars[1] ;
                Y := (Pars[0] /( 1.0 + (A*A)))
                     + (Pars[2]/(X*X));
                end
             else Y := 0.0 ;
             end ;

          Linear : begin
             Y := Pars[0] + X*Pars[1] ;
             end ;

          Parabola : begin
             if Pars[1] <> 0.0 then begin
                Y :=  X*Pars[0]
                      - ((X*X)/Pars[1]) + Pars[2] ;
                end
             else Y := 0.0 ;
             end ;

          Exponential : begin
             Y := Pars[2] ;
             if Pars[1] <> 0.0 then Y := Y + Pars[0]*exp(-X/Abs(Pars[1])) ;
             end ;

          Exponential2 : begin
             Y := Pars[4];
             if Pars[1] <> 0.0 then Y := Y + Pars[0]*exp(-X/Abs(Pars[1])) ;
             if Pars[3] <> 0.0 then Y := Y + Pars[2]*exp(-X/Abs(Pars[3])) ;
             end ;

          Exponential3 : begin
             Y := Pars[6];
             if Pars[1] <> 0.0 then Y := Y + Pars[0]*exp(-X/Abs(Pars[1])) ;
             if Pars[3] <> 0.0 then Y := Y + Pars[2]*exp(-X/Abs(Pars[3])) ;
             if Pars[5] <> 0.0 then Y := Y + Pars[4]*exp(-X/Abs(Pars[5])) ;
             end ;

          EPC : begin
             if (Pars[2] <> 0.0) and (Pars[3] <> 0.0) then
                Y := Pars[0]*0.5*(1. + erf( (X-Pars[1])/Abs(Pars[2]) ))
                     *exp(-(X-Pars[1])/Abs(Pars[3]))
             else Y := 0.0 ;
             end ;

          EPC2EXP : begin
             if (Pars[1] <> 0.0) and (Pars[3] <> 0.0) and (Pars[5] <> 0.0) then
                Y := 0.5*(1. + erf( (X-Pars[0])/Abs(Pars[1]))) *
                     ( Pars[2]*exp(-(X-Pars[0])/Abs(Pars[3])) +
                       Pars[4]*exp(-(X-Pars[0])/Abs(Pars[5])) )
             else Y := 0.0 ;
             end ;

          HHK : begin
             if Pars[1] <> 0.0 then
                Y := Pars[0]*Power( 1. - exp(-x/Abs(Pars[1])),Abs(Pars[2]) )
             else Y := 0.0 ;
             end ;

          HHNa : begin
             if (Pars[1] <> 0.0) and (Pars[4] <> 0.0) then
                Y := (Pars[0]*Power( 1. - exp(-x/Abs(Pars[1])),Abs(Pars[2]) )) *
                     (Abs(Pars[3]) - (Abs(Pars[3]) - 1. )*exp(-x/Abs(Pars[4])) )
             else Y := 0.0 ;
             end ;

          MEPCNoise : begin
             if (Pars[1] <> 0.0) and (Pars[2] <> 0.0) then begin
                Theta2 := 1.0 / Pars[1] ;
                Theta1 := 1.0 / Pars[2] ;
                Y := (Pars[0]) /
                     (1.0 + (X*X*(Theta1*Theta1 + Theta2*Theta2))
                     + (X*X*X*X*Theta1*Theta1*Theta2*Theta2) ) ;
                end
             else Y := 0.0 ;
             end ;

          Gaussian : Y := GaussianFunc( Pars, 1, X ) ;
          Gaussian2 : Y := GaussianFunc( Pars, 2, X ) ;
          Gaussian3 : Y := GaussianFunc( Pars, 3, X ) ;

          PDFExp : Y := PDFExpFunc( Pars, 1, X ) ;
          PDFExp2 : Y := PDFExpFunc( Pars, 2, X ) ;
          PDFExp3 : Y := PDFExpFunc( Pars, 3, X ) ;
          PDFExp4 : Y := PDFExpFunc( Pars, 4, X ) ;
          PDFExp5 : Y := PDFExpFunc( Pars, 5, X ) ;

          Quadratic : begin
             Y := Pars[0] + X*Pars[1] + X*X*Pars[2] ;
             end ;
          Cubic : begin
             Y := Pars[0] + X*Pars[1] + X*X*Pars[2] + X*X*X*Pars[3] ;
             end ;

          DecayingExp : begin
             Y := 0.0 ;
             if Pars[1] <> 0.0 then Y := Y + Pars[0]*exp(-X/Abs(Pars[1])) ;
             end ;

          DecayingExp2 : begin
             Y := 0.0 ;
             if Pars[1] <> 0.0 then Y := Pars[0]*exp(-X/Abs(Pars[1])) ;
             if Pars[3] <> 0.0 then Y := Y + Pars[2]*exp(-X/Abs(Pars[3])) ;
             end ;

          DecayingExp3 : begin
             Y := 0.0 ;
             if Pars[1] <> 0.0 then Y := Y + Pars[0]*exp(-X/Abs(Pars[1])) ;
             if Pars[3] <> 0.0 then Y := Y + Pars[2]*exp(-X/Abs(Pars[3])) ;
             if Pars[5] <> 0.0 then Y := Y + Pars[4]*exp(-X/Abs(Pars[5])) ;
             end ;

          Boltzmann : begin
             if Pars[2] <> 0.0 then
                Y := Pars[0] / ( 1.0 + exp( (X - pars[1])/Pars[2])) + Pars[3]
             else Y := 0.0 ;
             end ;

          DecayingExp2A : begin
             Y := 0.0 ;
             if Pars[1] <> 0.0 then Y := Y + Pars[2]*exp(-X/Abs(Pars[1])) ;
             if Pars[3] <> 0.0 then Y := Y + (1.0-Pars[2])*exp(-X/Abs(Pars[3])) ;
             Y := Y*Pars[0] ;
             end ;

          else Y := 0. ;
          end ;

     Result := Y ;
     end ;

function PDFExpFunc(
         Pars : Array of single ;
         nExp : Integer ;
         X : Single ) : Single ;
{ ------------------------------------
  General exponential p.d.f. function
  ------------------------------------ }
var
   i,j : Integer ;
   y : Single ;
begin
     y := 0.0 ;
     for i := 0 to nExp-1 do begin
         j := 2*i ;
         if Pars[j+1] > 0.0 then y := y + Pars[j]/Pars[j+1]*SafeExp(-X/pars[j+1]) ;
         end ;
     Result := y ;
     end ;


function GaussianFunc(
         Pars : Array of single ;
         nGaus : Integer ;
         X : Single ) : Single ;
{ ------------------------------------
  Gaussian function
  ------------------------------------ }
var
   i,j : Integer ;
   z,Variance,y : Single ;
begin

     Y := 0.0 ;
     for i := 0 to nGaus-1 do begin
         j := 3*i ;
         z := X - Pars[j] ;
         Variance := Pars[j+1]*Pars[j+1] ;
         if Variance > 0.0 then Y := Y + Pars[j+2]*Exp( -(z*z)/(2.0*Variance) ) ;
         end ;
     Result := y ;
     end ;


{ --------------------------------------------------------
  Determine scaling factors necessary to adjust parameters
  for data normalised to range 0-1
  --------------------------------------------------------}
procedure TMathFunc.SetupNormalisation(
          xScale : single ;
          yScale : single
          ) ;
begin

     { Scaling factor for residual standard deviation }
     ResidualSDScaleFactor := yScale ;

    { Set values for each equation type }
     Case FEqnType of
          Lorentzian : begin
                 AbsPars[0] := True ;
                 LogPars[0] := False ;
                 ParameterScaleFactors[0] := yScale ;
                 AbsPars[1] := True ;
                 LogPars[1] := False ;
                 ParameterScaleFactors[1] := xScale ;
                 end ;
          Lorentzian2 : begin
                 AbsPars[0] := True ;
                 LogPars[0] := False ;
                 ParameterScaleFactors[0] := yScale ;

                 AbsPars[1] := True ;
                 LogPars[1] := False ;
                 ParameterScaleFactors[1] := xScale ;

                 AbsPars[2] := True ;
                 LogPars[2] := False ;
                 ParameterScaleFactors[2] := yScale ;

                 AbsPars[3] := True ;
                 LogPars[3] := False ;
                 ParameterScaleFactors[3] := xScale ;
                 end ;
           LorAndOneOverF : begin
                 AbsPars[0] := True ;
                 LogPars[0] := False ;
                 ParameterScaleFactors[0] := yScale ;

                 AbsPars[1] := True ;
                 LogPars[1] := False ;
                 ParameterScaleFactors[1] := xScale ;

                 AbsPars[2] := True ;
                 LogPars[2] := False ;
                 ParameterScaleFactors[2] := yScale ;
                 end ;
           Linear : begin

                 AbsPars[0] := False ;
                 LogPars[0] := False ;
                 ParameterScaleFactors[0] := yScale ;

                 AbsPars[1] := False ;
                 LogPars[1] := False ;
                 ParameterScaleFactors[1] := yScale/xScale ;

                 end ;
           Parabola : begin
                 AbsPars[0] := False ;
                 LogPars[0] := False ;
                 ParameterScaleFactors[0] := yScale/xScale ;

                 AbsPars[1] := True ;
                 LogPars[1] := False ;
                 ParameterScaleFactors[1] := (xScale*xScale)/yScale ;

                 AbsPars[2] := False ;
                 LogPars[2] := False ;
                 ParameterScaleFactors[2] := yScale ;
                 end ;

           Exponential : begin
                 AbsPars[0] := False ;
                 LogPars[0] := False ;
                 ParameterScaleFactors[0] := yScale ;

                 AbsPars[1] := True ;
                 LogPars[1] := False ;
                 ParameterScaleFactors[1] := xScale ;

                 AbsPars[2] := False ;
                 LogPars[2] := False ;
                 ParameterScaleFactors[2] := yScale ;
                 end ;

           Exponential2 : begin
                 AbsPars[0] := False ;
                 LogPars[0] := False ;
                 ParameterScaleFactors[0] := yScale ;

                 AbsPars[1] := True ;
                 LogPars[1] := False ;
                 ParameterScaleFactors[1] := xScale ;

                 AbsPars[2] := False ;
                 LogPars[2] := False ;
                 ParameterScaleFactors[2] := yScale ;

                 AbsPars[3] := True ;
                 LogPars[3] := False ;
                 ParameterScaleFactors[3] := xScale ;

                 AbsPars[4] := False ;
                 LogPars[4] := False ;
                 ParameterScaleFactors[4] := yScale ;
                 end ;

           Exponential3 : begin
                 AbsPars[0] := False ;
                 LogPars[0] := False ;
                 ParameterScaleFactors[0] := yScale ;

                 AbsPars[1] := True ;
                 LogPars[1] := False ;
                 ParameterScaleFactors[1] := xScale ;

                 AbsPars[2] := False ;
                 LogPars[2] := False ;
                 ParameterScaleFactors[2] := yScale ;

                 AbsPars[3] := True ;
                 LogPars[3] := False ;
                 ParameterScaleFactors[3] := xScale ;

                 AbsPars[4] := False ;
                 LogPars[4] := False ;
                 ParameterScaleFactors[4] := yScale ;

                 AbsPars[5] := True ;
                 LogPars[5] := False ;
                 ParameterScaleFactors[5] := xScale ;

                 AbsPars[6] := False ;
                 LogPars[6] := False ;
                 ParameterScaleFactors[6] := yScale ;
                 end ;

          EPC : begin
                 AbsPars[0] := False ;
                 LogPars[0] := False ;
                 ParameterScaleFactors[0] := yScale ;

                 AbsPars[1] := False ;
                 LogPars[1] := False ;
                 ParameterScaleFactors[1] := xScale ;

                 AbsPars[2] := True ;
                 LogPars[2] := False ;
                 ParameterScaleFactors[2] := xScale ;

                 AbsPars[3] := True ;
                 LogPars[3] := False ;
                 ParameterScaleFactors[3] := xScale ;
                 end ;

          EPC2EXP : begin

                 AbsPars[0] := False ;
                 LogPars[0] := False ;
                 ParameterScaleFactors[0] := xScale ;

                 AbsPars[1] := True ;
                 LogPars[1] := False ;
                 ParameterScaleFactors[1] := xScale ;

                 AbsPars[2] := False ;
                 LogPars[2] :=  False ;
                 ParameterScaleFactors[2] := yScale ;

                 AbsPars[3] := True ;
                 LogPars[3] := False ;
                 ParameterScaleFactors[3] := xScale ;

                 AbsPars[4] := False ;
                 LogPars[4] := False ;
                 ParameterScaleFactors[4] := yScale ;

                 AbsPars[5] := True ;
                 LogPars[5] := False ;
                 ParameterScaleFactors[5] := xScale ;

                 end ;

          HHK : begin
                 AbsPars[0] := False ;
                 LogPars[0] := False ;
                 ParameterScaleFactors[0] := yScale ;

                 AbsPars[1] := True ;
                 LogPars[1] := False ;
                 ParameterScaleFactors[1] := xScale ;

                 AbsPars[2] := True ;
                 LogPars[2] := False ;
                 ParameterScaleFactors[2] := 1. ;
                 end ;

          HHNa : begin
                 AbsPars[0] := False ;
                 LogPars[0] := False ;
                 ParameterScaleFactors[0] := yScale ;

                 AbsPars[1] := True ;
                 LogPars[1] := False ;
                 ParameterScaleFactors[1] := xScale ;

                 AbsPars[2] := True ;
                 LogPars[2] := False ;
                 ParameterScaleFactors[2] := 1. ;

                 AbsPars[3] := True ;
                 LogPars[3] := False ;
                 ParameterScaleFactors[3] := 1. ;

                 AbsPars[4] := True ;
                 LogPars[4] := False ;
                 ParameterScaleFactors[4] := xScale ;
                 end ;

          MEPCNoise : begin
                 AbsPars[0] := True ;
                 LogPars[0] := False ;
                 ParameterScaleFactors[0] := yScale ;

                 AbsPars[1] := True ;
                 LogPars[1] := False ;
                 ParameterScaleFactors[1] := xScale ;

                 AbsPars[2] := True ;
                 LogPars[2] := False ;
                 ParameterScaleFactors[2] := xScale ;
                 end ;
          Gaussian : begin
                 AbsPars[0] := False ;
                 LogPars[0] := False ;
                 ParameterScaleFactors[0] := xScale ;

                 AbsPars[1] := True ;
                 LogPars[1] := False ;
                 ParameterScaleFactors[1] := xScale ;

                 AbsPars[2] := True ;
                 LogPars[2] := False ;
                 ParameterScaleFactors[2] := yScale ;
                 end ;
          Gaussian2 : begin
                 AbsPars[0] := False ;
                 LogPars[0] := False ;
                 ParameterScaleFactors[0] := xScale ;

                 AbsPars[1] := True ;
                 LogPars[1] := False ;
                 ParameterScaleFactors[1] := xScale ;

                 AbsPars[2] := True ;
                 LogPars[2] := False ;
                 ParameterScaleFactors[2] := yScale ;

                 AbsPars[3] := False ;
                 LogPars[3] := False ;
                 ParameterScaleFactors[3] := xScale ;

                 AbsPars[4] := True ;
                 LogPars[4] := False ;
                 ParameterScaleFactors[4] := xScale ;

                 AbsPars[5] := True ;
                 LogPars[5] := False ;
                 ParameterScaleFactors[5] := yScale ;
                 end ;

          Gaussian3 : begin
                 AbsPars[0] := False ;
                 LogPars[0] := False ;
                 ParameterScaleFactors[0] := xScale ;

                 AbsPars[1] := True ;
                 LogPars[1] := False ;
                 ParameterScaleFactors[1] := xScale ;

                 AbsPars[2] := True ;
                 LogPars[2] := False ;
                 ParameterScaleFactors[2] := yScale ;

                 AbsPars[3] := False ;
                 LogPars[3] := False ;
                 ParameterScaleFactors[3] := xScale ;

                 AbsPars[4] := True ;
                 LogPars[4] := False ;
                 ParameterScaleFactors[4] := xScale ;

                 AbsPars[5] := True ;
                 LogPars[5] := False ;
                 ParameterScaleFactors[5] := yScale ;

                 AbsPars[6] := False ;
                 LogPars[6] := False ;
                 ParameterScaleFactors[6] := xScale ;

                 AbsPars[7] := True ;
                 LogPars[7] := False ;
                 ParameterScaleFactors[7] := xScale ;

                 AbsPars[8] := True ;
                 LogPars[8] := False ;
                 ParameterScaleFactors[8] := yScale ;
                 end ;

          PDFExp : PDFExpScaling(AbsPars,LogPars,ParameterScaleFactors,yScale,1) ;
          PDFExp2 : PDFExpScaling(AbsPars,LogPars,ParameterScaleFactors,yScale,2) ;
          PDFExp3 : PDFExpScaling(AbsPars,LogPars,ParameterScaleFactors,yScale,3) ;
          PDFExp4 : PDFExpScaling(AbsPars,LogPars,ParameterScaleFactors,yScale,4) ;
          PDFExp5 : PDFExpScaling(AbsPars,LogPars,ParameterScaleFactors,yScale,5) ;

           Quadratic : begin

                 AbsPars[0] := False ;
                 LogPars[0] := False ;
                 ParameterScaleFactors[0] := yScale ;

                 AbsPars[1] := False ;
                 LogPars[1] := False ;
                 ParameterScaleFactors[1] := yScale/xScale ;

                 AbsPars[2] := False ;
                 LogPars[2] := False ;
                 ParameterScaleFactors[2] := yScale/(xScale*xScale) ;
                 end ;

           Cubic : begin

                 AbsPars[0] := False ;
                 LogPars[0] := False ;
                 ParameterScaleFactors[0] := yScale ;

                 AbsPars[1] := False ;
                 LogPars[1] := False ;
                 ParameterScaleFactors[1] := yScale/xScale ;

                 AbsPars[2] := False ;
                 LogPars[2] := False ;
                 ParameterScaleFactors[2] := yScale/(xScale*xScale) ;

                 AbsPars[3] := False ;
                 LogPars[3] := False ;
                 ParameterScaleFactors[3] := yScale/(xScale*xScale*xScale) ;

                 end ;

           DecayingExp : begin
                 AbsPars[0] := False ;
                 LogPars[0] := False ;
                 ParameterScaleFactors[0] := yScale ;

                 AbsPars[1] := True ;
                 LogPars[1] := False ;
                 ParameterScaleFactors[1] := xScale ;

                 end ;

           DecayingExp2 : begin
                 AbsPars[0] := False ;
                 LogPars[0] := False ;
                 ParameterScaleFactors[0] := yScale ;

                 AbsPars[1] := True ;
                 LogPars[1] := False ;
                 ParameterScaleFactors[1] := xScale ;

                 AbsPars[2] := False ;
                 LogPars[2] := False ;
                 ParameterScaleFactors[2] := yScale ;

                 AbsPars[3] := True ;
                 LogPars[3] := False ;
                 ParameterScaleFactors[3] := xScale ;

                 end ;

           DecayingExp3 : begin
                 AbsPars[0] := False ;
                 LogPars[0] := False ;
                 ParameterScaleFactors[0] := yScale ;

                 AbsPars[1] := True ;
                 LogPars[1] := False ;
                 ParameterScaleFactors[1] := xScale ;

                 AbsPars[2] := False ;
                 LogPars[2] := False ;
                 ParameterScaleFactors[2] := yScale ;

                 AbsPars[3] := True ;
                 LogPars[3] := False ;
                 ParameterScaleFactors[3] := xScale ;

                 AbsPars[4] := False ;
                 LogPars[4] := False ;
                 ParameterScaleFactors[4] := yScale ;

                 AbsPars[5] := True ;
                 LogPars[5] := False ;
                 ParameterScaleFactors[5] := xScale ;

                 end ;

           Boltzmann : begin
                 AbsPars[0] := False ;
                 LogPars[0] := False ;
                 ParameterScaleFactors[0] := yScale ;

                 AbsPars[1] := False;
                 LogPars[1] := False ;
                 ParameterScaleFactors[1] := xScale ;

                 AbsPars[2] := False ;
                 LogPars[2] := False ;
                 ParameterScaleFactors[2] := xScale ;

                 AbsPars[3] := False ;
                 LogPars[3] := False ;
                 ParameterScaleFactors[3] := yScale ;

                 end ;

           DecayingExp2A : begin
                 AbsPars[0] := False ;
                 LogPars[0] := False ;
                 ParameterScaleFactors[0] := yScale ;

                 AbsPars[1] := True ;
                 LogPars[1] := False ;
                 ParameterScaleFactors[1] := xScale ;

                 AbsPars[2] := True ;
                 LogPars[2] := False ;
                 ParameterScaleFactors[2] := 1.0 ;

                 AbsPars[3] := True ;
                 LogPars[3] := False ;
                 ParameterScaleFactors[3] := xScale ;

                 end ;


          end ;

     Normalised := True ;
     end ;

procedure PDFExpScaling(
          var AbsPars : Array of Boolean ;
          var LogPars : Array of Boolean ;
          var ParameterScaleFactors : Array of Single ;
          yScale : Single ;
          nExp : Integer ) ;
{ --------------------------------
  Exponential PDF scaling factors
  ------------------------------- }
var
   i,j : Integer ;
begin
     for i := 0 to nExp-1 do begin
         j := 2*i ;
         AbsPars[j] := True ;
         LogPars[j] := False ;
         ParameterScaleFactors[j] := yScale ;
         AbsPars[j+1] := false ;
         LogPars[j+1] := true ;
         ParameterScaleFactors[j+1] := 1.0 ;
         end ;
     end ;


{ -----------------------------------------------------------------
  Adjust a parameter to account for data normalisation to 0-1 range
  -----------------------------------------------------------------}
function TMathFunc.NormaliseParameter(
         Index : Integer ;           { Parameter Index (IN) }
         Value : single              { Parameter value (IN) }
         ) : single ;
var
   NormValue : single ;
begin
     if (Index >= 0) and (Index<GetNumParameters) and Normalised then begin
        NormValue := Value * ParameterScaleFactors[Index] ;
        if AbsPars[Index] then NormValue := Abs(NormValue) ;
        if LogPars[Index] then NormValue := ln(NormValue) ;
        Result := NormValue ;
        end
     else Result := Value ; ;
     end ;


{ ----------------------------------------
  Restore a parameter to actual data range
  ----------------------------------------}
function TMathFunc.DenormaliseParameter(
         Index : Integer ;           { Parameter Index (IN) }
         Value : single              { Parameter value (IN) }
         ) : single ;
var
   NormValue : single ;
begin
     if (Index >= 0) and (Index<GetNumParameters) and Normalised then begin
        NormValue := Value / ParameterScaleFactors[Index] ;
        if AbsPars[Index] then NormValue := Abs(NormValue) ;
        if LogPars[Index] then NormValue := exp(NormValue) ;
        Result := NormValue ;
        end
     else Result := Value ; ;
     end ;


{ --------------------------------------------------------------
  Make an initial guess at parameter value based upon (X,Y) data
  pairs in Data
  --------------------------------------------------------------}
function TMathFunc.InitialGuess(
         const Data : TXYData ;   { Data set to be fitted }
         nPoints : Integer ;      { No. of points }
         Index : Integer          { Function parameter No. }
         ) : single ;
var
   i,iEnd,iY25,iY50,iY75 : Integer ;
   xMin,xMax,yMin,yMax,x,y,yRange,XAtYMax,XAtYMin : Single ;
   YSum,YMean,XYSum,XSum,XMean,XYMean : single ;
   Guess : Array[0..LastParameter] of single ;
begin

      if (Index < 0) or (Index>=GetNumParameters)  then begin
         Result := 1.0 ;
         Exit ;
         end ;

      iEnd := nPoints - 1 ;

      { Find Min./Max. limits of data }
      xMin := MaxSingle ;
      xMax := -xMin ;
      yMin := MaxSingle ;
      yMax := -yMin ;
      XAtYMax := Data.x[0] ;
      XAtYMin := Data.x[0] ;
      for i := 0 to iEnd do begin
         x := Data.x[i] ;
         y := Data.y[i] ;
         if xMin > x then xMin := x ;
         if xMax < x then xMax := x ;
         if yMin > y then begin
            yMin := y ;
            XAtYMin := x ;
            end ;
         if yMax < y then begin
            yMax := y ;
            XAtYMax := x ;
            end ;
         end ;

      { Find points which are 75%, 50% and 25% of yMax }
      iY25 := 0 ;
      iY50 := 0 ;
      iY75 := 0 ;
      for i := 0 to iEnd do begin
          y := Data.y[i] - yMin ;
          yRange := yMax - yMin ;
          if y > (yRange*0.75) then iY75 := i ;
          if y > (yRange*0.5) then iY50 := i ;
          if y > (yRange*0.25) then iY25 := i ;
          end ;

      { Find mean X value weighted by Y values }
      XYSum := 0.0 ;
      YSum := 0.0 ;
      XSum := 0.0 ;
      for i := 0 to iEnd do begin
          XYSum := XYSum + Data.y[i]*Data.x[i] ;
          YSum := YSum + Data.y[i] ;
          XSum := XSum + Data.x[i] ;
          end ;
      if YSum <> 0.0 then XYMean := XYSum / YSum
                     else XYMean := 0.0 ;
      YMean := YSum / (iEnd+1) ;
      XMean :=  XSum / (iEnd+1) ;


      Case FEqnType of
           Lorentzian : begin
                  Guess[0] := Data.y[0] ;
                  Guess[1] := Data.x[iY50] ;
                  end ;
           Lorentzian2 : begin
                  Guess[0] := Data.y[0] ;
                  Guess[1] := Data.x[iY75] ;
                  Guess[2] := Data.y[0]/4.0 ;
                  Guess[3] := Data.x[iY25] ;
                  end ;
           LorAndOneOverF : begin
                  Guess[0] := Data.y[0]*0.75 ;
                  Guess[1] := Data.x[iY50] ;
                  Guess[2] := Data.y[0]*0.25 ;
                  end ;
           Linear : begin
                  Guess[0] := yMin ;
                  Guess[1] := (yMax - yMin) / (xMax - xMin);
                  end ;
           Parabola : begin
                  Guess[0] := yMean / xMean ;
                  if Guess[0] > 0.0 then Guess[1] := Abs(xMax/Guess[0])
                  else if Guess[0] < 0.0 then Guess[1] := Abs(xMin/Guess[0])
                  else Guess[1] := 1.0 ;
                  Guess[2] := yMin ;
                  end ;

           Exponential : begin
                  Guess[0] := Data.y[0] - Data.y[iEnd] ;
                  if Guess[0] = 0.0 then Guess[0] := 1.0 ;
                  Guess[1] := (Data.x[iEnd] - Data.x[0]) / 4.0 ;
                  Guess[2] := Data.y[iEnd] ;
                  end ;

           Exponential2 : begin
                  Guess[0] := (Data.y[0] - Data.y[iEnd])*0.5 ;
                  if Guess[0] = 0.0 then Guess[0] := 1.0 ;
                  Guess[1] := (Data.x[iEnd] - Data.x[0]) / 20.0 ;
                  Guess[2] := (Data.y[0] - Data.y[iEnd])*0.5 ;
                  if Guess[2] = 0.0 then Guess[0] := 1.0 ;
                  Guess[3] := (Data.x[iEnd] - Data.x[0]) / 2.0 ;
                  Guess[4] := Data.y[iEnd] ;
                  end ;

           Exponential3 : begin
                  Guess[0] := (Data.y[0] - Data.y[iEnd])*0.33 ;
                  if Guess[0] = 0.0 then Guess[0] := 1.0 ;
                  Guess[1] := (Data.x[iEnd] - Data.x[0]) / 20.0 ;
                  Guess[2] := Data.y[0] - Data.y[iEnd]*0.33 ;
                  if Guess[2] = 0.0 then Guess[0] := 1.0 ;
                  Guess[3] := (Data.x[iEnd] - Data.x[0]) / 5.0 ;
                  Guess[4] := (Data.y[0] - Data.y[iEnd])*0.33 ;
                  if Guess[4] = 0.0 then Guess[0] := 1.0 ;
                  Guess[5] := (Data.x[iEnd] - Data.x[0]) / 1.0 ;
                  Guess[6] := Data.y[iEnd] ;
                  end ;

           EPC : begin
                  { Peak amplitude }
                  if Abs(yMax) > Abs(yMin) then begin
                     Guess[0] := yMax ;
                     Guess[1] := XAtYmax ;
                     end
                  else begin
                     Guess[0] := yMin ;
                     Guess[1] := XAtYmin ;
                     end ;
                  if Guess[0] = 0.0 then Guess[0] := 1.0 ;
                  { Set initial latency to time of signal peak }
                  { Rising time constant }
                  Guess[2] := (Data.x[1] - Data.x[0])*5.0 ;
                  { Decay time constant }
                  Guess[3] := (Data.x[iEnd] - Data.x[0]) / 4. ;
                  end ;

           EPC2EXP : begin

                  { Peak amplitude }
                  if Abs(yMax) > Abs(yMin) then begin
                     Guess[0] := XAtYmax ;
                     Guess[2] := yMax*0.5 ;
                     Guess[4] := yMax*0.5 ;
                     end
                  else begin
                     Guess[2] := yMin*0.5 ;
                     Guess[4] := yMin*0.5 ;
                     Guess[0] := XAtYmin ;
                     end ;
                  { Set initial latency to time of signal peak }
                  { Rising time constant }
                  Guess[1] := (Data.x[1] - Data.x[0])*2.0 ;

                  { Decay time constant }
                  Guess[5] := (Data.x[iEnd] - Data.x[0]) / 2. ;
                  Guess[3] := (Data.x[iEnd] - Data.x[0]) / 20.0 ;

                  end ;

           HHK : begin
                  if Abs(yMax) > Abs(yMin) then Guess[0] := yMax
                                           else Guess[0] := yMin ;
                  if Guess[0] = 0.0 then Guess[0] := 1.0 ;
                  Guess[1] := (Data.x[iEnd] - Data.x[0]) / 6. ;
                  Guess[2] := 2. ;
                  end ;

           HHNa : begin
                  if Abs(yMax) > Abs(yMin) then Guess[0] := yMax
                                           else Guess[0] := yMin ;
                  if Guess[0] = 0.0 then Guess[0] := 1.0 ;
                  Guess[1] := (Data.x[iEnd] - Data.x[0]) / 30. ;
                  Guess[2] := 3. ;
                  Guess[3] := Abs( Data.y[iEnd]/Guess[0] ) ;
                  Guess[4] := (Data.x[iEnd] - Data.x[0]) / 3. ;
                  end ;

           MEPCNoise : begin
                  Guess[0] := Data.y[0] ;
                  Guess[1] := Data.x[iY50] ;
                  Guess[2] := Guess[1]*10.0 ;
                  end ;

           Gaussian : begin
                  GaussianGuess( Data.x, Data.Y, nPoints, 1, Guess ) ;
                  end ;

           Gaussian2 : begin
                  GaussianGuess( Data.X, Data.Y, nPoints, 2, Guess ) ;
                  end ;

           Gaussian3 : begin
                  GaussianGuess( Data.X, Data.Y, nPoints, 3, Guess ) ;
                  end ;

           PDFExp : begin
                  Guess[0] := 100.0 ;
                  Guess[1] := XYMean ;
                  end ;
           PDFExp2 : begin
                  Guess[0] := 75.0 ;
                  Guess[1] := XYMean*0.3 ;
                  Guess[2] := 25.0 ;
                  Guess[3] := XYMean*3.0 ;
                  end ;
           PDFExp3 : begin
                  Guess[0] := 50.0 ;
                  Guess[1] := XYMean*0.2 ;
                  Guess[2] := 25.0 ;
                  Guess[3] := XYMean*5.0 ;
                  Guess[4] := 25.0 ;
                  Guess[5] := XYMean*50.0 ;
                  end ;
           PDFExp4 : begin
                  Guess[0] := 50.0 ;
                  Guess[1] := XYMean*0.2 ;
                  Guess[2] := 25.0 ;
                  Guess[3] := XYMean*5.0 ;
                  Guess[4] := 15.0 ;
                  Guess[5] := XYMean*50.0 ;
                  Guess[6] := 10.0 ;
                  Guess[7] := XYMean*200.0 ;
                  end ;

           PDFExp5 : begin
                  Guess[0] := 50.0 ;
                  Guess[1] := XYMean*0.2 ;
                  Guess[2] := 25.0 ;
                  Guess[3] := XYMean*5.0 ;
                  Guess[4] := 10.0 ;
                  Guess[5] := XYMean*50.0 ;
                  Guess[6] := 5.0 ;
                  Guess[7] := XYMean*200.0 ;
                  Guess[8] := 5.0 ;
                  Guess[9] := XYMean*500.0 ;
                  end ;


           Quadratic : begin
                  Guess[0] := yMin ;
                  Guess[1] := (yMax - yMin) / (xMax - xMin);
                  Guess[2] := Guess[1]*0.1 ;
                  end ;
           Cubic : begin
                  Guess[0] := yMin ;
                  Guess[1] := (yMax - yMin) / (xMax - xMin);
                  Guess[2] := Guess[1]*0.1 ;
                  Guess[3] := Guess[2]*0.1 ;
                  end ;

           DecayingExp : begin
                  Guess[0] := Data.y[0] - Data.y[iEnd] ;
                  Guess[1] := (Data.x[iEnd] - Data.x[0]) / 4.0 ;
                  end ;

           DecayingExp2 : begin
                  Guess[0] := Data.y[0] - Data.y[iEnd]*0.5 ;
                  Guess[1] := (Data.x[iEnd] - Data.x[0]) / 20.0 ;
                  Guess[2] := Data.y[0] - Data.y[iEnd]*0.5 ;
                  Guess[3] := (Data.x[iEnd] - Data.x[0]) / 2.0 ;
                  end ;

           DecayingExp3 : begin
                  Guess[0] := Data.y[0] - Data.y[iEnd]*0.33 ;
                  Guess[1] := (Data.x[iEnd] - Data.x[0]) / 20.0 ;
                  Guess[2] := Data.y[0] - Data.y[iEnd]*0.33 ;
                  Guess[3] := (Data.x[iEnd] - Data.x[0]) / 5.0 ;
                  Guess[4] := Data.y[0] - Data.y[iEnd]*0.33 ;
                  Guess[5] := (Data.x[iEnd] - Data.x[0]) / 1.0 ;
                  end ;

           Boltzmann : begin
                 Guess[0] := YMax - YMin ;
                 Guess[1] := (XAtYMax + XAtYMin) / 2.0 ;
                 Guess[2] := -(XAtYMax - XAtYMin)*0.2 ;
                 Guess[3] := YMin ;
                 end ;

           DecayingExp2A : begin
                  Guess[0] := Data.y[0] - Data.y[iEnd] ;
                  Guess[1] := (Data.x[iEnd] - Data.x[0]) / 20.0 ;
                  Guess[2] := 0.5 ;
                  Guess[3] := (Data.x[iEnd] - Data.x[0]) / 2.0 ;
                  end ;

           end ;

      if (Index >= 0) and (Index<GetNumParameters)  then begin
         Result := Guess[Index] ;
         end
      else Result := 1.0 ;
      end ;

procedure TMathFunc.GaussianGuess(
          const X : Array of Single ;   // X data points
          const Y : Array of Single ;   // Y data points
          NumPoints : Integer ;         // No. points in X and Y
          NumGaussians : Integer ;      // No. of of gaussians to be fitted
          var Guess : Array of Single ) ; // Initial parameter guesses returned
// ----------------------------------------------------
// Find initial guesses for gaussin function parameters
// ----------------------------------------------------
var
    G,i0,i1,i : Integer ;
    XYSum,X2YSum,YSum,YPeak,XMean,XSD : Single ;
begin

//  Split X,Y data into NumGaussian equal segments and
//  use mean, sd and peak for each section as initial guesses for gaussian parameters

    for G := 0 to NumGaussians-1 do begin

        XYSum := 0.0 ;
        X2YSum := 0.0 ;
        YSum := 0.0 ;
        YPeak := 0.0 ;
        XMean := 0.0 ;
        XSD := 0.0 ;
        i0 := G*(NumPoints div NumGaussians) ;
        i1 := i0 + (NumPoints div NumGaussians) - 1 ;
        for i := i0 to i1 do begin
            XYSum := XYSum + Y[i]*X[i] ;
            X2YSum := X2YSum + Y[i]*X[i]*X[i] ;
            if Y[i] >= YPeak then YPeak := Y[i] ;
            YSum := YSum + Y[i] ;
            end ;
      if YSum <> 0.0 then begin
         XMean := XYSum / YSum ;
         XSD := sqrt( X2YSum/YSum - XMean*XMean) ;
         end ;
      Guess[G*3] := XMean ;
      Guess[G*3+1] := XSD ;
      Guess[G*3+2] := YPeak ;
      end ;
    end ;

procedure TMathFunc.FitCurve(
          var Data : TXYData ;         { Data to be fitted to }
          nPoints : LongInt            { No. of data points }
          ) ;
var
   NumSig,nSigSq,iConv,Maxiterations,i : Integer ;
   nVar,nFixed : Integer ;
   SSQ,DeltaMax : Single ;
   F,W : ^TWorkArray ;
   sltjj : Array[0..300] of Single ;
   FitPars : TPars ;
begin

     { Create buffers for SSQMIN }
     New(F) ;
     New(W) ;

     try

        { Determine an initial set of parameter guesses }
        if not ParsSet then begin
           for i := 0 to GetNumParameters-1 do if not FixedPars[i] then
               Pars[i] := InitialGuess( Data, nPoints, i ) ;
           end ;

        { Scale X & Y data into 0-1 numerical range }
        ScaleData( Data, nPoints ) ;

        { Re-arrange parameters putting fixed parameters at end of array }
        nVar := 0 ;
        nFixed := GetNumParameters ;
        for i := 0 to GetNumParameters-1 do begin
            if FixedPars[i] then begin
               FitPars.Value[nFixed] := Pars[i] ;
               FitPars.Map[nFixed] := i ;
               Dec(nFixed) ;
               end
            else begin
               Inc(nVar) ;
               FitPars.Value[nVar] := Pars[i] ;
               FitPars.Map[nVar] := i ;
               end ;
            end ;

        { Set weighting array to unity }
        for i := 1 to nPoints do W^[i] := 1. ;

        NumSig := 5 ;
        nSigSq := 5 ;
        deltamax := 1E-16 ;
        maxiterations := 100 ;
        iconv := 0 ;
        if nVar > 0 then
           begin
           try
              ssqmin ( FitPars , nPoints, nVar, maxiterations,
                       NumSig,NSigSq,DeltaMax,
                       W^,SLTJJ,iConv,IterationsValue,SSQ,F^, Data )
           except
              { on EOverFlow do MessageDlg( ' Fit abandoned -FP Overflow !',
                                  mtWarning, [mbOK], 0 ) ;
               on EUnderFlow do MessageDlg( ' Fit abandoned -FP Underflow !',
                                  mtWarning, [mbOK], 0 ) ;
               on EZeroDivide do MessageDlg( ' Fit abandoned -FP Zero divide !',
                                  mtWarning, [mbOK], 0 ) ; }
               GoodFitFlag := False ;
               end ;

           { Calculate parameter and residual standard deviations
           (If the fit has been successful) }
           if iConv > 0 then
              begin
              if nPoints > nVar then
                 begin
                 STAT( nPoints,nVar,F^,Data.y,W^,SLTJJ,SSQ,FitPars.SD,ResidualSDValue,RValue,FitPars.Value ) ;
                 for i := 1 to GetNumParameters do Pars[FitPars.Map[i]] := FitPars.Value[i] ;
                 for i := 1 to GetNumParameters do ParSDs[FitPars.Map[i]] := FitPars.SD[i] ;
                 DegreesOfFreedomValue := nPoints - GetNumParameters ;
                 end
              else DegreesOfFreedomValue := 0 ;

              // Mark as bad fit if any parameters NAN or INF
              GoodFitFlag := True ;
              for i:= 1 to nVar do if IsNAN(Pars[i]) or IsInFinite(Pars[i]) then GoodFitFlag := False ;

              ParsSet := False ;
              end
           else GoodFitFlag := False ;
           end
        else GoodFitFlag := True ;

        { Return parameter scaling to normal }
        UnScaleParameters ;


     finally ;

        Dispose(W) ;
        Dispose(F) ;
        end ;

     end ;



{ ----------------------------------------------------------
  Scale Y data to lie in same range as X data
  (The iterative fitting routine is more stable when
  the X and Y data do not differ too much in numerical value)
  ----------------------------------------------------------}
procedure TMathFunc.ScaleData(
          var Data : TXYData ;
          nPoints : LongInt
          );
var
   i,iEnd : Integer ;
   xMax,yMax,xScale,yScale,x,y,ySum : Single ;
begin
     iEnd := nPoints - 1 ;
     { Find absolute value limits of data }
     xMax := -MaxSingle ;
     yMax := -MaxSingle ;
     ySum := 0.0 ;
     for i := 0 to iEnd do begin
         x := Abs(Data.x[i]) ;
         y := Abs(Data.y[i]) ;
         if xMax < x then xMax := x ;
         if yMax < y then yMax := y ;
         ySum := ySum + y ;
         end ;

     {Calc. scaling factor}
     if xMax > 0. then xScale := 1./xMax
                  else xScale := 1. ;
     if yMax > 0. then yScale := 1./yMax
                  else yScale := 1. ;

     { Disable x,y scaling in special case of exponential prob. density functions }
     if (FEqnType = PDFExp) or
        (FEqnType = PDFExp2) or
        (FEqnType = PDFExp3) or
        (FEqnType = PDFExp4) or
        (FEqnType = PDFExp5) then begin
        xScale := 1.0 ;
        yScale := 1.0 ;
        end ;

     { Scale data to lie in same numerical range as X data }
     for i := 0 to iEnd do begin
         Data.x[i] := xScale * Data.x[i] ;
         Data.y[i] := yScale * Data.y[i] ;
         end ;


     { Set parameter scaling factors which adjust for
       data normalisation to 0-1 range }
     SetupNormalisation( xScale, yScale ) ;

     { Scale equation parameters }
     for i := 0 to GetNumParameters-1 do begin
         Pars[i] := NormaliseParameter(i,Pars[i]) ;
         end ;

     end ;


{ ----------------------------------------------------
  Correct best-fit parameters for effects of Y scaling
  ----------------------------------------------------}
procedure TMathFunc.UnScaleParameters ;
var
   i : Integer ;
   UpperLimit,LowerLimit : single ;
begin
     for i := 0 to GetNumParameters-1 do begin

         { Don't denormalise a fixed parameter }
         if not FixedPars[i] then begin
            UpperLimit := DenormaliseParameter(i,Pars[i]+ParSDs[i]) ;
            LowerLimit := DenormaliseParameter(i,Pars[i]-ParSDs[i]) ;
            ParSDs[i] := Abs(UpperLimit - LowerLimit)*0.5 ;
            end ;
         { Denormalise parameter }
         Pars[i] := DenormaliseParameter(i,Pars[i]) ;
         end ;

     {Unscale residual standard deviation }
     ResidualSDValue := ResidualSDValue/ResidualSDScaleFactor ;

     end ;


procedure TMathFunc.SsqMin (
          var Pars : TPars ;
          nPoints,nPars,ItMax,NumSig,NSiqSq : LongInt ;
          Delta : Single ;
          var W,SLTJJ : Array of Single ;
          var ICONV,ITER : LongInt ;
          var SSQ : Single ;
          var F : Array of Single ;
          Const Data : TXYData) ;

{
  SSQMIN routine based on an original FORTRAN routine written by
  Kenneth Brown and modified by S.H. Bryant

C
C       Work buffer structure
C
C      (1+N(N-1)/2)
C      :---------:------N*M----------:-----------:
C      1         JACSS               GRADSS      GRDEND
C
C                :--N--:             :----M------------:---N----:
C                      DELEND        FPLSS             DIAGSS   ENDSS
C                                                                :--->cont.
C                                                                FMNSS
C
C       :-------M------:--N-1---:
C       FMNSS          XBADSS   XBEND
C
C
C
C
C               SSQMIN   ------   VERSION II.
C
C       ORIGINAL SOURCE FOR SSQMIN WAS GIFT FROM K. BROWN, 3/19/76.
C       PROGRAM WAS MODIFIED A FOLLOWS:
C
C       1.      WEIGHTING VECTOR W(1) WAS ADDED SO THAT ALL RESIDUALS
C	EQUAL F(I) * SQRT1(W(I)).
C
C       2.      THE VARIABLE KOUT WHICH INDICATED ON EXIT WHETHER F(I)
C       WAS CALCULATED FROM UPDATED X(J) WAS REMOVED. IN
C       CONDITIONS WHERE KOUT =0 THE NEW F(I)'S AND AN UPDATED
C       SSQ IS OUTPUTTED . SSQ ( SUM WEIGHTED F(I) SQUARED )
C       WAS PUT INTO THE CALL STRING.
C
C       3.      A NEW ARRAY SLTJJ(K) WHICH CONTAINS THE SUPER LOWER
C       TRIANGLE OF JOCOBIAN (TRANSPOSE)*JACOBIAN WAS ADDED TO THE
C       CALL STRING. IT HAS THE SIZE N*(N+1)/2 AND IS USED FOR
C       CALCULATING THE STATSTICS OF THE FIT. STORAGE OF
C       ELEMENTS IS AS FOLLOWS:C(1,1),C(2,1),C(2,2),C(3,2),C(3,3),
C       C(4,1)........
C       NOTE THE AREA WORK (1) THROU WORK (JACM1) IN WHICH SLTJJ
C       IS INITALLY STORED IS WRITTEN OVER (DO 52) IN CHOLESKY
C       AND IS NOT AVAILABLE ON RETURN.
C
C       4.      A BUG DUE TO SUBSCRIPTING W(I) OUT OF BOUNDS WAS
C       CORRECTED IN MAY '79. THE CRITERION FOR SWITCHING FROM
C       FORWARD DIFFERENCES (ISW=1) TO CENTRAL DIFFERENCES
C       (ISW = 2) FOR THE PARTIAL DERIVATIVE ESTIMATES IS SET
C       IN STATEMENT 27 (ERL2.LT.GRCIT).GRCIT IS INITALIZED
C       TO 1.E-3 AS IN ORIGINAL PROGRAM. THE VARIABLE T IN
C       CHOLESKY WAS MADE TT TO AVIOD CONFUSION WITH ARRAY T.
C
C       SSQMIN -- IS A FINITE DIFFERENCE LEVENBERG-MARQUARDT LEAST
C       SQUARES ALGORTHM. GIVEN THE USER SUPPLIED INITIAL
C       ESTIMATE FOR X, SSQMIN FINDS THE MINIMUM OF
C       SUM ((F (X ,....,X ) ) ** 2)   J=1,2,.....M
C              J  1       N   J
C       BY A MODIFICATION OF THE LEVENBERG-MARQUARDT ALGORITHM
C       WHICH INCLUDES INTERNAL SCALING AND ELIMINATES THE
C       NEED FOR EXPLICIT DERIVATIVES. THE F (X ,...,X )
C                           J  1      N
C       CAN BE TAKEN TO BE THE RESIDUALS OBTAINED WHEN FITTING
C       NON-LINEAR MODEL, G, TO DATA Y IN THE LEAST SQUARES
C       SENSE ..., I.E.,TAKE
C               F (X ,...,X ) = G (X ,...,X ) - Y
C                J  1      N     J  1      N
C       REFERENCES:
C
C       BROWN,K.M. AND DENNIS,J.S. DERIVATIVE FREE ANALOGS OF
C       THE LEVENBERG-MARQUARDT AND GAUSS ALGORITHMS FOR
C       NON-LINEAR LEAST SQUARES APPROXIMATION. NUMERISCHE
C       MATHEMATIK 18:289 -297  (1972).
C       BROWN,K.M.  COMPUTER ORIENTED METHODS FOR FITTING
C       TABULAR DATA IN THE LINEAR AND NON-LINEAR LEAST SQUARES
C       SENSE.  TECHNICIAL REPORT NO. 72-13. DEPT..COMPUTER &
C       INFORM. SCIENCES; 114 LIND HALL, UNIVERSITY OF
C       MINNESOTA, MINNEAPOLIS, MINNESOTA  5545.
C
C       PARAMETERS :
C
C       X       REAL ARRAY WITH DIMENSION N.
C               INPUT --- INITIAL ESTIMATES
C               OUTPUT -- VALUES AT MIN (OR FINAL APPROXIMATION)
C
C       M       THE NUMBER OF RESIDUALS (OBSERVATIONS)
C
C       N       THE NUMBER OF UNKNOWN PARAMETERS
C
C       ITMAX   THE MAXIMUM NUMBER OF ITERATIONS TO BE ALLOWED
C               NOTE-- THE MAXIMUM NUMBER OF FUNCTION EVALUATIONS
C               ALLOWED IS ROUGHLY (N+1)*ITMAX  .
C
C       IPRINT  AN OUTPUT PARAMETER. IF IPRINT IS NON ZERO CONTROL
C               IS PASSED ONCE DURING EACH ITERATION TO SUBROUTINE
C               PRNOUT WHICH PRINTS INTERMEDIATE RESULTS (SEE BELOW)
C               IF IPRINT IS ZERO NO CALL IS MADE.
C
C       NUMSIG  FIRST CONVERGENCE CRITERION. CONVERGENCE CONDITION
C               SATISFIED IF ALL COMPONENTS OF TWO SUCCESSIVE
C               ITERATES AGREE TO NUMSIG DIGITS.
C
C       NSIGSQ  SECOND CONVERGENCE CRITERION. CONVERGENCE CONDITIONS
C               SATISFIED IF SUM OF SQUARES OF RESIDUALS FOR TWO
C               SUCCESSIVE ITERATIONS AGREE TO NSIGSQ DIGITS.
C
C       DELTA   THIRD CONVERGENCE CRITERION. CONVERGENCE CONDITIONS
C               SATISFIED IF THE EUCLIDEAN NORM OF THE APPROXIMATE
C               GRADIENT VECTOR IS LESS THAN DELTA.
C
C         ***************  NOTE  ********************************
C
C               THE ITERATION WILL TERMIATE ( CONVERGENCE WILL CONSIDERED
C               ACHIEVED ) IF ANY ONE OF THE THREE CONDITIONS IS SATISFIED.
C
C       RMACH   A REAL ARRAY OF LENGTH TWO WHICH IS DEPENDENT
C               UPON THE MACHINE SIGNIFICANCE;
C               SIG (MAXIMUM NUMBER OF SIGNIFICANT
C               DIGITS ) AND SHOULD BE COMPUTED AS FOLLOWS:
C
C               RMACH(1)= 5.0*10.0 **(-SIG+3)
C               RMACH(2)=10.0 **(-(SIG/2)-1)
C
C          WORK SCRATCH ARRAY OF LENGTH 2*M+(N*(N+2*M+9))/2
C               WHOSE CONTENTS ARE
C
C       1 TO JACM1      N*(N+1)/2       LOWER SUPER TRIANGLE OF
C                               JACOBIAN( TRANSPOSED )
C                               TIMES JACOBIAN
C
C       JACESS TO GRDM1         N*M     JACOBIAN MATRIX
C
C       JACSS TO DELEND         N       DELTA X
C
C       GRADSS TO GRDEND        N       GRADIENT
C
C       GRADSS TO DIAGM1        M       INCREMENTED FUNCTION VECTOR
C
C       DIAGSS TO ENDSS N       SCALING VECTOR
C
C       FMNSS TO XBADSS-1       M       DECREMENTED FUNCTION VECTOR
C
C       XBADSS TO XBEND N       LASTEST SINGULAR POINT
C
C               NOTE:
C               SEVERAL WORDS ARE USED FOR TWO DIFFERENT QUANTITIES (E.G.,
C               JACOBIAN AND DELTA X) SO THEY MAY NOT BE AVAILABLE
C               THROUGHOUT THE PROGRAM.
C
C       W       WEIGHTING VECTOR OF LENGTH M
C
C       SLTJJ   ARRAY OF LENGTH N*(N+1)/2 WHICH CONTAINS THE LOWER SUPER
C               TRIANGLE OF J(TRANS)*J RETAINED FROM WORK(1) THROUGH
C               WORK(JACM1) IN DO 30. ELEMENTS STORED SERIALLY AS C(1,1),
C               C(2,1),C(2,2),C(3,1),C(3,2),...,C(N,N). USED IN STATISTICS
C               SUBROUTINES FOR STANDARD DEVIATIONS AND CORRELATION
C               COEFFICIENTS OF PARAMETERS.
C
C       ICONV   AN INTEGER OUTPUT PARAMETER INDICATING SUCCESSFUL
C               CONVERGENCE OR FAILURE
C
C               .GT.  0  MEANS CONVERGENCE IN ITER ITERATION
C                  =  1  CONVERGENCE BY FIRST CRITERION
C                  =  2  CONVERGENCE BY SECOND CRITERION
C                  =  3  CONVERGENCE BY THIRD CRITERION
C               .EQ.  0  MEANS FAILURE TO CONVERGE IN ITMAX ITERATIONS
C               .EQ. -1  MEANS FAILURE TO CONVERGE IN ITER ITERATIONS
C                BECAUSE OF UNAVOIDABLE SINGULARITY WAS ENCOUNTERED
C
C          ITER AN INTEGER OUTPUT PARAMETER WHOSE VALUE IS THE NUMBER OF
C               ITERATIONS USED. THE NUMBER OF FUNCTION EVALUATIONS USED
C               IS ROUGHLY (N+1)*ITER.
C
C          SSQ  THE SUM OF THE SQUARES OF THE RESIDUALS FOR THE CURRENT
C               X AT RETURN.
C
C          F    A REAL ARRAY OF LENGTH M WHICH CONTAINS THE FINAL VALUE
C               OF THE RESIDUALS (THE F(I)'S) .
C
C
C       EXPLANATION OF PARAMETERS ----
C
C               X       CURRENT X VECTOR
C               N       NUMBER OF UNKNOWNS
C               ICONV   CONVERGENCE INDICATOR (SEE ABOVE)
C               ITER    NUMBER OF THE CURRENT ITERATION
C               SSQ     THE NUMBER OF THE SQUARES OF THE RESIDUALS FOR THE
C               CURRENT X
C               ERL2    THE EUCLICEAN NORM OF THE GRADIENT FOR THE CURRENT X
C               GRAD    THE REAL ARRAY OF LENGTH N CONTAINING THE GRADIENT
C               AT THE CURRENT X
C
C               NOTE ----
C
C               N AND ITER MUST NOT BE CHANGED IN PRNOUT
C               X AND ERL2 SHOULD NOT BE CAPRICIOUSLY CHANGED.
C
C
C
C       S.H. BRYANT ---- REVISION MAY 12, 1979  ----
C
C       DEPARTMENT OF PHARACOLOGY AND CELL BIOPHYSICS,
C       COLLEGE OF MEDICINE,
C       UNIVERSITY OF CINCINNATI,
C       231 BETHESDA AVE.,
C       CINCINNATI,
C       OHIO. 45267.
C       TELEPHONE 513/ 872-5621. }

{       Initialisation }


var
   i,j,jk,k,kk,l,jacss,jacm1,delend,GRADSS,GRDEND,GRDM1,FPLSS,FPLM1 : LongInt ;
   DIAGSS,DIAGM1,ENDSS,FMNSS,XBADSS,XBEND,IBAD,NP1,ISW : LongInt ;
   Iis,JS,LI,Jl,JM,KQ,JK1,LIM,JN,MJ : LongInt ;
   PREC,REL,DTST,DEPS,RELCON,RELSSQ,GCrit,ERL2,RN,OldSSQ,HH,XDABS,ParHold,SUM,TT : Single ;
   RHH,DNORM : Single ;
   Quit,Singular,retry,Converged : Boolean ;
   WorkSpaceSize : Integer ;
   Work : ^TWorkArray ;
begin

{ Set machine precision constants }
      PREC := 0.01 ;
      REL := 0.005 ;
      DTST := SQRT1(PREC) ;
      DEPS := SQRT1(REL) ;

      { Set convergence limits }
    {  RELCON := 10.**(-NUMSIG) ;
      RELSSQ := 10.**(-NSIGSQ) ; }
       RELCON := 1E-4 ;
       RELSSQ := 1E-4 ;

      { Set up pointers into WORK buffer }

        JACSS := 1+(nPars*(nPars+1)) div 2 ;
        JACM1 := JACSS-1 ;
        DELEND := JACM1 + nPars ;
        { Gradient }
        GRADSS := JACSS+nPars*nPoints ;
        GRDM1 := GRADSS-1 ;
        GRDEND := GRDM1 + nPars ;
        { Forward trial residuals }
        FPLSS := GRADSS ;
        FPLM1 := FPLSS-1 ;
        { Diagonal elements of Jacobian }
        DIAGSS := FPLSS + nPoints ;
        DIAGM1 := DIAGSS - 1 ;
        ENDSS := DIAGM1 + nPars ;
        { Reverse trial residuals }
        FMNSS := ENDSS + 1 ;
        XBADSS := FMNSS + nPoints ;
        XBEND := XBADSS + nPars - 1 ;
        ICONV := -5 ;
        ERL2 := 1.0E35 ;
        GCRIT := 1.0E-3 ;
        IBAD := -99 ;
        RN := 1. / nPars ;
        NP1 := nPars + 1 ;
        ISW := 1 ;
        ITER := 1 ;

        // Allocate work buffer
        WorkSpaceSize := ((2*nPoints) + (nPars*(nPars+2*nPoints+9)) div 2)*4 ;
        GetMem( Work, WorkSpaceSize ) ;

        { Iterative loop to find best fit parameter values }

        Quit := False ;
        While Not Quit do begin

            { Compute sum of squares
              SSQ :=  W * (Ydata - Yfunction)*(Ydata - Yfunction) }
            SSQ := SSQCAL(Pars,nPoints,nPars,F,1,W,Data) ;

            { Convergence test - 2 Sum of squares nPointsatch to NSIGSQ figures }
            IF ITER <> 1 then begin {125}
                 IF ABS(SSQ-OLDSSQ) <= (RELSSQ*MaxFlt([ 0.5,SSQ])) then begin
                       ICONV := 2 ;
                       break ;
                       end ;
                 end ;
            OLDSSQ := SSQ ;{125}

            { Compute trial residuals by incrementing
              and decrementing X(j) by HH j := 1...N
              R  :=  Zi (Y(i) - Yfunc(i)) i := 1...M }
            K := JACM1 ;
            for J := 1 to nPars do begin

                  { Compute size of increment in parameter }
                  XDABS := ABS(Pars.Value[J]) ;
                  HH := REL*XDABS ;
                  if ISW = 2 then HH := HH*1.0E3 ;
                  if HH <= PREC then HH := PREC ;

                  { Compute forward residuals Rf  :=  X(J)+dX(J) }
                  ParHold := Pars.Value[J] ;
                  Pars.Value[j] := Pars.Value[j] + HH ;
                  FITFUNC(Pars, nPoints, nPars, Work^,FPLSS,Data) ;
                  Pars.Value[j] := ParHold ;

                  { ISW = 1 then skip reverse residuals }
                  IF ISW <> 1 then begin {GO TO 16 }
                         { Compute reverse residual Rr  :=  Pars[j]  -  dPars[j] }
                       Pars.Value[j] := ParHold - HH ;
                       FITFUNC(Pars, nPoints, nPars, Work^,FMNSS, Data ) ;
                       Pars.Value[j] := ParHold ;

                       { Compute gradients (Central differences)
                       Store in JACSS  -  GRDM1
 		       SQRT1(W(j))(Rf(j)  -  Rr)j))/2HH
                       for j := 1..M and  X(i) i := 1..N }

                       L := ENDSS ;
                       RHH := 0.5/HH ;
                       KK := 0 ;
                       for I := FPLSS to DIAGM1 do begin
                           L := L + 1 ;
                           K := K + 1 ;
                           KK := KK + 1 ;
			   Work^[K] := SQRT1(W[KK])*(Work^[I] - Work^[L])*RHH ;
                           end ;
                       end
                  else begin
                        { 16 }
                       { Case of no reverse residuals
                       Forward difference
                       G := SQRT1(W(j)(Rf(j)  -  Ro(j))/HH
                       j := 1..M X(i) i := 1..N }

                       L := FPLM1 ;
                       RHH := 1./HH ;
                       for I := 1 to nPoints do begin
                           K := K + 1 ;
                           L := L + 1 ;
			   Work^[K] := (SQRT1(W[I])*Work^[L] - F[I])*RHH ;
                           end ;
                       end ;
                  end ;
        {20 }
{22      CONTINUE}

{C
C       G2 :=  Z W(j)* ((Rf(j) - Rr(j))/2HH) * Ro(j)
C          j := 1..M
C
C       ERL2  :=  Z G2
C          i := 1..N
C }
            ERL2 := 0. ;
            K := JACM1 ;
            for I := GRADSS to GRDEND do begin
                  SUM := 0. ;
                  for  J := 1 to nPoints do begin
                        K := K + 1 ;
                        SUM := SUM + Work^[K]*F[J] ;
                        end ;
                  Work^[I] := SUM ;
                  ERL2 := ERL2 + SUM*SUM ;
                  end ;

            ERL2 := SQRT1(ERL2) ;

            { Convergence test - 3 Euclidian norm < DELTA }
            IF(ERL2 <= DELTA) then begin
                 ICONV := 3 ;
                 break ;
                 end ;
            IF(ERL2 < GCRIT) then ISW := 2 ;

            { Compute summed cross - products of residual gradients
              Sik  :=  Z Gi(j) * Gk(j)   (i,k := 1...N)
             j := 1...M S11,S12,S22,S13,S23,S33,..... }
            repeat
                  Retry := False ;
                  L := 0 ;
                  Iis := JACM1 - nPoints ;
                  for I := 1 to nPars do begin
                      Iis := Iis + nPoints ;
                      JS := JACM1 ;
                      for J := 1 to I do begin
                          L := L + 1 ;
                          SUM := 0. ;
                          for K := 1 to nPoints do begin
                                LI := Iis + K ;
                                JS := JS + 1 ;
                                SUM := SUM + Work^[LI]*Work^[JS] ;
                                end ;
                          SLTJJ[L] := SUM ;
                          Work^[L] := SUM ;
                          end ;
                      end ;

                  { Compute normalised diagonal matrix
                   SQRT1(Sii)/( SQRT1(Zi (Sii)**2) ) i := 1..N }

                  L := 0 ;
                  J := 0 ;
                  DNORM := 0. ;
                  for I := DIAGSS to ENDSS do begin {34}
                      J := J + 1 ;
                      L := L + J ;
                      Work^[I] := SQRT1(Work^[L]) ;
                      DNORM := DNORM + Work^[L]*Work^[L] ;
                      end ;
                  DNORM := 1./SQRT1(MinFlt([DNORM,3.4E38])) ;
                  for I := DIAGSS to ENDSS do Work^[I] := Work^[I]*DNORM ;

                  { Add ERL2 * Nii i := 1..N
                    Diagonal elements of summed cross - products }

                  L := 0 ;
                  K := 0 ;
                  for J := DIAGSS to ENDSS do begin
                      K := K + 1 ;
                      L := L + K ;
                      Work^[L] := Work^[L] + ERL2*Work^[J] ;
                      IF(IBAD > 0) then Work^[L] := Work^[L]*1.5 + DEPS ;
                      end ;

                  JK := 1 ;
                  Singular := False ;
                  JK1 := 0 ;
                  for I := 1 to nPars do begin {52}
                      JL := JK ;
                      JM := 1 ;
                      for J := 1 to I do begin {52}
                          TT := Work^[JK] ;
                          IF(J <> 1) then begin
                               for K := JL to JK1 do begin
                                   TT := TT - Work^[K]*Work^[JM] ;
                                   JM := JM + 1 ;
                                   end ;
                               end ;
                          IF(I = J) then begin
                               IF (Work^[JK] + TT*RN) <= Work^[JK] then
                                  Singular := True ;{GO TO 76}
		               Work^[JK] := 1./SQRT1(TT) ;
                               end
                          else Work^[JK] := TT*Work^[JM] ;
                          JK1 := JK ;
                          JM := JM + 1 ;
                          JK := JK + 1 ;
                          end ;
                          if Singular then Break ;
                      end ;

                  if Singular then begin

                     { Singularity processing 76 }
                     IF IBAD >= 2 then ReTry := False {GO TO 92}
                     else if iBad < 0 then begin
                          iBad := 0 ;
                          ReTry := True ;
                          {IF(IBAD) 81,78,78 }
                          end
                     else begin
                          J := 0 ; {78}
                          ReTry := False ;
                          for I := XBADSS to XBEND do begin{80}
                              J := J + 1 ;
                              IF(ABS(Pars.Value[j] - Work^[I]) > MaxFlt(
                                          [DTST,ABS(Work^[I])*DTST]) ) then
                                              ReTry := True ;
                              end ; {80}
                          end ;
                     end ;

                  if ReTry then begin
                     J := 0 ; {82}
                     for I := XBADSS to XBEND do begin
                         J := J + 1 ;
                         Work^[I] := Pars.Value[j]
                         end ;
                     IBAD := IBAD + 1 ;
                     end ;
                  until not ReTry ;

            JK := 1 ;
            JL := JACM1 ;
            KQ := GRDM1 ;
            for I := 1 to nPars do begin {60}
                  KQ := KQ + 1 ;
                  TT := Work^[KQ] ;
                  IF JL <> JACM1 then begin
                     JK := JK + JL - 1 - JACM1 ;
                     LIM := I - 1 + JACM1 ;
                     for J := JL to LIM do begin
                         TT := TT - Work^[JK]*Work^[J] ;
                         JK := JK + 1 ;
                         end ;
                     end
                  else begin
                     IF(TT <> 0. ) then JL := JACM1 + I ;
                     JK := JK + I - 1 ;
                     end ;
                  Work^[JACM1 + I] := TT*Work^[JK] ;
                  JK := JK + 1 ;
                  end ; {60}

            for I := 1 to nPars do begin{66}
                  J := NP1 - I + JACM1 ;
                  JK := JK - 1 ;
                  JM := JK ;
                  JN := NP1 - I + 1 ;
                  TT := Work^[J] ;
                  IF (nPars >= JN) then begin {GO TO 64}
                     LI := nPars + JACM1 ;
                     for MJ := JN to nPars do begin
                         TT := TT - Work^[JM]*Work^[LI] ;
                         LI := LI - 1 ;
                         JM := JM - LI + JACM1 ;
                         end ;
                     end ; {64}
                  Work^[J] := TT*Work^[JM] ;
                  end ; {66}

            IF (IBAD <>  - 99 ) then IBAD := 0 ;
            J := JACM1 ;
            for I := 1 to nPars do begin {68}
                  J := J + 1 ;
                  Pars.Value[I] := Pars.Value[I] - Work^[J] ;
                  end ; {68}

            { Convergence condition  -  1
             Xnew  :=  Xold to NUMSIG places 5E - 20 V1.1 .5 in V1. }
            Converged := True ;
            J := JACM1 ;
            for I := 1 to nPars do begin {70}
                  J := J + 1 ;
                  IF ABS(Work^[J]) > (RELCON*MaXFlt([0.5,ABS(Pars.Value[I])])) then
                                  Converged := False ;
                  end ;

            if Converged then begin
                 ICONV := 1 ;
                 Quit := True ;
                 end ;

            ITER := ITER + 1 ;
            IF (ITER > ITMAX) then Quit := True ;
            end ;

        SSQ := SSQCAL(Pars,nPoints,nPars,F,1,W,Data) ;
        Dispose(Work) ;
        end ;


function TMathFunc.SSQCAL(
         const Pars : TPars ;
         nPoints : Integer ;
         nPars : Integer ;
         var Residuals : Array of Single ;
         iStart : Integer ;
         const W : Array of Single ;
         const Data : TXYData
         ) : Single ;

       { Compute sum of squares of residuals }
       { Enter with :
         Pars = Array of function parameters
         nPoints = Number of data points to be fitted
         nPars = Number of parameters in Pars
         Residuals = array of residual differences
         W = array of weights
         Data = Data to be fitted (array of x,y points) }
var
   I : LongInt ;
   SSQ : single ;
begin
	FitFunc(Pars,nPoints,nPars,Residuals,iStart,Data ) ;
        SSQ := 0. ;
        for I := 1 to nPoints do begin
            Residuals[I] := SQRT1(W[I])*Residuals[iStart+I-1] ;
            SSQ := SSQ + Sqr(Residuals[iStart+I-1]) ;
            end ;
        SSQCAL := SSQ ;
        end ;


procedure TMathFunc.FitFunc(
          Const FitPars :TPars ;
          nPoints : Integer ;
          nPars : Integer ;
          Var Residuals : Array of Single ;
          iStart : Integer ;
          Const Data : TXYData
          ) ;
var
   i : Integer ;
begin

     { Un-map parameters from compressed array to normal }
     for i := 1 to nPars do Pars[FitPars.Map[i]] := FitPars.Value[i] ;
     { Convert log-transformed parameters to normal }
     for i := 0 to nPars-1 do if LogPars[i] then Pars[i] := Exp(Pars[i]) ;

     if UseBinWidthsFlag then begin
        { Apply bin width multiplier when fitting probability density
          functions to histograms }
        for i := 0 to nPoints-1 do
            Residuals[iStart+I] := Data.y[I]
                                   - (Data.BinWidth[i]*Value(Data.x[I])) ;
        end
     else begin
        { Normal curve fitting }
        for i := 0 to nPoints-1 do
            Residuals[iStart+I] := Data.y[I]
                                   - Value(Data.x[I]) ;
        end ;
     end ;


procedure TMathFunc.STAT(
          nPoints : Integer ;         { no. of residuals (observations) }
          nPars : Integer ;           { no. of fitted parameters }
          var F : Array of Single ;   { final values of the residuals (IN) }
          var Y : Array of Single ;   { Y Data (IN) }
          var W : Array of Single ;   { Y Data weights (IN) }
          var SLT : Array of Single ; { lower super triangle of
                                        J(TRANS)*J from SLTJJ in SSQMIN (IN) }
          var SSQ : Single;           { Final sum of squares of residuals (IN)
                                        Returned containing parameter corr. coeffs.
                                        as CX(1,1),CX(2,1),CX(2,2),CX(3,1)....CX(N,N)}
          var SDPars : Array of Single ; { OUT standard deviations of each parameter X }
          var SDMIN : Single ;         { OUT Minimised standard deviation }
          var R : Single ;               { OUT Hamilton's R }
          var XPAR : Array of Single     { IN Fitted parameter array }
          ) ;
{C
C       J.DEMPSTER 1 - FEB - 82
C       Adapted from STAT by S.H. Bryant
CC      Subroutine to supply statistics for non - linear least -
C       squares fit of tabular data  by SSQMIN.
C       After minminsation takes J(TRANSPOSE)*J matrix from
C       ssqmin which is stored serially as a lower super tr -
C       angle in SLTJJ(1) through SLTJJ(JACM1). Creates full
C       matrix in C(N,N) which is then inverted to give the var -
C       iance/covariance martix from which standard deviances
C       and correlation coefficients are calculated by the
C       methods of Hamilton (1964).  Hamilton's R is calculated from
C       the data and theoretical values
C
C       Variables in call string:
C
C       M        - Integer no. of residuals (observations)
C       N        - Integer no. of fitted parameters
C       F        - Real array of length M which contains the
C                final values of the residuals
C       Y        - Real array of length M containing Y data
C       W        - Real weighting array of length M
C       SLT      - Real array of length N*(N + 1)/2
C                on input stores lower super triangle of
C                J(TRANS)*J from SLTJJ in SSQMIN
C                on return contains parameter corr. coeffs.
C                as CX(1,1),CX(2,1),CX(2,2),CX(3,1)....CX(N,N)
C       SSQ      - Final sum of squares of residuals
C       SDX      - REal array of length N containing the % standard
C                deviations of each parameter X
C       SDMIN    -        Minimised standard deviation
C       R        -        Hamilton's R
C       XPAR     -        Fitted parameter array
C
C
C       Requires matrix inversion srtn. MINV
C
        DIMENSION Y(M),SLT(1),SDX(N),C(8,8),A(64)
C
        REAL F(M),W(M),XPAR(N)
	INTEGER LROW(8),MCOL(8)
 }
 var
        I,J,L : LongInt ;
        LROW,MCOL : Array[0..8] of LongInt ;
        C : Array[1..8,1..8] of Single ;
        A : Array[0..80] of Single ;
        SUMP,YWGHT,DET : Single ;
 begin
	SDMIN := SQRT1( (SSQ/(nPoints - nPars)) ) ;
        SUMP := 0. ;
        for I := 1 to nPoints do begin
	    YWGHT := Y[I-1]*SQRT1(W[I]) ;
            SUMP := SUMP + Sqr(F[I] + YWGHT) ;
            end ;
        R := SQRT1(MinFlt([3.4E38,SSQ])/SUMP) ;

        { Restore J(TRANSP)*J and place in C(I,J) }

        L := 0 ;
        for I := 1 to nPars do begin
            for J := 1 to I do begin
                L := L + 1 ;
                C[I,J]  :=  SLT[L] ;
                end ;
            end ;

        for I := 1 to nPars do
            for J := 1 to nPars do
                IF (I < J) then C[I,J]  :=  C[J,I] ;

        { Invert C(I,J) }
        L := 0 ;
        for J := 1 to nPars do begin
            for I := 1 to nPars do begin
                L := L + 1 ;
                A[L] := C[I,J] ;
                end ;
            end ;

        MINV (A,nPars,DET,LROW,MCOL) ;

        L := 0 ;
        for J := 1 to nPars do begin
            for I := 1 to nPars do begin
                L := L + 1 ;
                C[I,J] := A[L] ;
                end ;
            end ;

        { Calculate std. dev. Pars[j] }

        for J  :=  1 to nPars do SDPars[j]  :=  SDMIN * SQRT1(ABS(C[J,J])) ;


{C	*** REMOVED since causing F.P. error and not used
C       Calculate correlation coefficients for
C       X(1) on Pars[j]. Return in lower super
C       triangle as X(1,1),X(2,2),X(3,1),X(3,2) ....
C

C	 L := 0
C	 DO 7 I := 1 to N
C	 DO 7 J := 1,I
C	 L := L + 1
C	 SLT(L) := C(I,J)/SQRT1(C(I,I)*C(J,J))
C7	 CONTINUE
	 RETURN}
         end ;

procedure MINV(
          var A : Array of Single ;
          N : LongInt ;
          var D : Single ;
          var L,M : Array of LongInt
          ) ;
{
C           A  -  INPUT MATRIX, DESTROYED IN COMPUTATION AND REPLACED BY
C               RESULTANT INVERSE.
C           N  -  ORDER OF MATRIX A
C           D  -  RESULTANT DETERMINANT
C           L  -  Work^ VECTOR OF LENGTH N
C           M  -  Work^ VECTOR OF LENGTH N
C
C        REMARKS
C           MATRIX A MUST BE A GENERAL MATRIX
C
C
C        METHOD
C           THE STANDARD GAUSS - JORDAN METHOD IS USED. THE DETERMINANT
C           IS ALSO CALCULATED. A DETERMINANT OF ZERO INDICATES THAT
C           THE MATRIX IS SINGULAR.
C
}
var
   NK,K,I,J,KK,IJ,IK,IZ,KI,KJ,JP,JQ,JR,JI,JK : LongInt ;
   BIGA,HOLD : Single ;
begin

      D := 1.0 ;
      NK :=  -N ;
      for K := 1 to N do begin {80}
          NK := NK + N ;
          L[K] := K ;
          M[K] := K ;
          KK := NK + K ;
          BIGA := A[KK] ;
          for J := K to N do begin{20}
              IZ := N*(J - 1) ;
              for I := K to N do begin {20}
                  IJ := IZ + I ;
                  IF( ABS(BIGA) -  ABS(A[IJ])) < 0. then begin {15,20,20}
                      BIGA := A[IJ] ;
                      L[K] := I ;
                      M[K] := J ;
                      end ;
                  end ;
              end ;

          { INTERCHANGE ROWS }

          J := L[K] ;
          IF(J - K) > 0. then begin {35,35,25}
               KI := K - N ;
               for I := 1 to N do begin {30}
                   KI := KI + N ;
                   HOLD :=  - A[KI] ;
                   JI := KI - K + J ;
                   A[KI] := A[JI] ;
                   A[JI]  := HOLD ;
                   end ; {30}
               end ;

          { INTERCHANGE COLUMNS }

          I := M[K] ; {35}
          IF(I - K) > 0. then begin
               JP := N*(I - 1) ;
               for J := 1 to N do begin {40}
                   JK := NK + J ;
                   JI := JP + J ;
                   HOLD :=  - A[JK] ;
                   A[JK] := A[JI] ;
                   A[JI]  := HOLD
                   end ;{40}
               end ;

         { DIVIDE COLUMN BY MINUS PIVOT (VALUE OF PIVOT ELEMENT IS
          CONTAINED IN BIGA }

          IF BIGA = 0. then begin
                  D := 0.0 ;
                  break ;
                  end ;

          for I := 1 to N do begin {55}
              IF(I - K) <> 0 then begin {50,55,50}
                   IK := NK + I ;
                   A[IK] := A[IK]/( -BIGA) ;
                   end ;
              end ; {55}

         { REDUCE MATRIX }

         for I := 1 to N do begin {65}
             IK := NK + I ;
             HOLD := A[IK] ;
             IJ := I - N ;
             for J := 1 to N do begin {65}
                 IJ := IJ + N ;
                 IF(I - K) <> 0 then begin {60,65,60}
                      IF(J - K) <> 0 then begin {62,65,62}
                           KJ := IJ - I + K ;
                           A[IJ] := HOLD*A[KJ] + A[IJ] ;
                           end ;
                      end ;
                 end ;
             end ; {65}

         { DIVIDE ROW BY PIVOT }

         KJ := K - N ;
         for J := 1 to N do begin {75}
             KJ := KJ + N ;
             IF(J <> K) then {70,75,70} A[KJ] := A[KJ]/BIGA ;
             end ; {75}

        { PRODUCT OF PIVOTS }

        D := D*BIGA ;

        { REPLACE PIVOT BY RECIPROCAL }

        A[KK] := 1.0/BIGA ;
        end ;

      { FINAL ROW AND COLUMN INTERCHANGE }

      K := N - 1 ;
      while (K>0) do begin {150,150,105}
              I := L[K] ;{105}
              IF(I - K) > 0 then begin {120,120,108}
                   JQ := N*(K - 1) ; {108}
                   JR := N*(I - 1) ;
                   for J := 1 to N do begin {110}
                       JK := JQ + J ;
                       HOLD := A[JK] ;
                       JI := JR + J ;
                       A[JK] :=  -A[JI] ;
                       A[JI] := HOLD ;
                       end ; {110}
                   end ;
              J := M[K] ;{120}
              IF(J - K) > 0 then begin {100,100,125}
                   KI := K - N ; {125}
                   for I := 1 to N do begin {130}
                       KI := KI + N ;
                       HOLD := A[KI] ;
                       JI := KI - K + J ;
                       A[KI] :=  -A[JI] ;
                       A[JI]  := HOLD ;
                       end ; {130}
                   end ;
              K := (K - 1) ;
              end ;

      end ;


FUNCTION SQRT1 (
         R : single
         ) : single ;
begin
     SQRT1  :=  SQRT( MIN(R,MaxSingle) ) ;
     end ;



function erf(x : Single ) : Single ;
{ --------------
  Error function
  --------------}
var
   t,z,y,erfx : single ;
begin
        if x < 10. then begin
	   z := abs( x )  ;
	   t := 1./( 1. + 0.5*z ) ;
	   y := t*exp( -z*z - 1.26551223 +
      	        t*(1.00002368 + t*(0.37409196 + t*(0.09678418 +
      	        t*( -0.18628806 + t*(0.27886807 + t*( -1.13520398 +
      	        t*(1.48851587 + t*( -0.82215223 + t*0.17087277 ))))))))) ;

           if ( x < 0. ) then y := 2. - y ;
	   erfx := 1. - y ;
           end
        else erfx := 1. ;
        Result := erfx ;
        end ;


function LinearRegression(
         x : Array of Single ;    // X data points (IN)
         y : Array of Single ;    // Y data points (IN)
         n : Integer ;            // No. of (X,Y) data points in line
         var Slope : Single ;     // Slope of line (OUT)
         var YIntercept : Single  // Y intercept (OUT)
         ) : Boolean ;
{ -------------------------------------------------------------
  Calculate slope and y intercept of best fitting straight line
  ------------------------------------------------------------- }
var
   i : Integer ;
   XSum,YSum,XYSum,X2Sum,XMean,YMean : Single ;
begin
     if n > 0 then begin
        if n > (High(x)+1) then n := High(x)+1 ;
        XSum := 0.0 ;
        YSum := 0.0 ;
        XYSum := 0.0 ;
        X2Sum := 0.0 ;
        for i := 0 to n-1 do begin
            XSum := XSum + x[i] ;
            YSum := YSum + y[i] ;
            XYSum := XYSum + x[i]*y[i] ;
            X2Sum := X2Sum + x[i]*x[i] ;
            end ;

        XMean := XSum / n ;
        YMean := YSum / n ;
        if Abs(X2Sum - (XMean*XSum)) > 1E-30 then begin
           Slope := (XYSum - YMean*XSum) / ( X2Sum - XMean*XSum ) ;
           YIntercept := YMean - Slope*XMean ;
           Result := True ;
           end
        else begin
           Slope := 1.0 ;
           YIntercept := 0.0 ;
           Result := False ;
           end ;
        end
     else begin
          Slope := 1.0 ;
          YIntercept := 0.0 ;
          Result := False ;
          end ;
     end ;


function HTMLColorString( Color : TColor ) : String ;
// --------------------------------------------------
// Create HTML colour string from Delphi TColor value
// --------------------------------------------------
var
     iColor : Integer ;
begin
     iColor := Integer(Color) ;
     Result := '#' ;
     Result := Result + format('%.2x',[(iColor and $FF)]) ;
     Result := Result + format('%.2x',[((iColor div 256) and $FF)]) ;
     Result := Result + format('%.2x',[((iColor div (256*256)) and $FF)]) ;
     end ;


procedure Spline(
         var X : Array of Single ;
         var Y : Array of Single ;
         N : Integer ;
         var Y2 : Array of Single
         ) ;
var
    i,k : Integer ;
    sig,P,qn,un : single ;
    U : Array[0..1000] of Single ;
begin

    Y2[0] := 0.0 ;
    U[0] := 0.0 ;
    for i := 1 to N-2 do begin
        sig := (X[i] - X[i-1])/(X[i+1] - X[i-1]) ;
        P := sig*Y2[i-1] + 2.0 ;
        Y2[i] := (sig - 1.0) / P ;
        U[i] := (6.0 - ((Y[i+1] - Y[i])/(X[i+1] - X[i]) / (X[i] - X[i-1]))
                /(X[i+1] - X[i-1]) - sig*U[i-1])/P ;
        end ;

    qn := 0.0 ;
    un := 0.0 ;
    Y2[N-1] := (un - qn*U[N-1]) / (qn*Y2[n-1] + 1.0 ) ;
    for k := N-2 downto 0 do begin
        Y2[k] := Y2[k]*Y2[k] + U[k] ;
        end ;

    end ;

procedure Splint(
          var XA : Array of Single ;
          var YA : Array of Single ;
          var Y2A : Array of Single ;
          N : Integer ;
          X : Single ;
          Y : Single ) ;
var
    K,KLo,KHi : Integer ;
    A,B,H : Single ;
begin

    KLo := 0 ;
    KHi := N-1 ;
    while KHi - KLo > 1 do begin
        K := (KHi - KLo) div 2 ;
        if XA[K] > X then KHi := K
                     else KLo := K ;
        end ;

    H := XA[KHi] - XA[KLo] ;
    //if H = 0.0

    A := (XA[KHi] - X)/H ;
    B := (X - XA[KLo])/H ;
    Y := A + YA[KLo] + B*YA[KHi] +
         ((Power(A,3)-A)*Y2A[KLo] + (Power(B,3)-B)*Y2A[KHi])*(H*H)/6.0 ;
    end ;

function RoundToNearestMultiple(
         Value : Double ;
         Factor : Double ) : Double ;
// -------------------------------
// Round value to nearest multiple
// -------------------------------
begin

   if Factor = 0.0 then begin
      Result := Value ;
      Exit ;
      end;
   Result := int(Value/Factor)*Factor ;
   if Frac(Value/Factor) >= 0.5 then Result := Result + Factor ;
   end;

function ExtractInt ( CBuf : string ) : longint ;
{ ---------------------------------------------------
  Extract a 32 bit integer number from a string which
  may contain additional non-numeric text
  ---------------------------------------------------}

Type
    TState = (RemoveLeadingWhiteSpace, ReadNumber) ;
var
    CNum : string ;
    i : integer ;
    Quit : Boolean ;
    State : TState ;

begin

     if CBuf = '' then begin
        Result := 0 ;
        Exit ;
        end ;

     CNum := '' ;
     i := 1;
     Quit := False ;
     State := RemoveLeadingWhiteSpace ;
     while not Quit do begin

           case State of

                { Ignore all non-numeric characters before number }
                RemoveLeadingWhiteSpace : begin
                   if CBuf[i] in ['0'..'9','+','-'] then State := ReadNumber
                                                    else i := i + 1 ;
                   end ;

                { Copy number into string CNum }
                ReadNumber : begin
                    {End copying when a non-numeric character
                    or the end of the string is encountered }
                    if CBuf[i] in ['0'..'9','E','e','+','-','.'] then begin
                       CNum := CNum + CBuf[i] ;
                       i := i + 1 ;
                       end
                    else Quit := True ;
                    end ;
                else end ;

           if i > Length(CBuf) then Quit := True ;
           end ;
     try


        ExtractInt := StrToInt( CNum ) ;
     except
        ExtractInt := 1 ;
        end ;
     end ;


function VerifyInt( text : string ; LoLimit,HiLimit : LongInt ) : string ;
{ -------------------------------------------------------------
  Ensure an ASCII edit field contains a value within set limits
  -------------------------------------------------------------}
var
   Value : LongInt ;
begin
     Value := ExtractInt( text ) ;
     if Value < LoLimit then Value := LoLimit ;
     If Value > HiLimit then Value := HiLimit ;
     VerifyInt := IntToStr( Value ) ;
     end ;


function ExtractListOfFloats ( const CBuf : string ;
                                var Values : Array of Single ;
                                PositiveOnly : Boolean ) : Integer ;
{ -------------------------------------------------------------
  Extract a series of floating point number from a string which
  may contain additional non-numeric text
  ---------------------------------------}

var
   CNum,dsep : string ;
   i,nValues : integer ;
   EndOfNumber : Boolean ;
begin
     nValues := 0 ;
     CNum := '' ;
     for i := 1 to length(CBuf) do begin

         { If character is numeric ... add it to number string }
         if PositiveOnly then begin
            { Minus sign is treated as a number separator }
            if CBuf[i] in ['0'..'9', 'E', 'e', '.','+',',' ] then begin
               CNum := CNum + CBuf[i] ;
               EndOfNumber := False ;
               end
            else EndOfNumber := True ;
            end
         else begin
            { Positive or negative numbers }
            if CBuf[i] in ['0'..'9', 'E', 'e', '.', '-','+',',' ] then begin
               CNum := CNum + CBuf[i] ;
               EndOfNumber := False ;
               end
            else EndOfNumber := True ;
            end ;

         { Correct for use of comma/period as decimal separator }
         {$IF CompilerVersion > 7.0} dsep := formatsettings.DECIMALSEPARATOR ;
         {$ELSE} dsep := DECIMALSEPARATOR ;
         {$IFEND}
         if dsep = '.' then CNum := ANSIReplaceText(CNum ,',',dsep);
         if dsep = ',' then CNum := ANSIReplaceText(CNum, '.',dsep);

         { If all characters are finished ... check number }
         if i = length(CBuf) then EndOfNumber := True ;

         if (EndOfNumber) and (Length(CNum) > 0)
            and (nValues <= High(Values)) then begin
              try
                 Values[nValues] := StrToFloat( CNum ) ;
                 CNum := '' ;
                 Inc(nValues) ;
              except
                    on E : EConvertError do CNum := '' ;
                    end ;
              end ;
         end ;
     { Return number of values extracted }
     Result := nValues ;
     end ;

function PrinterPointsToPixels(
         PointSize : Integer
         ) : Integer ;
var
   PixelsPerInch : single ;
begin

     { Get height and width of page (in mm) and calculate
       the size of a pixel (in cm) }
     PixelsPerInch := GetDeviceCaps( printer.handle, LOGPIXELSX ) ;
     PrinterPointsToPixels := Trunc( (PointSize*PixelsPerInch) / 72. ) ;
     end ;


function PrinterCmToPixels(
         const Axis : string;
         cm : single
         ) : Integer ;
{ -------------------------------------------
  Convert from cm (on printer page) to pixels
  -------------------------------------------}
var
   PixelWidth,PixelHeight : single ;
begin
     { Get height and width of page (in mm) and calculate
       the size of a pixel (in cm) }
     if UpperCase(Axis) = 'H' then begin
        { Printer pixel width (mm) }
        PixelWidth := GetDeviceCaps( printer.handle, HORZSIZE ) ;
        Result := Trunc( ( 10. * cm * printer.pagewidth) / PixelWidth );
        end
     else begin
        { Printer pixel height (mm) }
        PixelHeight := GetDeviceCaps( printer.handle, VERTSIZE ) ;
        Result := Trunc( ( printer.pageheight * 10. * cm )/ PixelHeight ) ;
        end ;
     end ;





end.
