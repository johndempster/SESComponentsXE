unit HekaUnit;
//
// HEKA patch clamps & Instrutech interfaces
// 08.09.10

interface

  uses WinTypes,Dialogs, SysUtils, WinProcs,mmsystem, math, classes ;

const
// defines for DA and AD channel numbering:
LIH_MaxAdcChannels =       16 ;
LIH_MaxDacChannels =       8 ;
LIH_DigitalInChannel =     16 ;
LIH_DigitalOutChannel =    8 ;

// defines of AcquisitionMode values:
LIH_EnableDacOutput =      1 ;
LIH_DontStopDacOnUnderrun = 2 ;
LIH_DontStopAdcOnOverrun = 4 ;
LIH_TriggeredAcquisition = 8 ;

LIH_Success =         0 ;

LIH_ITC16Board =      0 ;
LIH_ITC18Board =      1 ;
LIH_LIH1600Board =    2 ;
LIH_LIH88Board =      3 ;


LIH_StatusUnknown =    0 ;
LIH_StatusLocked =     1 ;
LIH_StatusIdle =       2 ;
LIH_StatusBusy =       3 ;
LIH_StatusAdcOverflow = 4 ;


// defines for EPC9_SetMuxPath:
  EPC9_F2Ext = 0 ;
  EPC9_Imon1 = 1 ;
  EPC9_Vmon =  2 ;

// defines for EPC9_Get/SetExtStimPath:
  EPC9_ExtStimOff =      0 ;
  EPC9_ExtStimStimDac =  1 ;
  EPC9_ExtStimInput =    2 ;

// defines for EPC9_SetCCGain:
  EPC9_CC1pA = 0 ;
  EPC9_CC10pA =          1 ;
  EPC9_CC100pA =         2 ;

// defines for EPC9_CCTrackTaus:
  EPC9_TauOff =          0 ;
  EPC9_Tau1 =  1 ;
  EPC9_Tau3 =  2 ;
  EPC9_Tau10 = 3 ;
  EPC9_Tau30 = 4 ;
  EPC9_Tau100 =          4 ;

  EPC9_RsModeOff =        0 ;
  EPC9_RsMode100us =      1 ;
  EPC9_RsMode10us =      2 ;
  EPC9_RsMode2us =       3 ;

  EPC9_Success =         0 ;
  EPC9_NoScaleFiles =    22 ;
  EPC9_MaxFileLength =   10240 ;

  EPC9_Epc7Ampl =        0 ;
  EPC9_Epc8Ampl =        1 ;
  EPC9_Epc9Ampl =        2 ;
  EPC9_Epc10Ampl =        3 ;
  EPC9_Epc10PlusAmpl =   4 ;
  EPC9_Epc10USB =        5 ;

EPC8_StrobeBit = 14 ;
EPC8_DisableBit = 15 ;

type

TEPC8_BandwidthType = (
                      EPC8_Filter100Hz,
                      EPC8_Filter300Hz,
                      EPC8_Filter500Hz,
                      EPC8_Filter700Hz,
                      EPC8_Filter1kHz,
                      EPC8_Filter3kHz,
                      EPC8_Filter5kHz,
                      EPC8_Filter7kHz,
                      EPC8_Filter10kHz,
                      EPC8_Filter20kHz,
                      EPC8_Filter30kHz,
                      EPC8_FilterFull);

TEPC8_GainType=  (
                      EPC8_Gain5MOhm = 0,   // i.e. 0.005 mV/pA
                      EPC8_Gain10MOhm,
                      EPC8_Gain20MOhm,
                      EPC8_Gain50MOhm,
                      EPC8_Gain100MOhm,
                      EPC8_Gain200MOhm,
                      EPC8_GainNone1,
                        // MEDIUM range:
                      EPC8_Gain500MOhm,
                      EPC8_Gain1GOhm,       // i.e. 1.0 mV/pA
                      EPC8_Gain2GOhm,
                      EPC8_Gain5GOhm,
                      EPC8_Gain10GOhm,
                      EPC8_Gain20GOhm,
                      EPC8_GainNone2,
                        // HIGH range:
                      EPC8_Gain50GOhm,
                      EPC8_Gain100GOhm,
                      EPC8_Gain200GOhm,
                      EPC8_Gain500GOhm,
                      EPC8_Gain1TOhm        // i.e. 1000 mV/pA
                      ) ;

TEPC8_ModeType = (
                      EPC8_ModeTest,
                      EPC8_ModeSearch,
                      EPC8_ModeVC,
                      EPC8_ModeCC,
                      EPC8_ModeCCcomm,
                      EPC8_ModeCCFast,
                      EPC8_ModeUnknown);



TEPC9_StateType = packed record
     StateVersion : Array[0..7] of ANSIChar ;
     CalibDate : Array[0..15] of ANSIChar ;
     RealCurrentGain : Double ;
     RealF2Bandwidth : Double ;
     F2Frequency : Double ;
     RsValue : Double ;
     RsFraction : Double ;
     GLeak : Double ;
     CFastAmp1 : Double ;
     CFastAmp2 : Double ;
     CFastTau : Double ;
     CSlow : Double ;
     GSeries : Double ;
     StimDacScale : Double ;
     CCStimScale : Double ;
     VHold : Double ;
     LastVHold : Double ;
     VpOffset : Double ;
     VLiquidJunction : Double ;
     CCIHold : Double ;
     CSlowStimVolts : Double ;
     CCTrackVHold : Double ;
     TimeoutLength : Double ;
     SearchDelay : Double ;
     MConductance : Double ;
     MCapacitance : Double ;
     RsTau : Double ;
     StimFilterHz : Double ;
     SerialNumber : Array[0..7] of ANSIChar ;
     E9Boards : SmallInt ;
     CSlowCycles : SmallInt ;
     IMonAdc : SmallInt ;
     VMonAdc : SmallInt ;
     MuxAdc : SmallInt ;
     TstDac : SmallInt ;
     StimDac : SmallInt ;
     StimDacOffset : SmallInt ;
     MaxDigitalBit : SmallInt ;
     SpareInt1 : SmallInt ;
     SpareInt2 : SmallInt ;
     SpareInt3 : SmallInt ;
     AmplKind : Byte ;
     IsEpc9N : ByteBool ;
     ADBoard : Byte ;
     BoardVersion : ANSIChar ;
     ActiveE9Board : Byte ;
     Mode : Byte ;
     Range : Byte ;
     F2Response : Byte ;
     RsOn : ByteBool ;
     CSlowRange : Byte ;
     CCRange : Byte ;
     CCGain : Byte ;
     CSlowToTstDac : ByteBool ;
     StimPath : Byte ;
     CCTrackTau : Byte ;
     WasClipping : ByteBool ;
     RepetitiveCSlow : ByteBool ;
     LastCSlowRange : Byte ;
     Locked : ByteBool ;
     CanCCFast : ByteBool ;
     CanLowCCRange : ByteBool ;
     CanHighCCRange : ByteBool ;
     CanCCTracking : ByteBool ;
     HasVmonPath : ByteBool ;
     HasNewCCMode : ByteBool ;
     Selector : ANSIChar ;
     HoldInverted : ByteBool ;
     AutoCFast : Byte ;
     AutoCSlow : Byte ;
     HasVmonX100 : ByteBool ;
     TestDacOn : ByteBool ;
     QMuxAdcOn : ByteBool ;
     RealImon1Bandwidth : Double ;
     StimScale : Double ;
     Gain : Byte ;
     Filter1 : Byte ;
     StimFilterOn : ByteBool ;
     RsSlow : ByteBool ;
     StateInited : ByteBool ;
     CCCFastOn : ByteBool ;
     CCFastSpeed : ByteBool ;
     F2Source : Byte ;
     TestRange : Byte ;
     TestDacPath : Byte ;
     MuxChannel : Byte ;
     MuxGain64 : ByteBool ;
     VmonX100 : ByteBool ;
     IsQuadro : ByteBool ;
     F1Mode : Byte ;
     CSlowNoGLeak : ByteBool ;
     SelHold : Double ;
	   Spare : Array[0..63] of ANSIChar ;
     end ;

PEPC9_StateType = ^TEPC9_StateType ;

TEPC9_GetMuxAdcOffset= function  : LongInt ; stdcall ;

TEPC9_GetStimDacOffset= function  : LongInt ; stdcall ;

TEPC9_AutoCFast= function : LongInt ; stdcall ;

TEPC9_AutoCSlow= function : LongInt ; stdcall ;

TEPC9_AutoGLeak= function : LongInt ; stdcall ;

TEPC9_AutoSearch= function : LongInt ; stdcall ;

TEPC9_AutoVpOffset= function : LongInt ; stdcall ;

TEPC9_Reset= function : LongInt ; stdcall ;

TEPC9_ResetTempState= function  : LongInt ; stdcall ;

TEPC9_FlushCache= function  : LongInt ; stdcall ;

TEPC9_GetLastError= function   : LongInt ; stdcall ;

TEPC9_Shutdown= function   : LongInt ; stdcall ;

TEPC9_GetClipping= function  : LongInt ; stdcall ;

TEPC9_GetIpip= function(Samples : Integer ) : Double ; stdcall ;

TEPC9_GetRMSNoise= function : Double ; stdcall ;

TEPC9_GetStateAdr= function : Pointer ; stdcall ;

TEPC9_GetEpc9NStateAdr= function (BoardIndex : Integer ) : Pointer ; stdcall ;

TEPC9_GetVmon= function (Samples : Integer) : Double ; stdcall ;

TEPC9_SetCCFastSpeed= function(CCSpeed : Boolean ) : LongInt ; stdcall ;

TEPC9_SetCCIHold= function(Amperes : Double) : LongInt ; stdcall ;

TEPC9_SetCCStimScale= function( Siemens: Double) : LongInt ; stdcall ;

TEPC9_SetCFast1= function( Farads: Double) : LongInt ; stdcall ;

TEPC9_SetCFast2= function( Farads: Double) : LongInt ; stdcall ;

TEPC9_SetCFastTau= function( Seconds: Double) : LongInt ; stdcall ;

