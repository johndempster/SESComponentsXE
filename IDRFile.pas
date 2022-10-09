unit IDRFile;
// -------------------------------------------------
// WinFluor IDR file handling component
// (c) J. Dempster, University of Strathclyde, 2003
// -------------------------------------------------
// 5.8.03 ... .CreateFileFrom() now creates copy of EDR file
// 6.8.03 ... .IntensityScale and .IntensityOffset added
// 11.8.03 ... IntensityOffset forced to 0 when IntensityScale=1
// 24.9.03 ... IDR file offsets now stored as Int64 to permit files bigger than 2Gbyte
// 10.8.03 ... Event marker list added
// 9.12.03 ... IDR and EDR files can now have non-standard header sizes
// 12.3.04 ... User now has option of updating non-standard header size to normal value
// 9.06.04 ... EDR file header size increased to 2048
// 29.06.04 .. LineScan property added
// 08.06.05 .. Data folder created automatically if one does not exist
// 10.06.05 .. IMGDELAY=', FImageStartDelay added Delay before start of imaging
// 21.06.05 .. DATECR=, Creation date field added
// 23.06.05 .. WriteEnabled property added
//             File is now opened in read-only mode except when writing is required
// 05.08.05 .. CopyADCSamples added to CreateFileFrom
//             .SaveADC() method added
// 04.09.05 .. Channel.YMax and YMin now set when first IDR file opened
// 12.10.05 .. ADCNumScansInFile=0 fixed if scans exist in EDR file
// 28.02.06 .. Disk free space always reported as available on G
// 26.04.06 .. IDR file header size increased to 16000 bytes
//             No. of ROIs increased to 50
// 23.01.07 .. Max. no. of frame types increased to 9
// 22.01.07 .. Spectrum data properties added
// 08.05.07 .. Channel settings now acquired from EDR file
//             if EDR file exists bit IDR file indicates no channels or samples.
// 11.07.07 .. EventDisplayDuration property added
// 23.04.08 .. FrameTypeDivideFactor added
// 03.07.08 .. No. of frame types now made equal to no. frames in line scan files
// 22.01.09 .. Support for 4 byte pixel images addded
// 13.07.10 .. .LoadADCData now always fills buffer with required number of samples
//             padding upper and lower ends if necessary
//             .FileHeader property added returning string with IDR file header text
// 27.07.10 .. IDRFileRead now times out after 500ms if no data available
//             No. of frames listed in header now checked against file size
//             and can be corrected to match file size.
// 05.08.10 .. JD .LoadADCData can now return data for buffer request which are
//             completely outside data. (first or last data samples are returned
//             Event detector display settings now stored in IDR file header
// 26.07.11 .. JD FileSeek(..) replaced with IDRGetFileSize() for IDR file
//             because it was returning incorrect file size for files > 2Gbyte
// 24.07.12 .. DiskSpaceAvailable now works correctly for all drives
// 31.07.12 .. Max. no. of ROIs increased to 100
// 30.01.13 .. Z stack parameters (ZNUMSECTIONS,ZSTART,ZSPACING) added
// 24-7-13 JD Now compiles unders Delphi XE2/3 as well as 7.
//            CopyStringToArray() name changed to AppendStringToANSIArray()
// 13-11-13 JD .ADCNumScansInFile now Int64 as is StartScan in .LoadADC() .SaveADC()
//            .EDR files larger than 2GB now supported
// 29.05.14 JD .AsyncFileWrite() now transfers directly from source data buffer
//             to increase file writing speed.
//             EDRFileHandle now THandle (for 64 bit compatibility)
// 17.06.14 JD Error in DiskSpaceAvailable() causing false report of free disk space fixed
//             SetWriteEnabled() EDR file now closed correctly (fixes inability to
//             reselect existing file as a new data file.)
// 19.01.15 JD File creation time properties (Hour,mins,seconds) added
//             .CreateFileFrom() now uses current date/time as creation date
// 23.09.22 JD IDR and EDR header texts now read/written using StringLists
// 04.10.22 JD ROIs now saved in <filename>.roi.csv file along with <filename>.idr file
//             Limit of 100 ROIs stored in IDR file header, 100-1000 stored in <filename>.roi.csv

interface

uses
  Classes, Types, Dialogs, Graphics, Controls, DateUtils, math, windows, mmsystem, SysUtils, strutils  ;

const
     MaxEqn = 9 ;                    // Upper limit of binding equations
     MaxFrameType = 8 ;              // Upper limit of frame types
     MaxFrameDivideFactor = 100 ; 
     MaxChannel = 7 ;                // Upper limit of A/D channels
     cMaxROIs = 1000 ;               // Upper limit of ROIs (raised from 100 04/10/22)
     cMaxROIsInHeader = 100 ;        // Upper limit of ROIs stored in IDR Header
     MaxMarker = 20 ;               // Upper limit of event markers
     cNumIDRHeaderBytes = 32768 ;  // Old size = 4096 ;
     cNumEDRHeaderBytes = 2048 ; //
     MaxFrameWidth = 4096 ;
     MaxFrameHeight = 4096 ;
     MaxPixelsPerFrame = MaxFrameWidth*MaxFrameHeight ;
     MaxBytesPerFrame = MaxPixelsPerFrame*2 ;
     MaxWavelengthDivideFactor = 100 ;
     MaxLightSourceCycleLength = MaxWavelengthDivideFactor*(MaxFrameType+2) ;

     NoROI = -1 ;
     PointROI = 0 ;
     RectangleROI = 1 ;
     EllipseROI = 2 ;
     LineROI = 3 ;
     PolyLineROI = 4 ;
     PolygonROI = 5 ;
     ROIMaxPoints = 100 ;

type

TSmallIntArray = Array[0..99999999] of SmallInt ;
PSmallIntArray = ^TSmallIntArray ;
TIntArray = Array[0..MaxPixelsPerFrame-1] of Integer ;
PIntArray = ^TIntArray ;
TSingleArray = Array[0..MaxPixelsPerFrame-1] of Single ;
PSingleArray = ^TSingleArray ;
TPointArray = Array[0..MaxPixelsPerFrame-1] of TPoint ;
PPointArray = ^TPointArray ;


