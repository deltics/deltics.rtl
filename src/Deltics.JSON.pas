{
  * X11 (MIT) LICENSE *

  Copyright � 2011 Jolyon Smith

  Permission is hereby granted, free of charge, to any person obtaining a copy of
   this software and associated documentation files (the "Software"), to deal in
   the Software without restriction, including without limitation the rights to
   use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
   of the Software, and to permit persons to whom the Software is furnished to do
   so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all
   copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
   SOFTWARE.


  * GPL and Other Licenses *

  The FSF deem this license to be compatible with version 3 of the GPL.
   Compatability with other licenses should be verified by reference to those
   other license terms.


  * Contact Details *

  Original author : Jolyon Smith
  skype           : deltics
  e-mail          : <EXTLINK mailto: jsmith@deltics.co.nz>jsmith@deltics.co.nz</EXTLINK>
  website         : <EXTLINK http://www.deltics.co.nz>www.deltics.co.nz</EXTLINK>
}

{$i deltics.rtl.inc}

{$ifdef ddx_json} {$debuginfo ON} {$endif}


  unit Deltics.JSON;


interface

  uses
  { vcl: }
    Classes,
    Contnrs,
    SysUtils,
    TypInfo,
  { deltics: }
    Deltics.DateUtils,
    Deltics.Strings,
    Deltics.Unicode;


  type
    JSON = class;

    TJSONDateTimeParts = (dpYear, dpMonth, dpDay, dpTime, dpOffset);
    TJSONDatePart = dpYear..dpDay;

    TJSONValue = class;
      TJSONBoolean = class;
      TJSONNull = class;
      TJSONNumber = class;
      TJSONInteger = class;
      TJSONString = class;
      TJSONStructure = class;
        TJSONArray  = class;
        TJSONObject  = class;