TEPC9_GetCFastTauReal= function : Double ; stdcall ;

TEPC9_SetCFastTauReal= function( Tau: Double) : LongInt ; stdcall ;

TEPC9_SetCSlow= function( Farads: Double) : LongInt ; stdcall ;

TEPC9_SetCSlowCycles= function( Cycles : Integer ) : LongInt ; stdcall ;

TEPC9_SetCSlowPeak= function( Peak: Double) : LongInt ; stdcall ;

TEPC9_SetCSlowRange= function( Range : Integer ) : LongInt ; stdcall ;

TEPC9_SetCSlowRepetitive= function(Repetitive : LongBool ) : LongInt ; stdcall ;

TEPC9_SetCurrentGain= function( NewGain: Double) : LongInt ; stdcall ;

TEPC9_SetCurrentGainIndex= function( GainIndex : Integer ) : LongInt ; stdcall ;

TEPC9_SetCCGain= function( NewCCGain : Integer ) : LongInt ; stdcall ;

TEPC9_SetE9Board= function( E9Board : Integer ) : LongInt ; stdcall ;

TEPC9_GetExtStimPath= function : LongInt ; stdcall ;

TEPC9_SetExtStimPath= function(
                      Factor : Double ;
                      Path : Integer
                      ) : LongInt ; stdcall ;

TEPC9_SetF1Index= function(
                  Filter1 : Integer ) : LongInt ; stdcall ;

TEPC9_SetF1Bandwidth= function( Bandwidth : Double) : LongInt ; stdcall ;

TEPC9_SetF2Bandwidth= function( Bandwidth : Double) : LongInt ; stdcall ;

TEPC9_SetF2Butterworth= function(SetButterworth : LongBool ) : LongInt ; stdcall ;

TEPC9_SetGLeak= function( Siemens : Double) : LongInt ; stdcall ;

TEPC9_SetGSeries= function( Siemens : Double) : LongInt ; stdcall ;

TEPC9_SetMode= function(
               Mode : Integer ;
               Gently : LongBool
               ) : LongInt ; stdcall ;

TEPC9_SetMuxPath= function( MuxPath : Integer ) : LongInt ; stdcall ;

TEPC9_SetRsFraction= function( Fraction : Double) : LongInt ; stdcall ;

TEPC9_SetRsMode= function( NewRsMode : Integer ) : LongInt ; stdcall ;

     TEPC9_GetRsMode= function  : LongInt ; stdcall ;

TEPC9_SetRsValue= function( Ohms : Double ) : LongInt ; stdcall ;

TEPC9_SetStimFilterOn= function(StimFilterOn : LongBool ) : LongInt ; stdcall ;

TEPC9_SetTimeout= function( Timeout : Double) : LongInt ; stdcall ;

TEPC9_SetVHold= function( Volts : Double) : LongInt ; stdcall ;

TEPC9_SetVLiquidJunction= function( Volts : Double) : LongInt ; stdcall ;

TEPC9_SetVpOffset= function( Volts : Double) : LongInt ; stdcall ;

TEPC9_SetCCTrackHold= function( TrackVHold : Double) : LongInt ; stdcall ;

TEPC9_SetCCTrackTau= function( Tau : Double) : LongInt ; stdcall ;

TEPC9_GetErrorText= function(Msg : PANSIChar ) : LongInt ; stdcall ;

TEPC9_SetLastVHold= function : LongInt ; stdcall ;

TEPC9_InitializeAndCheckForLife= function(
            ErrorMessage : PANSIChar ;
            var FirstError : Integer ;
            var LastError : Integer ;
            IAmplifier : Integer ;
            LoadScaleProc : Pointer ;
            LoadCFastProc : Pointer ) : LongInt ; stdcall ;

TEPC9_FinishInitialization= function(
            ForceAmplifier : LongBool ;
            Version : ANSIChar ;
            E9Boards : Integer ) : LongInt ; stdcall ;

TEPC9_LoadScaleFiles= function(
            ErrorMessage : PANSIChar ;
            var FirstError : Integer ;
            var LastError : Integer ;
            LoadScaleProc : Pointer ;
            LoadCFastProc : Pointer ) : LongInt ; stdcall ;

TEPC8_EncodeFilter= function( Filter : Double ) : Word ; stdcall ;

TEPC8_DecodeFilter= function(AllBits : Word ) : Double ;

TEPC8_DecodeGain= function(AllBits : Word ) : LongInt ; stdcall ;

TEPC8_EncodeGain= function(
            Gain : Integer ;
            var Bits1 : Word ;
            var Bits2 : Word ) : LongInt ; stdcall ;

TEPC8_DecodeMode= function(AllBits : Word) : LongInt ; stdcall ;

TEPC8_EncodeMode= function( ModeToSet : Integer ): LongInt ; stdcall ;

TEPC8_DecodeRemote= function(AllBits : Word) : LongInt ; stdcall ;

TEPC8_EncodeRemote= function(RemoteActive : LongBool ) : Word ; stdcall ;

TEPC8_SendToEpc8= function(Epc8Value: Word) : LongInt ; stdcall ;

TLIH_StartStimAndSample= function(
            DacChannelNumber : Integer ;
            AdcChannelNumber : Integer ;
            DacSamplesPerChannel : Integer ;
            AdcSamplesPerChannel : Integer ;
            AcquisitionMode : Word ;
            pDAChannelList : Pointer ;
            pADChannelList : Pointer ;
            var SampleInterval : Double ;
            OutData : Pointer ;
            SetStimEnd : LongInt ;
            ReadContinuously: LongInt) : LongInt ; stdcall ;

TLIH_AvailableStimAndSample= function(var StillRunning : LongBool ) : LongInt ; stdcall ;

TLIH_DoneStimAndSample= function(
            AdcSamplesPerChannel : Integer ;
            var StillRunning : Integer
            ) : LongInt ; stdcall ;


TLIH_ReadStimAndSample= function(
            AdcSamplesPerChannel : Integer ;
            DoHalt : Integer ;
            InData : Pointer
            ) : LongInt ; stdcall ;


TLIH_AppendToFIFO= function(
            DacSamplesPerChannel : Integer ;
            SetStimEnd: LongInt ;
            OutData : Pointer
            ) : LongInt ; stdcall ;

TLIH_Halt= function : LongInt ; stdcall ;

TLIH_ForceHalt= function : LongInt ; stdcall ;

TLIH_ReadAdc= function( Channel : Integer ) : Integer ; stdcall ;


TLIH_ReadDigital= function( Channel : Integer ) : Word  ; stdcall ;


TLIH_ReadAll= function(
            AdcVoltages : Pointer ;
            var DigitalPort : Word ;
            Interval : Double ): LongInt ; stdcall ;

TLIH_SetDac= function(
             Channel : Integer ;
             Value : Integer ): LongInt ; stdcall ;

TLIH_SetDigital= function(
            Channel : Integer ;
            Value : Word
            ): LongInt ; stdcall ;

TLIH_VoltsToDacUnits= function(
                      DacChannel : Integer ;
                      var Volts : Double ): LongInt ; stdcall ;

TLIH_AdcUnitsToVolts= function(
            AdcChannel : Integer ;
            AdcUnits : Integer
            ) : Double ; stdcall ;

TLIH_CheckSampleInterval= function( SamplingInterval: Double ): LongInt ; stdcall ;


TLIH_Status= function : LongInt ; stdcall ;

TLIH_SetInputRange= function(
            AdcChannel : Integer ;
            Range : Integer ): LongInt ; stdcall ;

TLIH_InitializeInterface= function(
            Amplifier : Integer ;
            ADBoard : Integer ): LongInt ; stdcall ;

TLIH_Shutdown= function : LongInt ; stdcall ;

TLIH_SetBoardNumber= function( BoardNumber : Integer ): LongInt ; stdcall ;

     TLIH_GetBoardType= function : LongInt ; stdcall ;

TLIH_GetErrorText= function(Text : Pointer ): LongInt ; stdcall ;

TLIH_GetBoardInfo= function(
             var SecPerTick : Double ;
             var MinSamplingTime: Double ;
             var MaxSamplingTime: Double ;
             var FIFOLength : Integer ;
             var NumberOfDacs : Integer ;
             var NumberOfAdcs : Integer ): LongInt ; stdcall ;


TTIB14_Present= function : LongInt ; stdcall ;

TTIB14_Initialize= function : LongInt ; stdcall ;


TPSA12_Initialize= function(ErrorMessage : Pointer ): LongInt ; stdcall ;

TPSA12_Shutdown= function : LongInt ; stdcall ;

TPSA12_IsOpen= function : LongInt ; stdcall ;

TPSA12_SetTone= function(
              Frequency : Double ;
              Amplitude: Double ;
              ErrorMessage : Pointer ): LongInt ; stdcall ;


