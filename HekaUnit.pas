unit HekaUnit;
// ==========================================
// HEKA patch clamps & Instrutech interfaces
// ==========================================
// 20.09.13 Tested and working with EPC-10
//          Support for 2 and 4 channel amplifiers not tested
//          Digital outputs not supported yet
//  14.01.14 Heka support updated to work with current EPCDLL downloadable from Heka site
//           Support for ITC-18-USB added to HekaUnit.pas
//  21.01.14 Latest EPCDLL supplied by Hubert used
//  11.03.14 _GetRSFraction now works correctly
//           Only Filter 2 bandwidth can now be changed
//           Filter 2 response now set by EPC9_SetF23Response
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

   EPC9_ModeVC                = 0 ;
   EPC9_ModeCC                = 1 ;


// Definitions for EPC9_SetCurrentGainIndex
   EPC9_Gain_0005             = 0;     // 0.005 pA/mV; low range
   EPC9_Gain_0010             = 1;     // 0.010 pA/mV; low range
   EPC9_Gain_0020             = 2;     // 0.020 pA/mV; low range
   EPC9_Gain_0050             = 3;     // 0.050 pA/mV; low range
   EPC9_Gain_0100             = 4;     // 0.100 pA/mV; low range
   EPC9_Gain_0200             = 5;     // 0.200 pA/mV; low range
                                    // value 6: spaceholder for a menu separation line
   EPC9_Gain_0500             = 7;     // 0.5 pA/mV; medium range
   EPC9_Gain_1                = 8;     // 1.0 pA/mV; medium range
   EPC9_Gain_2                = 9;     // 2.0 pA/mV; medium range
   EPC9_Gain_5                = 10;    // 5.0 pA/mV; medium range
   EPC9_Gain_10               = 11;    // 10 pA/mV; medium range
   EPC9_Gain_20               = 12;    // 20 pA/mV; medium range
                                    // value 13: spaceholder for a menu separation line
   EPC9_Gain_50               = 14;    // 50 pA/mV; high range
   EPC9_Gain_100              = 15;    // 100 pA/mV; high range
   EPC9_Gain_200              = 16;    // 200 pA/mV; high range
   EPC9_Gain_500              = 17;    // 500 pA/mV; high range
   EPC9_Gain_1000             = 18;    // 1000 pA/mV; high range
   EPC9_Gain_2000             = 19;     // 2000 pA/mV; high range

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
  EPC9_CC1000pA              = 3;

// defines for EPC9_CCTrackTaus:
  EPC9_TauOff =          0 ;
  EPC9_Tau1 =  1 ;
  EPC9_Tau3 =  2 ;
  EPC9_Tau10 = 3 ;
  EPC9_Tau30 = 4 ;
  EPC9_Tau100 = 5 ;

  EPC9_RsModeOff =        0 ;
  EPC9_RsMode100us =      1 ;
  EPC9_RsMode10us =      2 ;
  EPC9_RsMode2us =       3 ;

  EPC9_Success =         0 ;
  EPC9_LIHInitFailed         = 1 ;
  EPC9_FirmwareError         = 2 ;
  EPC9_NoScaleFile           = 3 ;
  EPC9_NoCFastFile           = 4 ;
  EPC9_NoScaleFiles =    22 ;
  EPC9_MaxFileLength =   10240 ;

  EPC9_Epc7Ampl =        0 ;
  EPC9_Epc8Ampl =        1 ;
  EPC9_Epc9Ampl =        2 ;
  EPC9_Epc10Ampl =        3 ;
  EPC9_Epc10PlusAmpl =   4 ;
  EPC9_Epc10USB =        5 ;

// Definitions for EPC9_SetF2Response
   EPC9_F2_I_Bessel           = 0;
   EPC9_F2_I_Butterworth      = 1;
   EPC9_F2_Bypass             = 2;
   EPC9_F2_V_Bessel           = 3;
   EPC9_F2_V_Butterworth      = 4;

// Definitions for EPC9_SetElectrodeMode
   EPC9_Two_Electrodes        = 0;
   EPC9_Three_Electrodes      = 1;

// Definitions for EPC9_HasProperty
   EPC9_HasCCFastSpeed        = 0;
   EPC9_HasLowCCRange         = 1;
   EPC9_HasHighCCRange        = 2;
   EPC9_HasInternalVmon       = 3;
   EPC9_HasCCTracking         = 4;
   EPC9_HasVmonX100           = 5;
   EPC9_HasCFastExtended      = 6;
   EPC9_Has3ElectrodeMode     = 7;
   EPC9_HasBathSense          = 8;
   EPC9_HasF2Bypass           = 9;
   EPC9_HasCFastHigh          = 10;
   EPC9_HasScaleEEPROM        = 11;
   EPC9_HasVrefX2AndF2Vmon    = 12;


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

TLIH_OptionsType = packed record
   UseUSB : LongInt ;
   BoardNumber : LongInt ;
   FIFOSamples : LongInt ;
   MaxProbes : LongInt ;
   DeviceNumber : Array[0..15] of ANSIChar ;
   SerialNumber : Array[0..15] of ANSIChar ;
   ExternalScaling : LongInt ;
   DacScaling : Pointer ;
   AdcScaling : Pointer ;
   end ;

PLIH_OptionsType = ^TLIH_OptionsType ;

TEPC9_GetMuxAdcOffset= function  : LongInt ; stdcall ;

TEPC9_GetStimDacOffset= function  : LongInt ; stdcall ;

TEPC9_AutoCFast= function : LongInt ; stdcall ;

TEPC9_AutoCSlow= function : LongInt ; stdcall ;

TEPC9_AutoGLeak= function : LongInt ; stdcall ;

TEPC9_AutoSearch= function : LongInt ; stdcall ;

TEPC9_AutoVpOffset= function : LongInt ; stdcall ;

TEPC9_AutoRsComp= function : LongInt ; stdcall ;

TEPC9_Reset= function : LongInt ; stdcall ;

//TEPC9_ResetTempState= function  : LongInt ; stdcall ;

TEPC9_FlushCache= function  : LongInt ; stdcall ;

TEPC9_FlushThenWait= function( Seconds : Double ) : LongInt ; stdcall ;

TEPC9_GetLastError= function   : LongInt ; stdcall ;

TEPC9_Shutdown= function   : LongInt ; stdcall ;

TEPC9_GetClipping= function  : LongInt ; stdcall ;

TEPC9_GetIpip= function(Samples : Integer ) : Double ; stdcall ;

TEPC9_GetRMSNoise= function : Double ; stdcall ;

TEPC9_GetVmon= function (Samples : Integer) : Double ; stdcall ;

TEPC9_SetCCFastSpeed= function(CCSpeed : Byte ) : LongInt ; stdcall ;

TEPC9_SetCCIHold= function(Amperes : Double) : LongInt ; stdcall ;

TEPC9_SetCFastTot= function( Farads: Double) : LongInt ; stdcall ;
TEPC9_SetCFastTau= function( Seconds: Double) : LongInt ; stdcall ;
TEPC9_GetCFastTot= function : Double ; stdcall ;
TEPC9_GetCFastTau= function : Double ; stdcall ;

