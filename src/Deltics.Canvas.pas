
  unit Deltics.Canvas;

{$i deltics.inc}

interface

  uses
    Contnrs,
    Controls,
    Forms,
    Graphics,
    Windows,
    Deltics.Canvas.Stacks,
    Deltics.GDI.Regions,
    Deltics.Strings;


  type
    TFormArea = (faClientArea, faNonClientArea);


    TCanvas = class(Graphics.TCanvas)
    private
      function get_Handle: HDC;
      procedure set_Handle(const aValue: HDC);
    protected
      procedure CreateHandle; override;
    public
      constructor Create(const aHandle: HDC);
      destructor Destroy; override;
      procedure Draw(const aGraphic: TGraphic; const aRect: TRect); overload;

      property Handle: HDC read get_Handle write set_Handle;
    end;


    TEnhancedCanvas = class(TCanvas)
    private
      fClipRgn: TClipRgnStack;
      fDC: HDC;
      fWND: HWND;
      fBkMode: TModeStack;
      fBrush: TBrushStack;
      fFont: TFontStack;
      fPen: TPenStack;
      fTextColor: TColorStack;
      fUpdateCount: Integer;
      procedure set_DC(const aValue: HDC);
    protected
      procedure DoBeginUpdate; virtual;
      procedure DoEndUpdate; virtual;
    public
      constructor Create; overload;
      constructor Create(const aDC: HDC); overload;
      constructor Create(const aForm: TForm); overload;
      constructor CreateNonClient(const aForm: TForm);
      destructor Destroy; override;
      procedure Draw(aX, aY: Integer; aGraphic: TGraphic); overload; {$ifNdef DELPHI7}override;{$endif}
      procedure Draw(const aGraphic: TGraphic; const aRect: TRect); overload;
      procedure DrawHorizontalLine(const aY, aLeft, aRight: Integer);
      procedure DrawIcon(const aIcon: HICON; const aRect: TRect);
      procedure DrawVerticalLine(const aX, aTop, aBottom: Integer);
      procedure DrawText(const aString: String; var aRect: TRect; const aFlags: Integer);
      procedure Fill; overload;
      procedure Fill(const aColor: TColor); overload;
      procedure Fill(const aBrush: HBRUSH); overload;
      procedure FillRect(const aRect: TRect); overload;
      procedure FillRect(const aRect: TRect; const aColor: TColor); overload;
      procedure FillRect(const aRect: TRect; const aBrush: HBRUSH); overload;
      procedure FillRgn(const aRGN: HRGN); overload;
      procedure FillRgn(const aRGN: HRGN; const aBrush: HBRUSH); overload;
      procedure FillRgn(const aRGN: HRGN; const aColor: TColor); overload;
      procedure FrameRect(const aRect: TRect); overload;
      procedure FrameRect(const aRect: TRect; const aBrush: HBRUSH); overload;
      procedure FrameRect(const aRect: TRect; const aColor: TColor); overload;
      procedure LineTo(const aPos: TPoint); overload;
      procedure LineTo(const aX, aY: Integer); overload;
      procedure LineTo(const aFrom, aTo: TPoint); overload;
      procedure LineTo(const aFromX, aFromY, aToX, aToY: Integer); overload;
      procedure MoveTo(const aPos: TPoint); overload;
      procedure MoveTo(const aX, aY: Integer); overload;
      procedure MoveTo(const aPos: TPoint; var aPrev: TPoint); overload;
      procedure MoveTo(const aX, aY: Integer; var aPrevX, aPrevY: Integer); overload;
      procedure TextExtent(const aString: String; var aRect: TRect; const aFlags: Integer);
      function TextHeight: Integer; overload;
      function TextHeight(const aString: String; const aWidth: Integer; const aFlags: Integer): Integer; overload;
      function TextWidth(const aString: String; const aFlags: Integer): Integer;
      procedure BeginUpdate;
      procedure EndUpdate;
      property BkMode: TModeStack read fBkMode;
      property Brush: TBrushStack read fBrush;
      property ClipRgn: TClipRgnStack read fClipRgn;
      property Font: TFontStack read fFont;
      property Pen: TPenStack read fPen;
      property TextColor: TColorStack read fTextColor;
      property HDC: HDC read fDC write set_DC;
      property HWND: HWND read fWND;
    end;


    TCompatibleCanvas = class(TEnhancedCanvas)
    private
      fCompatibleDC: HDC;
      procedure Init(const aDC: HDC); overload;
      procedure Reset;
    protected
      procedure DoEndUpdate; override;
      procedure DoReset; virtual;
    public
      property Handle: HDC read fCompatibleDC;
    end;


    TBufferedCanvas = class(TCompatibleCanvas)
    private
      fClipBuffer: TGDIRegion;
      fDestDC: HDC;
      fDestWND: HWND;
      fBMP: HBITMAP;
      fHeight: Integer;
      fWidth: Integer;
      procedure Init(const aDC: HDC; const aWidth, aHeight: Integer); overload;
    protected
      procedure DoEndUpdate; override;
      procedure DoReset; override;
    public
      procedure AfterConstruction; override;
      procedure BeforeDestruction; override;
      procedure BeginUpdate(const aControl: TWinControl); overload;
      procedure BeginUpdate(const aControl: TWinControl; const aRect: TRect); overload;
      procedure BeginUpdate(const aForm: TCustomForm; const aArea: TFormArea = faClientArea); overload;
      procedure BeginUpdate(const aForm: TCustomForm; const aRect: TRect; const aArea: TFormArea = faClientArea); overload;
      procedure BitBlt; overload;
      procedure BitBlt(const aX, aY: Integer); overload;
      procedure BitBlt(const aRect: TRect); overload;
      property ClipBuffer: TGDIRegion read fClipBuffer;
    end;


    TAACanvas = class(TBufferedCanvas)
    public
      procedure Init(const aDC: HDC; const aWidth, aHeight: Integer); overload;
      procedure BitBlt(const aRect: TRect); overload;
    end;


    TMeasuringCanvas = class(TCompatibleCanvas)
    public
      procedure BeginUpdate(const aDC: HDC); overload;
    end;