TEPC9_DLLVersion= function : LongInt ; stdcall ;


  procedure HEKA_InitialiseBoard ;
  procedure HEKA_LoadLibrary  ;

  procedure HEKA_ConfigureHardware(
            EmptyFlagIn : Integer ) ;

  function  HEKA_ADCToMemory(
            HostADCBuf : Pointer ;
            NumADCChannels : Integer ;
            NumADCSamples : Integer ;
            var dt : Double ;
            ADCVoltageRange : Single ;
            TriggerMode : Integer ;
            CircularBuffer : Boolean
            ) : Boolean ; stdcall ;

  function HEKA_StopADC : Boolean ;

  procedure HEKA_GetADCSamples(
            var OutBuf : Array of SmallInt ;
            var OutBufPointer : Integer
            ) ;

  procedure HEKA_CheckSamplingInterval(
            var SamplingInterval : Double ) ;


  function  HEKA_MemoryToDACAndDigitalOut(
          var DACValues : Array of SmallInt  ; // D/A output values
          NumDACChannels : Integer ;                // No. D/A channels
          NumDACPoints : Integer ;                  // No. points per channel
          var DigValues : Array of SmallInt  ; // Digital port values
          DigitalInUse : Boolean ;             // Output to digital outs
          ExternalTrigger : Boolean ;           // Wait for ext. trigger
          RepeatWaveform  : Boolean            // Repeat output waveform
          ) : Boolean ;                        // before starting output

  function HEKA_GetDACUpdateInterval : Double ;

  function HEKA_StopDAC : Boolean ;

  procedure HEKA_WriteDACsAndDigitalPort(
            var DACVolts : array of Single ;
            nChannels : Integer ;
            DigValue : Integer
            ) ;

  function  HEKA_GetLabInterfaceInfo(
            InterfaceTypeIn : Integer ;
            var Model : string ; { Laboratory interface model name/number }
            var ADCMaxChannels : Integer ;
            var ADCMinSamplingInterval : Double ; { Smallest sampling interval }
            var ADCMaxSamplingInterval : Double ; { Largest sampling interval }
            var ADCMinValue : Integer ; { Negative limit of binary ADC values }
            var ADCMaxValue : Integer ; { Positive limit of binary ADC values }
            var ADCVoltageRanges : Array of single ; { A/D voltage range option list }
            var NumADCVoltageRanges : Integer ; { No. of options in above list }
            var ADCBufferLimit : Integer ;      { Max. no. samples in A/D buffer }
            var DACMaxChannels : Integer ;
            var DACMaxVolts : Single ; { Positive limit of bipolar D/A voltage range }
            var DACMinUpdateInterval : Double {Min. D/A update interval }
            ) : Boolean ;

  function HEKA_GetMaxDACVolts : single ;

  function HEKA_ReadADC( Channel : Integer ) : SmallInt ;

  procedure HEKA_GetChannelOffsets(
            var Offsets : Array of Integer ;
            NumChannels : Integer
            ) ;

  procedure HEKA_CloseLaboratoryInterface ;

  function  HEKA_LoadProcedure(
         Hnd : THandle ;       { Library DLL handle }
         Name : string         { Procedure name within DLL }
         ) : Pointer ;         { Return pointer to procedure }

function EPC9_LoadFileProcType(
         FileName : PANSIChar ;
         var DataStart : Pointer ;
         var FileSize : Integer ;
         MustLocate : LongBool ) : Integer ; cdecl ;



   function TrimChar( Input : Array of ANSIChar ) : string ;
   procedure HEKA_CheckError( OK : ByteBool ) ;

   procedure HEKA_FillOutputBufferWithDefaultValues ;

   function Heka_GetEPCState : Pointer ;

   procedure Heka_GetCurrentGain(
          var Gain : Single  ;
          var ScaleFactor : Single ) ;

   procedure Heka_GetCurrentGainList( List : TStrings ) ;

   procedure Heka_SetCurrentGain( iGain : Integer )  ;

   procedure Heka_SetFilterMode(
          iFilterNum : Integer ;
          iFilterMode : Integer  )  ;

   procedure Heka_GetFilterMode(
          iFilterNum : Integer ;
          var iFilterMode : Integer )  ;

   procedure Heka_SetFilterBandwidth(
          iFilterNum : Integer ;
          Bandwidth : Single )  ;

   procedure Heka_GetFilterBandwidth(
          iFilterNum : Integer ;
          var Bandwidth : Single )  ;

    procedure Heka_SetCfast( Num : Integer ; var Value : Single ) ;
    procedure Heka_GetCfast( Num : Integer ; var Value : Single ) ;
    procedure Heka_SetCfastTau( var Value : Single ) ;
    procedure Heka_GetCfastTau( var Value : Single ) ;
    procedure Heka_SetCslow( var Value : Single ) ;
    procedure Heka_GetCslow( var Value : Single ) ;
    procedure Heka_SetGseries( var Value : Single ) ;
    procedure Heka_GetGseries( var Value : Single ) ;
    procedure Heka_SetCslowRange( var Value : Integer ) ;
    procedure Heka_GetCslowRange( var Value : Integer ) ;
    procedure Heka_SetGleak( var Value : Single ) ;
    procedure Heka_GetGleak( var Value : Single ) ;
    procedure Heka_SetRSValue( var Value : Single ) ;
    procedure Heka_GetRSValue( var Value : Single ) ;
    procedure Heka_SetRsFraction( var Value : Single ) ;
    procedure Heka_GetRsFraction( var Value : Single ) ;
    procedure Heka_SetRsMode( var Value : Integer ) ;
    procedure Heka_GetRsMode( var Value : Integer ) ;
    procedure Heka_SetMode( var Value : Integer ) ;
    procedure Heka_GetMode( var Value : Integer ) ;
    procedure Heka_SetVHold( var Value : Single ) ;
    procedure Heka_GetVHold( var Value : Single ) ;
    procedure Heka_SetVLiquidJunction( var Value : Single ) ;
    procedure Heka_GetVLiquidJunction( var Value : Single ) ;
    procedure Heka_SetVPOffset( var Value : Single ) ;
    procedure Heka_GetVPOffset( var Value : Single ) ;
    procedure Heka_SetCCTrackHold( var Value : Single ) ;
    procedure Heka_GetCCTrackHold( var Value : Single ) ;
    procedure Heka_SetCCTrackTau( var Value : Single ) ;
    procedure Heka_GetCCTrackTau( var Value : Single ) ;
    procedure Heka_AutoCFast ;
    procedure Heka_AutoCSlow ;
    procedure Heka_AutoGLeak ;
    procedure Heka_AutoSearch ;
    procedure Heka_AutoVpOffset ;

implementation

uses seslabio ;

const
    HEKA_MaxADCSamples = 32768*16 ;
    NumPointsPerBuf = 256 ;
    MaxBufs = (HEKA_MaxADCSamples div NumPointsPerBuf) + 2 ;