//      TJSONComment = class;


    TJSONValueClass = class of TJSONValue;


    EJSONError = class(Exception);
    EJSONStreamError = class(EJSONError);

    TJSONObjectComparer = function(const A, B: TJSONObject): Integer;

    TJSONValueType = (jsString, jsNumber, jsBoolean, jsArray, jsObject, jsNull);


    JSON = class
      class function DecodeDate(const aString: UnicodeString): TDateTime;
      class function EncodeDate(const aDate: TDate; const aAccuracy: TJSONDatePart = dpDay): UnicodeString; overload;
      class function EncodeDate(const aYear: Word): UnicodeString; overload;
      class function EncodeDate(const aYear, aMonth: Word): UnicodeString; overload;
      class function EncodeDate(const aYear, aMonth, aDay: Word): UnicodeString; overload;
      class function EncodeDateTime(const aDateTime: TDateTime): UnicodeString; overload;
      class function EncodeDateTime(const aDateTime: TDateTime; const aDateAccuracy: TJSONDatePart): UnicodeString; overload;
      class function EncodeDateTime(const aDateTime: TDateTime; const aOffset: SmallInt): UnicodeString; overload;
      class function EncodeDateTime(const aDateTime: TDateTime; const aDateAccuracy: TJSONDatePart; const aOffset: SmallInt): UnicodeString; overload;
      class function EncodeString(const aString: String): String;

      class function ReadFromFile(const aFilename: String): TJSONValue;
      class function ReadValue(aStream: TStream): TJSONValue; overload;
      class function ReadValue(const aString: String): TJSONValue; overload;
    end;


    TJSONValue = class
    private
      fIsNull: Boolean;
      fName: UnicodeString;
      fValueType: TJSONValueType;
      function get_AsArray: TJSONArray;
      function get_AsBoolean: Boolean;
      function get_AsDateTime: TDateTime;
      function get_AsDouble: Double;
      function get_AsEnum(const aTypeInfo: PTypeInfo): Integer;
      function get_AsGUID: TGUID;
      function get_AsInt64: Int64;
      function get_AsInteger: Integer;
      function get_AsObject: TJSONObject;
      function get_AsString: UnicodeString;
      procedure set_AsBoolean(const aValue: Boolean);
      procedure set_AsDateTime(const aValue: TDateTime);
      procedure set_AsDouble(const aValue: Double);
      procedure set_AsGUID(const aValue: TGUID);
      procedure set_AsInt64(const aValue: Int64);
      procedure set_AsInteger(const aValue: Integer);
      procedure set_AsString(const aValue: UnicodeString);
      function get_IsNull: Boolean; virtual;
      procedure set_IsNull(const aValue: Boolean); virtual;
      function DoGetAsString: UnicodeString; virtual; abstract;
      procedure DoSetAsString(const aValue: UnicodeString); virtual;
      procedure Wipe; virtual;
    protected
      function get_AsJSON: UnicodeString; virtual;
    public
      constructor Create; virtual;
      procedure Clear; virtual;
      function Clone: TJSONValue; virtual;
      procedure CopyFrom(const aSource: TJSONValue); virtual;
      function IsEqual(const aOther: TJSONValue): Boolean;
      property AsArray: TJSONArray read get_AsArray;
      property AsBoolean: Boolean read get_AsBoolean write set_AsBoolean;
      property AsDateTime: TDateTime read get_AsDateTime write set_AsDateTime;
      property AsDouble: Double read get_AsDouble write set_AsDouble;
      property AsEnum[const aTypeInfo: PTypeInfo]: Integer read get_AsEnum;
      property AsGUID: TGUID read get_AsGUID write set_AsGUID;
      property AsInt64: Int64 read get_AsInt64 write set_AsInt64;
      property AsInteger: Integer read get_AsInteger write set_AsInteger;
      property AsJSON: UnicodeString read get_AsJSON;
      property AsObject: TJSONObject read get_AsObject;
      property AsString: UnicodeString read get_AsString write set_AsString;
      property IsNull: Boolean read get_IsNull write set_IsNull;
      property Name: UnicodeString read fName write fName;
      property ValueType: TJSONValueType read fValueType;

    {$ifdef DELPHI2009__}
    private
      function get_AsDate: TDate;
      function get_AsTime: TTime;
      procedure set_AsDate(const aValue: TDate);
      procedure set_AsTime(const aValue: TTime);
    public
      property AsDate: TDate read get_AsDate write set_AsDate;
      property AsTime: TTime read get_AsTime write set_AsTime;
    {$endif}
    end;


      TJSONBoolean = class(TJSONValue)
      private
        fValue: Boolean;
        procedure set_Value(const aValue: Boolean);
      protected
        function DoGetAsString: UnicodeString; override;
        procedure DoSetAsString(const aValue: UnicodeString); override;
      public
        procedure CopyFrom(const aSource: TJSONValue); override;
        property Value: Boolean read fValue write set_Value;
      end;

      TJSONNull = class(TJSONValue)
      protected
        function get_IsNull: Boolean; override;
        function DoGetAsString: UnicodeString; override;
      end;

      TJSONNumber = class(TJSONValue);

        TJSONDouble = class(TJSONNumber)
        private
          fValue: Double;
          procedure set_Value(const aValue: Double);
        protected
          function DoGetAsString: UnicodeString; override;
          procedure DoSetAsString(const aValue: UnicodeString); override;
        public
          procedure CopyFrom(const aSource: TJSONValue); override;
          property Value: Double read fValue write set_Value;
        end;

        TJSONInteger = class(TJSONNumber)
        private
          fValue: Int64;
          procedure set_Value(const aValue: Int64);
        protected
          function DoGetAsString: UnicodeString; override;
          procedure DoSetAsString(const aValue: UnicodeString); override;
        public
          procedure CopyFrom(const aSource: TJSONValue); override;
          property Value: Int64 read fValue write set_Value;
        end;


      TJSONString = class(TJSONValue)
      private
        fValue: UnicodeString;
        procedure set_Value(const aValue: UnicodeString);
      protected
        function get_AsJSON: UnicodeString; override;
        function DoGetAsString: UnicodeString; override;
        procedure DoSetAsString(const aValue: UnicodeString); override;
      public
        class function Decode(const aValue: UnicodeString): UnicodeString;
        class function Encode(const aValue: UnicodeString): UnicodeString;
        procedure CopyFrom(const aSource: TJSONValue); override;
        property Value: UnicodeString read fValue write set_Value;
      end;


      TJSONStructure = class(TJSONValue)
      private
        function get_AsDisplayText: UnicodeString;
      protected
        function get_IsEmpty: Boolean; virtual; abstract;
        function get_IsNull: Boolean; override;
        procedure Add(const aValue: TJSONValue); overload; virtual; abstract;
      public
        class function CreateFromFile(const aFilename: UnicodeString; const aBufferKB: Word = 4): TJSONStructure;
        class function CreateFromStream(const aStream: TStream; const aBufferKB: Word = 4): TJSONStructure; overload;
        class function CreateFromStream(const aStream: TStream; const aDefaultEncoding: TEncoding; const aBufferKB: Word = 4): TJSONStructure; overload;
        class function CreateFromANSI(const aString: ANSIString): TJSONStructure;
        class function CreateFromUTF8(const aString: UTF8String): TJSONStructure;
        class function CreateFromWIDE(const aString: UnicodeString): TJSONStructure;
        class function CreateFromString(const aString: String): TJSONStructure;
        function Add(const aName: UnicodeString; const aValue: TJSONStructure): TJSONStructure; overload;
        function Add(const aName: UnicodeString; const aValue: Boolean): TJSONBoolean; overload;
        function Add(const aName: UnicodeString; const aValue: Integer): TJSONInteger; overload;
        function Add(const aName: UnicodeString; const aValue: Int64): TJSONNumber; overload;
        function Add(const aName: UnicodeString; const aValue: UnicodeString): TJSONString; overload;
        function Add(const aName: UnicodeString; const aValue: TGUID): TJSONString; overload;
        function Add(const aName: UnicodeString; const aValue: Double): TJSONNumber; overload;
        function Add(const aName: UnicodeString; const aValue: Integer; const aTypeInfo: PTypeInfo): TJSONString; overload;
      {$ifdef DELPHI2009__}
        function Add(const aName: UnicodeString; const aValue: TDateTime): TJSONString; overload;
        function Add(const aName: UnicodeString; const aValue: TDate): TJSONString; overload;
        function Add(const aName: UnicodeString; const aValue: TTime): TJSONString; overload;
      {$endif}
        function AddArray(const aName: UnicodeString = ''): TJSONArray;
        function AddDate(const aName: UnicodeString; const aValue: TDate): TJSONString;
        function AddTime(const aName: UnicodeString; const aValue: TTime): TJSONString;
        function AddDateTime(const aName: UnicodeString; const aValue: TDateTime): TJSONString;
        function AddDouble(const aName: UnicodeString; const aValue: Double): TJSONNumber;
        procedure AddNull(const aName: UnicodeString);
        function AddObject(const aName: UnicodeString = ''): TJSONObject;
        procedure Load(const aSource: IUnicodeReader);
        procedure LoadFromFile(const aFileName: UnicodeString; const aEncoding: TEncoding; const aBufferKB: Word);
        procedure LoadFromStream(const aStream: TStream; const aEncoding: TEncoding; const aBufferKB: Word);
        procedure SaveToFile(const aFileName: UnicodeString; const aCompact: Boolean = FALSE);
        procedure SaveToStream(const aStream: TStream; const aCompact: Boolean = FALSE);
        procedure Wipe; override; abstract;
        property AsDisplayText: UnicodeString read get_AsDisplayText;
        property IsEmpty: Boolean read get_IsEmpty;
      end;


        TJSONArray = class(TJSONStructure)
        private
          fItems: TObjectList;
          function get_Item(const aIndex: Integer): TJSONValue;
          function get_Count: Integer;
        protected
          function get_IsEmpty: Boolean; override;
          function DoGetAsString: UnicodeString; override;
          procedure DoSetAsString(const aValue: UnicodeString); override;
        public
          constructor Create; overload; override;
          destructor Destroy; override;
          function Add(const aValue: Boolean): TJSONBoolean; reintroduce; overload;
          function Add(const aValue: Integer): TJSONInteger; reintroduce; overload;
          function Add(const aValue: UnicodeString): TJSONString; reintroduce; overload;
          function Add(const aValue: TDateTime): TJSONString; reintroduce; overload;
          function Add(const aValue: TGUID): TJSONString; reintroduce; overload;
          function Add(const aValue: TJSONStructure): TJSONStructure; reintroduce; overload;
          function Add(const aValue: Integer; const aTypeInfo: PTypeInfo): TJSONString; reintroduce; overload;
          procedure Add(const aValue: TJSONValue); override;
          function AddArray: TJSONArray; reintroduce;
          procedure AddNull; reintroduce;
          function AddObject(const aTemplate: TJSONObject = NIL): TJSONObject; reintroduce;
          function AsStringArray: TStringArray;
          procedure Clear; override;
          function Clone: TJSONArray; reintroduce;
          procedure Combine(const aSource: TJSONArray);
          procedure CopyFrom(const aSource: TJSONValue); override;
          procedure Delete(const aIndex: Integer); overload;
          procedure Delete(const aValue: TJSONValue); overload;
          function FindObject(const aValueName: UnicodeString; const aValue: TGUID; var aObject: TJSONObject): Boolean;
          procedure GetStrings(const aList: TStringList);
          procedure Sort(const aComparer: TJSONObjectComparer);
          procedure Wipe; override;
          property Count: Integer read get_Count;
          property Items[const aIndex: Integer]: TJSONValue read get_Item; default;
        end;


        TJSONObject = class(TJSONStructure)
        private
          fValues: TObjectList;
          function get_Value(const aName: UnicodeString): TJSONValue;
          function get_ValueCount: Integer;
          function get_ValueByIndex(const aIndex: Integer): TJSONValue;
        protected
          function get_IsEmpty: Boolean; override;
          procedure Add(const aValue: TJSONValue); override;
          function DoGetAsString: UnicodeString; override;
          procedure DoSetAsString(const aValue: UnicodeString); override;
        public
          class function TryCreate(const aString: UnicodeString): TJSONObject;
          constructor Create; overload; override;
          constructor Create(const aString: UnicodeString); reintroduce; overload;
          constructor CreateFromFile(const aFilename: UnicodeString; const aEncoding: TEncoding; const aBufferKB: Word = 4);
          destructor Destroy; override;
          function AddAfter(const aPredecessor: UnicodeString; const aName: UnicodeString; const aValue: UnicodeString): TJSONString; overload;
          procedure Clear; override;
          function Clone: TJSONObject; reintroduce;
          procedure Combine(const aObject: TJSONObject);
          function Contains(const aValueName: UnicodeString): Boolean; overload;
          function Contains(const aValueName: UnicodeString; var aValue: UnicodeString): Boolean; overload;
          function Contains(const aValueName: UnicodeString; var aValue: TJSONArray): Boolean; overload;
          function Contains(const aValueName: UnicodeString; var aValue: TWIDEStringArray): Boolean; overload;
          procedure Delete(const aValueName: UnicodeString); overload;
          function FindValue(const aName: UnicodeString): TJSONValue;
          procedure CopyFrom(const aSource: TJSONValue); override;
          procedure LoadFromStream(const aStream: TStream; const aEncoding: TEncoding; const aBufferKB: Word);
          function OptBoolean(const aName: UnicodeString; const aDefault: Boolean = FALSE): Boolean;
          function OptDateTime(const aName: UnicodeString; const aDefault: TDateTime = 0): TDateTime;
          function OptEnum(const aName: UnicodeString; const aTypeInfo: PTypeInfo; const aDefault: Integer = 0): Integer;
          function OptInteger(const aName: UnicodeString; const aDefault: Integer = 0): Integer;
          function OptString(const aName: UnicodeString; const aDefault: UnicodeString = ''): UnicodeString;
          procedure Wipe; override;
        {$ifdef DELPHI2009__}
          function OptDate(const aName: UnicodeString; const aDefault: TDate = 0): TDate;
          function OptTime(const aName: UnicodeString; const aDefault: TTime = 0): TTime;
        {$endif}
          property ValueCount: Integer read get_ValueCount;
          property Values[const aName: UnicodeString]: TJSONValue read get_Value; default;
          property ValueByIndex[const aIndex: Integer]: TJSONValue read get_ValueByIndex;
        end;


    TJSONReader = class
    private
      fNextChar: WideChar;
      fNextCharReady: Boolean;
      fSource: IUnicodeReader;
      fLine: Integer;
      fPos: Integer;
      function EOF: Boolean;
      function NextChar: WideChar;
      function NextRealChar: WideChar;
      function ReadChar: WideChar;
      function ReadRealChar: WideChar; overload;
      function ReadName: UnicodeString;
      function ReadString(const aQuoted: Boolean = TRUE): UnicodeString;
    public
      constructor Create(const aSource: IUnicodeReader);
      function ReadArray: TJSONArray;
      function ReadObject: TJSONObject;
      function ReadValue: TJSONValue;
      property Line: Integer read fLine;
      property Pos: Integer read fPos;
    end;


implementation

  uses
    Types,
    Windows;
  { deltics: }
