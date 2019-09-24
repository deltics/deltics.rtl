

  unit Deltics.CSV.StreamReader;


interface

  uses
    SysUtils,
    Deltics.Classes,
    Deltics.DateUtils,
    Deltics.Strings,
    Deltics.Unicode;


  type
    TCSVStreamReader = class;
    TValue = class;

    TCSVStreamReader = class
    private
      fBuffer: PWIDEChar;
      fBufferSize: Integer;
      fReader: IUnicodeReader;
      fLineNo: Integer;
      fRecNo: Integer;
      fValues: TList;
      function get_EOF: Boolean;
      function get_ValueCount: Integer;
      procedure ReadRecord;
    protected
      function GetValue(aIndex: Integer): TValue;
    public
      constructor Create(aStream: TStream);
      destructor Destroy; override;
      procedure Next;
      property EOF: Boolean read get_EOF;
      property LineNo: Integer read fLineNo;
      property RecNo: Integer read fRecNo;
      property ValueCount: Integer read get_ValueCount;
      property Values[aIndex: Integer]: TValue read GetValue; default;
    end;


    TValue = class
    private
      fData: PWIDEChar;
      fDataLen: Integer;
      function get_AsANSI: ANSIString;
      function get_AsANSIChar: ANSIChar;
      function get_AsBoolean: Boolean;
      function get_AsInteger: Integer;
      function get_AsString: String;
      function get_AsUnicode: UnicodeString;
      function get_HasValue: Boolean;
      function get_IsNull: Boolean;
    public
      constructor Create(aData: PWIDEChar; aLen: Integer);
      function AsDate: TDate; overload;
      function AsDate(const aFormat: String): TDate; overload;
      function IsANSIChar: Boolean; overload;
      function IsANSIChar(var aValue: ANSIChar): Boolean; overload;
      function IsDate: Boolean; overload;
      function IsDate(const aFormat: String): Boolean; overload;
      function IsInteger: Boolean; overload;
      function IsInteger(var aValue: Integer): Boolean; overload;

      property AsANSIChar: ANSIChar read get_AsANSIChar;
      property AsANSI: ANSIString read get_AsANSI;
      property AsBoolean: Boolean read get_AsBoolean;
      property AsInteger: Integer read get_AsInteger;
      property AsString: String read get_AsString;
      property AsUnicode: UnicodeString read get_AsUnicode;
      property HasValue: Boolean read get_HasValue;
      property IsNull: Boolean read get_IsNull;
    end;





implementation

  uses
    Deltics.Strings.Parsers.WIDE;