var
   InterfaceType : Integer ;
   ADCNumSamplesRequired : Integer ;
   FADCVoltageRangeMax : single ;    // Max. positive A/D input voltage range
   FADCMinValue : Integer ;          // Max. binary A/D sample value
   FADCMaxValue : Integer ;          // Min. binary A/D sample value
   FDACMinUpdateInterval : Double ;  // Min. D/A update interval= function(s)

   MinSamplingInterval : double ;  // Min. sampling interval(s)
   MaxSamplingInterval : double ;  // Max. sampling interval(s)
   SamplingIntervalStepSize : double ;
   SamplingInterval : double ;

   FIFOMaxPoints : Integer ;

   FDACVoltageRangeMax : single ;      // Max. D/A voltage range(+/-V)

   DeviceInitialised : Boolean ; { True if hardware has been initialised }

   AINumChannels : Integer ;
   AIMaxChannels : Integer ;
   AIChannelList : Array[0..LIH_MaxAdcChannels-1] of Word ;

   AICircularBuffer : Boolean ;     // TRUE = repeated buffer fill mode
   AIBuf : PSmallIntArray ;
   AIPointer : Integer ;
   AINumSamples : Integer ;        // Input buffer size= function(no. samples)
   AIDataBufs : Array[0..LIH_MaxAdcChannels-1] of PSmallIntArray ;

   ADCActive : Boolean ;  // A/D sampling in progress flag
   DACActive : Boolean ;  // D/A output in progress flag

   Err : Integer ;                           // Error number returned by Digidata
   ErrorMsg : Array[0..80] of ANSIchar ;         // Error messages returned by Digidata

   LibraryHnd : THandle ;         // axDD1440.dll library handle
   LibraryLoaded : Boolean ;      // Libraries loaded flag

   AOCircularBuffer : Boolean ;     // TRUE = repeated buffer fill mode
   AONumChannels : Integer ;          // No. of channels in O/P buffer
   AOMaxChannels : Integer ;
   AOChannelList : Array[0..LIH_MaxDACChannels-1] of Word ;

   AONumPoints : Integer ;            // No. of time points in O/P buffer
   AOPointer : Integer ;              // Pointer to latest value written to AOBuf

   AOBuf : PSmallIntArray ;
   AONumSamples : Integer ;        // Output buffer size= function(no. samples)

   DACDefaultValue : Array[0..LIH_MaxDacChannels-1] of SmallInt ;
   ScaleData : Array[0..49999] of Byte ;
   EPC9MinCurrentGain : Double ;

   DIGDefaultValue : Integer ;

    EPC9_GetMuxAdcOffset : TEPC9_GetMuxAdcOffset;
    EPC9_GetStimDacOffset : TEPC9_GetStimDacOffset;
    EPC9_AutoCFast : TEPC9_AutoCFast;
    EPC9_AutoCSlow : TEPC9_AutoCSlow;
    EPC9_AutoGLeak : TEPC9_AutoGLeak;
    EPC9_AutoSearch : TEPC9_AutoSearch ;
    EPC9_AutoVpOffset : TEPC9_AutoVpOffset ;
    EPC9_Reset : TEPC9_Reset ;
    EPC9_ResetTempState : TEPC9_ResetTempState ;
    EPC9_FlushCache : TEPC9_FlushCache ;
    EPC9_GetLastError : TEPC9_GetLastError ;
    EPC9_Shutdown : TEPC9_Shutdown ;
    EPC9_GetClipping : TEPC9_GetClipping ;
    EPC9_GetIpip : TEPC9_GetIpip ;
    EPC9_GetRMSNoise : TEPC9_GetRMSNoise ;
    EPC9_GetStateAdr : TEPC9_GetStateAdr ;
    EPC9_GetEpc9NStateAdr : TEPC9_GetEpc9NStateAdr  ;
    EPC9_GetVmon : TEPC9_GetVmon ;
    EPC9_SetCCFastSpeed : TEPC9_SetCCFastSpeed ;
    EPC9_SetCCIHold : TEPC9_SetCCIHold ;
    EPC9_SetCCStimScale : TEPC9_SetCCStimScale ;
    EPC9_SetCFast1 : TEPC9_SetCFast1 ;
    EPC9_SetCFast2 : TEPC9_SetCFast2 ;
    EPC9_SetCFastTau : TEPC9_SetCFastTau ;
    EPC9_GetCFastTauReal : TEPC9_GetCFastTauReal ;
    EPC9_SetCFastTauReal : TEPC9_SetCFastTauReal ;
    EPC9_SetCSlow : TEPC9_SetCSlow ;
    EPC9_SetCSlowCycles : TEPC9_SetCSlowCycles ;
    EPC9_SetCSlowPeak : TEPC9_SetCSlowPeak ;
    EPC9_SetCSlowRange : TEPC9_SetCSlowRange ;
    EPC9_SetCSlowRepetitive : TEPC9_SetCSlowRepetitive ;
    EPC9_SetCurrentGain : TEPC9_SetCurrentGain ;
    EPC9_SetCurrentGainIndex : TEPC9_SetCurrentGainIndex ;
    EPC9_SetCCGain : TEPC9_SetCCGain ;
    EPC9_SetE9Board : TEPC9_SetE9Board ;
    EPC9_GetExtStimPath : TEPC9_GetExtStimPath ;
    EPC9_SetExtStimPath : TEPC9_SetExtStimPath ;
    EPC9_SetF1Index : TEPC9_SetF1Index ;
    EPC9_SetF1Bandwidth : TEPC9_SetF1Bandwidth ;
    EPC9_SetF2Bandwidth : TEPC9_SetF2Bandwidth ;
    EPC9_SetF2Butterworth : TEPC9_SetF2Butterworth ;
    EPC9_SetGLeak : TEPC9_SetGLeak ;
    EPC9_SetGSeries : TEPC9_SetGSeries ;
    EPC9_SetMode : TEPC9_SetMode ;
    EPC9_SetMuxPath : TEPC9_SetMuxPath ;
    EPC9_SetRsFraction : TEPC9_SetRsFraction ;
    EPC9_SetRsMode : TEPC9_SetRsMode ;
    EPC9_GetRsMode : TEPC9_GetRsMode ;
    EPC9_SetRsValue : TEPC9_SetRsValue ;
    EPC9_SetStimFilterOn : TEPC9_SetStimFilterOn ;
    EPC9_SetTimeout : TEPC9_SetTimeout ;
    EPC9_SetVHold : TEPC9_SetVHold ;
    EPC9_SetVLiquidJunction : TEPC9_SetVLiquidJunction ;
    EPC9_SetVpOffset : TEPC9_SetVpOffset ;
    EPC9_SetCCTrackHold : TEPC9_SetCCTrackHold ;
    EPC9_SetCCTrackTau : TEPC9_SetCCTrackTau ;
    EPC9_GetErrorText : TEPC9_GetErrorText ;
    EPC9_SetLastVHold : TEPC9_SetLastVHold ;
    EPC9_InitializeAndCheckForLife : TEPC9_InitializeAndCheckForLife ;
    EPC9_FinishInitialization : TEPC9_FinishInitialization ;
    EPC9_LoadScaleFiles : TEPC9_LoadScaleFiles ;
    EPC8_EncodeFilter : TEPC8_EncodeFilter ;
    EPC8_DecodeFilter : TEPC8_DecodeFilter ;
    EPC8_DecodeGain : TEPC8_DecodeGain ;
    EPC8_EncodeGain : TEPC8_EncodeGain ;
    EPC8_DecodeMode : TEPC8_DecodeMode ;
    EPC8_EncodeMode : TEPC8_EncodeMode ;
    EPC8_DecodeRemote : TEPC8_DecodeRemote ;
    EPC8_EncodeRemote : TEPC8_EncodeRemote ;
    EPC8_SendToEpc8 : TEPC8_SendToEpc8 ;
    LIH_StartStimAndSample : TLIH_StartStimAndSample ;
    LIH_AvailableStimAndSample : TLIH_AvailableStimAndSample  ;
    LIH_DoneStimAndSample : TLIH_DoneStimAndSample ;
    LIH_ReadStimAndSample : TLIH_ReadStimAndSample ;
    LIH_AppendToFIFO : TLIH_AppendToFIFO ;
    LIH_Halt : TLIH_Halt ;
    LIH_ForceHalt : TLIH_ForceHalt ;
    LIH_ReadAdc : TLIH_ReadAdc ;
    LIH_ReadDigital : TLIH_ReadDigital ;
    LIH_ReadAll : TLIH_ReadAll ;
    LIH_SetDac : TLIH_SetDac ;
    LIH_SetDigital : TLIH_SetDigital ;
    LIH_VoltsToDacUnits : TLIH_VoltsToDacUnits ;
    LIH_AdcUnitsToVolts : TLIH_AdcUnitsToVolts ;
    LIH_CheckSampleInterval : TLIH_CheckSampleInterval ;
    LIH_Status : TLIH_Status ;
    LIH_SetInputRange : TLIH_SetInputRange ;
    LIH_InitializeInterface : TLIH_InitializeInterface ;
    LIH_Shutdown : TLIH_Shutdown ;
    LIH_SetBoardNumber : TLIH_SetBoardNumber ;
    LIH_GetBoardType : TLIH_GetBoardType ;
    LIH_GetErrorText : TLIH_GetErrorText ;
    LIH_GetBoardInfo : TLIH_GetBoardInfo ;
    TIB14_Present : TTIB14_Present ;
    TIB14_Initialize : TTIB14_Initialize ;
    PSA12_Initialize : TPSA12_Initialize ;
    PSA12_Shutdown : TPSA12_Shutdown ;
    PSA12_IsOpen : TPSA12_IsOpen ;
    PSA12_SetTone : TPSA12_SetTone ;
    EPC9_DLLVersion : TEPC9_DLLVersion ;


// Find, Open & close device.



function  HEKA_GetLabInterfaceInfo(
            InterfaceTypeIn : Integer ;
            var Model : string ; { Laboratory interface model name/number }
            var ADCMaxChannels : Integer ;
            var ADCMinSamplingInterval : Double ; { Smallest sampling interval }
            var ADCMaxSamplingInterval : Double ; { Largest sampling interval }
            var ADCMinValue : Integer ; { Negative limit of binary ADC values }
            var ADCMaxValue : Integer ; { Positive limit of binary ADC values }
            var ADCVoltageRanges : Array of single ; { A/D voltage range option list }
            var NumADCVoltageRanges : Integer ; { No. of options in above list }
            var ADCBufferLimit : Integer ;      { Max. no. samples in A/D buffer }
            var DACMaxChannels : Integer ;
            var DACMaxVolts : Single ; { Positive limit of bipolar D/A voltage range }
            var DACMinUpdateInterval : Double {Min. D/A update interval }
            ) : Boolean ;
{ --------------------------------------------
  Get information about the interface hardware
  -------------------------------------------- }
var
    iBoardType : Integer ;
    BoardName : String ;
    EPC9State : PEPC9_StateType ;
begin

     InterfaceType := InterfaceTypeIn ;

     if not DeviceInitialised then HEKA_InitialiseBoard ;
     if not DeviceInitialised then begin
        Result := DeviceInitialised ;
        Exit ;
        end ;

     // Get name of interface board
     iBoardType := LIH_GetBoardType ;
     case iBoardType of
        LIH_ITC16Board : BoardName := 'ITC-16' ;
        LIH_ITC18Board : BoardName := 'ITC-18' ;
        LIH_LIH1600Board : BoardName := 'ITC-1600' ;
        LIH_LIH88Board : BoardName := 'LIH-88' ;
        else BoardName := '??' ;
     end;

     // Get board capabilities
     LIH_GetBoardInfo ( SamplingIntervalStepSize,
                        MinSamplingInterval,
                        MaxSamplingInterval,
                        FIFOMaxPoints,
                        AOMaxChannels,
                        AIMaxChannels );

     ADCMaxChannels :=  AIMaxChannels ;
     DACMaxChannels :=  AOMaxChannels ;

     // Define available A/D voltage range options
     ADCVoltageRanges[0] := 10.0 ;
     NumADCVoltageRanges := 1 ;
     FADCVoltageRangeMax := ADCVoltageRanges[0] ;

     // A/D sample value range= function(16 bits)
     ADCMinValue := -32678 ;
     ADCMaxValue := -ADCMinValue - 1 ;
     FADCMinValue := ADCMinValue ;
     FADCMaxValue := ADCMaxValue ;
     ADCMinSamplingInterval := MinSamplingInterval ;
     ADCMaxSamplingInterval := MaxSamplingInterval ;


     // Upper limit of bipolar D/A voltage range
     DACMaxVolts := 10.0 ;
     FDACVoltageRangeMax := 10.0 ;
     DACMinUpdateInterval := MinSamplingInterval ;
     DACMinUpdateInterval := MaxSamplingInterval ;

     EPC9_SetCurrentGainIndex(0) ;
     EPC9State := EPC9_GetStateAdr ;
     EPC9MinCurrentGain := EPC9State^.RealCurrentGain ;

     { Get device model and firmware details }
     Model := BoardName + format( ' (DLL V.%d)',[EPC9_DLLVersion]) + ANSIString(EPC9State^.SerialNumber);

     Result := DeviceInitialised ;

     end ;


procedure HEKA_LoadLibrary  ;
{ -------------------------------------
  Load AXDD1440.DLL library into memory
  -------------------------------------}
var
     DLLName : String ; // DLL file paths