TChannel = record
         xMin : single ;
         xMax : single ;
         yMin : single ;
         yMax : single ;
         xScale : single ;
         yScale : single ;
         Left : LongInt ;
         Right : LongInt ;
         Top : LongInt ;
         Bottom : LongInt ;
         TimeZero : single ;
         ADCZero : single ;
         ADCZeroAt : LongInt ;
         ADCSCale : single ;
         ADCCalibrationFactor : single ;
         ADCCalibrationValue : single ;
         ADCAmplifierGain : single ;
         ADCUnits : string ;
         ADCName : string ;
         InUse : Boolean ;
         ChannelOffset : LongInt ;
         CursorIndex : LongInt ;
         ZeroIndex : LongInt ;
         CursorTime : single ;
         CursorValue : single ;
         Cursor0 : Integer ;
         Cursor1 : Integer ;
         TZeroCursor : Integer ;
         color : TColor ;
         end ;

     TROI = record
         InUse : Boolean ;
         Shape : Integer ;
         TopLeft : TPoint ;
         BottomRight : TPoint ;
         Centre : TPoint ;
         Width : Integer ;
         Height : Integer ;
         ZoomFactor : Single ;
         XY : Array[0..ROIMaxPoints-1] of TPoint ;
         NumPoints : Integer ;
         end ;

  TBindingEquation = record
         InUse : Boolean ;
         Name : string ;
         Ion : string ;
         Units : string ;
         RMin : Single ;
         RMax : Single ;
         KEff : Single ;
         end ;

  TIDRFile = class(TComponent)
  private
    { Private declarations }
    FFileName : String ;           // Data file name
    FFileOpen : Boolean ;          // TRUE = File open
    FWriteEnabled : Boolean ;      // TRUE = file can be written to
    FIdent : String ;              // Comment line
    FYearCreated : Integer ;         // Creation date (year)
    FMonthCreated : Integer ;       // Creation date (month)
    FDayCreated : Integer ;         // Creation date (day)
    FHourCreated : Integer ;        // Creation time (hour)
    FMinuteCreated : Integer ;      // minute
    FSecondCreated  : Integer ;     // second

    FLineScan : Boolean ;          // Line scan flag
    FLSTimeCoursePixel : Integer  ;  // Time course pixel
    FLSTimeCourseNumAvg : Integer ;  // No. of pixel on line averaged for time course
    FLSTimeCourseBackgroundPixel : Integer ;    // Background subtraction pixel
    FLSSubtractBackground : Boolean ; // Subtract background

    FImageStartDelay : Single ;
    FLineScanIntervalCorrectionFactor : Single ;
    FNumFrames : Integer ;   // No. of frames in data file
    FFrameWidth : Integer ;        // Image frame width (pixels)
    FFrameHeight : Integer ;       // Image frame height (pixels)
    FPixelDepth : Integer ;        // No. of bits per pixel
    FNumZSections : Integer ;         // No. of Z sections
    FZStart : Single ;                // Z position of first Z section
    FZSpacing : Single ;       // Spacing between Z sections
    FFrameInterval : Single ;      // Frame capture interval (s)
    FNumBytesPerFrame : Integer ;    // No. bytes per frame
    FNumPixelsPerFrame : Integer ; // No. of pixels per frame
    FNumBytesPerPixel : Integer ;  // No. of bytes per image pixel
    //FGreyMin : Integer ;            // Minimum grey level
    FGreyMax : Integer ;            // Maximum intensity value
    FIntensityScale : Single ;      // Image intensity measurement scale factor
    FIntensityOffset : Single ;     // Image intensity measurement offset
    //GreyMax : Integer ;            // Maximum grey level
    FXResolution : Single ;         // Pixel width
    FYResolution : Single ;         // Pixel height
    FResolutionUnits : String ;     // Pixel width measurement units

    FNumIDRHeaderBytes : Integer ;  // No. of bytes in IDR file header
    FNumEDRHeaderBytes : Integer ;  // No. of bytes in EDR file header

    // Type of frame
    FNumFrameTypes : Integer ;                       // No. of frames types in file
    FFrameTypes : Array[0..MaxFrameType] of string ; // Frame type names
    FFrameTypeDivideFactor : Array[0..MaxFrameType] of Integer ; // Frame divide factor
    FFrameTypeCycle : Array[0..MaxLightSourceCycleLength-1] of Integer ;
    FFrameTypeCycleLength : Integer ;

    // Regions of interest within images
    FMaxROI : Integer ;                        // Highest ROI
    FROIs: Array[0..cMaxROIs] of TROI ;
    // Binding equations
    FMaxEquations : Integer ;                  // No. of equations
    FEquations : Array[0..MaxEqn] of TBindingEquation ;

    // Analogue signal channel parameters
    FADCMaxChannels : Integer ;
    Channels : Array[0..MaxChannel] of TChannel ;
    FADCNumScansInFile : Int64 ;  // No. of A/D multi-channel scans in file
    FADCNumSamplesInFile : Int64 ; // No. of A/D samples in file
    FADCNumChannels : Integer ;     // No. of A/D channels per scan
    FADCScanInterval : Single ;     // Time interval between A/D scans (s)
    FADCVoltageRange : Single ;     // A/D input voltage range
    FADCNumScansPerFrame : Integer ; // No. of scans per image frame
    FADCMaxValue : Integer ;         // Max. A/D sample value

    FNumMarkers : Integer ;
    FMarkerTime : Array[0..MaxMarker] of Single ;
    FMarkerText : Array[0..MaxMarker] of String ;

    // Spectrum data
    FSpectralDataFile : Boolean ;
    FSpectrumStartWavelength : Single ;
    FSpectrumEndWavelength : Single ;
    FSpectrumBandwidth : Single ;
    FSpectrumStepSize : Single ;

    // Event detection data
    FEventDisplayDuration : Single ;
    FEventDeadTime : Single ;
    FEventDetectionThreshold : Single ;
    FEventThresholdDuration : Single ;
    FEventDetectionThresholdPolarity : Integer ;
    FEventDetectionSource : Integer ;
    FEventROI : Integer ;
    FEventBackgROI : Integer ;
    FEventFixedBaseline : Boolean ;
    FEventRollingBaselinePeriod : Single ;
    FEventBaselineLevel : Integer ;
    FEventRatioExclusionThreshold : Integer ;
    FEventRatioTop : Integer ;
    FEventRatioBottom : Integer ;
    FEventRatioDisplayMax : Single ;
    FEventRatioRMax : Single ;
    FEventF0Wave : Integer ;
    FEventFLWave : Integer ;
    FEventF0Start : Integer ;
    FEventF0End : Integer ;
    FEventF0Constant : Single ;
    FEventF0UseConstant : Boolean ;
    FEventF0DisplayMax : Single ;
    FEventF0SubtractF0 : Boolean ;

    FIDRFileHandle : THandle ;       // .IDR (images) file handle
    FEDRFileHandle : THandle ;       // .EDR (A/D samples) file handle
    PInternalBuf : Pointer ;         // Internal frame buffer

    AsyncWriteOverlap : _Overlapped ;
    FAsyncWriteInProgess : Boolean ;   // Asynchronous file write in progress flag
    AsyncNumBytesToWrite : Integer ;
    FAsyncBufferOverflow : Boolean ;

    NoPreviousOpenFile : Boolean ;   // No file has been opened yet flag

    IDRFileHeaderText : string ;     // IDR File header KEY=Value text

 //   HeaderFull : Boolean ;
 //   Header : array[1..cNumIDRHeaderBytes] of ANSIchar ;

    Err : Boolean ;

    procedure GetIDRHeader ;
    procedure SaveIDRHeader ;
    procedure SaveROIsToCSVFile(
              FileName : String
              ) ;
    procedure LoadROIsFromCSVFile(
              FileName : String
              ) ;
    function GetInt( var s : String ) : Integer ;
    function GetNumFramesInFile : Integer ;
    procedure GetEDRHeader ;
    procedure SaveEDRHeader ;
    function GetNumScansInEDRFile : Int64 ;

    procedure AddKeyValue( List : TStringList ;  // List for Key=Value pairs
                           Keyword : string ;    // Key
                           Value : single        // Value
                           ) ; Overload ;

    procedure AddKeyValue( List : TStringList ;  // List for Key=Value pairs
                           Keyword : string ;    // Key
                           Value : Integer        // Value
                           ) ; Overload ;

    procedure AddKeyValue( List : TStringList ;  // List for Key=Value pairs
                           Keyword : string ;    // Key
                           Value : Int64        // Value
                           ) ; Overload ;

    procedure AddKeyValue( List : TStringList ;  // List for Key=Value pairs
                           Keyword : string ;    // Key
                           Value : NativeInt        // Value
                           ) ; Overload ;

    procedure AddKeyValue( List : TStringList ;  // List for Key=Value pairs
                           Keyword : string ;    // Key
                           Value : String        // Value
                           ) ; Overload ;

    procedure AddKeyValue( List : TStringList ;  // List for Key=Value pairs
                           Keyword : string ;    // Key
                           Value : Boolean        // Value
                           ) ; Overload ;


   function GetKeyValue( List : TStringList ;  // List for Key=Value pairs
                         KeyWord : string ;   // Key
                         Value : single       // Value
                         ) : Single ; Overload ;        // Return value

   function GetKeyValue( List : TStringList ;  // List for Key=Value pairs
                         KeyWord : string ;   // Key
                         Value : Integer       // Value
                         ) : Integer ; Overload ;        // Return value

   function GetKeyValue( List : TStringList ;  // List for Key=Value pairs
                         KeyWord : string ;   // Key
                         Value : Int64       // Value
                         ) : Int64 ; Overload ;        // Return value

   function GetKeyValue( List : TStringList ;  // List for Key=Value pairs
                         KeyWord : string ;   // Key
                         Value : NativeInt       // Value
                         ) : NativeInt ; Overload ;        // Return value

   function GetKeyValue( List : TStringList ;  // List for Key=Value pairs
                         KeyWord : string ;   // Key
                         Value : string       // Value
                         ) : string ; Overload ;        // Return value

   function GetKeyValue( List : TStringList ;  // List for Key=Value pairs
                         KeyWord : string ;   // Key
                         Value : Boolean       // Value
                         ) : Boolean ; Overload ;        // Return value

    function IntLimitTo( Value, LowerLimit, UpperLimit : Integer ) : Integer ;
    function ExtractFloat ( CBuf : ANSIstring ; Default : Single) : single ;

    function GetFrameType( i : Integer ) : String ;

    function GetFrameTypeDivideFactor( i : Integer ) : Integer ;

    function GetEquation( i : Integer ) : TBindingEquation ;
    function GetMarkerTime( i : Integer ) : Single ;
    procedure SetMarkerTime( i : Integer ; Value : Single ) ;
    function GetMarkerText( i : Integer ) : String ;
    procedure SetMarkerText( i : Integer ; Value : String ) ;
    function GetADCChannel( i : Integer ) : TChannel ;
    function GetROI( i : Integer ) : TROI ;

    procedure SetADCChannel( i : Integer ; Value : TChannel ) ;
    procedure SetROI( i : Integer ; Value : TROI ) ;
    procedure SetEquation( i : Integer ; Value : TBindingEquation ) ;

    procedure SetPixelDepth( Value : Integer ) ;
    procedure SetFrameWidth( Value : Integer ) ;
    procedure SetFrameHeight( Value : Integer ) ;
    procedure SetADCVoltageRange( Value : Single ) ;
    procedure SetADCNumChannels( Value : Integer ) ;
    procedure ComputeFrameSize ;

    procedure SetFrameType( i : Integer ; Value : String ) ;
    procedure SetFrameTypeDivideFactor( i : Integer ; Value : Integer ) ;
    procedure SetWriteEnabled( Value : Boolean ) ;

    function IDRFileCreate( FileName : String ) : Boolean ;
    function IDRFileOpen( FileName : String ; FileMode : Integer ) : Boolean ;
    function IDRFileWrite(
             pDataBuf : Pointer ;
             FileOffset : Int64 ;
             NumBytesToWrite : Integer
             ) : Integer ;
    function IDRAsyncFileWrite(
             pDataBuf : Pointer ;
             FileOffset : Int64 ;
             NumBytesToWrite : Integer
             ) : Integer ;

    function GetAsyncWriteInProgress : Boolean ;

    function IDRFileRead(
             pDataBuf : Pointer ;
             FileOffset : Int64 ;
             NumBytesToRead : Integer
             ) : Integer ;

    function IDRGetFileSize : Int64 ;
    procedure IDRFileClose;

    function IsIDRFileOpen : Boolean ;

    function GetNumFramesPerSpectrum : Integer ;
    function GetNumFrameTypes : Integer ;
    procedure SetNumFrameTypes( Value : Integer ) ;

    function GetFileHeader : string ;

    function GetMaxROIInUse : Integer ;

    procedure StringListToFile(
          FileName : string ;        // File name
          FileHandle : THandle ;     // File Handle
          List : TStringList ;       // StringList to be written
          FileOffset : NativeInt ;   // Starting offset in file
          NumBytes : Integer ) ;     // Bytes to be written


  protected
    { Protected declarations }
  public
    { Public declarations }
    Constructor Create(AOwner : TComponent) ; override ;
    Destructor Destroy ; override ;

    function CreateNewFile(
             FileName : String
             ) : Boolean ;
    function CreateFileFrom(
             FileName : String ;
             Source : TIDRFile ;
             CopyADCSamples : Boolean
             ) : Boolean ;
    function OpenFile( FileName : String ) : Boolean ;
    procedure CloseFile ;

    function LoadFrame( FrameNum : Integer ; FrameBuf : Pointer ) : Boolean ;
    function SaveFrame( FrameNum : Integer ; FrameBuf : Pointer ) : Boolean ;
    function LoadFrame32( FrameNum : Integer ; FrameBuf32 : PIntArray ) : Boolean ;
    function SaveFrame32( FrameNum : Integer ; FrameBuf32 : PIntArray ) : Boolean ;
    function AsyncSaveFrames( FrameNum : Integer ; NumFrames : Integer ; FrameBuf : Pointer ) : Boolean ;

    procedure UpdateNumFrames ;
    function DiskSpaceAvailable( NumFrames : Integer ) : Boolean ;

    function LoadADC(
             StartScan : Int64 ;
             NumScans : Integer ;
             var ADCBuf : Array of SmallInt
             ) : Integer ;

    function SaveADC(
             StartScan : Int64 ;
             NumScans : Integer ;
             var ADCBuf : Array of SmallInt
             ) : Integer ;


    procedure UpdateChannelScalingFactors(
              var Channels : Array of TChannel ;
              NumChannels : Integer ;
              ADCVoltageRange : Single ;
              ADCMaxValue : Integer ) ;

    function AddMarker( Time : Single ; Text : String ) : Boolean ;

   procedure CreateFramePointerList(
             var FrameList : PIntArray  ) ;

   function TypeOfFrame( FrameNum : Integer ) : Integer ;

   procedure CreateFrameTypeCycle(
          var FrameTypeCycle : Array of Integer ;
          var FrameTypeCycleLength : Integer ) ;


    property FrameType[ i : Integer ] : String
             read GetFrameType write SetFrameType ;

    property FrameTypeDivideFactor[ i : Integer ] : Integer
             read GetFrameTypeDivideFactor write SetFrameTypeDivideFactor ;

    property ADCChannel[ i : Integer ] : TChannel
             read GetADCChannel write SetADCChannel ;

    property ROI[ i : Integer ] : TROI
             read GetROI write SetROI ;

    property Equation[ i : Integer ] : TBindingEquation
             read GetEquation write SetEquation ;

    property MarkerTime[ i : Integer ] : Single read GetMarkerTime write SetMarkerTime ;
    property MarkerText[ i : Integer ] : String read GetMarkerText write SetMarkerText;

  published
    { Published declarations }
    Property FileName : String Read FFileName ;
    Property Open : Boolean Read IsIDRFileOpen ;
    Property EDRFileHandle : THandle Read FEDRFileHandle ;
    Property AsyncBufferOverflow : Boolean read FAsyncBufferOverflow ;
    Property Ident : String Read FIdent Write FIdent ;
    Property NumFrames : Integer read FNumFrames write FNumFrames ; //
    Property NumFrameTypes : Integer
             read GetNumFrameTypes write SetNumFrameTypes ;     // No. of types of frame


    Property FrameWidth : Integer read FFrameWidth write FFrameWidth;   // Image frame width (pixels)
    Property FrameHeight : Integer read FFrameHeight write FFrameHeight; // Image frame height (pixels)
    Property PixelDepth : Integer read FPixelDepth write SetPixelDepth ;   // No. of bits per pixel
    Property FrameInterval : Single read FFrameInterval write FFrameInterval;      // Frame capture interval (s)

    Property NumZSections : Integer read FNumZSections write FNumZSections ;
    Property ZSpacing : Single read FZSpacing write FZSpacing ;
    Property ZStart : Single read FZStart write FZStart ;

    Property NumBytesPerFrame : Integer read FNumBytesPerFrame ;  // No. bytes per frame
    Property NumPixelsPerFrame : Integer read FNumPixelsPerFrame ; // No. of pixels per frame
    Property NumBytesPerPixel : Integer read FNumBytesPerPixel ;  // No. of bytes per image pixel
    Property GreyMax : Integer read FGreyMax ;            // Maximum grey level
    Property IntensityScale : Single Read FIntensityScale Write FIntensityScale ;
    Property IntensityOffset : Single Read FIntensityOffset Write FIntensityOffset ;
    Property XResolution : Single read FXResolution write FXResolution ;  // Pixel width
    Property ResolutionUnits : String read FResolutionUnits write FResolutionUnits ;     // Pixel width measurement units
    Property NumIDRHeaderBytes : Integer Read FNumIDRHeaderBytes ;
    Property NumEDRHeaderBytes : Integer Read FNumEDRHeaderBytes ;

    Property ADCNumScansInFile : Int64 Read FADCNumScansInFile Write FADCNumScansInFile ;  // No. of A/D multi-channel scans in file
    Property ADCNumChannels : Integer Read FADCNumChannels Write SetADCNumChannels ;
    Property ADCNumScansPerFrame : Integer Read FADCNumScansPerFrame write FADCNumScansPerFrame ;
    Property ADCMaxValue : Integer Read FADCMaxValue Write FADCMaxValue ;
    Property ADCSCanInterval : Single Read FADCSCanInterval Write FADCSCanInterval ;
    Property ADCVoltageRange : Single Read FADCVoltageRange Write SetADCVoltageRange ;
    Property ADCMaxChannels : Integer Read FADCMaxChannels ;
    Property MaxROI : Integer read FMaxROI ;
    Property MaxROIInUse : Integer read GetMaxROIInUse ;
    Property MaxEquations : Integer read FMaxEquations ;

    Property NumMarkers : Integer Read FNumMarkers ;
    Property LineScan : Boolean Read FLineScan Write FLineScan ;
    Property LSTimeCoursePixel : Integer read FLSTimeCoursePixel write FLSTimeCoursePixel ;
    Property LSTimeCourseNumAvg : Integer read FLSTimeCourseNumAvg write FLSTimeCourseNumAvg;
    Property LSTimeCourseBackgroundPixel : Integer  read FLSTimeCourseBackgroundPixel write FLSTimeCourseBackgroundPixel;
    Property LSSubtractBackground : Boolean read FLSSubtractBackground write FLSSubtractBackground;
    Property ImageStartDelay : Single
             read FImageStartDelay
             write FImageStartDelay ;
    Property LineScanIntervalCorrectionFactor : Single
             read FLineScanIntervalCorrectionFactor
             write FLineScanIntervalCorrectionFactor ;

    Property Year : Integer read FYearCreated ;
    Property Month : Integer read FMonthCreated ;
    Property Day : Integer read FDayCreated ;
    Property Hour : Integer read FHourCreated ;
    Property Minute : Integer read FMinuteCreated ;
    Property Second : Integer read FSecondCreated ;

    Property WriteEnabled : Boolean read FWriteEnabled write SetWriteEnabled ;
    Property SpectralDataFile : Boolean read FSpectralDataFile
                                        write FSpectralDataFile ;
    Property SpectrumStartWavelength : Single read FSpectrumStartWavelength
                                              write FSpectrumStartWavelength ;
    Property SpectrumEndWavelength : Single read FSpectrumEndWavelength
                                            write FSpectrumEndWavelength ;
    Property SpectrumBandwidth : Single read FSpectrumBandwidth
                                              write FSpectrumBandwidth ;
    Property SpectrumStepSize : Single read FSpectrumStepSize
                                              write FSpectrumStepSize ;
    Property NumFramesPerSpectrum : Integer read GetNumFramesPerSpectrum ;

    Property EventDisplayDuration : Single
             read FEventDisplayDuration write FEventDisplayDuration ;
    Property EventDeadTime : Single
             read FEventDeadTime write FEventDeadTime ;
    Property EventDetectionThreshold : Single
             read FEventDetectionThreshold write FEventDetectionThreshold ;
    Property EventThresholdDuration : Single
             read FEventThresholdDuration write FEventThresholdDuration ;
    Property EventDetectionThresholdPolarity : Integer
             read FEventDetectionThresholdPolarity write FEventDetectionThresholdPolarity ;
    Property EventDetectionSource : Integer
             read FEventDetectionSource write FEventDetectionSource ;
    Property EventROI : Integer
             read FEventROI write FEventROI ;
    Property EventBackgROI : Integer
             read FEventBackgROI write FEventBackgROI ;
    Property EventFixedBaseline : Boolean
             read FEventFixedBaseline write FEventFixedBaseline ;
    Property EventRollingBaselinePeriod : Single
             read FEventRollingBaselinePeriod write FEventRollingBaselinePeriod ;
    Property EventBaselineLevel : Integer
             read FEventBaselineLevel write FEventBaselineLevel ;
    Property EventRatioExclusionThreshold : Integer
             read FEventRatioExclusionThreshold write FEventRatioExclusionThreshold;
    Property EventRatioTop : Integer
             read FEventRatioTop write FEventRatioTop ;
    Property EventRatioBottom : Integer
             read FEventRatioBottom write FEventRatioBottom ;
    Property EventRatioDisplayMax : Single
             read FEventRatioDisplayMax write  FEventRatioDisplayMax ;
    Property EventRatioRMax : Single
             read FEventRatioRMax write FEventRatioRMax ;
    Property EventFLWave : Integer
             read FEventFLWave write FEventFLWave ;
    Property EventF0Wave : Integer 
             read FEventF0Wave write FEventF0Wave ;
    Property EventF0Start : Integer
             read FEventF0Start write FEventF0Start ;
    Property EventF0End : Integer
             read FEventF0End write FEventF0End ;
    Property EventF0Constant : Single
             read FEventF0Constant write FEventF0Constant ;
    Property EventF0UseConstant : Boolean
             read FEventF0UseConstant write FEventF0UseConstant ;
    Property EventF0DisplayMax : Single
             read FEventF0DisplayMax write FEventF0DisplayMax ;
    Property EventF0SubtractF0 : Boolean
             read FEventF0SubtractF0 write FEventF0SubtractF0 ;

    Property FrameTypeCycleLength : Integer read FFrameTypeCycleLength ;

    Property FileHeader : string read GetFileHeader ;
    Property AsyncWriteInProgress : Boolean read GetAsyncWriteInProgress ;

  end;

procedure Register;

implementation


constructor TIDRFile.Create(AOwner : TComponent) ;
{ --------------------------------------------------
  Initialise component's internal objects and fields
  -------------------------------------------------- }
var
     i : Integer ;
