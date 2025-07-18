unit Ced1401;
{ ===========================================================================
  CED 1401 Interface Library                                                                                                                                     dcmf
  (c) John Dempster, University of Strathclyde, All Rights Reserved 1997-2003
  ===========================================================================                                                                                              etstringf
  V1.0 Started 6/3/97, Working 20/3/97
  V1.1 1/12/97 ... Support for old 1401s without Z8 added using ADCMEMI
  23/8/99 ... 32 bit version for WinWCP V3.0 and later
  4/9/99  ... 16/12 A/D conversion modes added
  24/11/00 ... Now works with SESLABIO component
  19/2/01 ... CED_ReadADC function added
  10/5/01 ... Support for Power-1401 added and tested
  11/12/01 ... Min sampling rate of 1401-plus adjusted to 3 us
  25/11/02 ... Micro-1401 Mk2 supported added
               1401 commands now taken from c:\1401
               use1432.dll now loaded from c:\1401\utils
  4/4/03 ..... Support for 10V 1401s added                                          m
               (using CEDDAC10V.txt CEDADC10V.txt flag files )
  25/8/03 .... Both \1401 and \1401\utils checked for 1401 commands
  18/9/03 .... Error messages now indicates name of 1401 commands which fail to load
  9/2/04 ..... CED_MemoryToDAC can now wait for external trigger
  27/7/04 .... Active High external trigger of ADCToMemory now supported
  20/10/04 ... Internal trigger now used to synchronised A/D and D/A sweeps
  26/10/04 ... External stimulus trigger input is now EVENT 0
  30/11/04 ... Buffer size increased to 131072 (ex. standard 1401)
  08/03/05 ... RepeatWaveform option added to CED_MemoryToDac
  09/03/05 ... Internal events now cleared in CED_ADCToMemory
  04/07/05 ... DAC 2 used to start ADCMEM, MEMDAC, DIGTIM via Events 3, 4, 2
               with Standard 1401 because it doesn't support EVENT,I internal triggering
  19/10/05 ... CED 1401-plus buffer limited to 65536
  06/06/07 ... Power/Micro1401 buffer limited to 131072
  06/03/08 ... Power1401 Mk2 support added
               Bug which caused end of long DAC waveforms to be truncated fixed
               DACBufferLimit now set for each type 1401
               MemorytoDig updated to avoid repeated digital pulses when
               recording sweep is longer than DAC/digital sweep due to
               A/D sampling rate limitations for very large buffer sizes
               Buffer size for Power 1401 Mk2 = 1048576
  11/03/08 ... MemoryToDAC DAC Data now written to 1401 in single To1401 call
  12/09/08 ... 10V ADC & DAC selection in CED_Configure supersedes CEDDAC10V.txt CEDADC10V.txt flag files.
  16/04/11 ... DIGTIM command in Power 1401s now seems to operate in the same way as
               other 1401s, iDigShift now fixed at 0 in MemoryToDigital function
               LibrayLoaded flag now cleared by CED_CloseLaboratoryInterface
               when DLL library freed, preventing access violation when CED
               library loaded again.
  13/07/11 ... Some Power 1401s still seem to need iDigShift = 1. So settings
               CEDPOWER1401DIGTIMCOUNTSHIFT added to 'lab interface.xml' to
               allow user to define iDigShift (0 or 1)
               No. of A/D and D/A channels now returned by CED_GetLabInterfaceInfo
  12/09/11 ... CED Power 1401
               ADCMinSamplingInterval increased from 2E-6 to 3E-6 (same as Mk2)
               ADCBufferLimit increased from 131072 to 4*131072
  11/6/12 .... Circular A/D buffering implemented in GetADCSamples, now allowed
               A/D buffer sizes up 8 Msamples
  15/6/12 .... Both A/D and D/A now have circular buffers and 8 Msamples limits
               Min. A/D sampling interval of CED140-plus & Micro 1401 increased to 5 us.
  26/6/12 .... use1432.dll now loaded from c:\winwcp to ensure a version
               compatible with WinWCP (with stdcalls) is used
  18/9/12 .... Micro 1401 Mk3 now specifically identified.
  27/11/12 ... Micro 1401 now correctly identified again ADC host buffer reduced to 32768*2
  16/04/13 ... CED_CheckSamplingInterval() Sampling interval now ROUNDed to nearest integer
               clock tick rather than TRUNCated to nearest lower value.
  17/04/13 ... ADCMEM and MEMDAC now timed using faster hardware 'H' clock rather than standard 'C' 1 MHz clock
               Time intervals can now be set more precisely. Appropriate clock period set when type of 1401 identified.
               ClockSource argument added to CED_CheckSamplingInterval()
  19/04/13 ... ClockPeriod initialised to 2.5E-7 s (investigating Motoharu Yoshida's div by 0 problem
  07/08/13 ... Modified to compiled under Delphi XE2/3 )
  11/09/13 ... Correct 4 MHz clock period (rather than 10 MHz)
               now set for A/D and D/A timing for Power and Micro 1401 Mk2 and MK2
               Multiple 64 Kb update buffers now used for D/A transfers to 1401
               to avoid long delays when updating short pulses with Power 1401 Mk1
               Tested with Power 1401, Micro 1401 Mk2 at Plymouth
               A/D data now transferred to host in multiple 64Kbyte blocks
               to avoid data being scrambled in long records at high sampling rates
               TEMPORARY FIX CED Power 1401 Mk3 No. of D/A channels limited to 2 since channels
               get scrambled (AO0 appearing on AO1 AO3 on AO0) when 4 channels used.
   06.11.13    A/D input channels can now be mapped to different physical inputs
 28/11/13 ...  DACPointsInBlock now adjusted to ensure at least 3 buffers in 1401 DAC buffer
               to fix problems with CED 1401-plus. CED 1401-plus buffer sizes changed DAC buffer increased
 18.11.21 ...  Support for Micro 1401 Mk4 added. DIGTIM.ars ADCMEM.ars command bugs fixed by Greg Smith from CED
 22.11.21 ...  U14Ld now automatically looks for commands in folder c:\1401
               CLIST used to check for presence of Micro1401 MK4 ADCMEM 80.0 which returns Word pointer
               rather than Byte pointer in response to ADCMEM,P. Get_ADCSamples() adapts to this.
 24.11.21 ...  RepeatedWaveform argument added to CED_MemoryToDig() Digital pulse pattern can now repeat indefinetely
               Digital waveforms now work in WinEDR as well as WinWCP
 08.12.21 ...  MinDacInterval of Power 1401s reduced from 1E-4s to 1E-5s to allow higher frequency sine wave stimuli
               to be produced/
 25.08.21 ...  DIGTIMSlicesBufLimit increased to 5000 (previously 500) for Micro & Power 1401's
}
interface
uses WinTypes,Dialogs, SysUtils, WinProcs, Classes,use1401, math, strutils, System.UITypes ;
const
     MaxADCChannel = 15 ;
     DIGTIMSlicesBufLimit = 5000 ;
     MaxPointsinBlock = 32000 ;
     MaxBytesinBlock = MaxPointsinBlock*2 ;
     Event0 = 1 ;
     Event1 = 2 ;
     Event2 = 4 ; // Digital trigger
     Event3 = 8 ; // D/A trigger
     Event4 = 16 ;// A/D trigger

  procedure CED_LoadLibrary  ;
  procedure CED_InitialiseBoard ;
  procedure CED_ConfigureHardware( Resolution : Integer ;
                                   EmptyFlagIn : Integer ;
                                   DACVoltageRange : Single ) ;
  procedure SendCommand(
            const CommandString : string
            ) ;
  function CED_ADCToMemory(
            var ADCBuf : Array of SmallInt ;
            nChannels : Integer ;
            nSamples : Integer ;
            var dt : Double ;
            ADCVoltageRange : Single ;
            TriggerMode : Integer ;
            ADCExternalTriggerActiveHigh : Boolean ;
            CircularBuffer : Boolean ;
            ADCChannelInputMap : Array of Integer
            ) : Boolean ;