begin

     DLLName :=  ExtractFilePath(ParamStr(0)) + 'EPCDLL.DLL';
     if not FileExists(DLLName) then begin
        ShowMessage( DLLName + ' missing from ' + ExtractFilePath(ParamStr(0))) ;
        end ;

     // Load main library
     LibraryHnd := LoadLibrary(PChar(DLLName)) ;

     { Get addresses of procedures in library }
     if LibraryHnd > 0 then begin
        @EPC9_DLLVersion := HEKA_LoadProcedure(LibraryHnd,'EPC9_DLLVersion') ;
        @PSA12_SetTone := HEKA_LoadProcedure(LibraryHnd,'PSA12_SetTone') ;
        @PSA12_Shutdown := HEKA_LoadProcedure(LibraryHnd,'PSA12_Shutdown') ;
        @PSA12_Initialize := HEKA_LoadProcedure(LibraryHnd,'PSA12_Initialize') ;
        @TIB14_Initialize := HEKA_LoadProcedure(LibraryHnd,'TIB14_Initialize') ;
        @TIB14_Present := HEKA_LoadProcedure(LibraryHnd,'TIB14_Present') ;
        @LIH_GetBoardInfo := HEKA_LoadProcedure(LibraryHnd,'LIH_GetBoardInfo') ;
        @LIH_GetErrorText := HEKA_LoadProcedure(LibraryHnd,'LIH_GetErrorText') ;
        @LIH_GetBoardType := HEKA_LoadProcedure(LibraryHnd,'LIH_GetBoardType') ;
        @LIH_SetBoardNumber := HEKA_LoadProcedure(LibraryHnd,'LIH_SetBoardNumber') ;
        @LIH_Shutdown := HEKA_LoadProcedure(LibraryHnd,'LIH_Shutdown') ;
        @LIH_InitializeInterface := HEKA_LoadProcedure(LibraryHnd,'LIH_InitializeInterface') ;
        @LIH_SetInputRange := HEKA_LoadProcedure(LibraryHnd,'LIH_SetInputRange') ;
        @LIH_Status := HEKA_LoadProcedure(LibraryHnd,'LIH_Status') ;
        @LIH_CheckSampleInterval := HEKA_LoadProcedure(LibraryHnd,'LIH_CheckSampleInterval') ;
        @LIH_AdcUnitsToVolts := HEKA_LoadProcedure(LibraryHnd,'LIH_AdcUnitsToVolts') ;
        @LIH_VoltsToDacUnits := HEKA_LoadProcedure(LibraryHnd,'LIH_VoltsToDacUnits') ;
        @LIH_SetDigital := HEKA_LoadProcedure(LibraryHnd,'LIH_SetDigital') ;
        @LIH_SetDac := HEKA_LoadProcedure(LibraryHnd,'LIH_SetDac') ;
        @LIH_ReadAll := HEKA_LoadProcedure(LibraryHnd,'LIH_ReadAll') ;
        @LIH_ReadDigital := HEKA_LoadProcedure(LibraryHnd,'LIH_ReadDigital') ;
        @LIH_ReadAdc := HEKA_LoadProcedure(LibraryHnd,'LIH_ReadAdc') ;
        @LIH_ForceHalt := HEKA_LoadProcedure(LibraryHnd,'LIH_ForceHalt') ;
        @LIH_Halt := HEKA_LoadProcedure(LibraryHnd,'LIH_Halt') ;
        @LIH_AppendToFIFO := HEKA_LoadProcedure(LibraryHnd,'LIH_AppendToFIFO') ;
        @LIH_ReadStimAndSample := HEKA_LoadProcedure(LibraryHnd,'LIH_ReadStimAndSample') ;
        @LIH_DoneStimAndSample := HEKA_LoadProcedure(LibraryHnd,'LIH_DoneStimAndSample') ;
        @LIH_StartStimAndSample := HEKA_LoadProcedure(LibraryHnd,'LIH_StartStimAndSample') ;
        @LIH_AvailableStimAndSample := HEKA_LoadProcedure(LibraryHnd,'LIH_AvailableStimAndSample') ;
        @EPC8_SendToEpc8 := HEKA_LoadProcedure(LibraryHnd,'EPC8_SendToEpc8') ;
        @EPC8_EncodeRemote := HEKA_LoadProcedure(LibraryHnd,'EPC8_EncodeRemote') ;
        @EPC8_DecodeRemote := HEKA_LoadProcedure(LibraryHnd,'EPC8_DecodeRemote') ;
        @EPC8_EncodeMode := HEKA_LoadProcedure(LibraryHnd,'EPC8_EncodeMode') ;
        @EPC8_DecodeMode := HEKA_LoadProcedure(LibraryHnd,'EPC8_DecodeMode') ;
        @EPC8_EncodeGain := HEKA_LoadProcedure(LibraryHnd,'EPC8_EncodeGain') ;
        @EPC8_DecodeGain := HEKA_LoadProcedure(LibraryHnd,'EPC8_DecodeGain') ;
        @EPC8_DecodeFilter := HEKA_LoadProcedure(LibraryHnd,'EPC8_DecodeFilter') ;
        @EPC8_EncodeFilter := HEKA_LoadProcedure(LibraryHnd,'EPC8_EncodeFilter') ;
        @EPC9_LoadScaleFiles := HEKA_LoadProcedure(LibraryHnd,'EPC9_LoadScaleFiles') ;
        @EPC9_FinishInitialization := HEKA_LoadProcedure(LibraryHnd,'EPC9_FinishInitialization') ;
        @EPC9_InitializeAndCheckForLife := HEKA_LoadProcedure(LibraryHnd,'EPC9_InitializeAndCheckForLife') ;
        @EPC9_SetLastVHold := HEKA_LoadProcedure(LibraryHnd,'EPC9_SetLastVHold') ;
        @EPC9_GetErrorText := HEKA_LoadProcedure(LibraryHnd,'EPC9_GetErrorText') ;
        @EPC9_SetCCTrackTau := HEKA_LoadProcedure(LibraryHnd,'EPC9_SetCCTrackTau') ;
        @EPC9_SetCCTrackHold := HEKA_LoadProcedure(LibraryHnd,'EPC9_SetCCTrackHold') ;
        @EPC9_SetVpOffset := HEKA_LoadProcedure(LibraryHnd,'EPC9_SetVpOffset') ;
        @EPC9_SetVLiquidJunction := HEKA_LoadProcedure(LibraryHnd,'EPC9_SetVLiquidJunction') ;
        @EPC9_SetVHold := HEKA_LoadProcedure(LibraryHnd,'EPC9_SetVHold') ;
        @EPC9_SetTimeout := HEKA_LoadProcedure(LibraryHnd,'EPC9_SetTimeout') ;
        @EPC9_SetStimFilterOn := HEKA_LoadProcedure(LibraryHnd,'EPC9_SetStimFilterOn') ;
        @EPC9_SetRsValue := HEKA_LoadProcedure(LibraryHnd,'EPC9_SetRsValue') ;
        @EPC9_GetRsMode := HEKA_LoadProcedure(LibraryHnd,'EPC9_GetRsMode') ;
        @EPC9_SetRsMode := HEKA_LoadProcedure(LibraryHnd,'EPC9_SetRsMode') ;
        @EPC9_SetRsFraction := HEKA_LoadProcedure(LibraryHnd,'EPC9_SetRsFraction') ;
        @EPC9_SetMuxPath := HEKA_LoadProcedure(LibraryHnd,'EPC9_SetMuxPath') ;
        @EPC9_SetMode := HEKA_LoadProcedure(LibraryHnd,'EPC9_SetMode') ;
        @EPC9_SetGSeries := HEKA_LoadProcedure(LibraryHnd,'EPC9_SetGSeries') ;
        @EPC9_SetGLeak := HEKA_LoadProcedure(LibraryHnd,'EPC9_SetGLeak') ;
        @EPC9_SetF2Butterworth := HEKA_LoadProcedure(LibraryHnd,'EPC9_SetF2Butterworth') ;
        @EPC9_SetF2Bandwidth := HEKA_LoadProcedure(LibraryHnd,'EPC9_SetF2Bandwidth') ;
        @EPC9_SetF1Bandwidth := HEKA_LoadProcedure(LibraryHnd,'EPC9_SetF1Bandwidth') ;
        @EPC9_SetF1Index := HEKA_LoadProcedure(LibraryHnd,'EPC9_SetF1Index') ;
        @EPC9_SetExtStimPath := HEKA_LoadProcedure(LibraryHnd,'EPC9_SetExtStimPath') ;
        @EPC9_GetExtStimPath := HEKA_LoadProcedure(LibraryHnd,'EPC9_GetExtStimPath') ;
        @EPC9_SetE9Board := HEKA_LoadProcedure(LibraryHnd,'EPC9_SetE9Board') ;
        @EPC9_SetCCGain := HEKA_LoadProcedure(LibraryHnd,'EPC9_SetCCGain') ;
        @EPC9_SetCurrentGainIndex := HEKA_LoadProcedure(LibraryHnd,'EPC9_SetCurrentGainIndex') ;
        @EPC9_SetCurrentGain := HEKA_LoadProcedure(LibraryHnd,'EPC9_SetCurrentGain') ;
        @EPC9_SetCSlowRepetitive := HEKA_LoadProcedure(LibraryHnd,'EPC9_SetCSlowRepetitive') ;
        @EPC9_SetCSlowRange := HEKA_LoadProcedure(LibraryHnd,'EPC9_SetCSlowRange') ;
        @EPC9_SetCSlowPeak := HEKA_LoadProcedure(LibraryHnd,'EPC9_SetCSlowPeak') ;
        @EPC9_SetCSlowCycles := HEKA_LoadProcedure(LibraryHnd,'EPC9_SetCSlowCycles') ;
        @EPC9_SetCSlow := HEKA_LoadProcedure(LibraryHnd,'EPC9_SetCSlow') ;
        @EPC9_SetCFastTauReal := HEKA_LoadProcedure(LibraryHnd,'EPC9_SetCFastTauReal') ;
        @EPC9_GetCFastTauReal := HEKA_LoadProcedure(LibraryHnd,'EPC9_GetCFastTauReal') ;
        @EPC9_SetCFast2 := HEKA_LoadProcedure(LibraryHnd,'EPC9_SetCFast2') ;
        @EPC9_SetCFast1 := HEKA_LoadProcedure(LibraryHnd,'EPC9_SetCFast1') ;
        @EPC9_SetCCStimScale := HEKA_LoadProcedure(LibraryHnd,'EPC9_SetCCStimScale') ;
        @EPC9_SetCCIHold := HEKA_LoadProcedure(LibraryHnd,'EPC9_SetCCIHold') ;
        @EPC9_SetCCFastSpeed := HEKA_LoadProcedure(LibraryHnd,'EPC9_SetCCFastSpeed') ;
        @EPC9_GetVmon := HEKA_LoadProcedure(LibraryHnd,'EPC9_GetVmon') ;
        @EPC9_GetEpc9NStateAdr := HEKA_LoadProcedure(LibraryHnd,'EPC9_GetEpc9NStateAdr') ;
        @EPC9_GetStateAdr := HEKA_LoadProcedure(LibraryHnd,'EPC9_GetStateAdr') ;
        @EPC9_GetRMSNoise := HEKA_LoadProcedure(LibraryHnd,'EPC9_GetRMSNoise') ;
        @EPC9_GetIpip := HEKA_LoadProcedure(LibraryHnd,'EPC9_GetIpip') ;
        @EPC9_GetClipping := HEKA_LoadProcedure(LibraryHnd,'EPC9_GetClipping') ;
        @EPC9_Shutdown := HEKA_LoadProcedure(LibraryHnd,'EPC9_Shutdown') ;
        @EPC9_GetLastError := HEKA_LoadProcedure(LibraryHnd,'EPC9_GetLastError') ;
        @EPC9_FlushCache := HEKA_LoadProcedure(LibraryHnd,'EPC9_FlushCache') ;
        @EPC9_ResetTempState := HEKA_LoadProcedure(LibraryHnd,'EPC9_ResetTempState') ;
        @EPC9_Reset := HEKA_LoadProcedure(LibraryHnd,'EPC9_Reset') ;
        @EPC9_AutoVpOffset := HEKA_LoadProcedure(LibraryHnd,'EPC9_AutoVpOffset') ;
        @EPC9_AutoSearch := HEKA_LoadProcedure(LibraryHnd,'EPC9_AutoSearch') ;
        @EPC9_AutoGLeak := HEKA_LoadProcedure(LibraryHnd,'EPC9_AutoGLeak') ;
        @EPC9_AutoCSlow := HEKA_LoadProcedure(LibraryHnd,'EPC9_AutoCSlow') ;
        @EPC9_AutoCFast := HEKA_LoadProcedure(LibraryHnd,'EPC9_AutoCFast') ;
        @EPC9_GetStimDacOffset := HEKA_LoadProcedure(LibraryHnd,'EPC9_GetStimDacOffset') ;
        @EPC9_GetMuxAdcOffset := HEKA_LoadProcedure(LibraryHnd,'EPC9_GetMuxAdcOffset') ;
        //@ := HEKA_LoadProcedure(LibraryHnd,'') ;
        LibraryLoaded := True ;
        end
     else begin
          ShowMessage( DLLName + ' not found!' ) ;
          LibraryLoaded := False ;
          end ;
     end ;