{ TCSVStreamReader }

  constructor TCSVStreamReader.Create(aStream: TStream);
  begin
    inherited Create;

    fReader := TUnicodeReader.OfStream(aStream, TEncoding.UTF8);

    if fReader.EOF then
      EXIT;

    fBufferSize := 16384;

    GetMem(fBuffer, fBufferSize);

    fValues := TList.Create;
    fValues.Capacity  := 32;

    ReadRecord;
  end;


  destructor TCSVStreamReader.Destroy;
  begin
    fValues.Free;

    FreeMem(fBuffer);

    inherited;
  end;


  function TCSVStreamReader.get_EOF: Boolean;
  begin
    result := fReader.EOF;
  end;


  function TCSVStreamReader.GetValue(aIndex: Integer): TValue;
  begin
    result := TValue(fValues[aIndex]);
  end;


  function TCSVStreamReader.get_ValueCount: Integer;
  begin
    result := fValues.Count;
  end;


  procedure TCSVStreamReader.Next;
  begin
    ReadRecord;
  end;


  procedure TCSVStreamReader.ReadRecord;

  var
    pc, vc: PWIDEChar;
    nextc: WIDEChar;
    inString: Boolean;
  begin
    fValues.Clear;

    pc := fBuffer;
    vc := fBuffer;

    inString := FALSE;
    try
      while NOT fReader.EOF do
      begin
        pc^ := fReader.ReadChar;

        if inString then
        begin
          if pc^ = '"' then
          begin
            if NOT fReader.Peek(nextc) then
            begin
              fValues.Add(TValue.Create(vc, pc - vc));
              EXIT;
            end
            else if nextc = '"' then
            begin
              fReader.ReadChar; // Consume the next "
              Inc(pc);
            end
            else
              inString := FALSE;
          end
          else
            Inc(pc);

          CONTINUE;
        end
        else case pc^ of
          #10,
          #13 : begin
                  // If we haven't yet read a record value then we simply ignore
                  //  the CR/LF

                  if pc^ = #10 then
                    Inc(fLineNo);

                  if pc = fBuffer then
                    CONTINUE;

                  // Otherwise if we aren't in a string then we have reached the
                  //  end of the record.

                  if NOT inString then
                  begin
                    // Add the final value indices, skip over
                    //  any additional CR/LF's and we're done.

                    fValues.Add(TValue.Create(vc, pc - vc));

                    while fReader.Peek(nextc) and (ANSIChar(Ord(nextc)) in [#13, #10]) do
                    begin
                      if nextc = #10 then
                        Inc(fLineNo);

                      fReader.ReadChar;
                    end;

                    EXIT;
                  end;
                end;

          '"' : if (pc = vc) then
                begin
                  inString  := TRUE;
                  CONTINUE;
                end;

          ',' : begin
                  fValues.Add(TValue.Create(vc, pc - vc));
                  vc := pc;
                  CONTINUE;
                end;
        end;

        Inc(pc);
      end;

    finally
      if fValues.Count > 0 then
        Inc(fRecNo);
    end;
  end;












{ TValue }

  constructor TValue.Create(aData: PWIDEChar;
                            aLen: Integer);
  begin
    inherited Create;

    fData     := aData;
    fDataLen  := aLen;
  end;


  function TValue.get_AsANSI: ANSIString;
  begin
    result := ANSI(AsUnicode);
  end;


  function TValue.get_AsANSIChar: ANSIChar;
  begin
    if (fDataLen = 1) then
      result := ANSI(fData[0])
    else
      result := #0;
  end;


  function TValue.get_AsBoolean: Boolean;
  begin
    result := WIDE.Parse.AsBoolean(fData, fDataLen);
  end;


  function TValue.get_AsInteger: Integer;
  begin
    result := WIDE.Parse.AsInteger(fData, fDataLen);
  end;


  function TValue.get_AsString: String;
  begin
  {$ifdef UNICODE}
    result := AsUnicode;
  {$else}
    result := ANSI(AsUnicode);
  {$endif}
  end;


  function TValue.get_AsUnicode: UnicodeString;
  begin
    result := WIDE(fData, fDataLen);
  end;


  function TValue.get_HasValue: Boolean;
  begin
    result := fDataLen > 0;
  end;


  function TValue.get_IsNull: Boolean;
  begin
    result := fDataLen = 0;
  end;



  function TValue.AsDate: TDate;
  begin
    // TODO: Use system settings

    result := AsDate('dd/mm/yyyy');
  end;


  function TValue.AsDate(const aFormat: String): TDate;
  begin
    result := StrToDate(AsString, aFormat);
  end;


  function TValue.IsInteger: Boolean;
  begin
    result := WIDE.Parse.IsInteger(fData, fDataLen);
  end;


  function TValue.IsANSIChar: Boolean;
  begin
    result := fDataLen = 1;
  end;


  function TValue.IsANSIChar(var aValue: ANSIChar): Boolean;
  begin
    result := fDataLen = 1;
    if result then
      aValue := ANSI(fData[0]);
  end;


  function TValue.IsDate: Boolean;
  begin
    // TODO: Use system settings

    result := IsDate('dd/mm/yyyy');
  end;

  function TValue.IsDate(const aFormat: String): Boolean;
  begin
    result := HasValue and StrIsDate(AsString, aFormat);
  end;


  function TValue.IsInteger(var aValue: Integer): Boolean;
  begin
    result := WIDE.Parse.IsInteger(fData, fDataLen, aValue);
  end;




end.