TEPC9_SetCSlow= function( Farads: Double) : LongInt ; stdcall ;

TEPC9_SetCSlowCycles= function( Cycles : Integer ) : LongInt ; stdcall ;

TEPC9_SetCSlowPeak= function( Peak: Double) : LongInt ; stdcall ;

TEPC9_SetCSlowRange= function( Range : Integer ) : LongInt ; stdcall ;

//TEPC9_SetCSlowRepetitive= function(Repetitive : LongBool ) : LongInt ; stdcall ;

TEPC9_SetCurrentGain= function( NewGain: Double) : LongInt ; stdcall ;

TEPC9_SetCurrentGainIndex= function( GainIndex : Integer ) : LongInt ; stdcall ;

TEPC9_SetCCGain= function( NewCCGain : Integer ) : LongInt ; stdcall ;

//TEPC9_SetE9Board= function( E9Board : Integer ) : LongInt ; stdcall ;

TEPC9_GetExtStimPath= function : LongInt ; stdcall ;

TEPC9_SetExtStimPath= function(
                      Factor : Double ;
                      Path : Integer
                      ) : LongInt ; stdcall ;


TEPC9_SetF1Index= function(
                  Filter1 : Integer ) : LongInt ; stdcall ;

TEPC9_SetF2Response= function( Response : Integer ) : LongInt ; stdcall ;

TEPC9_SetF2Bandwidth= function( Bandwidth : Double) : LongInt ; stdcall ;

TEPC9_SetGLeak= function( Siemens : Double) : LongInt ; stdcall ;

TEPC9_SetGSeries= function( Siemens : Double) : LongInt ; stdcall ;

TEPC9_SetMode= procedure(
               Mode : Integer ;
               Gently : byte
               )  ; stdcall ;

//TEPC9_SetMuxPath= function( MuxPath : Integer ) : LongInt ; stdcall ;

TEPC9_SetRsFraction= function( Fraction : Double) : LongInt ; stdcall ;

TEPC9_SetRsMode= function( NewRsMode : Integer ) : LongInt ; stdcall ;

     TEPC9_GetRsMode= function  : LongInt ; stdcall ;

//TEPC9_SetRsValue= function( Ohms : Double ) : LongInt ; stdcall ;

TEPC9_SetStimFilterOn= function(StimFilterOn : LongBool ) : LongInt ; stdcall ;

TEPC9_SetTimeout= function( Timeout : Double) : LongInt ; stdcall ;

TEPC9_SetVHold= function( Volts : Double) : LongInt ; stdcall ;

TEPC9_SetVLiquidJunction= function( Volts : Double) : LongInt ; stdcall ;

TEPC9_SetVpOffset= function( Volts : Double) : LongInt ; stdcall ;

TEPC9_SetCCTrackHold= function( TrackVHold : Double) : LongInt ; stdcall ;

TEPC9_SetCCTrackTau= function( Tau : Integer ) : LongInt ; stdcall ;

TEPC9_GetErrorText= function(Msg : PANSIChar ) : LongInt ; stdcall ;

//TEPC9_SetLastVHold= function : LongInt ; stdcall ;

TEPC9_InitializeAndCheckForLife= function(
            ErrorMessage : PANSIChar ;
            IAmplifier : Integer ;
            PathtoScaleFile : PANSIChar ;
            pLIH_Options : PLIH_OptionsType ;
            OptionsSize : LongInt ) : LongInt ; stdcall ;

{TEPC9_FinishInitialization= function(
            ForceAmplifier : LongBool ;
            Version : ANSIChar ;
            E9Boards : Integer ) : LongInt ; stdcall ;}

TEPC9_LoadScaleFiles= function(
            ErrorMessage : PANSIChar ;
           PathtoScaleFile : PANSIChar
           ) : LongInt ; stdcall ;

TEPC9_GetMode = function : LongInt ; stdcall ;

TEPC9_GetCurrentGain = function : Double ; stdcall ;

TEPC9_GetCurrentGainIndex = function : LongInt ; stdcall ;

TEPC9_GetVHold = function : Double ; stdcall ;

TEPC9_GetCCIHold = function : Double ; stdcall ;

TEPC9_GetCCGain = function : LongInt ; stdcall ;

TEPC9_GetVLiquidJunction = function : Double ; stdcall ;

TEPC9_GetVpOffset = function : Double ; stdcall ;

TEPC9_GetCSlowRange = function : LongInt ; stdcall ;

TEPC9_GetCSlow = function : Double ; stdcall ;

TEPC9_GetGSeries = function : Double ; stdcall ;

TEPC9_GetRsFraction = function : Double ; stdcall ;

TEPC9_GetGLeak = function : Double ; stdcall ;

TEPC9_GetF1Index = function : LongInt ; stdcall ;

TEPC9_GetF2Response = function : Integer ; stdcall ;

TEPC9_GetF2Bandwidth = function : Double ; stdcall ;

TEPC9_GetStimFilterOn = function : Byte ; stdcall ;

TEPC9_GetCCTrackHold = function : Double ; stdcall ;

TEPC9_GetCCTrackTau = function : LongInt ; stdcall ;

TEPC9_GetVmonX100 = function : Byte ; stdcall ;

TEPC9_GetCCFastSpeed = function : Byte ; stdcall ;

TEPC9_GetCSlowCycles = function : Byte ; stdcall ;

TEPC9_GetCSlowPeak = function : Double ; stdcall ;

TEPC9_GetTimeout = function : Double ; stdcall ;

// EPC9_GetActiveBoard
// Returns the index of the active amplifier board.
TEPC9_GetActiveBoard = function : LongInt ; stdcall ;

TEPC9_SetActiveBoard = function( BoardNum : LongInt ) : LongInt ; stdcall ;

// EPC9_GetBoards
// Returns the number of amplifier boards.
TEPC9_GetBoards = function : LongInt ; stdcall ;

// EPC9_GetSelector
// Returns the index of the active selector position board.
TEPC9_GetSelector = function : LongInt ; stdcall ;



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
            InData : Pointer ;
            var Immediate : Byte ;
            SetStimEnd : Byte ;
            ReadContinuously: Byte ) : LongInt ; stdcall ;

TLIH_AvailableStimAndSample= function(var StillRunning : LongBool ) : LongInt ; stdcall ;

{TLIH_DoneStimAndSample= function(
            AdcSamplesPerChannel : Integer ;
            var StillRunning : Integer
            ) : LongInt ; stdcall ;}


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
            ErrorMessage : pANSIChar ;
            Amplifier : Integer ;
            ADBoard : Integer ;
            pLIH_Options : Pointer ;
            OptionsSize : Integer
            ): LongInt ; stdcall ;

TLIH_Shutdown= function : LongInt ; stdcall ;

