unit ScopeDisplay;
{ =====================================================
  Oscilloscope Display Component
  (c) J. Dempster, University of Strathclyde, 1999-2001
  =====================================================
  24/1/99 ... Started
  5/3/99 .... Trunc changed to Round
  15/7/99 ... Vertical cursors can now be associated with individual channels
  1/8/99  ... Additional lines no longer displayed in zoom mode
              Channel.CalBars initialised with -1 to indicate no data yet
              FTCalBar now in units of samples rather than time
  6/8/99 .... Multi-record storage mode added
  17/8/99 ... T calibration bar now correct size
  20/8/99 ... PlotRecord now o/p's partial lines to canvas when more than
              16000 points are required, to avoid limitations of Windows polyline function
  27/8/99 ... Grid option added to display
  16/9/99 ... Horizontal cursors now visible only when channel is visible
  26/10/99 ... AddHorizontalCursor now has UseAsZeroLevel flag
               Channel zero levels updated when baseline cursors changed
  10/2/00 .... Bug in Print and CopyImageToClipboard when some channels
               disabled fixed.
  28/2/00 .... Left margin now leaves space for vertical cal. bar. text.

               PrinterShowLabels & PrinterShowZeroLevels added to properties
               Printer top margin now taken into account when setting plot height
  6/3/00  .... CopyImageToClipboard now adjusts pen width correctly
  23/7/00 .... Bug where zoom box jumped to mouse cursor on entry to zoom mode fixed
  4/1/01 ... OnCursorChange now called when returning from zoom to normal display mode
             Traces now restricted to limits of channel area within display
  21/1/01 ... Printer font name now set correctly (DefaultFont object handled correctly)
              Space correctly set for title at top of page
  26/4/01 ... Print and CopyImageToClipboard Left margin now set correctly
              allowing space for calibration labels
  20/7/01 ... CopyDataToClipboard now handles large blocks of data correctly
  14/8/01 ... Array properties shifted to Public to make component compilable under Delphi V5
  5/12/01 ... StorageMode now superimposes traces captured in real-time
  18/2/02 ... FNumPoints now correctly set to zero
  19/3/02 ... Channels now spaced apart vertically, top/bottom grid lines now correctly plotted
              ???Units/Div calibrations added to channel name labels
  26/10/02 ... Trails left when moving zoom box fixed
               Cursors no longer disappear when superimposed
               An internal bitmap now used to hold image upon which cursors are superimoposed
  29/10/02 ... Display corruption caused by superimposed windows fixed
  8/12/02 .... OnCursorChange now only called in normal (not zoom) display mode
               Horizontal cursors displayed with pen in pmMASK mode
  12/12/02 ... Downward shift of top margin with repeated printing fixed.
  12.02.03 ... Zero baseline cursors now displayed in a different colour
               to indicate when zero level is not a true ADC=0 level.
  3.04.03 .... Error when no printers are defined now fixed
  18.05.03 ... Marker text can be added to bottom of display
  24.04.03 ... Number of horizontal and vertical grid lines can be changed
  04.11.03 ... Display calibration now displays 1000s
  06.11.03 ... Vertical grid spacing now correct when MaxPoints is small value
  20.11.03 ... Divide error when xMax = xMin fixed
  03.02.04 ... Vertical cursors can now be moved using keyboard arrows
               without a trail being left on the screen (MoveActiveCursor)
  21.11.04 ... Max. no.of points increased to 131072
  20.06.05 ... Colour of vertical cursor can now be defined  again
               Selected pair of vertical cursors can be linked with a hor. line
               at bottom of display area (LinkVerticalCursors())
  23.09.05 ... .ZoomIn and .ZoomOut added
  02.11.05 ... .LinkVerticalCursors added
               Pairs of vertical cursors can now be linked with a horizontal line
               Cursor labels now appear below X axis
               Cursors now drawn in overwrite mode
  18.11.05 ... Horizontal cursor labels added
  05.01.06 ... XAxis scaling now updated in ClearDisplay for all channels
               not just displayed ones.
  24/11/06 ... Width parameter added to CreateLine method
               KeepPens now .Assigned correctly
  03/07/07 ... Upper/lower limits of display now calibrated
  20/07/07 ... Zoom selection no longer flickers during live update
  04.09.07 ... Zoom window must now be larger than 8x8 pixels
               XMin,XMax,YMin,YMax limits cannot now be set equal
  01.05.08 ... Vertical cursor readout limited to buffer size.
  09.06.08 ... Cursor readout shows 5 digits
  07.07.08 ... Y axis calibration ticks now units of X1,X2,X5 ...
               Y axis size can be varied for each channel
               Channel display disable button added
  05.09.08 ... Channel Y axis resizing no longer evoked by unintentional mouse up
               on first display of trace. Vertical cursors no longer displayed
               when outside selected display area
  04.12.08 ... Trace no longer plotted outside left and right margins during live updates
               of displays within zoomed in X axes
  29.03.10 ... '?a' vertical cursor type which displays time at cursor
  20.04.10 ... ? query cursors updated. Now displays any combination of
                 ?t time, ?y signal amplitude and ?i sample index, ?r time relative to cursor 0
  24.05.10 ... Max. number of display channels increased to 32
  05.08.10 ... Memory violations when ?y vertical cursors created with no buffers allocated fixed
               Channel display tick box shifted down to avoid overlap with Y axis names
  07.09.10 ... JD ?t cursor now includes starting time of record (defined by XOFFSET) in time reading
  17.09.10 ... JD cursor readout format adjusted to %6.5g to ensure that zero values do not appears as blanks
  06.01.11 ... JD FP error trapped when ADCScale factors are negative
  12.07.11 ... JD Horizontal display zoom/move button now in fixed place
                  no longer move when left hand time label changes size
  22.08.11 ... JD Channel display enable/disable buttons no longer
                  drop off bottom of display when several channels disabled.
                  Horizontal time access now has automatic tick calibration markers
  23.09.11 ... JD Marker text now displayed again
  25.09.11 ... JD Tex font size can now be set on object Inspector panel
  15.11.11 ... JD CopyDataToClipboard now also copies FLINE external line data points
  26.07.12 ... JD time calibration bar in print and clipboard images no longer has excessive digits
  04.09.12 ... JD Vertical tickmarks now computed correctly when Y axis scaling factor is negative
  13.11.13 ... JD .CopyDataToClipboard Line written limited to number of time points available
  11.06.14 ... JD Ratio channel names can now be split over two line by including '/' separator
  22.06.14 ... JD DrawVerticalCursor() Vertical cursor no longer disappears when dragged to right
                  edge of display
  06.07.15 ... JD No. of trace points displayed now limited to 2X no of X x pixels to
                  improve performance of plotting when very large traces plotted
  22.07.15 ... JD Up to 32 lines can now be added display.
  24.07.15 ... JD Length of vertical cursors now restricted to top - bottom of displayed traces.
                  SetChanVisible() now invalidates display to force update
  04.08.15 ... JD PlotRecords() now plots traces correctly on clipboard and to printer.
                  Fixes problem introduced 06.07.15
  07.08.15 ... JD .MaxPoints no longer limited to 131072
  10.08.15 ... JD .PlotRecord now correctly displays min/max points for large records (rather than just min.)
  17.08.15 ... JD Added lines no longer printed or copied to clipboard on non-visible channels
  14.09.15 ... JD Gaps in display traces when updating fixed.
  29.09.15 ... JD Cursor link line now displays correctly when all-channel spanning cursors mode in use
                  trailing ', ' now removed from cursor text.
  16.10.15 ... JD Data exported to clipboard now min/max compressed to less than 20000 points.
  08.02.16 ... JD .GridSpacing added to channel object (indicates vertical interval between horizontal grid lines
  02.03.16 ... JD Time calibration bar shifted down one line for image copy and print out to avoid
                  potential overlap of annotations
                  TimeGridSpacing property added
                  Printer exception when no default printer set or printers available now handled
                  allowing printer margins to be set without exception halting application
  16.03.16 ... JD StorageMode updated. StorageMode=TRUE now works correctly again superimposing
                  traces on screen
  27.10.16 ... JD Support for single, double floating point and 8 byte integer arrays added
                  .FloatingPointSamples property added
  04.11.16 ... JD ADCZero and cursors position properties now single type rather than integer
  03.07.19 ... JD ?yd1 and ?yd2 1 and 2 fixed decimal place cursor readout format added
  25.05.21 ... JD SaveToFile public procedure added
  17.01.22 ... JD System.IO.TPath function now used to get temporary file name
  }

interface

uses
  System.IOUtils, Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Clipbrd, printers, mmsystem, math, strutils, types, uitypes ;
const
     ScopeChannelLimit = 31 ;
     AllChannels = -1 ;
     NoRecord = -1 ;
     MaxStoredRecords = 200 ;
     MaxPoints = 131072 ;
     ScopeDisplayMaxPoints = 131072 ;
     MaxVerticalCursorLinks = 32 ;
     MaxScopeLines = 32 ;
type
    TPointArray = Array[0..MaxPoints-1] of TPoint ;
    TSinglePoint = record
        x : single ;
        y : single ;
        end ;
    TSinglePointArray = Array[0..MaxPoints-1] of TSinglePoint ;
    TScopeSingleArray = Array[0..MaxPoints-1] of Single ;
    PScopeSingleArray = ^TScopeSingleArray  ;

    TScopeLine = record
      Channel : Integer ;
      x : PScopeSingleArray ;
      y : PScopeSingleArray ;
      Count : integer ;
      Pen : TPen ;
      end ;

    TScopeChannel = record
         xMin : single ;
         xMax : single ;
         yMin : single ;
         yMax : single ;
         xScale : single ;
         yScale : single ;
         Left : Integer ;
         Right : Integer ;
         Top : Integer ;
         Bottom : Integer ;
         ADCUnits : string ;
         ADCName : string ;
         ADCScale : single ;
         ADCZero : single ;
         ADCZeroAt : Integer ;
         CalBar : single ;
         InUse : Boolean ;
         ADCOffset : Integer ;
         color : TColor ;
         Position : single ;
         ChanNum : Integer ;
         ZeroLevel : Boolean ;
         YSize : Single ;
         xLast : Integer ;
         yLast : single ;
         GridSpacing : single ;
         end ;
    TMousePos = ( TopLeft,
              TopRight,
              BottomLeft,
              BottomRight,
              MLeft,
              MRight,
              MTop,
              MBottom,
              MDrag,
              MNone ) ;

  TScopeDisplayZoomButtonList = record
      Rect : TRect ;
      ButtonType : Integer ;
      ChanNum : Integer ;
      end ;

  TScopeDisplay = class(TGraphicControl)
  private
    { Private declarations }
    FMinADCValue : Integer ;   // Minimum A/D sample value
    FMaxADCValue : Integer ;   // Maximum A/D sample value
    FNumChannels : Integer ;   // No. of channels in display
    FNumPoints : Integer ;     // No. of points displayed
    FMaxPoints : Integer ;     // Max. display points allowed
    FXMin : Integer ;          // Index of first sample in buffer on display
    FXMax : Integer ;          // Index of last sample in buffer on display
    FXOffset : Integer ;       // User-settable offset added to sample index numbers
                               // when computing sample times

    Channel : Array[0..ScopeChannelLimit] of TScopeChannel ;
    FTimeGridSpacing : single ;   // Spacing between vertical grid lines (s)
    HorCursors : Array[0..ScopeChannelLimit] of TScopeChannel ;
    VertCursors : Array[0..64] of TScopeChannel ;
    FNumVerticalCursorLinks : Integer ;
    FLinkVerticalCursors : Array[0..2*MaxVerticalCursorLinks-1] of Integer ;
    FChanZeroAvg : Integer ;
    FTopOfDisplayArea : Integer ;
    FBottomOfDisplayArea : Integer ;
    FBuf : Pointer ;
    FNumBytesPerSample : Integer ;
    FFloatingPointSamples : Boolean ; // TRue = floating point samples

    FCursorsEnabled : Boolean ;
    FHorCursorActive : Boolean ;
    FHorCursorSelected : Integer ;
    FVertCursorActive : Boolean ;
    FVertCursorSelected : Integer ;
    FLastVertCursorSelected : Integer ;
    FZoomCh : Integer ;
    FMouseOverChannel : Integer ;
    FBetweenChannel : Integer ;
    FZoomDisableHorizontal : Boolean ;
    FZoomDisableVertical : Boolean ;
    FDisableChannelVisibilityButton : Boolean ;
    FTScale : single ;
    FTUnits : string ;
    FTCalBar : single ;
    FFontSize : Integer ;
    FOnCursorChange : TNotifyEvent ;
    FCursorChangeInProgress : Boolean ;
    { Printer settings }
    FPrinterFontSize : Integer ;
    FPrinterPenWidth : Integer ;
    FPrinterFontName : string ;
    FPrinterLeftMargin : Integer ;
    FPrinterRightMargin : Integer ;
    FPrinterTopMargin : Integer ;
    FPrinterBottomMargin : Integer ;
    FPrinterDisableColor : Boolean ;
    FPrinterShowLabels : Boolean ;
    FPrinterShowZeroLevels : Boolean ;
    FMetafileWidth : Integer ;
    FMetafileHeight : Integer ;
    FTitle : TStringList ;
    { Additional line }
    FLines : Array[0..MaxScopeLines] of TScopeLine ;
//    FLineCount : Integer ;
//    FLineChannel : Integer ;
//    FLinePen : TPen ;
    { Display storage mode internal variables }
    FStorageMode : Boolean ;
    FStorageFileName : String ;
    FStorageFile : TFileStream ;

    FStorageList : Array[0..MaxStoredRecords-1] of Integer ; // storage mode list
    FStorageListIndex : Integer ;                            // Last storage list element used index
    FRecordNum : Integer ;
    FDrawGrid : Boolean ;

    //Display settings
    FGridColor : TColor ;         // Calibration grid colour
    FTraceColor : TColor ;        // Trace colour
    FBackgroundColor : TColor ;   // Background colour
    FCursorColor : TColor ;       // Cursors colour
    FNonZeroHorizontalCursorColor : TColor ; // Cursor colour
    FZeroHorizontalCursorColor : TColor ;

    FFixZeroLevels : Boolean ; // True = Zero level cursors fixed at true zero

    FDisplaySelected : Boolean ;

    FMouseDown : Boolean ;

    BackBitmap : TBitMap ;        // Display background bitmap (traces/grid)
    ForeBitmap : TBitmap ;        // Display foreground bitmap (cursors)
    DisplayRect : TRect ;         // Rectangle defining size of display area

    FMarkerText : TStringList ;   // Marker text list

    MouseX : Integer ;            // Last know mouse X position
    MouseY : Integer ;            // Last know mouse Y position

    ZoomRect : TRect ;
    ZoomRectCount : Integer ;
    ZoomChannel : Integer ;
    ZoomButtonList : Array[0..100] of TScopeDisplayZoomButtonList ;
    NumZoomButtons : Integer ;

    PrinterException : Boolean ;

    { -- Property read/write methods -------------- }

    procedure SetNumChannels(Value : Integer ) ;
    procedure SetNumPoints( Value : Integer ) ;
    procedure SetMaxPoints( Value : Integer ) ;

    procedure SetChanName( Ch : Integer ; Value : string ) ;
    function  GetChanName( Ch : Integer ) : string ;

    procedure SetChanUnits( Ch : Integer ; Value : string ) ;
    function  GetChanUnits( Ch : Integer ) : string ;

    procedure SetChanScale( Ch : Integer ; Value : single ) ;
    function  GetChanScale( Ch : Integer ) : single ;

    procedure SetChanCalBar( Ch : Integer ; Value : single ) ;
    function GetChanCalBar( Ch : Integer ) : single ;

    procedure SetChanZero( Ch : Integer ; Value : single ) ;
    function GetChanZero( Ch : Integer ) : single ;

    procedure SetChanZeroAt( Ch : Integer ; Value : Integer ) ;
    function GetChanZeroAt( Ch : Integer ) : Integer ;

    procedure SetChanZeroAvg( Value : Integer ) ;

    procedure SetChanOffset( Ch : Integer ; Value : Integer ) ;
    function GetChanOffset( Ch : Integer ) : Integer ;

    procedure SetChanVisible( Ch : Integer ; Value : boolean ) ;
    function GetChanVisible( Ch : Integer ) : Boolean ;

    procedure SetChanColor( Ch : Integer ; Value : TColor ) ;
    function GetChanColor( Ch : Integer ) : TColor ;

    function GetChanGridSpacing( Ch : Integer ) : Single ;

    procedure SetXMin( Value : Integer ) ;
    procedure SetXMax( Value : Integer ) ;
    procedure SetYMin( Ch : Integer ; Value : single ) ;
    function GetYMin( Ch : Integer ) : single ;
    procedure SetYMax( Ch : Integer ; Value : single ) ;
    function GetYMax( Ch : Integer ) : single ;
    procedure SetYSize( Ch : Integer ; Value : single ) ;
    function GetYSize( Ch : Integer ) : single ;

    procedure SetHorCursor( iCursor : Integer ; Value : single ) ;
    function GetHorCursor( iCursor : Integer ) : single ;
    procedure SetVertCursor( iCursor : Integer ; Value : single ) ;
    function GetVertCursor( iCursor : Integer ) : single ;

    procedure SetPrinterFontName( Value : string ) ;
    function GetPrinterFontName : string ;

    procedure SetPrinterLeftMargin( Value : Integer ) ;
    function GetPrinterLeftMargin : integer ;

    procedure SetPrinterRightMargin( Value : Integer ) ;
    function GetPrinterRightMargin : integer ;

    procedure SetPrinterTopMargin( Value : Integer ) ;
    function GetPrinterTopMargin : integer ;

    procedure SetPrinterBottomMargin( Value : Integer ) ;
    function GetPrinterBottomMargin : integer ;

    function GetXScreenCoord( Value : Integer ) : Integer ;

    procedure SetStorageMode( Value : Boolean ) ;

    procedure SetGrid( Value : Boolean ) ;

    function GetNumVerticalCursors : Integer ;
    function GetNumHorizontalCursors : Integer ;

    procedure SetFixZeroLevels( Value : Boolean ) ;

    { -- End of property read/write methods -------------- }


    { -- Methods used internally by component ------------ }

    function IntLimitTo( Value : Integer ; Lo : Integer ;  Hi : Integer ) : Integer ;
    procedure DrawHorizontalCursor( Canv : TCanvas ; iCurs : Integer ) ;
    function ProcessHorizontalCursors( X : Integer ; Y : Integer ) : Boolean ;
    procedure DrawVerticalCursor( Canv : TCanvas ; iCurs : Integer ) ;
    procedure DrawVerticalCursorLink( Canv : TCanvas ) ;

    function ProcessVerticalCursors( X : Integer ; Y : Integer )  : Boolean ;
    function XToCanvasCoord( var Chan : TScopeChannel ; Value : single ) : Integer  ;
    function CanvasToXCoord( var Chan : TScopeChannel ; xPix : Integer ) : Integer  ;
    function YToCanvasCoord( var Chan : TScopeChannel ; Value : single ) : Integer  ;
    function CanvasToYCoord( var Chan : TScopeChannel ; yPix : Integer ) : Integer  ;
    procedure PlotRecord( Canv : TCanvas ;
                          var Channels : Array of TScopeChannel ;
                          var xy : Array of TPoint ) ;

    procedure CodedTextOut(
              Canvas : TCanvas ;
              var LineLeft : Integer ;
              var LineYPos : Integer ;
              List : TStringList
              ) ;

    procedure ClearDisplay( Canv : TCanvas ) ;

    procedure DrawZoomButton(
              var CV : TCanvas ;
              X : Integer ;
              Y : Integer ;
              Size : Integer ;
              ButtonType : Integer ;
              ChanNum : Integer
              ) ;
    procedure CheckZoomButtons ;
    procedure ShowSelectedZoomButton ;
    procedure ProcessZoomBox ;
    procedure ResizeZoomBox(
              X : Integer ;
              Y : Integer ) ;

    procedure UpdateChannelYSize(
              X : Integer ;
              Y : Integer
              ) ;


  protected
    { Protected declarations }
    procedure Paint ; override ;
    procedure MouseMove( Shift: TShiftState; X, Y: Integer ); override ;
    procedure MouseDown( Button: TMouseButton; Shift: TShiftState;X, Y: Integer ); override ;
    procedure MouseUp(Button: TMouseButton;Shift: TShiftState;X, Y: Integer ); override ;
    procedure DblClick ; override ;
    procedure Click ; override ;


  public
    { Public declarations }
    Constructor Create(AOwner : TComponent) ; override ;
    Destructor Destroy ; override ;
    procedure Invalidate ; override ;
    procedure ClearHorizontalCursors ;
    function AddHorizontalCursor( iChannel : Integer ;
                                  Color : TColor ;
                                  UseAsZeroLevel : Boolean ;
                                  CursorText : String
                                  ) : Integer ;
    procedure ClearVerticalCursors ;
    function AddVerticalCursor( Chan : Integer ;
                                Color : TColor ;
                                CursorText : String ) : Integer ;
    procedure MoveActiveVerticalCursor( Step : Integer ) ;
    procedure LinkVerticalCursors( C0 : Integer ; C1 : Integer ) ;

    procedure ZoomIn( Chan : Integer ) ;
    procedure ZoomOut ;

    procedure XZoom( PercentChange : Single ) ;
    procedure YZoom( Chan : Integer ; PercentChange : Single ) ;

    procedure SetDataBuf( Buf : Pointer ) ;
    procedure CopyDataToClipBoard ;
    procedure CopyImageToClipBoard ;
    procedure SaveDataToFile( FileName : string ) ;
    procedure Print ;
    procedure ClearPrinterTitle ;
    procedure AddPrinterTitleLine( Line : string);
    function CreateLine(
             Ch : Integer ;                    { Display channel to be drawn on [IN] }
             iColor : TColor ;                 { Line colour [IN] }
             iStyle : TPenStyle ;               { Line style [IN] }
             Width : Integer                   // Line width (IN)
             ) : Integer ;
    procedure AddPointToLine(
              iLine : Integer ;
              x : single ;
              y : single
              ) ;

    procedure ClearLines ;

    procedure DisplayNewPoints( NewPoints : Integer ) ;


    procedure AddMarker ( AtPoint : Integer ; Text : String ) ;
    procedure ClearMarkers ;

    function XToScreenCoord(Chan : Integer ;Value : single ) : Integer  ;
    function YToScreenCoord(Chan : Integer ;Value : single ) : Integer  ;
    function ScreenCoordToX(Chan : Integer ;Value : Integer ) : single ;
    function ScreenCoordToY(Chan : Integer ;Value : Integer ) : single ;

    property ChanName[ i : Integer ] : string read GetChanName write SetChanName ;
    property ChanUnits[ i : Integer ] : string read GetChanUnits write SetChanUnits ;
    property ChanScale[ i : Integer ] : single read GetChanScale write SetChanScale ;
    property ChanCalBar[ i : Integer ] : single read GetChanCalBar write SetChanCalBar ;
    property ChanZero[ i : Integer ] : single read GetChanZero write SetChanZero ;
    property ChanZeroAt[ i : Integer ] : Integer read GetChanZeroAt write SetChanZeroAt ;
    property ChanZeroAvg : Integer read FChanZeroAvg write SetChanZeroAvg ;
    property ChanOffsets[ i : Integer ] : Integer read GetChanOffset write SetChanOffset ;
    property ChanVisible[ i : Integer ] : boolean read GetChanVisible write SetChanVisible ;
    property ChanColor[ i : Integer ] : TColor read GetChanColor write SetChanColor ;
    property ChanGridSpacing[ i : Integer ] : single read GetChanGridSpacing ;
    property TimeGridSpacing : single read FTimeGridSpacing ;

    property YSize[ i : Integer ] : Single read GetYSize write SetYSize ;
    property YMin[ i : Integer ] : single read GetYMin write SetYMin ;
    property YMax[ i : Integer ] : single read GetYMax write SetYMax ;
    property XScreenCoord[ Value : Integer ] : Integer read GetXScreenCoord ;
    property HorizontalCursors[ i : Integer ] : single
             read GetHorCursor write SetHorCursor ;
    property VerticalCursors[ i : Integer ] : single
             read GetVertCursor write SetVertCursor ;

  published
    { Published declarations }
    property DragCursor ;
    property DragMode ;
    property OnDragDrop ;
    property OnDragOver ;
    property OnEndDrag ;
    property OnMouseDown ;
    property OnMouseMove ;
    property OnMouseUp ;
    property OnCursorChange : TNotifyEvent
             read FOnCursorChange write FOnCursorChange ;
    property CursorChangeInProgress : Boolean
             read FCursorChangeInProgress write FCursorChangeInProgress ;
    property Height default 150 ;
    property Width default 200 ;
    Property NumChannels : Integer Read FNumChannels write SetNumChannels ;
    Property NumPoints : Integer Read FNumPoints write SetNumPoints ;
    Property MaxPoints : Integer Read FMaxPoints write SetMaxPoints ;
    property XMin : Integer read FXMin write SetXMin ;
    property XMax : Integer read FXMax write SetXMax ;
    property XOffset : Integer read FXOffset write FXOffset ;
    property CursorsEnabled : Boolean read FCursorsEnabled write FCursorsEnabled ;

    property ActiveHorizontalCursor : Integer read FHorCursorSelected ;
    property ActiveVerticalCursor : Integer read FHorCursorSelected ;
    property TScale : single read FTScale write FTScale ;
    property TUnits : string read FTUnits write FTUnits ;
    property TCalBar : single read FTCalBar write FTCalBar ;
    property ZoomDisableHorizontal : Boolean
             read FZoomDisableHorizontal write FZoomDisableHorizontal ;
    property ZoomDisableVertical : Boolean
             read FZoomDisableVertical write FZoomDisableVertical ;
    property DisableChannelVisibilityButton : Boolean
             read FDisableChannelVisibilityButton
             write FDisableChannelVisibilityButton ;
    property PrinterFontSize : Integer read FPrinterFontSize write FPrinterFontSize ;
    property PrinterFontName : string
             read GetPrinterFontName write SetPrinterFontName ;
    property PrinterPenWidth : Integer
             read FPrinterPenWidth write FPrinterPenWidth ;
    property PrinterLeftMargin : Integer
             read GetPrinterLeftMargin write SetPrinterLeftMargin ;
    property PrinterRightMargin : Integer
             read GetPrinterRightMargin write SetPrinterRightMargin ;
    property PrinterTopMargin : Integer
             read GetPrinterTopMargin write SetPrinterTopMargin ;
    property PrinterBottomMargin : Integer
             read GetPrinterBottomMargin write SetPrinterBottomMargin ;
    property PrinterDisableColor : Boolean
             read FPrinterDisableColor write FPrinterDisableColor ;
    property PrinterShowLabels : Boolean
             read FPrinterShowLabels write FPrinterShowLabels ;
    property PrinterShowZeroLevels : Boolean
             read FPrinterShowZeroLevels write FPrinterShowZeroLevels ;

    property MetafileWidth : Integer
             read FMetafileWidth write FMetafileWidth ;
    property MetafileHeight : Integer
             read FMetafileHeight write FMetafileHeight ;
    property StorageMode : Boolean
             read FStorageMode write SetStorageMode ;
    property RecordNumber : Integer
             read FRecordNum write FRecordNum ;
    property DisplayGrid : Boolean
             Read FDrawGrid Write SetGrid ;
    property MaxADCValue : Integer
             Read FMaxADCValue write FMaxADCValue ;
    property MinADCValue : Integer
             Read FMinADCValue write FMinADCValue ;
    property NumVerticalCursors : Integer read GetNumVerticalCursors ;
    property NumHorizontalCursors : Integer read GetNumHorizontalCursors ;
    property NumBytesPerSample : Integer read FNumBytesPerSample write FNumBytesPerSample ;
    property FloatingPointSamples : Boolean read FFloatingPointSamples write FFloatingPointSamples ;
    property FixZeroLevels : Boolean read FFixZeroLevels write SetFixZeroLevels ;
    property DisplaySelected : Boolean
             read FDisplaySelected write FDisplaySelected ;
    property FontSize : Integer
             read FFontSize write FFontSize ;
  end;

procedure Register;

implementation
const
    LeftEdgeSpace = 70 ;
    RightEdgeSpace = 20 ;
    cZoomInButton = 0 ;
    cZoomOutButton = 1 ;
    cZoomUpButton = 2 ;
    cZoomDownButton = 3 ;
    cZoomLeftButton = 4 ;
    cZoomRightButton = 5 ;
    cEnabledButton = 6 ;

type
    TSmallIntArray = Array[0..$FFFFFF] of SmallInt ;
    PSmallIntArray = ^TSmallIntArray ;
    TIntArray = Array[0..$FFFFFF] of Integer ;
    PIntArray = ^TIntArray ;
    TSingleArray = Array[0..$FFFFFF] of Single ;
    PSingleArray = ^TSingleArray ;
    TDoubleArray = Array[0..$FFFFFF] of Single ;
    PDoubleArray = ^TSingleArray ;

function GetSample(
         Buf : Pointer ;                 // Pointer to start of buffer
         i : Integer ;                   // Index of sample
         NumBytesPerSample : Integer ;   // No. bytes per sample
         FloatingPointSamples : Boolean  // TRUE = floating point format
         ) : Single ; Inline ;
// ---------------------------
// Get sample value from array
// ---------------------------
begin
    if FloatingPointSamples then
       begin
       // Floating point data
       case NumBytesPerSample of
            4 : Result := PSingleArray(Buf)^[i] ;
            8 : Result := PDoubleArray(Buf)^[i] ;
            else Result := 0 ;
            end ;
       end
    else
       begin
       // Int
       case NumBytesPerSample of
            2 : Result := PSmallIntArray(Buf)^[i] ;
            4 : Result := PIntArray(Buf)^[i] ;
            else Result := 0 ;
            end ;
       end ;
    end;




procedure Register;
begin
  RegisterComponents('Samples', [TScopeDisplay]);
end;


constructor TScopeDisplay.Create(AOwner : TComponent) ;
{ --------------------------------------------------
  Initialise component's internal objects and fields
  -------------------------------------------------- }
var
   i,ch : Integer ;
begin

     inherited Create(AOwner) ;

     { Set opaque background to minimise flicker when display updated }
     ControlStyle := ControlStyle + [csOpaque] ;

     BackBitmap := TBitMap.Create ;
     ForeBitmap := TBitMap.Create ;
     BackBitmap.Width := Width ;
     BackBitmap.Height := Height ;
     ForeBitmap.Width := Width ;
     ForeBitmap.Height := Height ;

     { Create a list to hold any printer title strings }
     FTitle := TStringList.Create ;

     { Create an empty line array }
     for i := 0 to High(FLines) do begin
       FLines[i].Channel := 0 ;
       FLines[i].X := Nil ;
       FLines[i].Y := Nil ;
       FLines[i].Count := 0 ;
       FLines[i].Pen := TPen.Create ;
       FLines[i].Pen.Assign(Canvas.Pen) ;
       end;
{     FLine := Nil ;
     FLineCount := 0 ;
     FLineChannel := 0 ;
     FLinePen := TPen.Create;
     FLinePen.Assign(Canvas.Pen) ;}

     FGridColor := clLtGray ;
     FTraceColor := clBlue ;
     FBackgroundColor := clWhite ;
     FCursorColor := clNavy ;
     FNonZeroHorizontalCursorColor := clRed ;
     FZeroHorizontalCursorColor := clGreen ;

     FMouseDown := False ;

     Width := 200 ;
     Height := 150 ;
     { Create internal objects used by control }

     FMinADCValue := -32768 ;
     FMaxADCValue := 32768 ;

     FNumChannels := 1 ;
     FNumPoints := 0 ;
     FMaxPoints := 1024 ;
     FXMin := 0 ;
     FXMax := FMaxPoints - 1 ;
     FXOffset := 0 ;
     FTimeGridSpacing := 0.0 ;
     FChanZeroAvg := 20 ;
     FBuf := Nil ;
     FNumBytesPerSample := 2 ;
     FFloatingPointSamples := False ;
     for ch := 0 to High(Channel) do
         begin
         Channel[ch].InUse := True ;
         Channel[ch].ADCName := format('Ch.%d',[ch]) ;
         Channel[ch].ADCUnits := '' ;
         Channel[ch].YMin := FMinADCValue ;
         Channel[ch].YMax := FMaxADCValue ;
         Channel[ch].ADCScale := 1.0 ;
         Channel[ch].XMin := FXMin ;
         Channel[ch].XMax := FXMax ;
         Channel[ch].ADCOffset := ch ;
         Channel[Ch].CalBar := -1.0 ;    { <0 indicates no value entered yet }
         Channel[ch].Color := FTraceColor ;
         Channel[ch].ADCZeroAt := -1 ;
         Channel[ch].YSize := 1.0 ;
         end ;

     for i := 0 to High(HorCursors) do HorCursors[i].InUse := False ;
     for i := 0 to High(VertCursors) do VertCursors[i].InUse := False ;
     FNumVerticalCursorLinks := 0 ;

    FCursorsEnabled := True ;
    FHorCursorActive := False ;
    FHorCursorSelected := -1 ;
    FVertCursorActive := False ;
    FVertCursorSelected := -1 ;
    FLastVertCursorSelected := 0 ;
    FOnCursorChange := Nil ;
    FCursorChangeInProgress := False ;
    FFixZeroLevels := False ;

    FTopOfDisplayArea := 0 ;
    FBottomOfDisplayArea := Height ;
    FZoomCh := 0 ;
    FMouseOverChannel := 0 ;
    FBetweenChannel := -1 ;
    FZoomDisableHorizontal := False ;
    FZoomDisableVertical := False ;
    FDisableChannelVisibilityButton := False ;
    FTUnits := 's' ;
    FTScale := 1.0 ;
    FTCalBar := -1.0 ;
    FFontSize := 8 ;
    FPrinterDisableColor := False ;
    FPrinterShowLabels := True ;
    FPrinterShowZeroLevels := True ;

    { Create file for holding records in stored display mode }
    FStorageMode := False ;
    FStorageFile := Nil ;
    for i := 1 to High(FStorageList) do FStorageList[i] := NoRecord ;
    FStorageListIndex := 0 ;
    FRecordNum := NoRecord ;

    FDrawGrid := True ;

    // Create marker text list
    FMarkerText := TStringList.Create ;

    FDisplaySelected := False ;

    ZoomRectCount := 0 ;
    NumZoomButtons := 0 ;
    PrinterException := False ;

    end ;


destructor TScopeDisplay.Destroy ;

{ ------------------------------------
   Tidy up when component is destroyed
   ----------------------------------- }
var
  i: Integer;
begin
     { Destroy internal objects created by TScopeDisplay.Create }
     FBuf := Nil ;

     BackBitmap.Free ;  // Free internal bitmap
     ForeBitmap.Free ;

     { Call inherited destructor }
     inherited Destroy ;

     FTitle.Free ;
//     FLinePen.Free ;

     for i := 0 to High(FLines) do
        begin
        FLines[i].Pen.Free ;
        if FLines[i].x <> Nil then  Dispose(FLines[i].x) ;
        if FLines[i].y <> Nil then  Dispose(FLines[i].y) ;
        end;

     if FStorageFile <> Nil then
        begin
        FStorageFile.Destroy ;
        DeleteFile( FStorageFileName ) ;
        FStorageFile := Nil ;
        end ;
//     if FLine <> Nil then Dispose(FLine) ;

     FMarkerText.Free ;

     end ;


procedure TScopeDisplay.Paint ;
{ ---------------------------
  Draw signal on display area
  ---------------------------}
const
     pFilePrefix : PChar = 'SCD' ;
var
   i,j,ch,Rec,NumBytesPerRecord,iChan : Integer ;

   SaveColor : TColor ;
   KeepPen : TPen ;
   KeepColor : Array[0..ScopeChannelLimit] of TColor ;
   xy : ^TPointArray ;
   InList : Boolean ;
begin

     { Create plotting points array }
     New(xy) ;
     KeepPen := TPen.Create ;

     // Keep within valid limits
     Top := Max( Top, 2 ) ;
     Left := Max( Left, 2 ) ;
     Height := Max( Height,2 ) ;
     Width := Max( Width,2 ) ;

     try

        // Make bit map same size as control
        if (BackBitmap.Width <> Width) or
           (BackBitmap.Height <> Height) then
           begin
           BackBitmap.Width := Width ;
           BackBitmap.Height := Height ;
           ForeBitmap.Width := Width ;
           ForeBitmap.Height := Height ;
           end ;

        DisplayRect := Rect(0,0,Width-1,Height-1) ;

        // Set colours
        BackBitmap.Canvas.Pen.Color := FTraceColor ;
        BackBitmap.Canvas.Brush.Color := FBackgroundColor ;

        // Clear display, add grid and labels
        ClearDisplay( BackBitmap.Canvas ) ;

        { Display records in storage list }
        if FStorageMode then
           begin

           { Create a temporary storage file, if one isn't already open }
           if FStorageFile = Nil then
              begin
              FStorageFileName := System.IOUtils.TPath.GetTempFileName ;
              FStorageFile := TFileStream.Create( FStorageFileName, fmCreate ) ;
              end ;

           NumBytesPerRecord := FNumChannels*FNumPoints*2 ;

           { Save current record as first record in file }
           FStorageFile.Seek( 0, soFromBeginning ) ;
           FStorageFile.Write( FBuf^, NumBytesPerRecord ) ;

           { Change colour of stored records }
           for ch := 0 to FNumChannels-1 do
               begin
               KeepColor[Ch] := Channel[Ch].Color ;
               Channel[Ch].Color := clAqua ;
               end ;

           { Display old records stored in file }
           for Rec := 1 to High(FStorageList) do if FStorageList[Rec] <> NoRecord
               then
               begin
               FStorageFile.Read( FBuf^, NumBytesPerRecord ) ;
               PlotRecord( BackBitmap.Canvas, Channel, xy^) ;
               end ;

           { Restore colour }
           for ch := 0 to FNumChannels-1 do Channel[Ch].Color := KeepColor[Ch] ;

           { Retrieve current record }
           FStorageFile.Seek( 0, soFromBeginning ) ;
           FStorageFile.Read( FBuf^, NumBytesPerRecord ) ;

           // Determine whether current record is already in list
           InList := False ;
           for Rec := 1 to High(FStorageList) do
               if FStorageList[Rec] = FRecordNum then InList := True ;

           // Add to list (if it is a valid record)
           if (not InList) and (FRecordNum <> NoRecord) then
              begin
              Inc(FStorageListIndex) ;
              FStorageListIndex := Min(Max(1,FStorageListIndex),High(FStorageList)) ;
              FStorageList[FStorageListIndex] := FRecordNum ;
              FStorageFile.Seek( FStorageListIndex*NumBytesPerRecord, soFromBeginning ) ;
              FStorageFile.Write( FBuf^, NumBytesPerRecord ) ;
              end ;

           end ;

        PlotRecord( BackBitmap.Canvas, Channel, xy^ ) ;

       { Plot external line on selected channel }
       for i := 0 to High(FLines) do if (FLines[i].Count > 0) then
          begin
          iChan := FLines[i].Channel ;
          if Channel[iChan].InUse then
             begin
             KeepPen.Assign(BackBitmap.Canvas.Pen) ;
             BackBitmap.Canvas.Pen.Assign(FLines[i].Pen) ;
             for j := 0 to FLines[i].Count-1 do
                  begin
                  xy^[j].x := XToCanvasCoord( Channel[iChan], FLines[i].x^[j] ) ;
                  xy^[j].y := YToCanvasCoord( Channel[iChan], FLines[i].y^[j] ) ;
                  end ;
             Polyline( BackBitmap.Canvas.Handle, xy^, FLines[i].Count ) ;
             BackBitmap.Canvas.Pen.Assign(KeepPen) ;
             end ;
          end ;

        // Copy from internal bitmap to control
        Canvas.CopyRect( DisplayRect, BackBitmap.Canvas, DisplayRect) ;

        // Add cursors or zoom box
        { Horizontal Cursors }
        for i := 0 to High(HorCursors) do if HorCursors[i].InUse
            and Channel[HorCursors[i].ChanNum].InUse then DrawHorizontalCursor(Canvas,i) ;

        // Draw link between selected pair of vertical cursors
        DrawVerticalCursorLink(Canvas) ;

        // Draw red box round display to indicate it is selected

        SaveColor := Canvas.Brush.Color ;
        if FDisplaySelected then
           begin
           Canvas.Brush.Color := clRed ;
           Canvas.FrameRect( DisplayRect );
           Canvas.Brush.Color := SaveColor ;
           end ;

        { Vertical Cursors }
        for i := 0 to High(VertCursors) do if VertCursors[i].InUse then
            DrawVerticalCursor(Canvas,i) ;

        ResizeZoomBox( ZoomRect.Right, ZoomRect.Bottom ) ;

        { Notify a change in cursors }
        if Assigned(OnCursorChange) and
          (not FCursorChangeInProgress) then OnCursorChange(Self) ;

     finally
        { Get rid of array }
        Dispose(xy) ;
        KeepPen.Free ;
        end ;

     end ;


procedure TScopeDisplay.PlotRecord(
          Canv : TCanvas ;                        { Canvas to be plotted on }
          var Channels : Array of TScopeChannel ; { Channel definition array }
          var xy : Array of TPoint ) ;               { Work array }
{ -----------------------------------
  Plot a signal record on to a canvas
  ----------------------------------- }
var
   ch,n,i,j,iStart,iEnd,iStep,iPlot : Integer ;
   XPix,XPixRange,iYMin,iYMax : Integer ;
   YMin,YMax,y : single ;
begin

     // Exit if no buffer
     if FBuf = Nil then Exit ;

     iStart := Round(FXMin) ;
     iEnd := Min(Round(FXMax),FNumPoints-1) ;

     { Plot each active channel }
     for ch := 0 to FNumChannels-1 do if Channels[ch].InUse then
         begin
         Canv.Pen.Color := Channels[ch].Color ;
         n := 0 ;

         XPixRange := Min( XToCanvasCoord( Channels[ch], iEnd ), Channels[ch].Right )
                      - Max( XToCanvasCoord( Channels[ch], iStart ), Channels[ch].Left ) ;
         XPixRange := Max(XPixRange,1) ;

         i := iStart ;
         j := (i*FNumChannels) + Channels[ch].ADCOffset ;
         iStep := Max((iEnd - iStart) div (XPixRange*2),1) ;
         iPlot := iStart ;
         iYMin := 0 ;
         iYMax := 1 ;
         YMin := 1E30 ;
         YMax := -YMin ;
         repeat

             y := GetSample( FBuf, j, FNumBytesPerSample, FFloatingPointSamples ) ;

             if y < Ymin then begin
                iYMin := i ;
                YMin := y ;
                end;
             if y > Ymax then begin
                iYMax := i ;
                YMax := y ;
                end;

             if i = iPlot then begin
                XPix := XToCanvasCoord( Channels[ch], i ) ;
                if iYMin < iYMax then begin
                   xy[n].y := YToCanvasCoord( Channels[ch], yMin) ;
                   xy[n].x := XPix ;
                   Inc(n) ;
                   xy[n].y := YToCanvasCoord( Channels[ch], yMax) ;
                   xy[n].x := XPix ;
                   Channels[ch].xLast := i ;
                   Channels[ch].yLast := yMax ;
                   Inc(n) ;
                   end
                else begin
                   xy[n].y := YToCanvasCoord( Channels[ch], yMax) ;
                   xy[n].x := XPix ;
                   Inc(n) ;
                   xy[n].y := YToCanvasCoord( Channels[ch], yMin) ;
                   xy[n].x := XPix ;
                   Channels[ch].xLast := i ;
                   Channels[ch].yLast := yMin ;
                   Inc(n) ;
                   end ;
                YMin := 1E30 ;
                YMax := -YMin ;
                iPlot := Min(iPlot + iStep,iEnd) ;
                end;

             { If line exceeds 16000 output a partial line to canvas,
               since polyline function seems to be unable to handle more than 16000 points }
             if n > 16000 then begin
                Polyline( Canv.Handle, xy, n ) ;
                xy[0] := xy[n-1] ;
                n := 1 ;
                end ;

             Inc(i) ;
             j := j + FNumChannels ;
             until i >= iEnd ;

         Polyline( Canv.Handle, xy, n ) ;

         // Display lines indicating area from which "From Record" zero level is derived
         if (Channels[ch].ADCZeroAt >= Channels[ch].xMin) and
            ((Channels[ch].ADCZeroAt+FChanZeroAvg) <= Channels[ch].xMax) then begin
            Canv.Pen.Color := FCursorColor ;
            xy[0].x := XToCanvasCoord( Channels[ch],Channels[ch].ADCZeroAt ) ;
            xy[1].x := xy[0].x ;
            xy[0].y := YToCanvasCoord( Channels[ch], Channels[ch].ADCZero ) - 15 ;
            xy[1].y := xy[0].y + 30 ;
            Polyline( Canv.Handle, xy, 2 ) ;

            xy[0].x := XToCanvasCoord( Channels[ch],
                                       Channels[ch].ADCZeroAt + FChanZeroAvg -1) ;
            xy[1].x := xy[0].x ;
            xy[0].y := YToCanvasCoord( Channels[ch], Channels[ch].ADCZero ) - 15 ;
            xy[1].y := xy[0].y + 30 ;
            Polyline( Canv.Handle, xy, 2 ) ;

            end ;
         end ;
     end ;


procedure TScopeDisplay.ClearDisplay(
          Canv : TCanvas               // Canvas to be cleared
          ) ;
{ ---------------------------
  Clear signal display canvas
  ---------------------------}
const
    TickSize = 4 ;
    ButtonSize  = 12 ;
    TickMultipliers : array[0..6] of Integer = (1,2,5,10,20,50,100) ;
var
   CTop,ch,i,NumInUse,AvailableHeight,ChannelHeight,ChannelSpacing,LastActiveChannel : Integer ;
   x,xPix,yPix : Integer ;
   dx : Single ;
   KeepColor : TColor ;
   s : String ;
   XLeft,YMid : Integer ;
   yRange,TickBase,YTick,YTickSize,YTickMin,YTickMax,YScaledMax,YScaledMin : Single ;
   XRange,XTick,XTickSize,XTickMin,XTickMax,XScaledMax,XScaledMin : Single ;
   XAxisAt : Integer ;
   YTotal : Single ;
   iTick, NumTicks,iSlashPos : Integer ;
begin

     Canv.Font.Size := FFontSize ;
     // Clear number of zoom buttons on display
     NumZoomButtons := 0 ;

     { Clear display area }
     Canv.fillrect(DisplayRect);

     { Determine number of channels in use and the height
       available for each channel }
     YTotal := 0.0 ;
     NumInUse := 0 ;
     for ch := 0 to FNumChannels-1 do if Channel[ch].InUse then begin
        Inc(NumInUse) ;
        YTotal := YTotal + Channel[ch].YSize ;
        end ;
     if NumInUse < 1 then begin
        YTotal := 1.0 ;
        end ;

     Canv.Font.Size := FFontSize ;
     Canv.Font.Color := FTraceColor ;
     ChannelSpacing :=  Canv.TextHeight('X') + 1  ;
     AvailableHeight := Height - ((NumInUse+1)*ChannelSpacing)
                        - 2*Canv.TextHeight('X')
                        - ((FNumChannels - NumInUse)*ButtonSize)
                        - 4 - ButtonSize ;

     { Define display area for each channel in use }
     cTop := 4 ;
     FTopOfDisplayArea := cTop ;
     LastActiveChannel := 0 ;
     for ch := 0 to FNumChannels-1 do begin

         // Update X scale for all channels
         Channel[ch].Left := LeftEdgeSpace ;
         Channel[ch].Right := Width - RightEdgeSpace ;
         if FXMax = FXMin then FXMax := FXMin + 1 ;
         Channel[ch].xMin := FXMin ;
         Channel[ch].xMax := FXMax ;
         Channel[ch].xScale := (Channel[ch].Right - Channel[ch].Left) /
                               (FXMax - FXMin ) ;

         // Update y scale for channels in use
         if Channel[ch].InUse then begin
            LastActiveChannel := Ch ;
            ChannelHeight := Round((Channel[ch].YSize/YTotal)*AvailableHeight) ;
            Channel[ch].Top := cTop ;
            Channel[ch].Bottom := Channel[ch].Top + ChannelHeight ;
            if Channel[ch].yMax = Channel[ch].yMin then
               Channel[ch].yMax := Channel[ch].yMin + 1.0 ;
            Channel[ch].yScale := (Channel[ch].Bottom - Channel[ch].Top) /
                                  (Channel[ch].yMax - Channel[ch].yMin ) ;
            cTop := cTop + ChannelHeight + ChannelSpacing ;
            FBottomOfDisplayArea := Channel[ch].Bottom ;
            end
         else begin
            Channel[ch].Top := cTop ;
            Channel[ch].Bottom := Channel[ch].Top + ChannelSpacing ;
            cTop := cTop + ChannelSpacing ;
            FBottomOfDisplayArea := Channel[ch].Bottom ;
            end ;

         end ;

     // Display channel enabled buttons
     Canv.Pen.Color := clBlack ;
     for ch := 0 to FNumChannels-1 do if not FDisableChannelVisibilityButton then
         begin
         YPix := (Channel[ch].Top + Channel[ch].Bottom {- ButtonSize}) div 2 ;
         XPix := 2 ;
         DrawZoomButton( Canv,
                         XPix,
                         YPix,
                         ButtonSize,
                         cEnabledButton,
                         ch ) ;
         end ;

     { Update horizontal cursor limits/scale factors to match channel settings }
     for i := 0 to High(HorCursors) do if HorCursors[i].InUse then
         begin
         HorCursors[i].Left := Channel[HorCursors[i].ChanNum].Left ;
         HorCursors[i].Right := Channel[HorCursors[i].ChanNum].Right ;
         HorCursors[i].Top := Channel[HorCursors[i].ChanNum].Top ;
         HorCursors[i].Bottom := Channel[HorCursors[i].ChanNum].Bottom ;
         HorCursors[i].xMin := Channel[HorCursors[i].ChanNum].xMin ;
         HorCursors[i].xMax := Channel[HorCursors[i].ChanNum].xMax ;
         HorCursors[i].xScale := Channel[HorCursors[i].ChanNum].xScale ;
         HorCursors[i].yMin := Channel[HorCursors[i].ChanNum].yMin ;
         HorCursors[i].yMax := Channel[HorCursors[i].ChanNum].yMax ;
         HorCursors[i].yScale := Channel[HorCursors[i].ChanNum].yScale ;
         end ;

     { Update vertical cursor limits/scale factors  to match channel settings}
     for i := 0 to High(VertCursors) do if VertCursors[i].InUse then begin
         if VertCursors[i].ChanNum >= 0 then
            begin
            { Vertical cursors linked to individual channels }
            VertCursors[i].Left := Channel[VertCursors[i].ChanNum].Left ;
            VertCursors[i].Right := Channel[VertCursors[i].ChanNum].Right ;
            VertCursors[i].Top := Channel[VertCursors[i].ChanNum].Top ;
            VertCursors[i].Bottom := Channel[VertCursors[i].ChanNum].Bottom ;
            VertCursors[i].xMin := Channel[LastActiveChannel].xMin ;
            VertCursors[i].xMax := Channel[LastActiveChannel].xMax ;
            VertCursors[i].xScale := Channel[VertCursors[i].ChanNum].xScale ;
            VertCursors[i].yMin := Channel[LastActiveChannel].yMin ;
            VertCursors[i].yMax := Channel[LastActiveChannel].yMax ;
            VertCursors[i].yScale := Channel[VertCursors[i].ChanNum].yScale ;
            end
         else begin
            { All channel cursors }
            for ch := FNumChannels-1 downto 0 do if Channel[ch].InUse then VertCursors[i].Top := Channel[ch].Top ;
            for ch := 0 to FNumChannels-1 do if Channel[ch].InUse then VertCursors[i].Bottom := Channel[ch].Bottom ;
            VertCursors[i].Left := Channel[LastActiveChannel].Left ;
            VertCursors[i].Right := Channel[LastActiveChannel].Right ;
            VertCursors[i].xMin := Channel[LastActiveChannel].xMin ;
            VertCursors[i].xMax := Channel[LastActiveChannel].xMax ;
            VertCursors[i].xScale := Channel[LastActiveChannel].xScale ;
            VertCursors[i].yScale := 1.0 ;
            end ;
         end ;

         KeepColor := Canv.Pen.Color ;
         Canv.Pen.Color := FGridColor ;

     // Draw horizontal ticks/grid lines

     for ch := 0 to FNumChannels-1 do if Channel[ch].InUse then begin

         Canv.Font.Color := clBlack ;

         // Determine suitable calibration tick size
         if Channel[ch].ADCScale = 0.0 then Channel[ch].ADCScale := 1.0 ;
         yScaledMax := (Channel[ch].yMax-Channel[ch].ADCZero)*Channel[ch].ADCScale*Sign(Channel[ch].ADCScale) ;
         yScaledMin := (Channel[ch].yMin-Channel[ch].ADCZero)*Channel[ch].ADCScale*Sign(Channel[ch].ADCScale) ;
         if yScaledMax = yScaledMin then yScaledMax := yScaledMin + 1.0 ;

         yRange := yScaledMax - yScaledMin ;
         TickBase := 0.01*exp(Round(Log10(Abs(yRange)))*ln(10.0)) ;
         for i := 0 to High(TickMultipliers) do begin
             YTickSize := TickBase*TickMultipliers[i] ;
             if (yRange/YTickSize) <= 10 then Break ;
             end ;

         // Find minimum & maximum Y tick
         YTickMax := YTickSize*Floor(yScaledMax/YTickSize) ;
         YTickMin := YTickSize*Ceil(yScaledMin/YTickSize) ;
         NumTicks := Round((YTickMax - YTickMin)/YTickSize) + 1 ;
         Channel[ch].GridSpacing := YTickSize ;

         // Plot ticks
         YTick := YTickMin ;
         iTick := 0 ;
         while iTick < NumTicks do
             begin

             yPix := YToCanvasCoord( Channel[ch],
                                    (YTick/Channel[ch].ADCScale) + Channel[ch].ADCZero ) ;

             Canv.Pen.Color := clBlack ;
             Canv.MoveTo( Channel[ch].Left, yPix )  ;
             Canv.LineTo( Channel[ch].Left + TickSize, yPix )  ;
             if FDrawGrid then
                begin
                Canv.Pen.Color := FGridColor ;
                Canv.Pen.Style := psDot ;
                Canv.LineTo( Channel[ch].Right, yPix )  ;
                Canv.Pen.Style := psSolid ;
                end ;

             // Display min/max values

             if iTick = 0 then begin
                s := format('%6.5g',[YTick]) ;
                Canv.TextOut( Max(Channel[ch].Left - Canv.TextWidth(s) - 1,0),
                              yPix - Canv.TextHeight(s) + 1,
                              s) ;
                end
             else if iTick = (NumTicks-1) then begin
                s := format('%6.5g',[YTick]) ;
                Canv.TextOut( Max(Channel[ch].Left - Canv.TextWidth(s) - 1,0),
                              yPix -1,
                              s) ;
                end ;

             YTick := YTick + YTickSize ;
             Inc(iTick) ;
             end ;

         end ;

     // Draw vertical ticks/grid line
     Canv.Font.Color := clBlack ;

     // Determine suitable calibration tick size
     XScaledMin := (FXMin+FXOffset)*FTScale ;
     XScaledMax := (FXMax+FXOffset)*FTScale ;
     if XScaledMax = XScaledMin then XScaledMax := XScaledMin + 1.0 ;

     XRange := XScaledMax - XScaledMin ;
     TickBase := 0.01*exp(Round(Log10(Abs(xRange)))*ln(10.0)) ;
     for i := 0 to High(TickMultipliers) do begin
         XTickSize := TickBase*TickMultipliers[i] ;
         if (XRange/XTickSize) <= 10 then Break ;
         end ;
     FTimeGridSpacing := XTickSize ;

     // Find minimum & maximum Y tick
     XTickMax := XTickSize*Floor(XScaledMax/XTickSize) ;
     XTickMin := XTickSize*Ceil(XScaledMin/XTickSize) ;
     NumTicks := Round((XTickMax - XTickMin)/XTickSize) + 1 ;

     // Plot ticks
     XTick := XTickMin ;
     iTick := 0 ;
     dx := (Channel[0].Right - Channel[0].Left) / XRange ;
     XAxisAt := Channel[LastActiveChannel].Bottom + Canv.TextHeight('X') + 2 ;
     while iTick < NumTicks do begin

        xPix := Round((XTick - XScaledMin)*dx) + Channel[0].Left ;

        Canv.Pen.Color := clBlack ;

        // X axis
        Canv.MoveTo( Channel[0].Left, XAxisAt )  ;
        Canv.LineTo( Channel[0].Right, XAxisAt )  ;

        // Draw tick
        Canv.MoveTo( xPix, XAxisAt )  ;
        Canv.LineTo( xPix, XAxisAt + TickSize )  ;

        // Draw grid
        if FDrawGrid then begin
           Canv.Pen.Color := FGridColor ;
           Canv.Pen.Style := psDot ;
           for ch := 0 to FNumChannels-1 do if Channel[ch].InUse then begin
               Canv.MoveTo( xPix, Channel[ch].Top )  ;
               Canv.LineTo( xPix, Channel[ch].Bottom )  ;
               end ;
           Canv.Pen.Style := psSolid ;
           end ;

        // Display tick value

        if iTick < (NumTicks-1) then s := format('%.6g',[XTick])
                                else s := format('%.6g %s',[XTick,FTUnits]) ;
        Canv.TextOut( xPix - (Canv.TextWidth(s) div 2),
                      XAxisAt + TickSize + 1,
                      s ) ;

        XTick := XTick + XTickSize ;
        Inc(iTick) ;
        end ;

     // Draw vertical axis
     Canv.Pen.Color := KeepColor ;
     Canv.Pen.Style := psSolid ;
     for ch := 0 to FNumChannels-1 do if Channel[ch].InUse then begin
         Canv.MoveTo( Channel[ch].Left, Channel[ch].Top )  ;
         Canv.LineTo( Channel[ch].Left, Channel[ch].Bottom )  ;
         end ;

     // Display channel name(s)

     for ch := 0 to FNumChannels-1 do if Channel[ch].InUse then begin

         Canv.Pen.Color := clBlack ; //Channel[ch].Color ;
         Canv.Font.Color := clBlack ;

         iSlashPos := Pos('/', Channel[ch].ADCName ) ;
         if iSlashPos <= 0 then s := Channel[ch].ADCName
                           else s := LeftStr(Channel[ch].ADCName,iSlashPos-1) ;

         // Draw label & units mid-way between lower and upper limits
         YMid := (Channel[ch].Top + Channel[ch].Bottom) div 2 ;
         XLeft := Max(Channel[ch].Left - Canv.TextWidth(s+'x') - 1,0);
         Canv.TextOut( XLeft,YMid - Canv.TextHeight(s) -1,s) ;

         if iSlashPos > 0  then begin
            // Draw line
            Canv.MoveTo( XLeft, yMid )  ;
            Canv.LineTo( XLeft + Canv.TextWidth(s), yMid )  ;
            // Draw denominator
            s := RightStr(Channel[ch].ADCName,Length(Channel[ch].ADCName)-iSlashPos) ;
            Canv.TextOut( XLeft,YMid + 1,s) ;
            end
         else begin
            s := Channel[ch].ADCUnits ;
            Canv.TextOut( XLeft,YMid,s) ;
            end ;

         if not FZoomDisableVertical then begin
            DrawZoomButton( Canv,
                         Channel[ch].Right + 2,
                         YMid - 27,
                         12,
                         cZoomUpButton,
                         ch ) ;

            DrawZoomButton( Canv,
                         Channel[ch].Right + 2,
                         YMid - 13,
                         12,
                         cZoomInButton,
                         ch ) ;

             DrawZoomButton( Canv,
                         Channel[ch].Right + 2,
                         YMid + 1,
                         12,
                         cZoomOutButton,
                         ch ) ;

             DrawZoomButton( Canv,
                         Channel[ch].Right + 2,
                         YMid + 14,
                         12,
                         cZoomDownButton,
                         ch ) ;
             end ;

         end ;

     // Display Horizontal zoom buttons

     if not FZoomDisableHorizontal then begin

         xPix := (Max(ClientWidth,2) - (ButtonSize*2)) div 2 ;
         //xPix := 0 ;
         yPix := Height - ButtonSize - 1 ;

         DrawZoomButton( Canv,
                         xPix,
                         yPix,
                         12,
                         cZoomLeftButton,
                         -1 ) ;

         xPix := xPix + 14 ;
         DrawZoomButton( Canv,
                         xPix,
                         yPix,
                         12,
                         cZoomInButton,
                         -1 ) ;

         xPix := xPix + 14 ;
         DrawZoomButton( Canv,
                         xPix,
                         yPix,
                         12,
                         cZoomOutButton,
                         -1 ) ;

         xPix := xPix + 14 ;
         DrawZoomButton( Canv,
                         xPix,
                         yPix,
                         12,
                         cZoomRightButton,
                         -1 ) ;

         end ;

     // Marker text
     for i := 0 to FMarkerText.Count-1 do begin
         x := Integer(FMarkerText.Objects[i]) ;
         xPix := XToCanvasCoord( Channel[LastActiveChannel], x ) ;
         yPix := Height - ((i Mod 2)+1)*Canv.TextHeight(FMarkerText.Strings[i]) ;
         Canv.TextOut( xPix, yPix, FMarkerText.Strings[i] );
         end ;

     end ;


procedure TScopeDisplay.DisplayNewPoints(
          NewPoints : Integer
          ) ;
{ -----------------------------------------
  Plot a new block of A/D samples of display
  -----------------------------------------}
var
   i,iStep,j,ch,iPlot : Integer ;
   StartAt,EndAt,XPix,XPixRange,XPixLeft,XPixRight,iYMin,iYMax : Integer ;
   YMin,YMax,y : single ;
begin

     { Start plot lines at last point in buffer }
     StartAt := Max( FNumPoints - 1,0 ) ;
     { End plot at newest point }
     FNumPoints := NewPoints ;
     EndAt := FNumPoints-1 ;

     for ch := 0 to FNumChannels-1 do
         if Channel[ch].InUse and (FBuf <> Nil) then begin

         XPixRange := Min( XToCanvasCoord( Channel[ch], EndAt ), Channel[ch].Right )
                      - Max( XToCanvasCoord( Channel[ch], StartAt ), Channel[ch].Left ) ;
         XPixRange := Max(XPixRange,1) ;

         Canvas.Pen.Color := Channel[ch].Color ;

         i := StartAt ;
         j := (i*FNumChannels) + Channel[ch].ADCOffset ;
         iStep := Max((EndAt - StartAt) div (XPixRange*2),1) ;
         iPlot := StartAt ;
         YMin := 1E30 ;
         YMax := -YMin ;
         iYMin := 0 ;
         iYMax := 0 ;
         XPixLeft := Channel[ch].Left ;
         XPixRight := Channel[ch].Right ;

         if StartAt = 0 then begin
            y := GetSample( FBuf, j, FNumBytesPerSample, FFloatingPointSamples ) ;
            Canvas.MoveTo( Channel[ch].Left, YToCanvasCoord( Channel[ch], y) ) ;
            end
         else begin
            Canvas.MoveTo( XToCanvasCoord( Channel[ch],Channel[ch].xLast ),
                           YToCanvasCoord( Channel[ch],Channel[ch].yLast ) ) ;
            end;

         repeat
             y := GetSample( FBuf, j, FNumBytesPerSample, FFloatingPointSamples ) ;
            if y <= Ymin then begin
               iYMin := i ;
               YMin := y ;
               end;
            if y >= Ymax then begin
               iYmax := i ;
               YMax := y ;
               end;
            XPix := XToCanvasCoord( Channel[ch], i ) ;
            if i = iPlot then begin
                 if (XPix >= XPixLeft) and (XPix <= XPixRight) then begin
                    if iYMin < iYMax then begin
                       Canvas.LineTo( XPix, YToCanvasCoord( Channel[ch], yMin) ) ;
                       Canvas.LineTo( XPix, YToCanvasCoord( Channel[ch], yMax) ) ;
                       Channel[ch].xLast := i ;
                       Channel[ch].yLast := yMax ;
                       end
                    else begin
                       Canvas.LineTo( XPix, YToCanvasCoord( Channel[ch], yMax) ) ;
                       Canvas.LineTo( XPix, YToCanvasCoord( Channel[ch], yMin) ) ;
                       Channel[ch].xLast := i ;
                       Channel[ch].yLast := yMin ;
                       end ;
                    end ;
                 YMin := 1E30 ;
                 YMax := -YMin ;
                 iPlot := Min(iPlot + iStep,EndAt) ;
                 end;
            Inc(i) ;
            j := j + FNumChannels ;
            until i >= EndAt ;
         end ;

     ResizeZoomBox( ZoomRect.Right, ZoomRect.Bottom ) ;

     // Draw link between selected pair of vertical cursors
     DrawVerticalCursorLink(Canvas) ;

     { Vertical Cursors }
     for i := 0 to High(VertCursors) do if VertCursors[i].InUse then
         DrawVerticalCursor(Canvas,i) ;

     end ;


procedure TScopeDisplay.AddMarker (
          AtPoint : Integer ;       // Marker display point
          Text : String             // Marker text
                    ) ;
// ------------------------------------
// Add marker text at bottom of display
// ------------------------------------
begin

    FMarkerText.AddObject( Text, TObject(AtPoint) ) ;
    Invalidate ;
    end ;


procedure TScopeDisplay.ClearMarkers ;
// ----------------------
// Clear marker text list
// ----------------------
begin
     FMarkerText.Clear ;
     Invalidate ;
     end ;


procedure TScopeDisplay.ClearHorizontalCursors ;
{ -----------------------------
  Remove all horizontal cursors
  -----------------------------}
var
   i : Integer ;
begin
     for i := 0 to High(HorCursors) do HorCursors[i].InUse := False ;
     end ;


function TScopeDisplay.AddHorizontalCursor(
         iChannel : Integer ;       { Signal channel associated with cursor }
         Color : TColor ;           { Colour of cursor }
         UseAsZeroLevel : Boolean ;  { If TRUE indicates this is a zero level cursor }
         CursorText : String       // Cursor label text
         ) : Integer ;
{ --------------------------------------------
  Add a new horizontal cursor to the display
  -------------------------------------------}
var
   iCursor : Integer ;
begin
     { Find an unused cursor }
     iCursor := 0 ;
     while HorCursors[iCursor].InUse
           and (iCursor < High(HorCursors)) do Inc(iCursor) ;

    { Attach the cursor to a channel }
    if iCursor <= High(HorCursors) then begin
       HorCursors[iCursor] := Channel[iChannel] ;
       HorCursors[iCursor].Position := 0 ;
       HorCursors[iCursor].InUse := True ;
       HorCursors[iCursor].Color := Color ;
       HorCursors[iCursor].ChanNum := iChannel ;
       HorCursors[iCursor].ZeroLevel := UseAsZeroLevel ;
       HorCursors[iCursor].ADCName := CursorText ;
       Result := iCursor ;
       end
    else begin
         { Return -1 if no cursors available }
         Result := -1 ;
         end ;
    end ;


procedure TScopeDisplay.DrawHorizontalCursor(
          Canv : TCanvas ;
          iCurs : Integer
          ) ;
{ -----------------------
  Draw horizontal cursor
 ------------------------}
var
   yPix : Integer ;
   OldPen : TPen ;
begin

     // Skip plot if cursor not within displayed area
     if (HorCursors[iCurs].Position < HorCursors[iCurs].yMin) or
        (HorCursors[iCurs].Position > HorCursors[iCurs].yMax) then Exit ;

     // Skip if channel disabled
     if not Channel[HorCursors[iCurs].ChanNum].InUse then Exit ;

     // Save pen settings
     OldPen := TPen.Create ;
     OldPen.Assign(Canv.Pen) ;

     // Settings for cursor
     Canv.Pen.Style := psDashDotDot ;
     Canv.Pen.Mode := pmMASK ;

     // If fixed zero levels flag set, set channel zero level to 0
     if FFixZeroLevels and HorCursors[iCurs].ZeroLevel then begin
        HorCursors[iCurs].Position := 0 ;
        end ;

     // Set line colour
     // (Note. If this cursor is being used as a zero level
     //  use a different colour when cursors is not at true zero)
     if HorCursors[iCurs].ZeroLevel and (HorCursors[iCurs].Position = 0) then
        Canv.Pen.Color := FZeroHorizontalCursorColor
     else Canv.Pen.Color := FNonZeroHorizontalCursorColor ;

     // Draw line
     yPix := YToCanvasCoord( HorCursors[iCurs],
                             HorCursors[iCurs].Position ) ;
     Canv.polyline( [Point(HorCursors[iCurs].Left,yPix),
                     Point(HorCursors[iCurs].Right,yPix)]);

     { If this cursor is being used as the zero baseline level for a signal
       channel, update the zero level for that channel }
     if (HorCursors[iCurs].ZeroLevel) then
        Channel[HorCursors[iCurs].ChanNum].ADCZero := HorCursors[iCurs].Position ;

     // Plot cursor label
     if HorCursors[iCurs].ADCName <> '' then begin
        Canv.TextOut( HorCursors[iCurs].Right
                      - Canv.TextWidth(HorCursors[iCurs].ADCName)-2,
                      yPix - (Canv.TextHeight(HorCursors[iCurs].ADCName) div 2) - 1,
                      HorCursors[iCurs].ADCName) ;
        end ;

     // Restore pen colour
     Canv.Pen.Assign(OldPen)  ;
     OldPen.Free ;

    end ;


procedure TScopeDisplay.ClearVerticalCursors ;
{ -----------------------------
  Remove all vertical cursors
  -----------------------------}
var
   i : Integer ;
begin
     for i := 0 to High(VertCursors) do VertCursors[i].InUse := False ;
     FNumVerticalCursorLinks := 0 ;
     end ;


function TScopeDisplay.AddVerticalCursor(
         Chan : Integer ;                { Signal channel (-1=all channels) }
         Color : TColor ;                 { Cursor colour }
         CursorText : String             // Text label at bottom of cursor
         ) : Integer ;
{ --------------------------------------------
  Add a new vertical cursor to the display
  -------------------------------------------}
var
   iCursor : Integer ;
begin
     { Find an unused cursor }
     iCursor := 0 ;
     while VertCursors[iCursor].InUse
           and (iCursor < High(VertCursors)) do Inc(iCursor) ;

    { Attach the cursor to a channel }
    if iCursor <= High(VertCursors) then begin
       VertCursors[iCursor] := Channel[0] ;
       VertCursors[iCursor].ChanNum := Chan ;
       VertCursors[iCursor].Position := FNumPoints div 2 ;
       VertCursors[iCursor].InUse := True ;
       VertCursors[iCursor].Color := Color ;
       VertCursors[iCursor].ADCName := CursorText ;
       Result := iCursor ;
       end
    else begin
         { Return -1 if no cursors available }
         Result := -1 ;
         end ;
    end ;


procedure TScopeDisplay.DrawVerticalCursor(
          Canv : TCanvas ;
          iCurs : Integer
          ) ;
{ -----------------------
  Draw vertical cursor
 ------------------------}
var
   j,ch,xPix,StartCh,EndCh,TChan : Integer ;
   OldFontColor : TColor ;
   y,yz : single ;
   s : string ;
   SavedPen : TPenRecall ;
   ChannelsAvailable : Boolean ;
begin

     // Skip if off the display
     if (VertCursors[iCurs].Position < Max(Channel[0].XMin,0)) or
        (VertCursors[iCurs].Position > Min(Channel[0].XMax,FMaxPoints)) then Exit ;

     // Skip if channel disabled
     ChannelsAvailable := False ;
     for ch := 0 to FNumChannels-1 do if Channel[ch].InUse then begin
         ChannelsAvailable := True ;
         Break ;
         end ;
     if not ChannelsAvailable then Exit ;

     if VertCursors[iCurs].ChanNum >= 0 then begin
        if not Channel[VertCursors[iCurs].ChanNum].InUse then Exit ;
        end ;

     SavedPen := TPenRecall.Create( Canv.Pen ) ;
     // Set pen to cursor colour (saving old)
     OldFontColor := Canv.Font.Color ;
     Canv.Pen.Color := VertCursors[iCurs].Color ;
     Canv.Font.Color := VertCursors[iCurs].Color ;
     Canv.Font.Size := FFontSize ;

     // Plot cursor line
     xPix := XToCanvasCoord( VertCursors[iCurs], VertCursors[iCurs].Position ) ;
     Canv.polyline( [Point(xPix,VertCursors[iCurs].Top),
                     Point(xPix,VertCursors[iCurs].Bottom)] );

     // Plot cursor label

     // Display signal value at cursor
     if VertCursors[iCurs].ChanNum < 0 then begin
        StartCh := 0 ;
        EndCh := FNumChannels-1 ;
        end
     else begin
       StartCh := VertCursors[iCurs].ChanNum ;
       EndCh := VertCursors[iCurs].ChanNum ;
       end ;

     // Select channel to be used to display time
     TChan := 0 ;
     for ch := StartCh to EndCh do if Channel[ch].InUse then TChan := ch ;

     for ch := StartCh to EndCh do if Channel[ch].InUse then begin
         // Get cursor name
         s := VertCursors[iCurs].ADCName ;

         // Cursor signal level reading
         j := (Round(VertCursors[iCurs].Position)*FNumChannels) + Channel[ch].ADCOffset ;
         if (j >= 0) and (j < (FMaxPoints*FNumChannels)) and (FBuf <> Nil) then begin
            y := GetSample( FBuf, j, FNumBytesPerSample, FFloatingPointSamples ) ;
            end
         else y := 0 ;

         // Display time

         if ANSIContainsText(VertCursors[iCurs].ADCName,'?t0') and (ch = TChan) then begin
            // Display time relative to cursor 0
            s := s + format('t=%6.5g, ',[(VertCursors[iCurs].Position
                                        - VertCursors[0].Position)*FTScale]) ;
            end
         else if ANSIContainsText(VertCursors[iCurs].ADCName,'?t') and (ch = TChan) then begin
            // Display time relative to start of record
            s := s + format('t=%6.5g, ',[(VertCursors[iCurs].Position + FXOffset)*FTScale]) ;
            end ;

         // Display sample index
         if ANSIContainsText(VertCursors[iCurs].ADCName,'?i') then begin
            s := s + format('i=%.0f, ',[VertCursors[iCurs].Position]) ;
            end ;

         // Display signal level
         if ANSIContainsText(VertCursors[iCurs].ADCName,'?y0') then begin
            // Display signal level (relative to cursor 0)
            j := Round(VertCursors[0].Position)*FNumChannels + Channel[ch].ADCOffset ;
            if (j >= 0) and (j < (FMaxPoints*FNumChannels)) and (FBuf <> Nil) then begin
               yz := GetSample( FBuf, j, FNumBytesPerSample, FFloatingPointSamples ) ;
               end
            else yz := 0 ;
            s := s + format('%6.5g %s',[(y-yz)*Channel[ch].ADCScale,Channel[ch].ADCUnits]) ;
            end
         else if ANSIContainsText(VertCursors[iCurs].ADCName,'?yd1') then begin
            // Display signal level (relative to baseline)
              yz := Channel[ch].ADCZero ;
              s := s + format('%.1f %s',[(y-yz)*Channel[ch].ADCScale,Channel[ch].ADCUnits]) ;
              s := AnsiReplaceText(s,'?yd1','') ;
              end
         else if ANSIContainsText(VertCursors[iCurs].ADCName,'?yd2') then begin
            // Display signal level (relative to baseline)
              yz := Channel[ch].ADCZero ;
              s := s + format('%.2f %s',[(y-yz)*Channel[ch].ADCScale,Channel[ch].ADCUnits]) ;
              s := AnsiReplaceText(s,'?yd2','') ;
              end
         else if ANSIContainsText(VertCursors[iCurs].ADCName,'?y') then begin
            // Display signal level (relative to baseline)
              yz := Channel[ch].ADCZero ;
              s := s + format('%6.5g %s',[(y-yz)*Channel[ch].ADCScale,Channel[ch].ADCUnits]) ;
              end ;

         // Remove query text
         s := AnsiReplaceText(s,'?t0','') ;
         s := AnsiReplaceText(s,'?t','') ;
         s := AnsiReplaceText(s,'?r','') ;
         s := AnsiReplaceText(s,'?i','') ;

         s := AnsiReplaceText(s,'?y0','') ;
         s := AnsiReplaceText(s,'?y','') ;

         if ANSIEndsText(', ',s) then s := LeftStr(s,Length(s)-2);


         if s <> '' then Canv.TextOut( xPix - Canv.TextWidth(s) div 2,Channel[ch].Bottom + 1,s) ;

         end ;

     // Restore pen colour
     SavedPen.Free ;
     Canv.Font.Color := OldFontColor ;

     end ;


procedure TScopeDisplay.DrawVerticalCursorLink(
          Canv : TCanvas
          ) ;
{ ---------------------------------------------
  Draw horizontal link between vertical cursors
 ----------------------------------------------}
var
   i,ch,iChan : Integer ;
   iCurs0,iCurs1 : Integer ;
   xPix0,xPix1,yPix : Integer ;
   SavedPen : TPenRecall ;
   ChannelsAvailable : Boolean ;
begin

     // Skip if all channels disabled
     ChannelsAvailable := False ;
     for ch := 0 to FNumChannels-1 do if Channel[ch].InUse then begin
         ChannelsAvailable := True ;
         Break ;
         end ;
     if not ChannelsAvailable then Exit ;

     SavedPen := TPenRecall.Create( Canv.Pen ) ;

     for i := 0 to FNumVerticalCursorLinks-1 do begin

         iCurs0 := FLinkVerticalCursors[2*i] ;
         iCurs1 := FLinkVerticalCursors[(2*i)+1] ;

         if VertCursors[iCurs0].ChanNum < 0 then begin
            iChan := 0 ;
            for ch := 0 to FNumChannels-1 do if Channel[ch].InUse then iChan := ch ;
            end
         else iChan := VertCursors[iCurs0].ChanNum ;

         if VertCursors[iCurs0].InUse and VertCursors[iCurs1].InUse and Channel[iChan].InUse then begin ;

            // Set pen to cursor colour (saving old)
            Canv.Pen.Color := VertCursors[iCurs0].Color ;

            // Y location of line
            yPix := Channel[iChan].Bottom + (Canv.TextHeight('X') div 2) ;

            // Plot left cursor end
            xPix0 := XToCanvasCoord( VertCursors[iCurs0], VertCursors[iCurs0].Position ) ;
            if VertCursors[iCurs0].ADCName <> '' then begin
               xPix0 := xPix0 + (Canv.TextWidth(VertCursors[iCurs0].ADCName) div 2) + 2 ;
               end
            else begin
               Canv.polyline( [Point(xPix0,yPix-3),Point(xPix0,yPix+3)] );
               end ;

            // Plot right cursor end
            xPix1 := XToCanvasCoord( VertCursors[iCurs1], VertCursors[iCurs1].Position ) ;
            if VertCursors[iCurs1].ADCName <> '' then begin
               xPix1 := xPix1 - (Canv.TextWidth(VertCursors[iCurs0].ADCName) div 2) - 2 ;
               end
            else begin
               Canv.polyline( [Point(xPix1,yPix-3),Point(xPix1,yPix+3)] );
               end ;

            // Plot horizontal lne
            Canv.polyline( [Point(xPix0,yPix),Point(xPix1,yPix)] );

            end ;
         end ;

     SavedPen.Free ;

     end ;



{ ==========================================================
  PROPERTY READ / WRITE METHODS
  ==========================================================}


procedure TScopeDisplay.SetNumChannels(
          Value : Integer
          ) ;
{ ------------------------------------------
  Set the number of channels to be displayed
  ------------------------------------------ }
begin
     FNumChannels := IntLimitTo(Value,1,High(Channel)+1) ;
     end ;


procedure TScopeDisplay.SetNumPoints(
          Value : Integer
          ) ;
{ ------------------------------------
  Set the number of points per channel
  ------------------------------------ }
begin
     FNumPoints :=  Max(Value,1);
     end ;


procedure TScopeDisplay.SetMaxPoints(
          Value : Integer
          ) ;
{ --------------------------------------------
  Set the maximum number of points per channel
  ------------------------------------------- }
begin
     FMaxPoints := Max(Value,1) ;
     end ;


 procedure TScopeDisplay.SetXMin(
          Value : Integer
          ) ;
{ ----------------------
  Set the X axis minimum
  ---------------------- }
var
   ch : Integer ;
begin
     FXMin := Min(Value,FMaxPoints-1) ;
     if FXMax = FXMin then FXMax := FXMin + 1 ;
     for ch := 0 to High(Channel) do Channel[ch].XMin := FXMin ;
     end ;


 procedure TScopeDisplay.SetXMax(
          Value : Integer
          ) ;
{ ----------------------
  Set the X axis maximum
  ---------------------- }
var
   ch : Integer ;
begin
     FXMax := Min(Value,FMaxPoints-1) ;
     if FXMax = FXMin then FXMax := FXMin + 1 ;
     for ch := 0 to High(Channel) do Channel[ch].XMax := FXMax ;
     end ;


procedure TScopeDisplay.SetYMin(
          Ch : Integer ;
          Value : single
          ) ;
{ -------------------------
  Set the channel Y minimum
  ------------------------- }
begin
     if (ch < 0) or (ch > ScopeChannelLimit) then Exit ;
     Channel[Ch].YMin := Max(Value,FMinADCValue) ;
     if Channel[Ch].YMin = Channel[Ch].YMax then
        Channel[Ch].YMax := Channel[Ch].YMin + 1.0 ;
     end ;


procedure TScopeDisplay.SetYMax(
          Ch : Integer ;
          Value : single
          ) ;
{ -------------------------
  Set the channel Y maximum
  ------------------------- }
begin
     if (ch < 0) or (ch > ScopeChannelLimit) then Exit ;
     Channel[Ch].YMax := Min(Value,FMaxADCValue) ;
     if Channel[Ch].YMin = Channel[Ch].YMax then
        Channel[Ch].YMax := Channel[Ch].YMin + 1.0 ;
     end ;


procedure TScopeDisplay.SetYSize(
          Ch : Integer ;
          Value : single
          ) ;
{ -------------------------
  Set the channel Y axis relative size
  ------------------------- }
begin
     if (ch < 0) or (ch > ScopeChannelLimit) then Exit ;
     Channel[Ch].YSize := Value ;
     end ;


function TScopeDisplay.GetYMin(
         Ch : Integer
          ) : single ;
{ -------------------------
  Get the channel Y minimum
  ------------------------- }
begin
     Ch := IntLimitTo(Ch,0,ScopeChannelLimit) ;
     Result := Channel[Ch].YMin ;
     end ;


function TScopeDisplay.GetYMax(
         Ch : Integer
          ) : single ;
{ -------------------------
  Get the channel Y maximum
  ------------------------- }
begin
     Ch := IntLimitTo(Ch,0,ScopeChannelLimit) ;
     Result := Channel[Ch].YMax ;
     end ;


function TScopeDisplay.GetYSize(
         Ch : Integer
          ) : single ;
{ -------------------------
  Get the channel Y axis relative size
  ------------------------- }
begin
     Ch := IntLimitTo(Ch,0,ScopeChannelLimit) ;
     Result := Channel[Ch].YSize ;
     end ;


procedure TScopeDisplay.SetChanName(
          Ch : Integer ;
          Value : string
          ) ;
{ ------------------
  Set a channel name
  ------------------ }
begin
     if (ch < 0) or (ch > ScopeChannelLimit) then Exit ;
     Channel[Ch].ADCName := Value ;
     end ;


function TScopeDisplay.GetChanName(
          Ch : Integer
          ) : string ;
{ ------------------
  Get a channel name
  ------------------ }
begin
     Ch := IntLimitTo(Ch,0,ScopeChannelLimit) ;
     Result := Channel[Ch].ADCName ;
     end ;


procedure TScopeDisplay.SetChanUnits(
          Ch : Integer ;
          Value : string
          ) ;
{ ------------------
  Set a channel units
  ------------------ }

begin
     if (ch < 0) or (ch > ScopeChannelLimit) then Exit ;
     Channel[Ch].ADCUnits := Value ;
     end ;


function TScopeDisplay.GetChanUnits(
          Ch : Integer
          ) : string ;
{ ------------------
  Get a channel units
  ------------------ }
begin
     Ch := IntLimitTo(Ch,0,FNumChannels-1) ;
     Result := Channel[Ch].ADCUnits ;
     end ;


procedure TScopeDisplay.SetChanScale(
          Ch : Integer ;
          Value : single
          ) ;
{ ------------------------------------------------
  Set a channel A/D -> physical units scale factor
  ------------------------------------------------ }
begin
     if (ch < 0) or (ch > ScopeChannelLimit) then Exit ;
     Channel[Ch].ADCScale := Value ;
     end ;


function TScopeDisplay.GetChanScale(
          Ch : Integer
          ) : single ;
{ --------------------------------------------------
  Get a channel A/D -> physical units scaling factor
  -------------------------------------------------- }
begin
     Ch := IntLimitTo(Ch,0,ScopeChannelLimit) ;
     Result := Channel[Ch].ADCScale ;
     end ;


procedure TScopeDisplay.SetChanCalBar(
          Ch : Integer ;
          Value : single
          ) ;
{ -----------------------------
  Set a channel calibration bar
  ----------------------------- }
begin
     if (ch < 0) or (ch > ScopeChannelLimit) then Exit ;
     Channel[Ch].CalBar := Value ;
     end ;


function TScopeDisplay.GetChanCalBar(
          Ch : Integer
          ) : single ;
{ -----------------------------------
  Get a channel calibration bar value
  ----------------------------------- }
begin
     Ch := IntLimitTo(Ch,0,ScopeChannelLimit) ;
     Result := Channel[Ch].CalBar ;
     end ;

function TScopeDisplay.GetChanGridSpacing(
          Ch : Integer
          ) : single ;
{ -----------------------------------
  Get a channel grid spacing
  ----------------------------------- }
begin
     Ch := IntLimitTo(Ch,0,ScopeChannelLimit) ;
     Result := Channel[Ch].GridSpacing ;
     end ;

procedure TScopeDisplay.SetChanOffset(
          Ch : Integer ;
          Value : Integer
          ) ;
{ ---------------------------------------------
  Get data interleaving offset for this channel
  ---------------------------------------------}
begin
     if (ch < 0) or (ch > ScopeChannelLimit) then Exit ;
     Channel[Ch].ADCOffset := Value ;
     end ;


function TScopeDisplay.GetChanOffset(
          Ch : Integer
          ) : Integer ;
{ ---------------------------------------------
  Get data interleaving offset for this channel
  ---------------------------------------------}
begin
     Ch := IntLimitTo(Ch,0,ScopeChannelLimit) ;
     Result := Channel[Ch].ADCOffset ;
     end ;


procedure TScopeDisplay.SetChanZero(
          Ch : Integer ;
          Value : single
          ) ;
{ ------------------------
  Set a channel zero level
  ------------------------ }
begin
     if (ch < 0) or (ch > ScopeChannelLimit) then Exit ;
     Channel[Ch].ADCZero := Value ;
     end ;


function TScopeDisplay.GetChanZero(
          Ch : Integer
          ) : single ;
{ ----------------------------
  Get a channel A/D zero level
  ---------------------------- }
begin
     Ch := IntLimitTo(Ch,0,ScopeChannelLimit) ;
     Result := Channel[Ch].ADCZero ;
     end ;


procedure TScopeDisplay.SetChanZeroAt(
          Ch : Integer ;
          Value : integer
          ) ;
{ ------------------------
  Set a channel zero level
  ------------------------ }
begin
     if (ch < 0) or (ch > ScopeChannelLimit) then Exit ;
     Channel[Ch].ADCZeroAt := Value ;
     end ;


function TScopeDisplay.GetChanZeroAt(
          Ch : Integer
          ) : Integer ;
{ ----------------------------
  Get a channel A/D zero level
  ---------------------------- }
begin
     Ch := IntLimitTo(Ch,0,ScopeChannelLimit) ;
     Result := Channel[Ch].ADCZeroAt ;
     end ;


procedure TScopeDisplay.SetChanZeroAvg(
          Value : Integer
          ) ;
{ ------------------------------------------------------------
  Set no. of points to average to get From Record channel zero
  ------------------------------------------------------------ }
begin
     FChanZeroAvg := IntLimitTo(Value,1,FNumPoints) ;
     end ;


procedure TScopeDisplay.SetChanVisible(
          Ch : Integer ;
          Value : boolean
          ) ;
{ ----------------------
  Set channel visibility
  ---------------------- }
begin
     if (ch < 0) or (ch > ScopeChannelLimit) then Exit ;
     Channel[Ch].InUse := Value ;
     Invalidate ;
     end ;


function TScopeDisplay.GetChanVisible(
          Ch : Integer
          ) : boolean ;
{ ----------------------
  Get channel visibility
  ---------------------- }
begin
     Ch := IntLimitTo(Ch,0,ScopeChannelLimit) ;
     Result := Channel[Ch].InUse ;
     end ;


procedure TScopeDisplay.SetChanColor(
          Ch : Integer ;
          Value : TColor
          ) ;
{ ----------------------
  Set channel colour
  ---------------------- }
begin
     if (ch < 0) or (ch > ScopeChannelLimit) then Exit ;
     Channel[Ch].Color := Value ;
     end ;


function TScopeDisplay.GetChanColor(
          Ch : Integer
          ) : TColor ;
{ ----------------------
  Get channel colour
  ---------------------- }
begin
     Ch := IntLimitTo(Ch,0,ScopeChannelLimit) ;
     Result := Channel[Ch].Color ;
     end ;


function TScopeDisplay.GetHorCursor(
         iCursor : Integer
         ) : single ;
{ ---------------------------------
  Get position of horizontal cursor
  ---------------------------------}
begin
     iCursor := IntLimitTo(iCursor,0,High(HorCursors)) ;
     if HorCursors[iCursor].InUse then Result := HorCursors[iCursor].Position
                                   else Result := -1 ;
     end ;


procedure TScopeDisplay.SetHorCursor(
          iCursor : Integer ;           { Cursor # }
          Value : single              { New Cursor position }
          )  ;
{ ---------------------------------
  Set position of horizontal cursor
  ---------------------------------}
begin

     iCursor := IntLimitTo(iCursor,0,High(HorCursors)) ;
     HorCursors[iCursor].Position := Value ;

     { If this cursor is being used as the zero baseline level for a signal
       channel, update the zero level for that channel }
     if (HorCursors[iCursor].ZeroLevel) then
        Channel[HorCursors[iCursor].ChanNum].ADCZero := HorCursors[iCursor].Position ;

     Invalidate ;
     end ;


function TScopeDisplay.GetVertCursor(
         iCursor : Integer
         ) : single ;
{ -------------------------------
  Get position of vertical cursor
  -------------------------------}
begin
     iCursor := IntLimitTo(iCursor,0,High(VertCursors)) ;
     if VertCursors[iCursor].InUse then Result := VertCursors[iCursor].Position
                                   else Result := -1 ;
     end ;


procedure TScopeDisplay.SetVertCursor(
          iCursor : Integer ;           { Cursor # }
          Value : single                { New Cursor position }
          )  ;
{ -------------------------------
  Set position of Vertical cursor
  -------------------------------}
begin
     iCursor := IntLimitTo(iCursor,0,High(VertCursors)) ;
     VertCursors[iCursor].Position := Value ;
     Invalidate ;
     end ;


function TScopeDisplay.GetXScreenCoord(
         Value : Integer               { Index into display data array (IN) }
         ) : Integer ;
{ --------------------------------------------------------------------------
  Get the screen coordinate within the paint box from the data array index
  -------------------------------------------------------------------------- }
begin
     Result := XToScreenCoord( 0, Value ) ;
     end ;


procedure TScopeDisplay.SetPrinterFontName(
          Value : string
          ) ;
{ -----------------------
  Set printer font name
  ----------------------- }
begin
     FPrinterFontName := Value ;
     end ;


function TScopeDisplay.GetPrinterFontName : string ;
{ -----------------------
  Get printer font name
  ----------------------- }
begin
     Result := FPrinterFontName ;
     end ;


procedure TScopeDisplay.SetPrinterLeftMargin(
          Value : Integer                    { Left margin (mm) }
          ) ;
{ -----------------------
  Set printer left margin
  ----------------------- }
begin
     { Printer pixel height (mm) }
     try
        FPrinterLeftMargin := 0 ;
        if Printer.Printers.Count > 0 then FPrinterLeftMargin :=
           (Printer.PageWidth*Value) div GetDeviceCaps( printer.handle, HORZSIZE ) ;
     except
        on e:EPrinter do PrinterException := True ;
     end;

     end ;


function TScopeDisplay.GetPrinterLeftMargin : integer ;
{ ----------------------------------------
  Get printer left margin (returned in mm)
  ---------------------------------------- }
begin
     Result := 0 ;
     try
       if Printer.Printers.Count > 0 then Result :=
          (FPrinterLeftMargin*GetDeviceCaps(Printer.Handle,HORZSIZE)) div Printer.PageWidth ;
     except
        on e:EPrinter do PrinterException := True ;
        end;
     end ;


procedure TScopeDisplay.SetPrinterRightMargin(
          Value : Integer                    { Right margin (mm) }
          ) ;
{ -----------------------
  Set printer Right margin
  ----------------------- }
begin
     { Printer pixel height (mm) }
     try
        FPrinterRightMargin := 0 ;
        if Printer.Printers.Count > 0 then FPrinterRightMargin :=
           (Printer.PageWidth*Value) div GetDeviceCaps( printer.handle, HORZSIZE ) ;
     except
        on e:EPrinter do PrinterException := True ;
        end;
     end ;


function TScopeDisplay.GetPrinterRightMargin : integer ;
{ ----------------------------------------
  Get printer Right margin (returned in mm)
  ---------------------------------------- }
begin
    Result := 0 ;
    try
       if Printer.Printers.Count > 0 then Result :=
          (FPrinterRightMargin*GetDeviceCaps(Printer.Handle,HORZSIZE)) div Printer.PageWidth ;
     except
        on e:EPrinter do PrinterException := True ;
        end;
    end ;


procedure TScopeDisplay.SetPrinterTopMargin(
          Value : Integer                    { Top margin (mm) }
          ) ;
{ -----------------------
  Set printer Top margin
  ----------------------- }
begin
     { Printer pixel height (mm) }
     try
        FPrinterTopMargin := 0 ;
        if Printer.Printers.Count > 0 then FPrinterTopMargin :=
           (Printer.PageHeight*Value) div GetDeviceCaps( printer.handle, VERTSIZE ) ;
     except
        on e:EPrinter do PrinterException := True ;
        end;
     end ;


function TScopeDisplay.GetPrinterTopMargin : integer ;
{ ----------------------------------------
  Get printer Top margin (returned in mm)
  ---------------------------------------- }
begin
     Result := 0 ;
     try
        if Printer.Printers.Count > 0 then Result :=
           (FPrinterTopMargin*GetDeviceCaps(Printer.Handle,VERTSIZE)) div Printer.PageHeight ;
     except
        on e:EPrinter do PrinterException := True ;
        end;
     end ;


procedure TScopeDisplay.SetPrinterBottomMargin(
          Value : Integer                    { Bottom margin (mm) }
          ) ;
{ -----------------------
  Set printer Bottom margin
  ----------------------- }
begin
     { Printer pixel height (mm) }
     try
         FPrinterBottomMargin := 0 ;
        if Printer.Printers.Count > 0 then FPrinterBottomMargin :=
           (Printer.PageHeight*Value) div GetDeviceCaps( printer.handle, VERTSIZE ) ;
     except
        on e:EPrinter do PrinterException := True ;
        end;
     end ;


function TScopeDisplay.GetPrinterBottomMargin : integer ;
{ ----------------------------------------
  Get printer Bottom margin (returned in mm)
  ---------------------------------------- }
begin
     Result := 0 ;
     try
        if Printer.Printers.Count > 0 then Result :=
           (FPrinterBottomMargin*GetDeviceCaps(Printer.Handle,VERTSIZE)) div Printer.PageHeight ;
     except
        on e:EPrinter do PrinterException := True ;
        end;
     end ;


procedure TScopeDisplay.SetStorageMode(
          Value : Boolean                    { True=storage mode on }
          ) ;
{ ------------------------------------------------------
  Set display storage mode
  (in store mode records are superimposed on the screen
  ------------------------------------------------------ }
var
   i : Integer ;
begin
     FStorageMode := Value ;
     { Clear out list of stored records }
     for i := 1 to High(FStorageList) do FStorageList[i] := NoRecord ;
     FStorageListIndex := 0 ;
     FRecordNum := NoRecord ;
     Invalidate ;
     end ;


procedure TScopeDisplay.SetGrid(
          Value : Boolean                    { True=storage mode on }
          ) ;
{ ---------------------------
  Enable/disable display grid
  --------------------------- }
begin
     FDrawGrid := Value ;
     Invalidate ;
     end ;


function TScopeDisplay.GetNumVerticalCursors : Integer ;
// ---------------------------------------------------
// Get number of vertical cursors defined in displayed
// ---------------------------------------------------
var
    i,NumCursors : Integer ;
begin
    NumCursors := 0 ;
    for i := 0 to High(VertCursors) do if
        VertCursors[i].InUse then Inc(NumCursors) ;
    Result := NumCursors ;
    end ;


function TScopeDisplay.GetNumHorizontalCursors : Integer ;
// ---------------------------------------------------
// Get number of horizontal cursors defined in displayed
// ---------------------------------------------------
var
    i,NumCursors : Integer ;
begin
    NumCursors := 0 ;
    for i := 0 to High(HorCursors) do if
        HorCursors[i].InUse then Inc(NumCursors) ;
    Result := NumCursors ;
    end ;


procedure TScopeDisplay.SetFixZeroLevels( Value : Boolean ) ;
// -------------------------
// Set fixed zero level flag
// -------------------------
begin
     FFixZeroLevels := Value ;
     Invalidate ;
     end ;


{ =======================================================
  INTERNAL EVENT HANDLING METHODS
  ======================================================= }

procedure TScopeDisplay.MouseDown(
          Button: TMouseButton;
          Shift: TShiftState;
          X, Y: Integer
          ) ;
{ --------------------
  Mouse button is down
  -------------------- }
var
    OldCopyMode : TCopyMode ;
    ch : Integer ;
begin
     Inherited MouseDown( Button, Shift, X, Y ) ;

     FMouseDown := True ;

     if FHorCursorSelected > -1  then FHorCursorActive := True ;

     if (not FHorCursorActive)
        and (FVertCursorSelected > -1) then FVertCursorActive := True ;

     if ZoomRectCount > 1 then begin
        OldCopyMode := Canvas.CopyMode ;
        Canvas.CopyMode := cmNotSrcCopy	;
        Canvas.CopyRect( ZoomRect, Canvas, ZoomRect ) ;
        Canvas.CopyMode := OldCopyMode ;
        end ;

     { Find and store channel mouse is over }
     for ch := 0 to FNumChannels-1 do if Channel[ch].InUse then begin
         if (Channel[ch].Top <= Y) and (Y <= Channel[ch].Bottom) then
            ZoomChannel := ch ;
         end ;
     ZoomChannel := Min(Max(0,ZoomChannel),FNumChannels-1) ;

     ZoomRect.Left := Min(Max(X,Channel[ZoomChannel].Left),Channel[ZoomChannel].Right) ;
     ZoomRect.Top := Min(Max(Y,Channel[ZoomChannel].Top),Channel[ZoomChannel].Bottom) ;
     ZoomRect.Bottom := ZoomRect.Top ;
     ZoomRect.Right := ZoomRect.Left ;
     ZoomRectCount := 1 ;

     // If mouse is between channels, record upper channel
     FBetweenChannel := -1 ;
     for ch := 0 to FNumChannels-2 do if Channel[ch].InUse then begin
         if (X < Channel[ch].Left) and
            (Y > Channel[ch].Bottom) and
            (Y < Channel[ch+1].Top) then FBetweenChannel := ch ;
         end ;

     // Save mouse position
     MouseX := X ;
     MouseY := Y ;

     // If mouse over zoom button, change its colour
     ShowSelectedZoomButton ;

     end ;


procedure TScopeDisplay.MouseUp(
          Button: TMouseButton;
          Shift: TShiftState;
          X, Y: Integer
          ) ;
{ --------------------
  Mouse button is up
  -------------------- }
begin
     Inherited MouseUp( Button, Shift, X, Y ) ;


     FHorCursorActive := false ;
     FVertCursorActive := false ;

     // Save mouse position
     MouseX := X ;
     MouseY := Y ;

     // Update display magnification from zoom box
     ProcessZoomBox ;

     // Update space occupied by channel
     UpdateChannelYSize( X, Y ) ;

     Invalidate ;

     FMouseDown := False ;

     end ;

procedure TScopeDisplay.UpdateChannelYSize(
          X : Integer ;
          Y : Integer
          ) ;
// -----------------------------------------------
// Change proportion of Y axis occupied by channel
// -----------------------------------------------
var
    ch,ChannelSpacing : Integer ;
begin

     if FBetweenChannel < 0 then Exit ;

     ChannelSpacing :=  Canvas.TextHeight('X') + 1  ;
     Channel[FBetweenChannel].Bottom := Max( Y + (ChannelSpacing div 2),
                                             Channel[FBetweenChannel].Top ) ;

     // Find next higher channel
     for ch := FBetweenChannel+1 to FNumChannels-1 do if Channel[ch].InUse then begin
        Channel[FBetweenChannel].Bottom := Min( Channel[FBetweenChannel].Bottom,
                                                Channel[ch].Bottom ) ;
         Channel[ch].Top := Channel[FBetweenChannel].Bottom + ChannelSpacing ;
         break ;
         end ;

    for ch := 0 to FNumChannels-1 do if Channel[ch].InUse then begin
         Channel[ch].YSize := Channel[ch].Bottom - Channel[ch].Top ;
         end ;

     { Notify a change in cursors }
     if Assigned(OnCursorChange) and
        (not FCursorChangeInProgress) then OnCursorChange(Self) ;

     end ;



procedure TScopeDisplay.MouseMove(
          Shift: TShiftState;
          X, Y: Integer) ;
{ --------------------------------------------------------
  Select/deselect cursors as mouse is moved over display
  -------------------------------------------------------}
var
   ch,i : Integer ;
   HorizontalChanged : Boolean ; // Horizontal cursor changed flag
   VerticalChanged : Boolean ;   // Vertical cursor changed flag
   BetweenChannels : Boolean ;
begin
     Inherited MouseMove( Shift, X, Y ) ;

     { Find and store channel mouse is over }
     BetweenChannels := False ;
     for ch := 0 to FNumChannels-1 do if Channel[ch].InUse then begin
         if (Channel[ch].Top <= Y) and (Y <= Channel[ch].Bottom) then FMouseOverChannel := ch ;
         if (X < Channel[ch].Left) and
            (Y > Channel[ch].Bottom) and
            (Y < Channel[ch+1].Top) then BetweenChannels := True ;
         end ;


     if not FMouseDown then ZoomRectCount := 0 ;
     // Re-size display zoom box
     ResizeZoomBox( X, Y ) ;

     if FCursorsEnabled then begin

        { Find/move any active horizontal cursor }
        HorizontalChanged := ProcessHorizontalCursors( X, Y ) ;
        { Find/move any active vertical cursor }
        if not FHorCursorActive then VerticalChanged := ProcessVerticalCursors( X, Y )
                                else  VerticalChanged := False ;

        if (HorizontalChanged or VerticalChanged) then begin

           // Copy image from internal bitmap
           ForeBitmap.Canvas.CopyRect( DisplayRect,
                                       BackBitmap.Canvas,
                                       DisplayRect ) ;

           // Re-draw cursors
           for i := 0 to High(HorCursors) do if HorCursors[i].InUse
               and Channel[HorCursors[i].ChanNum].InUse then DrawHorizontalCursor(ForeBitmap.Canvas,i) ;

           // Draw link between selected pair of vertical cursors
           DrawVerticalCursorLink(ForeBitmap.Canvas) ;

           // Draw vertical cursors
           for i := 0 to High(VertCursors) do if VertCursors[i].InUse then
               DrawVerticalCursor(ForeBitmap.Canvas,i) ;

          Canvas.CopyRect( DisplayRect,
                           ForeBitmap.Canvas,
                           DisplayRect) ;

           end ;

        { Set type of cursor icon }
        if FHorCursorSelected > -1 then Cursor := crSizeNS
        else if FVertCursorSelected > -1 then Cursor := crSizeWE
        else if BetweenChannels then Cursor := crVSplit
        else Cursor := crDefault ;

        end ;

     end ;


procedure TScopeDisplay.DblClick ;
{ -------------------------------------------------
  Handle events activated by double mouse clicks
  -------------------------------------------------}
begin

     CheckZoomButtons ;

     end ;


procedure TScopeDisplay.Click ;
{ ----------------------------------------
  Handle events activated by mouse clicks
  ----------------------------------------}
begin

     CheckZoomButtons ;

     end ;



procedure TScopeDisplay.Invalidate ;
begin

     inherited Invalidate ;

     end ;


procedure TScopeDisplay.ZoomIn(
          Chan : Integer
          ) ;
{ -----------------------------------------------------------
  Switch to zoom in/out mode on selected chan (External call)
  ----------------------------------------------------------- }
begin
     end ;


procedure TScopeDisplay.XZoom( PercentChange : Single ) ;
// ----------------------------------------------------------
// Change horizontal display magnification for selected channel
// ----------------------------------------------------------
const
    XLoLimit = 16 ;
var
    XShift,XMid : Integer ;
begin

     XShift := Round(Abs(FXMax - FXMin)*Min(Max(PercentChange*0.01,-1.0),10.0)) div 2 ;
     FXMin := Min( Max( FXMin - XShift, 0 ), FMaxPoints - 1 ) ;
     FXMax := Min( Max( FXMax  + XShift, 0 ), FMaxPoints - 1 ) ;
     if Abs(FXMax - FXMin) < XLoLimit then begin
        XMid := Round((FXMax +FXMin)*0.5) ;
        FXMax := Min(XMid + (XLoLimit div 2),FMaxPoints - 1 ) ;
        FXMin := Max(XMid - (XLoLimit div 2),0) ;
        end ;

     end ;


procedure TScopeDisplay.YZoom(
          Chan : Integer ;       // Selected channel (-1 = all channels)
          PercentChange : Single // % change (-100..10000%) (Negative values zoom in)
          ) ;
// ----------------------------------------------------------
// Change vertical display magnification for selected channel
// ----------------------------------------------------------
const
    YLoLimit = 16 ;
var
    ch : Integer ;
    YShift,YMid : Integer ;
begin

     if Chan >= FNumChannels then Exit ;

     YShift := Round( Abs(Channel[Chan].YMax - Channel[Chan].YMin)
                      *Min(Max(PercentChange*0.01,-1.0),10.0)) div 2 ;

     if Chan < 0 then begin
        // Zoom all channels
        for ch := 0 to FNumChannels-1 do begin
            Channel[ch].YMax := Max(Min(Channel[ch].YMax + YShift, FMaxADCValue),FMinADCValue) ;
            Channel[ch].YMin := Max(Min(Channel[ch].YMin - YShift, FMaxADCValue),FMinADCValue) ;
            if Abs(Channel[ch].YMax - Channel[ch].YMin) < YLoLimit then begin
               YMid := Round((Channel[ch].YMax + Channel[ch].YMin)*0.5) ;
               Channel[ch].YMax := YMid + (YLoLimit div 2) ;
               Channel[ch].YMin := YMid - (YLoLimit div 2) ;
               end ;
            end ;
        end
     else begin
        // Zoom selected channel
        Channel[Chan].YMax := Max(Min(Channel[Chan].YMax + YShift, FMaxADCValue),FMinADCValue) ;
        Channel[Chan].YMin := Max(Min(Channel[Chan].YMin - YShift, FMaxADCValue),FMinADCValue) ;
        if Abs(Channel[Chan].YMax - Channel[Chan].YMin) < YLoLimit then begin
           YMid := Round((Channel[Chan].YMax + Channel[Chan].YMin)*0.5) ;
           Channel[Chan].YMax := YMid + (YLoLimit div 2) ;
           Channel[Chan].YMin := YMid - (YLoLimit div 2) ;
           end ;
        end ;

     Self.Invalidate ;

     end ;


procedure TScopeDisplay.ZoomOut ;
{ ---------------------------------
  Zoom out to minimum magnification
  ---------------------------------}
var
   ch : Integer ;
begin
     for ch := 0 to FNumChannels-1 do begin
         Channel[ch].yMin := FMinADCValue ;
         Channel[ch].yMax := FMaxADCValue ;
         FXMin := 0 ;
         FXMax := FMaxPoints - 1;
         Channel[ch].xMin := FXMin ;
         Channel[ch].xMax := FXMax ;
         end ;
     Invalidate ;
     end ;


function TScopeDisplay.ProcessHorizontalCursors(
         X : Integer ;
         Y : Integer
         ) : Boolean ;                       // Returns TRUE if a cursor changed
{ ----------------------------------
  Find/move active horizontal cursor
  ----------------------------------}
const
     Margin = 4 ;
var
   YPosition,i : Integer ;
begin

     if FHorCursorActive and (FHorCursorSelected > -1) then begin
        { ** Move the currently activated cursor to a new position ** }
        { Keep within display limits }
        Y := IntLimitTo( Y,
                         HorCursors[FHorCursorSelected].Top,
                         HorCursors[FHorCursorSelected].Bottom ) ;
        HorCursors[FHorCursorSelected].Position := CanvasToYCoord(
                                                   HorCursors[FHorCursorSelected],Y) ;

        { Notify a change in cursors }
        if Assigned(OnCursorChange) and
           (not FCursorChangeInProgress) then OnCursorChange(Self) ;

        Result := True ;
        end
     else begin
        { Find the active horizontal cursor (if any) }
        FHorCursorSelected := -1 ;
        for i := 0 to High(HorCursors) do if HorCursors[i].InUse then begin
            YPosition := YToCanvasCoord(HorCursors[i],HorCursors[i].Position) ;
            if (Abs(Y - YPosition) <= Margin) and
               (X < Channel[0].Right) and
               (X > Channel[0].Left) then FHorCursorSelected := i ;
            end ;

        Result := False ;
        end ;

     end ;


function TScopeDisplay.ProcessVerticalCursors(
         X : Integer ;                        // X mouse coord (IN)
         Y : Integer                          // Y mouse coord (IN)
         ) : Boolean ;                       // Returns TRUE is cursor changed
{ --------------------------------
  Find/move active vertical cursor
  --------------------------------}
const
     Margin = 4 ;
var
   XPosition,i : Integer ;
begin

     if FVertCursorActive and (FVertCursorSelected > -1) then begin
        { ** Move the currently activated cursor to a new position ** }
        { Keep within channel display area }
        X := IntLimitTo( X,
                         VertCursors[FVertCursorSelected].Left,
                         VertCursors[FVertCursorSelected].Right ) ;
        { Calculate new X value }
        VertCursors[FVertCursorSelected].Position := CanvasToXCoord(
                               VertCursors[FVertCursorSelected], X ) ;

        { Notify a change in cursors }
        if Assigned(OnCursorChange) and
           (not FCursorChangeInProgress) then OnCursorChange(Self) ;

        Result := True ;
        end
     else begin
        { ** Find the active vertical cursor (if any) ** }
        FVertCursorSelected := -1 ;
        for i := 0 to High(VertCursors) do if VertCursors[i].InUse and
            (VertCursors[i].Bottom >= Y) and (Y >= VertCursors[i].Top) then begin
            XPosition := XToCanvasCoord( VertCursors[i], VertCursors[i].Position ) ;
            if Abs(X - XPosition) <= Margin then begin
               FVertCursorSelected := i ;
               FLastVertCursorSelected := FVertCursorSelected ;
               end ;
            end ;
        Result := False ;
        end ;
     end ;


procedure TScopeDisplay.MoveActiveVerticalCursor( Step : Integer ) ;
{ ----------------------------------------------------------------
  Move the currently selected vertical cursor by "Step" increments
  ---------------------------------------------------------------- }
begin

    VertCursors[FLastVertCursorSelected].Position := Max(FXMin,Min(FXMax,
                        VertCursors[FLastVertCursorSelected].Position + Step ));


    //  Notify a change in cursors
     if Assigned(OnCursorChange) and
        (not FCursorChangeInProgress) then OnCursorChange(Self) ;

    Self.Invalidate ;

    end ;


procedure TScopeDisplay.LinkVerticalCursors(
          C0 : Integer ;                     // First cursor to link
          C1 : Integer                       // Second cursor to link
          ) ;
// -----------------------------------------------------
// Link a pair of cursors with line at bottom of display
// -----------------------------------------------------
begin


    if FNumVerticalCursorLinks > MaxVerticalCursorLinks then Exit ;
    if (C0 < 0) or (C0 > High(VertCursors)) then Exit ;
    if (C1 < 0) or (C1 > High(VertCursors)) then Exit ;
    if (not VertCursors[C0].InUse) or (not VertCursors[C1].InUse) then Exit ;

    FLinkVerticalCursors[2*FNumVerticalCursorLinks] := C0 ;
    FLinkVerticalCursors[2*FNumVerticalCursorLinks+1] := C1 ;
    Inc(FNumVerticalCursorLinks) ;

    end ;


function TScopeDisplay.IntLimitTo(
         Value : Integer ;          { Value to be checked }
         Lo : Integer ;             { Lower limit }
         Hi : Integer               { Upper limit }
         ) : Integer ;              { Return limited value }
{ --------------------------------
  Limit Value to the range Lo - Hi
  --------------------------------}
begin
     if Value < Lo then Value := Lo ;
     if Value > Hi then Value := Hi ;
     Result := Value ;
     end ;


function TScopeDisplay.XToCanvasCoord(
         var Chan : TScopeChannel ;
         Value : single
         ) : Integer  ;
var
   XScale : single ;
begin
        XScale := (Chan.Right - Chan.Left) / ( FXMax - FXMin ) ;
     Result := Round( (Value - FXMin)*XScale + Chan.Left ) ;
     end ;


function TScopeDisplay.XToScreenCoord(
         Chan : Integer ;
         Value : single
         ) : Integer  ;
{ ------------------------------------------------------------------------
  Public function which allows pixel coord to be obtained for X axis coord
  ------------------------------------------------------------------------}
var
   XScale : single ;
begin
     XScale := (Channel[Chan].Right - Channel[Chan].Left) / ( FXMax - FXMin ) ;
     Result := Round( (Value - FXMin)*XScale + Channel[Chan].Left ) ;
     end ;


function TScopeDisplay.ScreenCoordToX(
         Chan : Integer ;
         Value : Integer
         ) : Single  ;
{ ------------------------------------------------------------------------
  Public function which allows pixel coord to be obtained for X axis coord
  ------------------------------------------------------------------------}
var
   XScale : single ;
begin
     XScale := (Channel[Chan].Right - Channel[Chan].Left) / ( FXMax - FXMin ) ;
     Result := (Value - Channel[Chan].Left)/XSCale + FXMin ;
     end ;



function TScopeDisplay.CanvasToXCoord(
         var Chan : TScopeChannel ;
         xPix : Integer
         ) : Integer  ;
var
   XScale : single ;
begin
     XScale := (Chan.Right - Chan.Left) / ( FXMax - FXMin ) ;
     Result := Round((xPix - Chan.Left)/XScale + FXMin) ;
     end ;


function TScopeDisplay.YToCanvasCoord(
         var Chan : TScopeChannel ;
         Value : single
         ) : Integer  ;
begin
     Chan.yScale := (Chan.Bottom - Chan.Top)/(Chan.yMax - Chan.yMin ) ;
     Result := Round( Chan.Bottom - (Value - Chan.yMin)*Chan.yScale ) ;
     if Result > Chan.Bottom then Result := Chan.Bottom ;
     if Result < Chan.Top then Result := Chan.Top ;
     end ;


function TScopeDisplay.YToScreenCoord(
         Chan : Integer ;
         Value : single
         ) : Integer  ;
{ ------------------------------------------------------------------------
  Public function which allows pixel coord to be obtained from Y axis coord
  ------------------------------------------------------------------------}

begin
     Channel[Chan].yScale := (Channel[Chan].Bottom - Channel[Chan].Top)/
                             (Channel[Chan].yMax - Channel[Chan].yMin ) ;
     Result := Round( Channel[Chan].Bottom
               - (Value - Channel[Chan].yMin)*Channel[Chan].yScale ) ;

     end ;


function TScopeDisplay.ScreenCoordToY(
         Chan : Integer ;
         Value : Integer
         ) : single  ;
{ ------------------------------------------------------------------------
  Public function which allows pixel coord to be obtained from Y axis coord
  ------------------------------------------------------------------------}

begin
     Channel[Chan].yScale := (Channel[Chan].Bottom - Channel[Chan].Top)/
                             (Channel[Chan].yMax - Channel[Chan].yMin ) ;
     Result := (Channel[Chan].Bottom - Value)/Channel[Chan].yScale
               + Channel[Chan].yMin ;
     end ;



function TScopeDisplay.CanvasToYCoord(
         var Chan : TScopeChannel ;
         yPix : Integer
         ) : Integer  ;
begin
     Chan.yScale := (Chan.Bottom - Chan.Top)/(Chan.yMax - Chan.yMin ) ;
     Result := Round( (Chan.Bottom - yPix)/Chan.yScale + Chan.yMin ) ;
     end ;

procedure TScopeDisplay.SetDataBuf(
          Buf : Pointer ) ;
// --------------------------------------------------------------------------
// Supply address of data buffer containing digitised signals to be displayed
// --------------------------------------------------------------------------
begin
     FBuf := Buf ;
     //Invalidate ; Removed 5/12/01
     end ;


procedure TScopeDisplay.CopyDataToClipBoard ;
{ ------------------------------------------------
  Copy the data points on display to the clipboard
  ------------------------------------------------}
const
      MaxPoints = 10000 ;
var
   L,i,ch,NumLines,jPoint : Integer ;
   iYMin,iYMax,NumCompressed,NumPointsPerBlock,iBlock,iPoint,NumChannelsInUse,LineCount : Integer ;
   y,yMin,YMax : single ;
   iCell,Col,Row,RowStart,ColOffset,NumColumns : Integer ;
   CompBuf : PSingleArray ;
   InUse : PSMallIntArray ;
   s : string ;
begin

     Screen.Cursor := crHourGlass ;

     // Open clipboard preventing others acceessing it
     Clipboard.Open ;

     // No. channels in use
     NumChannelsInUse := 0 ;
     for ch := 0 to FNumChannels-1 do if Channel[ch].InUse then Inc(NumChannelsInUse) ;

     // No. lines on display
     NumLines := 0 ;
     for L := 0 to High(FLines) do if (FLines[L].Count > 0) and Channel[FLines[L].Channel].InUse then Inc(NumLines) ;

     // Total no. of columns in data table (Time + Channels + Lines)
     NumColumns := NumLines + NumChannelsInUse + 1 ;

     // Allocated compressed data buffer and InUse flags
     GetMem( CompBuf, MaxPoints*NumColumns*SizeOf(Single)*3 ) ;
     GetMem( InUse, MaxPoints*NumColumns*SizeOf(SmallInt)*3 ) ;

     // Clear in use flags
     for i := 0 to MaxPoints*NumColumns-1 do InUse[i] := 0 ;

     // Build compressed data table

     // No. of data points per compression block
     NumPointsPerBlock := Max((FXMax - FXMin) div MaxPoints,1) ;
     // Starting column for channels
     ColOffset := 1 ;
     RowStart := 0 ;
     for ch := 0 to FNumChannels-1 do if Channel[ch].InUse then begin

         // Point to starting index in source data buffer
         jPoint := Max(FXMin,0)*FNumChannels + Channel[ch].ADCOffset ;
         // pointer to first element of row in table
         RowStart := 0 ;
         // Compression block point counter
         iBlock := 0 ;
         // Initiialise compression block min/max
         iYMin := 0 ;
         iYMax := 0 ;
         YMin := 1E30 ;
         YMax := -YMin ;

         for iPoint := Max(FXMin,0) to Min(FXMax,FNumPoints-1) do begin

             // Get data point
             y := GetSample( FBuf, jPoint, FNumBytesPerSample, FFloatingPointSamples ) ;

             // Update min/max limits
             if y < Ymin then begin
                iYMin := iPoint ;
                YMin := y ;
                end;
             if y > Ymax then begin
                iYMax := iPoint ;
                YMax := y ;
                end;

             // Add to compressed data table
             Inc(iBlock) ;
             if iBlock >= NumPointsPerBlock then begin
                if iYMin = iYMax then begin
                   CompBuf^[RowStart] := (iYMin-FXMin) ;
                   InUse[RowStart] := 1 ;
                   CompBuf^[RowStart + ColOffset] := (YMin - Channel[ch].ADCZero)*Channel[ch].ADCScale ;
                   InUse[RowStart + ColOffset] := 1 ;
                   RowStart := RowStart + NumColumns ;
                   end
                else if iYMin < iYMax then begin
                   CompBuf^[RowStart] := (iYMin-FXMin) ;
                   InUse[RowStart] := 1 ;
                   CompBuf^[RowStart + ColOffset] := (YMin - Channel[ch].ADCZero)*Channel[ch].ADCScale ;
                   InUse[RowStart + ColOffset] := 1 ;
                   RowStart := RowStart + NumColumns ;
                   CompBuf^[RowStart] := (iYMax-FXMin) ;
                   InUse[RowStart] := 1 ;
                   CompBuf^[RowStart + ColOffset] := (YMax - Channel[ch].ADCZero)*Channel[ch].ADCScale ;
                   InUse[RowStart + ColOffset] := 1 ;
                   RowStart := RowStart + NumColumns ;
                   end
                else begin
                   CompBuf^[RowStart] := (iYMax-FXMin) ;
                   InUse[RowStart] := 1 ;
                   CompBuf^[RowStart + ColOffset] := (YMax - Channel[ch].ADCZero)*Channel[ch].ADCScale ;
                   InUse[RowStart + ColOffset] := 1 ;
                   RowStart := RowStart + NumColumns ;
                   CompBuf^[RowStart] := (iYMin-FXMin) ;
                   InUse[RowStart] := 1 ;
                   CompBuf^[RowStart + ColOffset] := (YMin - Channel[ch].ADCZero)*Channel[ch].ADCScale ;
                   InUse[RowStart + ColOffset] := 1 ;
                   RowStart := RowStart + NumColumns ;
                   end;

                iBlock := 0 ;
                YMin := 1E30 ;
                YMax := -YMin ;

                end;

             jPoint := jPoint + FNumChannels ; // Increment data pointer

             end;

         Inc(ColOffset) ;
         end ;
     NumCompressed := RowStart div NumColumns ;

     // Add data points of superimposed lines to table row

     RowStart := 0 ;
     for Row := 0 to NumCompressed-1 do begin
         LineCount := 0 ;
         for L := 0 to High(FLines) do if (FLines[L].Count > 0) and Channel[FLines[L].Channel].InUse then begin
             ch := FLines[L].Channel ;
             for i := 0 to FLines[L].Count-1 do
                 if Round(CompBuf^[RowStart]) = (FLines[L].x^[i]-FXMin) then begin
                 Col := RowStart+LineCount+NumChannelsInUse+1 ;
                 CompBuf^[Col] := (FLines[L].y^[i]- Channel[ch].ADCZero)*Channel[ch].ADCScale ;
                 InUse^[Col] := 1 ;
                 end;
             Inc(LineCount) ;
             end ;
         RowStart := RowStart + NumColumns ;
         end;

       // Write table of data to copy buffer

       iCell := 0 ;
       s := '' ;
       for i := 0 to NumCompressed-1 do begin
           s := s + format( '%.5g', [CompBuf^[iCell]*FTScale] ) ;
           Inc(iCell) ;
           for Col := 1 to NumColumns-1 do  begin
               if InUse[iCell]=1 then s := s + Format(#9+'%.5g',[CompBuf^[iCell]])
                               else s := s + #9 ;
               Inc(iCell) ;
               end ;
            s := s + #13#10 ;
           end;

     try
       // Copy text accumulated in copy buffer to clipboard
      ClipBoard.SetTextBuf( PChar(s) ) ;

     finally
       // Free buffer
       FreeMem(CompBuf) ;
       FreeMem(InUse) ;
       // Release clipboard
       Clipboard.Close ;
       Screen.Cursor := crDefault ;
       end ;

     end ;


procedure TScopeDisplay.SaveDataToFile(
          FileName : string               // Name of file
          ) ;
{ -------------------------------------------------------
  Copy the data points on display to a file in CSV format
  -------------------------------------------------------}
const
      MaxPoints = 10000 ;
var
   L,i,ch,NumLines,jPoint : Integer ;
   iYMin,iYMax,NumCompressed,NumPointsPerBlock,iBlock,iPoint,NumChannelsInUse,LineCount : Integer ;
   y,yMin,YMax : single ;
   iCell,Col,Row,RowStart,ColOffset,NumColumns : Integer ;
   CompBuf : PSingleArray ;
   InUse : PSMallIntArray ;
   s : string ;
   Table : TStringList ;
begin

     Screen.Cursor := crHourGlass ;

     // No. channels in use
     NumChannelsInUse := 0 ;
     for ch := 0 to FNumChannels-1 do if Channel[ch].InUse then Inc(NumChannelsInUse) ;

     // No. lines on display
     NumLines := 0 ;
     for L := 0 to High(FLines) do if (FLines[L].Count > 0) and Channel[FLines[L].Channel].InUse then Inc(NumLines) ;

     // Total no. of columns in data table (Time + Channels + Lines)
     NumColumns := NumLines + NumChannelsInUse + 1 ;

     // Allocated compressed data buffer and InUse flags
     GetMem( CompBuf, MaxPoints*NumColumns*SizeOf(Single)*3 ) ;
     GetMem( InUse, MaxPoints*NumColumns*SizeOf(SmallInt)*3 ) ;

     // Clear in use flags
     for i := 0 to MaxPoints*NumColumns-1 do InUse[i] := 0 ;

     // Build compressed data table

     // No. of data points per compression block
     NumPointsPerBlock := Max((FXMax - FXMin) div MaxPoints,1) ;
     // Starting column for channels
     ColOffset := 1 ;
     RowStart := 0 ;
     for ch := 0 to FNumChannels-1 do if Channel[ch].InUse then begin

         // Point to starting index in source data buffer
         jPoint := Max(FXMin,0)*FNumChannels + Channel[ch].ADCOffset ;
         // pointer to first element of row in table
         RowStart := 0 ;
         // Compression block point counter
         iBlock := 0 ;
         // Initiialise compression block min/max
         iYMin := 0 ;
         iYMax := 0 ;
         YMin := 1E30 ;
         YMax := -YMin ;

         for iPoint := Max(FXMin,0) to Min(FXMax,FNumPoints-1) do
             begin

             // Get data point
             y := GetSample( FBuf, jPoint, FNumBytesPerSample, FFloatingPointSamples ) ;

             // Update min/max limits
             if y < Ymin then
                begin
                iYMin := iPoint ;
                YMin := y ;
                end;
             if y > Ymax then
                begin
                iYMax := iPoint ;
                YMax := y ;
                end;

             // Add to compressed data table
             Inc(iBlock) ;
             if iBlock >= NumPointsPerBlock then
                begin
                if iYMin = iYMax then
                   begin
                   CompBuf^[RowStart] := (iYMin-FXMin) ;
                   InUse[RowStart] := 1 ;
                   CompBuf^[RowStart + ColOffset] := (YMin - Channel[ch].ADCZero)*Channel[ch].ADCScale ;
                   InUse[RowStart + ColOffset] := 1 ;
                   RowStart := RowStart + NumColumns ;
                   end
                else if iYMin < iYMax then
                   begin
                   CompBuf^[RowStart] := (iYMin-FXMin) ;
                   InUse[RowStart] := 1 ;
                   CompBuf^[RowStart + ColOffset] := (YMin - Channel[ch].ADCZero)*Channel[ch].ADCScale ;
                   InUse[RowStart + ColOffset] := 1 ;
                   RowStart := RowStart + NumColumns ;
                   CompBuf^[RowStart] := (iYMax-FXMin) ;
                   InUse[RowStart] := 1 ;
                   CompBuf^[RowStart + ColOffset] := (YMax - Channel[ch].ADCZero)*Channel[ch].ADCScale ;
                   InUse[RowStart + ColOffset] := 1 ;
                   RowStart := RowStart + NumColumns ;
                   end
                else
                   begin
                   CompBuf^[RowStart] := (iYMax-FXMin) ;
                   InUse[RowStart] := 1 ;
                   CompBuf^[RowStart + ColOffset] := (YMax - Channel[ch].ADCZero)*Channel[ch].ADCScale ;
                   InUse[RowStart + ColOffset] := 1 ;
                   RowStart := RowStart + NumColumns ;
                   CompBuf^[RowStart] := (iYMin-FXMin) ;
                   InUse[RowStart] := 1 ;
                   CompBuf^[RowStart + ColOffset] := (YMin - Channel[ch].ADCZero)*Channel[ch].ADCScale ;
                   InUse[RowStart + ColOffset] := 1 ;
                   RowStart := RowStart + NumColumns ;
                   end;

                iBlock := 0 ;
                YMin := 1E30 ;
                YMax := -YMin ;

                end;

             jPoint := jPoint + FNumChannels ; // Increment data pointer

             end;

         Inc(ColOffset) ;
         end ;
     NumCompressed := RowStart div NumColumns ;

     // Add data points of superimposed lines to table row

     RowStart := 0 ;
     for Row := 0 to NumCompressed-1 do
         begin
         LineCount := 0 ;
         for L := 0 to High(FLines) do if (FLines[L].Count > 0) and Channel[FLines[L].Channel].InUse then
             begin
             ch := FLines[L].Channel ;
             for i := 0 to FLines[L].Count-1 do
                 if Round(CompBuf^[RowStart]) = (FLines[L].x^[i]-FXMin) then
                 begin
                 Col := RowStart+LineCount+NumChannelsInUse+1 ;
                 CompBuf^[Col] := (FLines[L].y^[i]- Channel[ch].ADCZero)*Channel[ch].ADCScale ;
                 InUse^[Col] := 1 ;
                 end;
             Inc(LineCount) ;
             end ;
         RowStart := RowStart + NumColumns ;
         end;

       // Write table of data to copy buffer



       // Create table
       Table := TStringList.Create ;

       // Table column names
       s := 'Time' ;
       for ch := 0 to FNumChannels-1 do if Channel[ch].InUse then begin
           s := s + ',"' + Channel[ch].ADCName + ' ' + Channel[ch].ADCUnits + '"' ;
       end;
       Table.Add(s) ;

       iCell := 0 ;
       for i := 0 to NumCompressed-1 do
           begin
           s := format( '%.6g', [CompBuf^[iCell]*FTScale] ) ;
           Inc(iCell) ;
           for Col := 1 to NumColumns-1 do
               begin
               if InUse[iCell]=1 then s := s + Format(',"%.6g"',[CompBuf^[iCell]])
                                 else s := s + ',' ;
               Inc(iCell) ;
               end ;
            Table.Add(s) ;
           end;

     Table.SaveToFile(FileName) ;
     Table.Free ;

     // Free buffer
     FreeMem(CompBuf) ;
     FreeMem(InUse) ;

     Screen.Cursor := crDefault ;

     end ;


procedure TScopeDisplay.Print ;
{ ---------------------------------
  Copy signal on display to printer
  ---------------------------------}
var
   i,j,ch,ichan,LastCh,YPix,xPix,Rec,NumBytesPerRecord : Integer ;
   YTotal : single ;
   LeftMarginShift, XPos,YPos : Integer ;
   ChannelHeight,cTop,NumInUse,AvailableHeight : Integer ;
   PrChan : Array[0..ScopeChannelLimit] of TScopeChannel ;
   xy : ^TPointArray ;
   Bar : TRect ;
   Lab : string ;
   DefaultPen : TPen ;
   TopSpaceNeeded : Integer ;
begin
     { Create plotting points array }
     New(xy) ;
     DefaultPen := TPen.Create ;
     Printer.BeginDoc ;
     Cursor := crHourglass ;

     try

        Printer.Canvas.Pen.Color := clBlack ;
        Printer.Canvas.font.Name := FPrinterFontName ;
        Printer.Canvas.font.size := FPrinterFontSize ;
        Printer.Canvas.Pen.Width := FPrinterPenWidth ;
        Printer.Canvas.Pen.Style := psSolid ;
        Printer.Canvas.Pen.Color := clBlack ;
        DefaultPen.Assign(Printer.Canvas.Pen) ;

        // Determine number of channels in use and the height
        TopSpaceNeeded := (3 + FTitle.Count)*Printer.Canvas.TextHeight('X') ;
        AvailableHeight := Printer.PageHeight
                           - FPrinterBottomMargin - Printer.Canvas.TextHeight('X')*3
                           - FPrinterTopMargin
                           - TopSpaceNeeded ;

        // Determine number of channels in use
        NumInUse := 0 ;
        YTotal := 0.0 ;
        for ch := 0 to FNumChannels-1 do if Channel[ch].InUse then begin
            Inc(NumInUse) ;
            YTotal := YTotal + Channel[ch].YSize ;
            end ;
        if NumInUse < 1 then begin
           YTotal := 1.0 ;
           end ;

        { Make space at left margin for channel names/cal. bars }
        LeftMarginShift := 0 ;
        for ch := 0 to FNumChannels-1 do if Channel[ch].InUse then begin
            Lab := Channel[ch].ADCName + ' ' ;
            if (LeftMarginShift < Printer.Canvas.TextWidth(Lab)) then
                LeftMarginShift := Printer.Canvas.TextWidth(Lab) ;
            Lab := format( ' %6.5g %s ', [Channel[ch].CalBar,Channel[ch].ADCUnits] ) ;
            if (LeftMarginShift < Printer.Canvas.TextWidth(Lab)) then
                LeftMarginShift := Printer.Canvas.TextWidth(Lab) ;
            end ;

        { Define display area for each channel in use }
        cTop := FPrinterTopMargin + TopSpaceNeeded ;
                ;
        for ch := 0 to FNumChannels-1 do begin
             PrChan[ch] := Channel[ch] ;
             if Channel[ch].InUse then begin
                if FPrinterDisableColor then PrChan[ch].Color := clBlack ;
                PrChan[ch].Left := FPrinterLeftMargin + LeftMarginShift ;
                PrChan[ch].Right := Printer.PageWidth - FPrinterRightMargin ;
                PrChan[ch].Top := cTop ;
                ChannelHeight := Round((Channel[ch].YSize/YTotal)*AvailableHeight) ;
                PrChan[ch].Bottom := PrChan[ch].Top + ChannelHeight ;
                PrChan[ch].xMin := FXMin ;
                PrChan[ch].xMax := FXMax ;
                PrChan[ch].xScale := (PrChan[ch].Right - PrChan[ch].Left) /
                                     (PrChan[ch].xMax - PrChan[ch].xMin ) ;
                PrChan[ch].yScale := (PrChan[ch].Bottom - PrChan[ch].Top) /
                                     (PrChan[ch].yMax - PrChan[ch].yMin ) ;
                cTop := cTop + ChannelHeight ;
                end ;
             end ;

        { Plot channel }
        for ch := 0 to FNumChannels-1 do
           if PrChan[ch].InUse and (FBuf <> Nil) and FPrinterShowLabels then begin
           { Display channel name(s) }
           Lab := PrChan[ch].ADCName + ' ' ;
           Printer.Canvas.TextOut( PrChan[ch].Left - Printer.Canvas.TextWidth(Lab),
                                   (PrChan[ch].Top + PrChan[ch].Bottom) div 2,
                                   Lab ) ;
           end ;

        { Plot record(s) on screen }

        if FStorageMode then begin
           { Display all records stored on screen }
           NumBytesPerRecord := FNumChannels*FNumPoints*2 ;
           for Rec := 1 to High(FStorageList) do if (FStorageList[Rec] <> NoRecord) then
               begin
               { Read buffer }
               FStorageFile.Seek( Rec*NumBytesPerRecord, soFromBeginning ) ;
               FStorageFile.Read( FBuf^, NumBytesPerRecord ) ;
               PlotRecord( Printer.Canvas, PrChan, xy^ ) ;
               end ;
           end
        else begin
           { Single-record mode }
           PlotRecord( Printer.Canvas, PrChan, xy^ ) ;
           end ;

       { Plot external line on selected channel }
       for i := 0 to High(FLines) do if FLines[i].Count > 0 then begin
           iChan := FLines[i].Channel ;
           if PrChan[iChan].InUse then begin
              Printer.Canvas.Pen.Assign(FLines[i].Pen) ;
              Printer.Canvas.Pen.Width := FPrinterPenWidth ;
              for j := 0 to FLines[i].Count-1 do begin
                  xy^[j].x := XToCanvasCoord( PrChan[iChan], FLines[i].x^[j] ) ;
                  xy^[j].y := YToCanvasCoord( PrChan[iChan], FLines[i].y^[j]  ) ;
                  end ;
              Polyline( Printer.Canvas.Handle, xy^, FLines[i].Count ) ;
              Printer.Canvas.Pen.Assign(DefaultPen) ;
              end;
           end ;

       { Draw baseline levels }
       if FPrinterShowZeroLevels then begin
          Printer.Canvas.Pen.Style := psDot ;
          Printer.Canvas.Pen.Width := 1 ;
          for ch := 0 to FNumChannels-1 do if PrChan[ch].InUse then begin
              YPix := YToCanvasCoord( PrChan[ch], PrChan[ch].ADCZero ) ;
              Printer.Canvas.MoveTo( PrChan[ch].Left,  YPix ) ;
              Printer.Canvas.LineTo( PrChan[ch].Right, YPix ) ;
              end ;
          end ;

       { Restore pen to black and solid for cal. bars }
       Printer.Canvas.Pen.Assign(DefaultPen) ;

       if FPrinterShowLabels then begin
          { Draw vertical calibration bars }
          for ch := 0 to FNumChannels-1 do
              if PrChan[ch].InUse and (PrChan[ch].CalBar <> 0.0) then begin
              { Bar label }
              Lab := format( '%6.5g %s ', [PrChan[ch].CalBar,PrChan[ch].ADCUnits] ) ;
              { Calculate position/size of bar }
              Bar.Left := PrChan[ch].Left - Printer.Canvas.TextWidth(Lab+' ') div 2 ;
              Bar.Right := Bar.Left + Printer.Canvas.TextWidth('X') ;
              Bar.Bottom := PrChan[ch].Bottom ;
              Bar.Top := Bar.Bottom
                         - Abs( Round((PrChan[ch].CalBar*PrChan[ch].yScale)
                                    /PrChan[ch].ADCScale) ) ;
              { Draw vertical bar with T's at each end }
              Printer.Canvas.MoveTo( Bar.Left ,  Bar.Bottom ) ;
              Printer.Canvas.LineTo( Bar.Right , Bar.Bottom ) ;
              Printer.Canvas.MoveTo( Bar.Left ,  Bar.Top ) ;
              Printer.Canvas.LineTo( Bar.Right , Bar.Top ) ;
              Printer.Canvas.MoveTo( (Bar.Left + Bar.Right) div 2,  Bar.Bottom ) ;
              Printer.Canvas.LineTo( (Bar.Left + Bar.Right) div 2,  Bar.Top ) ;
              { Draw bar label }
              Printer.Canvas.TextOut(PrChan[ch].Left - Printer.Canvas.TextWidth(Lab),
                                     prChan[ch].Bottom
                                     + Printer.Canvas.TextHeight(Lab) div 4,
                                     Lab ) ;
              end ;

          { Draw horizontal time calibration bar }
          Lab := format( '%.4g %s', [FTCalBar*FTScale,FTUnits] ) ;
          { Calculate position/size of bar }
          LastCh := 0 ;
          for ch := 0 to FNumChannels-1 do if Channel[ch].InUse then begin
              Bar.Top := PrChan[ch].Bottom + Printer.Canvas.TextHeight(Lab)*3 ;
              LastCh := ch ;
              end ;
          Bar.Bottom := Bar.Top + (Printer.Canvas.TextHeight(Lab) div 2);
          Bar.Left := PrChan[LastCh].Left ;
          Bar.Right := Bar.Left + Abs(Round(FTCalBar*PrChan[LastCh].xScale)) ;
          { Draw vertical bar with T's at each end }
          Printer.Canvas.MoveTo( Bar.Left ,  Bar.Bottom ) ;
          Printer.Canvas.LineTo( Bar.Left ,  Bar.Top ) ;
          Printer.Canvas.MoveTo( Bar.Right , Bar.Bottom ) ;
          Printer.Canvas.LineTo( Bar.Right , Bar.Top ) ;
          Printer.Canvas.MoveTo( Bar.Left, (Bar.Top + Bar.Bottom) div 2 ) ;
          Printer.Canvas.LineTo( Bar.Right,(Bar.Top + Bar.Bottom) div 2 ) ;
          { Draw bar label }
          Printer.Canvas.TextOut(Bar.Left ,
                              Bar.Bottom + Printer.Canvas.TextHeight(Lab) div 4,
                              Lab ) ;

           // Marker text
          for i := 0 to FMarkerText.Count-1 do begin
              xPix := XToCanvasCoord( PrChan[LastCh],
                                      Integer(FMarkerText.Objects[i]) ) ;
              yPix := PrChan[LastCh].Bottom +
                      ((i Mod 2)+1)*Printer.Canvas.TextHeight(FMarkerText.Strings[i]) ;
              Printer.Canvas.TextOut( xPix, yPix, FMarkerText.Strings[i] );
              end ;

          { Draw printer title }
          XPos := FPrinterLeftMargin ;
          YPos := FPrinterTopMargin ;
          CodedTextOut( Printer.Canvas, XPos, YPos, FTitle ) ;

          end ;

     finally
           { Get rid of array }
           Dispose(xy) ;
           DefaultPen.Free ;
           { Close down printer }
           Printer.EndDoc ;
           Cursor := crDefault ;
           end ;

     end ;


procedure TScopeDisplay.CopyImageToClipboard ;
{ -----------------------------------------
  Copy signal image on display to clipboard
  -----------------------------------------}
var
   i,j,ch,iChan,LastCh,yPix,xPix,Rec,NumBytesPerRecord : Integer ;
   YTotal : single ;
   LeftMarginShift : Integer ;
   ChannelHeight,cTop,NumInUse,AvailableHeight : Integer ;
   MFChan : Array[0..ScopeChannelLimit] of TScopeChannel ;
   xy : ^TPointArray ;
   Bar : TRect ;
   Lab : string ;

   TMF : TMetafile ;
   TMFC : TMetafileCanvas ;
   DefaultPen : TPen ;
begin

     { Create plotting points array }
     New(xy) ;
     DefaultPen := TPen.Create ;
     Cursor := crHourglass ;

     { Create Windows metafile object }
     TMF := TMetafile.Create ;
     TMF.Width := FMetafileWidth ;
     TMF.Height := FMetafileHeight ;

     try
        { Create a metafile canvas to draw on }
        TMFC := TMetafileCanvas.Create( TMF, 0 ) ;

        try
            { Set type face }
            TMFC.Font.Name := FPrinterFontName ;
            TMFC.Font.Size := FPrinterFontSize ;
            TMFC.Pen.Width := FPrinterPenWidth ;
            DefaultPen.Assign(TMFC.Pen) ;

            { Make the size of the canvas the same as the displayed area
              AGAIN ... See above. Not sure why we need to do this again
              but clipboard image doesn't come out right if we don't}
            TMF.Width := FMetafileWidth ;
            TMF.Height := FMetafileHeight ;
            { ** NOTE ALSO The above two lines MUST come
              BEFORE the setting of the plot margins next }

            // Determine number of channels in use
             NumInUse := 0 ;
             YTotal := 0.0 ;
             for ch := 0 to FNumChannels-1 do if Channel[ch].InUse then begin
                 Inc(NumInUse) ;
                 YTotal := YTotal + Channel[ch].YSize ;
                 end ;
             if NumInUse < 1 then begin
                YTotal := 1.0 ;
                end ;

             // Height available for each channel. NOTE This includes 3
             AvailableHeight := TMF.Height - 6*TMFC.TextHeight('X') - 4 ;

            { Make space at left margin for channel names/cal. bars }
            LeftMarginShift := 0 ;
            for ch := 0 to FNumChannels-1 do if Channel[ch].InUse then begin
                Lab := Channel[ch].ADCName + ' ' ;
                if (LeftMarginShift < TMFC.TextWidth(Lab)) then
                   LeftMarginShift := TMFC.TextWidth(Lab) ;
                Lab := format( ' %6.5g %s ', [Channel[ch].CalBar,Channel[ch].ADCUnits] ) ;
                if (LeftMarginShift < TMFC.TextWidth(Lab)) then
                   LeftMarginShift := TMFC.TextWidth(Lab) ;
                end ;

            { Define display area for each channel in use }
            cTop := TMFC.TextHeight('X') ;
            for ch := 0 to FNumChannels-1 do begin
                MFChan[ch] := Channel[ch] ;
                if Channel[ch].InUse then begin
                   if FPrinterDisableColor then MFChan[ch].Color := clBlack ;
                   MFChan[ch].Left := TMFC.TextWidth('X') + LeftMarginShift ;
                   MFChan[ch].Right := TMF.Width - TMFC.TextWidth('X') ;
                   MFChan[ch].Top := cTop ;
                   ChannelHeight := Round((Channel[ch].YSize/YTotal)*AvailableHeight) ;
                   MFChan[ch].Bottom := MFChan[ch].Top + ChannelHeight ;
                   MFChan[ch].xMin := FXMin ;
                   MFChan[ch].xMax := FXMax ;
                   MFChan[ch].xScale := (MFChan[ch].Right - MFChan[ch].Left) /
                                        (MFChan[ch].xMax - MFChan[ch].xMin ) ;
                   MFChan[ch].yScale := (MFChan[ch].Bottom - MFChan[ch].Top) /
                                        (MFChan[ch].yMax - MFChan[ch].yMin ) ;
                   cTop := cTop + ChannelHeight ;
                   End ;
                end ;

            { Plot channel names }
            if FPrinterShowLabels then begin
               for ch := 0 to FNumChannels-1 do
                   if MFChan[ch].InUse and (FBuf <> Nil) then begin
                   Lab := MFChan[ch].ADCName + ' ' ;
                   TMFC.TextOut( MFChan[ch].Left - TMFC.TextWidth(Lab),
                                (MFChan[ch].Top + MFChan[ch].Bottom) div 2,
                                 Lab ) ;
                   end ;
               end ;

            { Plot record(s) on metafile image canvas }

            if FStorageMode then begin
               { Display all records stored on screen }
               NumBytesPerRecord := FNumChannels*FNumPoints*2 ;
               for Rec := 1 to High(FStorageList) do if (FStorageList[Rec] <> NoRecord) then
                   begin
                   FStorageFile.Seek( Rec*NumBytesPerRecord, soFromBeginning ) ;
                   FStorageFile.Read( FBuf^, NumBytesPerRecord ) ;
                   PlotRecord( TMFC, MFChan, xy^ ) ;
                   end ;
               end
            else begin
               { Single-record mode }
               PlotRecord( TMFC, MFChan, xy^ ) ;
               end ;

            { Plot external line on selected channel }
            for i := 0 to High(FLines) do if FLines[i].Count > 0 then begin
                iChan := FLines[i].Channel ;
                if MFChan[iChan].InUse then begin
                   TMFC.Pen.Assign(FLines[i].Pen) ;
                   for j := 0 to FLines[i].Count-1 do begin
                       xy^[j].x := XToCanvasCoord( MFChan[iChan], FLines[i].x^[j] ) ;
                       xy^[j].y := YToCanvasCoord( MFChan[iChan], FLines[i].y^[j]  ) ;
                       end ;
                   Polyline( TMFC.Handle, xy^, FLines[i].Count ) ;
                   TMFC.Pen.Assign(DefaultPen) ;
                   end;
                end ;

            { Draw baseline levels }
            if FPrinterShowZeroLevels then begin
               TMFC.Pen.Width := 1 ;
               TMFC.Pen.Style := psDot ;
               for ch := 0 to FNumChannels-1 do if MFChan[ch].InUse then begin
                   YPix := YToCanvasCoord( MFChan[ch], MFChan[ch].ADCZero ) ;
                   TMFC.MoveTo( MFChan[ch].Left,  YPix ) ;
                   TMFC.LineTo( MFChan[ch].Right, YPix ) ;
                   end ;
               end ;

            { Restore pen to black and solid for cal. bars }
            TMFC.Pen.Assign(DefaultPen) ;

            if FPrinterShowLabels then begin
               { Draw vertical calibration bars }
               for ch := 0 to FNumChannels-1 do
                   if MFChan[ch].InUse and (MFChan[ch].CalBar <> 0.0) then begin
                   { Bar label }
                   Lab := format( '%6.5g %s ', [MFChan[ch].CalBar,MFChan[ch].ADCUnits] ) ;
                   { Calculate position/size of bar }
                   Bar.Left := MFChan[ch].Left - TMFC.TextWidth(Lab+' ') div 2 ;
                   Bar.Right := Bar.Left + TMFC.TextWidth('X') ;
                   Bar.Bottom := MFChan[ch].Bottom ;
                   Bar.Top := Bar.Bottom
                              - Abs( Round((MFChan[ch].CalBar*MFChan[ch].yScale)/
                                         MFChan[ch].ADCScale) ) ;
                   { Draw vertical bar with T's at each end }
                   TMFC.MoveTo( Bar.Left ,  Bar.Bottom ) ;
                   TMFC.LineTo( Bar.Right , Bar.Bottom ) ;
                   TMFC.MoveTo( Bar.Left ,  Bar.Top ) ;
                   TMFC.LineTo( Bar.Right , Bar.Top ) ;
                   TMFC.MoveTo( (Bar.Left + Bar.Right) div 2,  Bar.Bottom ) ;
                   TMFC.LineTo( (Bar.Left + Bar.Right) div 2,  Bar.Top ) ;
                   { Draw bar label }
                   TMFC.TextOut(MFChan[ch].Left - TMFC.TextWidth(Lab),
                                MFChan[ch].Bottom
                                + TMFC.TextHeight(Lab) div 4,
                                Lab ) ;
                   end ;

               { Draw horizontal time calibration bar }
               Lab := format( '%.4g %s', [FTCalBar*FTScale,FTUnits] ) ;
               { Calculate position/size of bar }
               LastCh := 0 ;
               for ch := 0 to FNumChannels-1 do if Channel[ch].InUse then begin
                   Bar.Top := MFChan[ch].Bottom + TMFC.TextHeight(Lab)*3 ;
                   LastCh := ch ;
                   end ;
               Bar.Bottom := Bar.Top + (TMFC.TextHeight(Lab) div 2);
               Bar.Left := MFChan[LastCh].Left ;
               Bar.Right := Bar.Left + Round(FTCalBar*MFChan[LastCh].xScale) ;
               { Draw vertical bar with T's at each end }
               TMFC.MoveTo( Bar.Left ,  Bar.Bottom ) ;
               TMFC.LineTo( Bar.Left ,  Bar.Top ) ;
               TMFC.MoveTo( Bar.Right , Bar.Bottom ) ;
               TMFC.LineTo( Bar.Right , Bar.Top ) ;
               TMFC.MoveTo( Bar.Left, (Bar.Top + Bar.Bottom) div 2 ) ;
               TMFC.LineTo( Bar.Right,(Bar.Top + Bar.Bottom) div 2 ) ;
               { Draw bar label }
               TMFC.TextOut(Bar.Left ,
                         Bar.Bottom + TMFC.TextHeight(Lab) div 4,
                         Lab ) ;

               // Marker text
               for i := 0 to FMarkerText.Count-1 do begin
                   xPix := XToCanvasCoord( MFChan[LastCh],
                                           Integer(FMarkerText.Objects[i]) ) ;
                   yPix := MFChan[LastCh].Bottom +
                           ((i Mod 2)+1)*TMFC.TextHeight(FMarkerText.Strings[i]) ;
                   TMFC.TextOut( xPix, yPix, FMarkerText.Strings[i] );
                   end ;

               end ;
        finally
            { Free metafile canvas. Note this copies plot into metafile object }
            DefaultPen.Free ;
            TMFC.Free ;
            end ;

        { Copy metafile to clipboard }
        Clipboard.Assign(TMF) ;

     finally
           { Get rid of array }
           Dispose(xy) ;
           Cursor := crDefault ;
           end ;

     end ;


procedure TScopeDisplay.CodedTextOut(
          Canvas : TCanvas ;           // Output Canvas
          var LineLeft : Integer ;     // Position of left edge of line
          var LineYPos : Integer ;     // Vertical line position
          List : TStringList           // Strings to be displayed
          ) ;
//----------------------------------------------------------------
// Display lines of text with ^-coded super/subscripts and symbols
//----------------------------------------------------------------
// Added 17/7/01
var
   DefaultFont : TFont ;
   Line,LineSpacing,YSuperscriptShift,YSubscriptShift,i,X,Y : Integer ;
   Done : Boolean ;
   TextLine : string ;
begin

     // Store default font settings
     DefaultFont := TFont.Create ;
     DefaultFont.Assign(Canvas.Font) ;

     try

     // Inter-line spacing and offset used for super/subscripting
     LineSpacing := Canvas.TextHeight('X') ;
     YSuperscriptShift := LineSpacing div 4 ;
     YSubscriptShift := LineSpacing div 2 ;
     LineSpacing := LineSpacing + YSuperscriptShift ;

     // Move to start position for text output
     Canvas.MoveTo( LineLeft, LineYPos ) ;

     { Display coded lines of text on device }

     for Line := 0 to FTitle.Count-1 do begin

         // Get line of text
         TextLine := FTitle.Strings[Line] ;

         // Move to start of line
         X := LineLeft ;
         Y := LineYPos ;
         Canvas.MoveTo( X, Y ) ;

         // Decode and output line
         Done := False ;
         i := 1 ;
         while not Done do begin

             // Get current cursor position
             X := Canvas.PenPos.X ;
             Y := LineYPos ;
             // Restore default font setting
             Canvas.Font.Assign(DefaultFont) ;

             if i <= Length(TextLine) then begin
                if TextLine[i] = '^' then begin
                   Inc(i) ;
                   case TextLine[i] of
                        // Bold
                        'b' : begin
                           Canvas.Font.Style := [fsBold] ;
                           Canvas.TextOut( X, Y, TextLine[i+1] ) ;
                           Inc(i) ;
                           end ;
                        // Italic
                        'i' : begin
                           Canvas.Font.Style := [fsItalic] ;
                           Canvas.TextOut( X, Y, TextLine[i+1] ) ;
                           Inc(i) ;
                           end ;
                        // Subscript
                        '-' : begin
                           Y := Y + YSubscriptShift ;
                           Canvas.Font.Size := (3*Canvas.Font.Size) div 4 ;
                           Canvas.TextOut( X, Y, TextLine[i+1] ) ;
                           Inc(i) ;
                           end ;
                        // Superscript
                        '+' : begin
                           Y := Y - YSuperscriptShift ;
                           Canvas.Font.Size := (3*Canvas.Font.Size) div 4 ;
                           Canvas.TextOut( X, Y, TextLine[i+1] ) ;
                           Inc(i) ;
                           end ;
                        // Superscripted 2
                        '2' : begin
                           Y := Y - YSuperscriptShift ;
                           Canvas.Font.Size := (3*Canvas.Font.Size) div 4 ;
                           Canvas.TextOut( X, Y, '2' ) ;
                           end ;

                        // Greek letter from Symbol character set
                        's' : begin
                           Canvas.Font.Name := 'Symbol' ;
                           Canvas.TextOut( X, Y, TextLine[i+1] ) ;
                           Inc(i) ;
                           end ;
                        // Square root symbol
                        '!' : begin
                           Canvas.Font.Name := 'Symbol' ;
                           Canvas.TextOut( X, Y, chr(214) ) ;
                           end ;
                        // +/- symbol
                        '~' : begin
                           Canvas.Font.Name := 'Symbol' ;
                           Canvas.TextOut( X, Y, chr(177) ) ;
                           end ;

                        end ;
                   end
                else Canvas.TextOut( X, Y, TextLine[i] ) ;

                Inc(i) ;
                end
             else Done := True ;
             end ;

         // Increment position to next line
         LineYPos := LineYPos + LineSpacing ;

         Canvas.Font.Assign(DefaultFont) ;

         end ;

     finally

            DefaultFont.Free ;

            end ;

     end ;



procedure TScopeDisplay.ClearPrinterTitle ;
{ -------------------------
  Clear printer title lines
  -------------------------}
begin
     FTitle.Clear ;
     end ;


procedure TScopeDisplay.AddPrinterTitleLine(
          Line : string
          );
{ ---------------------------
  Add a line to printer title
  ---------------------------}
begin
     FTitle.Add( Line ) ;
     end ;


function TScopeDisplay.CreateLine(
          Ch : Integer ;                    { Display channel to be drawn on [IN] }
          iColor : TColor ;                 { Line colour [IN] }
          iStyle : TPenStyle ;               { Line style [IN] }
          Width : Integer                   // Line width (IN)
          ) : Integer ;
{ -----------------------------------------------
  Create a line to be superimposed on the display
  -----------------------------------------------}
var
    iLine : Integer ;
begin
     { Create line data array }
     iLine := 0 ;
     while (FLines[iLine].x <> Nil) and (iLine < High(FLines)) do Inc(iLine) ;
     if iLine >= High(FLines) then begin
        Result := -1 ;
        exit ;
        end;

     New(FLines[iLine].x) ;
     New(FLines[iLine].y) ;
     FLines[iLine].Count := 0 ;
     FLines[iLine].Channel := Min(Max(ch,0),FNumChannels-1) ;
     FLines[iLine].Pen.Color := iColor ;
     FLines[iLine].Pen.Style := iStyle ;
     FLines[iLine].Pen.Width := Width ;

     Result := iLine ;

     end ;


procedure TScopeDisplay.AddPointToLine(
          iLine : Integer ;
          x : single ;
          y : single
          ) ;
{ ---------------------------
  Add a point to end of line
  ---------------------------}
var
   xPix, yPix,iChan,nCount : Integer ;
   KeepPen : TPen ;
begin

     if FLines[iLine].x = Nil then exit ;

     KeepPen := TPen.Create ;

     { Add x,y point to array }
     nCount := FLines[iLine].Count ;
     iChan := FLines[iLine].Channel ;
     FLines[iLine].x^[nCount] := x ;
     FLines[iLine].y^[nCount] := y ;

     { Add line to end of plot }
     if nCount > 0 then begin
        KeepPen.Assign(Canvas.Pen) ;
        Canvas.Pen.Assign(FLines[iLine].Pen) ;
        xPix := XToCanvasCoord( Channel[iChan], FLines[iLine].x^[nCount] ) ;
        yPix := YToCanvasCoord( Channel[iChan], FLines[iLine].y^[nCount] ) ;
        Canvas.MoveTo( xPix, yPix ) ;
        xPix := XToCanvasCoord( Channel[iChan], x ) ;
        yPix := YToCanvasCoord( Channel[iChan], y ) ;
        Canvas.LineTo( xPix, yPix ) ;
        Canvas.Pen.Assign(KeepPen) ;
        end ;

     if nCount < High(TSinglePointArray) then Inc(nCount) ;
     FLines[iLine].Count := nCount ;
     KeepPen.Free ;
     end ;

procedure TScopeDisplay.ClearLines ;
// -----------------
// Clear added lines
// -----------------
var
    i : Integer ;
begin
    for i := 0 to High(Flines) do begin
        if FLines[i].x <> Nil then begin
           Dispose(FLines[i].x) ;
           FLines[i].x := Nil ;
           end;
        if FLines[i].y <> Nil then begin
           Dispose(FLines[i].y) ;
           FLines[i].y := Nil ;
           end;
        FLines[i].Count := 0 ;
        end;
    end ;


procedure TScopeDisplay.DrawZoomButton(
          var CV : TCanvas ;
          X : Integer ;
          Y : Integer ;
          Size : Integer ;
          ButtonType : Integer ;
          ChanNum : Integer
          ) ;
var
    SavedBrush : TBrushRecall ;
    SavedPen : TPenRecall ;
    XMid,YMid,HalfSize : Integer ;
begin

    SavedBrush := TBrushRecall.Create( CV.Brush ) ;
    SavedPen := TPenRecall.Create( CV.Pen ) ;

    CV.Pen.Color := clBlack ;
    CV.Brush.Style := bsSolid ;
    CV.Brush.Color := clGray ;

    HalfSize := Size div 2 ;
    XMid :=  X + HalfSize -1 ;
    YMid :=  Y + HalfSize -1 ;

    ZoomButtonList[NumZoomButtons].Rect.Left := X ;
    ZoomButtonList[NumZoomButtons].Rect.Top := Y ;
    ZoomButtonList[NumZoomButtons].Rect.Right := X + Size -1 ;
    ZoomButtonList[NumZoomButtons].Rect.Bottom := Y + Size -1 ;
    ZoomButtonList[NumZoomButtons].ChanNum := ChanNum ;
    ZoomButtonList[NumZoomButtons].ButtonType := ButtonType ;

    CV.RoundRect( ZoomButtonList[NumZoomButtons].Rect.Left,
                  ZoomButtonList[NumZoomButtons].Rect.Top,
                  ZoomButtonList[NumZoomButtons].Rect.Right,
                  ZoomButtonList[NumZoomButtons].Rect.Bottom,
                  2,2) ;

    CV.Pen.Color := clWhite ;

    // Draw button label

    case ButtonType of
       cZoomOutButton : begin
          CV.Polyline( [Point(X+2,YMid),Point(X+Size-3,YMid)]);
          end ;
       cZoomInButton : begin
          CV.Polyline( [Point(X+2,YMid),Point(X+Size-3,YMid)]);
          CV.Polyline( [Point(XMid,Y+2),Point(XMid,Y+Size-3)]);
          end ;
       cZoomUpButton : begin
          CV.Polygon( [Point(XMid,Y+2),
                       Point(X+2,Y+Size-3),
                       Point(X+Size-3,Y+Size-3)]);
          end ;
       cZoomDownButton : begin
          CV.Polygon( [Point(XMid,Y+Size-3),
                       Point(X+2,Y+2),
                       Point(X+Size-3,Y+2)]);
          end ;
       cZoomLeftButton : begin
          CV.Polygon( [Point(X+2,YMid),
                       Point(X+Size-3,Y+2),
                       Point(X+Size-3,Y+Size-3)]);
          end ;
       cZoomRightButton : begin
          CV.Polygon( [Point(X+Size-3,YMid),
                       Point(X+2,Y+2),
                       Point(X+2,Y+Size-3)]);
          end ;
       cEnabledButton : begin
          if Channel[ChanNum].InUse then begin
             CV.Polyline( [Point(X+2,Y+Size-4),
                           Point(X+4,Y+Size-2),
                           Point(X+Size-3,Y+2)]);
             end
          else begin
             CV.Polyline( [Point(X+2,Y+2),
                           Point(X+Size-3,Y+Size-3)]) ;
             CV.Polyline( [Point(X+Size-3,Y+2),
                        Point(X+2,Y+Size-3)]) ;
             end ;
          end ;
       end ;

    SavedBrush.Free ;
    SavedPen.Free ;

    if NumZoomButtons < High(ZoomButtonList) then Inc(NumZoomButtons) ;

    end ;


procedure TScopeDisplay.CheckZoomButtons ;
// -------------------------------------------
// Handle mouse clicks on display zoom buttons
// -------------------------------------------
var
    ch,i,ChanNum : Integer ;
    XRange,YRange : Single ;
begin

    for i := 0 to NumZoomButtons-1 do begin
        if (MouseX >= ZoomButtonList[i].Rect.Left) and
           (MouseX <= ZoomButtonList[i].Rect.Right) and
           (MouseY >= ZoomButtonList[i].Rect.Top) and
           (MouseY <= ZoomButtonList[i].Rect.Bottom) then begin
           ChanNum := ZoomButtonList[i].ChanNum ;
           case ZoomButtonList[i].ButtonType of

             cZoomInButton : begin
                  if ChanNum >= 0 then Self.YZoom( ChanNum, -50.0 )
                                  else Self.XZoom( -50.0 ) ;
                  end ;

             cZoomOutButton : begin
                  if ChanNum >= 0 then Self.YZoom( ChanNum, 100.0 )
                                  else Self.XZoom( 100.0 ) ;
                  end ;

             cZoomUpButton : begin
                 YRange := (Channel[ChanNum].YMax - Channel[ChanNum].YMin) ;
                 Channel[ChanNum].YMax := Min( FMaxADCValue,
                                               Channel[ChanNum].YMax + (YRange*0.1));
                 Channel[ChanNum].YMin := Max( FMinADCValue,
                                               Channel[ChanNum].YMax - YRange);
                 end ;

             cZoomDownButton : begin
                 YRange := (Channel[ChanNum].YMax - Channel[ChanNum].YMin) ;
                 Channel[ChanNum].YMin := Max( FMinADCValue,
                                               Channel[ChanNum].YMin - (YRange*0.1));
                 Channel[ChanNum].YMax := Min( FMaxADCValue,
                                               Channel[ChanNum].YMin + YRange);
                 end ;

             cZoomLeftButton : begin
                 if FNumPoints > 0 then begin
                    XRange := (FXMax - FXMin) ;
                    FXMin := Max( 0,Round(FXMin - (XRange*0.1)));
                    FXMax := Min( FNumPoints,Round(FXMin + XRange));
                    end ;
                 for ch := 0 to FNumChannels-1 do begin
                     Channel[ch].XMin := FXMin ;
                     Channel[ch].XMax := FXMax ;
                     end ;
                 end ;

             cZoomRightButton : begin
                 if FNumPoints > 0 then begin
                    XRange := (FXMax - FXMin) ;
                    FXMax := Min( FNumPoints,Round(FXMax + (XRange*0.1)));
                    FXMin := Max( 0,Round(FXMax - XRange));
                    end ;
                 for ch := 0 to FNumChannels-1 do begin
                     Channel[ch].XMin := FXMin ;
                     Channel[ch].XMax := FXMax ;
                     end ;
                 end ;

             cEnabledButton : begin
                 Channel[ChanNum].InUse := not Channel[ChanNum].InUse ;
                 end ;
             end ;
           Invalidate ;
           end ;
        end ;
    end ;


procedure TScopeDisplay.ShowSelectedZoomButton ;
// --------------------------------------
// Change colour of selected zoom button
// --------------------------------------
var
    i : Integer ;
    SavedBrush : TBrushRecall ;
begin

    SavedBrush := TBrushRecall.Create( Canvas.Brush ) ;
    Canvas.Brush.Color := clBlack ;
    Canvas.Brush.Style := bsSolid ;

    for i := 0 to NumZoomButtons-1 do begin
        if (MouseX >= ZoomButtonList[i].Rect.Left) and
           (MouseX <= ZoomButtonList[i].Rect.Right) and
           (MouseY >= ZoomButtonList[i].Rect.Top) and
           (MouseY <= ZoomButtonList[i].Rect.Bottom) then begin
           Canvas.RoundRect( ZoomButtonList[i].Rect.Left,
                         ZoomButtonList[i].Rect.Top,
                         ZoomButtonList[i].Rect.Right,
                         ZoomButtonList[i].Rect.Bottom,
                         2,2) ;
           end ;
        end ;

    SavedBrush.Free ;

    end ;


procedure TScopeDisplay.ProcessZoomBox ;
// ----------------
// Process zoom box
// ----------------
var
    BoxTop,BoxBottom : Integer ;
    BoxLeft,BoxRight : Integer ;
    ch : Integer ;
    yMax,yScale : Single ;
    xMin,xScale : Single ;
begin

     // Exit if zoom box invalid
     if ZoomRectCount <= 1 then begin
        ZoomRectCount := 0 ;
        Exit ;
        end ;

     if Abs(ZoomRect.Bottom - ZoomRect.Top) < 8 then Exit ;
     if Abs(ZoomRect.Right - ZoomRect.Left) < 8 then Exit ;

     // Vertical magnification
     if not ZoomDisableVertical then begin
        yMax := Channel[ZoomChannel].yMax ;
        YScale := (Channel[ZoomChannel].yMax - Channel[ZoomChannel].yMin) /
                  (Channel[ZoomChannel].Top - Channel[ZoomChannel].Bottom) ;

        BoxTop := Min( ZoomRect.Top, ZoomRect.Bottom ) ;
        BoxBottom := Max( ZoomRect.Top, ZoomRect.Bottom ) ;
        Channel[ZoomChannel].yMax := Round( yMax +
                                     (BoxTop - Channel[ZoomChannel].Top)*YScale ) ;
        Channel[ZoomChannel].yMin := Round( yMax +
                                     (BoxBottom - Channel[ZoomChannel].Top)*YScale ) ;
        end ;

     // Horizontal magnification
     if not ZoomDisableHorizontal then begin
        xMin := FXMin ;
        XScale := (FXMax - FXMin) /
                  (Channel[ZoomChannel].Right - Channel[ZoomChannel].Left) ;
        BoxLeft := Min( ZoomRect.Left, ZoomRect.Right ) ;
        BoxRight := Max( ZoomRect.Left, ZoomRect.Right ) ;

        FXMin := Round( FXMin + (BoxLeft - Channel[ZoomChannel].Left)*XScale ) ;
        FXMax := Round( xMin + (BoxRight - Channel[ZoomChannel].Left)*XScale ) ;

        for ch := 0 to FNumChannels-1 do begin
            Channel[ch].XMin := FXMin ;
            Channel[ch].XMax := FXMax ;
            end ;

        end ;

     ZoomRectCount := 0 ;

     Invalidate ;

     end ;


procedure TScopeDisplay.ResizeZoomBox(
          X : Integer ;
          Y : Integer ) ;
// -----------------------------
// Resize zoom box (if one exists)
// -----------------------------
var
   OldCopyMode : TCopyMode ;
begin

     // Display zoom box
     if ZoomRectCount <= 0 then Exit ;
     if FHorCursorActive or FVertCursorActive then Exit ;
     if (X < Channel[ZoomChannel].Left) or
        (X > Channel[ZoomChannel].Right) or
        (Y < Channel[ZoomChannel].Top) or
        (Y > Channel[ZoomChannel].Bottom) then Exit ;

     OldCopyMode := Canvas.CopyMode ;
     Canvas.CopyMode := cmNotSrcCopy ;

     // Remove existing zoom rectangle
     if ZoomRectCount > 1 then Canvas.CopyRect( ZoomRect, Canvas, ZoomRect ) ;

     // Update right edge of zoom box
     if FZoomDisableHorizontal then begin
        ZoomRect.Right := Channel[0].Right ;
        ZoomRect.Left := Channel[0].Left ;
        end
     else ZoomRect.Right :=  Min(Max(X,Channel[0].Left),Channel[0].Right) ;

     // Update bottom edge of zoom box
     if FZoomDisableVertical then begin
        ZoomRect.Top := Channel[ZoomChannel].Top ;
        ZoomRect.Bottom := Channel[ZoomChannel].Bottom ;
        end
     else ZoomRect.Bottom := Min(Max(Y,Channel[ZoomChannel].Top),
                                       Channel[ZoomChannel].Bottom) ;

     // Display new zoom rectangle
     Canvas.CopyRect( ZoomRect, Canvas, ZoomRect ) ;
     Canvas.CopyMode := OldCopyMode ;

     Inc(ZoomRectCount) ;
     end ;


end.