procedure CED_GetADCSamples(
          var ADCBuf : Array of SmallInt  ;
          var OutPointer : Integer
          ) ;
  function CED_StopADC : Boolean ;
  function CED_MemoryToDAC(
            var DACBufIn : Array of SmallInt ;
            nChannels : Integer ;
            nPoints : Integer ;
            dt : Double ;
            TriggerMode : Integer ;
            ExternalTrigger : Boolean ;
            DACRepeatedWaveformIn : Boolean
            ) : Boolean ;
  procedure CED_SetDAC2( Volts : Single ) ;
  function CED_StopDAC : Boolean ;
  function CED_GetLabInterfaceInfo(
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
          var DACBufferLimit : Integer ;      { Max. no. samples in A/D buffer }
          var DACMaxVolts : Single ; { Positive limit of bipolar D/A voltage range }
          var DACMinUpdateInterval : Double {Min. D/A update interval }
          ) : Boolean ;
procedure CED_CheckSamplingInterval(
          var dt : Double ;            // Sampling Interval (returns valid value)
          var PreScale,Ticks : Word ;  // Returns clock prescale and ticks
          ClockSource : string         // H=hardware clock C=standard 1MHz
          ) ;
  procedure CED_CheckError(
            Err : Integer
            ) ;
  procedure CED_WriteToDigitalOutPutPort(
            Pattern : Integer
            ) ;
  function CED_ReadDigitalInPutPort : Integer ;
  procedure CED_ArmStimulusTriggerInput ;
  function CED_StimulusTriggerInputState : Boolean ;
  procedure CED_MemoryToDigitalPort(
            var DigBuf : Array of SmallInt ;
            nValues : Integer ;
            dt : Double ;
            StartAt : Integer ;
            CEDPower1401DIGTIMCountShift : Integer ;
            RepeatedWaveform : Boolean
            ) ;
  procedure CED_StopDIG ;
  function CED_ReadADC( Chan : Integer ) : SmallInt ;
  procedure CED_WriteDACs(
            const DACVolts : array of single ; NumDACS : Integer
            ) ;
  procedure CED_GetChannelOffsets(
            var Offsets : Array of Integer ; NumChannels :
            Integer
            ) ;
  procedure CED_ReportFailure(
            const ProcName : string
            ) ;
  function  CED_IsLabInterfaceAvailable : boolean ;
  procedure CED_CloseLaboratoryInterface ;
  procedure CED_GetError ;
  function CED_GetType : Integer ;
  procedure CED_WriteToDACBuffer ;
  function ExtractInt ( CBuf : string ) : longint ;
  procedure CED_TestDIGTIM ;
implementation
uses SESLabIO ;
type
    TADCBuf = Array[0..MaxADCSamples-1] of SmallInt ;
    PADCBuf = ^TADCBuf ;
    TU14TypeOf1401 = FUNCTION (hand:SmallInt):SmallInt; stdcall;
    TU14DriverVersion = FUNCTION : LongInt; stdcall;
    TU14DriverName = FUNCTION( cBuf : PANSIChar; BufSize: Word ) : SmallInt ; stdcall;
    TU14Open1401 = FUNCTION (n1401:SmallInt):SmallInt ;stdcall;
    TU14Ld = FUNCTION (hand:SmallInt;vl:PANSIChar;str:PANSIChar):DWORD;stdcall;
    TU14LdCmd = FUNCTION (hand:SmallInt;command:PANSIChar):DWORD;stdcall;
    TU14Close1401 = FUNCTION (hand:SmallInt):SmallInt;stdcall;
    TU14LongsFrom1401 = FUNCTION ( hand:SmallInt;
                                   palBuff:TpNums;
                                   sMaxLongs:SmallInt):
                                   SmallInt;stdcall;
    TU14ToHost = FUNCTION (hand:SmallInt;lpAddrHost:PANSIChar;dwSize:DWORD;
                    lAddr1401:LongInt;eSz:SmallInt):SmallInt;stdcall;
    TU14To1401 = FUNCTION (hand:SmallInt;lpAddrHost:Pointer;dwSize:DWORD;
                    lAddr1401:LongInt;eSz:SmallInt):SmallInt;stdcall;
    TU14sendstring = FUNCTION (hand:SmallInt;PCharing:PANSIChar):SmallInt; stdcall;
    TU14KillIO1401 = FUNCTION(hand:SmallInt):SmallInt; stdcall;
    TU14GetUserMemorySize = function(hand:SmallInt; var MemoryAvailable : DWORD ) : SmallInt; stdcall;
    TU14GetString = function(hand:SmallInt; Reply : pANSIChar ; Size :WORD  ) : SmallInt; stdcall;

var
   { Variables for dynamic calls to USE1401.DLL }
   U14TypeOf1401 : TU14TypeOf1401 ;
   U14DriverVersion : TU14DriverVersion ;
   U14DriverName : TU14DriverName ;
   U14Open1401 :TU14Open1401 ;
   U14Ld :TU14Ld ;
   U14LdCmd :TU14LdCmd ;
   U14Close1401 :TU14Close1401 ;
   U14LongsFrom1401 :TU14LongsFrom1401 ;
   U14ToHost : TU14ToHost ;
   U14To1401 : TU14To1401 ;
   U14sendstring : TU14sendstring ;
   U14KillIO1401 : TU14KillIO1401 ;
   U14GetUserMemorySize : TU14GetUserMemorySize ;
   U14GetString : TU14GetString ;
   LibraryHnd : THandle ; { DLL library handle }
   LibraryLoaded : boolean ;      { True if CED 1401 procedures loaded }
   Device : SmallInt ;
   DeviceInitialised : boolean ; { True if hardware has been initialised }
   FADCVoltageRangeMax : single ;  { Max. positive A/D input voltage range}
   FDACVoltageRangeMax : single ;
   DACScale : Integer ;           { D/A value scaling factor (16/12 conversion) }
   Use16BitResolution : Boolean ; { 16/12 bit resolution flag }
   MaxNativeValue : Integer ;
   FADCMinSamplingInterval : single ;
   FADCMaxSamplingInterval : single ;
   ADC1401BufferSize : Integer ;
   ADC1401BufferNumBytes : Integer ;
   //FDACBufferLimit : Integer ;
   CEDVRange : Single ;
   ClockPeriod : Double ; // Clock period used for timing A/D and D/A
   StartOf1401ADCBuffer : DWORD ;
   EndOf1401ADCBuffer : DWORD ;
   StartOf1401Digbuffer : DWORD ;
   EndOf1401Digbuffer : DWORD ;
   StartOf1401DACBuffer : DWORD ;
   EndOf1401DACBuffer : DWORD ;
   ADC1401Pointer : DWORD ;
   CircularBufferMode : boolean ;
   MemoryAvailable : DWORD ;
   ADCActive : Boolean ;
   DACActive : Boolean ;
   TypeOf1401 : Integer ;
   ADCCommand : ANSIstring ;
   ADCMEMVersion : string ;     // ADCMEM Command version (used only by Micro 1401 Mk4)
   IOBuf : PADCBuf ;
   DACBuf : PADCBuf ;
   EndofADCBuf : Integer ;
   ADCBufPointer : Integer ;
   //EndofDACBuf : Integer ;
   DACNumChannels : Integer ;
   DACBufPointer : Integer ;
   DACBufNumPoints : Integer ;
   DAC1401BufferSize : Integer ;
   DACNumPointsIn1401Buf : Integer ;
   DACNumPointsInBlock : Integer ;
   DACNumBytesInBlock : Integer ;
   DACNumBlocksIn1401Buf : Integer ;
   DACNextBlockToWrite : Integer ;
   DAC1401BlockDone : Integer ;
   DACStartOf1401BufLo : DWORD ;
   DACRepeatedWaveform : Boolean ;
   EmptyFlag : Integer ;
   DIGTIMStartEvent : Integer ;
   MaxDIGTIMSlices : Integer ;
procedure CED_LoadLibrary  ;
{ ----------------------------------
  Load USE1401.DLL library into memory
  ----------------------------------}
var
     Path : Array[0..255] of char ;
     LibraryPath : String ;