begin

     inherited Create(AOwner) ;

     FIDRFileHandle := INVALID_HANDLE_VALUE ;
     FEDRFileHandle := INVALID_HANDLE_VALUE ;

     FNumIDRHeaderBytes :=  cNumIDRHeaderBytes ;
     FNumEDRHeaderBytes :=  cNumEDRHeaderBytes ;

     FFileName := '' ;
     FFileOpen := False ;

     FFrameWidth := 0 ;
     FFrameHeight := 0 ;
     FPixelDepth := 0 ;
     FNumFrames := 0 ;
     FLineScan := False ;
     FLSTimeCoursePixel := 0 ;
     FLSTimeCourseNumAvg := 1 ;
     FLSTimeCourseBackgroundPixel := 0 ;
     FLSSubtractBackground := False ;

     FImageStartDelay := 0.0 ;

     // Image intensity measurement scaling
     FIntensityScale := 1.0 ;
     FIntensityOffset := 0.0 ;

     FResolutionUnits := '' ;
     FXResolution := 1.0 ;
     FYResolution := 1.0 ;

    FNumZSections := 1 ;
    FZStart :=0.0 ;
    FZSpacing := 1.0 ;

     FMaxROI := cMaxROIs ;

     FIdent := '' ;

     // Clear marker list
     FNumMarkers := 0 ;

     // Frame type
     FNumFrameTypes := 1 ;
     for i := 0 to High(FFrameTypes) do begin
         FFrameTypes[i] := format('Fr.%d',[i]) ;
         FFrameTypeDivideFactor[i] := 1 ;
         end ;

     for i := 0 to High(FFrameTypeCycle) do FFrameTypeCycle[i] := 0 ;
     FFrameTypeCycleLength := 1 ;

     // Binding equations
     FMaxEquations := High(FEquations) + 1 ;
     for i := 0 to High(FEquations) do begin
         FEquations[i].InUse := False ;
         FEquations[i].Name := format('Eqn.%d',[i]) ;
         FEquations[i].Ion := '??' ;
         FEquations[i].Units := 'nM' ;
         FEquations[i].RMin := 1.0 ;
         FEquations[i].RMax := 2.0 ;
         FEquations[i].KEff := 1E-6 ;
         end ;

     // Analogue signal channels
     FADCMaxChannels := High(Channels) + 1 ;
     for i := 0 to High(Channels) do begin
         Channels[i].ADCZero := 0 ;
         Channels[i].ADCZeroAt := 0 ;
         Channels[i].ADCSCale := 1.0 ;
         Channels[i].ADCCalibrationFactor := 1.0 ;
         Channels[i].ADCAmplifierGain := 1.0 ;
         Channels[i].ADCUnits := 'mV' ;
         Channels[i].ADCName := format('Ch.%d',[i]) ;
         Channels[i].InUse := True ;
         Channels[i].ChannelOffset := i ;
         end ;

    // Flag indicates that no file with A/D samples has been opened
    NoPreviousOpenFile := True ;

    // Regions of interest
    for i := 0 to High(FROIs) do begin
        FROIs[i].InUse := False ;
        FROIs[i].Shape := PointROI ;
        FROIs[i].TopLeft := Point(0,0) ;
        FROIs[i].BottomRight := Point(0,0) ;
        FROIs[i].Centre := Point(0,0) ;
        FROIs[i].Width := 0 ;
        FROIs[i].Height := 0 ;
        FROIs[i].ZoomFactor := 0 ;
        FROIs[i].NumPoints := 0 ;
        end ;

     // Initial spectrum data
     FSpectralDataFile := False ;
     FSpectrumStartWavelength := 0.0 ;
     FSpectrumEndWavelength := 0.0 ;
     FSpectrumBandwidth := 0.0 ;
     FSpectrumStepSize := 0.0 ;

     FEventDisplayDuration := 1.0 ;

    FEventRatioExclusionThreshold := 0 ;
    FEventDeadTime := 1.0 ;
    FEventDetectionThreshold := 1000 ;
    FEventThresholdDuration := 0.0 ;
    FEventDetectionThresholdPolarity := 0  ;
    FEventDetectionSource := 0 ;
    FEventROI := 0 ;
    FEventBackgROI := 0 ;

    FEventFixedBaseline := True ;
    FEventRollingBaselinePeriod := 1.0 ;
    FEventBaselineLevel := 0 ;

    FEventRatioTop := 0 ;
    FEventRatioBottom := 1 ;
    FEventRatioDisplayMax := 10.0 ;
    FEventRatioRMax := 1.0 ; ;
    FEventFLWave := 0 ;
    FEventF0Wave := 0 ;
    FEventF0Start := 1 ;
    FEventF0End := 1 ;
    FEventF0Constant := 0.0 ;
    FEventF0UseConstant := False ;
    FEventF0DisplayMax := 10.0 ;
    FEventF0SubtractF0 := False  ;

     FAsyncBufferOverflow := False ;
     AsyncNumBytesToWrite := 0 ;

     // Create internal frame buffer
     GetMem( PInternalBuf, MaxBytesPerFrame ) ;

     IDRFileHeaderText := '' ;

     end ;


destructor TIDRFile.Destroy ;
{ ------------------------------------
   Tidy up when component is destroyed
   ----------------------------------- }
begin

     // Close image file
     CloseFile ;

     // Free internal buffer
     FreeMem(PInternalBuf) ;

     { Call inherited destructor }
     inherited Destroy ;

     end ;


function TIDRFile.CreateNewFile(
         FileName : String        // Name of file to be created
          ) : Boolean ;           // Returns TRUE if file created OK
// ---------------------------
// Create empty IDR data file
// ---------------------------
var
    EDRFileName : String ;
    FilePath : String ;
    CurrentDate : TDateTime ;
begin

    Result := False ;
    FFileOpen := Result ;

    if FIDRFileHandle <> INVALID_HANDLE_VALUE then begin
       ShowMessage( 'A file is aready open ' ) ;
       Exit ;
       end ;

    // Create directory for file (if one does not exist already)

    FilePath := ExtractFilePath(FileName) ;
    if not DirectoryExists(FilePath) then begin
       if not CreateDir(FilePath) then begin
          ShowMessage( 'Unable to create folder ' + FilePath ) ;
          Exit ;
          end
       else begin
          ShowMessage( 'Folder ' + FilePath + ' created!' ) ;
          end ;
       end ;

    // Create IDR file
    FFileName := FileName ;
    IDRFileCreate(FileName) ;

    if FIDRFileHandle = INVALID_HANDLE_VALUE then begin
       ShowMessage( 'Unable to create ' ) ;
       FFileOpen := False ;
       Exit ;
       end ;

    FWriteEnabled := True ;

    // Create EDR file
    EDRFileName :=  ChangeFileExt( FFileName, '.EDR' ) ;
    FEDRFileHandle := FileCreate( EDRFileName, fmOpenReadWrite ) ;
    if FEDRFileHandle = INVALID_HANDLE_VALUE then begin
       ShowMessage( 'Unable to create ' + EDRFileName ) ;
       Exit ;
       end ;

    // Set file header size to current default size
    FNumIDRHeaderBytes := cNumIDRHeaderBytes ;
    FNumEDRHeaderBytes := cNumEDRHeaderBytes ;
    FMaxROI := cMaxROIs ;

    // Compute size of frame
    ComputeFrameSize ;

    // Image intensity measurement scaling
    FIntensityScale := 1.0 ;
    FIntensityOffset := 0.0 ;

    FNumFrames := 0 ;
    FADCNumSamplesInFile := 0 ;
    FADCNumScansInFile := 0 ;
    FNumMarkers := 0 ;
    FIdent := '' ;

    // Date of creation
    CurrentDate := FileDateToDateTime(FileGetDate(FIDRFileHandle)) ;
    FYearCreated := YearOf(CurrentDate) ;
    FMonthCreated := MonthOfTheYear(CurrentDate) ;
    FDayCreated := DayofTheMonth(CurrentDate) ;
    FHourCreated := HouroftheDay(CurrentDate) ;
    FMinuteCreated := MinuteoftheHour(CurrentDate) ;
    FSecondCreated := SecondoftheMinute(CurrentDate) ;

    Result := True ;
    FFileOpen := Result ;
    end ;


function TIDRFile.CreateFileFrom(
         FileName : String ;      // Name of file to be created
         Source : TIDRFile ;      // Source IDR file
         CopyADCSamples : Boolean
          ) : Boolean ;           // Returns TRUE if file created OK
// ---------------------------
// Create empty IDR data file
// ---------------------------
var
    i : Integer ;
    EDRFileName : String ;
    ADCBuf : Array[0..MaxChannel] of SmallInt ;
    CurrentDate : TDateTime ;
begin

    Result := False ;
    FFileOpen := Result ;

    if FIDRFileHandle <> INVALID_HANDLE_VALUE then begin
       ShowMessage( 'Unable to create: ' + FileName + 'Another file is aready open!' ) ;
       Exit ;
       end ;

    // Open file
    FFileName := FileName ;
    IDRFileCreate( FFileName ) ;
    if FIDRFileHandle = INVALID_HANDLE_VALUE then begin
       ShowMessage( 'TIDRFile: Unable to create ' + FFileName ) ;
       Exit ;
       end ;

    // Indicate that file can be written to
    FWriteEnabled := True ;

    // Date of creation
    CurrentDate := FileDateToDateTime(FileGetDate(FIDRFileHandle)) ;
    FYearCreated := YearOf(CurrentDate) ;
    FMonthCreated := MonthOfTheYear(CurrentDate) ;
    FDayCreated := DayofTheMonth(CurrentDate) ;
    FHourCreated := HouroftheDay(CurrentDate) ;
    FMinuteCreated := MinuteoftheHour(CurrentDate) ;
    FSecondCreated := SecondoftheMinute(CurrentDate) ;

    // Initialise file header`
    FFrameWidth := Source.FrameWidth ;
    FFrameHeight := Source.FrameHeight ;
    FPixelDepth := Source.PixelDepth ;
    FFrameInterval := Source.FrameInterval ;
    FIntensityScale := Source.IntensityScale ;
    FIntensityOffset := Source.IntensityOffset ;
    FXResolution := Source.XResolution ;
    FResolutionUnits := Source.ResolutionUnits ;

    FNumZSections := Source.NumZSections ;
    FZStart := Source.ZStart ;
    FZSpacing := Source.ZSpacing ;

    // Set file header size to current default size
    FNumIDRHeaderBytes := cNumIDRHeaderBytes ;
    FNumEDRHeaderBytes := cNumEDRHeaderBytes ;
    FMaxROI := cMaxROIs ;

    // Compute size of frame
    ComputeFrameSize ;

    // Frame type
    FNumFrameTypes := Source.NumFrameTypes ;
    for i := 0 to FNumFrameTypes-1 do begin
        FFrameTypes[i] := Source.FrameType[i] ;
        FFrameTypeDivideFactor[i] := Source.FrameTypeDivideFactor[i] ;
        end ;

     // Create frame type cycle
     CreateFrameTypeCycle( FFrameTypeCycle, FFrameTypeCycleLength ) ;

     // Binding equations
    for i := 0 to High(FEquations) do FEquations[i] := Source.Equation[i] ;

    // Marker list
    FNumMarkers := Source.NumMarkers ;
    for i := 0 to Source.NumMarkers-1 do begin
         FMarkerTime[i] := Source.MarkerTime[i] ;
         FMarkerText[i] := Source.MarkerText[i] ;
         end ;

    // Analogue signal channels

    FADCNumChannels := Source.ADCNumChannels ;
    FADCNumScansPerFrame := Source.ADCNumScansPerFrame ;
    FADCNumScansInFile := Source.ADCNumScansInFile ;
    FADCMaxValue := Source.ADCMaxValue ;
    FADCSCanInterval := Source.ADCSCanInterval ;
    FADCVoltageRange := Source.ADCVoltageRange ;
    for i := 0 to FADCNumChannels-1 do Channels[i] := Source.ADCChannel[i] ;

    FSpectralDataFile := Source.SpectralDataFile ;
    FSpectrumStartWavelength := Source.SpectrumStartWavelength  ;
    FSpectrumEndWavelength := Source.SpectrumEndWavelength ;
    FSpectrumBandwidth := Source.SpectrumBandwidth ;
    FSpectrumStepSize := Source.SpectrumStepSize ;

    FEventDisplayDuration := Source.EventDisplayDuration ;
    FEventRatioExclusionThreshold := Source.EventRatioExclusionThreshold ;
    FEventDeadTime := Source.EventDeadTime ;
    FEventDetectionThreshold := Source.EventDetectionThreshold  ;
    FEventThresholdDuration := Source.EventThresholdDuration ;
    FEventDetectionThresholdPolarity := Source.EventDetectionThresholdPolarity  ;
    FEventDetectionSource := Source.EventDetectionSource ;
    FEventROI := Source.EventROI ;
    FEventBackgROI := Source.EventBackgROI ;

    FEventFixedBaseline := Source.EventFixedBaseline ;
    FEventBaselineLevel := Source.EventBaselineLevel ;
    FEventRollingBaselinePeriod := Source.EventRollingBaselinePeriod ;

    FEventRatioExclusionThreshold := Source.EventRatioExclusionThreshold ;
    FEventRatioTop  := Source.EventRatioTop ;
    FEventRatioBottom  := Source.EventRatioBottom ;
    FEventRatioDisplayMax  := Source.EventRatioDisplayMax ;
    FEventRatioRMax  := Source.EventRatioRMax ;
    FEventFLWave  := Source.EventFLWave ;
    FEventF0Wave  := Source.EventF0Wave ;
    FEventF0Start  := Source.EventF0Start ;
    FEventF0End  := Source.EventF0End ;
    FEventF0Constant  := Source.EventF0Constant ;
    FEventF0UseConstant  := Source.EventF0UseConstant ;
    FEventF0DisplayMax  := Source.EventF0DisplayMax ;
    FEventF0SubtractF0  := Source.EventF0SubtractF0  ;

    // Create EDR file
    EDRFileName :=  ChangeFileExt( FFileName, '.EDR' ) ;
    FEDRFileHandle := FileCreate( EDRFileName, fmOpenReadWrite ) ;
    if FEDRFileHandle = INVALID_HANDLE_VALUE then begin
       ShowMessage( 'Unable to create A/D data file: ' + EDRFileName ) ;
       Exit ;
       end ;

    if CopyADCSamples then begin
       // Copy A/D samples into EDR file
       if FADCNumScansInFile > 0 then begin
          // Move to end of header block
          FileSeek( Source.EDRFileHandle,FNumEDRHeaderBytes,0) ;
          FileSeek( FEDRFileHandle,FNumEDRHeaderBytes,0) ;
          for i := 1 to Source.ADCNumScansInFile do begin
              FileRead( Source.EDRFileHandle, ADCBuf, FADCNumChannels*2 ) ;
              FileWrite( FEDRFileHandle, ADCBuf, FADCNumChannels*2 ) ;
              end ;
          end ;
       end
    else begin
       FADCNumScansInFile := 0 ;
       end ;

    // Regions of interest
    for i := 0 to High(FROIs) do FROIs[i] := Source.ROI[i] ;

    FNumFrames := 0 ;
    Result := True ;
    FFileOpen := Result ;

    end ;



function TIDRFile.OpenFile(
         FileName : String     // Name of IDR file (IN)
          ) : Boolean ;        // Returns TRUE if file open successful
// ---------------------------
// Open image file (READ ONLY)
// ---------------------------
var
     EDRFileName : String ;
     ch : Integer ;
begin

     Result := False ;

     if FIDRFileHandle <> INVALID_HANDLE_VALUE then begin
       ShowMessage( 'A file is aready open ' ) ;
       Exit ;
       end ;

     // Open IDR file (READ ONLY)
     FFileName := FileName ;
     IDRFileOpen( FFileName, fmOpenRead ) ;
     if FIDRFileHandle = INVALID_HANDLE_VALUE then begin
        ShowMessage( 'Unable to open ' + FileName ) ;
        Exit ;
        end ;
     FWriteEnabled := False ;

     // Load file header data
     GetIDRHeader ;

     // Create frame type cycle
     CreateFrameTypeCycle( FFrameTypeCycle, FFrameTypeCycleLength ) ;

     if FIntensityScale = 1.0 then FIntensityOffset := 0.0 ;

     // Open EDR file
     EDRFileName :=  ChangeFileExt( FFileName, '.EDR' ) ;
     if FileExists( EDRFileName ) then begin
        FEDRFileHandle := FileOpen( EDRFileName, fmOpenRead ) ;
        if FEDRFileHandle <> INVALID_HANDLE_VALUE then begin
          if (FADCNumChannels <= 0) or (FADCNumScansInFile <= 0) then GetEDRHeader ;
          FADCNumSamplesInFile := FADCNumScansInFile*FADCNumChannels ;
          if NoPreviousOpenFile then begin
             for ch := 0 to MaxChannel do begin
                 Channels[ch].YMax := FADCMaxValue ;
                 Channels[ch].YMin := -FADCMaxValue - 1;
                 end ;
             NoPreviousOpenFile := False ;
             end ;
          end
        else begin
          FADCNumChannels := 0 ;
          end ;
        end
     else begin
        FADCNumChannels := 0 ;
        end ;

     Result := True ;
     FFileOpen := Result ;
     end ;


procedure TIDRFile.CloseFile ;
{ -----------------
   Close IDR file
   ---------------- }
begin

     // Close image file
     if FIDRFileHandle <> INVALID_HANDLE_VALUE then begin
        SaveIDRHeader ;
        IDRFileClose ;
        FIDRFileHandle := INVALID_HANDLE_VALUE ;
        end ;

     if FEDRFileHandle <> INVALID_HANDLE_VALUE then begin
        SaveEDRHeader ;
        FileClose( FEDRFileHandle ) ;
        FEDRFileHandle := INVALID_HANDLE_VALUE ;
        end ;

     FFileOpen := False  ;

     end ;