function  HEKA_LoadProcedure(
         Hnd : THandle ;       { Library DLL handle }
         Name : string         { Procedure name within DLL }
         ) : Pointer ;         { Return pointer to procedure }
{ ----------------------------
  Get address of DLL procedure
  ----------------------------}
var
   P : Pointer ;
begin
     P := GetProcAddress(Hnd,PChar(Name)) ;
     if P = Nil then begin
        ShowMessage(format('EPCDLL.DLL- %s not found',[Name])) ;
        end ;
     Result := P ;
     end ;


function  HEKA_GetMaxDACVolts : single ;
{ -----------------------------------------------------------------
  Return the maximum positive value of the D/A output voltage range
  -----------------------------------------------------------------}

begin
     Result := FDACVoltageRangeMax ;
     end ;


procedure HEKA_InitialiseBoard ;
{ -------------------------------------------
  Initialise Digidata 1200 interface hardware
  -------------------------------------------}
var
   ch,FirstError,LastError,IAmplifier, Err : Integer ;
   LoadScaleProc,LoadCFastProc : Pointer ;
   ErrorMsg : Array[0..511] of ANSIChar ;
begin

     DeviceInitialised := False ;

     if not LibraryLoaded then HEKA_LoadLibrary ;
     if not LibraryLoaded then Exit ;

     case InterfaceType of
       HekaEPC9 : IAmplifier := EPC9_Epc9Ampl ;
       HekaEPC10 : IAmplifier := EPC9_Epc10Ampl ;
       HekaEPC10plus : IAmplifier := EPC9_Epc10PlusAmpl ;
       HekaEPC10USB : IAmplifier := EPC9_Epc10USB ;
       else IAmplifier := EPC9_Epc9Ampl ;
       end ;

     Err := EPC9_InitializeAndCheckForLife( ErrorMsg,FirstError,LastError,IAmplifier,
                                            @EPC9_LoadFileProcType,
                                            @EPC9_LoadFileProcType ) ;

     //ShowMessage( ANSIString( ErrorMsg));

     // Get board capabilities
     LIH_GetBoardInfo ( SamplingIntervalStepSize,
                        MinSamplingInterval,
                        MaxSamplingInterval,
                        FIFOMaxPoints,
                        AOMaxChannels,
                        AIMaxChannels );

     // Initialise ADC data buffers
     for ch := 0 to AIMaxChannels-1 do begin
         GetMem( AIDataBufs[ch], FIFOMaxPoints*2 ) ;
         end;

     // Set channel mappings

     // Input
     AIChannelList[0] := 0 ;
     AIChannelList[1] := 3 ;
     AIChannelList[2] := 2 ;
     AIChannelList[3] := 1 ;
     AIChannelList[4] := 4 ;
     AIChannelList[5] := 5 ;
     AIChannelList[6] := 6 ;
     AIChannelList[7] := 7 ;

     // Output
     AOChannelList[0] := 3 ;
     AOChannelList[1] := 1 ;
     AOChannelList[2] := 2 ;
     AOChannelList[3] := 0 ;

     AIBuf := Nil ;
     AOBuf := Nil ;

     // Determine number of available DD1440s
     //NumDevices := HEKA_CountDevices ;


    DeviceInitialised := True ;

     end ;


procedure HEKA_FillOutputBufferWithDefaultValues ;
// --------------------------------------
// Fill output buffer with default values
// --------------------------------------
var
    i,j,ch : Integer ;
begin
    exit ;
    // Circular transfer buffer
    for i := 0 to AONumSamples-1 do begin
        for ch  := 0 to AONumChannels - 1 do begin
            AOBuf^[j] := DACDefaultValue[ch] ;
            Inc(j) ;
            end ;
        end ;

    end ;

procedure HEKA_ConfigureHardware(
          EmptyFlagIn : Integer ) ;
{ --------------------------------------------------------------------------

  -------------------------------------------------------------------------- }
begin
     //EmptyFlag := EmptyFlagIn ;
     end ;


function HEKA_ADCToMemory(
          HostADCBuf : Pointer  ;   { A/D sample buffer= function(OUT) }
          NumADCChannels : Integer ;                   { Number of A/D channels= function(IN) }
          NumADCSamples : Integer ;                    { Number of A/D samples= function( per channel)= function(IN) }
          var dt : Double ;                       { Sampling interval= function(s)= function(IN) }
          ADCVoltageRange : Single ;              { A/D input voltage range= function(V)= function(IN) }
          TriggerMode : Integer ;                 { A/D sweep trigger mode= function(IN) }
          CircularBuffer : Boolean                { Repeated sampling into buffer= function(IN) }
          ) : Boolean ;                           { Returns TRUE indicating A/D started }
{ -----------------------------
  Start A/D converter sampling
  -----------------------------}
var
   i,AcquisitionMode : Word ;
   ch : Integer ;
   iPointer : Cardinal ;
   SetStimEnd,ReadContinuously,OK : LongInt ;
   AODataBufs : Array[0..LIH_MaxDacChannels-1] of PSmallIntArray ;
begin

     Result := False ;
     if not DeviceInitialised then HEKA_InitialiseBoard ;
     if not DeviceInitialised then Exit ;

     AINumChannels := NumADCChannels ;
     AONumChannels := 1 ;
     AINumSamples := NumADCSamples ;
     AICircularBuffer := CircularBuffer ;
     AIPointer := 0 ;


     //EPC9_SetMuxPath(1) ;

     SamplingInterval := dt ;
     Heka_CheckSamplingInterval( SamplingInterval ) ;

     if TriggerMode <> tmWaveGen then begin

        // Set up a single
        AONumPoints := 1000 ;
        AONumChannels := 1 ;
        GetMem( AODataBufs[0], AONumPoints*2 ) ;
        for i := 0 to AONumPoints-1 do AODataBufs[0]^[i] := 0 ;

        // Set external trigger mode
        if TriggerMode = tmExtTrigger then AcquisitionMode := LIH_TriggeredAcquisition
                                      else AcquisitionMode := 0 ;

        AOPointer := 0 ;
        SetStimEnd := 0 ;
        ReadContinuously := 1 ;
        OK := LIH_StartStimAndSample ( 1,
                                       NumADCChannels,
                                       NumADCSamples,
                                       1,
                                       AcquisitionMode,
                                       @AOChannelList,
                                       @AICHannelList,
                                       SamplingInterval,
                                       @AODataBufs,
                                       SetStimEnd,
                                       ReadContinuously ) ;

        FreeMem(AODataBufs[0]) ;

        ADCActive := True ;
        DACActive := False ;
        end ;


     end ;


function HEKA_StopADC : Boolean ;  { Returns False indicating A/D stopped }
{ -------------------------------
  Reset A/D conversion sub-system
  -------------------------------}
begin
     Result := False ;
     if not DeviceInitialised then HEKA_InitialiseBoard ;
     if not DeviceInitialised then Exit ;

     // Stop any activity
     LIH_Halt ;

     // Fill D/A & digital O/P buffers with default values
     ADCActive := False ;
     DACActive := False ;  // Since A/D and D/A are synchronous D/A stops too
     Result := ADCActive ;

     end ;


procedure HEKA_GetADCSamples(
          var OutBuf : Array of SmallInt ;  { Buffer to receive A/D samples }
          var OutBufPointer : Integer       { Latest sample pointer [OUT]}
          ) ;
var
    i,ch,MaxAOPointer,MaxAIPointer,NewSamples,SetStimEnd : Integer ;
    StillRunning : LongBool ;
    DoHalt : Integer;