begin
     { Load library }
     GetSystemDirectory( Path, High(Path) ) ;
     // Get DLL from program folder (firat choice)
     LibraryPath := ExtractFilePath(ParamStr(0)) + 'USE1432.DLL' ;
     if not FileExists(LibraryPath) then begin
        // Get DLL from program folder <sysdir>\1401\utils\
        // if not in program folder
        LibraryPath := ExtractFileDrive(String(Path))  + '\1401\utils\USE1432.DLL' ;
        if not FileExists( LibraryPath ) then begin
           ShowMessage( 'USE1432.DLL library not found in ' + LibraryPath ) ;
           LibraryLoaded := False ;
           Exit ;
           end ;
        end ;
     // Load library
     LibraryHnd := LoadLibrary( PChar(LibraryPath) );
     { Get addresses of procedures in USE1432.DLL }
     if LibraryHnd <> 0 then begin
        @U14TypeOf1401 := GetProcAddress(LibraryHnd,'U14TypeOf1401') ;
        if @U14TypeOf1401 = Nil then CED_ReportFailure('U14TypeOf1401') ;
        @U14DriverVersion := GetProcAddress(LibraryHnd,'U14DriverVersion') ;
        if @U14DriverVersion = Nil then CED_ReportFailure('U14DriverVersion') ;
        @U14DriverName := GetProcAddress(LibraryHnd,'U14DriverName') ;
        if @U14DriverName = Nil then CED_ReportFailure('U14DriverName') ;
        @U14Open1401 := GetProcAddress(LibraryHnd,'U14Open1401') ;
        @U14Open1401 := GetProcAddress(LibraryHnd,'U14Open1401') ;
        if @U14Open1401 = Nil then CED_ReportFailure('U14Open1401') ;
        @U14Ld := GetProcAddress(LibraryHnd,'U14Ld') ;
        if @U14Ld = Nil then CED_ReportFailure('U14Ld') ;
        @U14Close1401 := GetProcAddress(LibraryHnd,'U14Close1401') ;
        @U14LdCmd := GetProcAddress(LibraryHnd,'U14LdCmd') ;
        if @U14LdCmd = Nil then CED_ReportFailure('U14LdCmd') ;
        if @U14Close1401 = Nil then CED_ReportFailure('U14Close1401') ;
        @U14LongsFrom1401 := GetProcAddress(LibraryHnd,'U14LongsFrom1401') ;
        if @U14LongsFrom1401 = Nil then CED_ReportFailure('U14LongsFrom1401') ;
        @U14ToHost := GetProcAddress(LibraryHnd,'U14ToHost') ;
        if @U14ToHost = Nil then CED_ReportFailure('U14ToHost') ;
        @U14To1401 := GetProcAddress(LibraryHnd,'U14To1401') ;
        if @U14To1401 = Nil then CED_ReportFailure('U14To1401') ;
        @U14sendstring := GetProcAddress(LibraryHnd,'U14SendString') ;
        if @U14sendstring = Nil then CED_ReportFailure('U14SendString') ;
        @U14KillIO1401 := GetProcAddress(LibraryHnd,'U14KillIO1401') ;
        if @U14KillIO1401 = Nil then CED_ReportFailure('U14KillIO1401') ;
        @U14GetUserMemorySize := GetProcAddress(LibraryHnd,'U14GetUserMemorySize') ;
        if @U14GetUserMemorySize = Nil then CED_ReportFailure('U14GetUserMemorySize') ;
        @U14GetString := GetProcAddress(LibraryHnd,'U14GetString') ;
        if @U14GetUserMemorySize = Nil then CED_ReportFailure('U14GetString') ;

        LibraryLoaded := True ;
        end
     else begin
          ShowMessage( 'Unable to open ' + LibraryPath);
          end ;
     end ;

procedure CED_ReportFailure(
          const ProcName : string
          ) ;
begin
     ShowMessage('USE1432.DLL- ' + ProcName + ' not found.') ;
     end ;

procedure CED_ConfigureHardware(
          Resolution : Integer ;   { A/D & D/A converter resolution (bits) }
          EmptyFlagIn : Integer ;  { Empty buffer flag value }
          DACVoltageRange : Single ) { D/A output voltage range +/-V } ;
{ --------------------------------------------------------------------------
  Configure A/D and D/A to work using 16 bit (rather than 12 bit) resolution
  -------------------------------------------------------------------------- }
begin
     if Resolution = 16 then begin
        Use16BitResolution := True ;
        DACScale := 1 ;
        FDACVoltageRangeMax := DACVoltageRange ;
        end
     else begin
        Use16BitResolution := False ;
        DACScale := 16 ;
        FDACVoltageRangeMax := DACVoltageRange ;
        end ;
     CEDVRange := DACVoltageRange ;
     EmptyFlag := EmptyFlagIn ;
     end ;

function CED_GetLabInterfaceInfo(
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
          var DACBufferLimit : Integer ;      { Max. no. samples in A/D buffer }
          var DACMaxVolts : Single ; { Positive limit of bipolar D/A voltage range }
          var DACMinUpdateInterval : Double {Min. D/A update interval }
          ) : Boolean ;
{ ---------------------------------------
  Determine which type of 1401 is in use
  --------------------------------------}
var
//   Ver,VerHigh,VerLow : Integer ;
   Buf : Array[0..5000] of AnsiCHar ;
   s : ANSIString ;
   Err : SmallInt ;