implementation

  uses
    Classes,
    SysUtils;

  type
    TGraphicHelper = class(TGraphic);


  {$ifdef DELPHIXE4__}
    TCanvasCrack = class(TCustomCanvas)
  {$else}
    TCanvasCrack = class(TPersistent)
  {$endif}
    private
      fHandle: HDC;
      fState: TCanvasState;
    end;


  constructor TCanvas.Create(const aHandle: HDC);
  begin
    inherited Create;

    Handle := aHandle;
  end;


  destructor TCanvas.Destroy;
  begin
    Handle := 0;

    inherited Destroy;
  end;


  procedure TCanvas.Draw(const aGraphic: TGraphic;
                         const aRect: TRect);
  var
    omode: Integer;
  begin
    omode := GetBkMode(Handle);
    try
      TGraphicHelper(aGraphic).Draw(self, aRect);

    finally
      SetBkMode(Handle, omode);
    end;
  end;


  function TCanvas.get_Handle: HDC;
  begin
    result := TCanvasCrack(self).fHandle;
  end;


  procedure TCanvas.set_Handle(const aValue: HDC);
  begin
    if (Handle = aValue) then
      EXIT;

    TCanvasCrack(self).fHandle := aValue;

    if (aValue = 0) then
      Exclude(TCanvasCrack(self).fState, csHandleValid)
    else
      Include(TCanvasCrack(self).fState, csHandleValid);
  end;


  procedure TCanvas.CreateHandle;
  begin
    raise Exception.Create('TCanvas error: Handle (HDC) has not been assigned');
  end;