function TIDRFile.IsIDRFileOpen : Boolean ;
// -------------------------------
// Return TRUE if IDR file is open
// -------------------------------
begin
    if FIDRFileHandle <> INVALID_HANDLE_VALUE then Result := True
                                              else Result := False ;
    end ;

function TIDRFile.GetNumFramesPerSpectrum : Integer ;
// --------------------------
// No. of frames per spectrum
// --------------------------
begin
    if FSpectrumStepSize > 0.0 then begin
       Result := Max(Round(
                 (FSpectrumEndWavelength - FSpectrumStartWavelength) /
                  FSpectrumStepSize)+1,
                  1) ;
       end
    else Result := 1 ;

    end ;


function TIDRFile.GetNumFrameTypes : Integer ;
// ----------------------------
// Return number of frame types
// ----------------------------
begin
     if FSpectralDataFile then Result := GetNumFramesPerSpectrum
                          else Result := FNumFrameTypes ;
     end ;

procedure TIDRFile.SetNumFrameTypes( Value : Integer ) ;
// -------------------------
// Set number of frame types
// -------------------------
begin

    FNumFrameTypes := Value ;

    // Create frame type cycle
     CreateFrameTypeCycle( FFrameTypeCycle, FFrameTypeCycleLength ) ;

    end ;

procedure TIDRFile.GetIDRHeader ;
// ------------------------
// Load IDR data file header
// ------------------------
var

   i,j,ch : Integer ;
   iValue : Integer ;
   NumFrameActual : Integer ;
   NumBytesPerFrame : Integer ;
   NumBytesInFile : Int64 ;
   Header : TStringList ;
   pANSIBuf : PANSIChar ;
   ANSIHeader : ANSIString ;

begin

     // Create header parameter list
     Header := TStringList.Create ;

     // Read ANSI text from file header and load into Header StringList
     pANSIBuf := AllocMem( cNumIDRHeaderBytes ) ;
     IDRFileRead( pANSIBuf, 0, cNumIDRHeaderBytes ) ;
     pANSIBuf[cNumIDRHeaderBytes-1] := #0 ;
     ANSIHeader := ANSIString( pANSIBuf ) ;
     Header.Text := String(ANSIHeader) ;

     { Get default size of file header }
     FNumIDRHeaderBytes := cNumIDRHeaderBytes ;
     { Get size of file header for this file }
     FNumIDRHeaderBytes := GetKeyValue( Header, 'NBH', FNumIDRHeaderBytes ) ;

     // File creation date

     FYearCreated := 0 ;
     FMonthCreated := 0 ;
     FDayCreated := 0 ;
     FYearCreated := GetKeyValue( Header, 'YEAR', FYearCreated ) ;
     FMonthCreated := GetKeyValue( Header, 'MONTH', FMonthCreated ) ;
     FDayCreated := GetKeyValue( Header, 'DAY', FDayCreated ) ;
     FHourCreated := GetKeyValue( Header, 'HOUR', FHourCreated ) ;
     FMinuteCreated := GetKeyValue( Header, 'MINUTE', FMinuteCreated ) ;
     FSecondCreated := GetKeyValue( Header, 'SECOND', FSecondCreated ) ;

     // Frame parameters
     FFrameInterval := GetKeyValue( Header, 'FI', FFrameInterval ) ;

     FFrameWidth := GetKeyValue( Header, 'FW', FFrameWidth ) ;

     FFrameHeight := GetKeyValue( Header, 'FH', FFrameHeight ) ;

     FNumBytesPerPixel := 2 ;
     FNumBytesPerPixel  := GetKeyValue( Header, 'NBPP', FNumBytesPerPixel ) ;

     FNumFrames := GetKeyValue( Header, 'NF', FNumFrames ) ;


     FNumZSections := GetKeyValue(Header, 'ZNUMS',FNumZSections) ;
     FNumZSections := Max(FNumZSections,1) ;
     FZStart := GetKeyValue( Header, 'ZSTART',FZStart) ;
     FZSpacing := GetKeyValue( Header, 'ZSPACING',FZSpacing) ;

     // Correct number of frames list in file header
     NumBytesPerFrame := FFrameHeight*FFrameWidth*FNumBytesPerPixel ;
     FNumBytesPerFrame := NumBytesPerFrame ;
     // Prevent divide by zero exception
     if NumBytesPerFrame > 0 then begin
        NumBytesInFile := IDRGetFileSize ;
        NumFrameActual := Integer( (NumBytesInFile - Int64(FNumIDRHeaderBytes))
                                   div Int64(NumBytesPerFrame) ) ;
//        outputdebugstring(pchar(format('Numbytesinfile=%d,NumFramesActual=%d,NumFrames=%d'
//        ,[NumBytesInFile,NumFrameActual,FNumFrames])));
        end;

     // Line scan flag
     FLineScan := GetKeyValue( Header, 'LINESCAN', FLineScan ) ;
     // Line scan interval correction factor
     FImageStartDelay := 0.0 ;
     FImageStartDelay := GetKeyValue( Header, 'IMGDELAY', FImageStartDelay ) ;

     FLSTimeCoursePixel := GetKeyValue( Header, 'LSTCPIX',FLSTimeCoursePixel);               // 5.8.10 JD
     FLSTimeCourseNumAvg := GetKeyValue( Header, 'LSTCNAVG',FLSTimeCourseNumAvg);
     FLSTimeCourseBackgroundPixel := GetKeyValue( Header, 'LSTCBKPIX',FLSTimeCourseBackgroundPixel);
     FLSSubtractBackground := GetKeyValue( Header, 'LSTCBKSUB',FLSSubtractBackground) ;

     FGreyMax := GetKeyValue( Header, 'GRMAX', FGreyMax ) ;
     if FGreyMax = 0 then FGreyMax := 4095 ;

     i := 1 ;
     FPixelDepth := 0 ;
     while i < (FGreyMax+1) do begin
        i := i*2 ;
        Inc(FPixelDepth) ;
        end ;

     FPixelDepth := GetKeyValue( Header, 'PIXDEP', FPixelDepth ) ;

     FIntensityScale := 1.0 ;
     FIntensityScale := GetKeyValue( Header, 'ISCALE', FIntensityScale ) ;
     FIntensityOffset := 0.0 ;
     FIntensityOffset := GetKeyValue( Header, 'IOFFSET', FIntensityOffset ) ;

     // Pixel width
     FXResolution := 1.0 ;
     FXResolution := GetKeyValue( Header, 'XRES', FXResolution ) ;
     if FXResolution = 0.0 then FXResolution := 1.0 ;

     // Pixel width units
     FResolutionUnits := '' ;
     FResolutionUnits := GetKeyValue( Header, 'RESUNITS', FResolutionUnits ) ;

     FNumPixelsPerFrame := FFrameWidth*FFrameHeight ;
     FNumBytesPerFrame := FNumPixelsPerFrame*FNumBytesPerPixel ;

     // Types of frame
     FNumFrameTypes := GetKeyValue( Header, 'NFTYP', FNumFrameTypes ) ;

     for i := 0 to FNumFrameTypes-1 do
         begin
         FFrameTypes[i] := GetKeyValue( Header, format('FTYP%d',[i]),FFrameTypes[i] ) ;
         FFrameTypeDivideFactor[i] := 1 ;
         FFrameTypeDivideFactor[i] := GetKeyValue( Header, format('FTYPDF%d',[i]),FFrameTypeDivideFactor[i] ) ;
         end ;

     if NumFrameTypes <= 0 then begin
        FNumFrameTypes := 1 ;
        FFrameTypes[0] := 'Unknown' ;
        end ;

     // Ensure no. of frame types equal to no. frames for line scans
     if FLineScan and (NumFrameTypes < NumFrames) then
        begin
        NumFrameTypes := NumFrames ;
        for i := 0 to FNumFrameTypes-1 do
            begin
            FFrameTypes[i] := format('Ch.%d',[i+1]) ;
            FFrameTypeDivideFactor[i] := 1 ;
            end ;
        end ;

     // A/D channel settings
     FADCNumChannels := GetKeyValue( Header, 'ADCNC', FADCNumChannels ) ;

     FADCNumScansPerFrame := GetKeyValue( Header, 'ADCNSPF', FADCNumScansPerFrame ) ;
     FADCNumScansInFile := GetKeyValue( Header, 'ADCNSC', FADCNumScansInFile ) ;

     FADCMaxValue := GetKeyValue( Header, 'ADCMAX', FADCMaxValue ) ;
     FADCSCanInterval := GetKeyValue( Header, 'ADCSI', FADCSCanInterval ) ;

     if FADCSCanInterval = 0.0 then
        begin
        if FADCNumScansPerFrame > 0 then
           FADCSCanInterval := FFrameInterval/FADCNumScansPerFrame
        else FADCSCanInterval := 1.0 ;
        FADCSCanInterval := Trunc(FADCSCanInterval/0.0001)*0.0001 ;
        end ;

     FADCVoltageRange := GetKeyValue( Header, 'ADCVR', FADCVoltageRange ) ;
     if Abs(FADCVoltageRange) < 1E-3 then FADCVoltageRange := 10.0 ;
     for ch := 0 to FADCNumChannels-1 do
         begin
         Channels[ch].ChannelOffset := GetKeyValue(    Header, format('CIN%d',[ch]), Channels[ch].ChannelOffset) ;
         Channels[ch].ADCUnits := GetKeyValue( Header, format('CU%d',[ch]), Channels[ch].ADCUnits ) ;
         Channels[ch].ADCName := GetKeyValue( Header, format('CN%d',[ch]), Channels[ch].ADCName ) ;
         Channels[ch].ADCCalibrationFactor := GetKeyValue( Header, format('CCF%d',[ch]), Channels[ch].ADCCalibrationFactor ) ;
         Channels[ch].ADCAmplifierGain := GetKeyValue( Header, format('CAG%d',[ch]), Channels[ch].ADCAmplifierGain ) ;
         Channels[ch].ADCScale := GetKeyValue( Header, format('CSC%d',[ch]), Channels[ch].ADCScale) ;
         end ;

     // Update A/D channel scaling factors
     UpdateChannelScalingFactors( Channels,
                                  FADCNumChannels,
                                  FADCVoltageRange,
                                  FADCMaxValue )  ;

     // Fluophore binding equation table
     for i := 0 to High(FEquations) do
         begin
         FEquations[i].InUse := GetKeyValue( Header, format('EQNUSE%d',[i]), FEquations[i].InUse) ;
         FEquations[i].Name := GetKeyValue( Header, format('EQNNAM%d',[i]), FEquations[i].Name) ;
         FEquations[i].Ion := GetKeyValue( Header, format('EQNION%d',[i]), FEquations[i].Ion) ;
         FEquations[i].Units := GetKeyValue( Header, format('EQNUN%d',[i]), FEquations[i].Units) ;
         FEquations[i].RMax := GetKeyValue( Header, format('EQNRMAX%d',[i]), FEquations[i].RMax) ;
         FEquations[i].RMin := GetKeyValue( Header, format('EQNRMIN%d',[i]), FEquations[i].RMin) ;
         FEquations[i].KEff := GetKeyValue( Header, format('EQNKEFF%d',[i]), FEquations[i].KEff) ;
         end ;

     // Regions of Interest

     // Determine space for ROIs in this file
     if FNumIDRHeaderBytes = cNumIDRHeaderBytes then FMaxROI := cMaxROIs
                                                else FMaxROI := 10 ;

     for i := 0 to Min(FMaxROI,cMaxROIsInHeader) do
         begin
         FROIs[i].InUse := False ;
         FROIs[i].InUse := GetKeyValue( Header, format('ROIUSE%d',[i]),FROIs[i].InUse ) ;
         if FROIs[i].InUse then
            begin
            FROIs[i].Shape := GetKeyValue( Header, format('ROISHP%d',[i]), FROIs[i].Shape ) ;
            FROIs[i].TopLeft.x := GetKeyValue( Header, format('ROITLX%d',[i]), FROIs[i].TopLeft.x ) ;
            FROIs[i].TopLeft.y := GetKeyValue( Header, format('ROITLY%d',[i]), FROIs[i].TopLeft.y ) ;
            FROIs[i].BottomRight.x := GetKeyValue( Header, format('ROIBRX%d',[i]), FROIs[i].BottomRight.x ) ;
            FROIs[i].BottomRight.y := GetKeyValue( Header, format('ROIBRY%d',[i]), FROIs[i].BottomRight.y ) ;
            FROIs[i].Centre.x := (FROIs[i].TopLeft.x + FROIs[i].BottomRight.x) div 2 ;
            FROIs[i].Centre.y := (FROIs[i].TopLeft.y + FROIs[i].BottomRight.y) div 2 ;
            FROIs[i].Width := Abs(FROIs[i].BottomRight.x - FROIs[i].TopLeft.x ) ;
            FROIs[i].Height := Abs(FROIs[i].BottomRight.y - FROIs[i].TopLeft.y ) ;
            FROIs[i].NumPoints := GetKeyValue( Header, format('ROINP%d',[i]), FROIs[i].NumPoints ) ;
            for j := 0 to FROIs[i].NumPoints-1 do
                begin
                FROIs[i].XY[j].X := GetKeyValue( Header, format('ROI%dX%d',[i,j]), FROIs[i].XY[j].X ) ;
                FROIs[i].XY[j].Y := GetKeyValue( Header, format('ROI%dY%d',[i,j]), FROIs[i].XY[j].Y ) ;
                end ;
            end ;
         end ;

     // ROIs loaded from external csv file (if it exists)
     LoadROIsFromCSVFile( FileName ) ;

     // Read experiment comment line
     FIdent := '' ;
     FIdent := GetKeyValue( Header, 'ID', FIdent ) ;

     // Spectrum data
     FSpectralDataFile := GetKeyValue( Header, 'SPECDATAFILE',FSpectralDataFile ) ;
     FSpectrumStartWavelength := GetKeyValue( Header, 'SPECSTARTW',FSpectrumStartWavelength)  ;
     FSpectrumEndWavelength := GetKeyValue( Header, 'SPECENDW',FSpectrumEndWavelength) ;
     FSpectrumBandwidth := GetKeyValue( Header, 'SPECBW',FSpectrumBandwidth) ;
     FSpectrumStepSize := GetKeyValue( Header, 'SPECSTEP',FSpectrumStepSize) ;

     // Event data
     FEventDisplayDuration := GetKeyValue( Header, 'EVDISPD',FEventDisplayDuration ) ;

     FEventRatioExclusionThreshold := GetKeyValue(Header, 'EVREXCLT',FEventRatioExclusionThreshold) ; // 5.8.10 JD
     FEventDeadTime := GetKeyValue( Header, 'EVDEADT',FEventDeadTime) ;
     FEventDetectionThreshold := GetKeyValue(Header, 'EVTHRESH',FEventDetectionThreshold) ;
     FEventThresholdDuration := GetKeyValue( Header, 'EVTHRDUR',FEventThresholdDuration) ;
     FEventDetectionThresholdPolarity := GetKeyValue(Header, 'EVTHRPOL',FEventDetectionThresholdPolarity)  ;
     FEventDetectionSource := GetKeyValue(Header, 'EVDETSRC',FEventDetectionSource) ;
     FEventROI := GetKeyValue(Header, 'EVROI',FEventROI) ;
     FEventBackgROI := GetKeyValue(Header, 'EVBACKGROI',FEventBackgROI) ;
     FEventFixedBaseline := GetKeyValue(Header,'EVBASEFX',FEventFixedBaseline) ;
     FEventBaselineLevel := GetKeyValue(Header, 'EVBASELEV',FEventBaselineLevel) ;
     FEventRollingBaselinePeriod := GetKeyValue( Header, 'EVBASRL',FEventRollingBaselinePeriod) ;

     FEventRatioTop := GetKeyValue(Header, 'EVRTOP',FEventRatioTop) ;                  // Event detector settings
     FEventRatioBottom := GetKeyValue(Header, 'EVRBOT',FEventRatioBottom) ;
     FEventRatioDisplayMax := GetKeyValue( Header, 'EVRDMAX',FEventRatioDisplayMax) ;
     FEventRatioRMax := GetKeyValue( Header, 'EVRMAX',FEventRatioRMax) ; ;
     FEventFLWave := GetKeyValue(Header, 'EVFLWAVE',FEventFLWave) ;
     FEventF0Wave := GetKeyValue(Header, 'EVF0WAVE',FEventF0Wave) ;
     FEventF0Start := GetKeyValue(Header, 'EVF0STA',FEventF0Start) ;
     FEventF0End := GetKeyValue(Header, 'EVF0END',FEventF0End) ;
     FEventF0Constant := GetKeyValue( Header, 'EVF0CONS',FEventF0Constant) ;
     FEventF0UseConstant := GetKeyValue(Header,'EVF0USEC',FEventF0UseConstant) ;
     FEventF0DisplayMax := GetKeyValue( Header, 'EVF0DMAX',FEventF0DisplayMax) ;
     FEventF0SubtractF0 := GetKeyValue(Header,'EVF0SUBF0',FEventF0SubtractF0)  ;

     { Read Markers }
     FNumMarkers := 0 ;
     FNumMarkers := GetKeyValue( Header, 'MKN', FNumMarkers ) ;
     for i := 0 to FNumMarkers-1 do
         begin
         FMarkerTime[i] := GetKeyValue( Header, format('MKTIM%d',[i]), FMarkerTime[i] ) ;
         FMarkerText[i] := GetKeyValue( Header, format('MKTXT%d',[i]), FMarkerText[i] ) ;
         end ;

     // Save file header text
     IDRFileHeaderText := Header.Text ;

     Header.Free ;

     end ;