begin

     if not ADCActive then exit ;
     NewSamples := LIH_AvailableStimAndSample(StillRunning);

     if NewSamples <= 0 then Exit ;

     // Get A/D samples
     DoHalt := 0 ;
     LIH_ReadStimAndSample( NewSamples, DoHalt, @AIDataBufs ) ;

     // Copy data to output buffer
     MaxAIPointer := AINumSamples*AINumChannels - 1 ;
     for i := 0 to NewSamples-1 do begin
         for ch := 0 to AINumChannels-1 do begin
             OutBuf[AIPointer] := AIDataBufs[ch]^[i] ;
             Inc(AIPointer) ;
             if AIPointer > MaxAIPointer then begin
                if AICircularBuffer then AIPointer := 0
                                    else Break ;
                end;
             end;
         end;

     // Add same number of data points to output buffer

     MaxAOPointer := AONumSamples*AONumChannels - 1 ;
     for i := 0 to NewSamples-1 do begin
         for ch := 0 to AONumChannels-1 do begin
             AIDataBufs[ch]^[i] := AOBuf[AOPointer]  ;
             Inc(AOPointer) ;
             if AIPointer > MaxAOPointer then begin
                if AOCircularBuffer then AOPointer := 0
                                    else AOPointer := AOPointer - AONumChannels ;
                end;
             end;
         end;

     SetStimEnd := 0 ;
     LIH_AppendToFIFO( NewSamples, SetStimEnd, @AIDataBufs ) ;

     end ;


procedure HEKA_CheckSamplingInterval(
          var SamplingInterval : Double ) ;
// --------------------------------------------------------------------------
// Ensure that sampling interval is within limits and divisible by tick size
// --------------------------------------------------------------------------
  begin

  SamplingInterval := Max(Round(SamplingInterval/SamplingIntervalStepSize),1)*SamplingIntervalStepSize ;
  SamplingInterval := Min(Max(SamplingInterval,MinSamplingInterval),MaxSamplingInterval) ;

	end ;


function  HEKA_MemoryToDACAndDigitalOut(
          var DACValues : Array of SmallInt  ;
          NumDACChannels : Integer ;
          NumDACPoints : Integer ;
          var DigValues : Array of SmallInt  ;
          DigitalInUse : Boolean ;
          ExternalTrigger : Boolean ;
          RepeatWaveform  : Boolean
          ) : Boolean ;
{ --------------------------------------------------------------
  Send a voltage waveform stored in DACBuf to the D/A converters
  30/11/01 DigFill now set to correct final value to prevent
  spurious digital O/P changes between records
  --------------------------------------------------------------}
const
    MinBufferDuration = 0.5 ;
var
   i,j,ch,iTo,iFrom,DigCh,MaxOutPointer,NP,NPWrite,AcquisitionMode,NPDACValues : Integer ;
   AODataBufs : Array[0..LIH_MaxDacChannels-1] of PSmallIntArray ;
   SetStimEnd,ReadContinuously,OK : LongInt ;
begin

    Result := False ;
    if not DeviceInitialised then HEKA_InitialiseBoard ;
    if not DeviceInitialised then Exit ;

    AONumChannels := Min(Max(NumDACChannels,1),LIH_MaxDacChannels) ;
    AONumSamples := NumDACPoints ;
    AOCircularBuffer := RepeatWaveform ;

    //EPC9_SetExtStimPath( 0.1, EPC9_ExtStimInput ) ;

    // Copy DAC waveform data into internal buffer
    // Ensure that the buffer has data for MinBufferDuration (s)
    if AOBuf <> Nil then FreeMem(AOBuf) ;
    NP := Max( AONumSamples, Round(MinBufferDuration/SamplingInterval))*AONumChannels ;
    GetMem( AOBuf, NP*2 ) ;

    j := 0 ;
    NPDACValues := AONumSamples*AONumChannels ;
    for i := 0 to NP-1 do begin
        AOBuf^[i] := DACValues[j] ;
        Inc(j) ;
        if j >= NPDACValues then j := j - AONumChannels ;
        end;

    // Fill transfer buffer with initialise waveform to fill FIFO
    NPWrite := (Min(FIFOMaxPoints,NP) div AONumChannels)*AONumChannels ;
    for ch  := 0 to AONumChannels-1 do begin
      GetMem( AODataBufs[ch], NPWrite*2 ) ;
      j := ch ;
      for i := 0 to NPWrite-1 do begin
          AODataBufs[ch]^[i] := AOBuf^[j] ;
          j := j + AONumChannels ;
          end;
      end;
    AOPointer := NPWrite ;

    // Start A/D and D/A conversion

    EPC9_FlushCache ;

    SetStimEnd := 0 ;
    ReadContinuously := 0 ;
    AcquisitionMode := LIH_EnableDacOutput ;
    OK := LIH_StartStimAndSample ( 1,//AONumChannels-1,
                                   AINumChannels,
                                   NPWrite,
                                   NPWrite,
                                   AcquisitionMode,
                                   @AOChannelList,
                                   @AICHannelList,
                                   SamplingInterval,
                                   @AODataBufs,
                                   SetStimEnd,
                                   ReadContinuously ) ;

    // Release buffers
    for ch  := 0 to AONumChannels-1 do FreeMem(AODataBufs[ch]);

    ADCActive := True ;
    DACActive := True ;
    Result := DACActive ;

    end ;


function HEKA_GetDACUpdateInterval : Double ;
{ -----------------------
  Get D/A update interval
  -----------------------}
begin

     // DAC update interval is same as A/D sampling interval
     Result := SamplingInterval ;

     end ;


function HEKA_StopDAC : Boolean ;
//---------------------------------
//  Stop D/A & digital waveforms
//---------------------------------
begin
     Result := False ;
     if not DeviceInitialised then HEKA_InitialiseBoard ;
     if not DeviceInitialised then Exit ;


     DACActive := False ;
     ADCActive := False ;
     Result := DACActive ;

     end ;


procedure HEKA_WriteDACsAndDigitalPort(
          var DACVolts : array of Single ;
          nChannels : Integer ;
          DigValue : Integer
          ) ;
{ ----------------------------------------------------
  Update D/A outputs with voltages suppled in DACVolts
  and TTL digital O/P with bit pattern in DigValue
  ----------------------------------------------------}
const
     MaxDACValue = 32767 ;
     MinDACValue = -32768 ;
var
   DACScale : single ;
   ch,DACValue : Integer ;
   DigWord : Word ;
begin

     if not DeviceInitialised then HEKA_InitialiseBoard ;
     if not DeviceInitialised then Exit ;

     //EPC9_SetVHold( -0.1 ) ;

     // Scale from Volts to binary integer units
     DACScale := MaxDACValue/FDACVoltageRangeMax ;

     { Update D/A channels }
     for ch := 0 to Min(nChannels,LIH_MaxDacChannels)-1 do begin
         // Keep within legitimate limits
         DACValue :=  Round(DACScale*DACVolts[ch]) ;
         if DACValue > MaxDACValue then DACValue := MaxDACValue ;
         if DACValue < MinDACValue then DACValue := MinDACValue ;
         // Output D/A value
         if not ADCActive then LIH_SetDac( AOChannelList[ch], DACValue ) ;
         DACDefaultValue[ch] := DACValue ;
         end ;

     // Set digital outputs
     DigWord := DigValue ;
     if not ADCActive then  LIH_SetDigital( 0, DigWord ) ;
     DIGDefaultValue := DigValue ;

     // Fill D/A & digital O/P buffers with default values
     HEKA_FillOutputBufferWithDefaultValues ;

     end ;


function HEKA_ReadADC(
         Channel : Integer // A/D channel
         ) : SmallInt ;
// ---------------------------
// Read Analogue input channel
// ---------------------------
var
   Value : SmallInt ;
begin

     Value := 0 ;
     Result := Value ;
     if not DeviceInitialised then HEKA_InitialiseBoard ;
     if not DeviceInitialised then Exit ;

     //HEKA_GetAIValue( Channel, Value ) ;
     Result := LIH_ReadADC( Channel )  ;

     end ;


procedure HEKA_GetChannelOffsets(
          var Offsets : Array of Integer ;
          NumChannels : Integer
          ) ;
{ --------------------------------------------------------
  Returns the order in which analog channels are acquired
  and stored in the A/D data buffers
  --------------------------------------------------------}
var
   ch : Integer ;
begin
     for ch := 0 to NumChannels-1 do Offsets[ch] := ch ;
     end ;


procedure HEKA_CloseLaboratoryInterface ;
var
  i: Integer;
{ -----------------------------------
  Shut down lab. interface operations
  ----------------------------------- }
begin

     if not DeviceInitialised then Exit ;

     // Stop any operation
     LIH_Halt ;

     // Shut down interface
     LIH_Shutdown ;

     for i := 0 to AIMaxChannels-1 do FreeMem( AIDataBufs[i] );

     // Free DLL libraries
     if LibraryHnd > 0 then FreeLibrary( LibraryHnd ) ;

     FreeMem( AOBuf ) ;
     FreeMem( AIBuf ) ;
     DeviceInitialised := False ;
     DACActive := False ;
     ADCActive := False ;

     end ;


procedure HEKA_CheckError(
          OK : ByteBool ) ;
{ ------------------------------------------------
  Check error code and display message if required
  ------------------------------------------------ }
begin

     if not OK then begin
        //HEKA_GetLastErrorText(  ErrorMsg, High(ErrorMsg)+1 ) ;
        ShowMessage( TrimChar(ErrorMsg) ) ;
        end ;

     end ;


function TrimChar( Input : Array of ANSIChar ) : string ;
var
   i : Integer ;
   pInput : PANSIChar ;
begin
     pInput := @Input ;
     Result := '' ;
     for i := 0 to StrLen(pInput)-1 do Result := Result + Input[i] ;
     end ;

function EPC9_LoadFileProcType(
         FileName : PANSIChar ;
         var DataStart : Pointer ;
         var FileSize : Integer ;
         MustLocate : LongBool ) : Integer ; cdecl ;
var
    FileHandle : THandle ;
    Path : String ;
    NumBytes : Integer ;
