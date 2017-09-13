unit dd1550A;
// ==================================================================
// Molecular Devices Digidata 1550A Interface Library V1.0
//  (c) John Dempster, University of Strathclyde, All Rights Reserved
// ==================================================================
// 3.07.15
// 09.07.15 Tested and working with 1550A
//          HumSilencer not supported yet (unable to determine how to enable it)
//          DIGDATA1550A_StopAcquisition() hangs up until a trigger pulse is provided
//          to START input if called after a protocol with external trigger mode is started
//          but no trigger occurs.
//          Bug in AI channel mapping. If analog input number is not >= channel number
//          channel mapping is mixed up. High channel numbers can NOT be mapped to low analog inputs
// 21.08.15 AXdd1550A.dll, wdapi1140.dll & DD1550fpga.bin now acquired from PCLAMP or AXOCLAMP folder and copied
//          to settings folder C:\Users\Public\Documents\SESLABIO
// 06.01.15 AXdd1550A.dll and wdapi1140.dll now explicitly loaded from C:\Users\Public\Documents\SESLABIO
//          to ensure that DLLs in program folder are not loaded by default. Copying and
//          loading now handled by Dig1550A_CopyAndLoadLibrary()
// 09.02.16 wdapi1140.dll now loaded before axdd1550A.dll to allow axdd1550A.dll to be loaded under Windows XP
// 7.7.16 4 byte packing added to end TDD1550_Protocol record to avoid 'Error writing to device' error
//          when external trigger selected  Not clear why this is necessary
// 04.09.16 Updated to be compatible with drivers installed by PCLAMP V10.7
//          axdd?????.dll now loaded from program folder of latest version of PCLAMP or AxoScope installed
//          Whatever version number of wdapi????.dll available in folder is now loaded (instead of
//          only WDAPI1140.dll)
// 04.09.17 .. Max. no. of DAC channels limited to 4
interface

  uses WinTypes,Dialogs, SysUtils, WinProcs,mmsystem, math ;

const DIGD1550A_ANY_DEVICE       = -1;
const DIGD1550A_MAX_AI_CHANNELS  = 8;            // NST reduce to 8 AI channels from 16 to support req 1
const DIGD1550A_MAX_AO_CHANNELS  = 8;            // NST increase to 8 A0 channels from 4 to support req 1
const DIGD1550A_MAX_TELEGRAPHS   = 4;
const DIGD1550A_MAX_DO_CHANNELS  = 16;
const DIGD1550A_MAX_ANC_CHANNELS = 1;
const DIGD1550A_MAX_HARMONIC_CHNANELS = 2 ;

// Active bits in the digital input stream.
const DIGD1550A_BIT_EXT_TRIGGER = $0001;
const DIGD1550A_BIT_EXT_TAG     = $0002;

const DIGD1550A_FLAG_EXT_TRIGGER  = $0001;
const DIGD1550A_FLAG_TAG_BIT0     = $0002;
const DIGD1550A_FLAG_STOP_ON_TC   = $0004;
const DIGD1550A_FLAG_SCOPE_OUT    = $0008;
const DIGD1550A_FLAG_DO15_OUT     = $8000;
//const BYTE DIGD1550A_ANC[DIGD1550A_MAX_ANC_CHANNELS] = {0, 4};
const DIGD1550A_IO_TIMEOUT  = 1000;

// Error codes
const DIGD1550A_ERROR                       = $01000000;
const DIGD1550A_ERROR_OUTOFMEMORY           = $01000002;
const DIGD1550A_ERROR_STARTACQ              = $01000006;
const DIGD1550A_ERROR_STOPACQ               = $01000007;
const DIGD1550A_ERROR_READDATA              = $01000009;
const DIGD1550A_ERROR_WRITEDATA             = $0100000A;
const DIGD1550A_ERROR_THREAD_START          = $0100000F;
const DIGD1550A_ERROR_THREAD_TIMEOUT        = $01000010;
const DIGD1550A_ERROR_THREAD_WAIT_ABANDONED = $01000011;
const DIGD1550A_ERROR_OPEN_RAMWARE          = $01000013;
const DIGD1550A_ERROR_DOWNLOAD              = $01000015;
const DIGD1550A_ERROR_OPEN_FPGA             = $01000016;
const DIGD1550A_ERROR_LOAD_FPGA             = $01000017;
const DIGD1550A_ERROR_READ_RAMWARE          = $01000018;
const DIGD1550A_ERROR_SIZE_RAMWARE          = $01000019;
const DIGD1550A_ERROR_READ_FPGA             = $0100001A;
const DIGD1550A_ERROR_SIZE_FPGA             = $0100001B;
const DIGD1550A_ERROR_PIPE_NOT_FOUND        = $0100001E;
const DIGD1550A_ERROR_OVERRUN               = $01000020;
const DIGD1550A_ERROR_UNDERRUN              = $01000021;
const DIGD1550A_ERROR_SETPROTOCOL           = $01000022;
const DIGD1550A_ERROR_SETAOVALUE            = $01000023;
const DIGD1550A_ERROR_SETDOVALUE            = $01000024;
const DIGD1550A_ERROR_GETAIVALUE            = $01000025;
const DIGD1550A_ERROR_GETDIVALUE            = $01000026;
const DIGD1550A_ERROR_READTELEGRAPHS        = $01000027;
const DIGD1550A_ERROR_READCALIBRATION       = $01000028;
const DIGD1550A_ERROR_WRITECALIBRATION      = $01000029;
const DIGD1550A_ERROR_READEEPROM            = $0100002A;
const DIGD1550A_ERROR_WRITEEEPROM           = $0100002B;
const DIGD1550A_ERROR_SETTHRESHOLD          = $0100002C;
const DIGD1550A_ERROR_GETTHRESHOLD          = $0100002D;
const DIGD1550A_ERROR_NOTPRESENT            = $0100002E;
const DIGD1550A_ERROR_USB1NOTSUPPORTED      = $0100002F;
const DIGD1550A_ERROR_CRC_CHECKFAIL	     = $0100003A;

const DIGD1550A_ERROR_DEVICEERROR           = $03000000;

const DIGD1550A_ERROR_SYSERROR              = $02000000;

// All error codes from AXDIGD1550A.DLL have one of these bits set.
const DIGD1550A_ERROR_MASK                  = $FF000000;

type

TDATABUFFER = packed record
   uNumSamples : Cardinal ;      // Number of samples in this buffer.
   uFlags : Cardinal ;           // Flags describing the data buffer.
   pnData : Pointer ;            // The buffer containing the data.
   psDataFlags : Pointer ;       // Byte Flags split out from the data buffer.
   pNextBuffer : Pointer ;       // Next buffer in the list.
   pPrevBuffer : Pointer ;       // Previous buffer in the list.
   end ;
PDATABUFFER = ^TDATABUFFER ;

//
// Define a linked list structure for holding floating point acquisition buffers.
//
TFLOATBUFFER = packed record
   uNumSamples : Cardinal ;  // Number of samples in this buffer.
   uFlags : Cardinal ;       // Flags discribing the data buffer.
   pfData : Pointer ;       // The buffer containing the data.
   pNextBuffer : Pointer ;          // Next buffer in the list.
   pPrevBuffer : Pointer ;          // Previous buffer in the list.
   end ;
PFLOATBUFFER = ^TFLOATBUFFER ;

TDIGD1550A_Info = packed record
   VendorID : Word ;
   ProductID : Word ;
   SerialNumber : Cardinal ;
   Name : Array[0..31] of ANSIChar ;
   FirmwareVersion : Array[0..15] of ANSIChar ;
   FPGAVersion : Array[0..15] of ANSIChar ;
   InputBufferSamples : Cardinal ;
   OutputBufferSamples : Cardinal ;
   AIChannels : Cardinal ;
   AOChannels : Cardinal ;
   Telegraphs : Cardinal ;
   DOChannels : Cardinal ;           // (bits)
   MinSequencePeriodUS : Double ;
   MaxSequencePeriodUS : Double ;
   SequenceQuantaUS : Double ;
   MinPrequeueSamples : Cardinal ;
   MaxPrequeueSamples : Cardinal ;
   ScopeOutBit : Word ;
   ANCGatingBits: Array[0..2] of Word ;
   USB1 : ByteBool ;
   MaxSamplingFreq : Byte ;       // NST 0 = 500kHz , 1= 250 kHz  Req 3
	 ANC_Enable : Byte ;
   end ;