begin
     if not DeviceInitialised then CED_InitialiseBoard ;
     ADCMEMVersion := '' ;
     if DeviceInitialised then
        begin
        { Get the 1401 model }
        case U14TypeOf1401( Device ) of
             U14TYPE1401 : begin
                Model := 'CED 1401 ';
                ADCMaxChannels := 16 ;
                DACMaxChannels := 4;
                ADCMinSamplingInterval := 2E-5 ;
                ADCMaxSamplingInterval := 1000.0 ;
                DACMinUpdateInterval := 1E-3 ;
                ADC1401BufferSize := 8192 ;            // Size of internal 1401 A/D buffer
                DAC1401BufferSize := ADC1401BufferSize ;
                MaxDIGTIMSlices := Min(100,DIGTIMSlicesBufLimit) ;
                ClockPeriod := 2.5E-7 ;
                end ;
             U14TYPEPLUS : begin
                Model := 'CED 1401-plus ';
                ADCMaxChannels := 16 ;
                DACMaxChannels := 4;
                ADCMinSamplingInterval := 5E-6 ;
                ADCMaxSamplingInterval := 1000.0 ;
                DACMinUpdateInterval := 2E-4 ;
                ADC1401BufferSize := 16000 ;//65536 ;
                DAC1401BufferSize := 14000 ; //ADC1401BufferSize div 2 ;
                MaxDIGTIMSlices := Min(200,DIGTIMSlicesBufLimit) ;
                ClockPeriod := 2.5E-7 ;
                end ;
             U14TYPEPOWER : begin
                Model := 'CED Power-1401 ';
                ADCMaxChannels := 16 ;
                DACMaxChannels := 4;
                ADCMinSamplingInterval := 3E-6 ;
                ADCMaxSamplingInterval := 1000.0 ;
                DACMinUpdateInterval := 1E-5 ;
                ADC1401BufferSize := 2*131072 ;
                DAC1401BufferSize := ADC1401BufferSize ;
                MaxDIGTIMSlices := Min(5000,DIGTIMSlicesBufLimit) ;
                ClockPeriod := 2.5E-7 ;
                end ;
             U14TYPEUNKNOWN : begin
                Model := 'CED 1401? ';
                ADCMaxChannels := 16 ;
                DACMaxChannels := 4;
                ADCMinSamplingInterval := 1E-5 ;
                ADCMaxSamplingInterval := 1000.0 ;
                DACMinUpdateInterval := 1E-3 ;
                ADC1401BufferSize := 131072 ;
                DAC1401BufferSize := ADC1401BufferSize ;
                MaxDIGTIMSlices := Min(500,DIGTIMSlicesBufLimit) ;
                ClockPeriod := 2.5E-7 ;
                end ;
             U14TYPEMICRO : begin
                Model := 'CED Micro-1401 ';
                ADCMaxChannels := 4 ;
                DACMaxChannels := 2;
                ADCMinSamplingInterval := 4E-6 ;
                ADCMaxSamplingInterval := 1000.0 ;
                DACMinUpdateInterval := 1E-4 ;
                ADC1401BufferSize := 32768*2 ;
                DAC1401BufferSize := ADC1401BufferSize ;
                MaxDIGTIMSlices := Min(5000,DIGTIMSlicesBufLimit) ;
                ClockPeriod := 2.5E-7 ;
                end ;
             U14TYPEMICROMK2 : begin
                Model := 'CED Micro-1401 Mk2 ';
                ADCMaxChannels := 4 ;
                DACMaxChannels := 2;
                ADCMinSamplingInterval := 2.0E-6 ;
                ADCMaxSamplingInterval := 1000.0 ;
                DACMinUpdateInterval := 1E-4 ;
                ADC1401BufferSize := 131072 ;
                DAC1401BufferSize := ADC1401BufferSize ;
                MaxDIGTIMSlices := Min(5000,DIGTIMSlicesBufLimit) ;
                ClockPeriod := 2.5E-7 ;
                end ;
             U14TYPEMICROMK3 : begin
                Model := 'CED Micro-1401 Mk3 ';
                ADCMaxChannels := 4 ;
                DACMaxChannels := 2;
                ADCMinSamplingInterval := 2.0E-6 ;
                ADCMaxSamplingInterval := 1000.0 ;
                DACMinUpdateInterval := 1E-5 ;
                ADC1401BufferSize := 131072 ;
                DAC1401BufferSize := ADC1401BufferSize ;
                MaxDIGTIMSlices := Min(5000,DIGTIMSlicesBufLimit) ;
                ClockPeriod := 2.50E-7 ;
                end ;
             U14TYPEPOWERMK2 : begin
                Model := 'CED Power-1401 Mk2 ';
                ADCMaxChannels := 16 ;
                DACMaxChannels := 4;
                ADCMinSamplingInterval := 3E-6 ;
                ADCMaxSamplingInterval := 1000.0 ;
                DACMinUpdateInterval := 1E-5 ;
                ADC1401BufferSize := 4*131072 ;
                DAC1401BufferSize := ADC1401BufferSize ;
                MaxDIGTIMSlices := Min(5000,DIGTIMSlicesBufLimit) ;
                ClockPeriod := 2.5E-7 ;
                end ;
             U14TYPEPOWERMK3 : begin
                Model := 'CED Power-1401 Mk3 ';
                ADCMaxChannels := 16 ;
                DACMaxChannels := 2 ;
                ADCMinSamplingInterval := 3E-6 ;
                ADCMaxSamplingInterval := 1000.0 ;
                DACMinUpdateInterval := 1E-5 ;
                ADC1401BufferSize := 4*131072 ;
                DAC1401BufferSize := ADC1401BufferSize ;
                MaxDIGTIMSlices := Min(5000,DIGTIMSlicesBufLimit) ;
                ClockPeriod := 2.5E-7 ;
                end ;
             U14TYPEMICROMK4 : begin
                Model := 'CED Micro-1401 Mk4 ';
                ADCMaxChannels := 4 ;
                DACMaxChannels := 2;
                ADCMinSamplingInterval := 2.0E-6 ;
                ADCMaxSamplingInterval := 1000.0 ;
                DACMinUpdateInterval := 1E-4 ;
                ADC1401BufferSize := 131072 ;
                DAC1401BufferSize := ADC1401BufferSize ;
                MaxDIGTIMSlices := Min(5000,DIGTIMSlicesBufLimit) ;
                ClockPeriod := 2.50E-7 ;
                // 22.11.21 Determine version of ADCMEM in use
                // Note. V80.0 ADCMEM,P returns Word pointers rather than Byte pointers
                SendCommand('CLIST;');
                repeat
                    Err := U14GetString( Device, @Buf, High(Buf));
                    s := String(Buf) ;
                    if ANSIContainsText(s,'ADCMEM 80.0') then ADCMEMVersion := '80.0' ;
                    until (s='') or (Err <> U14ERR_NOERROR) ;
                end ;
             else begin
                Model := 'CED 1401 (unidentified)' ;
                ADCMaxChannels := 4 ;
                DACMaxChannels := 2 ;
                ADCMinSamplingInterval := 5E-6 ;
                ADCMaxSamplingInterval := 1000.0 ;
                DACMinUpdateInterval := 1E-4 ;
                ADC1401BufferSize := 131072 ;
                DAC1401BufferSize := ADC1401BufferSize ;
                MaxDIGTIMSlices := Min(500,DIGTIMSlicesBufLimit) ;
                ClockPeriod := 2.5E-7 ;
                end ;
             end ;
        FADCMinSamplingInterval := ADCMinSamplingInterval ;
        FADCMaxSamplingInterval := ADCMaxSamplingInterval ;
        { Add the CED1401.SYS driver version number }
//      24.11.21 Removed because U14DriverVersion causing some sort of stack problem leading
//      to access violation when CED_GetLabInterfaceInfo exits
//      Ver := U14DriverVersion ;
//        VerHigh := Ver div $10000 ;
//        VerLow := Ver and $FFFF ;
//        Model := Model + format('Driver V%d.%d',[VerHigh,VerLow]) ;
        { Return A/D value range }
        if Use16BitResolution then ADCMinValue := -32768
                              else ADCMinValue := -2048 ;
        ADCMaxValue := (-ADCMinValue) - 1 ;
        ADCVoltageRanges[0] := CEDVRange ;
        FADCVoltageRangeMax := ADCVoltageRanges[0] ;
        NumADCVoltageRanges := 1 ;
        FDACVoltageRangeMax := CEDVRange ;
        DACMaxVolts := FDACVoltageRangeMax ;
        DIGTIMStartEvent := 0 ;
        { Cancel all commands and reset 1401 }
        SendCommand( 'CLEAR;' ) ;
        CED_GetError ;
        Result := True ;
        end
     else begin
          Model := 'Device Not Initialised' ;
          Result := False ;
          end ;
     // Initial placement of DIGTIM buffer
     Endof1401ADCBuffer := 0 ;
     StartOf1401DigBuffer := Endof1401ADCBuffer + 1 ;
     EndOf1401DigBuffer := StartOf1401DigBuffer + MaxDIGTIMSlices*16 - 1 ;
     end ;

function  CED_IsLabInterfaceAvailable : boolean ;
begin
     if not DeviceInitialised then CED_InitialiseBoard ;
     Result := DeviceInitialised ;
     end ;

procedure CED_InitialiseBoard ;
{ -------------------------------------------
  Initialise CED 1401 interface hardware
  -------------------------------------------}
var
   Err : DWORD ;
begin
   DeviceInitialised := False ;
   { Load CED1401 DLL library }
   if not LibraryLoaded then CED_LoadLibrary ;
   if LibraryLoaded then begin
      { Open 1401 }
      Device := U14Open1401(0) ;
      if Device >= 0 then
         begin
         { Load ADCMEM command }
         Err := U14Ld(Device,'','ADCMEM') ;
         if Err = -540 then
            ShowMessage( 'CED 1401 ERROR: Cannot find/load ADCMEM command! Check c:\1401 folder.');
         if Err = -541 then
            begin
            { If ADCMEM load fails (usually due to an old 1401 not
              having a Z8 chip) load the older command ADCMEMI }
            Err := U14Ld(Device,'','ADCMEMI') ;
           if Err = -540 then
              ShowMessage( 'CED 1401 ERROR: Cannot find ADCMEMI command! Check c:\1401 folder.');
           ADCCommand := 'ADCMEMI' ;
           end
         else ADCCommand := 'ADCMEM' ;
         // Load MEMDAC = D/A output command
         Err := U14Ld(Device,'','MEMDAC') ;
         if Err = -540 then
            ShowMessage( 'CED 1401 ERROR: Cannot find MEMDAC command! Check c:\1401 folder.');
         // Load DIGTIM = digital timing command
         Err := U14Ld(Device,'','DIGTIM') ;
         if Err = -540 then
            ShowMessage( 'CED 1401 ERROR: Cannot find DIGTIM command! Check c:\1401 folder.');
         if Err = U14ERR_NOERROR then
            begin
            { CED 1401 model }
            TypeOf1401 := U14TypeOf1401( Device ) ;
            DeviceInitialised := True ;
            { Make all events inputs ACTIVE-LOW }
            SendCommand( 'EVENT,P,63;' ) ;
            end
         else U14Close1401( Device ) ;
         end
      else CED_CheckError(Device) ;
      end ;
   { Create A/D input buffer }
   if DeviceInitialised then begin
      New(IOBuf) ;
      New(DACBuf) ;
   end ;
   ADCActive := False ;
   DACActive := False ;
   end ;

procedure CED_CheckError
          ( Err : Integer
          ) ;
{ --------------------------------------------------------------
  Warn User if the Lab. interface library returns an error
  --------------------------------------------------------------}
var
   s : string ;
