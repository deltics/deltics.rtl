

  unit Deltics.GDI.Regions;


interface

  uses
    Windows;


  type
    TGDIRegionChangeEvent = procedure(const aRGN: HRGN) of object;


    TGDIRegion = class
    private
      fHandle: HRGN;
      fOnChange: TGDIRegionChangeEvent;
      fRetain: Boolean;
      procedure set_Handle(const aValue: HRGN);
      procedure DoChanged;
    public
      class function ForCircle(const aCenter: TPoint; const aRadius: Integer): HRGN;
      class function ForEllipse(const aRect: TRect): HRGN;
      class function ForRect(const aRect: TRect): HRGN; overload;
      class function ForRect(const aLeft, aTop, aRight, aBottom: Integer): HRGN; overload;
      class function ForShape(const aPoints: array of TPoint): HRGN; overload;

      constructor Create; overload;
      constructor CreateNonVolatile; overload;
      constructor Create(const aOnChange: TGDIRegionChangeEvent); overload;
      destructor Destroy; override;
      procedure Add(const aRect: TRect); overload;
      procedure Add(const aPoints: array of TPoint); overload;
      procedure Delete; overload;
      procedure Delete(const aCenter: TPoint; const aRadius: Integer); overload;
      procedure Delete(const aRect: TRect); overload;
      procedure Delete(const aRGN: HRGN); overload;
      procedure Init(const aRect: TRect); overload;
      procedure Init(const aCenter: TPoint; const aRadius: Integer); overload;
      procedure InitElliptical(const aRect: TRect); overload;
//      procedure Init(const aWidth, aHeight: Integer); overload;
      procedure Init(const aLeft, aTop, aRight, aBottom: Integer); overload;
      property Handle: HRGN read fHandle write set_Handle;
      property OnChange: TGDIRegionChangeEvent read fOnChange write fOnChange;
    end;



implementation



{ TRegion }

  constructor TGDIRegion.Create;
  begin
    inherited Create;
  end;


  constructor TGDIRegion.Create(const aOnChange: TGDIRegionChangeEvent);
  begin
    Create;
    fOnChange := aOnChange;
  end;


  constructor TGDIRegion.CreateNonVolatile;
  begin
    Create;
    fRetain := TRUE;
  end;


  procedure TGDIRegion.Delete;
  begin
    DeleteObject(fHandle);
    fHandle := 0;
  end;


  destructor TGDIRegion.Destroy;
  begin
    if NOT fRetain then
      Delete;

    inherited;
  end;


  procedure TGDIRegion.DoChanged;
  begin
    if Assigned(fOnChange) then
      fOnChange(fHandle);
  end;


  class function TGDIRegion.ForCircle(const aCenter: TPoint;
                                      const aRadius: Integer): HRGN;
  var
    rc: TRect;
  begin
    rc.Left   := aCenter.X - aRadius;
    rc.Top    := aCenter.Y - aRadius;
    rc.Right  := aCenter.X + aRadius;
    rc.Bottom := aCenter.Y + aRadius;

    result := CreateEllipticRgnIndirect(rc);
  end;


  class function TGDIRegion.ForEllipse(const aRect: TRect): HRGN;
  begin
    result := CreateEllipticRgnIndirect(aRect);
  end;


  class function TGDIRegion.ForRect(const aRect: TRect): HRGN;
  begin
    result := CreateRectRgnIndirect(aRect);
  end;


  class function TGDIRegion.ForRect(const aLeft, aTop, aRight, aBottom: Integer): HRGN;
  begin
    result := CreateRectRgn(aLeft, aTop, aRight, aBottom);
  end;



  class function TGDIRegion.ForShape(const aPoints: array of TPoint): HRGN;
  begin
    result := CreatePolygonRgn(aPoints, Length(aPoints), WINDING);
  end;


  procedure TGDIRegion.Delete(const aCenter: TPoint; const aRadius: Integer);
  var
    rgn: HRGN;
  begin
    rgn := ForCircle(aCenter, aRadius);
    Delete(rgn);
    DeleteObject(rgn);
  end;


  procedure TGDIRegion.Delete(const aRect: TRect);
  var
    rgn: HRGN;
  begin
    rgn := ForRect(aRect);
    Delete(rgn);
    DeleteObject(rgn);
  end;


  procedure TGDIRegion.Delete(const aRGN: HRGN);
  begin
    CombineRgn(fHandle, fHandle, aRGN, RGN_DIFF);
    DoChanged;
  end;


  procedure TGDIRegion.set_Handle(const aValue: HRGN);
  begin
    if fHandle = aValue then
      EXIT;

    if fHandle <> 0 then
      Delete;

    fHandle := aValue;

    DoChanged;
  end;


  procedure TGDIRegion.Add(const aRect: TRect);
  var
    rc: HRGN;
  begin
    rc := ForRect(aRect);

    CombineRgn(fHandle, fHandle, rc, RGN_OR);
    DoChanged;
  end;


  procedure TGDIRegion.Add(const aPoints: array of TPoint);
  var
    shape: HRGN;
  begin
    shape := ForShape(aPoints);

    CombineRgn(fHandle, fHandle, shape, RGN_OR);
    DoChanged;
  end;


  procedure TGDIRegion.Init(const aCenter: TPoint;
                            const aRadius: Integer);
  begin
    Handle := ForCircle(aCenter, aRadius);
  end;


(*
  procedure TGDIRegion.Init(const aWidth, aHeight: Integer);
  begin
    Handle := CreateRectRgn(-1, -1, aWidth, aHeight);
  end;
*)

  procedure TGDIRegion.Init(const aRect: TRect);
  begin
    Handle := ForRect(aRect);
  end;


  procedure TGDIRegion.Init(const aLeft, aTop, aRight, aBottom: Integer);
  begin
    Handle := ForRect(aLeft, aTop, aRight, aBottom);
  end;


  procedure TGDIRegion.InitElliptical(const aRect: TRect);
  begin
    Handle := ForEllipse(aRect);
  end;






end.