//==============================================================================================
// STRUCTURE: DIGD1550A_Protocol
// PURPOSE:   Describes acquisition settings.
//

TDIGD1550A_Protocol = packed record
   dSequencePeriodUS : Double ;       // Sequence interval in us.
   uFlags : Cardinal ;                // Boolean flags that control options.

   nScopeOutAIChannel : Integer ;     // Analog Input to generate "Scope Output" pulse
   nScopeOutThreshold : SmallInt ;    // "Scope Output"=on threshold level  [cnts]
   nScopeOutHysteresis : SmallInt ;   // "Scope Output"=on hysterisis delta [cnts]
   bScopeOutPolarity : ByteBool ;    // TRUE = positive polarity.

   // Inputs:
   uAIChannels : Cardinal ;
   anAIChannels: Array[0..DIGD1550A_MAX_AI_CHANNELS-1] of Integer ;
   pAIBuffers : Pointer ;
   uAIBuffers : Cardinal ;
   bDIEnable : ByteBool ;
   bUnused1 : Array[1..3] of ByteBool ;        // (alignment padding)

   // Outputs:
   uAOChannels : Cardinal ;
   anAOChannels : Array[0..DIGD1550A_MAX_AO_CHANNELS-1] of Integer ;
   pAOBuffers : Pointer ;
   uAOBuffers : Cardinal ;
   bDOEnable : ByteBool ;
   bUnused2 : Array[1..3] of ByteBool ;        // (alignment padding)

   uChunksPerSecond : Cardinal ;   // Granularity of data transfer.
   uTerminalCount : Cardinal ;     // If DIGD1550A_FLAG_STOP_ON_TC this is the count.

   ANCEnable : Array[0..DIGD1550A_MAX_ANC_CHANNELS-1] of Integer ;
   Harmonics : Array[0..DIGD1550A_MAX_HARMONIC_CHNANELS-1] of Integer ;
	 NoOfAvgCycle : Integer ;       // NST Maximum Number of Average Cycle

   bSaveAI : ByteBool ;
   bSaveAO : ByteBool ;
 	 MinSequencePeriodUS : Double ;   // NST Minimum sequence period
	 MaxSequencePeriodUS : Double ;   // NST Maximum Sequence Period as per change in Maximum Sampling Frequency 060612
	 TriggerTimeout : Cardinal ;

                                      // 7.7.16
   Packing : Array[1..4] of Byte ;    // 4 byte packing of avoid 'Error writing to device' error
                                      // when external trigger selected
                                      // Not clear why this is necessary


   end ;

//==============================================================================================
// STRUCTURE: DIGD1550A_Calibration
// PURPOSE:   Describes calibration constants for data correction.
//
TDIGD1550A_Calibration = packed record

   anADCGains : Array[0..DIGD1550A_MAX_AI_CHANNELS-1] of Single ;    // Get/Set
   anADCOffsets : Array[0..DIGD1550A_MAX_AI_CHANNELS-1] of SmallInt ;  // Get/Set

   afDACGains : Array[0..DIGD1550A_MAX_AO_CHANNELS-1] of Single ;    // Get
   anDACOffsets : Array[0..DIGD1550A_MAX_AO_CHANNELS-1] of SmallInt ;  // Get

   MaxSamplingFreq : Integer ;
	 NumberOf_ANC_Channel : Integer ;

   end ;

//==============================================================================================
// STRUCTURE: DIGD1550A_PowerOnData
// PURPOSE:   Contains items that are set in the EEPROM of the DIGD1550A as power-on defaults.
//
TDIGD1550A_PowerOnData = packed record
   uDigitalOuts : Cardinal ;
   anAnalogOuts : Array[0..DIGD1550A_MAX_AO_CHANNELS-1] of SmallInt;
   end ;

//==============================================================================================
// STRUCTURE: Start acquisition info.
// PURPOSE:   To store the start acquisition time and precision, by querying a high resolution
//            timer before and after the start acquisition SCSI command.
//
TDIGD1550A_StartAcqInfo = packed record
   StartTime : Integer ; // SYSTEMTIME? Stores the time and date of the begginning of the acquisition.
   n64PreStartAcq : Int64 ;   // Stores the high resolution counter before the acquisition start.
   n64PostStartAcq : Int64 ;  // Stores the high resolution counter after the acquisition start.
   end ;


TDIGD1550A_Reset = Function : ByteBool ;  cdecl;

TDIGD1550A_GetDeviceInfo = Function(
                        pInfo : Pointer
                        ) : ByteBool ;  cdecl;

TDIGD1550A_SetSerialNumber = Function (
                          uSerialNumber : cardinal
                          ) : ByteBool ;  cdecl;

TDIGD1550A_GetBufferGranularity =   Function  : Cardinal ;  cdecl;

TDIGD1550A_SetProtocol =   Function(
                        var DIGD1550A_Protocol : TDIGD1550A_Protocol
                        ) : ByteBool ;  cdecl;

TDIGD1550A_GetProtocol =   Function (
                        var DIGD1550A_Protocol : TDIGD1550A_Protocol
                        ) : ByteBool ;  cdecl;

TDIGD1550A_StartAcquisition =   Function : ByteBool ;  cdecl;
TDIGD1550A_StopAcquisition =   Function  : ByteBool ;  cdecl;
TDIGD1550A_IsAcquiring =   Function  : ByteBool ;  cdecl;

TDIGD1550A_GetAIPosition =   Function(
                          var uSequences : Int64) : ByteBool ;  cdecl;
TDIGD1550A_GetAOPosition =   Function(
                          var uSequences : Int64) : ByteBool ;  cdecl;

TDIGD1550A_GetAIValue = Function(
                     uAIChannel : Cardinal ;
                     var nValue : SmallInt
                      ) : ByteBool ;  cdecl;
TDIGD1550A_GetDIValue = Function (
                     var wValue : Word
                     ) : ByteBool ;  cdecl;

TDIGD1550A_SetAOValue =   Function (
                       uAOChannel : Cardinal ;
                       nValue : SmallInt ) : ByteBool ;  cdecl;
TDIGD1550A_SetDOValue =   Function (
                       wValue : Word
                       ) : ByteBool ;  cdecl;

TDIGD1550A_SetTrigThreshold =   Function (
                             nValue : SmallInt
                             ) : ByteBool ;  cdecl;
TDIGD1550A_GetTrigThreshold =   Function (
                             var nValue : SmallInt
                             ) : ByteBool ;  cdecl;

TDIGD1550A_ReadTelegraphs =   Function (
                           uFirstChannel : Cardinal ;
                           var pnValue : SmallInt ;
                           uValues : Cardinal
                           ) : ByteBool ;  cdecl;

TDIGD1550A_GetTimeAtStartOfAcquisition =   procedure (
                                        var StartAcqInfo : TDIGD1550A_StartAcqInfo
                                        ) ; cdecl;

TDIGD1550A_GetCalibrationParams =   Function (
                                  var Params : TDIGD1550A_Calibration
                                  ) : ByteBool ;  cdecl;

TDIGD1550A_SetCalibrationParams = Function (
                               const Params : TDIGD1550A_Calibration
                               ) : ByteBool ;  cdecl;

TDIGD1550A_GetPowerOnData = Function(
                         var Data : TDIGD1550A_PowerOnData
                         ) : ByteBool ;  cdecl;

TDIGD1550A_SetPowerOnData =   Function (
                           const Data : TDIGD1550A_PowerOnData
                           )  : ByteBool ;  cdecl;

TDIGD1550A_GetEepromParams =   Function (
                            pvEepromImage : pointer ;
                            uBytes : Cardinal
                            )  : ByteBool ;  cdecl;

TDIGD1550A_SetEepromParams =   Function (
                            pvEepromImage : Pointer ;
                            uBytes : Cardinal
                            )  : ByteBool ;  cdecl;

TDIGD1550A_GetLastErrorText =   Function(
                            pszMsg : PANSIChar ;
                            uMsgLen : Cardinal
                            ) : ByteBool ;  cdecl;