begin
     if Err <> U14ERR_NOERROR then begin
        case Err of
             -500 : s := 'Present but switched off' ;
             -501 : s := 'Not connected' ;
             -502 : s := 'Not working';
             -503 : s := 'Interface card missing';
             -504 : s := 'Failed to come ready';
             -505 : s := 'Interface card, bad switches';
             -506 : s := '+ failed to come ready';
             -507 : s := 'Could not grab int. vector';
             -508 : s := 'Already in use';
             -509 : s := 'Could not get DMA channel';
             -510 : s := 'Bad handle';
             -511 : s := 'Bad number';
             -520 : s := 'No such function';
             -521 : s := 'No such subfunction';
             -522 : s := 'No room in output buffer';
             -523 : s := 'No input in buffer';
             -524 : s := 'String longer than buffer';
             -525 : s := 'Failed to lock memory';
             -526 : s := 'Failed to unlock memory';
             -527 : s := 'Area already set up';
             -528 : s := 'Area not set up';
             -529 : s := 'Illegal area number';
             -540 : s := 'Command file not found';
             -541 : s := 'Error reading command file';
             -542 : s := 'Unknown command';
             -543 : s := 'Not enough host space to load';
             -544 : s := 'Could not lock resource/command';
             -545 : s := 'CLOAD command failed';
             -560 : s := 'TOHOST/1401 failed';
             -580 : s := 'Not 386 enhanced mode';
             -581 : s := 'No device driver';
             -582 : s := 'Device driver too old';
             -590 : s := 'Timeout occurred';
             -600 : s := 'Buffer for GETSTRING too small';
             -601 : s := 'There is already a callback';
             -602 : s := 'Bad parameter to deregcallback';
             -610 : s := 'Failed talking to driver';
             -611 : s := 'Needed memory and could not get it';
             523748 : s := '1401 command not loaded';
             else s := 'Unknown error' ;
             end ;
        MessageDlg( format('Error CED 1401 %s (%d)',[s,Err]),
                    mtWarning, [mbOK], 0 ) ;
        end ;
     end ;

function CED_ADCToMemory(
          var ADCBuf : Array of SmallInt ;        { A/D sample buffer (OUT) }
          nChannels : Integer ;                   { Number of A/D channels (IN) }
          nSamples : Integer ;                    { Number of A/D samples ( per channel) (IN) }
          var dt : Double ;                       { Sampling interval (s) (IN) }
          ADCVoltageRange : Single ;              { A/D input voltage range (V) (IN) }
          TriggerMode : Integer ;                 // Trigger mode
          ADCExternalTriggerActiveHigh : Boolean ; { TRUE = Active High ext. trigger}
          CircularBuffer : Boolean ;               { Repeated sampling into buffer (IN) }
          ADCChannelInputMap : Array of Integer
           ) : Boolean ;                          { Returns TRUE indicating A/D started }
{ -------------------------------
  Set up an A/D conversion sweeep
  -------------------------------}
var
   ch : Integer ;
   dt1 : Double ;
   PreScale,Ticks : Word ;
   CommandString : string ;
begin
     Result := False ;
     ADCActive := False ;
     if not DeviceInitialised then CED_InitialiseBoard ;
     if not DeviceInitialised then Exit ;
     { Kill any A/D conversions in progress }
     SendCommand( ADCCommand + ',K;') ;
     // Clear command settings
     SendCommand('CLEAR;') ;
     if TriggerMode = tmWaveGen then
        begin
        // Make Event I/Ps 3 & 4 internal
        SendCommand( format('EVENT, D,%d;',[Event3 or Event4])) ;
        // Set Events to 0ff
        SendCommand( format( 'EVENT, I,%d;',[0])) ;
        end
     else
        begin
        // Make Event I/Ps 3 & 4 external
        SendCommand( format('EVENT, E,%d;',[Event3 or Event4])) ;
        // Set Events to 0ff
        SendCommand( format( 'EVENT, I,%d;',[0])) ;
        end ;
     // Set events mode to level
     SendCommand( 'EVENT,M,0;') ;
     { Make all events inputs ACTIVE-LOW }
     if ADCExternalTriggerActiveHigh then
        begin
        // Active High TTL external trigger (on event 4)
        SendCommand( 'EVENT,P,47;' ) ;
        end
     else
        begin
        // Active Low TTL external trigger (on event 4)
        SendCommand( 'EVENT,P,63;' ) ;
        end ;
     // Set size of internal 1401 A/D buffer
     // (must be a multiple of 2*nChannels)
     ADC1401BufferNumBytes := (ADC1401BufferSize div (nChannels*2))*nChannels*4 ;
     StartOf1401ADCBuffer := 0;
     Endof1401ADCBuffer := ADC1401BufferNumBytes - 1 ;
     ADC1401Pointer := 0 ;
     { Define end of external A/D buffer (ADCBuf in calling routine) }
     EndofADCBuf := nChannels*nSamples - 1 ;
     ADCBufPointer := 0 ;
     { Define digital buffer area }
     StartOf1401DigBuffer := Endof1401ADCBuffer + 1 ;
     EndOf1401DigBuffer := StartOf1401DigBuffer + MaxDIGTIMSlices*16 - 1 ;
     { Define start of D/A buffer area in 1401 }
     StartOf1401DACBuffer := Endof1401DigBuffer + 1 ;
     { ADCMEM command with no.of bytes to be collected }
     if ADCCommand = 'ADCMEM' then
        CommandString := format('%s,I,2,0,%d,',[ADCCommand,ADC1401BufferNumBytes])
     else
        CommandString := format('%s,2,0,%d,',[ADCCommand,ADC1401BufferNumBytes]) ;
     { Add channel list }
     for ch := 0 to nChannels-1 do
         CommandString := CommandString + format('%d ',[ADCChannelInputMap[ch]]);
     // Start indefinite repeated sampling into circular buffer
     CommandString := CommandString + ',0,' ;
     { Select immediate sweep or wait for trigger pulse on Event 4}
     if TriggerMode <> tmFreeRun then CommandString := CommandString + 'HT,'
                                 else CommandString := CommandString + 'H,' ;
     { Set sampling clock }
     dt1 := dt / nChannels ;
     CED_CheckSamplingInterval( dt1, PreScale, Ticks, 'H' ) ;
     dt := dt1 * nChannels ;
     CommandString := CommandString + format('%d,%d;',[PreScale,Ticks] );
     { Send A/D start command to 1401 }
     SendCommand( CommandString ) ;
     CED_GetError ;
     ADCActive := True ;
     Result := ADCActive ;
 //    CED_TestDIGTIM ;
     end ;

procedure CED_GetADCSamples(
          var ADCBuf : Array of SmallInt  ;
          var OutPointer : Integer
          ) ;
{ ----------------------------------------------------------
  Transfer new A/D samples in 1401's A/D buffer area to host
  ----------------------------------------------------------}
var
   Reply : Array[0..2] of Integer ;
   i,nBytes,nWrite,StartAt,NumSamples,DAC1401BlockInUse,IOBufPointer : Integer ;
   Done : Boolean ;
begin
     // Query ADC byte pointer
     SendCommand( ADCCommand + ',P;' ) ;
     U14LongsFrom1401( Device, @Reply, High(Reply) ) ;
     // Code to ensure correct interpretation of ADCMEM,P with Micro 1401 Mk4.
     // Pre-2022 versions (80.0) of ADCMEM command returned Word rather than Byte pointers.
     // Version 80.1 of the command fixed this.
     if ADCMEMVersion = '80.0' then Reply[0] := Reply[0]*2 ;
     if Reply[0] > ADC1401Pointer then
        begin
        // Transfer samples to host memory as they are acquired }
        StartAt := ADC1401Pointer ;
        // Ensure 2 bytes blocks
        ADC1401Pointer := 2*(Reply[0] div 2);
        nBytes := Min(ADC1401Pointer - StartAt,ADC1401BufferNumBytes) ;
        end
     else if Reply[0] < ADC1401Pointer then begin
        { Roll-over has occurred ... just transfer the samples
         from the current position until the end of the buffer,
         leave ADC1401Pointer at the start of the buffer }
        StartAt := ADC1401Pointer ;
        nBytes := Min(Endof1401ADCBuffer + 1 - StartAt,ADC1401BufferNumBytes) ;
        ADC1401Pointer := 0 ;
        end
     else exit ;
     NumSamples := nBytes div 2 ;
     IOBufPointer := Cardinal(IOBuf) ;