procedure TIDRFile.SaveIDRHeader ;
// ------------------------
// Save IDR data file header
// ------------------------
var
   Header : TStringList ;
   pANSIBuf : pANSIChar ;
   i,j,ch : Integer ;
begin

     if FIDRFileHandle = INVALID_HANDLE_VALUE then Exit ;

     if not FWriteEnabled then SetWriteEnabled(True) ;

     // Create empty header string list
     Header := TStringList.Create ;

     // File creation date
     AddKeyValue( Header, 'YEAR', FYearCreated ) ;
     AddKeyValue( Header, 'MONTH', FMonthCreated ) ;
     AddKeyValue( Header, 'DAY', FDayCreated ) ;
     AddKeyValue( Header, 'HOUR', FHourCreated ) ;
     AddKeyValue( Header, 'MINUTE', FMinuteCreated ) ;
     AddKeyValue( Header, 'SECOND', FSecondCreated ) ;

     { Get size of file header for this file }
     AddKeyValue( Header, 'NBH', FNumIDRHeaderBytes ) ;

     // Frame parameters
     AddKeyValue( Header, 'FI', FFrameInterval ) ;
     AddKeyValue( Header, 'FW', FFrameWidth ) ;
     AddKeyValue( Header, 'FH', FFrameHeight ) ;
     AddKeyValue( Header, 'NBPP', FNumBytesPerPixel ) ;
     AddKeyValue( Header, 'PIXDEP', FPixelDepth ) ;

     AddKeyValue(Header, 'ZNUMS',FNumZSections) ;
     AddKeyValue( Header, 'ZSTART',FZStart) ;
     AddKeyValue( Header, 'ZSPACING',FZSpacing) ;

     // Line scan flag
     AddKeyValue( Header, 'LINESCAN', FLineScan ) ;
     AddKeyValue( Header, 'IMGDELAY', FImageStartDelay ) ;

     AddKeyValue( Header, 'LSTCPIX',FLSTimeCoursePixel);               // 5.8.10 JD
     AddKeyValue( Header, 'LSTCNAVG',FLSTimeCourseNumAvg);
     AddKeyValue( Header, 'LSTCBKPIX',FLSTimeCourseBackgroundPixel);
     AddKeyValue( Header, 'LSTCBKSUB',FLSSubtractBackground) ;

     AddKeyValue( Header, 'ISCALE', FIntensityScale ) ;
     AddKeyValue( Header, 'IOFFSET', FIntensityOffset ) ;

     // Get number of frames in file ;
     //FNumFrames := GetNumFramesInFile ;
     AddKeyValue( Header, 'NF', FNumFrames ) ;

     AddKeyValue( Header, 'GRMAX', FGreyMax ) ;

     AddKeyValue( Header, 'XRES', FXResolution ) ;

     AddKeyValue( Header, 'RESUNITS', FResolutionUnits ) ;

     // Types of frame
     AddKeyValue( Header, 'NFTYP', FNumFrameTypes ) ;
     for i := 0 to FNumFrameTypes-1 do begin
         AddKeyValue( Header, format('FTYP%d',[i]),FFrameTypes[i] ) ;
         AddKeyValue( Header, format('FTYPDF%d',[i]),FFrameTypeDivideFactor[i] ) ;
         end ;

     // A/D channel settings
     AddKeyValue( Header, 'ADCNC', FADCNumChannels ) ;
     AddKeyValue( Header, 'ADCNSPF', FADCNumScansPerFrame ) ;
     AddKeyValue( Header, 'ADCNSC', FADCNumScansInFile ) ;
     AddKeyValue( Header, 'ADCMAX', FADCMaxValue ) ;
     AddKeyValue( Header, 'ADCSI', FADCSCanInterval ) ;

     AddKeyValue( Header, 'ADCVR', FADCVoltageRange ) ;
     for ch := 0 to FADCNumChannels-1 do begin
        AddKeyValue(    Header, format('CIN%d',[ch]), Channels[ch].ChannelOffset) ;
        AddKeyValue( Header, format('CU%d',[ch]), Channels[ch].ADCUnits ) ;
        AddKeyValue( Header, format('CN%d',[ch]), Channels[ch].ADCName ) ;
        AddKeyValue( Header, format('CCF%d',[ch]), Channels[ch].ADCCalibrationFactor ) ;
        AddKeyValue( Header, format('CAG%d',[ch]), Channels[ch].ADCAmplifierGain ) ;
        AddKeyValue( Header, format('CSC%d',[ch]), Channels[ch].ADCScale) ;
        end ;

     // Fluophore binding equation table
     for i := 0 to High(FEquations) do begin
         AddKeyValue( Header, format('EQNUSE%d',[i]), FEquations[i].InUse) ;
         AddKeyValue( Header, format('EQNNAM%d',[i]), FEquations[i].Name) ;
         AddKeyValue( Header, format('EQNION%d',[i]), FEquations[i].Ion) ;
         AddKeyValue( Header, format('EQNUN%d',[i]), FEquations[i].Units) ;
         AddKeyValue( Header, format('EQNRMAX%d',[i]), FEquations[i].RMax) ;
         AddKeyValue( Header, format('EQNRMIN%d',[i]), FEquations[i].RMin) ;
         AddKeyValue( Header, format('EQNKEFF%d',[i]), FEquations[i].KEff) ;
         end ;

     // Regions of Interest
     for i := 0 to Min(FMaxROI,cMaxROIsInHeader) do if FROIs[i].InUse then
         begin
         AddKeyValue( Header, format('ROIUSE%d',[i]),FROIs[i].InUse ) ;
         AddKeyValue( Header, format('ROISHP%d',[i]), Integer(FROIs[i].Shape) ) ;
         AddKeyValue( Header, format('ROITLX%d',[i]), FROIs[i].TopLeft.x ) ;
         AddKeyValue( Header, format('ROITLY%d',[i]), FROIs[i].TopLeft.y ) ;
         AddKeyValue( Header, format('ROIBRX%d',[i]), FROIs[i].BottomRight.x ) ;
         AddKeyValue( Header, format('ROIBRY%d',[i]), FROIs[i].BottomRight.y ) ;
         AddKeyValue( Header, format('ROINP%d',[i]), FROIs[i].NumPoints ) ;
         for j := 0 to FROIs[i].NumPoints-1 do
             begin
             AddKeyValue( Header, format('ROI%dX%d',[i,j]), FROIs[i].XY[j].X ) ;
             AddKeyValue( Header, format('ROI%dY%d',[i,j]), FROIs[i].XY[j].Y ) ;
             end ;
         end ;

     // ROIs saved to external csv file
     SaveROIsToCSVFile( FileName ) ;

     // Spectrum data
     AddKeyValue( Header, 'SPECDATAFILE',FSpectralDataFile ) ;
     AddKeyValue( Header, 'SPECSTARTW',FSpectrumStartWavelength)  ;
     AddKeyValue( Header, 'SPECENDW',FSpectrumEndWavelength) ;
     AddKeyValue( Header, 'SPECBW',FSpectrumBandwidth) ;
     AddKeyValue( Header, 'SPECSTEP',FSpectrumStepSize) ;

     // Event data
     AddKeyValue( Header, 'EVDISPD',FEventDisplayDuration ) ;
    AddKeyValue( Header, 'EVDEADT',FEventDeadTime) ;            // 6.8.10 JD
    AddKeyValue(Header, 'EVTHRESH',FEventDetectionThreshold) ;
    AddKeyValue( Header, 'EVTHRDUR',FEventThresholdDuration) ;
    AddKeyValue(Header, 'EVTHRPOL',FEventDetectionThresholdPolarity)  ;
    AddKeyValue(Header, 'EVDETSRC',FEventDetectionSource) ;
    AddKeyValue(Header, 'EVROI',FEventROI) ;
    AddKeyValue(Header, 'EVBACKGROI',FEventBackgROI) ;
    AddKeyValue(Header,'EVBASEFX',FEventFixedBaseline) ;
    AddKeyValue(Header, 'EVBASELEV',FEventBaselineLevel) ;
    AddKeyValue( Header, 'EVBASRL',FEventRollingBaselinePeriod) ;

    AddKeyValue(Header, 'EVREXCLT',FEventRatioExclusionThreshold) ;
    AddKeyValue(Header, 'EVRTOP',FEventRatioTop) ;                  // Event detector settings
    AddKeyValue(Header, 'EVRBOT',FEventRatioBottom) ;
    AddKeyValue( Header, 'EVRDMAX',FEventRatioDisplayMax) ;
    AddKeyValue( Header, 'EVRMAX',FEventRatioRMax) ; ;
    AddKeyValue(Header, 'EVFLWAVE',FEventFLWave) ;
    AddKeyValue(Header, 'EVF0WAVE',FEventF0Wave) ;
    AddKeyValue(Header, 'EVF0STA',FEventF0Start) ;
    AddKeyValue(Header, 'EVF0END',FEventF0End) ;
    AddKeyValue( Header, 'EVF0CONS',EventF0Constant) ;
    AddKeyValue(Header,'EVF0USEC',FEventF0UseConstant) ;
    AddKeyValue( Header, 'EVF0DMAX',FEventF0DisplayMax) ;
    AddKeyValue(Header,'EVF0SUBF0',FEventF0SubtractF0)  ;

     // Append experiment comment line
     AddKeyValue( Header, 'ID', FIdent ) ;

     // Save markers to header
     AddKeyValue( Header, 'MKN', FNumMarkers ) ;
     for i := 0 to FNumMarkers-1 do begin
         AddKeyValue( Header, format('MKTIM%d',[i]),FMarkerTime[i]) ;
         AddKeyValue( Header, format('MKTXT%d',[i]), FMarkerText[i] ) ;
         end ;

     // Get ANSIstring copy of header text and write to file

     pANSIBuf := AllocMem( FNumIDRHeaderBytes ) ;
     for i := 1 to Min(Length(Header.Text),FNumIDRHeaderBytes-1) do
         begin
         pAnsiBuf[i-1] := ANSIChar(Header.Text[i]);
         end;

     if IDRFileWrite( pAnsiBuf, 0, FNumIDRHeaderBytes ) <> FNumIDRHeaderBytes then
        ShowMessage( FFileName + ' : File header write error!' );

     FreeMem( pANSIBuf ) ;


     // Free file header list
     Header.Free ;

     end ;


procedure TIDRFile.SaveROIsToCSVFile(
          FileName : String
          ) ;
// ------------------------------------
// Save regions of interest to CSV file
// ------------------------------------
var
     i,j : Integer ;
     s : String ;
     ROIList : TStringList ;
begin

    // Create empty list
    ROIList := TStringList.Create ;

    for i := 0 to FMaxROI do
        begin
        if FROIs[i].InUse then
           begin
           s := format('%d',[FROIs[i].Shape]) ;
           s := s + format(',%d',[FROIs[i].Centre.X]) ;
           s := s + format(',%d',[FROIs[i].Centre.Y]) ;
           s := s + format(',%d',[FROIs[i].Width]) ;
           s := s + format(',%d',[FROIs[i].Height]) ;
           for j := 0 to FROIs[i].NumPoints-1 do
               begin
               s := s + format(',%d',[FROIs[i].XY[j].X]);
               s := s + format(',%d',[FROIs[i].XY[j].Y]);
               end ;
           ROIList.Add(s) ;
           end;
        end ;

     ROIList.SaveToFile( ReplaceText( FileName, '.idr', '.roi.csv' )) ;
     ROIList.Free ;

     end ;


procedure TIDRFile.LoadROIsFromCSVFile(
          FileName : String
          ) ;
// ---------------------------------------
// Load regions of interest from CSV file
// ---------------------------------------
var
    FileHandle : THandle ;
    i : Integer ;
    ROIs : Array[0..cMaxROIs] of TROI ;         // Regions of interest list (scaled by zoom)
    InF : TextFile ;
    s : String ;
    ROIList : TStringList ;
begin

    FileName := ReplaceText( FileName, '.idr', '.roi.csv' ) ;
    if not FileExists(FileName) then Exit ;

    // Get ROI list from CSV file
    ROIList := TStringList.Create ;
    ROIList.LoadFromFile( FileName ) ;

    // Clear existing ROIs
    for i := 0 to High(ROIs) do ROIs[i].InUse := False ;

    // Read ROIs

    for i := 0 to ROIList.Count-1
        do begin

        FROIs[i].InUse := True ;
        s := ROIList[i] ;
        FROIs[i].Shape := GetInt(s) ;
        FROIs[i].Centre.X := GetInt(s) ;
        FROIs[i].Centre.Y := GetInt(s) ;
        FROIs[i].Width := GetInt(s) ;
        FROIs[i].Height := GetInt(s) ;
        FROIs[i].TopLeft.X := FROIs[i].Centre.X - FROIs[i].Width div 2 ;
        FROIs[i].TopLeft.Y := FROIs[i].Centre.Y - FROIs[i].Height div 2 ;
        FROIs[i].BottomRight.X := FROIs[i].TopLeft.X + FROIs[i].Width - 1 ;
        FROIs[i].BottomRight.Y := FROIs[i].TopLeft.Y + FROIs[i].Height - 1 ;
        FROIs[i].ZoomFactor := 1 ;

        FROIs[i].NumPoints := 0 ;
        while Length(s) > 0 do
              begin
              FROIs[i].XY[FROIs[i].NumPoints].X := GetInt(s) ;
              FROIs[i].XY[FROIs[i].NumPoints].Y := GetInt(s) ;
              Inc(FROIs[i].NumPoints) ;
              end;
        end;

    end ;


function TIDRFile.GetInt( var s : String ) : Integer ;
// -------------------------------------------------------
// Extract and return a comma-delimited integer value from s
// -------------------------------------------------------
var
    sNum : String ;
    i,iNum, iErr : Integer ;
begin

    sNum := '' ;
    i := 1 ;
    while (i <= Length(s)) and (s[i] <>',') do
        begin
        sNum := sNum + s[i] ;
        Inc(i) ;
        end ;
    s := RightStr(s,Max(Length(s)-i,0)) ;
    if Length(sNum) > 0 then
       begin
       Val( sNum, iNum, iErr ) ;
       Result := iNum ;
       end
    else Result := 0 ;
    end;


function TIDRFile.LoadFrame(
         FrameNum : Integer ;             // Frame # to load
         FrameBuf : Pointer ) : Boolean ; // Frame buffer pointer