TDIGD1550A_GetLastError =   Function : Integer ;  cdecl;

// Find, Open & close device.

TDIGD1550A_CountDevices = Function : cardinal ; cdecl ;

TDIGD1550A_FindDevices = Function(
                      pInfo : Pointer ;
                      uMaxDevices : Cardinal ;
                      var Error : Integer ) : cardinal ; cdecl ;

TDIGD1550A_GetErrorText = Function(
                       nError : Integer ;
                       pszMsg : PANSIChar ;
                       uMsgLen : Integer ) : ByteBool ; cdecl ;

TDIGD1550A_OpenDevice = Function(
                     uSerialNumber : Cardinal ;
                     var Error : Integer
                     ) : ByteBool ; cdecl ;

TDIGD1550A_CloseDevice = procedure ; cdecl ;

// Utility functions

TDIGD1550A_VoltsToDAC = Function(
                     var CalData : TDIGD1550A_Calibration ;
                     uDAC : Cardinal ;
                     dVolts : Double ) : Integer ; cdecl {DAC_VALUE} ;

TDIGD1550A_DACtoVolts = Function(
                     var CalData : TDIGD1550A_Calibration ;
                     uDAC : Cardinal ;
                     nDAC : Integer ) : Double ;

TDIGD1550A_VoltsToADC = Function(
                     dVolts : double
                     ) : Integer ; cdecl {ADC_VALUE} ;

TDIGD1550A_ADCtoVolts = Function(
                     nADC : Integer ) : Double ; cdecl ;


  procedure DIGD1550A_InitialiseBoard ;
  procedure DIGD1550A_LoadLibrary  ;

  procedure DIGD1550A_ConfigureHardware(
            EmptyFlagIn : Integer ) ;

  function  DIGD1550A_ADCToMemory(
            HostADCBuf : Pointer ;
            NumADCChannels : Integer ;
            NumADCSamples : Integer ;
            var dt : Double ;
            ADCVoltageRange : Single ;
            TriggerMode : Integer ;
            CircularBuffer : Boolean ;
            ADCChannelInputMap : Array of Integer
            ) : Boolean ;

  function DIGD1550A_StopADC : Boolean ;

  procedure DIGD1550A_GetADCSamples (
            var OutBuf : Array of SmallInt ;
            var OutBufPointer : Integer
            ) ;

  procedure DIGD1550A_CheckSamplingInterval(
          var SamplingInterval : Double ;
          ADCNumChannels : Integer ) ;


  function  DIGD1550A_MemoryToDACAndDigitalOut(
          var DACValues : Array of SmallInt  ; // D/A output values
          NumDACChannels : Integer ;                // No. D/A channels
          NumDACPoints : Integer ;                  // No. points per channel
          var DigValues : Array of SmallInt  ; // Digital port values
          DigitalInUse : Boolean ;             // Output to digital outs
          ExternalTrigger : Boolean ;           // Wait for ext. trigger
          RepeatWaveform  : Boolean            // Repeat output waveform
          ) : Boolean ;                        // before starting output

  function DIGD1550A_GetDACUpdateInterval : double ;

  function DIGD1550A_StopDAC : Boolean ;

  procedure DIGD1550A_WriteDACsAndDigitalPort(
            var DACVolts : array of Single ;
            nChannels : Integer ;
            DigValue : Integer
            ) ;

  function  DIGD1550A_GetLabInterfaceInfo(
            var Model : string ; { Laboratory interface model name/number }
            var ADCMaxChannels : Integer ;        // Max. no. of A/D channels
            var ADCMinSamplingInterval : Double ; { Smallest sampling interval }
            var ADCMaxSamplingInterval : Double ; { Largest sampling interval }
            var ADCMinValue : Integer ; { Negative limit of binary ADC values }
            var ADCMaxValue : Integer ; { Positive limit of binary ADC values }
            var ADCVoltageRanges : Array of single ; { A/D voltage range option list }
            var NumADCVoltageRanges : Integer ; { No. of options in above list }
            var ADCBufferLimit : Integer ;      { Max. no. samples in A/D buffer }
            var DACMaxChannels : Integer ;      // Max. no. of D/A channels
            var DACMaxVolts : Single ; { Positive limit of bipolar D/A voltage range }
            var DACMinUpdateInterval : Double ;{Min. D/A update interval }
            SettingsDirectoryIn : string
            ) : Boolean ;

  function DIGD1550A_GetMaxDACVolts : single ;

  function DIGD1550A_ReadADC( Channel : Integer ) : SmallInt ;

  procedure DIGD1550A_GetChannelOffsets(
            var Offsets : Array of Integer ;
            NumChannels : Integer
            ) ;

  procedure DIGD1550A_CloseLaboratoryInterface ;

  function  DIGD1550A_CopyAndLoadLibrary(
          DLLName : string ;
          SourcePath : string ;
          DestPath : string ) : Thandle ;

  function  DIGD1550A_LoadProcedure(
         Hnd : THandle ;       { Library DLL handle }
         Name : string         { Procedure name within DLL }
         ) : Pointer ;         { Return pointer to procedure }

   function TrimChar( Input : Array of ANSIChar ) : string ;
   procedure DIGD1550A_CheckError(  Err : Integer ; OK : ByteBool ) ;

   procedure DIGD1550A_FillOutputBufferWithDefaultValues ;

implementation

uses seslabio ;

const
    DIGD1550A_MaxADCSamples = 32768*16 ;
    NumPointsPerBuf = 64;//256 ;
    MaxBufs = (DIGD1550A_MaxADCSamples div NumPointsPerBuf) + 2 ;