//     outputdebugString(PChar(format('%d %d %d',[Reply[0],StartAt,nbytes])));
     repeat
       nWrite := Min(nBytes,MaxBytesinBlock) ;
       U14ToHost( Device,PANSIChar(Pointer(IOBufPointer)),nWrite,StartAt, 0 ) ;
       IOBufPointer := IOBufPointer + nWrite ;
       StartAt := StartAt + nWrite ;
       nBytes := nBytes - nWrite ;
       until nBytes = 0 ;
        //outputdebugString(PChar(format('%d',[nBytes div 2])));
     // Copy A/D samples to host buffer
     i := 0 ;
     Done := False ;
     while (Not Done) and (i < NumSamples) do begin
         { Ensure EmptyFlag is never returned by CED 1401 }
         if IOBuf^[i] <> EmptyFlag then ADCBuf[ADCBufPointer] := IOBuf^[i]
                                   else ADCBuf[ADCBufPointer] := EmptyFlag-1 ;
         if not Use16BitResolution then ADCBuf[ADCBufPointer] := ADCBuf[ADCBufPointer] div 16 ;
         inc(ADCBufPointer) ;
         inc(i) ;
         if CircularBufferMode then begin
            if ADCBufPointer > EndofADCBuf then ADCBufPointer := 0 ;
         end
         else begin
            if ADCBufPointer > EndofADCBuf then Done := True ;
         end ;
     end ;
     OutPointer := ADCBufPointer ;
     // Update D/A output
     if DACActive then begin
        SendCommand( 'MEMDAC,P;' ) ;
        U14LongsFrom1401( Device, @Reply, High(Reply) ) ;
        DAC1401BlockInUse := Reply[0] div DACNumBytesInBlock ;
//        outputdebugString(PChar(format('%d %d %d',[Reply[0],DAC1401BlockInUse,DAC1401BlockDone])));
        while DAC1401BlockDone <> DAC1401BlockInUse do begin
           CED_WriteToDACBuffer ;
           Inc(DAC1401BlockDone) ;
           if DAC1401BlockDone >= DACNumBlocksIn1401Buf then DAC1401BlockDone := 0 ;
           end ;
        end ;
     end ;

procedure CED_GetError ;
var
   Reply : Array[0..2] of Integer ;
begin
     SendCommand( 'ERR;' ) ;
     U14LongsFrom1401( Device, @Reply, High(Reply) ) ;
     end ;

procedure CED_CheckSamplingInterval(
          var dt : Double ;            // Sampling Interval (returns valid value)
          var PreScale,Ticks : Word ;  // Returns clock prescale and ticks
          ClockSource : string         // H=hardware clock C=standard 1MHz
          ) ;
var
   fTicks,Period : Double ;
begin
     if UpperCase(ClockSource) = 'H' then Period := ClockPeriod
                                     else Period := 1E-6 ;
     if ClockPeriod = 0.0 then begin
        ShowMessage('Error: CED 1401 ClockPeriod=0.0! Set to 2.5E-7') ;
        ClockPeriod := 2.5E-7 ;
        end ;
     dt := max(FADCMinSamplingInterval,dt) ;
     PreScale := 1 ;
     repeat
          PreScale := PreScale*2 ;
          fTicks := dt / (Period*PreScale) ;
          until ((fTicks < 65535.0)) ;
     Ticks := Max(round( fTicks ),1) ;
     dt := Ticks*PreScale*Period ;
     end ;

 Function CED_StopADC : Boolean ;
{ -------------------------------------
  Kill any A/D conversions in progress
  -------------------------------------}
begin
     if not DeviceInitialised then CED_InitialiseBoard ;
     if DeviceInitialised then begin
        SendCommand( ADCCommand + ',K;') ;
        { Wait till command done }
        CED_GetError ;
        end ;
     ADCActive := False ;
     Result := ADCActive ;
     end ;

function  CED_MemoryToDAC(
           var DACBufIn : Array of SmallInt ;  { D/A output data buffer (IN) }
           nChannels : Integer ;             { No. of D/A channels (IN) }
           nPoints : Integer ;               { No. of D/A output values (IN) }
           dt : Double ;                      { D/A output interval (s) (IN) }
           TriggerMode : Integer ;
           ExternalTrigger : Boolean ;        // True=Wait for ext. trigger (IN)
           DACRepeatedWaveformIn : Boolean     // True=Repeat waveform until stopped
           ) : Boolean ;                     { Returns TRUE=D/A active }
{ -------------------------------
   Set up a D/A conversion sweeep
  -------------------------------}
var
   ch,i : Integer ;
   PreScale,Ticks : Word ;
   CommandString : string ;
   nBytes : DWORD ;
   Reply : Array[0..2] of Integer ;
begin
     Result := False ;
     if not DeviceInitialised then CED_InitialiseBoard ;
     if not DeviceInitialised then Exit ;
     { Kill any D/A conversions in progress }
     SendCommand( 'MEMDAC,K;') ;
     CED_GetError ;
     DACRepeatedWaveform := DACRepeatedWaveformIn ;
     DACNumChannels := nChannels ;
     DACBufNumPoints := nPoints*nChannels ;
     DACNumPointsInBlock := (Min(MaxPointsinBlock,(DAC1401BufferSize div 4)) div nChannels)*nChannels ;
     DACNumBytesInBlock := DACNumPointsInBlock*2 ;
     DACNumBlocksIn1401Buf := DAC1401BufferSize div DACNumPointsInBlock ;
     DACNumPointsIn1401Buf := DACNumBlocksIn1401Buf*DACNumPointsInBlock ;
     // Copy D/A waveform to output buffer
     for i := 0 to DACBufNumPoints-1 do DACBuf^[i] := DACBufIn[i]*DACScale ;
     nBytes := DACNumPointsIn1401Buf*2 ;
     Endof1401DACBuffer := StartOf1401DACBuffer + nBytes -1 ;
     DACStartOf1401BufLo := StartOf1401DACBuffer ;
     // Fill first two 1401 blocks
     DACBufPointer := 0 ;
     DACNextBlockToWrite := 0 ;
     DAC1401BlockDone := 0 ;
     //CED_WriteToDACBuffer ;
     for i := 1 to 2 do begin
           CED_WriteToDACBuffer ;
           Inc(DAC1401BlockDone) ;
           if DAC1401BlockDone > DACNumBlocksIn1401Buf then DAC1401BlockDone := 0 ;
           end ;
     //outputdebugString(PChar(format('%d',[StartOf1401DACBuffer])));
     if TypeOf1401 = U14TYPE1401 then
        begin
        { Amount of 1401 memory available }
        SendCommand('MEMTOP;') ;
        U14LongsFrom1401( Device, @Reply, High(Reply) ) ;
        MemoryAvailable := Abs(Trunc( Reply[1] - Reply[0] )) ;
        if Endof1401DACBuffer > MemoryAvailable then
           ShowMessage( 'ERROR: Not enough 1401 memory' ) ;
        end ;
     { Create MEMDAC command string }
     //nBytes := 34 ;
     CommandString := format('MEMDAC,I,2,%d,%d,',[StartOf1401DACBuffer,nBytes]) ;
     { Add channel list }
     for ch := 0 to nChannels-1 do
         CommandString := CommandString + format('%d ',[ch]);
     { Number of repeats =1 or 0=until stopped}
     CommandString := CommandString + ',0,' ;
     { Set sampling clock and start D/A output }
     CED_CheckSamplingInterval( dt, PreScale, Ticks, 'H' ) ;
     if TriggerMode <> tmFreeRun then begin
        // Wait for trigger on Event 3
        CommandString := CommandString + format('HT,%d,%d;',[PreScale,Ticks] );
        end
     else begin
        // Start DAC output immediately
        CommandString := CommandString + format('H,%d,%d;',[PreScale,Ticks] );
        end ;
     SendCommand( CommandString ) ;
     CED_GetError ;
     // Trigger A/D and D/A sweeps (if in waveform generation mode)
     if U14TypeOf1401(Device) = U14TYPE1401 then
        begin
        // Standard 1401 = Send 5V step to DAC 2 to trigger Event 3 & 4
        CED_SetDAC2( 4.9 ) ;
        CED_SetDAC2( 0.0 ) ;
        end
     else
        begin
        // All other 1401s - trigger events internally
        // Event4 = A/D Event3 = D/A  DIGTIMStartEvent = Digital
        SendCommand( format( 'EVENT, I,%d;',[0])) ; // Clear events
        SendCommand( format( 'EVENT, I,%d;',[Event3 or Event4 or DIGTIMStartEvent])) ; // Set to trigger
        end ;
     DIGTIMStartEvent := 0 ;
     DACActive := True ;
     Result := DACActive ;
     end ;
