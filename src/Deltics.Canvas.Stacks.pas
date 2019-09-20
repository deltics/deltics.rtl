

  unit Deltics.Canvas.Stacks;


interface

  uses
    Contnrs,
    Graphics,
    Windows;


  type
    TGDIStack = class;
    TGDIStackItem = class;
    TGDIStackItemClass = class of TGDIStackItem;

    TGDIObject = class;
    TBrushStack = class;
    TFontStack = class;
    TPenStack = class;
    TColorStack = class;
    TModeStack = class;

    PDC = ^HDC;


    TGDIStack = class
    private
      fDC: PDC;
      fItemClass: TGDIStackItemClass;
      fItems: TObjectList;
      fSavePoints: array of TGDIStackItem;
      function get_Count: Integer;
      constructor Create(const aDC: PDC; const aItemClass: TGDIStackItemClass); overload;
      function InternalPeek: TGDIStackItem; overload;
      function InternalPeek(var aItem): Boolean; overload;
      function InternalPush: TGDIStackItem;
      procedure InternalPop(var aItem); overload;
      function InternalPop: TGDIStackItem; overload;
    protected
      procedure DoPop(const aItem); virtual; abstract;
    public
      constructor Create(const aDC: PDC); overload; virtual; abstract;
      destructor Destroy; override;
      procedure Restore;
      procedure SavePoint;
      property Count: Integer read get_Count;
    end;


    TGDIObjectStack = class(TGDIStack)
    private
      function InternalPeek: TGDIObject; overload;
      function InternalPush(const aItem: THandle; const aDeleteOnPop: Boolean = FALSE): TGDIObject;
    protected
      procedure DoPop(const aItem); override;
      function DoSelect(const aItem: THandle): THandle; virtual;
    public
      constructor Create(const aDC: PDC); override;
      function Peek: THandle;
      function Pop: THandle;
    end;


    TGDIStackItem = class
    end;


    TGDIObject = class(TGDIStackItem)
      Item: THandle;
      oItem: THandle;
      Delete: Boolean;
    end;


    TGDIColor = class(TGDIStackItem)
      Color: TColor;
      oColor: TColor;
    end;


    TGDIMode = class(TGDIStackItem)
      Mode: Integer;
      oMode: Integer;
    end;


    TBrushStack = class(TGDIObjectStack)
    private
      function get_Handle: HBRUSH;
    public
      procedure Push(const aColor: TColor); overload;
      procedure Push(const aRed, aGreen, aBlue: Byte); overload;
      procedure Push(const aBrush: HBRUSH); overload;
      property Handle: HBRUSH read get_Handle;
    end;


    TFontStack = class(TGDIObjectStack)
    public
      procedure Push(const aFont: TLogFont); overload;
      procedure Push(const aFont: HFONT); overload;
    end;


    TPenStack = class(TGDIObjectStack)
    public
      procedure Change(const aPen: HPEN);
      procedure Push(const aPen: HPEN); overload;
      procedure Push(const aColor: TColor); overload;
    end;


    TClipRgnStack = class(TGDIObjectStack)
    private
      function get_Handle: HRGN;
      function Peek: HRGN;
    protected
      function DoSelect(const aItem: THandle): THandle; override;
    public
      procedure Exclude(const aRect: TRect); overload;
      procedure Exclude(const aRGN: HRGN); overload;
      procedure Push(const aRGN: HRGN); overload;
      procedure Push(const aRect: TRect); overload;
      procedure Push(const aLeft, aTop, aRight, aBottom: Integer); overload;
      property Handle: HRGN read get_Handle;
    end;


    TColorStack = class(TGDIStack)
    protected
      procedure DoPop(const aItem); override;
    public
      constructor Create(const aDC: PDC); override;
      procedure Change(const aColor: TColor);
      procedure Push(const aColor: TColor);
      function Pop: TColor;
    end;


    TModeStack = class(TGDIStack)
    protected
      procedure DoPop(const aItem); override;
    public
      constructor Create(const aDC: PDC); override;
      procedure Push(const aMode: Integer);
      function Pop: Integer;
    end;



implementation

  uses
    Deltics.GDI.Regions;