var

   FADCVoltageRangeMax : single ;    // Max. positive A/D input voltage range
   FADCMinValue : Integer ;          // Max. binary A/D sample value
   FADCMaxValue : Integer ;          // Min. binary A/D sample value
   FDACMinUpdateInterval : Double ;  // Min. D/A update interval (s)

   FADCMinSamplingInterval : single ;  // Min. A/D sampling interval (s)
   FADCMaxSamplingInterval : single ;  // Max. A/D sampling interval (s)

   FDACVoltageRangeMax : single ;      // Max. D/A voltage range (+/-V)

   DeviceInitialised : boolean ; { True if hardware has been initialised }

   FOutPointer : Integer ;    // A/D sample pointer in O/P buffer
   FNumSamplesRequired : Integer ; // No. of A/D samples to be acquired ;
   FCircularBuffer : Boolean ;     // TRUE = repeated buffer fill mode
   AIPosition : Int64 ;
   AIBuf : PSmallIntArray ;
   AIPointer : Integer ;
   AIBufNumSamples : Integer ;        // Input buffer size (no. samples)
   GetADCSamplesInUse : Boolean ;

   ADCActive : Boolean ;  // A/D sampling in progress flag
   DACActive : Boolean ;  // D/A output in progress flag

   Err : Integer ;                           // Error number returned by Digidata
   ErrorMsg : Array[0..80] of ANSIChar ;         // Error messages returned by Digidata

   DD1550AHnd : THandle ;         // axDIGD1550.dll library handle
   AxDD1550AHnd : THandle ;       // AxDD1550A.dll library handle
   wdapiHnd : THandle ;      // wdapi.dll library handle

   LibraryLoaded : boolean ;      // Libraries loaded flag
   Protocol : TDIGD1550A_Protocol ;  // Digidata command protocol
   NumDevices : Integer ;
   DeviceInfo : Array[0..7] of TDIGD1550A_Info ;


   Calibration : TDIGD1550A_Calibration ; // Calibration parameters
   SettingsDirectory : String ;

   NumOutChannels : Integer ;          // No. of channels in O/P buffer
   NumOutPoints : Integer ;            // No. of time points in O/P buffer
   OutPointer : Integer ;              // Pointer to latest value written to AOBuf
   AOPosition : Int64 ;              // Pointer to latest output value
   AORepeatWaveform : Boolean ;      // TRUE = repeated output DAC/DIG waveform
   OutValues : PSmallIntArray ;

   AOBuf : PSmallIntArray ;
   AOPointer : Integer ;
   AOBufNumSamples : Integer ;        // Output buffer size (no. samples)

   DACDefaultValue : Array[0..DIGD1550A_MAX_AO_CHANNELS-1] of SmallInt ;

   AIBufs : Array[0..MaxBufs-1] of TDATABUFFER ;
   AOBufs : Array[0..MaxBufs-1] of TDATABUFFER ;

   DIGDefaultValue : Integer ;

  DIGD1550A_CountDevices : TDIGD1550A_CountDevices ;
  DIGD1550A_FindDevices : TDIGD1550A_FindDevices ;
  DIGD1550A_GetErrorText : TDIGD1550A_GetErrorText ;
  DIGD1550A_OpenDevice : TDIGD1550A_OpenDevice ;
  DIGD1550A_CloseDevice : TDIGD1550A_CloseDevice;
  DIGD1550A_VoltsToDAC : TDIGD1550A_VoltsToDAC ;
  DIGD1550A_DACtoVolts : TDIGD1550A_DACtoVolts;
  DIGD1550A_VoltsToADC : TDIGD1550A_VoltsToADC ;
  DIGD1550A_ADCtoVolts : TDIGD1550A_ADCtoVolts ;
  DIGD1550A_Reset : TDIGD1550A_Reset ;
  DIGD1550A_GetDeviceInfo : TDIGD1550A_GetDeviceInfo ;
  DIGD1550A_SetSerialNumber : TDIGD1550A_SetSerialNumber ;
  DIGD1550A_GetBufferGranularity : TDIGD1550A_GetBufferGranularity;
  DIGD1550A_SetProtocol : TDIGD1550A_SetProtocol ;
  DIGD1550A_GetProtocol : TDIGD1550A_GetProtocol;
  DIGD1550A_StartAcquisition : TDIGD1550A_StartAcquisition ;
  DIGD1550A_StopAcquisition : TDIGD1550A_StopAcquisition ;
  DIGD1550A_IsAcquiring : TDIGD1550A_IsAcquiring ;
  DIGD1550A_GetAIPosition : TDIGD1550A_GetAIPosition;
  DIGD1550A_GetAOPosition : TDIGD1550A_GetAOPosition;
  DIGD1550A_GetAIValue : TDIGD1550A_GetAIValue ;
  DIGD1550A_GetDIValue : TDIGD1550A_GetDIValue ;
  DIGD1550A_SetAOValue : TDIGD1550A_SetAOValue ;
  DIGD1550A_SetDOValue : TDIGD1550A_SetDOValue ;
  DIGD1550A_SetTrigThreshold : TDIGD1550A_SetTrigThreshold ;
  DIGD1550A_GetTrigThreshold : TDIGD1550A_GetTrigThreshold ;
  DIGD1550A_ReadTelegraphs : TDIGD1550A_ReadTelegraphs ;
  DIGD1550A_GetTimeAtStartOfAcquisition : TDIGD1550A_GetTimeAtStartOfAcquisition ;
  DIGD1550A_GetCalibrationParams : TDIGD1550A_GetCalibrationParams ;
  DIGD1550A_SetCalibrationParams : TDIGD1550A_SetCalibrationParams;
  DIGD1550A_GetPowerOnData : TDIGD1550A_GetPowerOnData ;
  DIGD1550A_SetPowerOnData : TDIGD1550A_SetPowerOnData ;
  DIGD1550A_GetEepromParams : TDIGD1550A_GetEepromParams ;
  DIGD1550A_SetEepromParams : TDIGD1550A_SetEepromParams;
  DIGD1550A_GetLastErrorText : TDIGD1550A_GetLastErrorText ;
  DIGD1550A_GetLastError : TDIGD1550A_GetLastError ;

// Find, Open & close device.
  t0 : Integer ;


function  DIGD1550A_GetLabInterfaceInfo(
            var Model : string ; { Laboratory interface model name/number }
            var ADCMaxChannels : Integer ;        // Max. no. of A/D channels
            var ADCMinSamplingInterval : Double ; { Smallest sampling interval }
            var ADCMaxSamplingInterval : Double ; { Largest sampling interval }
            var ADCMinValue : Integer ; { Negative limit of binary ADC values }
            var ADCMaxValue : Integer ; { Positive limit of binary ADC values }
            var ADCVoltageRanges : Array of single ; { A/D voltage range option list }
            var NumADCVoltageRanges : Integer ; { No. of options in above list }
            var ADCBufferLimit : Integer ;      { Max. no. samples in A/D buffer }
            var DACMaxChannels : Integer ;      // Max. no. of D/A channels
            var DACMaxVolts : Single ; { Positive limit of bipolar D/A voltage range }
            var DACMinUpdateInterval : Double ;{Min. D/A update interval }
            SettingsDirectoryIn : string
            ) : Boolean ;
{ --------------------------------------------
  Get information about the interface hardware
  -------------------------------------------- }

begin

     SettingsDirectory := SettingsDirectoryIn ;

     if not DeviceInitialised then DIGD1550A_InitialiseBoard ;
     if not DeviceInitialised then begin
        Result := DeviceInitialised ;
        Exit ;
        end ;

     { Get device model and firmware details }
     Model := TrimChar(DeviceInfo[0].Name) + ' (V' +
              TrimChar(DeviceInfo[0].FirmwareVersion) + ' firmware)';

     // Define available A/D voltage range options
     ADCVoltageRanges[0] := 10.0 ;
     NumADCVoltageRanges := 1 ;
     FADCVoltageRangeMax := ADCVoltageRanges[0] ;

     // A/D sample value range (16 bits)
     ADCMinValue := -32678 ;
     ADCMaxValue := -ADCMinValue - 1 ;
     FADCMinValue := ADCMinValue ;
     FADCMaxValue := ADCMaxValue ;

     // Min./max. A/D sampling intervals

     // Note. min. sampling interval is 1.2X greater than MinSequencePeriodUS
     // to avoid overshoot on DAC update at highest sampling rates. DAC
     // possibly has inadequate response rate for 250kHz updates.

     ADCMinSamplingInterval := 1.2*DeviceInfo[0].MinSequencePeriodUS*1E-6 ;

     ADCMaxSamplingInterval := ADCMinSamplingInterval*1000.0 ;//DeviceInfo[0].MaxSequencePeriodUS*1E-6 ;
     ADCMaxSamplingInterval := 1E3 ; // DeviceInfo[0].SequenceQuantaUS*1E-6*32768 ;
                                     // Unable to get sampling interval > 1ms to work
     FADCMinSamplingInterval := ADCMinSamplingInterval ;
     FADCMaxSamplingInterval := ADCMaxSamplingInterval ;
     ADCMaxChannels := DIGD1550A_MAX_AI_CHANNELS ;

     // Upper limit of bipolar D/A voltage range
     DACMaxVolts := 10.0 ;
     FDACVoltageRangeMax := 10.0 ;
     DACMinUpdateInterval := 4E-6 ;
     FDACMinUpdateInterval := DACMinUpdateInterval ;
     DACMaxChannels := 4;//DIGD1550A_MAX_AO_CHANNELS ;

     Result := DeviceInitialised ;

     end ;


procedure DIGD1550A_LoadLibrary  ;
{ -------------------------------------
  Load AXDIGD1550A.DLL library into memory
  -------------------------------------}
var
     AxonDLL,ProgramDir,SYSDrive : String ; // DLL file paths
     SourcePath,TrialPath : string ;
     Path : Array[0..255] of Char ;
     VMaj,VMin : Integer ;
     SearchRec : TSearchRec ;
begin

     ProgramDir := ExtractFilePath(ParamStr(0)) ;
     GetSystemDirectory( Path, High(Path) ) ;
     SYSDrive := ExtractFileDrive(String(Path)) ;