// -------------------------------
// Load image frame from data file
// -------------------------------
var
    FileOffset : Int64 ;
begin

     Result := False ;
     if (FrameNum > 0) and (FrameNum <= FNumFrames) and
        (FIDRFileHandle <> INVALID_HANDLE_VALUE) then begin

        FileOffset := Int64(FrameNum-1)*Int64(FNumBytesPerFrame) + Int64(FNumIDRHeaderBytes) ;
        if IDRFileRead( FrameBuf, FileOffset, FNumBytesPerFrame )
           = FNumBytesPerFrame then Result := True ;

        end ;

     end ;


function TIDRFile.LoadFrame32(
         FrameNum : Integer ;             // Frame # to load
         FrameBuf32 : PIntArray ) : Boolean ; // Frame buffer pointer
// ---------------------------------------------------
// Load image from data file and copy to 32 bit buffer
// ---------------------------------------------------
var
    i : Integer ;
begin
        for i := 0 to FNumPixelsPerFrame-1 do
            PWordArray(PInternalBuf)^[i] := 0 ;

     Result := True ;
     // Load raw frame from file
     Result := LoadFrame( FrameNum, PInternalBuf ) ;
     if not Result then Exit ;

     if FNumBytesPerPixel > 2 then begin
        // 32 bit images
        for i := 0 to FNumPixelsPerFrame-1 do
            FrameBuf32^[i] := PIntArray(PInternalBuf)^[i] ;
        end
     else if FNumBytesPerPixel > 1 then begin
        // 16 bit images
        for i := 0 to FNumPixelsPerFrame-1 do
            FrameBuf32^[i] := PWordArray(PInternalBuf)^[i] ;
        end
     else begin
        // 8 bit images
        for i := 0 to FNumPixelsPerFrame-1 do
            FrameBuf32^[i] := PByteArray(PInternalBuf)^[i] ;
        end ;

     end ;



function TIDRFile.SaveFrame(
         FrameNum : Integer ;              // Frame # to be written
         FrameBuf : Pointer ) : Boolean ;  // Pointer to image buffer
// -------------------------------
// Save image frame to data file
// -------------------------------
var
    FileOffset : Int64 ;
begin

     Result := False ;
     if (FrameNum <= 0) or (FIDRFileHandle = INVALID_HANDLE_VALUE) then Exit ;

     FileOffset := Int64(FrameNum-1)*Int64(FNumBytesPerFrame) + FNumIDRHeaderBytes ;
     if IDRFileWrite(FrameBuf,FileOffset,FNumBytesPerFrame) = FNumBytesPerFrame then begin
        FNumFrames := Max(FNumFrames,FrameNum) ;
        Result := True ;
        end ;

     end ;


function TIDRFile.SaveFrame32(
         FrameNum : Integer ;             // Frame # to save
         FrameBuf32 : PIntArray ) : Boolean ; // Frame buffer pointer
// ---------------------------------------------------
// Save image from 32 bit buffer to data file
// ---------------------------------------------------
var
    i : Integer ;
begin

     // Create 8/16 image frame

     if FNumBytesPerPixel > 2 then begin
        // 32 bit images
        for i := 0 to FNumPixelsPerFrame-1 do
            PIntArray(PInternalBuf)^[i] := FrameBuf32^[i] ;
           end
     else if FNumBytesPerPixel > 1 then begin
        // 16 bit images
        for i := 0 to FNumPixelsPerFrame-1 do
            PWordArray(PInternalBuf)^[i] := FrameBuf32^[i] ;
           end
     else begin
        // 8 bit images
        for i := 0 to FNumPixelsPerFrame-1 do
            PByteArray(PInternalBuf)^[i] := FrameBuf32^[i] ;
        end ;

     // Save raw frame to file
     Result := SaveFrame( FrameNum, PInternalBuf ) ;

     end ;


function TIDRFile.AsyncSaveFrames(
         FrameNum : Integer ;              // Starting Frame # to be written
         NumFrames : Integer ;             // Number of frames to be written
         FrameBuf : Pointer ) : Boolean ;  // Pointer to image buffer
// ------------------------------------------------------
// Save image frames to data file (asynchronous transfer)
// ------------------------------------------------------
var
    FileOffset : Int64 ;
    NumBytesToWrite : Integer ;
begin

     Result := False ;
     if (FrameNum <= 0) or (FIDRFileHandle = INVALID_HANDLE_VALUE) then Exit ;

     NumBytesToWrite := FNumBytesPerFrame*NumFrames ;

     FileOffset := Int64(FrameNum-1)*Int64(FNumBytesPerFrame) + FNumIDRHeaderBytes ;
     IDRAsyncFileWrite(FrameBuf,FileOffset,NumBytesToWrite) ;

     FNumFrames := FNumFrames + NumFrames ;

     Result := True ;

     end ;

procedure TIDRFile.UpdateNumFrames ;
// -----------------------------------
// Update the number of frames in file
// -----------------------------------
begin
     //FNumFrames := GetNumFramesInFile ;
     end ;


function TIDRFile.GetNumFramesInFile : Integer ;
// ---------------------------------
// Get number of frames in data file
// ---------------------------------
var
    NumFrames : Int64 ;
begin
     if FIDRFileHandle <> INVALID_HANDLE_VALUE then begin
        if FNumBytesPerFrame > 0 then begin
           NumFrames := (IDRGetFileSize - Int64(FNumIDRHeaderBytes))
                        div Int64(FNumBytesPerFrame) ;
           Result := Max( Integer(NumFrames), 0 ) ;
           end
        else Result := 0 ;
        end
     else Result := 0 ;
     end ;


function  TIDRFile.LoadADC(
          StartScan : Int64 ;               // First A/D channel scan to be loaded
          NumScans : Integer ;                // No. of A/D channel scans to load
          var ADCBuf : Array of SmallInt     // A/D sample buffer to be filled with samples
          ) : Integer ;                       // Returns no. of scans loaded
// -----------------------------------
// Load A/D samples from EDR data file
// -----------------------------------
var
     FileOffset : Int64 ;
     NumBytes,NumBytesRead : Integer ;
     FirstAvailableScan,NumScansAvailable,iShift,jFrom,jTo : Int64 ;
     i,ch : Integer ;
     TempBuf : pSmallIntArray ;
begin

     Result := 0 ;
     if FEDRFileHandle = INVALID_HANDLE_VALUE then Exit ;
     if FADCNumChannels <= 0 then Exit ;

     // Read scans available in file
     FirstAvailableScan :=  Min(Max(StartScan,0),FADCNumScansInFile-1) ;
     NumScansAvailable := Min(StartScan + NumScans, FADCNumScansInFile) - FirstAvailableScan ;
     FileOffset := Int64((FirstAvailableScan*FADCNumChannels*2) + FNumEDRHeaderBytes) ;
     NumBytes :=  NumScansAvailable*FADCNumChannels*2 ;
     FileSeek( FEDRFileHandle,FileOffset,0) ;
     NumBytesRead := FileRead( FEDRFileHandle, ADCBuf,NumBytes) ;

     // Pad ends of buffer if insufficient scans available
     if (StartScan <> FirstAvailableScan) or
        (NumScansAvailable <> NumScans) then begin
        iShift := Integer(FirstAvailableScan - StartScan) ;
        // Create and copy data to temp buf.
        TempBuf := GetMemory( NumScans*FADCNumChannels*2 ) ;
        for i := 0 to NumScans*FADCNumChannels-1 do TempBuf[i] := ADCBuf[i] ;
        // Shift data
        for i := NumScans-1 downto 0 do begin
            jFrom := Min(Max(i-iShift,0),NumScansAvailable-1)*FADCNumChannels ;
            jTo := i*FADCNumChannels ;
            for ch := 0 to FADCNumChannels-1 do ADCBuf[jTo+ch] :=  TempBuf[jFrom+ch] ;
            end ;
        FreeMemory(TempBuf) ;
        end ;

     Result := NumScans ;

     end ;


function  TIDRFile.SaveADC(
          StartScan : Int64 ;               // First A/D channel scan to be saved
          NumScans : Integer ;                // No. of A/D channel scans to save
          var ADCBuf : Array of SmallInt     // A/D sample buffer to saved to file
          ) : Integer ;                       // Returns no. of scans saved
// -----------------------------------
// Save A/D samples to EDR data file
// -----------------------------------
var
     FileOffset : Int64 ;
     NumBytes,NumBytesRead : Integer ;
begin

     Result := 0 ;
     if FEDRFileHandle = INVALID_HANDLE_VALUE then Exit ;
     if FADCNumChannels <= 0 then Exit ;

     FileOffset := Int64((StartScan*FADCNumChannels*2) + FNumEDRHeaderBytes) ;
     NumBytes :=  NumScans*FADCNumChannels*2 ;

     FileSeek( FEDRFileHandle,FileOffset,0) ;
     NumBytesRead := FileWrite( FEDRFileHandle, ADCBuf,NumBytes) ;
     Result := NumBytesRead div (FADCNumChannels*2) ;

     end ;




procedure TIDRFile.SaveEDRHeader ;
{ ---------------------------------------
  Save file header data to EDR data file
  ---------------------------------------}
var
   Header : TStringList ;
   pANSIBuf : pANSIChar ;

   i : Integer ;
   ch : Integer ;
begin

     if FEDRFileHandle = INVALID_HANDLE_VALUE then Exit ;

     // Ensure files are write enabled
     if not FWriteEnabled then SetWriteEnabled(True) ;

     // Create file header Name=Value string list
     Header := TStringList.Create ;

     AddKeyValue( Header, 'VER',1.0 );

     // 13/2/02 Added to distinguish between 12 and 16 bit data files
     AddKeyValue( Header, 'ADCMAX', FADCMaxValue ) ;

     { Number of bytes in file header }
     AddKeyValue( Header, 'NBH', FNumEDRHeaderBytes ) ;

     AddKeyValue( Header, 'NC', FADCNumChannels ) ;

     // A/D converter input voltage range
     AddKeyValue( Header, 'AD', FADCVoltageRange ) ;

     FADCNumSamplesInFile := (FileSeek(EDRFileHandle,0,2)
                             + 1 - FNumEDRHeaderBytes) div 2 ;

     if FADCNumChannels > 0 then begin
        FADCNumScansInFile := FADCNumSamplesInFile div FADCNumChannels ;
        end
     else FADCNumScansInFile := 1 ;

     AddKeyValue( Header, 'NP', FADCNumSamplesInFile ) ;

     AddKeyValue( Header, 'DT',FADCScanInterval );

     for ch := 0 to FADCNumChannels-1 do
         begin
         AddKeyValue( Header, format('YO%d',[ch]), Channels[ch].ChannelOffset) ;
         AddKeyValue( Header, format('YU%d',[ch]), Channels[ch].ADCUnits ) ;
         AddKeyValue( Header, format('YN%d',[ch]), Channels[ch].ADCName ) ;
         AddKeyValue(Header,format('YCF%d',[ch]),Channels[ch].ADCCalibrationFactor) ;
         AddKeyValue( Header, format('YAG%d',[ch]), Channels[ch].ADCAmplifierGain) ;
         AddKeyValue( Header, format('YZ%d',[ch]), Channels[ch].ADCZero) ;
         AddKeyValue( Header, format('YR%d',[ch]), Channels[ch].ADCZeroAt) ;
         end ;

     { Experiment identification line }
     //AddKeyValue( Header, 'ID', fHDR.IdentLine ) ;

     { Save the original file backed up flag }
     AddKeyValue( Header, 'BAK', False ) ;

     StringListToFile( ReplaceText(FFileName,'.idr','.edr'),
                       FEDRFileHandle,
                       Header,
                       0,
                       FNumEDRHeaderBytes ) ;

     // Free allocated variables
     Header.Free ;

     end ;


procedure TIDRFile.StringListToFile(
          FileName : string ;        // File name
          FileHandle : THandle ;     // File Handle
          List : TStringList ;       // StringList to be written
          FileOffset : NativeInt ;   // Starting offset in file
          NumBytes : Integer ) ;     // Bytes to be written
// ------------------------
// Write List text to file
// ------------------------
var
    pANSIBuf : PANSIChar ;
    i,nWritten : Integer ;
begin

     // Get ANSIstring copy of header text and write to file
     pANSIBuf := AllocMem( NumBytes ) ;
     for i := 1 to Min(Length(List.Text),NumBytes-1) do
         begin
         pAnsiBuf[i-1] := ANSIChar(List.Text[i]);
         end;

     if Length(List.Text) >= (NumBytes-1) then
        begin
        ShowMessage( FileName + ' : File header full!' ) ;
        end;

     // Write header to start of EDR data file
     nWritten := FileSeek( FileHandle, FileOffset, 0 ) ;
     nWritten := FileWrite( FileHandle, pANSIBuf^, NumBytes ) ;
     if nWritten <> NumBytes then
        ShowMessage( FileName + ': File Header Write Failed! ' ) ;

     FreeMem( pANSIBuf ) ;

end;


procedure TIDRFile.GetEDRHeader ;
// ------------------------
// Load EDR data file header
// ------------------------
var
   ch : Integer ;
   Header : TStringList ;
   pANSIBuf : PANSIChar ;
   ANSIHeader : ANSIString ;

begin

     if FEDRFileHandle  = INVALID_HANDLE_VALUE then Exit ;

     // Create header parameter list
     Header := TStringList.Create ;

     // Read ANSI text from file header and load into Header StringList
     pANSIBuf := AllocMem( cNumIDRHeaderBytes ) ;
     FileSeek( FEDRFileHandle, 0, 0 ) ;
     if FileRead( FEDRFileHandle, pANSIBuf^, cNumEDRHeaderBytes ) < cNumEDRHeaderBytes then Exit ;
     pANSIBuf[cNumEDRHeaderBytes-1] := #0 ;
     ANSIHeader := ANSIString( pANSIBuf ) ;
     Header.Text := String(ANSIHeader) ;

     // 13/2/02 Added to distinguish between 12 and 16 bit data files
     FADCMaxValue := GetKeyValue( Header, 'ADCMAX', FADCMaxValue ) ;

     FNumEDRHeaderBytes := cNumEDRHeaderBytes ;
     FNumEDRHeaderBytes := GetKeyValue( Header, 'NBH', FNumEDRHeaderBytes ) ;
     FNumEDRHeaderBytes := cNumEDRHeaderBytes  ;

     FADCNumChannels := GetKeyValue( Header, 'NC', FADCNumChannels ) ;
     if FADCNumChannels <= 0 then Exit ;

     // A/D converter input voltage range
     FADCVoltageRange := GetKeyValue( Header, 'AD', FADCVoltageRange ) ;

     FADCNumSamplesInFile := GetKeyValue( Header, 'NP', FADCNumSamplesInFile ) ;
     if FADCNumSamplesInFile <= 0 then begin
        FADCNumScansInFile := GetNumScansInEDRFile ;
        FADCNumSamplesInFile := FADCNumChannels*FADCNumScansInFile ;
        end
     else begin
        FADCNumScansInFile := FADCNumSamplesInFile div Max(FADCNumChannels,1) ;
        end;

     FADCScanInterval := GetKeyValue( Header, 'DT',FADCScanInterval );

     for ch := 0 to FADCNumChannels-1 do
         begin
         Channels[ch].ChannelOffset := GetKeyValue( Header, format('YO%d',[ch]), Channels[ch].ChannelOffset) ;
         Channels[ch].ADCUnits := GetKeyValue( Header, format('YU%d',[ch]), Channels[ch].ADCUnits ) ;
         Channels[ch].ADCName := GetKeyValue( Header, format('YN%d',[ch]), Channels[ch].ADCName ) ;
         Channels[ch].ADCCalibrationFactor := GetKeyValue(Header,format('YCF%d',[ch]),Channels[ch].ADCCalibrationFactor) ;
         Channels[ch].ADCAmplifierGain := GetKeyValue( Header, format('YAG%d',[ch]), Channels[ch].ADCAmplifierGain) ;
         Channels[ch].ADCZero := GetKeyValue( Header, format('YZ%d',[ch]), Channels[ch].ADCZero) ;
         Channels[ch].ADCZeroAt := GetKeyValue( Header, format('YR%d',[ch]), Channels[ch].ADCZeroAt) ;
         end ;

     // Update A/D channel scaling factors
     UpdateChannelScalingFactors( Channels,
                                  FADCNumChannels,
                                  FADCVoltageRange,
                                  FADCMaxValue )  ;

     // Release allocated memory
     Header.Free ;
     FreeMem(pANSIBuf) ;

     end ;