{ TGDIObjectStack }

  constructor TGDIStack.Create(const aDC: PDC;
                               const aItemClass: TGDIStackItemClass);
  begin
    inherited Create;

    fDC         := aDC;
    fItems      := TObjectList.Create(TRUE);
    fItemClass  := aItemClass;
  end;


  destructor TGDIStack.Destroy;
  begin
    while Count > 0 do
      InternalPop.Free;

    fItems.Free;

    inherited;
  end;


  function TGDIStack.get_Count: Integer;
  begin
    result := fItems.Count;
  end;


  function TGDIStack.InternalPush: TGDIStackItem;
  begin
    result := fItemClass.Create;
    fItems.Add(result);
  end;


  function TGDIStack.InternalPeek: TGDIStackItem;
  begin
    if Count > 0 then
      result := TGDIStackItem(fItems[fItems.Count - 1])
    else
      result := NIL;
  end;


  function TGDIStack.InternalPeek(var aItem): Boolean;
  var
    item: TGDIStackItem absolute aItem;
  begin
    item    := InternalPeek;
    result  := Assigned(item);
  end;


  function TGDIStack.InternalPop: TGDIStackItem;
  begin
    InternalPop(result);
  end;


  procedure TGDIStack.InternalPop(var aItem);
  var
    item: TGDIStackItem absolute aItem;
  begin
    if Count > 0 then
    begin
      item := TGDIStackItem(fItems[fItems.Count - 1]);

      DoPop(aItem);

      fItems.Extract(item);
    end
    else
      item := NIL;
  end;





{ TGDIObjectStack }

  constructor TGDIObjectStack.Create(const aDC: PDC);
  begin
    inherited Create(aDC, TGDIObject);
  end;


  procedure TGDIObjectStack.DoPop(const aItem);
  var
    o: TGDIObject absolute aItem;
  begin
    DoSelect(o.oItem);

    if o.Delete then
      DeleteObject(o.Item)
  end;


  function TGDIObjectStack.DoSelect(const aItem: THandle): THandle;
  begin
    result := SelectObject(fDC^, aItem);
  end;


  function TGDIObjectStack.InternalPeek: TGDIObject;
  begin
    result := TGDIObject(inherited InternalPeek);
  end;


  function TGDIObjectStack.InternalPush(const aItem: THandle;
                                        const aDeleteOnPop: Boolean): TGDIObject;
  begin
    result := TGDIObject(inherited InternalPush);

    result.Item   := aItem;
    result.oItem  := DoSelect(aItem);
    result.Delete := aDeleteOnPop;
  end;


  procedure TGDIStack.Restore;
  var
    i: Integer;
  begin
    i := Length(fSavePoints) - 1;

    ASSERT(i > -1, 'No SavePoint to Restore on this canvas');

    if fSavePoints[i] = NIL then
    begin
      while Count > 0 do
        InternalPop.Free;
    end
    else
    begin
      while InternalPeek <> fSavePoints[i] do
        InternalPop.Free;
    end;

    SetLength(fSavePoints, i);
  end;


  procedure TGDIStack.SavePoint;
  var
    i: Integer;
  begin
    i := Length(fSavePoints);
    SetLength(fSavePoints, i + 1);

    if Count > 0 then
      fSavePoints[i] := InternalPeek
    else
      fSavePoints[i] := NIL;
  end;


  function TGDIObjectStack.Peek: THandle;
  begin
    result := InternalPeek.Item;
  end;


  function TGDIObjectStack.Pop: THandle;
  var
    o: TGDIObject;
  begin
    InternalPop(o);
    try
      if o.Delete then
        result := 0
      else
        result := o.Item;

    finally
      o.Free;
    end;
  end;







{ TFontStack }

  procedure TFontStack.Push(const aFont: TLogFont);
  begin
    InternalPush(CreateFontIndirect(aFont), TRUE);
  end;


  procedure TFontStack.Push(const aFont: HFONT);
  begin
    InternalPush(aFont);
  end;





{ TPenStack }

  procedure TPenStack.Change(const aPen: HPEN);
  var
    p: TGDIObject;
    curr: HPEN;
  begin
    ASSERT(Count > 0, 'Cannot change pen - no items in stack');

    if InternalPeek(p) then
    begin
      curr := p.Item;

      p.Item := aPen;
      SelectObject(fDC^, p.Item);

      if p.Delete then
        DeleteObject(curr);
    end;
  end;


  procedure TPenStack.Push(const aPen: HPEN);
  begin
    InternalPush(aPen);
  end;


  procedure TPenStack.Push(const aColor: TColor);
  begin
    InternalPush(CreatePen(PS_SOLID, 0, ColorToRGB(aColor)), TRUE);
  end;