//TLIH_SetBoardNumber= function( BoardNumber : Integer ): LongInt ; stdcall ;

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

   procedure Heka_GetCurrentGain(
          AmpNumber : Integer ;
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

   procedure Heka_SetFilter2Bandwidth(
             Bandwidth : Single )  ;

   procedure Heka_GetFilter2Bandwidth(
             var Bandwidth : Single )  ;

    procedure Heka_SetCfast( var Value : Single ) ;
    procedure Heka_GetCfast( var Value : Single ) ;
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
    procedure Heka_SetGentleModeChange( var Value : Boolean ) ;
    procedure Heka_GetGentleModeChange( var Value : Boolean ) ;
    procedure Heka_SetVHold( var Value : Single ) ;
    procedure Heka_GetVHold( var Value : Single ) ;
    procedure Heka_SetVLiquidJunction( var Value : Single ) ;
    procedure Heka_GetVLiquidJunction( var Value : Single ) ;
    procedure Heka_SetVPOffset( var Value : Single ) ;
    procedure Heka_GetVPOffset( var Value : Single ) ;
    procedure Heka_SetCCGain( var Value : Integer ) ;
    procedure Heka_GetCCGain( var Value : Integer ) ;
    procedure Heka_SetCCTrackHold( var Value : Single ) ;
    procedure Heka_GetCCTrackHold( var Value : Single ) ;
    procedure Heka_SetCCTrackTau( Value : Integer ) ;
    procedure Heka_GetCCTrackTau( var Value : Integer ) ;
    procedure Heka_SetExtStimPath( Value : Integer ) ;
    procedure Heka_GetExtStimPath( var Value : Integer ) ;
    procedure Heka_SetEnableStimFilter( Value : Boolean ) ;
    procedure Heka_GetEnableStimFilter( var Value : Boolean ) ;
    procedure Heka_SetAmplifier( Value : Integer ) ;
    procedure Heka_GetAmplifier( var Value : Integer ) ;
    procedure Heka_GetNumAmplifiers( var Value : Integer ) ;
    procedure Heka_AutoCFast ;
    procedure Heka_AutoCSlow ;
    procedure Heka_AutoGLeak ;
    procedure Heka_AutoSearch ;
    procedure Heka_AutoVpOffset ;
    procedure Heka_AutoRsComp ;
    procedure Heka_FlushCache ;

implementation

uses seslabio ;

const
    HEKA_MaxADCSamples = 32768*16 ;
    NumPointsPerBuf = 256 ;
    MaxBufs = (HEKA_MaxADCSamples div NumPointsPerBuf) + 2 ;
var
   InterfaceType : Integer ;
   EPC9Available : Boolean ;
   SerialNumber : ANSIString ;
   DACScaleFactors : Array[0..LIH_MaxDACChannels-1] of Double ;
   ADCScaleFactors : Array[0..LIH_MaxADCChannels-1] of Double ;

   FADCVoltageRangeMax : single ;    // Max. positive A/D input voltage range
   FADCMinValue : Integer ;          // Max. binary A/D sample value
   FADCMaxValue : Integer ;          // Min. binary A/D sample value

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

   GentleModeChange : Byte ;  // 1=0 gentle mode change

   DIGDefaultValue : Integer ;

    EPC9_GetMuxAdcOffset : TEPC9_GetMuxAdcOffset;
    EPC9_GetStimDacOffset : TEPC9_GetStimDacOffset;
    EPC9_AutoCFast : TEPC9_AutoCFast;
    EPC9_AutoCSlow : TEPC9_AutoCSlow;
    EPC9_AutoGLeak : TEPC9_AutoGLeak;
    EPC9_AutoSearch : TEPC9_AutoSearch ;
    EPC9_AutoVpOffset : TEPC9_AutoVpOffset ;
    EPC9_AutoRsComp : TEPC9_AutoRsComp ;
    EPC9_Reset : TEPC9_Reset ;
//    EPC9_ResetTempState : TEPC9_ResetTempState ;
    EPC9_FlushCache : TEPC9_FlushCache ;
    EPC9_FlushThenWait : TEPC9_FlushThenWait ;
    EPC9_GetLastError : TEPC9_GetLastError ;
    EPC9_Shutdown : TEPC9_Shutdown ;
    EPC9_GetClipping : TEPC9_GetClipping ;
    EPC9_GetIpip : TEPC9_GetIpip ;
    EPC9_GetRMSNoise : TEPC9_GetRMSNoise ;
//    EPC9_GetStateAdr : TEPC9_GetStateAdr ;
//    EPC9_GetEpc9NStateAdr : TEPC9_GetEpc9NStateAdr  ;
    EPC9_GetVmon : TEPC9_GetVmon ;
    EPC9_SetCCFastSpeed : TEPC9_SetCCFastSpeed ;
    EPC9_SetCCIHold : TEPC9_SetCCIHold ;
//    EPC9_SetCCStimScale : TEPC9_SetCCStimScale ;
    EPC9_SetCFastTot : TEPC9_SetCFastTot ;
    EPC9_GetCFastTot : TEPC9_GetCFastTot ;
    EPC9_SetCFastTau : TEPC9_SetCFastTau ;
    EPC9_GetCFastTau : TEPC9_GetCFastTau ;
    EPC9_SetCSlow : TEPC9_SetCSlow ;
    EPC9_SetCSlowCycles : TEPC9_SetCSlowCycles ;
    EPC9_SetCSlowPeak : TEPC9_SetCSlowPeak ;
    EPC9_SetCSlowRange : TEPC9_SetCSlowRange ;
//    EPC9_SetCSlowRepetitive : TEPC9_SetCSlowRepetitive ;
    EPC9_SetCurrentGain : TEPC9_SetCurrentGain ;
    EPC9_SetCurrentGainIndex : TEPC9_SetCurrentGainIndex ;
    EPC9_SetCCGain : TEPC9_SetCCGain ;
//    EPC9_SetE9Board : TEPC9_SetE9Board ;
    EPC9_GetExtStimPath : TEPC9_GetExtStimPath ;
    EPC9_SetExtStimPath : TEPC9_SetExtStimPath ;
    EPC9_SetF1Index : TEPC9_SetF1Index ;
    EPC9_SetF2Response : TEPC9_SetF2Response ;
    EPC9_SetF2Bandwidth : TEPC9_SetF2Bandwidth ;
    EPC9_SetGLeak : TEPC9_SetGLeak ;
    EPC9_SetGSeries : TEPC9_SetGSeries ;
    EPC9_SetMode : TEPC9_SetMode ;
//    EPC9_SetMuxPath : TEPC9_SetMuxPath ;
    EPC9_SetRsFraction : TEPC9_SetRsFraction ;
    EPC9_SetRsMode : TEPC9_SetRsMode ;
    EPC9_GetRsMode : TEPC9_GetRsMode ;
//    EPC9_SetRsValue : TEPC9_SetRsValue ;
    EPC9_SetStimFilterOn : TEPC9_SetStimFilterOn ;
    EPC9_SetTimeout : TEPC9_SetTimeout ;
    EPC9_SetVHold : TEPC9_SetVHold ;
    EPC9_SetVLiquidJunction : TEPC9_SetVLiquidJunction ;
    EPC9_SetVpOffset : TEPC9_SetVpOffset ;
    EPC9_SetCCTrackHold : TEPC9_SetCCTrackHold ;
    EPC9_SetCCTrackTau : TEPC9_SetCCTrackTau ;
    EPC9_GetErrorText : TEPC9_GetErrorText ;
//    EPC9_SetLastVHold : TEPC9_SetLastVHold ;
    EPC9_InitializeAndCheckForLife : TEPC9_InitializeAndCheckForLife ;
//    EPC9_FinishInitialization : TEPC9_FinishInitialization ;
    EPC9_LoadScaleFiles : TEPC9_LoadScaleFiles ;

     EPC9_GetMode : TEPC9_GetMode ;
     EPC9_GetCurrentGain : TEPC9_GetCurrentGain ;
     EPC9_GetCurrentGainIndex : TEPC9_GetCurrentGainIndex ;
     EPC9_GetVHold : TEPC9_GetVHold ;
     EPC9_GetCCIHold : TEPC9_GetCCIHold ;
     EPC9_GetCCGain : TEPC9_GetCCGain ;
     EPC9_GetVLiquidJunction : TEPC9_GetVLiquidJunction ;
     EPC9_GetVpOffset : TEPC9_GetVpOffset ;
     EPC9_GetCSlowRange : TEPC9_GetCSlowRange ;
     EPC9_GetCSlow : TEPC9_GetCSlow ;
     EPC9_GetGSeries : TEPC9_GetGSeries ;
     EPC9_GetRsFraction : TEPC9_GetRsFraction ;
     EPC9_GetGLeak : TEPC9_GetGLeak ;
     EPC9_GetF1Index   : TEPC9_GetF1Index ;
     EPC9_GetF2Response : TEPC9_GetF2Response ;
     EPC9_GetF2Bandwidth : TEPC9_GetF2Bandwidth ;
     EPC9_GetStimFilterOn  : TEPC9_GetStimFilterOn ;
     EPC9_GetCCTrackHold : TEPC9_GetCCTrackHold ;
     EPC9_GetCCTrackTau   : TEPC9_GetCCTrackTau ;
     EPC9_GetVmonX100  : TEPC9_GetVmonX100 ;
     EPC9_GetCCFastSpeed  : TEPC9_GetCCFastSpeed ;
     EPC9_GetCSlowCycles  : TEPC9_GetCSlowCycles ;
     EPC9_GetCSlowPeak : TEPC9_GetCSlowPeak ;
     EPC9_GetTimeout : TEPC9_GetTimeout ;
     EPC9_GetActiveBoard   : TEPC9_GetActiveBoard ;
     EPC9_SetActiveBoard   : TEPC9_SetActiveBoard ;
     EPC9_GetBoards   : TEPC9_GetBoards ;
     EPC9_GetSelector   : TEPC9_GetSelector ;

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
//    LIH_DoneStimAndSample : TLIH_DoneStimAndSample ;
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
//    LIH_SetBoardNumber : TLIH_SetBoardNumber ;
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

     GentleModeChange := 0 ;

     Model := ' Board:' + BoardName ;
     if SerialNumber <> '' then Model := Model + ' s/n ' + SerialNumber ;
     Model := Model + ' ' + format( ' (epc.dll V.%d)',[EPC9_DLLVersion]) ;

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
//        @LIH_SetBoardNumber := HEKA_LoadProcedure(LibraryHnd,'LIH_SetBoardNumber') ;
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
//        @LIH_DoneStimAndSample := HEKA_LoadProcedure(LibraryHnd,'LIH_DoneStimAndSample') ;
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
//        @EPC9_FinishInitialization := HEKA_LoadProcedure(LibraryHnd,'EPC9_FinishInitialization') ;
        @EPC9_InitializeAndCheckForLife := HEKA_LoadProcedure(LibraryHnd,'EPC9_InitializeAndCheckForLife') ;
//        @EPC9_SetLastVHold := HEKA_LoadProcedure(LibraryHnd,'EPC9_SetLastVHold') ;
        @EPC9_GetErrorText := HEKA_LoadProcedure(LibraryHnd,'EPC9_GetErrorText') ;
        @EPC9_SetCCTrackTau := HEKA_LoadProcedure(LibraryHnd,'EPC9_SetCCTrackTau') ;
        @EPC9_SetCCTrackHold := HEKA_LoadProcedure(LibraryHnd,'EPC9_SetCCTrackHold') ;
        @EPC9_SetVpOffset := HEKA_LoadProcedure(LibraryHnd,'EPC9_SetVpOffset') ;
        @EPC9_SetVLiquidJunction := HEKA_LoadProcedure(LibraryHnd,'EPC9_SetVLiquidJunction') ;
        @EPC9_SetVHold := HEKA_LoadProcedure(LibraryHnd,'EPC9_SetVHold') ;
        @EPC9_SetTimeout := HEKA_LoadProcedure(LibraryHnd,'EPC9_SetTimeout') ;
        @EPC9_SetStimFilterOn := HEKA_LoadProcedure(LibraryHnd,'EPC9_SetStimFilterOn') ;
//        @EPC9_SetRsValue := HEKA_LoadProcedure(LibraryHnd,'EPC9_SetRsValue') ;
        @EPC9_GetRsMode := HEKA_LoadProcedure(LibraryHnd,'EPC9_GetRsMode') ;
        @EPC9_SetRsMode := HEKA_LoadProcedure(LibraryHnd,'EPC9_SetRsMode') ;
        @EPC9_SetRsFraction := HEKA_LoadProcedure(LibraryHnd,'EPC9_SetRsFraction') ;
//        @EPC9_SetMuxPath := HEKA_LoadProcedure(LibraryHnd,'EPC9_SetMuxPath') ;
        @EPC9_SetMode := HEKA_LoadProcedure(LibraryHnd,'EPC9_SetMode') ;
        @EPC9_SetGSeries := HEKA_LoadProcedure(LibraryHnd,'EPC9_SetGSeries') ;
        @EPC9_SetGLeak := HEKA_LoadProcedure(LibraryHnd,'EPC9_SetGLeak') ;
        @EPC9_SetF2Response := HEKA_LoadProcedure(LibraryHnd,'EPC9_SetF2Response') ;
        @EPC9_SetF2Bandwidth := HEKA_LoadProcedure(LibraryHnd,'EPC9_SetF2Bandwidth') ;
        @EPC9_SetF1Index := HEKA_LoadProcedure(LibraryHnd,'EPC9_SetF1Index') ;
        @EPC9_SetExtStimPath := HEKA_LoadProcedure(LibraryHnd,'EPC9_SetExtStimPath') ;
        @EPC9_GetExtStimPath := HEKA_LoadProcedure(LibraryHnd,'EPC9_GetExtStimPath') ;
//        @EPC9_SetE9Board := HEKA_LoadProcedure(LibraryHnd,'EPC9_SetE9Board') ;
        @EPC9_SetCCGain := HEKA_LoadProcedure(LibraryHnd,'EPC9_SetCCGain') ;
        @EPC9_GetCCGain := HEKA_LoadProcedure(LibraryHnd,'EPC9_GetCCGain') ;
        @EPC9_SetCurrentGainIndex := HEKA_LoadProcedure(LibraryHnd,'EPC9_SetCurrentGainIndex') ;
        @EPC9_SetCurrentGain := HEKA_LoadProcedure(LibraryHnd,'EPC9_SetCurrentGain') ;
//        @EPC9_SetCSlowRepetitive := HEKA_LoadProcedure(LibraryHnd,'EPC9_SetCSlowRepetitive') ;
        @EPC9_SetCSlowRange := HEKA_LoadProcedure(LibraryHnd,'EPC9_SetCSlowRange') ;
        @EPC9_SetCSlowPeak := HEKA_LoadProcedure(LibraryHnd,'EPC9_SetCSlowPeak') ;
        @EPC9_SetCSlowCycles := HEKA_LoadProcedure(LibraryHnd,'EPC9_SetCSlowCycles') ;
        @EPC9_SetCSlow := HEKA_LoadProcedure(LibraryHnd,'EPC9_SetCSlow') ;
        @EPC9_SetCFastTot := HEKA_LoadProcedure(LibraryHnd,'EPC9_SetCFastTot') ;
        @EPC9_GetCFastTot := HEKA_LoadProcedure(LibraryHnd,'EPC9_GetCFastTot') ;
        @EPC9_SetCFastTau := HEKA_LoadProcedure(LibraryHnd,'EPC9_SetCFastTau') ;
        @EPC9_GetCFastTau := HEKA_LoadProcedure(LibraryHnd,'EPC9_GetCFastTau') ;
        @EPC9_SetCCIHold := HEKA_LoadProcedure(LibraryHnd,'EPC9_SetCCIHold') ;

        @EPC9_SetCCFastSpeed := HEKA_LoadProcedure(LibraryHnd,'EPC9_SetCCFastSpeed') ;
        @EPC9_GetVmon := HEKA_LoadProcedure(LibraryHnd,'EPC9_GetVmon') ;
        @EPC9_GetRMSNoise := HEKA_LoadProcedure(LibraryHnd,'EPC9_GetRMSNoise') ;
        @EPC9_GetIpip := HEKA_LoadProcedure(LibraryHnd,'EPC9_GetIpip') ;
        @EPC9_GetClipping := HEKA_LoadProcedure(LibraryHnd,'EPC9_GetClipping') ;
        @EPC9_Shutdown := HEKA_LoadProcedure(LibraryHnd,'EPC9_Shutdown') ;
        @EPC9_GetLastError := HEKA_LoadProcedure(LibraryHnd,'EPC9_GetLastError') ;
        @EPC9_FlushCache := HEKA_LoadProcedure(LibraryHnd,'EPC9_FlushCache') ;
        @EPC9_FlushThenWait := HEKA_LoadProcedure(LibraryHnd,'EPC9_FlushThenWait') ;
        @EPC9_Reset := HEKA_LoadProcedure(LibraryHnd,'EPC9_Reset') ;
        @EPC9_AutoVpOffset := HEKA_LoadProcedure(LibraryHnd,'EPC9_AutoVpOffset') ;
        @EPC9_AutoRsComp := HEKA_LoadProcedure(LibraryHnd,'EPC9_AutoRsComp') ;
        @EPC9_AutoSearch := HEKA_LoadProcedure(LibraryHnd,'EPC9_AutoSearch') ;
        @EPC9_AutoGLeak := HEKA_LoadProcedure(LibraryHnd,'EPC9_AutoGLeak') ;
        @EPC9_AutoCSlow := HEKA_LoadProcedure(LibraryHnd,'EPC9_AutoCSlow') ;
        @EPC9_AutoCFast := HEKA_LoadProcedure(LibraryHnd,'EPC9_AutoCFast') ;
        @EPC9_GetStimDacOffset := HEKA_LoadProcedure(LibraryHnd,'EPC9_GetStimDacOffset') ;
        @EPC9_GetMuxAdcOffset := HEKA_LoadProcedure(LibraryHnd,'EPC9_GetMuxAdcOffset') ;

        @EPC9_GetVHold := HEKA_LoadProcedure(LibraryHnd,'EPC9_GetVHold') ;
        @EPC9_GetCCIHold := HEKA_LoadProcedure(LibraryHnd,'EPC9_GetCCIHold') ;
        @EPC9_GetVLiquidJunction := HEKA_LoadProcedure(LibraryHnd,'EPC9_GetVLiquidJunction') ;
        @EPC9_GetVpOffset := HEKA_LoadProcedure(LibraryHnd,'EPC9_GetVpOffset') ;
        @EPC9_GetCFastTot := HEKA_LoadProcedure(LibraryHnd,'EPC9_GetCFastTot') ;
        @EPC9_GetCFastTot := HEKA_LoadProcedure(LibraryHnd,'EPC9_GetCFastTot') ;
        @EPC9_GetCSlowRange := HEKA_LoadProcedure(LibraryHnd,'EPC9_GetCSlowRange') ;
        @EPC9_GetCSlow := HEKA_LoadProcedure(LibraryHnd,'EPC9_GetCSlow') ;
        @EPC9_GetGSeries := HEKA_LoadProcedure(LibraryHnd,'EPC9_GetGSeries') ;
        @EPC9_GetRsMode := HEKA_LoadProcedure(LibraryHnd,'EPC9_GetRsMode') ;
        @EPC9_GetRsFraction := HEKA_LoadProcedure(LibraryHnd,'EPC9_GetRsFraction') ;
        @EPC9_GetGLeak := HEKA_LoadProcedure(LibraryHnd,'EPC9_GetGLeak') ;
        @EPC9_GetF1Index := HEKA_LoadProcedure(LibraryHnd,'EPC9_GetF1Index') ;
        @EPC9_GetF2Response := HEKA_LoadProcedure(LibraryHnd,'EPC9_GetF2Response') ;
        @EPC9_GetF2Bandwidth := HEKA_LoadProcedure(LibraryHnd,'EPC9_GetF2Bandwidth') ;
        @EPC9_GetStimFilterOn := HEKA_LoadProcedure(LibraryHnd,'EPC9_GetStimFilterOn') ;
        @EPC9_GetCCTrackHold := HEKA_LoadProcedure(LibraryHnd,'EPC9_GetCCTrackHold') ;
        @EPC9_GetCCTrackTau := HEKA_LoadProcedure(LibraryHnd,'EPC9_GetCCTrackTau') ;
        @EPC9_GetVmonX100 := HEKA_LoadProcedure(LibraryHnd,'EPC9_GetVmonX100') ;
        @EPC9_GetCCFastSpeed := HEKA_LoadProcedure(LibraryHnd,'EPC9_GetCCFastSpeed') ;
        @EPC9_GetCSlowCycles := HEKA_LoadProcedure(LibraryHnd,'EPC9_GetCSlowCycles') ;
        @EPC9_GetCSlowPeak := HEKA_LoadProcedure(LibraryHnd,'EPC9_GetCSlowPeak') ;
        @EPC9_GetTimeout := HEKA_LoadProcedure(LibraryHnd,'EPC9_GetTimeout') ;
        @EPC9_GetActiveBoard := HEKA_LoadProcedure(LibraryHnd,'EPC9_GetActiveBoard') ;
        @EPC9_SetActiveBoard := HEKA_LoadProcedure(LibraryHnd,'EPC9_SetActiveBoard') ;
        @EPC9_GetBoards := HEKA_LoadProcedure(LibraryHnd,'EPC9_GetBoards') ;
        @EPC9_GetSelector := HEKA_LoadProcedure(LibraryHnd,'EPC9_GetSelector') ;
        @EPC9_GetMode := HEKA_LoadProcedure(LibraryHnd,'EPC9_GetMode') ;
        @EPC9_GetCurrentGain := HEKA_LoadProcedure(LibraryHnd,'EPC9_GetCurrentGain') ;
        @EPC9_GetCurrentGainIndex := HEKA_LoadProcedure(LibraryHnd,'EPC9_GetCurrentGainIndex') ;
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
   ch,IAmplifier, Err, iBoard : Integer ;
   Path : ANSIString ;
   ErrorMsg : Array[0..511] of ANSIChar ;
   pLIH_Options : PLIH_OptionsType ;
begin

     DeviceInitialised := False ;

     if not LibraryLoaded then HEKA_LoadLibrary ;
     if not LibraryLoaded then Exit ;

     // Create options record
     pLIH_Options := AllocMem(SizeOf(TLIH_OptionsType)) ;
     pLIH_Options^.DacScaling := @DACScaleFactors ;
     pLIH_Options^.AdcScaling := @ADCScaleFactors ;

     case InterfaceType of
       HekaEPC9 : IAmplifier := EPC9_Epc9Ampl ;
       HekaEPC10 : IAmplifier := EPC9_Epc10Ampl ;
       HekaEPC10plus : IAmplifier := EPC9_Epc10PlusAmpl ;
       HekaEPC10USB : IAmplifier := EPC9_Epc10USB ;
       else IAmplifier := EPC9_Epc7Ampl ;
       end ;

     if IAmplifier = EPC9_Epc7Ampl then begin
        // Initialise board only
        case InterfaceType of
           HekaITC16 : iBoard := LIH_ITC16Board ;
           HekaITC18 : iBoard := LIH_ITC18Board ;
           HekaITC18USB : begin
                          iBoard := LIH_ITC18Board ;
                          pLIH_Options^.UseUSB := 1 ;
                          end;
           HekaITC1600 : iBoard := LIH_LIH1600Board ;
           HekaLIH88 : iBoard := LIH_LIH88Board ;
           else iBoard :=  LIH_ITC16Board ;
           end ;
        Err := LIH_InitializeInterface( ErrorMsg,
                                 IAmplifier,
                                 iBoard,
                                 pLIH_Options,
                                 SizeOf(TLIH_OptionsType) ) ;
        EPC9Available := False ;
        EPC9MinCurrentGain := 1.0 ;
        end
     else begin
        // Initialise patch clamp & board

        // Check if scaling files are available
        Path := ANSIString(ExtractFilePath(ParamStr(0))) ;

        SerialNumber := '' ;
        Err := EPC9_InitializeAndCheckForLife( ErrorMsg,
                                               IAmplifier,
                                               PANSIChar(Path),
                                               pLIH_Options,
                                               SizeOf(TLIH_OptionsType) ) ;
        SerialNumber := ANSIString(pLIH_Options^.SerialNumber) ;

        // Get minimum current gain
        EPC9_SetActiveBoard(0) ;
        EPC9_SetCurrentGainIndex(0) ;
        EPC9MinCurrentGain := EPC9_GetCurrentGain ;
        EPC9_SetMode(0,0) ;
        EPC9_SetCFastTot( 0.0 ) ;
        EPC9_SetCFastTau( 1E-6 ) ;
        EPC9_SetCSlow( 0.0 ) ;
        EPC9_SetCCTrackTau(0) ;
        EPC9_SetCCTrackHold(0.0);
        EPC9_SetCCFastSpeed(0);
        //EPC9_SetCSlowTau( 1E-6 ) ;

        EPC9Available := True ;
        end ;

     FreeMem(pLIH_Options) ;

     // Report error and exist
     if Err <> 0 then begin
          case Err of
              EPC9_NoScaleFiles : ShowMessage(
              'EPC files: SCALE-nnnnnn.epc & CFAST-nnnnnn.epc missing! Copy to ' + path );
              EPC9_NoScaleFile : ShowMessage(
              'EPC file: SCALE-nnnnnn.epc missing! Copy to ' + path ) ;
              EPC9_NoCFastFile : ShowMessage(
              'EPC file: CFAST-nnnnnn.epc missing! Copy to ' + path ) ;
          else ShowMessage(ANSIString(ErrorMsg)) ;
          end;
          EPC9Available := False ;
          exit ;
          end ;

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
     if EPC9Available then begin
       // EPC-9/10 mappings
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
       end
     else begin
       // Board-only mappings
       for  ch := 0  to High(AIChannelList) do AIChannelList[ch] := ch ;
       for  ch := 0  to High(AOChannelList) do AOChannelList[ch] := ch ;
       end ;

     AIBuf := Nil ;
     AOBuf := Nil ;

     ADCActive := False ;
     DACActive := False ;
     DeviceInitialised := True ;

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
   OK : LongInt ;
   SetStimEnd,ReadContinuously,Immediate : Byte ;
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
        Immediate := 0 ;
        OK := LIH_StartStimAndSample ( 1,
                                       NumADCChannels,
                                       NumADCSamples,
                                       1,
                                       AcquisitionMode,
                                       @AOChannelList,
                                       @AICHannelList,
                                       SamplingInterval,
                                       @AODataBufs,
                                       Nil,
                                       Immediate,
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
     if not ADCActive then Exit ;

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
   OK : LongInt ;
   SetStimEnd,ReadContinuously,Immediate :Byte ;
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
      for i := 0 to (NPWrite div AONumChannels) -1 do begin
          AODataBufs[ch]^[i] := AOBuf^[j] ;
          j := j + AONumChannels ;
          end;
      end;
    AOPointer := NPWrite ;

    // Start A/D and D/A conversion

    //EPC9_FlushCache ;

    SetStimEnd := 0 ;
    ReadContinuously := 0 ;
    Immediate := 0 ;
    AcquisitionMode := LIH_EnableDacOutput ;

    OK := LIH_StartStimAndSample ( AONumChannels,
                                   AINumChannels,
                                   NPWrite,
                                   NPWrite,
                                   AcquisitionMode,
                                   @AOChannelList,
                                   @AICHannelList,
                                   SamplingInterval,
                                   @AODataBufs,
                                   Nil,
                                   Immediate,
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
     if not DACActive then exit ;

     DACActive := False ;
     //ADCActive := False ;
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

     // Shut down EPC-9
     if EPC9Available then begin
        EPC9_Shutdown ;
        end;

     for i := 0 to AIMaxChannels-1 do FreeMem( AIDataBufs[i] );

     // Free DLL libraries
     if LibraryHnd > 0 then FreeLibrary( LibraryHnd ) ;
     LibraryLoaded := False ;

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
// -----------------------
// Load scale factor files
// -----------------------
var
    FileHandle : THandle ;
    Path : String ;
    NumBytes : Integer ;
begin

    Path := ExtractFilePath(ParamStr(0)) + ANSIString(FileName) ;

    if not FileExists(Path) then begin
        ShowMessage('Cannot open ' + ANSIString(FileName) + '! Locate and copy file to folder ' +  ExtractFilePath(ParamStr(0)));
        Result := 1 ;
        end ;

    if FileExists(Path) then begin
       FileHandle := FileOpen( Path, fmOpenRead ) ;
       if FileHandle > 0 then begin
          NumBytes := FileSeek( FileHandle, 0, 2 ) ;
          FileSeek( FileHandle, 0, 0 ) ;
          FileRead( FileHandle, ScaleData, NumBytes ) ;
          FileClose(FileHandle) ;
          FileSize := NumBytes ;
          end;
       end ;

    DataStart := @ScaleData[0] ;

    Result := 0 ;

    end;

procedure Heka_GetCurrentGain(
          AmpNumber : Integer ;
          var Gain : Single  ;
          var ScaleFactor : Single ) ;
// -----------------
// Get current gain
// -----------------
begin
     ScaleFactor := EPC9MinCurrentGain*1E-12 ;  // Convert to mV/pA
     Gain :=  EPC9_GetCurrentGain / EPC9MinCurrentGain ;

     end;

procedure Heka_GetCurrentGainList( List : TStrings ) ;
// -----------------------------
// Return list of current gains
// -----------------------------
begin

     List.Clear ;
     List.Add('   0.005 mV/pA') ;
     List.Add('   0.010 mV/pA') ;
     List.Add('   0.020 mV/pA') ;
     List.Add('   0.050 mV/pA') ;
     List.Add('   0.100 mV/pA') ;
     List.Add('   0.200 mV/pA') ;
     List.Add('   0.5   mV/pA') ;
     List.Add('   1.0   mV/pA') ;
     List.Add('   2.0   mV/pA') ;
     List.Add('   5.0   mV/pA') ;
     List.Add('  10.0   mV/pA') ;
     List.Add('  20.0   mV/pA') ;
     List.Add('  50.0   mV/pA') ;
     List.Add(' 100.0   mV/pA') ;
     List.Add(' 200.0   mV/pA') ;
     List.Add(' 500.0   mV/pA') ;
     List.Add('1000.0   mV/pA') ;
     List.Add('2000.0   mV/pA') ;

     end ;


procedure Heka_SetCurrentGain( iGain : Integer )  ;
// ----------------------------
// Set current gain  (by index)
// ----------------------------
var
    EPC9Gain : Integer ;
begin

   if not DeviceInitialised then Exit ;

   EPC9_SetCurrentGainIndex( iGain ) ;
   case iGain of
       0 : EPC9Gain := EPC9_Gain_0005 ;
       1 : EPC9Gain := EPC9_Gain_0010 ;
       2 : EPC9Gain := EPC9_Gain_0020 ;
       3 : EPC9Gain := EPC9_Gain_0050 ;
       4 : EPC9Gain := EPC9_Gain_0100 ;
       5 : EPC9Gain := EPC9_Gain_0200 ;
       6 : EPC9Gain := EPC9_Gain_0500 ;
       7 : EPC9Gain := EPC9_Gain_1 ;
       8 : EPC9Gain := EPC9_Gain_2 ;
       9 : EPC9Gain := EPC9_Gain_5 ;
       10 : EPC9Gain := EPC9_Gain_10 ;
       11 : EPC9Gain := EPC9_Gain_20 ;
       12 : EPC9Gain := EPC9_Gain_50 ;
       13 : EPC9Gain := EPC9_Gain_100 ;
       14 : EPC9Gain := EPC9_Gain_200 ;
       15 : EPC9Gain := EPC9_Gain_500 ;
       16 : EPC9Gain := EPC9_Gain_1000 ;
       17 : EPC9Gain := EPC9_Gain_2000 ;
       else EPC9Gain := EPC9_Gain_0005 ;
       EPC9_SetCurrentGainIndex( EPC9Gain ) ;
       end;

     end;

procedure Heka_SetFilterMode(
          iFilterNum : Integer ;
          iFilterMode : Integer  )  ;
// ----------------------------
// Set current filter mode
// ----------------------------
begin

     if not DeviceInitialised then Exit ;

     case iFilterNum of
          1 : EPC9_SetF1Index( iFilterMode ) ;
          2 : EPC9_SetF2Response( iFilterMode ) ;
         end;

     end;


procedure Heka_GetFilterMode(
          iFilterNum : Integer ;
          var iFilterMode : Integer  )  ;
// ----------------------------
// Get current filter mode
// ----------------------------
begin

     if not DeviceInitialised then Exit ;

     case iFilterNum of
          1 : iFilterMode := EPC9_GetF1Index ;
          2 : iFilterMode := EPC9_GetF2Response ;
         end;

     end;

procedure Heka_SetFilter2Bandwidth(
          Bandwidth : Single )  ;
// ----------------------------
// Set current filter bandwidth
// ----------------------------
begin
     if not DeviceInitialised then Exit ;
     EPC9_SetF2Bandwidth( Bandwidth ) ;
     end;


procedure Heka_GetFilter2Bandwidth(
          var Bandwidth : Single )  ;
// ----------------------------
// Set current filter bandwidth
// ----------------------------
begin

     if not DeviceInitialised then Exit ;
     Bandwidth := EPC9_GetF2Bandwidth ;

     end;


procedure Heka_SetCfast( var Value : Single ) ;
begin
     if not DeviceInitialised then Exit ;
     EPC9_SetCFastTot( Value ) ;
     end;

procedure Heka_GetCfast( var Value : Single ) ;
begin
     if not DeviceInitialised then Exit ;
     Value := EPC9_GetCFastTot ;
     end;


procedure Heka_SetCfastTau( var Value : Single ) ;
var
    DValue : Double ;
begin
     if not DeviceInitialised then Exit ;
     DValue := Value ;
     DValue := Max(DValue,1E-6);
     EPC9_SetCFastTau(DValue) ;
     end;

procedure Heka_GetCfastTau( var Value : Single ) ;
begin
     if not DeviceInitialised then Exit ;
     Value := EPC9_GetCFastTau ;
     end;


procedure Heka_SetCslow( var Value : Single ) ;
begin
     if not DeviceInitialised then Exit ;
     EPC9_SetCSlow( Value ) ;
     end;

procedure Heka_GetCslow( var Value : Single ) ;
begin
     if not DeviceInitialised then Exit ;
     Value := EPC9_GetCslow ;
     end;

procedure Heka_SetCslowRange( var Value : Integer ) ;
begin
     if not DeviceInitialised then Exit ;
     EPC9_SetCSlowRange( Value ) ;
     end;

procedure Heka_GetCslowRange( var Value : Integer ) ;
begin
     if not DeviceInitialised then Exit ;
     Value := EPC9_GetCslowRange ;
     end;

procedure Heka_SetGseries( var Value : Single ) ;
begin
     if not DeviceInitialised then Exit ;
     Value := Max(Value,1E-10) ;
     EPC9_SetGseries( Value ) ;
     end;

procedure Heka_GetGseries( var Value : Single ) ;
begin
     if not DeviceInitialised then Exit ;
     Value := EPC9_GetGseries ;
     end;

procedure Heka_SetGleak( var Value : Single ) ;
begin
     if not DeviceInitialised then Exit ;
     EPC9_SetGleak( Value ) ;
     end;

procedure Heka_GetGleak( var Value : Single ) ;
begin
     if not DeviceInitialised then Exit ;
     Value := EPC9_GetGleak ;
     end;

procedure Heka_SetRSValue( var Value : Single ) ;
begin
     //EPC9_SetRSValue( Value ) ;
     end;

procedure Heka_GetRSValue( var Value : Single ) ;
begin
     //Value := EPC9_GetRsValue ;
     end;

procedure Heka_SetRsFraction( var Value : Single ) ;
begin
     if not DeviceInitialised then Exit ;
     EPC9_SetRsFraction( Value ) ;
     end;

procedure Heka_GetRsFraction( var Value : Single ) ;
begin
     if not DeviceInitialised then Exit ;
     Value := EPC9_GetRsFraction ;
     end;

procedure Heka_SetRsMode( var Value : Integer ) ;
begin
     if not DeviceInitialised then Exit ;
     EPC9_SetRsMode( Value ) ;
     end;

procedure Heka_GetRsMode( var Value : Integer ) ;
begin
     if not DeviceInitialised then Exit ;
     Value := EPC9_GetRsMode ;
     end;

procedure Heka_SetMode( var Value : Integer ) ;
//
begin
     if not DeviceInitialised then Exit ;
     EPC9_SetMode( Value, GentleModeChange ) ;
     end;

procedure Heka_GetMode( var Value : Integer ) ;
begin
     if not DeviceInitialised then Exit ;
     Value := EPC9_GetMode ;
     end;

procedure Heka_SetGentleModeChange( var Value : Boolean ) ;
begin
     if not DeviceInitialised then Exit ;
     if Value then GentleModeChange := 1
              else GentleModeChange := 0  ;
     end;

procedure Heka_GetGentleModeChange( var Value : Boolean ) ;
begin
     if not DeviceInitialised then Exit ;
     if GentleModeChange = 0 then Value := True
                             else Value := False ;
     end;

procedure Heka_SetVHold( var Value : Single ) ;
begin
     if not DeviceInitialised then Exit ;
     EPC9_SetVHold( Value ) ;
     end;

procedure Heka_GetVHold( var Value : Single ) ;
begin
     if not DeviceInitialised then Exit ;
     Value := EPC9_GetVHold ;
     end;

procedure Heka_SetVLiquidJunction( var Value : Single ) ;
begin
     if not DeviceInitialised then Exit ;
     EPC9_SetVLiquidJunction( Value ) ;
     end;

procedure Heka_GetVLiquidJunction( var Value : Single ) ;
begin
     if not DeviceInitialised then Exit ;
     Value := EPC9_GetVLiquidJunction ;
     end;

procedure Heka_SetVPOffset( var Value : Single ) ;
begin
     if not DeviceInitialised then Exit ;
     EPC9_SetVPOffset( Value ) ;
     end;

procedure Heka_GetVPOffset( var Value : Single ) ;
begin
     if not DeviceInitialised then Exit ;
     Value := EPC9_GetVPOffset ;
     end;

procedure Heka_SetCCGain( var Value : Integer ) ;
begin
     if not DeviceInitialised then Exit ;
     EPC9_SetCCGain( Value ) ;
     end;

procedure Heka_GetCCGain( var Value : Integer ) ;
begin
     if not DeviceInitialised then Exit ;
     Value := EPC9_GetCCGain ;
     end;

procedure Heka_SetCCTrackHold( var Value : Single ) ;
begin
     if not DeviceInitialised then Exit ;
     EPC9_SetCCTrackHold( Value ) ;
     end;

procedure Heka_GetCCTrackHold( var Value : Single ) ;
begin
     if not DeviceInitialised then Exit ;
     Value := EPC9_GetCCTrackHold ;
     end;

procedure Heka_SetCCTrackTau( Value : Integer ) ;
begin
     if not DeviceInitialised then Exit ;
     EPC9_SetCCTrackTau( Value ) ;
     end;

procedure Heka_GetCCTrackTau( var Value : Integer ) ;
begin
     if not DeviceInitialised then Exit ;
     Value := EPC9_GetCCTrackTau ;
     end;

procedure Heka_SetExtStimPath( Value : Integer ) ;
begin
     if not DeviceInitialised then Exit ;
     EPC9_SetExtStimPath( 10.0, Value ) ;
     end;

procedure Heka_GetExtStimPath( var Value : Integer ) ;
begin
     if not DeviceInitialised then Exit ;
     Value := EPC9_GetExtStimPath ;
     end;

procedure Heka_SetEnableStimFilter( Value : Boolean ) ;
begin
     if not DeviceInitialised then Exit ;
     EPC9_SetStimFilterOn( Value ) ;
     end;

procedure Heka_GetEnableStimFilter( var Value :  Boolean ) ;
begin
     //Value := GetStimFilterOn ;
     end;


procedure Heka_SetAmplifier( Value : Integer ) ;
begin
     Value := 0 ;
     if not DeviceInitialised then Exit ;
     EPC9_SetActiveBoard(Value);
     end;

procedure Heka_GetAmplifier( var Value : Integer ) ;
begin
     if not DeviceInitialised then Exit ;
     Value := EPC9_GetActiveBoard ;
     end;

procedure Heka_GetNumAmplifiers( var Value : Integer ) ;
begin
     if not DeviceInitialised then Exit ;
     Value := EPC9_GetBoards ;
     end;


procedure Heka_AutoCFast ;
begin
     if not DeviceInitialised then Exit ;
     EPC9_AutoCFast ;
     end;

procedure Heka_AutoCSlow ;
begin
     if not DeviceInitialised then Exit ;
     EPC9_AutoCSlow ;
     end;

procedure Heka_AutoGLeak ;
begin
     if not DeviceInitialised then Exit ;
     EPC9_AutoGLeak ;
     end;

procedure Heka_AutoSearch ;
begin
     if not DeviceInitialised then Exit ;
     EPC9_AutoSearch ;
     end;

procedure Heka_AutoVpOffset ;
begin
     if not DeviceInitialised then Exit ;
     EPC9_AutoVpOffset ;
     end;

procedure Heka_AutoRsComp ;
begin
     if not DeviceInitialised then Exit ;
     EPC9_AutoRsComp ;
     end;

procedure Heka_FlushCache ;
begin
     if not DeviceInitialised then Exit ;
     EPC9_FlushCache ;
     end;



end.