//   Find Axdd1550A.dll and copy to settings folder
     AxonDLL :=  'AxDD1550A.DLL' ;
     SourcePath := '' ;
     for VMaj := 15 downto 7 do for VMin := 9 downto 0 do begin
         // Check for PCLAMP installation
         TrialPath := format( '%s\Program Files\Molecular Devices\pCLAMP%d.%d\',
                               [SYSDrive,VMaj,VMin,AxonDLL]);
         if FileExists(TrialPath + AXONDLL) then SourcePath := TrialPath ;
         if SourcePath <> '' then Break ;

         TrialPath := format( '%s\Program Files (x86)\Molecular Devices\pCLAMP%d.%d\',
                               [SYSDrive,VMaj,VMin,AxonDLL]);
         if FileExists(TrialPath + AXONDLL) then SourcePath := TrialPath ;
         if SourcePath <> '' then Break ;

          // Check for Axoscope installation
         TrialPath := format( '%s\Program Files\Molecular Devices\Axoscope%d.%d\',
                               [SYSDrive,VMaj,VMin,AxonDLL]);
         if FileExists(TrialPath + AXONDLL) then SourcePath := TrialPath ;
         if SourcePath <> '' then Break ;

         TrialPath := format( '%s\Program Files\Molecular Devices (x86)\Axoscope%d.%d\',
                               [SYSDrive,VMaj,VMin,AxonDLL]);
         if FileExists(TrialPath + AXONDLL) then SourcePath := TrialPath ;
         if SourcePath <> '' then Break ;

         end;

     // If not available, use version from installation
     if SourcePath = '' then begin
        TrialPath := ProgramDir ;
        if FileExists(TrialPath + AXONDLL) then SourcePath := TrialPath ;
        end;

     // Copy to settings folder
     if SourcePath <> '' then begin
        Err := FindFirst( SourcePath + 'wdapi*.dll', faAnyFile, SearchRec ) ;
        if Err = 0 then
           wdapiHnd := DIGD1550A_CopyAndLoadLibrary( SearchRec.Name, SourcePath, SettingsDirectory ) ;
        AXDD1550AHnd := DIGD1550A_CopyAndLoadLibrary( AxonDLL, SourcePath, SettingsDirectory ) ;
        CopyFile( PChar(SourcePath+'DD1550Afpga.bin'), PChar(SettingsDirectory+'DD1550Afpga.bin'), false ) ;
        end
     else ShowMessage( AxonDLL + ' missing from ' + SettingsDirectory ) ;

     // Load DLL which calls Axon DLLs
     DD1550AHnd := DIGD1550A_CopyAndLoadLibrary( 'DD1550A.DLL', ProgramDir, SettingsDirectory ) ;

     if dd1550AHnd > 0 then begin
        { Get addresses of procedures in library }
        @DIGD1550A_CountDevices := DIGD1550A_LoadProcedure(dd1550AHnd,'DIGD1550A_CountDevices') ;
        @DIGD1550A_FindDevices := DIGD1550A_LoadProcedure(dd1550AHnd,'DIGD1550A_FindDevices') ;
        @DIGD1550A_GetErrorText := DIGD1550A_LoadProcedure(dd1550AHnd,'DIGD1550A_GetErrorText') ;
        @DIGD1550A_OpenDevice := DIGD1550A_LoadProcedure(dd1550AHnd,'DIGD1550A_OpenDevice') ;
        @DIGD1550A_CloseDevice := DIGD1550A_LoadProcedure(dd1550AHnd,'DIGD1550A_CloseDevice') ;
        @DIGD1550A_VoltsToDAC := DIGD1550A_LoadProcedure(dd1550AHnd,'DIGD1550A_VoltsToDAC') ;
        @DIGD1550A_DACtoVolts := DIGD1550A_LoadProcedure(dd1550AHnd,'DIGD1550A_DACtoVolts') ;
        @DIGD1550A_VoltsToADC := DIGD1550A_LoadProcedure(dd1550AHnd,'DIGD1550A_VoltsToADC') ;
        @DIGD1550A_ADCtoVolts := DIGD1550A_LoadProcedure(dd1550AHnd,'DIGD1550A_ADCtoVolts') ;

        @DIGD1550A_GetTrigThreshold  := DIGD1550A_LoadProcedure( dd1550AHnd, 'DIGD1550A_GetTrigThreshold') ;
        @DIGD1550A_SetTrigThreshold  := DIGD1550A_LoadProcedure( dd1550AHnd, 'DIGD1550A_SetTrigThreshold') ;
        @DIGD1550A_SetDOValue  := DIGD1550A_LoadProcedure( dd1550AHnd, 'DIGD1550A_SetDOValue') ;
        @DIGD1550A_SetAOValue  := DIGD1550A_LoadProcedure( dd1550AHnd, 'DIGD1550A_SetAOValue') ;
        @DIGD1550A_GetDIValue  := DIGD1550A_LoadProcedure( dd1550AHnd, 'DIGD1550A_GetDIValue') ;
        @DIGD1550A_GetAIValue  := DIGD1550A_LoadProcedure( dd1550AHnd, 'DIGD1550A_GetAIValue') ;
        @DIGD1550A_GetAOPosition  := DIGD1550A_LoadProcedure( dd1550AHnd, 'DIGD1550A_GetAOPosition') ;
        @DIGD1550A_GetAIPosition  := DIGD1550A_LoadProcedure( dd1550AHnd, 'DIGD1550A_GetAIPosition') ;
        @DIGD1550A_IsAcquiring  := DIGD1550A_LoadProcedure( dd1550AHnd, 'DIGD1550A_IsAcquiring') ;
        @DIGD1550A_StopAcquisition  := DIGD1550A_LoadProcedure( dd1550AHnd, 'DIGD1550A_StopAcquisition') ;
        @DIGD1550A_StartAcquisition  := DIGD1550A_LoadProcedure( dd1550AHnd, 'DIGD1550A_StartAcquisition') ;
        @DIGD1550A_GetProtocol  := DIGD1550A_LoadProcedure( dd1550AHnd, 'DIGD1550A_GetProtocol') ;
        @DIGD1550A_SetProtocol  := DIGD1550A_LoadProcedure( dd1550AHnd, 'DIGD1550A_SetProtocol') ;
//        @DIGD1550A_GetBufferGranularity  := DIGD1550A_LoadProcedure( dd1550AHnd, 'DIGD1550A_GetBufferGranularity') ;
        @DIGD1550A_SetSerialNumber  := DIGD1550A_LoadProcedure( dd1550AHnd, 'DIGD1550A_SetSerialNumber') ;
        @DIGD1550A_GetDeviceInfo  := DIGD1550A_LoadProcedure( dd1550AHnd, 'DIGD1550A_GetDeviceInfo') ;
        @DIGD1550A_Reset  := DIGD1550A_LoadProcedure( dd1550AHnd, 'DIGD1550A_RESET') ;
        @DIGD1550A_ReadTelegraphs  := DIGD1550A_LoadProcedure( dd1550AHnd, 'DIGD1550A_ReadTelegraphs') ;
        @DIGD1550A_GetTimeAtStartOfAcquisition  := DIGD1550A_LoadProcedure( dd1550AHnd, 'DIGD1550A_GetTimeAtStartOfAcquisition') ;
        @DIGD1550A_GetCalibrationParams  := DIGD1550A_LoadProcedure( dd1550AHnd, 'DIGD1550A_GetCalibrationParams') ;
        @DIGD1550A_SetCalibrationParams  := DIGD1550A_LoadProcedure( dd1550AHnd, 'DIGD1550A_SetCalibrationParams') ;
        @DIGD1550A_SetPowerOnData  := DIGD1550A_LoadProcedure( dd1550AHnd, 'DIGD1550A_SetPowerOnData') ;
        @DIGD1550A_GetPowerOnData  := DIGD1550A_LoadProcedure( dd1550AHnd, 'DIGD1550A_GetPowerOnData') ;
        @DIGD1550A_GetEepromParams  := DIGD1550A_LoadProcedure( dd1550AHnd, 'DIGD1550A_GetEepromParams') ;
        @DIGD1550A_SetEepromParams  := DIGD1550A_LoadProcedure( dd1550AHnd, 'DIGD1550A_SetEepromParams') ;
        @DIGD1550A_GetLastErrorText  := DIGD1550A_LoadProcedure( dd1550AHnd, 'DIGD1550A_GetLastErrorText') ;
        @DIGD1550A_GetLastError  := DIGD1550A_LoadProcedure( dd1550AHnd, 'DIGD1550A_GetLastError') ;
        LibraryLoaded := True ;
        end
     else LibraryLoaded := False ;

     end ;