function TIDRFile.GetNumScansInEDRFile : Int64 ;
// ------------------------------------
// Get number of A/D scans in data file
// ------------------------------------
var
     NumSamplesInFile,Offset : Int64 ;
begin

     if EDRFileHandle > 0 then begin
        Offset := 0 ;
        NumSamplesInFile := (FileSeek(EDRFileHandle,Offset,2)
                             + 1 - Int64(FNumEDRHeaderBytes)) div 2 ;

        Result := NumSamplesInFile div Max(FADCNumChannels,1) ;
        end
     else Result := 0 ;
     end ;


procedure TIDRFile.UpdateChannelScalingFactors(
          var Channels : Array of TChannel ;
          NumChannels : Integer ;
          ADCVoltageRange : Single ;
          ADCMaxValue : Integer
          ) ;
// ------------------------------
// Update channel scaling factors
// ------------------------------
var
   ch : Integer ;
   Denom : single ;
begin

     for ch := 0 to NumChannels-1 do begin

         // Ensure that calibration factor is non-zero
         if Channels[ch].ADCCalibrationFactor = 0.0 then
            Channels[ch].ADCCalibrationFactor := 0.001 ;

         // Ensure that amplifier gain is non-zero
         if Channels[ch].ADCAmplifierGain = 0.0 then
            Channels[ch].ADCAmplifierGain := 1.0 ;

         // Calculate bits->units scaling factor
         Denom := Channels[ch].ADCCalibrationFactor*Channels[ch].ADCAmplifierGain*(ADCMaxValue+1) ;
         if Abs(Denom) > 1E-10 then Channels[ch].ADCScale := ADCVoltageRange / Denom
                               else  Channels[ch].ADCScale := 1.0 ;

         end ;
     end ;


function TIDRFile.GetFrameType( i : Integer ) : String ;
{ ---------------------
  Get frame type label
  ---------------------}
begin
     if SpectralDataFile then begin
         Result :=format('%.0f(%.0f) nm ',
                  [ FSpectrumStartWavelength + (i*FSpectrumStepSize),
                    FSpectrumBandwidth]) ;
         end
     else begin
         Result := FFrameTypes[IntLimitTo(i,0,MaxFrameType)] ;
         end ;

     end ;


function TIDRFile.GetFrameTypeDivideFactor( i : Integer ) : Integer ;
{ ----------------------------
  Get frame type divide factor
  ----------------------------}
begin
     if SpectralDataFile then begin
         Result := 1 ;
         end
     else begin
         Result := FFrameTypeDivideFactor[IntLimitTo(i,0,MaxFrameType)] ;
         end ;

     end ;


function TIDRFile.GetEquation( i : Integer ) : TBindingEquation ;
{ ---------------------------
  Get binding equation
  ---------------------------}
begin
     Result := FEquations[IntLimitTo(i,0,MaxEqn)] ;
     end ;


function TIDRFile.GetMarkerTime( i : Integer ) : Single ;
{ ----------------------
  Get event marker time
  ----------------------}
begin
     if (i >= 0) and (i < FNumMarkers) then Result := FMarkerTime[i]
                                       else Result := 0.0 ;
     end ;


procedure TIDRFile.SetMarkerTime(
          i : Integer ;
          Value : Single )  ;
{ ----------------------
  Set event marker time
  ----------------------}
begin
     if (i >= 0) and (i < FNumMarkers) then FMarkerTime[i] := Value ;
     end ;


function TIDRFile.GetMarkerText( i : Integer ) : String ;
{ ----------------------
  Get event marker text
  ----------------------}
begin
     if (i >= 0) and (i < FNumMarkers) then Result := FMarkerText[i]
                                       else Result := '' ;
     end ;


procedure TIDRFile.SetMarkerText(
         i : Integer ;
         Value : String
         ) ;
{ ----------------------
  Get event marker text
  ----------------------}
begin
     if (i >= 0) and (i < FNumMarkers) then FMarkerText[i] := Value ;
     end ;


function TIDRFile.GetADCChannel( i : Integer ) : TChannel ;
// -----------------------------------------
// Get analogue input channel definition
// -----------------------------------------
begin
     Result := Channels[IntLimitTo(i,0,MaxChannel)] ;
     end ;


function TIDRFile.GetROI( i : Integer ) : TROI ;
// ----------------------
// Get region of interest
// ----------------------
begin
     Result := FROIs[IntLimitTo(i,0,FMaxROI)] ;
     end ;


procedure TIDRFile.SetADCChannel( i : Integer ;
                                  Value : TChannel ) ;
// -----------------------------------------
// Set analogue input channel definition
// -----------------------------------------
begin
     Channels[IntLimitTo(i,0,MaxChannel)] := Value ;
     // Update A/D channel scaling factors
     UpdateChannelScalingFactors( Channels,
                                  FADCNumChannels,
                                  FADCVoltageRange,
                                  FADCMaxValue )  ;
     end ;


procedure TIDRFile.SetROI( i : Integer ;
                           Value : TROI ) ;
// ----------------------
// Set region of interest
// ----------------------
begin
     FROIs[IntLimitTo(i,0,FMaxROI)] := Value ;
     end ;


procedure TIDRFile.SetPixelDepth( Value : Integer ) ;
// ---------------
// Set pixel depth
// ---------------
begin
     FPixelDepth := IntLimitTo( Value, 1, 32 ) ;
     ComputeFrameSize ;
     end ;


procedure TIDRFile.SetFrameWidth( Value : Integer ) ;
// ---------------
// Set frame width
// ---------------
begin
     FFrameWidth := IntLimitTo( Value, 0, $10000 ) ;
     ComputeFrameSize ;
     end ;


procedure TIDRFile.SetFrameHeight( Value : Integer ) ;
// ---------------
// Set frame height
// ---------------
begin
     FFrameHeight := IntLimitTo( Value, 0, $10000 ) ;
     ComputeFrameSize ;
     end ;


procedure TIDRFile.SetADCVoltageRange( Value : Single ) ;
// ---------------------------
// Set A/D input voltage range
// ---------------------------
begin
     FADCVoltageRange := Value ;
     // Update A/D channel scaling factors
     UpdateChannelScalingFactors( Channels,
                                  FADCNumChannels,
                                  FADCVoltageRange,
                                  FADCMaxValue )  ;
     end ;


procedure TIDRFile.SetADCNumChannels( Value : Integer ) ;
// ---------------------------
// Set no. of A/D input channels
// ---------------------------
var
     ch : Integer ;
begin
     FADCNumChannels := IntLimitTo( Value, 0, MaxChannel+1)  ;

     // Temporary to ensure correct channel sequence
     for ch := 0 to FADCNumChannels-1 do Channels[ch].ChannelOffset := ch ;

     // Update A/D channel scaling factors
     UpdateChannelScalingFactors( Channels,
                                  FADCNumChannels,
                                  FADCVoltageRange,
                                  FADCMaxValue )  ;
     end ;


function TIDRFile.AddMarker(
         Time : Single ;         // Event time (s)
         Text : String           // Marker text
         ) : Boolean ;           // Returns TRUE if marker added to list
// ------------------------------
// Add a new event marker to list
// ------------------------------
begin
     if (FNumMarkers-1) < MaxMarker then begin
        FMarkerTime[FNumMarkers] := Time ;
        FMarkerText[FNumMarkers] := Text ;
        Inc(FNumMarkers) ;
        Result := True ;
        end
     else Result := False ;
     end ;


procedure TIDRFile.ComputeFrameSize ;
// ------------------------------------------
// Compute frame size when properties changed
// ------------------------------------------
var
     i : Integer ;
begin

     if FPixelDepth > 16 then FNumBytesPerPixel := 4
     else if FPixelDepth > 8 then FNumBytesPerPixel := 2
                             else FNumBytesPerPixel := 1 ;

     FNumPixelsPerFrame := FFrameWidth*FFrameHeight ;
     FNumBytesPerFrame := FNumPixelsPerFrame*FNumBytesPerPixel ;

     FGreyMax := 1 ;
     for i := 1 to FPixelDepth do FGreyMax := FGreyMax*2 ;
     FGreyMax := FGreyMax - 1 ;

     end ;


procedure TIDRFile.SetFrameType( i : Integer ;
                                 Value : String ) ;
{ ---------------------
  Set frame type label
  ---------------------}
begin
     FFrameTypes[IntLimitTo(i,0,MaxFrameType)] := Value ;
     end ;


procedure TIDRFile.SetFrameTypeDivideFactor( i : Integer ;
                                             Value : Integer ) ;
{ ----------------------------
  Set frame type divide factor
  ----------------------------}
begin

     FFrameTypeDivideFactor[IntLimitTo(i,0,MaxFrameType)] := Value ;

     // Create frame type cycle
     CreateFrameTypeCycle( FFrameTypeCycle, FFrameTypeCycleLength ) ;

     end ;


procedure TIDRFile.SetWriteEnabled( Value : Boolean ) ;
// ---------------------------
// Set file write enabled mode
// ---------------------------
begin

    if FIDRFileHandle = INVALID_HANDLE_VALUE then Exit ;

    IDRFileClose ;

    FWriteEnabled := Value ;
    if FWriteEnabled then FileMode := fmOpenReadWrite
                     else FileMode := fmOpenRead ;

    // Open files in selected mode
    IDRFileOpen( FFileName, FileMode ) ;

    if FEDRFileHandle <> INVALID_HANDLE_VALUE then FileClose( FEDRFileHandle ) ;
    FEDRFileHandle := FileOpen( ChangeFileExt( FFileName, '.EDR' ), FileMode ) ;

    end ;


procedure TIDRFile.SetEquation( i : Integer ;
                                Value : TBindingEquation ) ;
{ ---------------------------
  Set binding equation
  ---------------------------}
begin
     FEquations[IntLimitTo(i,0,MaxEqn)] := Value ;
     end ;


function TIDRFile.GetFileHeader : string ;
// --------------------
// Get file header text
// --------------------
begin
    Result := IDRFileHeaderText ;
    end ;


function TIDRFile.GetMaxROIInUse : Integer ;
// -------------------------
// Return highest ROI in use
// -------------------------
var
    i : Integer ;
begin
    Result := 0 ;
    for i := 0 to cMaxROIs do begin
        if FROIs[i].InUse then Result := i ;
        end ;
        end ;

procedure TIDRFile.AddKeyValue( List : TStringList ;  // List for Key=Value pairs
                                KeyWord : string ;    // Key
                                Value : single        // Value
                                 ) ;
// ---------------------
// Add Key=Single Value to List
// ---------------------
begin

     List.Add( ReplaceText(Keyword + format('=%.4g',[Value]),'==','=') ) ;
end;


procedure TIDRFile.AddKeyValue( List : TStringList ;  // List for Key=Value pairs
                                KeyWord : string ;    // Key
                                Value : Integer        // Value
                                 ) ;
// ---------------------
// Add Key=Integer Value to List
// ---------------------
begin
     List.Add( ReplaceText( Keyword + format('=%d',[Value]),'==','=') ) ;
end;

procedure TIDRFile.AddKeyValue( List : TStringList ;  // List for Key=Value pairs
                                KeyWord : string ;    // Key
                                Value : Int64        // Value
                                 ) ;
// ---------------------
// Add Key=Int64 Value to List
// ---------------------
begin
     List.Add( ReplaceText( Keyword + format('=%d',[Value]),'==','=') ) ;
end;


procedure TIDRFile.AddKeyValue( List : TStringList ;  // List for Key=Value pairs
                                KeyWord : string ;    // Key
                                Value : NativeInt        // Value
                                 ) ;
// ---------------------
// Add Key=NativeInt Value to List
// ---------------------
begin
     List.Add( ReplaceText(Keyword + format('=%d',[Value] ),'==','=') ) ;
end;


procedure TIDRFile.AddKeyValue( List : TStringList ;  // List for Key=Value pairs
                                KeyWord : string ;    // Key
                                Value : string        // Value
                                 ) ;
// ---------------------
// Add Key=string Value to List
// ---------------------
begin
     List.Add( ReplaceText( Keyword + '=' + Value,'==','=') ) ;
end;


procedure TIDRFile.AddKeyValue( List : TStringList ;  // List for Key=Value pairs
                                KeyWord : string ;    // Key
                                Value : Boolean        // Value
                                 ) ;
// ---------------------
// Add Key=boolean Value to List
// ---------------------
begin
     if Value then List.Add(  ReplaceText( Keyword + '= T','==','=') )
              else List.Add(  ReplaceText( Keyword + '= F','==','=') ) ;
end;


function TIDRFile.GetKeyValue( List : TStringList ;  // List for Key=Value pairs
                               KeyWord : string ;   // Key
                               Value : single       // Value
                               ) : Single ;         // Return value
// ------------------------------
// Get Key=Single Value from List
// ------------------------------
var
    istart,idx : Integer ;
    s : string ;
begin

     idx := List.IndexOfName( Keyword ) ;
     if idx >= 0 then
        begin
        s := List[idx] ;
        // Find key=value separator and remove key
        istart := Pos( '=', s ) ;
        if istart > 0 then Delete( s, 1, istart ) ;
        Result := ExtractFloat( s, Value ) ;
        end
     else Result := Value ;

end;


function TIDRFile.GetKeyValue( List : TStringList ;  // List for Key=Value pairs
                               KeyWord : string ;   // Key
                               Value : Integer       // Value
                               ) : Integer ;        // Return value
// ------------------------------
// Get Key=Integer Value from List
// ------------------------------
var
    istart,idx : Integer ;
    s : string ;
begin

     idx := List.IndexOfName( Keyword ) ;
     if idx >= 0 then
        begin
        s := List[idx] ;
        // Find key=value separator and remove key
        istart := Pos( '=', s ) ;
        if istart > 0 then Delete( s, 1, istart ) ;
        Result := STrToInt( s ) ;
        end
     else Result := Value ;

end;


function TIDRFile.GetKeyValue( List : TStringList ;  // List for Key=Value pairs
                               KeyWord : string ;   // Key
                               Value : Int64       // Value
                               ) : Int64 ;        // Return value
// ------------------------------
// Get Key=Int64 Value from List
// ------------------------------
var
    istart,idx : Integer ;
    s : string ;
begin

     idx := List.IndexOfName( Keyword ) ;
     if idx >= 0 then
        begin
        s := List[idx] ;
        // Find key=value separator and remove key
        istart := Pos( '=', s ) ;
        if istart > 0 then Delete( s, 1, istart ) ;
        Result := STrToInt( s ) ;
        end
     else Result := Value ;

end;



function TIDRFile.GetKeyValue( List : TStringList ;  // List for Key=Value pairs
                               KeyWord : string ;   // Key
                               Value : NativeInt       // Value
                               ) : NativeInt ;        // Return value
// ------------------------------
// Get Key=Integer Value from List
// ------------------------------
var
    istart,idx : Integer ;
    s : string ;
begin

     idx := List.IndexOfName( Keyword ) ;
     if idx >= 0 then
        begin
        s := List[idx] ;
        // Find key=value separator and remove key
        istart := Pos( '=', s ) ;
        if istart > 0 then Delete( s, 1, istart ) ;
        Result := STrToInt( s ) ;
        end
     else Result := Value ;

end;


function TIDRFile.GetKeyValue( List : TStringList ;  // List for Key=Value pairs
                               KeyWord : string ;   // Key
                               Value : string       // Value
                               ) : string ;        // Return value
