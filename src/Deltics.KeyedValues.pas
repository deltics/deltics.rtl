

  unit Deltics.KeyedValues;


interface

  uses
    Classes;

  type
    TKeyValueList = class
    protected
      function get_Count: Integer; virtual; abstract;
      function get_KeyAsString(const aIndex: Integer): String; virtual; abstract;
      function get_ValueAsString(const aIndex: Integer): String; virtual; abstract;
    public
      property Count: Integer read get_Count;
      property KeyAsString[const aIndex: Integer]: String read get_KeyAsString;
      property ValueAsString[const aIndex: Integer]: String read get_KeyAsString;
    end;


    TStringsWithIntegerKey = class(TKeyValueList)
    protected
      function get_Count: Integer; override;
      function get_KeyAsString(const aIndex: Integer): String; override;
      function get_ValueAsString(const aIndex: Integer): String; override;
    private
      fItems: TStringList;
      function get_Key(const aIndex: Integer): Integer;
      function get_Value(const aKey: Integer): String;
      function get_ValueByIndex(const aIndex: Integer): String;
      function Find(const aKey: Integer; var aIndex: Integer): Boolean; overload;
    public
      constructor Create;
      destructor Destroy; override;
      procedure Add(const aKey: Integer; const aValue: String);
      function Find(const aKey: Integer; var aValue: String): Boolean; overload;
      property Count: Integer read get_Count;
      property Key[const aIndex: Integer]: Integer read get_Key;
      property KeyAsString[const aIndex: Integer]: String read get_KeyAsString;
      property Values[const aKey: Integer]: String read get_Value;
      property ValueByIndex[const aIndex: Integer]: String read get_ValueByIndex;
    end;




implementation

  uses
    SysUtils;

{ TIntegerStringDictionary }

  constructor TStringsWithIntegerKey.Create;
  begin
    inherited Create;

    fItems := TStringList.Create;
  end;


  destructor TStringsWithIntegerKey.Destroy;
  begin
    fItems.Free;

    inherited;
  end;


  function TStringsWithIntegerKey.get_Count: Integer;
  begin
    result := fItems.Count;
  end;


  function TStringsWithIntegerKey.get_Key(const aIndex: Integer): Integer;
  begin
    result := Integer(fItems.Objects[aIndex]);
  end;


  function TStringsWithIntegerKey.get_KeyAsString(const aIndex: Integer): String;
  begin
    result := IntToStr(Key[aIndex]);
  end;


  function TStringsWithIntegerKey.get_ValueAsString(const aIndex: Integer): String;
  begin
    result := fItems[aIndex];
  end;


  function TStringsWithIntegerKey.get_ValueByIndex(const aIndex: Integer): String;
  begin
    result := fItems[aIndex];
  end;


  function TStringsWithIntegerKey.get_Value(const aKey: Integer): String;
  var
    idx: Integer;
  begin
    if Find(aKey, idx) then
      result := fItems[idx]
    else
      result := '';
  end;


  procedure TStringsWithIntegerKey.Add(const aKey: Integer;
                                       const aValue: String);
  var
    idx: Integer;
  begin
    if Find(aKey, idx) then
      raise Exception.CreateFmt('Key %d already exists in dictionary', [aKey]);

    fItems.InsertObject(idx, aValue, TObject(aKey));
  end;


  function TStringsWithIntegerKey.Find(const aKey: Integer;
                                          var   aValue: String): Boolean;
  var
    idx: Integer;
  begin
    result := Find(aKey, idx);

    if result then
      aValue := ValueByIndex[idx]
    else
      aValue := '';
  end;


  function TStringsWithIntegerKey.Find(const aKey: Integer;
                                         var   aIndex: Integer): Boolean;
  var
    L, H, I, C: Integer;
  begin
    result := FALSE;

    L := 0;
    H := Count - 1;

    while L <= H do
    begin
      I := (L + H) shr 1;
      C := Integer(fItems.Objects[I]) - aKey;

      if C >= 0 then
      begin
        H := I - 1;
        if C = 0 then
        begin
          result := TRUE;
          L      := I;
          BREAK;
        end;
      end
      else
        L := I + 1;
    end;

    aIndex := L;
  end;



end.