begin
    Path := ExtractFilePath(ParamStr(0)) + ANSIString(FileName) ;
    if FileExists(Path) then begin
       FileHandle := FileOpen( Path, fmOpenRead ) ;
       if FileHandle > 0 then begin
          NumBytes := FileSeek( FileHandle, 0, 2 ) ;
          FileSeek( FileHandle, 0, 0 ) ;
          FileRead( FileHandle, ScaleData, NumBytes ) ;
          FileClose(FileHandle) ;
          end;
       end;
    //ShowMessage( ANSIString(Path)) ;
    DataStart := @ScaleData[0] ;
    FileSize := NumBytes ;
    end;

function Heka_GetEPCState : Pointer ;
// ------------------------------------
// Return address of EPC-9 state record
// ------------------------------------
begin
      Result := EPC9_GetStateAdr ;
      end;

procedure Heka_GetCurrentGain(
          var Gain : Single  ;
          var ScaleFactor : Single ) ;
// ------------------------------------
// Return address of EPC-9 state record
// ------------------------------------
var
    EPC9State : PEPC9_StateType ;
begin
     EPC9State := EPC9_GetStateAdr ;
     ScaleFactor := EPC9MinCurrentGain*1E-12 ;  // Convert to mV/pA
     Gain :=  EPC9State^.RealCurrentGain / EPC9MinCurrentGain ;
     end;

procedure Heka_GetCurrentGainList( List : TStrings ) ;
// -----------------------------
// Return list of current gains
// -----------------------------
var
    i,KeepGain : Integer ;
    EPC9State : PEPC9_StateType ;
begin
     EPC9State := EPC9_GetStateAdr ;
     EPC9MinCurrentGain := EPC9State^.RealCurrentGain ;
     KeepGain := EPC9State^.Gain ;

     List.Clear ;
     for i := 0 to 15 do begin
         EPC9_SetCurrentGainIndex(i) ;
         List.Add(format('%.4g mV/pA',[EPC9State^.RealCurrentGain*1E-9]));
         end ;

     EPC9_SetCurrentGainIndex(KeepGain) ;

     end ;

procedure Heka_SetCurrentGain( iGain : Integer )  ;
// ----------------------------
// Set current gain  (by index)
// ----------------------------
begin
     EPC9_SetCurrentGainIndex( iGain ) ;
     end;

procedure Heka_SetFilterMode(
          iFilterNum : Integer ;
          iFilterMode : Integer  )  ;
// ----------------------------
// Set current filter mode
// ----------------------------
begin
     case iFilterNum of
          1 : EPC9_SetF1Index( iFilterMode ) ;
          2 : begin
              if iFilterMode = 0 then EPC9_SetF2Butterworth( False )
                                 else EPC9_SetF2Butterworth( True ) ;
              end;
         end;

     end;


procedure Heka_GetFilterMode(
          iFilterNum : Integer ;
          var iFilterMode : Integer  )  ;
// ----------------------------
// Set current filter
// ----------------------------
var
    EPC9State : PEPC9_StateType ;
begin

     EPC9State := EPC9_GetStateAdr ;

     case iFilterNum of
          1 : iFilterMode := EPC9State^.Filter1 ;
          2 : iFilterMode := EPC9State^.F2Response ;
         end;

     end;

procedure Heka_SetFilterBandwidth(
          iFilterNum : Integer ;
          Bandwidth : Single )  ;
// ----------------------------
// Set current filter bandwidth
// ----------------------------
begin
     case iFilterNum of
          1 : EPC9_SetF1Bandwidth( Bandwidth ) ;
          2 : EPC9_SetF2Bandwidth( Bandwidth ) ;
         end;

     end;


procedure Heka_GetFilterBandwidth(
          iFilterNum : Integer ;
          var Bandwidth : Single )  ;
// ----------------------------
// Set current filter
// ----------------------------
var
    EPC9State : PEPC9_StateType ;
begin

     EPC9State := EPC9_GetStateAdr ;

     case iFilterNum of
          1 : Bandwidth := EPC9State^.RealImon1Bandwidth ;
          2 : Bandwidth := EPC9State^.RealF2Bandwidth ;
         end;

     end;


procedure Heka_SetCfast( Num : Integer ; var Value : Single ) ;
begin
     EPC9_SetCFast1( Value ) ;
     end;

procedure Heka_GetCfast( Num : Integer ; var Value : Single ) ;
var
    EPC9State : PEPC9_StateType ;
begin
     EPC9State := EPC9_GetStateAdr ;
     Value := EPC9State^.CFastAmp1 ;
     end;


procedure Heka_SetCfastTau( var Value : Single ) ;
begin
     EPC9_SetCFastTauReal( Value ) ;
     end;

procedure Heka_GetCfastTau( var Value : Single ) ;
var
    EPC9State : PEPC9_StateType ;
begin

     EPC9State := EPC9_GetStateAdr ;
     Value := EPC9State^.CFastTau ;
     end;


procedure Heka_SetCslow( var Value : Single ) ;
begin
     EPC9_SetCSlow( Value ) ;
     end;

procedure Heka_GetCslow( var Value : Single ) ;
var
    EPC9State : PEPC9_StateType ;
begin
     EPC9State := EPC9_GetStateAdr ;
     Value := EPC9State^.Cslow ;
     end;

procedure Heka_SetCslowRange( var Value : Integer ) ;
begin
     EPC9_SetCSlowRange( Value ) ;
     end;

procedure Heka_GetCslowRange( var Value : Integer ) ;
var
    EPC9State : PEPC9_StateType ;
begin
     EPC9State := EPC9_GetStateAdr ;
     Value := EPC9State^.CslowRange ;
     end;

procedure Heka_SetGseries( var Value : Single ) ;
begin
     EPC9_SetGseries( Value ) ;
     end;

procedure Heka_GetGseries( var Value : Single ) ;
var
    EPC9State : PEPC9_StateType ;
begin
     EPC9State := EPC9_GetStateAdr ;
     Value := EPC9State^.Gseries ;
     end;

procedure Heka_SetGleak( var Value : Single ) ;
begin
     EPC9_SetGleak( Value ) ;
     end;

procedure Heka_GetGleak( var Value : Single ) ;
var
    EPC9State : PEPC9_StateType ;
begin

     EPC9State := EPC9_GetStateAdr ;
     Value := EPC9State^.Gleak ;
     end;

procedure Heka_SetRSValue( var Value : Single ) ;
begin
     EPC9_SetRSValue( Value ) ;
     end;

procedure Heka_GetRSValue( var Value : Single ) ;
var
    EPC9State : PEPC9_StateType ;
begin
     EPC9State := EPC9_GetStateAdr ;
     Value := EPC9State^.RsValue ;
     end;

procedure Heka_SetRsFraction( var Value : Single ) ;
begin
     EPC9_SetRsFraction( Value ) ;
     end;

procedure Heka_GetRsFraction( var Value : Single ) ;
var
    EPC9State : PEPC9_StateType ;
begin
     EPC9State := EPC9_GetStateAdr ;
     Value := EPC9State^.RsFraction ;
     end;

procedure Heka_SetRsMode( var Value : Integer ) ;
begin
     EPC9_SetRsMode( Value ) ;
     end;

procedure Heka_GetRsMode( var Value : Integer ) ;
begin
     Value := EPC9_GetRsMode ;
     end;

procedure Heka_SetMode( var Value : Integer ) ;
begin
     EPC9_SetMode( Value, True ) ;
     end;

procedure Heka_GetMode( var Value : Integer ) ;
var
    EPC9State : PEPC9_StateType ;
begin
     EPC9State := EPC9_GetStateAdr ;
     Value := EPC9State^.Mode ;
     end;

procedure Heka_SetVHold( var Value : Single ) ;
begin
     EPC9_SetVHold( Value ) ;
     end;

procedure Heka_GetVHold( var Value : Single ) ;
var
    EPC9State : PEPC9_StateType ;
begin
     EPC9State := EPC9_GetStateAdr ;
     Value := EPC9State^.VHold ;
     end;

procedure Heka_SetVLiquidJunction( var Value : Single ) ;
begin
     EPC9_SetVLiquidJunction( Value ) ;
     end;

procedure Heka_GetVLiquidJunction( var Value : Single ) ;
var
    EPC9State : PEPC9_StateType ;
begin
     EPC9State := EPC9_GetStateAdr ;
     Value := EPC9State^.VLiquidJunction ;
     end;

procedure Heka_SetVPOffset( var Value : Single ) ;
begin
     EPC9_SetVPOffset( Value ) ;
     end;

procedure Heka_GetVPOffset( var Value : Single ) ;
var
    EPC9State : PEPC9_StateType ;
begin
     EPC9State := EPC9_GetStateAdr ;
     Value := EPC9State^.VPOffset ;
     end;

procedure Heka_SetCCTrackHold( var Value : Single ) ;
begin
     EPC9_SetCCTrackHold( Value ) ;
     end;

procedure Heka_GetCCTrackHold( var Value : Single ) ;
var
    EPC9State : PEPC9_StateType ;
begin
     EPC9State := EPC9_GetStateAdr ;
     Value := EPC9State^.CCTrackVHold ;
     end;

procedure Heka_SetCCTrackTau( var Value : Single ) ;
begin
     EPC9_SetCCTrackTau( Value ) ;
     end;

procedure Heka_GetCCTrackTau( var Value : Single ) ;
var
    EPC9State : PEPC9_StateType ;
begin
     EPC9State := EPC9_GetStateAdr ;
     Value := EPC9State^.CCTrackTau ;
     end;

procedure Heka_AutoCFast ;
begin
     EPC9_AutoCFast ;
     end;

procedure Heka_AutoCSlow ;
begin
     EPC9_AutoCSlow ;
     end;

procedure Heka_AutoGLeak ;
begin
     EPC9_AutoGLeak ;
     end;

procedure Heka_AutoSearch ;
begin
     EPC9_AutoSearch ;
     end;

procedure Heka_AutoVpOffset ;
begin
     EPC9_AutoVpOffset ;
     end;




end.