{ TEnhancedCanvas }

  constructor TEnhancedCanvas.Create;
  begin
    Create(0);
  end;


  constructor TEnhancedCanvas.Create(const aDC: HDC);
  begin
    inherited Create(aDC);

    HDC := aDC;

    fClipRgn    := TClipRgnStack.Create(@fDC);
    fBrush      := TBrushStack.Create(@fDC);
    fFont       := TFontStack.Create(@fDC);
    fPen        := TPenStack.Create(@fDC);
    fBkMode     := TModeStack.Create(@fDC);
    fTextColor  := TColorStack.Create(@fDC);
  end;


  constructor TEnhancedCanvas.Create(const aForm: TForm);
  begin
    fWND := aForm.Handle;

    Create(GetDC(fWND));

    fClipRgn.Push(0, 0, aForm.ClientWidth, aForm.ClientHeight);
  end;


  constructor TEnhancedCanvas.CreateNonClient(const aForm: TForm);
  begin
    fWND := aForm.Handle;

    Create(GetWindowDC(fWND));

    fClipRgn.Push(0, 0, aForm.Width, aForm.Height);
  end;


  destructor TEnhancedCanvas.Destroy;
  begin
    fTextColor.Free;
    fBkMode.Free;
    fPen.Free;
    fFont.Free;
    fBrush.Free;
    fClipRgn.Free;

    HDC := 0;

    inherited;
  end;


  procedure TEnhancedCanvas.set_DC(const aValue: HDC);
  begin
    fDC := aValue;

    if (HDC = 0) then
    begin
      if (fWND <> 0) then
        ReleaseDC(fWND, fDC);

      fWND := 0;
    end;
  end;


  procedure TEnhancedCanvas.BeginUpdate;
  begin
    Inc(fUpdateCount);

    fBkMode.SavePoint;
    fBrush.SavePoint;
    fFont.SavePoint;
    fPen.SavePoint;
    fTextColor.SavePoint;
    fClipRgn.SavePoint;

    if fUpdateCount = 1 then
      DoBeginUpdate;
  end;


  procedure TEnhancedCanvas.EndUpdate;
  begin
    fBkMode.Restore;
    fBrush.Restore;
    fFont.Restore;
    fPen.Restore;
    fTextColor.Restore;
    fClipRgn.Restore;

    Dec(fUpdateCount);

    if fUpdateCount = 0 then
      DoEndUpdate;
  end;


  procedure TEnhancedCanvas.DoBeginUpdate;
  begin
    // NO-OP
  end;


  procedure TEnhancedCanvas.DoEndUpdate;
  begin
    // NO-OP
  end;


  procedure TEnhancedCanvas.Draw(aX, aY: Integer;
                                 aGraphic: TGraphic);
  var
    rc: TRect;
  begin
    rc := RECT(aX, aY, aX + aGraphic.Width, aY + aGraphic.Height);
    Draw(aGraphic, rc);
  end;


  procedure TEnhancedCanvas.Draw(const aGraphic: TGraphic;
                                 const aRect: TRect);
  var
    omode: Integer;
    odc: THandle;
  begin
    omode := GetBkMode(fDC);
    odc := Handle;
    set_DC(fDC);
    try
      TGraphicHelper(aGraphic).Draw(self, aRect);

    finally
      set_DC(odc);
      SetBkMode(fDC, omode);
    end;
  end;


  procedure TEnhancedCanvas.DrawHorizontalLine(const aY, aLeft, aRight: Integer);
  begin
    Windows.MoveToEx(fDC, aLeft, aY, NIL);
    Windows.LineTo(fDC, aRight, aY);
  end;


  procedure TEnhancedCanvas.DrawIcon(const aIcon: HICON;
                                const aRect: TRect);
  begin
    Windows.DrawIconEx(fDC, aRect.Left, aRect.Top, aIcon,
                            aRect.Right - aRect.Left, aRect.Bottom - aRect.Top, 0, 0, DI_NORMAL);
  end;


  procedure TEnhancedCanvas.DrawVerticalLine(const aX, aTop, aBottom: Integer);
  begin
    Windows.MoveToEx(fDC, aX, aTop, NIL);
    Windows.LineTo(fDC, aX, aBottom);
  end;


  procedure TEnhancedCanvas.DrawText(const aString: String;
                                var   aRect: TRect;
                                const aFlags: Integer);
  begin
    Windows.DrawTextEx(HDC, PChar(aString), Length(aString), aRect, aFlags, NIL);
  end;


  procedure TEnhancedCanvas.FillRect(const aRect: TRect);
  begin
    Windows.FillRect(fDC, aRect, Brush.Handle);
  end;


  procedure TEnhancedCanvas.Fill;
  begin
    ASSERT(fClipRgn.Count > 0, 'No clipping region');

    FillRgn(fClipRgn.Handle, fBrush.Peek);
  end;


  procedure TEnhancedCanvas.Fill(const aColor: TColor);
  begin
    ASSERT(fClipRgn.Count > 0, 'No clipping region');

    Brush.Push(aColor);
    Fill;
    Brush.Pop;
  end;


  procedure TEnhancedCanvas.Fill(const aBrush: HBRUSH);
  begin
    ASSERT(fClipRgn.Count > 0, 'No clipping region');

    FillRgn(fClipRgn.Handle, aBrush);
  end;


  procedure TEnhancedCanvas.FillRect(const aRect: TRect;
                                const aBrush: HBRUSH);
  begin
    Windows.FillRect(fDC, aRect, aBrush);
  end;


  procedure TEnhancedCanvas.FillRgn(const aRGN: HRGN;
                               const aColor: TColor);
  begin
    Brush.Push(aColor);
    Windows.FillRgn(fDC, aRGN, Brush.Handle);
    Brush.Pop;
  end;


  procedure TEnhancedCanvas.FillRgn(const aRGN: HRGN);
  begin
    Windows.FillRgn(fDC, aRGN, Brush.Handle);
  end;


  procedure TEnhancedCanvas.FillRect(const aRect: TRect;
                                const aColor: TColor);
  begin
    Brush.Push(aColor);
    FillRect(aRect);
    Brush.Pop;
  end;


  procedure TEnhancedCanvas.FillRgn(const aRGN: HRGN;
                               const aBrush: HBRUSH);
  begin
    Windows.FillRgn(fDC, aRGN, aBrush)
  end;


  procedure TEnhancedCanvas.FrameRect(const aRect: TRect;
                                 const aBrush: HBRUSH);
  begin
    Windows.FrameRect(fDC, aRect, aBrush);
  end;


  procedure TEnhancedCanvas.FrameRect(const aRect: TRect;
                                 const aColor: TColor);
  begin
    Brush.Push(aColor);
    Windows.FrameRect(fDC, aRect, Brush.Peek);
    Brush.Pop;
  end;



  procedure TEnhancedCanvas.LineTo(const aFromX, aFromY, aToX, aToY: Integer);
  begin
    Windows.MoveToEx(fDC, aFromX, aFromY, NIL);
    Windows.LineTo(fDC, aToX, aToY);
  end;


  procedure TEnhancedCanvas.LineTo(const aFrom, aTo: TPoint);
  begin
    Windows.MoveToEx(fDC, aFrom.X, aFrom.Y, NIL);
    Windows.LineTo(fDC, aTo.X, aTo.Y);
  end;


  procedure TEnhancedCanvas.LineTo(const aPos: TPoint);
  begin
    Windows.LineTo(fDC, aPos.X, aPos.Y);
  end;


  procedure TEnhancedCanvas.LineTo(const aX, aY: Integer);
  begin
    Windows.LineTo(fDC, aX, aY);
  end;


  procedure TEnhancedCanvas.TextExtent(const aString: String;
                                  var   aRect: TRect;
                                  const aFlags: Integer);
  begin
    Windows.DrawTextEx(HDC, PChar(aString), Length(aString), aRect, aFlags or DT_CALCRECT, NIL);
  end;


  procedure TEnhancedCanvas.MoveTo(const aX, aY: Integer);
  begin
    Windows.MoveToEx(fDC, aX, aY, NIL);
  end;


  procedure TEnhancedCanvas.MoveTo(const aPos: TPoint);
  begin
    Windows.MoveToEx(fDC, aPos.X, aPos.Y, NIL);
  end;


  procedure TEnhancedCanvas.MoveTo(const aX, aY: Integer;
                              var aPrevX, aPrevY: Integer);
  var
    prev: TPoint;
  begin
    Windows.MoveToEx(fDC, aX, aY, @prev);
    aPrevX := prev.X;
    aPrevY := prev.Y;
  end;


  procedure TEnhancedCanvas.MoveTo(const aPos: TPoint; var aPrev: TPoint);
  begin
    Windows.MoveToEx(fDC, aPos.X, aPos.Y, @aPrev);
  end;


  function TEnhancedCanvas.TextHeight: Integer;
  var
    rc: TRect;
  begin
    rc := RECT(0, 0, 0, 0);
    Windows.DrawTextEx(HDC, 'X', 1, rc, DT_CALCRECT or DT_SINGLELINE, NIL);
    result := rc.Bottom - rc.Top + 1;
  end;


  function TEnhancedCanvas.TextHeight(const aString: String;
                                 const aWidth: Integer;
                                 const aFlags: Integer): Integer;
  var
    rc: TRect;
  begin
    rc := RECT(0, 0, aWidth, 0);
    Windows.DrawTextEx(HDC, PChar(aString), Length(aString), rc, DT_CALCRECT or aFlags, NIL);
    result := rc.Bottom - rc.Top + 1;
  end;


  function TEnhancedCanvas.TextWidth(const aString: String;
                                const aFlags: Integer): Integer;
  var
    rc: TRect;
  begin
    rc := RECT(0, 0, 0, 0);
    Windows.DrawTextEx(HDC, PChar(aString), Length(aString), rc, DT_CALCRECT or aFlags, NIL);
    result := rc.Right - rc.Left + 1;
  end;


  procedure TEnhancedCanvas.FrameRect(const aRect: TRect);
  var
    rgn: HRGN;
  begin
    rgn := CreateRectRgnIndirect(aRect);
    FrameRgn(fDC, rgn, 0, 0, 0);
    DeleteObject(rgn);
  end;






  procedure TCompatibleCanvas.DoEndUpdate;
  begin
    Reset;
    inherited;
  end;


  procedure TCompatibleCanvas.DoReset;
  begin
    DeleteDC(fCompatibleDC);

    fDC            := 0;
    fCompatibleDC  := 0;
  end;


  procedure TCompatibleCanvas.Init(const aDC: HDC);
  begin
    fCompatibleDC  := CreateCompatibleDC(aDC);
    HDC            := fCompatibleDC;
  end;


  procedure TCompatibleCanvas.Reset;
  begin
    DoReset;
  end;