function  DIGD1550A_CopyAndLoadLibrary(
          DLLName : string ;
          SourcePath : string ;
          DestPath : string ) : Thandle ;
// ---------------------------------------------------------
// Copy DLL library from source to destination path and load
// ---------------------------------------------------------
begin
     CopyFile( PChar(SourcePath+DLLName), PChar(DestPath+DLLName), false ) ;
     Result := LoadLibrary(PChar(DestPath+DLLName)) ;
     if Result = 0 then ShowMessage('Unable to load ' + DestPath+DLLName );
     end;


function  DIGD1550A_LoadProcedure(
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
        ShowMessage(format('DIGD1550A.DLL- %s not found',[Name])) ;
        end ;
     Result := P ;
     end ;


function  DIGD1550A_GetMaxDACVolts : single ;
{ -----------------------------------------------------------------
  Return the maximum positive value of the D/A output voltage range
  -----------------------------------------------------------------}

begin
     Result := FDACVoltageRangeMax ;
     end ;


procedure DIGD1550A_InitialiseBoard ;
{ -------------------------------------------
  Initialise Digidata 1200 interface hardware
  -------------------------------------------}
var
   ch : Integer ;
begin

     DeviceInitialised := False ;

     if not LibraryLoaded then DIGD1550A_LoadLibrary ;
     if not LibraryLoaded then Exit ;

     // Determine number of available DIGD1550As
     NumDevices := DIGD1550A_CountDevices ;

     if NumDevices <= 0 then begin
        ShowMessage('No Digidata 1550A devices available!') ;
        exit ;
        end ;

     // Get information from DIGD1550A devices
     DIGD1550A_FindDevices(@DeviceInfo, High(DeviceInfo)+1, Err ) ;
     if Err <> 0 then begin
        DIGD1550A_CheckError(Err,True) ;
        Exit ;
        end ;

     DIGD1550A_OpenDevice( DeviceInfo[0].SerialNumber, Err ) ;
     if Err <> 0 then begin
        DIGD1550A_CheckError(Err,False) ;
        Exit ;
        end ;

     // Get calibration parameters
     DIGD1550A_GetCalibrationParams( Calibration ) ;
     for ch := 0 to High(Calibration.afDACGains) do
         if Calibration.afDACGains[ch] = 0.0 then Calibration.afDACGains[ch] := 1.0 ;
     DACActive := False ;

    // Set output buffers to default values
    NumOutChannels := DIGD1550A_MAX_AO_CHANNELS + 1 ;
    for ch := 0 to DIGD1550A_MAX_AO_CHANNELS-1 do DACDefaultValue[ch] := -Calibration.anDACOffsets[ch];
    DIGDefaultValue := 0 ;

    AIBuf := Nil ;
    AOBuf := Nil ;
    OutValues := Nil ;

    DeviceInitialised := True ;

     end ;


procedure DIGD1550A_FillOutputBufferWithDefaultValues ;
// --------------------------------------
// Fill output buffer with default values
// --------------------------------------
var
    i,ch,DIGChannel : Integer ;
begin

    // Circular transfer buffer
    ch := 0 ;
    DIGChannel := NumOutChannels - 1 ;
    for i := 0 to AOBufNumSamples-1 do begin
        if ch < DIGChannel then begin
           AOBuf^[i] := DACDefaultValue[ch] ;
           inc(ch) ;
           end
        else begin
           AOBuf^[i] := DIGDefaultValue ;
           ch := 0 ;
           end ;
        end ;

    end ;

procedure DIGD1550A_ConfigureHardware(
          EmptyFlagIn : Integer ) ;
{ --------------------------------------------------------------------------

  -------------------------------------------------------------------------- }
begin
     //EmptyFlag := EmptyFlagIn ;
     end ;


function DIGD1550A_ADCToMemory(
          HostADCBuf : Pointer  ;   { A/D sample buffer (OUT) }
          NumADCChannels : Integer ;                   { Number of A/D channels (IN) }
          NumADCSamples : Integer ;                    { Number of A/D samples ( per channel) (IN) }
          var dt : Double ;                       { Sampling interval (s) (IN) }
          ADCVoltageRange : Single ;              { A/D input voltage range (V) (IN) }
          TriggerMode : Integer ;                 { A/D sweep trigger mode (IN) }
          CircularBuffer : Boolean ;               { Repeated sampling into buffer (IN) }
          ADCChannelInputMap : Array of Integer
          ) : Boolean ;                           { Returns TRUE indicating A/D started }
{ -----------------------------
  Start A/D converter sampling
  -----------------------------}
const
    MaxSamplesPerSubBuf = 1000;
var
   i : Word ;
   ch,iPrev,iNext : Integer ;
   NumSamplesPerSubBuf : Integer ;
   iPointer : Cardinal ;
begin
     Result := False ;
     if not DeviceInitialised then DIGD1550A_InitialiseBoard ;
     if not DeviceInitialised then Exit ;

     // Initialise A/D buffer pointers used by DIGD1550A_GetADCSamples
     FOutPointer := 0 ;
     FNumSamplesRequired := NumADCChannels*NumADCSamples ;

     // Clear protocol fClags
     Protocol.uFlags := 0 ;

     // Sampling interval
     Protocol.dSequencePeriodUS := dt*1E6 ;

     // Set analog input channels
     Protocol.uAIChannels := NumADCChannels ;
     for ch := 0 to Protocol.uAIChannels-1 do Protocol.anAIChannels[ch] := ADCChannelInputMap[ch] ;
     // Note. Bug in channel mapping. 1-1 mapping works OK but any mapping where the numerical
     // order of channels is reversed results in channels being mixed up.

     // Allocate A/D input buffers
     // Make sub-buffer contain multiple of both input and output channels
     NumSamplesPerSubBuf := MaxSamplesPerSubBuf*NumADCChannels*NumOutChannels ;
     AIBufNumSamples := ((DeviceInfo[0].InputBufferSamples*16) div NumSamplesPerSubBuf)*NumSamplesPerSubBuf ;
     if AIBuf <> Nil then FreeMem(AIBuf) ;
     GetMem( AIBuf, AIBufNumSamples*2 ) ;
     Protocol.pAIBuffers := @AIBufs ;

     iPointer := Cardinal(AIBuf) ;
     Protocol.uAIBuffers := Min( AIBufNumSamples div NumSamplesPerSubBuf, High(AIBufs)+1 );
     for i := 0 to Protocol.uAIBuffers-1 do begin
        AIBufs[i].pnData := Pointer(iPointer) ;
        AIBufs[i].uNumSamples := NumSamplesPerSubBuf ;
        AIBufs[i].uFlags := 0 ;
        AIBufs[i].psDataFlags := Nil ;
        iPointer := iPointer + NumSamplesPerSubBuf*2  ;
        end ;

     // Previous/Next buffer pointers
     for i := 0 to Protocol.uAIBuffers-1 do begin
         iPrev := i-1 ;
         if iPrev < 0 then iPrev := Protocol.uAIBuffers-1 ;
         AIBufs[i].pPrevBuffer := Pointer( Cardinal(@AIBufs) + (iPrev*SizeOf(TDATABuffer)) ) ;
         iNext := i+1 ;
         if iNext >= Protocol.uAIBuffers then iNext := 0 ;
         AIBufs[i].pNextBuffer := Pointer( Cardinal(@AIBufs) + (iNext*SizeOf(TDATABuffer)) ) ;
         end ;

     // Allocate AO buffer

     AOBufNumSamples := ((DeviceInfo[0].OutputBufferSamples*16) div NumSamplesPerSubBuf)*NumSamplesPerSubBuf ;
     if AOBuf <> Nil then FreeMem(AOBuf) ;
     GetMem( AOBuf, AOBufNumSamples*2 ) ;
     Protocol.pAOBuffers := @AOBufs ;

     iPointer := Cardinal(AOBuf) ;
     Protocol.uAOBuffers := Min( AOBufNumSamples div NumSamplesPerSubBuf, High(AOBufs)+1 );
     for i := 0 to Protocol.uAOBuffers-1 do begin
        AOBufs[i].pnData := Pointer(iPointer) ;
        AOBufs[i].uNumSamples := NumSamplesPerSubBuf ;
        AOBufs[i].uFlags := 0 ;
        AOBufs[i].psDataFlags := Nil ;
        iPointer := iPointer + NumSamplesPerSubBuf*2  ;
        end ;

     // Previous/Next buffer pointers
     for i := 0 to Protocol.uAOBuffers-1 do begin
         iPrev := i-1 ;
         if iPrev < 0 then iPrev := Protocol.uAOBuffers-1 ;
         AOBufs[i].pPrevBuffer := Pointer( Cardinal(@AOBufs) + (iPrev*SizeOf(TDATABuffer)) ) ;
         iNext := i+1 ;
         if iNext >= Protocol.uAOBuffers then iNext := 0 ;
         AOBufs[i].pNextBuffer := Pointer( Cardinal(@AOBufs) + (iNext*SizeOf(TDATABuffer)) ) ;
         end ;

     // Enable all analog O/P channels and digital channel
     Protocol.uAOChannels := DIGD1550A_MAX_AO_CHANNELS ;
     for ch := 0 to Protocol.uAOChannels-1 do Protocol.anAOChannels[ch] := ch ;
     Protocol.bDOEnable := True ;

     // No digital input
     Protocol.bDIEnable := False ;
     Protocol.uChunksPerSecond := 20 ;
     Protocol.uTerminalCount := NumADCSamples ;

     Protocol.MinSequencePeriodUS := 2.0 ;
     Protocol.MaxSequencePeriodUS := 1000.0;

//   Unable to get ANC to work
//     Protocol.ANCEnable[0] :=  1  ;
//     Protocol.Harmonics[0] := 1 ;
//     Protocol.Harmonics[1] := 0 ;
//     Protocol.NoOfAvgCycle := 10 ;

     AIPointer := 0 ;
     FOutPointer := 0 ;

     FCircularBuffer := CircularBuffer ;

     // Start acquisition if waveform generation not required
     if TriggerMode <> tmWaveGen then begin

        // Enable external start of sweep
        if TriggerMode = tmExtTrigger then Protocol.uFlags := DIGD1550A_FLAG_EXT_TRIGGER
                                      else Protocol.uFlags := 0 ;
        Protocol.TriggerTimeout := 0 ;
        Protocol.uFlags := Protocol.uFlags + 4096 + 8192 + 8192*2 ;
        // Clear any existing waveform from output buffer
        DIGD1550A_FillOutputBufferWithDefaultValues ;

        // Send protocol to device
        AOPointer := 0 ;
        DIGD1550A_CheckError(Err,DIGD1550A_SetProtocol(Protocol)) ;
        // ------------------------------------------------------------------------
        // Acquisition is stopped here (although it is not running)
        // to force DD1550A to recognise DIGD1550A_FLAG_EXT_TRIGGER flag when selected
        // otherwise A/D conversion after change to external triggered mode
        // starts immediately. Not clear why this should be necessary 8.7.15
        DIGD1550A_StopAcquisition ;
        // -----------------------------------------------------------------------
        // Start A/D conversion
        DIGD1550A_CheckError(Err,DIGD1550A_StartAcquisition) ;

        DIGD1550A_GetAOPosition(  AOPosition ) ;
        ADCActive := True ;
        DACActive := False ;
        AIPosition := 0 ;
        end ;
     GetADCSamplesInUse := False ;
     end ;


function DIGD1550A_StopADC : Boolean ;  { Returns False indicating A/D stopped }
{ -------------------------------
  Reset A/D conversion sub-system
  -------------------------------}
begin
     Result := False ;
     if not DeviceInitialised then DIGD1550A_InitialiseBoard ;
     if not DeviceInitialised then Exit ;

     // Stop A/D input (and D/A output) if in progress
     if DIGD1550A_IsAcquiring then begin
        DIGD1550A_StopAcquisition ;
        end ;

     // Fill D/A & digital O/P buffers with default values
     DIGD1550A_FillOutputBufferWithDefaultValues ;

     ADCActive := False ;
     DACActive := False ;  // Since A/D and D/A are synchronous D/A stops too
     Result := ADCActive ;

     end ;


procedure DIGD1550A_GetADCSamples(
          var OutBuf : Array of SmallInt ;  { Buffer to receive A/D samples }
          var OutBufPointer : Integer       { Latest sample pointer [OUT]}
          ) ;
var
    i,MaxOutPointer,NewPoints,NewSamples : Integer ;
    NewAOPosition,NewAIPosition : Int64 ;
begin

     if not ADCActive then exit ;
     if GetADCSamplesInUse then Exit ;
     if not DIGD1550A_IsAcquiring then Exit ;
     GetADCSamplesInUse := True ;

     // Transfer new A/D samples to host buffer
     DIGD1550A_GetAIPosition(  NewAIPosition ) ;
     NewSamples := (NewAIPosition - AIPosition)*Protocol.uAIChannels ;

     AIPosition := NewAIPosition ;
     if FCircularBuffer then begin
        // Circular buffer mode
        for i := 1 to NewSamples do begin
            OutBuf[FOutPointer] := AIBuf[AIPointer]  ;
            Inc(AIPointer) ;
            if AIPointer = AIBufNumSamples then AIPointer := 0 ;
            Inc(FOutPointer) ;
            if FOutPointer >= FNumSamplesRequired then FOutPointer := 0 ;
            end ;
        end
     else begin
        // Single sweep mode
        for i := 1 to NewSamples do if
            (FOutPointer < FNumSamplesRequired) then begin
            OutBuf[FOutPointer] := AIBuf[AIPointer]  ;
            Inc(AIPointer) ;
            if AIPointer = AIBufNumSamples then AIPointer := 0 ;
            Inc(FOutPointer) ;
            end ;
        OutBufPointer := FOutPointer ;
        end ;

     // Update D/A + Dig output buffer
     DIGD1550A_GetAOPosition(  NewAOPosition ) ;
     NewPoints := Integer(NewAOPosition - AOPosition) ;
     AOPosition := NewAOPosition ;

     if DACActive then begin
       // Copy into transfer buffer
       MaxOutPointer := (NumOutPoints*NumOutChannels) - 1 ;
       for i := 0 to NewPoints*NumOutChannels-1 do begin
          AOBuf^[AOPointer] := OutValues^[OutPointer] ;
          Inc(AOPointer) ;
          if AOPointer >= AOBufNumSamples then AOPointer := 0 ;
          Inc(OutPointer) ;
          if OutPointer > MaxOutPointer then begin
             if AORepeatWaveform then OutPointer := 0
                                 else OutPointer := OutPointer - NumOutChannels ;
             end ;
          end ;
        end ;

     GetADCSamplesInUse := False ;

     end ;


procedure DIGD1550A_CheckSamplingInterval(
          var SamplingInterval : Double ;
          ADCNumChannels : Integer ) ;
{ ---------------------------------------------------
  Convert sampling period from <SamplingInterval> (in s) into
  clocks ticks, Returns no. of ticks in "Ticks"
  ---------------------------------------------------}
var
  MinInterval : Double ;
  begin

  // Minimum sampling interval increased when more than 4 channels acquired
  // (Digidata 1550A appears unable to sustain maximum sampling rate when more than 4 channels in use)

  MinInterval := ((ADCNumChannels div 4) + 1)*DeviceInfo[0].MinSequencePeriodUS*1E-6 ;

  SamplingInterval := Max( SamplingInterval, MinInterval ) ;
  //SamplingInterval := Min( SamplingInterval, DeviceInfo[0].MaxSequencePeriodUS*1E-6 ) ;

  SamplingInterval := Max(Round(SamplingInterval/(DeviceInfo[0].SequenceQuantaUS*1E-6)),1) ;
  SamplingInterval := SamplingInterval*DeviceInfo[0].SequenceQuantaUS*1E-6 ;
	end ;


function  DIGD1550A_MemoryToDACAndDigitalOut(
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
var
   i,ch,iTo,iFrom,DigCh,MaxOutPointer : Integer ;
   begin

    Result := False ;
    if not DeviceInitialised then DIGD1550A_InitialiseBoard ;
    if not DeviceInitialised then Exit ;

    // Stop any acquisition in progress
    if DIGD1550A_IsAcquiring then DIGD1550A_StopAcquisition ;

    // Allocate internal output waveform buffer
    if OutValues <> Nil then FreeMem(OutValues) ;
    NumOutPoints := NumDACPoints ;
    GetMem( OutValues, NumOutPoints*NumOutChannels*2 ) ;

    // Copy D/A & digital values into internal buffer
    DigCh := NumOutChannels - 1 ;
    for i := 0 to NumDACPoints-1 do begin
        iTo := i*NumOutChannels ;
        iFrom := i*NumDACChannels ;
        for ch :=  0 to DIGD1550A_MAX_AO_CHANNELS-1 do begin
            if ch < NumDACChannels then begin
               OutValues[iTo+ch] := Round( DACValues[iFrom+ch]/Calibration.afDACGains[ch])
                                     - Calibration.anDACOffsets[ch];
               end
            else OutValues[iTo+ch] := DACDefaultValue[ch] ;
            end ;
        if DigitalInUse then OutValues^[iTo+DigCh] := DigValues[i]
                        else  OutValues^[iTo+DigCh] := DIGDefaultValue ;
        end ;

    // Download protocol to DIGD1550A and start/restart acquisition

    // If ExternalTrigger flag is set make D/A output wait for
    // TTL pulse on Trigger In line
    // otherwise set acquisition sweep triggering to start immediately
    if ExternalTrigger then Protocol.uFlags := DIGD1550A_FLAG_EXT_TRIGGER
                       else Protocol.uFlags := 0 ;

    // Fill buffer with data from new waveform
    OutPointer := 0 ;
    MaxOutPointer := (NumOutPoints*NumOutChannels) - 1 ;
    for i := 0 to AOBufNumSamples-1 do begin
        AOBuf^[i] := OutValues^[OutPointer] ;
        Inc(OutPointer) ;
        if OutPointer > MaxOutPointer then begin
           if RepeatWaveform then OutPointer := 0
                             else OutPointer := OutPointer - NumOutChannels ;
           end ;
        end ;

    // Load protocol
    Protocol.TriggerTimeout := 0 ;
    DIGD1550A_SetProtocol( Protocol ) ;
    // ------------------------------------------------------------------------
    // Acquisition is stopped here (although it is not running)
    // to force DD1550A to recognise DIGD1550A_FLAG_EXT_TRIGGER flag when selected
    // otherwise first A/D conversion after change to external triggered mode
    // starts immediately. Not clear why this should be necessary 8.7.15
    DIGD1550A_StopAcquisition ;
    // -----------------------------------------------------------------------

    // Start
    DIGD1550A_StartAcquisition ;

    ADCActive := True ;

    // Reload transfer buffer (replacing data preloaded into 1550A by DIGD1550A_StartAcquisition)
    DIGD1550A_GetAOPosition(  AOPosition ) ;
    AIPosition := 0 ;
    AIPointer := 0 ;
    AOPointer := 0 ;
    for i := 1 to AOPosition*NumOutChannels do begin
        AOBuf^[AOPointer] := OutValues^[OutPointer] ;
        Inc(OutPointer) ;
        Inc(AOPointer) ;
        if OutPointer > MaxOutPointer then begin
           if RepeatWaveform then OutPointer := 0
                             else OutPointer := OutPointer - NumOutChannels ;
           end ;
        end ;

    AORepeatWaveform := RepeatWaveform ;
    DACActive := True ;
    Result := DACActive ;

    end ;


function DIGD1550A_GetDACUpdateInterval : double ;
{ -----------------------
  Get D/A update interval
  -----------------------}
begin

     // DAC update interval is same as A/D sampling interval
     Result := Protocol.dSequencePeriodUS*1E-6 ;

     end ;


function DIGD1550A_StopDAC : Boolean ;
//---------------------------------
//  Stop D/A & digital waveforms
//---------------------------------
begin
     Result := False ;
     if not DeviceInitialised then DIGD1550A_InitialiseBoard ;
     if not DeviceInitialised then Exit ;

     // Set DAC and digital outputs to default values
     DIGD1550A_FillOutputBufferWithDefaultValues ;

     if DIGD1550A_IsAcquiring then begin
        DIGD1550A_StopAcquisition ;
        Protocol.uFlags := 0 ;  // Ensure no wait fot ext. trigger
        DIGD1550A_SetProtocol( Protocol ) ;
        DIGD1550A_StartAcquisition ;
        AIPosition := 0 ;
        AOPosition := 0 ;
        AIPointer := 0 ;
        end ;

     DACActive := False ;
     Result := DACActive ;

     end ;


procedure DIGD1550A_WriteDACsAndDigitalPort(
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
   SmallDACValue : SmallInt ;
begin

     if not DeviceInitialised then DIGD1550A_InitialiseBoard ;
     if not DeviceInitialised then Exit ;

     // Scale from Volts to binary integer units
     DACScale := MaxDACValue/FDACVoltageRangeMax ;

     { Update D/A channels }
     for ch := 0 to Min(nChannels,DIGD1550A_MAX_AO_CHANNELS)-1 do begin
         // Correct for errors in hardware DAC scaling factor
         DACValue := Round(DACVolts[ch]*DACScale/Calibration.afDACGains[ch]) ;
         // Correct for DAC zero offset
         DACValue := DACValue - Calibration.anDACOffsets[ch];
         // Keep within legitimate limits
         if DACValue > MaxDACValue then DACValue := MaxDACValue ;
         if DACValue < MinDACValue then DACValue := MinDACValue ;
         // Output D/A value
         SmallDACValue := DACValue ;
         if not ADCActive then DIGD1550A_SetAOValue(  ch, SmallDACValue ) ;
         DACDefaultValue[ch] := SmallDACValue ;

         end ;

     // Set digital outputs
     if not ADCActive then DIGD1550A_SetDOValue(  DigValue ) ;
     DIGDefaultValue := DigValue ;

     // Fill D/A & digital O/P buffers with default values
     DIGD1550A_FillOutputBufferWithDefaultValues ;

     // Stop/restart acquisition to flush output buffer
     if DIGD1550A_IsAcquiring then begin
        DIGD1550A_StopAcquisition ;
        Protocol.uFlags := 0 ;
        DIGD1550A_SetProtocol( Protocol ) ;
        DIGD1550A_StartAcquisition ;
        AIPosition := 0 ;
        AOPosition := 0 ;
        AIPointer := 0 ;
        end ;

     end ;


function DIGD1550A_ReadADC(
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
     if not DeviceInitialised then DIGD1550A_InitialiseBoard ;
     if not DeviceInitialised then Exit ;

     DIGD1550A_GetAIValue( Channel, Value ) ;
     Result := Value ;

     end ;


procedure DIGD1550A_GetChannelOffsets(
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


procedure DIGD1550A_CloseLaboratoryInterface ;
{ -----------------------------------
  Shut down lab. interface operations
  ----------------------------------- }
begin

     if not DeviceInitialised then Exit ;

     DIGD1550A_CloseDevice ;

     // Free DLL libraries
     if DD1550AHnd > 0 then FreeLibrary(DD1550AHnd) ;
     DD1550AHnd := 0 ;
     if AxDD1550AHnd > 0 then FreeLibrary(AxDD1550AHnd) ;
     AxDD1550AHnd := 0 ;
     if wdapiHnd > 0 then FreeLibrary(wdapiHnd) ;
     wdapiHnd := 0 ;

     if OutValues <> Nil then FreeMem( OutValues ) ;
     OutValues := Nil ;
     if AOBuf <> Nil then FreeMem( AOBuf ) ;
     AOBuf := Nil ;
     if AIBuf <> Nil then FreeMem( AIBuf ) ;
     AIBuf := Nil ;

     DeviceInitialised := False ;
     DACActive := False ;
     ADCActive := False ;

     end ;


procedure DIGD1550A_CheckError(
          Err : Integer ;
          OK : ByteBool ) ;
{ ------------------------------------------------
  Check error code and display message if required
  ------------------------------------------------ }
begin

     if not OK then begin
        DIGD1550A_GetErrorText(  Err, ErrorMsg, High(ErrorMsg)+1 ) ;
        ShowMessage( 'Digidata 1550A: ' + TrimChar(ErrorMsg) ) ;
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


end.