{ TBrushStack }

  procedure TBrushStack.Push(const aColor: TColor);
  begin
    InternalPush(CreateSolidBrush(ColorToRGB(aColor)), TRUE);
  end;


  function TBrushStack.get_Handle: HBRUSH;
  begin
    result := Peek;
  end;


  procedure TBrushStack.Push(const aBrush: HBRUSH);
  begin
    InternalPush(aBrush);
  end;


  procedure TBrushStack.Push(const aRed, aGreen, aBlue: Byte);
  begin
    InternalPush(CreateSolidBrush(RGB(aRed, aGreen, aBlue)), TRUE);
  end;








{ TColorStack }

  constructor TColorStack.Create(const aDC: PDC);
  begin
    inherited Create(aDC, TGDIColor);
  end;


  procedure TColorStack.DoPop(const aItem);
  var
    c: TGDIColor absolute aItem;
  begin
    SetTextColor(fDC^, c.oColor);
  end;


  procedure TColorStack.Change(const aColor: TColor);
  var
    c: TGDIColor;
  begin
    ASSERT(Count > 0, 'Cannot change color - no items in stack');

    if InternalPeek(c) then
    begin
      c.Color := aColor;
      SetTextColor(fDC^, aColor);
    end;
  end;


  function TColorStack.Pop: TColor;
  var
    c: TGDIColor;
  begin
    InternalPop(c);

    result := c.Color;

    c.Free;
  end;


  procedure TColorStack.Push(const aColor: TColor);
  var
    c: TGDIColor;
  begin
    c := TGDIColor(InternalPush);

    c.Color   := aColor;
    c.oColor  := SetTextColor(fDC^, ColorToRGB(aColor));
  end;




{ TModeStack }

  constructor TModeStack.Create(const aDC: PDC);
  begin
    inherited Create(aDC, TGDIMode);
  end;


  procedure TModeStack.DoPop(const aItem);
  var
    m: TGDIMode absolute aItem;
  begin
    SetBkMode(fDC^, m.oMode);
  end;


  function TModeStack.Pop: Integer;
  var
    m: TGDIMode;
  begin
    InternalPop(m);

    result := m.Mode;

    m.Free;
  end;


  procedure TModeStack.Push(const aMode: Integer);
  var
    m: TGDIMode;
  begin
    m := TGDIMode(InternalPush);

    m.Mode  := aMode;
    m.oMode := SetBkMode(fDC^, aMode);
  end;




{ TClipRGNStack }

  function TClipRgnStack.DoSelect(const aItem: THandle): THandle;
  begin
    result := SelectClipRGN(fDC^, aItem);
  end;



  procedure TClipRgnStack.Push(const aRGN: HRGN);
  begin
    InternalPush(aRGN);
  end;



  procedure TClipRgnStack.Push(const aRect: TRect);
  var
    o: TGDIObject;
    oRGN: HRGN;
    r: TGDIObject;
  begin
    if InternalPeek(o) then
      oRGN := o.Item
    else
      oRGN := 0;

    r := InternalPush(TGDIRegion.ForRect(aRect), TRUE);

    r.oItem := oRGN;
  end;


  procedure TClipRgnStack.Exclude(const aRGN: HRGN);
  var
    r: TGDIObject;
    rgn: HRGN;
  begin
    r   := InternalPeek;
    rgn := HRGN(r.Item);

    CombineRgn(rgn, aRGN, rgn, RGN_DIFF);
    SelectClipRGN(fDC^, rgn);
  end;


  function TClipRgnStack.get_Handle: HRGN;
  begin
    result := InternalPeek.Item;
  end;


  procedure TClipRgnStack.Exclude(const aRect: TRect);
  var
    rgn: HRGN;
  begin
    rgn := TGDIRegion.ForRect(aRect);
    Exclude(rgn);
    DeleteObject(rgn);
  end;


  function TClipRgnStack.Peek: HRGN;
  begin
    result := HRGN(InternalPeek.Item);
  end;


  procedure TClipRgnStack.Push(const aLeft, aTop, aRight, aBottom: Integer);
  begin
    InternalPush(TGDIRegion.ForRect(aLeft, aTop, aRight, aBottom), TRUE);
  end;




end.