{ TBufferedGDI }

  procedure TBufferedCanvas.AfterConstruction;
  begin
    inherited;

    fClipBuffer := TGDIRegion.Create;
  end;


  procedure TBufferedCanvas.Init(const aDC: HDC;
                                    const aWidth, aHeight: Integer);
  begin
    inherited Init(aDC);

    fDestDC := aDC;
    fBMP    := CreateCompatibleBitmap(aDC, aWidth, aHeight);

    fHeight := aHeight;
    fWidth  := aWidth;

    ClipRgn.Push(0, 0, aWidth, aHeight);
    ClipBuffer.Init(0, 0, aWidth, aHeight);

    SelectObject(HDC, fBMP);
  end;


  procedure TBufferedCanvas.DoEndUpdate;

  var
    rc: TRect;
  begin
    SelectClipRGN(fDestDC, ClipBuffer.Handle);

    GetClipBox(fDestDC, rc);
    Windows.BitBlt(fDestDC, rc.Left, rc.Top, rc.Right - rc.Left + 1, rc.Bottom - rc.Top + 1,
                   HDC,     rc.Left, rc.Top, SRCCOPY);

    ClipBuffer.Delete;

    inherited;
  end;


  procedure TBufferedCanvas.BeginUpdate(const aControl: TWinControl);
  begin
    BeginUpdate(aControl, aControl.ClientRect);
  end;


  procedure TBufferedCanvas.BeginUpdate(const aControl: TWinControl;
                                        const aRect: TRect);
  begin
    fDestWND := aControl.Handle;
    Init(GetDC(fDestWND), aControl.Width, aControl.Height);

    inherited BeginUpdate;
  end;


  procedure TBufferedCanvas.BeginUpdate(const aForm: TCustomForm;
                                        const aArea: TFormArea);
  begin
    inherited BeginUpdate;

    fDestWND := aForm.Handle;

    case aArea of
      faClientArea    : Init(GetDC(fDestWND), aForm.ClientWidth, aForm.ClientHeight);
      faNonClientArea : Init(GetWindowDC(fDestWND), aForm.Width, aForm.Height);
    end;
  end;


  procedure TBufferedCanvas.BeforeDestruction;
  begin
    FreeAndNIL(fClipBuffer);
    inherited;
  end;


  procedure TBufferedCanvas.BeginUpdate(const aForm: TCustomForm;
                                        const aRect: TRect;
                                        const aArea: TFormArea);
  begin
    ASSERT((fDestWND = 0) or (fDestWND = aForm.Handle), 'Buffered canvas already in use');

    if (fDestWND = 0) then
    begin
      BeginUpdate(aForm, aArea);
      ClipRGN.Push(aRect);
      ClipBuffer.Init(aRect);
    end
    else
      inherited BeginUpdate;
  end;


  procedure TBufferedCanvas.BitBlt(const aRect: TRect);
  begin
    BitBlt(aRect.Left, aRect.Top)
  end;


  procedure TBufferedCanvas.DoReset;
  begin
    DeleteObject(fBMP);

    if (fDestWND <> 0) then
      ReleaseDC(fDestWND, fDestDC);

    fDestWND := 0;
    fDestDC  := 0;

    inherited;
  end;


  procedure TBufferedCanvas.BitBlt;
  begin
    BitBlt(0, 0);
  end;


  procedure TBufferedCanvas.BitBlt(const aX, aY: Integer);
  begin
    Windows.BitBlt(fDestDC, aX, aY, fWidth, fHeight, fCompatibleDC, 0, 0, SRCCOPY);
  end;