// ------------------------------
// Get Key=Integer Value from List
// ------------------------------
var
    istart,idx : Integer ;
    s : string ;
begin

      idx := List.IndexOfName( Keyword ) ;
     if idx >= 0 then
        begin
        s := List[idx] ;
        // Find key=value separator and remove key
        istart := Pos( '=', s ) ;
        if istart > 0 then Delete( s, 1, istart ) ;
        Result := s ;
        end
     else Result := Value ;

end;


function TIDRFile.GetKeyValue( List : TStringList ;  // List for Key=Value pairs
                               KeyWord : string ;   // Key
                               Value : Boolean       // Value
                               ) : Boolean ;        // Return value
// ------------------------------
// Get Key=Boolean Value from List
// ------------------------------
var
    istart,idx : Integer ;
    s : string ;
begin

     idx := List.IndexOfName( Keyword ) ;
     if idx >= 0 then
        begin
        s := List[idx] ;
        // Find key=value separator and remove key
        istart := Pos( '=', s ) ;
        if istart > 0 then Delete( s, 1, istart ) ;
        if ContainsText(s,'T') then Result := True
                               else Result := False ;
        end
     else Result := Value ;

end;


function TIDRFile.IntLimitTo(
         Value : Integer ;       { Value to be tested (IN) }
         LowerLimit : Integer ;  { Lower limit (IN) }
         UpperLimit : Integer    { Upper limit (IN) }
         ) : Integer ;           { Return limited Value }
{ -------------------------------------------------------------------
  Make sure Value is kept within the limits LowerLimit and UpperLimit
  -------------------------------------------------------------------}
begin
     if Value < LowerLimit then Value := LowerLimit ;
     if Value > UpperLimit then Value := UpperLimit ;
     Result := Value ;
     end ;


function TIDRFile.ExtractFloat (
         CBuf : ANSIstring ;     { ASCII text to be processed }
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

     { Convert number from ASCII to real }
     try
        if Length(CNum)>0 then ExtractFloat := StrToFloat( CNum )
                          else ExtractFloat := Default ;
     except
        on E : EConvertError do ExtractFloat := Default ;
        end ;
     end ;


function TIDRFile.DiskSpaceAvailable(
         NumFrames : Integer
         ) : Boolean ;
// ------------------------------------------------
// Determine if there is enough disk space for file
// ------------------------------------------------
const
     DriverLetterList = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' ;
var
    DriveLetter : String ;
    SpaceRequired : Int64 ;
    FreeSpace : Int64 ;
    DiskIndex : Byte ;

begin

    Result := True ;
    //exit ;

     // Get drive
     DriveLetter := UpperCase(ExtractFileDrive(FFileName)) ;
     DiskIndex := Pos( LeftStr(DriveLetter,1), DriverLetterList ) ;
     if DiskIndex > 0 then FreeSpace := DiskFree(DiskIndex)
                      else  FreeSpace := 0 ;

     SpaceRequired := Int64(FFrameWidth) *
                      Int64(FFrameHeight) *
                      Int64(FNumBytesPerPixel) ;
     SpaceRequired := SpaceRequired*Int64(NumFrames) ;
     SpaceRequired := SpaceRequired + Int64(1000000) ;

     if FreeSpace > SpaceRequired then Result := True
                                  else Result := False ;

     end ;


function TIDRFile.IDRFileCreate(
         FileName : String
         ) : Boolean ;
// ---------------------------------------
// Create file for asynchronous read/write
// ---------------------------------------
begin

    // Create file
    FIDRFileHandle :=  CreateFile( PChar(FileName),
                                   GENERIC_WRITE	or GENERIC_READ,
                                   FILE_SHARE_READ,
                                   Nil,
                                   CREATE_ALWAYS,
                                   FILE_ATTRIBUTE_NORMAL or
                                   FILE_FLAG_OVERLAPPED or
                                   FILE_FLAG_WRITE_THROUGH,
                                   0 ) ;

    FAsyncBufferOverflow := False ;
    FAsyncWriteInProgess := False ;

    // Create frame type cycle
    CreateFrameTypeCycle( FFrameTypeCycle, FFrameTypeCycleLength ) ;

    if NativeInt(FIDRFileHandle) < 0 then Result := False
                                     else Result := True ;
    FFileOpen := Result ;

    end ;


function TIDRFile.IDRFileOpen(
         FileName : String ;
         FileMode : Integer
         ) : Boolean ;
// ---------------------------------------
// Create file for asynchronous read/write
// ---------------------------------------
var
    AccessMode : DWord ;
begin

    // Set file access mode
    if FileMode = fmOpenReadWrite then AccessMode := GENERIC_WRITE	or GENERIC_READ
                                  else AccessMode := GENERIC_READ ;

    // Create file
    FIDRFileHandle :=  CreateFile( PChar(FileName),
                                   AccessMode,
                                   FILE_SHARE_READ,
                                   Nil,
                                   OPEN_EXISTING,
                                   FILE_ATTRIBUTE_NORMAL or
                                   FILE_FLAG_OVERLAPPED or
                                   FILE_FLAG_WRITE_THROUGH,
                                   0 ) ;

    FAsyncBufferOverflow := False ;
    FAsyncWriteInProgess := False ;

    if NativeInt(FIDRFileHandle) < 0 then Result := False
                                     else Result := True ;
    FFileOpen := Result ;

    end ;


function TIDRFile.IDRFileWrite(
         pDataBuf : Pointer ;
         FileOffset : Int64 ;
         NumBytesToWrite : Integer
         ) : Integer ;
// ----------------------------
// Write to file (synchronous)
// ----------------------------
var
     NumBytesWritten : Cardinal ;
     Overlap : _Overlapped ;
begin

    // Wait for any existing asynchronous writes to complete
    if FAsyncWriteInProgess then
       begin
       GetOverlappedResult( FIDRFileHandle,
                            AsyncWriteOverlap,
                            NumBytesWritten,
                            True ) ;
       FAsyncWriteInProgess := False ;
       end ;

    // Set file offset point in overlap structure
    Overlap.Offset := FileOffset and $FFFFFFFF ;
    Overlap.OffsetHigh := (FileOffset shr 32) and $FFFFFFFF ;
    Overlap.hEvent := 0 ;

    // Request write to file
    WriteFile( FIDRFileHandle,
               PByteArray(pDataBuf)^,
               NumBytesToWrite,
               NumBytesWritten,
               @Overlap
               ) ;

    // Wait for write to complete
    GetOverlappedResult( FIDRFileHandle,
                         Overlap,
                         NumBytesWritten,
                         True ) ;

    Result := NumBytesWritten ;
    FAsyncBufferOverflow := False ;

    end ;


function TIDRFile.IDRAsyncFileWrite(
         pDataBuf : Pointer ;
         FileOffset : Int64 ;
         NumBytesToWrite : Integer
         ) : Integer ;
// ----------------------------
// Write to file (asynchronous)
// ----------------------------
var
     NumBytesWritten : Cardinal ;
     Err : Integer ;
begin

    // Check for buffer overflow
    FAsyncBufferOverflow := False ;
    if FAsyncWriteInProgess then begin
       GetOverlappedResult( FIDRFileHandle,
                            AsyncWriteOverlap,
                            NumBytesWritten,
                            False ) ;
       if NumBytesWritten <> AsyncNumBytesToWrite then begin
          FAsyncBufferOverflow := True ;
          // Wait for completion
          GetOverlappedResult( FIDRFileHandle,
                               AsyncWriteOverlap,
                               NumBytesWritten,
                               True ) ;
          FAsyncWriteInProgess := False ;
          end;
       end ;

    // Set file offset point in overlap structure
    AsyncWriteOverlap.Offset := FileOffset and $FFFFFFFF ;
    AsyncWriteOverlap.OffsetHigh := (FileOffset shr 32) and $FFFFFFFF ;
    AsyncWriteOverlap.hEvent := 0 ;

    // Write to file
    WriteFile( FIDRFileHandle,
               PByteArray(pDataBuf)^,
               NumBytesToWrite,
               NumBytesWritten,
               @AsyncWriteOverlap
               ) ;
     Err := GetLastError();

    GetOverlappedResult( FIDRFileHandle,
                         AsyncWriteOverlap,
                         NumBytesWritten,
                         False ) ;

//    outputdebugString(PChar(format('Async write %d %d %d',
//    [FileOffset,Cardinal(AsyncWriteOverlap.OffsetHigh),
//    Cardinal(AsyncWriteOverlap.Offset)]))) ;

    FAsyncWriteInProgess := True ;
    AsyncNumBytesToWrite := NumBytesToWrite ;
    Result := NumBytesWritten ;

    end ;


function TIDRFile.GetAsyncWriteInProgress : Boolean ;
// --------------------------------------------------
// Return TRUE if asynchronous file write in progress
// --------------------------------------------------
var
     NumBytesWritten : Cardinal ;
begin

    if not FFileOpen then begin
       Result := False ;
        ;
       Exit ;
       end;

    if FAsyncWriteInProgess then begin ;
       // Check if write completed
       GetOverlappedResult( FIDRFileHandle,
                            AsyncWriteOverlap,
                            NumBytesWritten,
                            False ) ;
       if NumBytesWritten = AsyncNumBytesToWrite then FAsyncWriteInProgess := False ;
       end;
    Result := FAsyncWriteInProgess ;
    end;


function TIDRFile.IDRFileRead(
         pDataBuf : Pointer ;
         FileOffset : Int64 ;
         NumBytesToRead : Integer
         ) : Integer ;
// ------------------
// Read from to file
// ------------------
var
     NumBytesRead,NumBytesWritten : Cardinal ;
     Overlap : _Overlapped ;
     Done : Boolean ;
     TTimeOut : Integer ;
begin

    // Wait for any existing asynchronous writes to complete
    if FAsyncWriteInProgess then begin
       GetOverlappedResult( FIDRFileHandle,
                            AsyncWriteOverlap,
                            NumBytesWritten,
                            True ) ;
       FAsyncWriteInProgess := False ;
       end ;

    // Set file offset point in overlap structure
    Overlap.Offset := FileOffset and $FFFFFFFF ;
    Overlap.OffsetHigh := (FileOffset shr 32) and $FFFFFFFF ;
    Overlap.hEvent := 0 ;

    // Request read of data from file
    Err := ReadFile( FIDRFileHandle,
                     PByteArray(pDataBuf)^,
                     NumBytesToRead,
                     NumBytesRead,
                     @Overlap
                     ) ;

    // Wait for read to complete
    Done := False ;
    TTimeOut := TimeGetTime + 500 ;
    While (not Done) and (TimeGetTime < TTimeOut) do begin
       Done := GetOverlappedResult( FIDRFileHandle,
                                    Overlap,
                                    NumBytesRead,
                                    False ) ;
       end ;

    If not Done then NumBytesRead := 0 ;
    Result := NumBytesRead ;

    end ;

function TIDRFile.IDRGetFileSize : Int64 ;
// -----------------------
// Return size of IDR file
// -----------------------
var
    LoWord,HiWord : DWord ;
begin

    LoWord := GetFileSize( FIDRFileHandle, @HiWord ) ;
    Result := LoWord ;
    Result := Result + Int64(HiWord) shl $10000 ;
    end ;


procedure TIDRFile.IDRFileClose ;
// -----------------------------
// Close asynchronous write file
// -----------------------------
var
     NumBytesWritten : Cardinal ;
begin

    if FIDRFileHandle = INVALID_HANDLE_VALUE then Exit ;

    // Wait for any existing asynchronous writes to complete
    if FAsyncWriteInProgess then begin
       GetOverlappedResult( FIDRFileHandle,
                            AsyncWriteOverlap,
                            NumBytesWritten,
                            True ) ;
       FAsyncWriteInProgess := False ;
       end ;

     // Close file
     CloseHandle( FIDRFileHandle ) ;

     FIDRFileHandle := INVALID_HANDLE_VALUE ;

     end ;


procedure TIDRFile.CreateFramePointerList(
          var FrameList : pIntArray ) ;
// ------------------------------------------------------------------
// Return multi-wavelength/multi-rate group -> frame no. pointer list
// ------------------------------------------------------------------
var
     i,j,iFrame,iFrameType : Integer ;
     FrameTypeCycleLength, LastSlow : Integer ;
     FrameTypeCycle : Array[0..(MaxFrameDivideFactor*(MaxFrameType+1))] of Integer ;
     LatestFrame : Array[0..MaxFrameType+1] of Integer ;
begin

    // Determine last slow frame
    i := 0 ;
    LastSlow := 0 ;
    while (FFrameTypeDivideFactor[i] > 1) and (i < FNumFrameTypes) do begin
          LastSlow := i ;
          Inc(i) ;
          end ;

    // Add one cycle of slow rate wavelengths
    FrameTypeCycleLength := 0 ;
    for i := 0 to LastSlow do begin
        FrameTypeCycle[FrameTypeCycleLength] := i ;
        Inc(FrameTypeCycleLength) ;
        end ;

    // Add DivideFactor cycle of fast frames
    for j := 1 to FFrameTypeDivideFactor[0] do begin
        for i := LastSlow+1 to FNumFrameTypes-1 do begin
            FrameTypeCycle[FrameTypeCycleLength] := i ;
            Inc(FrameTypeCycleLength) ;
            end ;
         end ;

    // Initialise empty frame list
    for i := 0 to FNumFrames*FNumFrameTypes-1 do FrameList[i] := -1 ;

    // Add frame type acquired at each frame
    for iFrame := 0 to FNumFrames-1 do begin
        iFrameType := FrameTypeCycle[iFrame mod FrameTypeCycleLength] ;
        FrameList[iFrame*FNumFrameTypes + iFrameType] := iFrame + 1 ;
        end ;

    // Set first entries
    for iFrameType := 0 to FNumFrameTypes-1 do LatestFrame[iFrameType] := iFrameType + 1 ;

    // Update remaining empty entries with latest available frame
    for iFrameType := 0 to FNumFrameTypes-1 do begin
        for iFrame := 0 to FNumFrames-1 do begin
           j := iFrame*FNumFrameTypes + iFrameType ;
           if FrameList[j] >= 0 then LatestFrame[iFrameType] := FrameList[j]
                                else FrameList[j] := LatestFrame[iFrameType] ;
           end ;
        end ;

    end ;


procedure TIDRFile.CreateFrameTypeCycle(
          var FrameTypeCycle : Array of Integer ;
          var FrameTypeCycleLength : Integer ) ;
// ------------------------------------------------------------------
// Return multi-wavelength/multi-rate frame type cycle
// ------------------------------------------------------------------
var
     i,j : Integer ;
     LastSlow : Integer ;
begin

    // Determine last slow frame
    i := 0 ;
    LastSlow := 0 ;
    while (FFrameTypeDivideFactor[i] > 1) and (i < FNumFrameTypes) do begin
          LastSlow := i ;
          Inc(i) ;
          end ;

    // Add one cycle of slow rate wavelengths
    FrameTypeCycleLength := 0 ;
    for i := 0 to LastSlow do begin
        FrameTypeCycle[FrameTypeCycleLength] := i ;
        Inc(FrameTypeCycleLength) ;
        end ;

    // Add DivideFactor cycle of fast frames
    for j := 1 to FFrameTypeDivideFactor[0] do begin
        for i := LastSlow+1 to FNumFrameTypes-1 do begin
            FrameTypeCycle[FrameTypeCycleLength] := i ;
            Inc(FrameTypeCycleLength) ;
            end ;
         end ;

    end ;

function TIDRFile.TypeOfFrame( FrameNum : Integer ) : Integer ;
// ------------------------------
// Return type of frame # FrameNum
// -------------------------------
begin
    Result := FFrameTypeCycle[(FrameNum - 1) mod FFrameTypeCycleLength] ;
    end ;

procedure Register;
begin
  RegisterComponents('Samples', [TIDRFile]);
end;

end.