procedure CED_WriteToDACBuffer ;
// -------------------------------
// Write D/A to DAC buffer in 1401
// -------------------------------
var
    i : Integer ;
    iStart : DWORD ;
begin
     // Copy from DACBuf to IOBuf
     for i := 0 to DACNumPointsInBlock-1 do begin
        IOBuf^[i] := DACBuf^[DACBufPointer] ;
        Inc(DACBufPointer) ;
        if DACBufPointer >= DACBufNumPoints then begin
           // Go back to start for repeated waveforms,
           // Pad with last set of channels for single sweeps
           if DACRepeatedWaveform then DACBufPointer := 0
                                  else DACBufPointer := DACBufNumPoints - DACNumChannels ;
           end ;
        end ;
//     outputdebugString(PChar(format('%d %d %d',[DACNextBlockToWrite,DACBufPointer,DACBufNumPoints])));
     iStart := DACNextBlockToWrite*DACNumBytesInBlock ;
     U14To1401( Device,
                IOBuf,
                DACNumBytesinBlock,
                StartOf1401DACBuffer + iStart, 0 ) ;
     Inc(DACNextBlockToWrite) ;
     if DACNextBlockToWrite >= DACNumBlocksIn1401Buf then DACNextBlockToWrite := 0 ;
      CED_GetError ;
      end ;

procedure CED_SetDAC2( Volts : Single ) ;
// -----------------
// Set DAC 2 voltage
// -----------------
var
   VSCale : Single ;
begin
     VScale := MaxNativeValue / FDACVoltageRangeMax ;
     SendCommand( format('DAC,%d,%d,2;',[2,Round( Volts*VScale )]));
     end ;

function CED_ReadADC( Chan : Integer ) : SmallInt ;
// --------------------------------
// Read selected A/D input channel
// --------------------------------
var
   Command : string ;
   Reply : Array[0..2] of Integer ;
begin
     // Keep channel within valid limits
     Chan := Min(Max(Chan,0), MaxADCChannel ) ;
     // Stop A/D conversions if in progress
     if ADCActive then CED_StopADC ;
     // Request an A/D conversion
     Command := format( 'ADC,%d;', [Chan] ) ;
     SendCommand( Command ) ;
     // Wait for return of value from 1401
     U14LongsFrom1401( Device, @Reply, High(Reply) ) ;
     // Return A/D sample (scaled 16->12 bits if necessary)
     Result := Reply[0] div DACScale ;
     end ;

procedure CED_WriteDACs(
          const DACVolts : array of single ;
          NumDACS : Integer
          ) ;
{ ------------------------
  Write to D/A converters
  -----------------------}
var
   Command : string ;
   DACValue,ch : Integer ;
   DACScale : single ;
begin
     if not DeviceInitialised then CED_InitialiseBoard ;
     if not DeviceInitialised then Exit ;
     DACScale := MaxNativeValue / FDACVoltageRangeMax ;
     for ch := 0 to Min(High(DACVolts),NumDACS-1) do begin
         DACValue := Round( DACVolts[ch]*DACScale ) ;
         Command := format('DAC,%d,%d,2;',[ch,DACValue]);
         SendCommand( Command ) ;
         end ;
     CED_GetError ;
     end ;

function CED_StopDAC : Boolean ;
{ -------------------------------------
  Kill any D/A conversions in progress
  -------------------------------------}
begin
     Result := False ;
     if not DeviceInitialised then CED_InitialiseBoard ;
     if not DeviceInitialised then Exit ;
     SendCommand( 'MEMDAC,K;') ; { Kill any D/A output }
     SendCommand( 'DIGTIM,K;') ; { Kill any digital output }
     { Wait till command done }
     CED_GetError ;
     DACActive := False ;
     Result := DACActive ;
     end ;

procedure  CED_WriteToDigitalOutPutPort(
           Pattern : Integer
           ) ;
{ ----------------------------------------------------------
  Write a value to the digital O/P lines 8(Pin 17)-15(Pin 1)
  ----------------------------------------------------------}
var
   Command : string ;
begin
     if not DeviceInitialised then CED_InitialiseBoard ;
     if not DeviceInitialised then Exit ;
     { Stop any digital pattern in progress }
     SendCommand( 'DIGTIM,K;') ;
     { Send digital O/P byte }
     Command := format('DIG,O,%d;',[Pattern*$100 and $FF00]) ;
     SendCommand( Command );
     { Wait till done }
     CED_GetError ;
     end ;

function  CED_ReadDigitalInPutPort : Integer  ;
{ ----------------------------------------------------------
  Read value of digital input port
  ----------------------------------------------------------}
var
   Reply : Array[0..2] of Integer ;
begin
     Result := 0 ;
     if not DeviceInitialised then CED_InitialiseBoard ;
     if not DeviceInitialised then Exit ;
     // Read digital input bits 0-7
     SendCommand( 'DIG,I;' );
     // Wait for result
     U14LongsFrom1401( Device, @Reply, High(Reply) ) ;
     Result := Reply[0] ;
     end ;

procedure CED_ArmStimulusTriggerInput ;
// ----------------------------------------------
// Arm external stimulus trigger input (EVENT 0)
// ----------------------------------------------
begin
     if not DeviceInitialised then CED_InitialiseBoard ;
     if not DeviceInitialised then Exit ;
     // Arm EVENT0
     SendCommand( 'CLKEVT,C,2;' ) ;
     end ;

function CED_StimulusTriggerInputState : Boolean ;
// ---------------------------------------------------------
// Return state of external stimulus trigger input (EVENT 0)
// ---------------------------------------------------------
var
  Reply : Array[0..3] of Integer ;
begin
     Result := False ;
     if not DeviceInitialised then CED_InitialiseBoard ;
     if not DeviceInitialised then Exit ;
     // Read CLKEVT state
     SendCommand( 'CLKEVT,R;') ;
     // Wait for return of value from 1401
     U14LongsFrom1401( Device, @Reply, High(Reply) ) ;
     if Reply[1] <> 0 then Result := True ;
     end ;

procedure CED_MemoryToDigitalPort(
          var DigBuf : Array of SmallInt ;  { Digital pattern buffer }
          nValues : Integer ;               { No. of pattern values in DigBuf }
          dt : Double ;                      { Output interval }
          StartAt : Integer ;               { Start o/p at StartAt in DigBuf }
          CEDPower1401DIGTIMCountShift : Integer ; // DIGSTIM command count offset for Power 1401
          RepeatedWaveform : Boolean               // True = repeat digital pulse pattern
          ) ;
{ --------------------------------------------------------
  Set up a digital output sequence within the 1401 memory
  (*NOTE* Event Input 2 (E2) is used to synchronise digital output
  with the start of the record sweeping. Thus the D/A 1 (sync. pulse)
  output is connected to BOTH Event 4 In (Trigger In on Micro1401)
  and Event 2 In (On back panel in Micro1401).)
  -------------------------------------------------------}
type
    TSlice = record
           State : Integer ;
           Count : Integer ;
           end ;
var
   Slice : Array[0..DIGTIMSlicesBufLimit-1]of TSlice ;
   nSlices : Integer ;
   nCount : Integer ;
   LastChange,i,iDig,iDigShift : Integer ;
   Command : string ;
   PreScale,Ticks : Word ;
   nRepeat : Integer ;
begin
     if not DeviceInitialised then CED_InitialiseBoard ;
     if not DeviceInitialised then Exit ;
     iDig := StartAt ;
     { Extract bit pattern from digital buffer and convert to
          a series of DIGTIM slices }
     nSlices := 1 ;
     Slice[nSlices-1].State := DigBuf[iDig] and $FF ;
     Slice[nSlices-1].Count := 2 ;
     { *** BODGE ***
          This second slice put here to sort out a curious bug
          where the time for the second slice is doubled.
          Don't know whether this is a bug in DIGTIM command
          or in my own code. }
     nSlices := 2 ;
     Slice[nSlices-1].State := DigBuf[iDig] and $FF ;
     Slice[nSlices-1].Count := 2 ;
     // DIGTIM command seems to operate differently with Power 1401
     // All other 1401 DIGTIM slices seem to count before changing state
     // Power 1401 changes state then counts. Not sure if this is a bug
     // in my code, but the line below adjusts for Power 1401 (10/5/01)
     // 13/7/11. Some Power 1401s seem to behave differently, not requiring the
     // offset. So option CEDPOWER1401DIGTIMCOUNTSHIFT added to 'lab interface.xml'
     // to allow user to enable or disable offset