{ TMeasuringCanvas }

  procedure TMeasuringCanvas.BeginUpdate(const aDC: HDC);
  begin
    Init(aDC);
    inherited BeginUpdate;
  end;





{ TAACanvas }

  procedure TAACanvas.Init(const aDC: HDC;
                           const aWidth, aHeight: Integer);
  begin
    inherited Init(aDC, aWidth * 8, aHeight * 8);

    SetMapMode(HDC, MM_ANISOTROPIC);
    SetViewportExtEx(HDC, aWidth * 8, aHeight * 8, NIL);
    SetWindowExtEx(HDC, aWidth, aHeight, NIL);
  end;


  procedure TAACanvas.BitBlt(const aRect: TRect);
  var
    bmp: TBitmap;
    bmi: TBitmapInfo;
    bits: array of Byte;
  begin
    GetObject(fBMP, sizeof(bmp), @bmp);

    bmi.bmiHeader.biSize        := sizeof(bmi);
    bmi.bmiHeader.biWidth       := bmp.bmWidth;
    bmi.bmiHeader.biHeight      := bmp.bmHeight;
    bmi.bmiHeader.biBitCount    := bmp.bmBitsPixel;
    bmi.bmiHeader.biCompression := BI_RGB;
    bmi.bmiHeader.biPlanes      := bmp.bmPlanes;
    bmi.bmiHeader.biSizeImage   := bmp.bmWidthBytes * bmp.bmHeight * 4; // 4 stands for 32bpp

    SetLength(bits, bmi.bmiHeader.biSizeImage);
    GetDIBits(HDC, fBMP, 1, bmp.bmHeight, @bits[0], bmi, DIB_RGB_COLORS);

    SetStretchBltMode(fDestDC, HALFTONE);
    StretchDIBits(fDestDC, aRect.Left, aRect.Top, aRect.Right - aRect.Left, aRect.Bottom - aRect.Top,
                           0, 0, fWidth, fHeight, @bits[0], bmi, DIB_RGB_COLORS, SRCCOPY);
  end;




end.
