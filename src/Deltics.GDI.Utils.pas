

  unit Deltics.GDI.Utils;


interface

  uses
    Graphics,
    Windows;


  const
    xfIdentity: TXForm = ( eM11 : 1; eM12 : 0;
                           eM21 : 0; eM22 : 1;
                           eDx  : 0; eDy  : 0 );


  function ExcludeClipRect(const aDC: HDC; const aRect: TRect): Cardinal;

  procedure GradientFill(const aDC: HDC;
                         const aRect: TRect;
                         const aColorA, aColorB: TColor;
                         const aHorizontal: Boolean = FALSE); overload;
  procedure GradientFill(const aDC: HDC;
                         const aRect: TRect;
                         const aColors: array of TColor;
                         const aProportions: array of Integer;
                         const aHorizontal: Boolean = FALSE); overload;

  procedure GetTextMetrics(const aFont: TFont; var aMetrics: TTextMetric);
  function TextHeight(const aFont: TFont): Integer;


implementation


  function Win32GradientFill(aDC: HDC; aVertex: PTRIVERTEX; aNumVertex: ULONG; aMesh: Pointer; aNumMesh, aMode: ULONG): BOOL; stdcall;
    external msimg32 name 'GradientFill';


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function ExcludeClipRect(const aDC: HDC; const aRect: TRect): Cardinal;
  begin
    result := Windows.ExcludeClipRect(aDC, aRect.Left, aRect.Top, aRect.Right, aRect.Bottom);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure GradientFill(const aDC: HDC;
                         const aRect: TRect;
                         const aColorA, aColorB: TColor;
                         const aHorizontal: Boolean);
  var
    vtx: array[0..1] of TRIVERTEX;
    rc: GRADIENT_RECT;
  begin
    vtx[0].x := aRect.Left;
    vtx[0].y := aRect.Top;
    vtx[0].Red   := GetRValue(ColorToRGB(aColorA)) shl 8;
    vtx[0].Green := GetGValue(ColorToRGB(aColorA)) shl 8;
    vtx[0].Blue  := GetBValue(ColorToRGB(aColorA)) shl 8;
    vtx[0].Alpha := 0;

    vtx[1].x := aRect.Right;
    vtx[1].y := aRect.Bottom;
    vtx[1].Red   := GetRValue(ColorToRGB(aColorB)) shl 8;
    vtx[1].Green := GetGValue(ColorToRGB(aColorB)) shl 8;
    vtx[1].Blue  := GetBValue(ColorToRGB(aColorB)) shl 8;
    vtx[1].Alpha := 0;

    rc.UpperLeft  := 0;
    rc.LowerRight := 1;

    if aHorizontal then
      Win32GradientFill(aDC, @vtx[0], 2, @rc, 1, GRADIENT_FILL_RECT_H)
    else
      Win32GradientFill(aDC, @vtx[0], 2, @rc, 1, GRADIENT_FILL_RECT_V);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure GradientFill(const aDC: HDC;
                         const aRect: TRect;
                         const aColors: array of TColor;
                         const aProportions: array of Integer;
                         const aHorizontal: Boolean = FALSE);
  var
    i: Integer;
    w, h: Integer;
    rc: array of TRect;

  begin
    w := (aRect.Right - aRect.Left) + 1;
    h := (aRect.Bottom - aRect.Top) + 1;

    SetLength(rc, Length(aColors) - 1);

    for i := 0 to Pred(Length(rc)) do
      rc[i] := aRect;

    if aHorizontal then
      rc[0].Right := aRect.Left + ((aProportions[1] * w) div 100)
    else
      rc[0].Bottom  := aRect.Top + ((aProportions[1] * h) div 100);

    for i := 1 to Pred(Length(rc)) do
    begin
      if aHorizontal then
      begin
        rc[i].Left  := rc[i - 1].Right;
        rc[i].Right := aRect.Left + ((aProportions[i + 1] * w) div 100);
      end
      else
      begin
        rc[i].Top     := rc[i - 1].Bottom;
        rc[i].Bottom  := aRect.Top + ((aProportions[i + 1] * h) div 100);
      end;
    end;

    for i := 0 to Pred(Length(rc)) do
      GradientFill(aDC, rc[i], aColors[i], aColors[i + 1], aHorizontal);
  end;


  procedure GetTextMetrics(const aFont: TFont; var aMetrics: TTextMetric);
  var
    dc: HDC;
    ofont: HFONT;
  begin
    ofont := 0;
    dc    := GetDC(0);
    try
      ofont := SelectObject(dc, aFont.Handle);

      Windows.GetTextMetrics(dc, aMetrics);

    finally
      if ofont <> 0 then
        SelectObject(dc, ofont);
        
      ReleaseDC(0, dc);
    end;
  end;


  function TextHeight(const aFont: TFont): Integer;
  var
    tm: TTextMetric;
  begin
    GetTextMetrics(aFont, tm);
    result := tm.tmHeight;
  end;


end.