//     Removed 22.11.2021
//     if (TypeOf1401 = U14TYPEPOWER) or
//        (TypeOf1401 = U14TYPEPOWERMK2) then iDigShift := CEDPower1401DIGTIMCountShift
//                                       else iDigShift := 0 ;
//    Added ... These problems seem to have been fixed. Now always assume that state changes at end of slice
      iDigShift := 0 ;
     iDig := iDig + 2 ;
     LastChange := iDig ;
     while (iDig <= nValues) and (nSlices < (MaxDIGTIMSlices-1)) do
           begin;
           Inc(iDig) ;
           if (DigBuf[iDig] <> DigBuf[iDig-1]) or (iDig >= nValues) then
              begin
              // Set slice count
              nCount := iDig-LastChange ;
              // Extend count beyond end of sweep by 10 seconds
//              if iDig >= nValues then nCount := nCount + round(10.0 /dt) ;
              // Create slices
              repeat
                 // Increment slice counter
                 Inc(nSlices) ;
                 // Set state
                 if iDig >= nValues then Slice[nSlices-1].State := DigBuf[nValues-1] and $FF
                 else Slice[nSlices-1].State := DigBuf[iDig-iDigShift] and $FF ;
                 // Set count for slice
                 Slice[nSlices-1].Count := 2*Max(Min(nCount,30000),1) ;
                 // Decrement counts to do
                 nCount := nCount - (Slice[nSlices-1].Count div 2) ;
                 until (nCount <= 0) or (nSlices >= MaxDIGTIMSlices) ;
              LastChange := iDig ;
              end ;
           end ;
     { Cancel any DIGTIM commands that are running }
     SendCommand( 'DIGTIM,K;') ;
     CED_GetError ;
     if U14TypeOf1401(Device) = U14TYPE1401 then begin
        // Standard 1401 only - set DAC2 (connected to Events 2,3,4) high to prevent DIGTIM
        CED_SetDAC2( 4.9 ) ;
        end
     else begin
        // All other 1401s - Set DIGTIM gate event to internal
        SendCommand( format('EVENT,D,%d;',[Event2])) ;
        end ;
     { Create DIGTIM slice table }
     Command := format('DIGTIM,SI,%d,%d;',[StartOf1401DigBuffer,nSlices*16]);
     SendCommand( Command ) ;
     { Allow DIGTIM to control digital O/P ports only }
     SendCommand( 'DIGTIM,OD;' ) ;
     for i := 0 to nSlices-1 do begin
         Command := format('DIGTIM,A,$FF,%d,%d;',[Slice[i].State,Slice[i].Count]);
         SendCommand( Command ) ;
         CED_GetError ;
         end ;
     { Set sampling clock and arm DIGTIM digital output
          Note.
          1) clock is run at twice the D/A update rate and slice counts are doubled
          2) DIGTIM clock is gated by Event Input 2 (Active Low) }
     CED_CheckSamplingInterval( dt, PreScale, Ticks, 'C' ) ;
     Ticks := Ticks div 2 ;
     if RepeatedWaveform then nRepeat := 0
                         else nRepeat := 1 ;
     Command := format('DIGTIM,CT,%d,%d,%d;',[PreScale,Ticks,nRepeat] );
     SendCommand( Command ) ;
     CED_GetError ;
     // Set DIGTIM start event #
     DIGTIMStartEvent := Event2 ;
     end ;

procedure CED_TestDIGTIM ;
var
  Command : string ;
begin

     SendCommand( 'DIGTIM,K;' ) ;
     CED_GetError ;

     // All other 1401s - Set DIGTIM gate event to internal
        SendCommand( format('EVENT,D,%d;',[Event2])) ;
    CED_GetError ;
     { Create DIGTIM slice table }
     Command := format('DIGTIM,SI,%d,%d;',[StartOf1401DigBuffer,40*16]);
     SendCommand( Command ) ;
    CED_GetError ;


     { Allow DIGTIM to control digital O/P ports only }
     SendCommand( 'DIGTIM,OD;' ) ;
     CED_GetError ;

     { Send slice table to 1401 }
     SendCommand( 'DIGTIM,A,$ff,1,100;' ) ;
     CED_GetError ;
     SendCommand( 'DIGTIM,A,$FF,0,900;' ) ;
     CED_GetError ;
     SendCommand( 'DIGTIM,A,$ff,1,200;' ) ;
     CED_GetError ;
     SendCommand( 'DIGTIM,A,$FF,0,800;' ) ;
     CED_GetError ;
     SendCommand( 'DIGTIM,A,$ff,1,300;' ) ;
     CED_GetError ;
     SendCommand( 'DIGTIM,A,$FF,0,700;' ) ;
     CED_GetError ;
     SendCommand( 'DIGTIM,A,$ff,0,100;' ) ;
     CED_GetError ;
     SendCommand( 'DIGTIM,A,$FF,0,900;' ) ;
     CED_GetError ;

   {  SendCommand( 'DIGTIM,A,$FF,1,1000,0,1;' ) ;
     CED_GetError ;
     SendCommand( 'DIGTIM,A,$FF,0,1000,0,1;' ) ;
     CED_GetError ;}


 //    SendCommand( 'DIGTIM,A,$FF,0,100,1,1;' ) ;
 //    CED_GetError ;
     SendCommand( 'DIGTIM,C,2,500,10;' ) ;
     CED_GetError ;

     end ;

procedure CED_StopDIG ;
{ -------------------------------------
  Stop digital output pattern generator
  -------------------------------------}
begin
     if not DeviceInitialised then CED_InitialiseBoard ;
     if not DeviceInitialised then Exit ;
     SendCommand( 'DIGTIM,K;' ) ;
     CED_GetError ;
     end ;

procedure SendCommand(
          const CommandString : string
          ) ;
{ -------------------------------
  Send a command to the CED 1401
  ------------------------------}
var
   Command : ANSIstring ;
begin
     if not DeviceInitialised then CED_InitialiseBoard ;
     Command := ANSIString(CommandString + #0) ;
     CED_CheckError( U14sendstring( Device, @Command[1] ) ) ;
     end ;

procedure CED_GetChannelOffsets(
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
procedure CED_CloseLaboratoryInterface ;
begin
     if DeviceInitialised then begin
        SendCommand( 'CLEAR;' ) ;
        if Device >= 0 then begin
           U14Close1401( Device ) ;
           Device := -1 ;
           DeviceInitialised := False ;
           end ;
        { Remove DLL library from memory }
        if LibraryLoaded then FreeLibrary( LibraryHnd ) ;
        LibraryLoaded := False ;
        end ;
     { Dispose of allocated memory resources }
     if IOBuf <> Nil then begin
        Dispose(IOBuf) ;
        IOBuf := Nil ;
        end ;
     if DACBuf <> Nil then begin
        Dispose(DACBuf) ;
        DACBuf := Nil ;
        end ;
     end ;
function CED_GetType : Integer ;
begin
     Result := TypeOf1401 ;
     end ;

function ExtractInt ( CBuf : string ) : longint ;
Type
    TState = (RemoveLeadingWhiteSpace, ReadNumber) ;
var
   CNum : string ;
   i : integer ;
   Quit : Boolean ;
   State : TState ;
begin
     CNum := '' ;
     i := 1;
     Quit := False ;
     State := RemoveLeadingWhiteSpace ;
     while not Quit do begin
           case State of
           { Ignore all non-numeric characters before number }
           RemoveLeadingWhiteSpace : begin
               if CBuf[i] in ['0'..'9','E','e','+','-','.'] then State := ReadNumber
                                                            else i := i + 1 ;
               end ;
           { Copy number into string CNum }
           ReadNumber : begin
                { End copying when a non-numeric character
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

initialization
    LibraryLoaded := False ;
    DeviceInitialised := False ;
    Use16BitResolution := False ;
    FADCMinSamplingInterval := 4E-6 ;
    FADCMaxSamplingInterval := 1000. ;
    MaxNativeValue := 32767 ;
    FDACVoltageRangeMax := 5. ;
    DACScale := 16 ;
    StartOf1401ADCBuffer := 0 ;
    CircularBufferMode := false ;
    IOBuf := Nil ;
    ADCBufPointer := 0 ;
    ClockPeriod := 2.5E-7 ;
    EmptyFlag := 32767 ;
end.