//    Deltics.StrUtils;


  const
    NULLDATE  : TDateTime = 0;
    NULLGUID  : TGUID = '{00000000-0000-0000-0000-000000000000}';



  function SameGUID(const GUIDA, GUIDB: TGUID): Boolean;
  begin
    result := CompareMem(@GUIDA, @GUIDB, sizeof(TGUID));
  end;



  class function JSON.DecodeDate(const aString: UnicodeString): TDateTime;

    function Pop(var S: String;
                 const aLen: Integer;
                 const aValidNextChars: TANSICharSet;
                 var   aNextChar: Char): Word;
    var
      ok: Boolean;
      nextChar: ANSIChar;
    begin
      ok        := TRUE;
      nextChar  := ANSIChar(#0);

      // Determine the ANSIChar that follows immediately after the value of the
      //  specified length that we are about to extract from the string.
      //
      // If the string is exactly the length of the value we are about to extract
      //  then the next char is #0 (NULL).  i.e. the end of the string.
      //
      // If the string is longer than the value we are about to extract then the
      //  next char is simply the char occuring immediately following the extracted
      //  value.
      //
      // If the string is shorter than the required value or if the determined
      //  next character is not one of the expected, valid next characters then
      //  the string is not a valid JSON encoded date.

      if (Length(S) > aLen) then
        nextChar := ANSIChar(S[aLen + 1])
      else if (Length(S) < aLen) then
        ok := FALSE;

      ok := ok and (nextChar in aValidNextChars);

      if NOT ok then
        raise EJSONError.Create('''' + aString + ''' is not a valid JSON date/time');

      result := StrToInt(Copy(S, 1, aLen));
      Delete(S, 1, aLen);

      if Length(S) > 0 then
      begin
        aNextChar := S[1];
        Delete(S, 1, 1);
      end
      else
        aNextChar := #0;
    end;

  var
    c: Char;
    s: String;
    year, month, day: Word;
    hour, min, sec, msec, zh, zm: Word;
    z: Integer;
  begin
    s := aString;

    // Year is required to be present so either we have a valid value and
    //  year will be set or the value is invalid and there will be an exception.
    //  Either way, we do not need to initialise year here.
    //
    // All other values are initialised with the required defaults should they
    //  not be present.

    month := 1;
    day   := 1;
    hour  := 0;
    min   := 0;
    sec   := 0;
    msec  := 0;
    z     := 0;
    zh    := 0;
    zm    := 0;

    year := Pop(s, 4, [#0, '-', 'T'], c);

    if c = '-' then
      month := Pop(s, 2, [#0, '-', 'T'], c);

    if c = '-' then
      day := Pop(s, 2, [#0, '-', 'T'], c);

    if c = 'T' then
    begin
      hour  := Pop(s, 2, [':'], c);
      min   := Pop(s, 2, [':'], c);
      sec   := Pop(s, 2, ['.'], c);
      msec  := Pop(s, 3, [#0, '+', '-', 'Z'], c);

      case c of
        '+' : z := 1;
        '-' : z := -1;
      end;

      if z <> 0 then
      begin
        zh := z * Pop(s, 2, [':'], c);
        zm := z * Pop(s, 2, [#0], c);
      end;
    end;

    result := SysUtils.EncodeDate(year, month, day);
    result := result + EncodeTime(hour - zh, min - zm, sec, msec);
  end;


  class function JSON.EncodeDate(const aDate: TDate;
                                 const aAccuracy: TJSONDatePart): UnicodeString;
  begin
    case aAccuracy of
      dpYear  : result := FormatDateTime('yyyy', aDate);
      dpMonth : result := FormatDateTime('yyyy-mm', aDate);
      dpDay   : result := FormatDateTime('yyyy-mm-dd', aDate);
    end;
  end;


  class function JSON.EncodeDate(const aYear: Word): UnicodeString;
  begin
    result := WIDE.PadLeft(aYear, 4, '0');
  end;


  class function JSON.EncodeDate(const aYear, aMonth: Word): UnicodeString;
  begin
    result := self.EncodeDate(aYear) + '-' + WIDE.PadLeft(aMonth, 2, '0');
  end;


  class function JSON.EncodeDate(const aYear, aMonth, aDay: Word): UnicodeString;
  begin
    result := self.EncodeDate(aYear, aMonth) + '-' + WIDE.PadLeft(aDay, 2, '0');
  end;


  class function JSON.EncodeDateTime(const aDateTime: TDateTime): UnicodeString;
  begin
    result := EncodeDateTime(aDateTime, dpDay);
  end;


  class function JSON.EncodeDateTime(const aDateTime: TDateTime;
                                     const aDateAccuracy: TJSONDatePart): UnicodeString;
  begin
    result := EncodeDate(aDateTime, aDateAccuracy) + 'T' + FormatDateTime('HH:nn:ss.zzz', aDateTime);
  end;


  class function JSON.EncodeDateTime(const aDateTime: TDateTime;
                                     const aOffset: SmallInt): UnicodeString;
  begin
    result := EncodeDateTime(aDateTime, dpDay, aOffset);
  end;


  class function JSON.EncodeDateTime(const aDateTime: TDateTime;
                                     const aDateAccuracy: TJSONDatePart;
                                     const aOffset: SmallInt): UnicodeString;
  const
    SIGN: array[FALSE..TRUE] of String = ('-', '+');
  var
    isPos: Boolean;
    zh, zm: SmallInt;
  begin
    if aOffset <> 0 then
    begin
      isPos := aOffset >= 0;
      zh    := Abs(aOffset) div 60;
      zm    := Abs(aOffset) mod 60;

      result := EncodeDateTime(aDateTime, aDateAccuracy) + SIGN[isPos] + WIDE.PadLeft(zh, 2, '0')
                                                                 + ':' + WIDE.PadLeft(zm, 2, '0');
    end
    else
      result := EncodeDate(aDateTime, aDateAccuracy) + 'Z';
  end;



  class function JSON.EncodeString(const aString: String): String;
  begin
    result := TJSONString.Encode(aString);
  end;


  class function JSON.ReadFromFile(const aFilename: String): TJSONValue;
  var
    src: TFileStream;
  begin
    result := NIL;

    src := TFileStream.Create(aFilename, fmOpenRead);
    try
      try
        result := ReadValue(src);

      except
        raise Exception.CreateFmt('Error reading JSON in file ''%s''', [aFilename]);
      end;

    finally
      src.Free;
    end;
  end;



  class function JSON.ReadValue(aStream: TStream): TJSONValue;
  var
    unicode: IUnicodeReader;
  begin
    unicode := TUnicodeReader.OfStream(aStream, TEncoding.UTF8);

    with TJSONReader.Create(unicode) do
    try
      result := ReadValue;
      try
        if NOT EOF and (NextRealChar <> #0) then
          raise EJSONStreamError.Create('Unexpected data');

      except
        result.Free;
        raise;
      end;

    finally
      Free;
    end;
  end;



  class function JSON.ReadValue(const aString: String): TJSONValue;
  var
    unicode: IUnicodeReader;
  begin
    unicode := TUnicodeReader.OfWIDE(aString);

    with TJSONReader.Create(unicode) do
    try
      result := ReadValue;
      try
        if NOT EOF and (NextRealChar <> #0) then
          raise EJSONStreamError.Create('Unexpected data');

      except
        result.Free;
        raise;
      end;

    finally
      Free;
    end;
  end;









{ TJSONValue ------------------------------------------------------------------------------------- }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TJSONValue.Create;
  begin
    inherited Create;

    if      (self is TJSONArray)   then  fValueType := jsArray
    else if (self is TJSONString)  then  fValueType := jsString
    else if (self is TJSONBoolean) then  fValueType := jsBoolean
    else if (self is TJSONNull)    then  fValueType := jsNull
    else if (self is TJSONNumber)  then  fValueType := jsNumber
    else if (self is TJSONObject)  then  fValueType := jsObject
    else
      raise EJSONError.Create('Unknown JSON value class');
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TJSONValue.DoSetAsString(const aValue: UnicodeString);
  begin
    fIsNull := FALSE;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TJSONValue.Clear;
  begin
    fIsNull  := TRUE;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONValue.Clone: TJSONValue;
  begin
    result := TJSONValueClass(ClassType).Create;
    result.CopyFrom(self);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TJSONValue.CopyFrom(const aSource: TJSONValue);
  begin
    fIsNull  := aSource.fIsNull;
    fName    := aSource.fName;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TJSONValue.Wipe;
  begin
    Clear;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONValue.get_AsArray: TJSONArray;
  begin
    result := self as TJSONArray;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONValue.get_AsBoolean: Boolean;
  begin
    if Assigned(self) and NOT IsNull then
    begin
      if NOT (self is TJSONBoolean) then
      begin
        ASSERT(ValueType = jsString);
        result := SameText(AsString, 'true');
      end
      else
        result := TJSONBoolean(self).Value;
    end
    else
      result := FALSE;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONValue.get_AsDateTime: TDateTime;
  begin
    if NOT IsNull then
    begin
      ASSERT(ValueType = jsString);
      result := JSON.DecodeDate(AsString)
    end
    else
      result := NULLDATE;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONValue.get_AsDouble: Double;
  begin
    if NOT IsNull then
    begin
      ASSERT(ValueType in [jsNumber, jsString]);
      result := StrToFloat(AsString);
    end
    else
      result := 0.0;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONValue.get_AsEnum(const aTypeInfo: PTypeInfo): Integer;
  begin
    if NOT IsNull then
    begin
      ASSERT(ValueType = jsString);
      result := GetEnumValue(aTypeInfo, AsString)
    end
    else
      result := 0;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONValue.get_AsGUID: TGUID;
  begin
    if NOT IsNull then
    begin
      ASSERT(ValueType = jsString);
      result := StringToGUID(AsString)
    end
    else
      result := NULLGUID;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONValue.get_AsInt64: Int64;
  begin
    if IsNull then
      raise EJSONError.CreateFmt('Cannot convert null value ''%s'' to integer', [Name]);

    case ValueType of
      jsBoolean : result := Ord(AsBoolean);
      jsNumber,
      jsString  : result := StrToInt64(DoGetAsString);
    else
      raise EJSONError.CreateFmt('Cannot convert value ''%s'' to integer', [Name]);
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONValue.get_AsInteger: Integer;
  begin
    if IsNull then
      raise EJSONError.CreateFmt('Cannot convert null value ''%s'' to integer', [Name]);

    case ValueType of
      jsBoolean : result := Ord(AsBoolean);
      jsNumber,
      jsString  : result := StrToInt(DoGetAsString);
    else
      raise EJSONError.CreateFmt('Cannot convert value ''%s'' to integer', [Name]);
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONValue.get_AsJSON: UnicodeString;
  begin
    result := DoGetAsString;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONValue.get_AsObject: TJSONObject;
  begin
    result := self as TJSONObject;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONValue.get_AsString: UnicodeString;
  begin
    if IsNull then
      raise EJSONError.CreateFmt('Cannot convert null value ''%s'' to UnicodeString', [Name])
    else
      result := DoGetAsString;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONValue.get_IsNull: Boolean;
  begin
    result := fIsNull;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONValue.IsEqual(const aOther: TJSONValue): Boolean;
  begin
    result := (ValueType = aOther.ValueType)
              and (Name = aOther.Name)
              and (AsString = aOther.AsString);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TJSONValue.set_AsBoolean(const aValue: Boolean);
  begin
    case aValue of
      TRUE  : AsString := 'true';
      FALSE : AsString := 'false';
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TJSONValue.set_AsDateTime(const aValue: TDateTime);
  begin
    AsString := DateTimeToISO8601(aValue);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TJSONValue.set_AsDouble(const aValue: Double);
  begin
    AsString := FloatToStr(aValue);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TJSONValue.set_AsGUID(const aValue: TGUID);
  begin
    ASSERT(ValueType = jsString);

    AsString := GUIDToString(aValue);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TJSONValue.set_AsInt64(const aValue: Int64);
  begin
    DoSetAsString(IntToStr(aValue));
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TJSONValue.set_AsInteger(const aValue: Integer);
  begin
    DoSetAsString(IntToStr(aValue));
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TJSONValue.set_AsString(const aValue: UnicodeString);
  begin
    DoSetAsString(aValue);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TJSONValue.set_IsNull(const aValue: Boolean);
  begin
    fIsNull := aValue;
  end;



{$ifdef DELPHI2009__}
  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONValue.get_AsDate: TDate;
  begin
    if NOT IsNull then
    begin
      ASSERT(ValueType = jsString);
      result := DateTimeFromISO8601(AsString, [dtDate])
    end
    else
      result := NULLDATE;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONValue.get_AsTime: TTime;
  begin
    if NOT IsNull then
    begin
      ASSERT(ValueType = jsString);
      result := DateTimeFromISO8601(AsString, [dtTime])
    end
    else
      result := NULLDATE;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TJSONValue.set_AsDate(const aValue: TDate);
  begin
    AsString := DateTimeToISO8601(aValue, [dtDate]);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TJSONValue.set_AsTime(const aValue: TTime);
  begin
    AsString := DateTimeToISO8601(aValue, [dtTime]);
  end;
{$endif}











{ TJSONText -------------------------------------------------------------------------------------- }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function TJSONStructure.CreateFromFile(const aFilename: UnicodeString;
                                          const aBufferKB: Word): TJSONStructure;
  var
    stream: TFileStream;
  begin
    stream := TFileStream.Create(aFilename, fmOpenRead or fmShareDenyWrite);
    try
      result := CreateFromStream(stream, aBufferKB);

    finally
      stream.Free;
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function TJSONStructure.CreateFromStream(const aStream: TStream;
                                            const aBufferKB: Word): TJSONStructure;
  var
    source: IUnicodeReader;
    reader: TJSONReader;
  begin
    // TODO: Default Encoding ? (move aEncoding to last param and make optional ?)

    source := TUnicodeReader.OfStream(aStream, TEncoding.UTF8, aBufferKB);
    reader := TJSONReader.Create(source);
    try
      result := reader.ReadValue as TJSONStructure;

    finally
      reader.Free;
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function TJSONStructure.CreateFromStream(const aStream: TStream;
                                            const aDefaultEncoding: TEncoding;
                                            const aBufferKB: Word): TJSONStructure;
  var
    source: IUnicodeReader;
    reader: TJSONReader;
  begin
    source := TUnicodeReader.OfStream(aStream, aDefaultEncoding, aBufferKB);
    reader := TJSONReader.Create(source);
    try
      result := reader.ReadValue as TJSONStructure;

    finally
      reader.Free;
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function TJSONStructure.CreateFromANSI(const aString: ANSIString): TJSONStructure;
  var
    source: IUnicodeReader;
    reader: TJSONReader;
  begin
    source := TUnicodeReader.OfANSI(aString);

    reader := TJSONReader.Create(source);
    try
      result := reader.ReadValue as TJSONStructure;

    finally
      reader.Free;
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function TJSONStructure.CreateFromUTF8(const aString: UTF8String): TJSONStructure;
  var
    source: IUnicodeReader;
    reader: TJSONReader;
  begin
    source := TUnicodeReader.OfUTF8(aString);

    reader := TJSONReader.Create(source);
    try
      result := reader.ReadValue as TJSONStructure;

    finally
      reader.Free;
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function TJSONStructure.CreateFromWIDE(const aString: UnicodeString): TJSONStructure;
  var
    source: IUnicodeReader;
    reader: TJSONReader;
  begin
    source := TUnicodeReader.OfWIDE(aString);

    reader := TJSONReader.Create(source);
    try
      result := reader.ReadValue as TJSONStructure;

    finally
      reader.Free;
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function TJSONStructure.CreateFromString(const aString: String): TJSONStructure;
  begin
  {$ifdef UNICODE}
    result := CreateFromWIDE(aString);
  {$else}
    result := CreateFromANSI(aString);
  {$endif}
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONStructure.get_AsDisplayText: UnicodeString;

    function ObjectToString(const aObject: TJSONObject;
                            const aIndent: Integer): UnicodeString; forward;

    function ArrayToString(const aArray: TJSONArray;
                           const aIndent: Integer): UnicodeString;
    var
      i: Integer;
      item: TJSONValue;
    begin
      if (aArray.Count = 0) then
      begin
        result := '[]';
        EXIT;
      end;

      result := '['#13#10;

      if aArray.Count > 0 then
      begin
        for i := 0 to Pred(aArray.Count) do
        begin
          item := aArray.Items[i];

          result := result + StringOfChar(' ', aIndent);

          if NOT item.IsNull then
            case item.ValueType of
              jsString  : result := result + TJSONString.Encode(item.AsString);
              jsArray   : result := result + '  ' + ArrayToString(item as TJSONArray, aIndent + 2);
              jsObject  : result := result + '  ' + ObjectToString(item as TJSONObject, aIndent + 2);
            else
              result := result + item.AsString;
            end
          else
            result := result + '  null';

          result := result + ','#13#10;
        end;

        SetLength(result, Length(result) - 3);
      end;

      result := result + #13#10 + StringOfChar(' ', aIndent) + ']';
    end;

    function ObjectToString(const aObject: TJSONObject;
                            const aIndent: Integer): UnicodeString;
    var
      i: Integer;
      value: TJSONValue;
    begin
      if (aObject.ValueCount = 0) then
      begin
        result := '{}';
        EXIT;
      end;

      result := '{'#13#10;

      if aObject.ValueCount > 0 then
      begin
        for i := 0 to Pred(aObject.ValueCount) do
        begin
          value := aObject.ValueByIndex[i];

          result := result + StringOfChar(' ', aIndent + 2) + TJSONString.Encode(value.Name) + ':';

          if value.IsNull then
            result := result + 'null'
          else
            case value.ValueType of
              jsString  : result := result + TJSONString.Encode(value.AsString);
              jsArray   : result := result + ArrayToString(value as TJSONArray, aIndent + Length(value.Name) + 5);
              jsObject  : result := result + ObjectToString(value as TJSONObject, aIndent + Length(value.Name) + 5);
            else
              result := result + value.AsString;
            end;

          result := result + ','#13#10;
        end;

        SetLength(result, Length(result) - 3);
      end;

      result := result + #13#10 + StringOfChar(' ', aIndent) + '}';
    end;

  begin
    case ValueType of
      jsArray   : result := ArrayToString(TJSONArray(self), 0);
      jsObject  : result := ObjectToString(TJSONObject(self), 0);
    else
      result := 'Not a JSON text Value';
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONStructure.get_IsNull: Boolean;
  begin
    result := FALSE;  // Arrays and objects are never NULL (not even when empty)
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONStructure.Add(const aName: UnicodeString; const aValue: Boolean): TJSONBoolean;
  begin
    result := TJSONBoolean.Create;
    result.Name   := aName;
    result.Value  := aValue;

    Add(result);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONStructure.Add(const aName: UnicodeString; const aValue: Integer): TJSONInteger;
  begin
    result := TJSONInteger.Create;
    result.Name  := aName;
    result.Value := aValue;

    Add(result);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONStructure.Add(const aName, aValue: UnicodeString): TJSONString;
  begin
    result := TJSONString.Create;
    result.Name  := aName;
    result.Value := aValue;

    Add(result);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONStructure.AddDate(const aName: UnicodeString;
                             const aValue: TDate): TJSONString;
  {
    Cannot simply overload Double/TDateTime if we wish to support earlier Delphi
     compilers as there is a bug in the compiler that considers Double/TDateTime
     ambiguous despite being declared as distinct types.

    Instead we have to provide this protected method specifically for adding
     TDateTime values - the Add(name, TDateTime) method calls this protected
     method as does the override in TJSONArray.
  }
  begin
    result := TJSONString.Create;
    result.Name := aName;

    if (aValue <> NULLDATE) then
      result.Value := DateTimeToISO8601(aValue, [dtDate])
    else
      result.IsNull := TRUE;

    Add(result);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONStructure.AddTime(const aName: UnicodeString;
                             const aValue: TTime): TJSONString;
  {
    Cannot simply overload Double/TDateTime if we wish to support earlier Delphi
     compilers as there is a bug in the compiler that considers Double/TDateTime
     ambiguous despite being declared as distinct types.

    Instead we have to provide this protected method specifically for adding
     TDateTime values - the Add(name, TDateTime) method calls this protected
     method as does the override in TJSONArray.
  }
  begin
    result := TJSONString.Create;
    result.Name := aName;

    if (aValue <> NULLDATE) then
      result.Value := DateTimeToISO8601(aValue, [dtTime])
    else
      result.IsNull := TRUE;

    Add(result);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONStructure.AddDateTime(const aName: UnicodeString;
                                      const aValue: TDateTime): TJSONString;
  {
    Cannot simply overload Double/TDateTime if we wish to support earlier Delphi
     compilers as there is a bug in the compiler that considers Double/TDateTime
     ambiguous despite being declared as distinct types.

    Instead we have to provide this protected method specifically for adding
     TDateTime values - the Add(name, TDateTime) method calls this protected
     method as does the override in TJSONArray.
  }
  begin
    result := TJSONString.Create;
    result.Name := aName;

    if (aValue <> NULLDATE) then
      result.Value := DateTimeToISO8601(aValue)
    else
      result.IsNull := TRUE;

    Add(result);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONStructure.AddDouble(const aName: UnicodeString;
                                    const aValue: Double): TJSONNumber;
  {
    Cannot simply overload Double/TDateTime if we wish to support earlier Delphi
     compilers as there is a bug in the compiler that considers Double/TDateTime
     ambiguous despite being declared as distinct types.

    Instead we have to provide this protected method specifically for adding
     TDateTime values - the Add(name, TDateTime) method calls this protected
     method as does the override in TJSONArray.
  }
  begin
    result := TJSONDouble.Create;
    result.Name := aName;

    TJSONDouble(result).Value  := aValue;

    Add(result);
  end;


{$ifdef DELPHI2009__}
  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONStructure.Add(const aName: UnicodeString;
                         const aValue: TDate): TJSONString;
  begin
    result := TJSONString.Create;
    result.Name := aName;

    if (aValue <> NULLDATE) then
      result.Value := DateTimeToISO8601(aValue, [dtDate])
    else
      result.IsNull := TRUE;

    Add(result);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONStructure.Add(const aName: UnicodeString;
                              const aValue: TTime): TJSONString;
  begin
    result := TJSONString.Create;
    result.Name := aName;

    if (aValue <> NULLDATE) then
      result.Value := DateTimeToISO8601(aValue, [dtTime])
    else
      result.IsNull := TRUE;

    Add(result);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONStructure.Add(const aName: UnicodeString;
                              const aValue: TDateTime): TJSONString;
  begin
    result := AddDateTime(aName, aValue);
  end;
{$endif}


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONStructure.Add(const aName: UnicodeString;
                              const aValue: TGUID): TJSONString;
  begin
    result := TJSONString.Create;
    result.Name  := aName;

    if NOT SameGUID(aValue, NULLGUID) then
      result.Value := GUIDToString(aValue)
    else
      result.IsNull := TRUE;

    Add(result);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONStructure.Add(const aName: UnicodeString;
                         const aValue: Integer;
                         const aTypeInfo: PTypeInfo): TJSONString;
  begin
    result := Add(aName, GetEnumName(aTypeInfo, aValue));
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONStructure.Add(const aName: UnicodeString;
                              const aValue: Int64): TJSONNumber;
  begin
    result := TJSONInteger.Create;
    result.Name := aName;

    TJSONInteger(result).Value := aValue;

    Add(result);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONStructure.Add(const aName: UnicodeString;
                              const aValue: Double): TJSONNumber;
  begin
    result := TJSONDouble.Create;
    result.Name := aName;

    TJSONDouble(result).Value  := aValue;

    Add(result);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONStructure.AddArray(const aName: UnicodeString): TJSONArray;
  begin
    result := TJSONArray.Create;
    result.Name := aName;
    Add(result);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TJSONStructure.AddNull(const aName: UnicodeString);
  var
    null: TJSONValue;
  begin
    null := TJSONNull.Create;
    null.Name   := aName;
    Add(null);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONStructure.AddObject(const aName: UnicodeString): TJSONObject;
  begin
    result := TJSONObject.Create;
    result.Name := aName;
    Add(result);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONStructure.Add(const aName: UnicodeString;
                         const aValue: TJSONStructure): TJSONStructure;
  begin
    result := TJSONStructure(aValue.Clone);
    result.Name := aName;
    Add(result);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TJSONStructure.Load(const aSource: IUnicodeReader);
  var
    reader: TJSONReader;
    loaded: TJSONValue;
  begin
    reader := NIL;
    loaded := NIL;
    try
      Clear;

      if NOT aSource.EOF then
      begin
        reader := TJSONReader.Create(aSource);
        loaded := reader.ReadValue;

        if Assigned(loaded) then
          CopyFrom(loaded);
      end;

    finally
      loaded.Free;
      reader.Free;
    end;
  end;


  procedure TJSONStructure.LoadFromFile(const aFileName: UnicodeString;
                                   const aEncoding: TEncoding;
                                   const aBufferKB: Word);
  var
    stream: TFileStream;
    reader: IUnicodeReader;
  begin
    stream := TFileStream.Create(aFileName, fmOpenRead or fmShareDenyWrite);
    reader := TUnicodeReader.AsOwnerOfStream(stream, aEncoding, aBufferKB);

    Load(reader);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TJSONStructure.LoadFromStream(const aStream: TStream;
                                     const aEncoding: TEncoding;
                                     const aBufferKB: Word);
  var
    reader: IUnicodeReader;
  begin
    reader := TUnicodeReader.OfStream(aStream, aEncoding, aBufferKB);
    Load(reader);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TJSONStructure.SaveToFile(const aFileName: UnicodeString;
                                 const aCompact: Boolean);
  var
    stream: TMemoryStream;
  begin
    stream := TMemoryStream.Create;
    try
      SaveToStream(stream, aCompact);
      stream.SaveToFile(aFileName);

    finally
      stream.Free;
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TJSONStructure.SaveToStream(const aStream: TStream;
                                   const aCompact: Boolean);
  var
    s: UTF8String;
  begin
    if aCompact then
      s := UTF8.FromWide(AsString)
    else
      s := UTF8.FromWide(AsDisplayText);

    aStream.Write(s[1], Length(s));
  end;









{ TJSONArray ------------------------------------------------------------------------------------- }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TJSONArray.Create;
  begin
    inherited Create;

    fItems := TObjectList.Create(TRUE);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  destructor TJSONArray.Destroy;
  begin
    FreeAndNIL(fItems);

    inherited;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONArray.Add(const aValue: UnicodeString): TJSONString;
  begin
    result := inherited Add('', aValue);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONArray.Add(const aValue: Integer): TJSONInteger;
  begin
    result := inherited Add('', aValue);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONArray.Add(const aValue: Boolean): TJSONBoolean;
  begin
    result := inherited Add('', aValue);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONArray.Add(const aValue: Integer; const aTypeInfo: PTypeInfo): TJSONString;
  begin
    result := inherited Add('', aValue, aTypeInfo);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONArray.Add(const aValue: TJSONStructure): TJSONStructure;
  begin
    result := inherited Add('', aValue);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONArray.Add(const aValue: TGUID): TJSONString;
  begin
    result := inherited Add('', aValue);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONArray.Add(const aValue: TDateTime): TJSONString;
  begin
    result := inherited AddDateTime('', aValue);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TJSONArray.Add(const aValue: TJSONValue);
  begin
    fIsNull := FALSE;
    fItems.Add(aValue);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONArray.AddArray: TJSONArray;
  begin
    result := inherited AddArray('');
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TJSONArray.AddNull;
  begin
    inherited AddNull('');
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONArray.AddObject(const aTemplate: TJSONObject): TJSONObject;
  begin
    if Assigned(aTemplate) then
      result := aTemplate.Clone
    else
      result := TJSONObject.Create;

    Add(TJSONValue(result));
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONArray.AsStringArray: TStringArray;
  var
    i: Integer;
  begin
    SetLength(result, Count);

    for i := 0 to Pred(Count) do
      result[i] := Items[i].AsString;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TJSONArray.Clear;
  begin
    fItems.Clear;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONArray.Clone: TJSONArray;
  begin
    ASSERT(self is TJSONArray);
    result := TJSONArray(inherited Clone);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TJSONArray.Combine(const aSource: TJSONArray);
  var
    i: Integer;
  begin
    for i := 0 to Pred(aSource.Count) do
      fItems.Add(aSource[i].Clone);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TJSONArray.CopyFrom(const aSource: TJSONValue);
  var
    i: Integer;
    source: TJSONArray absolute aSource;
  begin
    inherited CopyFrom(aSource);

    Clear;

    for i := 0 to Pred(source.Count) do
      fItems.Add(source.Items[i].Clone);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TJSONArray.Delete(const aIndex: Integer);
  begin
    fItems.Delete(aIndex);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TJSONArray.Delete(const aValue: TJSONValue);
  begin
    Delete(fItems.IndexOf(aValue));
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONArray.DoGetAsString: UnicodeString;
  var
    i: Integer;
    item: TJSONValue;
  begin
    result := '';

    if Count > 0 then
    begin
      for i := 0 to Pred(Count) do
      begin
        Item := Items[i];

        case item.ValueType of
          jsNull    : result := result + 'null';
          jsString  : result := result + TJSONString.Encode(item.AsString);
        else
          result := result + item.AsString;
        end;

        result := result + ',';
      end;

      SetLength(result, Length(result) - 1);
    end;

    result := '[' + result + ']';
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TJSONArray.DoSetAsString(const aValue: UnicodeString);
  var
    source: IUnicodeReader;
  begin
    source := TUnicodeReader.OfWIDE(aValue);
    Load(source);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONArray.get_Count: Integer;
  begin
    result := fItems.Count;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONArray.get_IsEmpty: Boolean;
  begin
    result := (fItems.Count = 0);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONArray.get_Item(const aIndex: Integer): TJSONValue;
  begin
    result := TJSONValue(fItems[aIndex])
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TJSONArray.Sort(const aComparer: TJSONObjectComparer);
  begin
    fItems.Sort(TListSortCompare(aComparer));
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TJSONArray.Wipe;
  var
    i: Integer;
  begin
    for i := 0 to Pred(Count) do
      Items[i].Wipe;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONArray.FindObject(const aValueName: UnicodeString;
                                 const aValue: TGUID;
                                 var aObject: TJSONObject): Boolean;
  var
    i: Integer;
  begin
    result := FALSE;

    try
      for i := 0 to Pred(Count) do
      begin
        if Items[i].ValueType <> jsObject then
          CONTINUE;

        aObject := TJSONObject(Items[i]);
        if aObject.Contains(aValueName)
         and SameGUID(aObject[aValueName].AsGUID, aValue) then
          EXIT;
      end;

      aObject := NIL;

    finally
      result := Assigned(aObject);
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TJSONArray.GetStrings(const aList: TStringList);
  var
    i: Integer;
  begin
    for i := 0 to Pred(Count) do
      aList.Add(Items[i].AsString);
  end;




{ TJSONNull -------------------------------------------------------------------------------------- }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONNull.DoGetAsString: UnicodeString;
  begin
    result := 'null';
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONNull.get_IsNull: Boolean;
  begin
    result := TRUE;
  end;







{ TJSONBoolean ----------------------------------------------------------------------------------- }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TJSONBoolean.set_Value(const aValue: Boolean);
  begin
    IsNull := FALSE;
    fValue := aValue;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TJSONBoolean.CopyFrom(const aSource: TJSONValue);
  begin
    inherited CopyFrom(aSource);

    fValue := TJSONBoolean(aSource).fValue;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONBoolean.DoGetAsString: UnicodeString;
  begin
    case fValue of
      TRUE  : result := 'true';
      FALSE : result := 'false';
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TJSONBoolean.DoSetAsString(const aValue: UnicodeString);
  begin
    inherited;

    if SameText(aValue, 'true') then
      Value := TRUE
    else if SameText(aValue, 'false') then
      Value := FALSE
    else
      raise EJSONError.CreateFmt('"%s" is not a valid value for a boolean', [aValue]);
  end;








{ TJSONDouble ------------------------------------------------------------------------------------ }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TJSONDouble.CopyFrom(const aSource: TJSONValue);
  begin
    inherited CopyFrom(aSource);

    fValue := TJSONDouble(aSource).fValue;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONDouble.DoGetAsString: UnicodeString;
  begin
    result := FloatToStr(fValue);

    if Trunc(fValue) = fValue then
      result := result + '.0';
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TJSONDouble.DoSetAsString(const aValue: UnicodeString);
  begin
    inherited;

    Value := StrToFloat(aValue);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TJSONDouble.set_Value(const aValue: Double);
  begin
    IsNull := FALSE;
    fValue := aValue;
  end;







{ TJSONInteger ----------------------------------------------------------------------------------- }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TJSONInteger.CopyFrom(const aSource: TJSONValue);
  begin
    inherited CopyFrom(aSource);

    fValue := TJSONInteger(aSource).fValue;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONInteger.DoGetAsString: UnicodeString;
  begin
    result := IntToStr(fValue);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TJSONInteger.DoSetAsString(const aValue: UnicodeString);
  begin
    inherited;

    Value := StrToInt64(aValue);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TJSONInteger.set_Value(const aValue: Int64);
  begin
    IsNull := FALSE;
    fValue := aValue;
  end;







{ TJSONString ------------------------------------------------------------------------------------ }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function TJSONString.Decode(const aValue: UnicodeString): UnicodeString;

    function UnescapeUnicode(var aI: Integer): WideChar;
    var
      buf: array[0..3] of ANSIChar;
    begin
      buf[2] := ANSIChar(aValue[aI + 1]);
      buf[3] := ANSIChar(aValue[aI + 2]);
      buf[0] := ANSIChar(aValue[aI + 3]);
      buf[1] := ANSIChar(aValue[aI + 4]);

      HexToBin(PANSIChar(@buf), @result, 2);

      Inc(aI, 4);
    end;

  var
    c: WideChar;
    quoted: Boolean;
    i, ri: Integer;
    len: Integer;
  begin
    result := '';
    if aValue = '' then
      EXIT;

    i   := 1;
    len := Length(aValue);

    quoted := (aValue[1] = '"');
    if quoted then
    begin
      if (len < 2) or (aValue[len] <> '"') then
        raise EJSONError.Create('Quoted string not terminated');

      Inc(i);
      Dec(len);
    end;

    ri := 1;
    SetLength(result, len);
    try
      while (i <= len) do
      begin
        c := aValue[i];

        if (c = '\') then
        begin
          if (i = len) then
            raise EJSONError.Create('Incomplete escape sequence');

          Inc(i);
          c := aValue[i];

          case c of
            '"', '\', '/' : {NO-OP - read these chars just as they are};
            'b' : c := WideChar(#8);
            't' : c := WideChar(#9);
            'n' : c := WideChar(#10);
            'f' : c := WideChar(#12);
            'r' : c := WideChar(#13);
            'u' : if (i + 4) <= len then
                    c := UnescapeUnicode(i)
                  else
                    raise EJSONError.Create('Incomplete Unicode escape sequence');
          else
            raise EJSONError.Create('Invalid escape sequence');
          end;
        end;

        result[ri] := c;
        Inc(ri);
        Inc(i);
      end;

    finally
      SetLength(result, ri - 1);
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function TJSONString.Encode(const aValue: UnicodeString): UnicodeString;

    procedure EscapeUnicode(const aChar: WideChar);
    var
      i: Integer;
      buf: array[0..3] of Char;
    begin
    {$ifdef UNICODE}
      BinToHex(@aChar, PWideChar(@buf), 2);
    {$else}
      BinToHex(PANSIChar(@aChar), @buf, 2);
    {$endif}

      i := Length(result);
      SetLength(result, i + 6);

      result[i + 1] := '\';
      result[i + 2] := 'u';
      result[i + 3] := WideChar(buf[2]);
      result[i + 4] := WideChar(buf[3]);
      result[i + 5] := WideChar(buf[0]);
      result[i + 6] := WideChar(buf[1]);
    end;

  var
    i: Integer;
    c: WideChar;
  begin
    result := '"';

    for i := 1 to Length(aValue) do
    begin
      c := aValue[i];

      case c of
        '"', '/', '\' : result := result + '\' + c;
        ANSIChar(#8)  : result := result + '\b';
        ANSIChar(#9)  : result := result + '\t';
        ANSIChar(#10) : result := result + '\n';
        ANSIChar(#12) : result := result + '\f';
        ANSIChar(#13) : result := result + '\r';
      else
        if (Word(c) > $7f) then
          EscapeUnicode(c)
        else
          result := result + c;
      end;
    end;

    result := result + '"';
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONString.get_AsJSON: UnicodeString;
  begin
    result := TJSONString.Encode(fValue);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TJSONString.set_Value(const aValue: UnicodeString);
  begin
    IsNull := FALSE;
    fValue := aValue;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TJSONString.CopyFrom(const aSource: TJSONValue);
  begin
    inherited CopyFrom(aSource);

    fValue := TJSONString(aSource).fValue;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONString.DoGetAsString: UnicodeString;
  begin
    result := fValue;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TJSONString.DoSetAsString(const aValue: UnicodeString);
  begin
    inherited;

    Value := aValue;
  end;







{ TJSONObject ------------------------------------------------------------------------------------ }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function TJSONObject.TryCreate(const aString: UnicodeString): TJSONObject;
  begin
    result := TJSONObject.Create;
    try
      result.AsString := aString;

    except
      result.Free;
      result := NIL;
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TJSONObject.Create;
  begin
    inherited Create;

    fValues := TObjectList.Create(TRUE);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TJSONObject.Create(const aString: UnicodeString);
  begin
    Create;
    AsString := aString;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TJSONObject.CreateFromFile(const aFilename: UnicodeString;
                                         const aEncoding: TEncoding;
                                         const aBufferKB: Word);
  begin
    Create;

    LoadFromFile(aFilename, aEncoding, aBufferKB);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TJSONObject.Delete(const aValueName: UnicodeString);
  var
    val: TJSONValue;
  begin
    if NOT Contains(aValueName) then
      EXIT;

    val := Values[aValueName];
    fValues.Remove(val);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  destructor TJSONObject.Destroy;
  begin
    FreeAndNIL(fValues);
    inherited;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONObject.get_IsEmpty: Boolean;
  begin
    result := (fValues.Count = 0);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONObject.get_Value(const aName: UnicodeString): TJSONValue;
  begin
    result := FindValue(aName);

    if NOT Assigned(result) then
      raise EJSONError.CreateFmt('No such value (%s) in object', [aName]);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONObject.get_ValueByIndex(const aIndex: Integer): TJSONValue;
  begin
    result := TJSONValue(fValues[aIndex]);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONObject.get_ValueCount: Integer;
  begin
    result := fValues.Count;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TJSONObject.Add(const aValue: TJSONValue);
  begin
    fValues.Add(aValue);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONObject.AddAfter(const aPredecessor: UnicodeString;
                                const aName: UnicodeString;
                                const aValue: UnicodeString): TJSONString;
  var
    i: Integer;
  begin
    if NOT Contains(aPredecessor) then
      raise EJSONError.CreateFmt('No such predecessor ''%s''', [aPredecessor]);

    result := TJSONString.Create;
    result.Name  := aName;
    result.Value := aValue;

    for i := 0 to Pred(fValues.Count) do
      if STR.SameText(aPredecessor, TJSONValue(fValues[i]).Name) then
        if i < Pred(fValues.Count) then
        begin
          fValues.Insert(i + 1, result);
          BREAK;
        end
        else
          fValues.Add(result);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TJSONObject.Clear;
  begin
    fValues.Clear;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONObject.Clone: TJSONObject;
  begin
    result := TJSONObject(inherited Clone);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TJSONObject.Combine(const aObject: TJSONObject);
  var
    i: Integer;
  begin
    for i := 0 to Pred(aObject.ValueCount) do
      Add(aObject.ValueByIndex[i].Clone);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONObject.Contains(const aValueName: UnicodeString): Boolean;
  begin
    result := Assigned(FindValue(aValueName));
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONObject.Contains(const aValueName: UnicodeString;
                                var   aValue: UnicodeString): Boolean;
  begin
    result := Assigned(FindValue(aValueName));
    if result then
      aValue := self[aValueName].AsString;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONObject.Contains(const aValueName: UnicodeString;
                                var   aValue: TJSONArray): Boolean;
  begin
    result := Contains(aValueName) and (Values[aValueName].ValueType = jsArray);

    if result then
      aValue := self[aValueName].AsArray;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONObject.Contains(const aValueName: UnicodeString;
                                var   aValue: TWIDEStringArray): Boolean;
  var
    i: Integer;
    values: TJSONArray;
  begin
    result := Contains(aValueName, values);

    if result then
    begin
      SetLength(aValue, values.Count);
      for i := 0 to Pred(values.Count) do
        aValue[i] := values[i].AsString;
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TJSONObject.CopyFrom(const aSource: TJSONValue);
  var
    i: Integer;
    source: TJSONObject absolute aSource;
  begin
    Clear;

    inherited CopyFrom(aSource);

    for i := 0 to Pred(source.ValueCount) do
      Add(source.ValueByIndex[i].Clone);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONObject.DoGetAsString: UnicodeString;
  var
    i: Integer;
    value: TJSONValue;
  begin
    result := '';

    if IsNull then
      result := 'null'
    else if ValueCount > 0 then
    begin
      for i := 0 to Pred(ValueCount) do
      begin
        value := ValueByIndex[i];

        result := result + TJSONString.Encode(value.Name) + ':';

        if value.IsNull then
          result := result + 'null'
        else if (value.ValueType = jsString) then
          result := result + TJSONString.Encode(value.AsString)
        else
          result := result + value.AsString;

        result := result + ',';
      end;

      SetLength(result, Length(result) - 1);
    end;

    result := '{' + result + '}';
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TJSONObject.DoSetAsString(const aValue: UnicodeString);
  var
    source: IUnicodeReader;
  begin
    inherited;

    source:= TUnicodeReader.OfWIDE(aValue);
    Load(source);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TJSONObject.Wipe;
  var
    i: Integer;
  begin
    for i := 0 to Pred(ValueCount) do
      ValueByIndex[i].Wipe;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONObject.FindValue(const aName: UnicodeString): TJSONValue;
  var
    i: Integer;
  begin
    for i := 0 to Pred(ValueCount) do
    begin
      result := ValueByIndex[i];
      if SameText(result.Name, aName) then
        EXIT;
    end;

    result := NIL;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TJSONObject.LoadFromStream(const aStream: TStream;
                                       const aEncoding: TEncoding;
                                       const aBufferKB: Word);
  var
    source: IUnicodeReader;
    reader: TJSONReader;
    loaded: TJSONValue;
  begin
    source := TUnicodeReader.OfStream(aStream, aEncoding, aBufferKB);

    loaded := NIL;
    reader := TJSONReader.Create(source);
    try
      loaded := reader.ReadValue;

      if NOT (loaded is TJSONObject) then
        raise EJSONError.Create('Stream does not contain a JSON object');

      Clear;
      CopyFrom(loaded);

    finally
      loaded.Free;
      reader.Free;
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONObject.OptBoolean(const aName: UnicodeString;
                                  const aDefault: Boolean): Boolean;
  begin
    if Contains(aName) and NOT Values[aName].IsNull then
      result := Values[aName].AsBoolean
    else
      result := aDefault;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONObject.OptDateTime(const aName: UnicodeString;
                                   const aDefault: TDateTime): TDateTime;
  begin
    if Contains(aName) and NOT Values[aName].IsNull then
      result := Values[aName].AsDateTime
    else
      result := aDefault;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONObject.OptEnum(const aName: UnicodeString;
                               const aTypeInfo: PTypeInfo;
                               const aDefault: Integer): Integer;
  begin
    if Contains(aName) and NOT Values[aName].IsNull then
      result := GetEnumValue(aTypeInfo, Values[aName].AsString)
    else
      result := aDefault;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONObject.OptInteger(const aName: UnicodeString;
                                  const aDefault: Integer): Integer;
  begin
    if Contains(aName) and NOT Values[aName].IsNull then
      result := Values[aName].AsInteger
    else
      result := aDefault;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONObject.OptString(const aName: UnicodeString;
                                 const aDefault: UnicodeString): UnicodeString;
  begin
    if Contains(aName) and NOT Values[aName].IsNull then
      result := Values[aName].AsString
    else
      result := aDefault;
  end;


{$ifdef DELPHI2009__}
  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONObject.OptDate(const aName: UnicodeString; const aDefault: TDate): TDate;
  begin
    if Contains(aName) and NOT Values[aName].IsNull then
      result := Values[aName].AsDate
    else
      result := aDefault;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONObject.OptTime(const aName: UnicodeString;
                               const aDefault: TTime): TTime;
  begin
    if Contains(aName) and NOT Values[aName].IsNull then
      result := Values[aName].AsTime
    else
      result := aDefault;
  end;
{$endif}







{ TJSONReader ------------------------------------------------------------------------------ }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TJSONReader.Create(const aSource: IUnicodeReader);
  begin
    inherited Create;

    fSource := aSource;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONReader.EOF: Boolean;
  begin
    result := fSource.EOF;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONReader.NextChar: WideChar;
  begin
    if NOT fNextCharReady then
      fNextCharReady := fSource.ReadChar(fNextChar);

    result := fNextChar;
   end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONReader.NextRealChar: WideChar;
  const
    WHITESPACE = [' ', #13, #10, #9];
  begin
    repeat
      result := ReadChar;
    until EOF or NOT (ANSIChar(result) in WHITESPACE);

    if (ANSIChar(result) in WHITESPACE) then
      result := #0;

    fNextChar       := result;
    fNextCharReady  := TRUE;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONReader.ReadChar: WideChar;
  begin
    if fNextCharReady then
    begin
      result := fNextChar;
      fNextCharReady := FALSE;
    end
    else if NOT EOF then
      fSource.ReadChar(result)
    else
      result := #0;

    if ANSIChar(result) in [#13,#10] then
    begin
      Inc(fLine);
      fPos := 0;
    end
    else
      Inc(fPos);
  end;



  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONReader.ReadRealChar: WideChar;
  const
    WHITESPACE = [' ', #13, #10, #9];
  begin
    repeat
      result := ReadChar;
    until EOF or NOT (ANSIChar(result) in WHITESPACE);

    if (ANSIChar(result) in WHITESPACE) then
      result := #0;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONReader.ReadArray: TJSONArray;
  var
    value: TJSONValue;
  begin
    if ReadRealChar <> '[' then
      raise EJSONStreamError.Create('Expected ''[''');

    result := TJSONArray.Create;
    try
      if (NextRealChar = ']') then
      begin
        // It's an array alright, but it's empty so just return
        //  the new, empty array, reading past the  ']' that closes the array
        ReadRealChar;
        EXIT;
      end;

      // Read values to be added to the array until we reach either the
      //  end of the array or run out of data

      while NOT EOF do
      begin
        value := ReadValue;
        result.Add(value);

        case NextRealChar of
          ']' : begin
                  ReadRealChar;
                  EXIT;
                end;

          ',' : ReadRealChar;
        else
          raise EJSONStreamError.Create('Unexpected character ''' + NextRealChar + ''' in array');
        end;
      end;

      raise EJSONStreamError.Create('Array not closed');

    except
      result.Free;
      raise;
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONReader.ReadObject: TJSONObject;
  var
    c: WideChar;
    name: UnicodeString;
    value: TJSONValue;
  begin
    if ReadRealChar <> '{' then
      raise EJSONStreamError.Create('Expected ''{''');

    result := TJSONObject.Create;
    try
      if (NextRealChar = '}') then
      begin
        ReadRealChar; // Skip the '}'
        EXIT;
      end;

      while NOT EOF do
      begin
        if NextRealChar = '"' then
          name := ReadString
        else
          name := ReadName;

        c := ReadRealChar;
        if (c <> ':') then
          raise EJSONStreamError.Create('Expected '':'', read ''' + c + ''' instead');

        value := ReadValue;

        if NOT Assigned(value) then
          raise EJSONStreamError.Create('Expected value');

        value.Name := name;

        result.Add(value);

        // Test the next char for , (another name/value pair to follow) or } (end of object)

        case NextRealChar of

          '}' : begin
                  ReadRealChar;
                  EXIT;
                end;

          ',' : ReadRealChar;

        else
          raise EJSONStreamError.Create('Unexpected character ''' + NextRealChar + ''' in object');
        end;
      end;

      raise EJSONStreamError.Create('Object not terminated');

    except
      result.Free;
      raise;
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONReader.ReadName: UnicodeString;
  {
    NOTE: This supports a relaxed JSON reader that allows for unquoted object
           value names instead of requiring quoted string values.  The lack
           of quotes means that allowed names are much simplified: only alpha
           characters are permitted.  Whitespace, most symbols and escaped
           characters are not supported or allowed.
  }
  var
    c: WideChar;
  begin
    result := '';
    while TRUE do
    begin
      c := ReadChar;

      case c of
        'a'..'z',
        'A'..'Z'  : result := result + c;
        '.', '-'  : if result = '' then
                      raise EJSONStreamError.Create('Invalid name')
                    else
                      result := result + c;
      else
        raise EJSONStreamError.Create('Invalid name');
      end;

      if EOF then
        raise EJSONError.Create('UnicodeString not terminated');

      c := NextRealChar;

      if ANSIChar(c) = ':' then
      begin
        if WIDE.EndsWith(result, '.') or WIDE.EndsWith(result, '-') then
          raise EJSONStreamError.Create('Invalid name')
        else
          EXIT;
      end;
    end;

  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONReader.ReadString(const aQuoted: Boolean): UnicodeString;
  {
    NOTE: This effectively duplicates the functionality of TJSONString.Decode
           but it is far more efficient to decode inline than it would be to
           parse the reading of the entire string before decoding it.
  }

    function UnescapeUnicode: WideChar;
    const
      BYTEINDEX: array[1..4] of Integer = (2, 3, 0, 1);
    var
      i: Integer;
      c: ANSIChar;
      buf: array[0..3] of ANSIChar;
    begin
      for i := 1 to 4 do
      begin
        c := ANSIChar(NextChar);

        if c in ['0'..'9', 'a'..'f', 'A'..'F'] then
          buf[BYTEINDEX[i]] := c
        else
          raise EJSONStreamError.CreateFmt('Invalid character ''%s'' in escaped Unicode', [c]);

        ReadChar;
      end;

      HexToBin(PANSIChar(@buf), @result, 2);
    end;

  var
    c: WideChar;
  begin
    if aQuoted then
    begin
      if (ReadRealChar <> '"') then
        raise EJSONStreamError.Create('Expected ''"''');
    end;

    if EOF then
      raise EJSONError.Create('UnicodeString not terminated');

    result := '';
    while TRUE do
    begin
      c := ReadChar;

      if (c = '\') then
      begin
        c := ReadChar;

        case c of
          '"', '\', '/' : {NO-OP - read these chars just as they are};
          'b' : c := WideChar(#8);
          't' : c := WideChar(#9);
          'n' : c := WideChar(#10);
          'f' : c := WideChar(#12);
          'r' : c := WideChar(#13);
          'u' : c := UnescapeUnicode;
        else
          raise EJSONStreamError.Create('Invalid escape character sequence');
        end;
      end
      else if aQuoted and (c = '"') then
        EXIT;

      result := result + c;

      if EOF then
        raise EJSONError.Create('UnicodeString not terminated');

      c := NextChar;

      if NOT aQuoted and (ANSIChar(c) in [#13, #10, #9, ' ', ',', '}', ']']) then
        EXIT;
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJSONReader.ReadValue: TJSONValue;
  var
    c: WideChar;
    s: UnicodeString;
  begin
    result := NIL;
    try
      c := NextRealChar;

      case c of
        #0  : { NO-OP };
        '[' : result := ReadArray;
        '{' : result := ReadObject;

        '"'       : begin
                      s := ReadString;
                      result := TJSONString.Create;
                      result.AsString := s;
                    end;

        '-'       : begin
                      ReadRealChar;

                      c := NextChar;
                      case c of
                        '1'..'9'  : begin
                                      s := ReadString(FALSE);

                                      if Length(s) > 1 then
                                      begin
                                        if STR.IsInteger(s) then
                                          result := TJSONInteger.Create
                                        else if STR.IsNumeric(s) then
                                          result := TJSONDouble.Create
                                        else
                                          raise EJSONStreamError.CreateFmt('''%s'' is not a valid number', [s]);
                                      end
                                      else
                                        result := TJSONInteger.Create;

                                      result.AsString := '-' + s;
                                    end;
                      else
                        raise EJSONStreamError.CreateFmt('Expected 1..9, found ''%s''', [c]);
                      end;
                    end;

        '0'..'9'  : begin
                      s := ReadString(FALSE);

                      if Length(s) > 1 then
                      begin
                        if STR.IsInteger(s) then
                          result := TJSONInteger.Create
                        else if STR.IsNumeric(s) then
                          result := TJSONDouble.Create
                        else
                          raise EJSONStreamError.CreateFmt('''%s'' is not a valid number', [s]);
                      end
                      else
                        result := TJSONInteger.Create;

                      result.AsString := s;
                    end;

        'n', 'N'  : begin
                      s := ReadString(FALSE);
                      if SameText(s, 'null') then
                        result := TJSONNull.Create
                      else
                        raise EJSONStreamError.CreateFmt('Expected ''null'', found ''%s''', [s]);
                    end;

        'f', 'F',
        't', 'T'  : begin
                      s := ReadString(FALSE);
                      if SameText(s, 'true') or SameText(s, 'false') then
                      begin
                        result := TJSONBoolean.Create;
                        result.AsString := s;
                      end
                      else
                        raise EJSONStreamError.CreateFmt('Expected ''true'' or ''false'', found ''%s''', [s]);
                    end;
      else
        raise EJSONStreamError.CreateFmt('Unexpected char (%s) in stream', [c]);
      end;

    except
      result.Free;
      raise EJSONStreamError.CreateFmt('Error at position %d, line %d', [Pos, Line]);
    end;
  end;












end.
