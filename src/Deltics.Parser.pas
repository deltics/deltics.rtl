

  unit Deltics.Parser;


interface

  uses
  { vcl: }
    Classes,
  { deltics: }
    Deltics.Strings,
    Deltics.Unicode;


  type
    TCharEncoding = (ceASCII, ceANSI, ceUTF8, ceUTF16, ceUTF16BE, ceUTF16LE, ceUTF32, ceUTF32BE, ceUTF32LE);

//    UTF8Char = ANSIChar;


    TBOMInfo = record
      Data: array[0..3] of ANSIChar;  // 1 to 4 bytes identifying the signature
      Len: Integer;                   // Byte length of the signature (i.e. how many of the Data[] bytes are actually used)
      Encoding: TCharEncoding;            // The encoding identified by the signature bytes
      IsHeuristic: Boolean;           // Indicates that the signature is part of the data to
                                      //  be parsed - i.e. not an *explicit* BOM
    end;


    TBlockReaderMethod = function: Boolean of object;
    TDecoderMethod = procedure of object;
    TWhitespace = set of ANSIChar;


    TParser = class
    {
      Provides a base class for parsers.  This base class provides the fundamental
       mechanisms required for reading any arbitrary stream as a series of UTF8 chars.
       Transcoding of the source stream to UFT8 is performed automatically.

      The encoding of the source is determined by identifying a BOM signature at
       the initial read position of the stream.  BOM signatures are automatically
       recognised for the standard UTF encodings (UTF8, UTF16 etc).  Derived classes
       should add their own signatures if/as required by overriding the Initialise
       virtual method and calling ADDBOMSignature for each signature that may be
       recognisable.
    }
    private
      fBOM: TBOMInfo;
      fBOMDetected: Boolean;
      fBOMSignature: array of TBOMInfo;

      fBlockSize: Integer;
      fBuffer: array of Byte;
      fBufferSize: Integer;

      fUTF8: array of UTF8Char;
      fUTF8Pos: Integer;
      fUTF8Size: Integer;

      fEncoding: TCharEncoding;
      fSource: TStream;
      fEOF: Boolean;

      fCodePage: Integer;
      fWhitespace: TWhitespace;

      fDecoderMethod: TDecoderMethod;
      fReadBlockMethod: TBlockReaderMethod;

      procedure DecodeMBCS;
      procedure DecodeUTF8;
      procedure DecodeUTF16;
      procedure DecodeUTF16BE;

      function ReadOtherBlock: Boolean;
      function ReadUTF8Block: Boolean;

      procedure set_CodePage(const aValue: integer);
      procedure set_Encoding(const aValue: TCharEncoding);
      function get_Data(const aIndex: Integer): UTF8Char;
    protected
      procedure AddBOMSignature(const aBOM: TBOMInfo);
      procedure IncPos(var aRemaining: integer);
      procedure Initialise; virtual;
      function MakeDataAvailable: Integer;
      procedure ReadBOM;
      property Data[const aIndex: Integer]: UTF8Char read get_Data;
      property DataPos: Integer read fUTF8Pos;
      property DecodeBlock: TDecoderMethod read fDecoderMethod;
      property ReadBlock: TBlockReaderMethod read fReadBlockMethod;
    public
      constructor Create(const aSource: TStream;
                         const aBlockSize: integer); virtual;
      destructor Destroy; override;
      procedure Flush;
      procedure MoveBack;
      function NextChar: UTF8Char; virtual;
      function NextRealChar: UTF8Char; overload; virtual;
      function NextRealChar(var aWhitespace: String): UTF8Char; overload; virtual;
      function NextWideChar: WideChar; overload; virtual;
      function NextWideChar(var aWhitespace: String): WideChar; overload; virtual;
      function PeekChar: UTF8Char;
      function PeekRealChar: UTF8Char; overload;
      function PeekRealChar(var aWhitespace: String): UTF8Char; overload;
      procedure SkipWhitespace; overload;
      procedure SkipWhitespace(var aWhitespace: String); overload;
      property CodePage: integer read fCodePage write set_CodePage;
      property Encoding: TCharEncoding read fEncoding write set_Encoding;
      property EOF: Boolean read fEOF;
      property Pos: Integer read fUTF8Pos write fUTF8Pos;
      property Whitespace: TWhitespace read fWhitespace write fWhitespace;
    end;



implementation

  uses
  { vcl: }
    SysUtils,
    Windows;


  type
    TByteArray = array of Byte;
    TWordArray = array of Word;


  constructor TParser.Create(const aSource: TStream;
                             const aBlockSize: Integer);
  begin
    inherited Create;

    fSource     := aSource;
    fBlockSize  := aBlockSize;
    SetLength(fBuffer, fBlockSize);

    Initialise;

    ReadBOM;
    ReadBlock;
  end;


  destructor TParser.Destroy;
  begin
    SetLength(fUTF8, 0);
    SetLength(fBuffer, 0);
    SetLength(fBOMSignature, 0);
    inherited;
  end;


  procedure TParser.AddBOMSignature(const aBOM: TBOMInfo);
  begin
    SetLength(fBOMSignature, Length(fBOMSignature) + 1);
    fBOMSignature[Length(fBOMSignature) - 1] := aBOM;
  end;


  procedure TParser.DecodeMBCS;
  var
    i: Integer;
    dp: Integer;
    s: ANSIString;
    b: Byte;
    wc: array of WideChar;
    wcLen: Integer;
  begin
    SetLength(fUTF8, fUTF8Size + (3 * fBufferSize));

    dp  := fUTF8Pos;
    i   := 0;
    while (i < fBufferSize) do
    begin
      b := Byte(fBuffer[i]);

      if (b < $80) then
      begin
        fUTF8[dp] := UTF8Char(b);
        Inc(dp);
        Inc(i);
        CONTINUE;
      end;

      s := '';
      while (b >= $80) do
      begin
        s := s + ANSIChar(b);
        Inc(i);

        if (i = fBufferSize) then
        begin
          if (fBufferSize < fBlockSize) then
            BREAK;

          ReadBlock;
          if (fBufferSize > 0) then
          begin
            SetLength(fUTF8, dp + (3 * fBufferSize));
            i := 0;
          end;
        end;

        b := Byte(fBuffer[i]);
      end;
      SetLength(wc, Length(s) * 2);
      wcLen := MultiByteToWideChar(fCodePage, 0, @s[1], Length(s), @wc[0], Length(wc));
      Move(wc[0], fUTF8[dp], wcLen * 2);
      Inc(dp, wcLen);
    end;

    SetLength(fUTF8, dp);
    fUTF8Size := dp;
  end;


  procedure TParser.DecodeUTF8;
  {
    No decoding necessary.  When reading a UTF8 stream the data is simply read
     straight into the fUTF8 array, by-passing the fBuffer array completely.
  }
  begin
(*
    SetLength(fUTF8, fUTF8Size + fBufferSize);
    Move(fBuffer[0], fUTF8[fUTF8Size], fBufferSize);
    fUTF8Size := fUTF8Size + fBufferSize;
*)
  end;


  procedure TParser.DecodeUTF16;
  var
    i: Integer;
    dp: Integer;
    wc: Word;
  begin
    SetLength(fUTF8, fUTF8Size + (fBufferSize * 2));

    dp  := fUTF8Pos;

    for i := 0 to Pred(fBufferSize) div 2 do
    begin
      wc := TWordArray(fBuffer)[i];

      case wc of
        $0000..$007f  : begin
                          fUTF8[dp] := UTF8Char(wc);
                          Inc(dp);
                        end;

        $0800..$ffff  : begin
                          fUTF8[dp] := UTF8Char($e0 or (wc shr 12));
                          fUTF8[dp + 1] := UTF8Char($80 or ((wc shr 6) and $3f));
                          fUTF8[dp + 2] := UTF8Char($80 or (wc and $3f));
                          Inc(dp, 3);
                        end;
      else
        fUTF8[dp] := UTF8Char($c0 or (wc shr 6));
        fUTF8[dp + 1] := UTF8Char($80 or (wc and $3f));
        Inc(dp, 2);
      end;
    end;

    SetLength(fUTF8, dp);
    fUTF8Size := dp;
  end;


  procedure TParser.DecodeUTF16BE;
  var
    i: Integer;
    dp: Integer;
    wc: Word;
  begin
    SetLength(fUTF8, fUTF8Size + (fBufferSize * 2));

    dp  := fUTF8Pos;

    for i := 0 to Pred(fBufferSize) div 2 do
    begin
      wc := Swap(TWordArray(fBuffer)[i]);

      case wc of
        $0000..$007f  : begin
                          fUTF8[dp] := UTF8Char(wc);
                          Inc(dp);
                        end;

        $0800..$ffff  : begin
                          fUTF8[dp] := UTF8Char($e0 or (wc shr 12));
                          fUTF8[dp + 1] := UTF8Char($80 or ((wc shr 6) and $3f));
                          fUTF8[dp + 2] := UTF8Char($80 or (wc and $3f));
                          Inc(dp, 3);
                        end;
      else
        fUTF8[dp] := UTF8Char($c0 or (wc shr 6));
        fUTF8[dp + 1] := UTF8Char($80 or (wc and $3f));
        Inc(dp, 2);
      end;
    end;

    SetLength(fUTF8, dp);
    fUTF8Size := dp;
  end;


  procedure TParser.Flush;
  var
    remaining: Integer;
  begin
    if (fUTF8Pos = 0) then
      EXIT;

    remaining := (fUTF8Size - fUTF8Pos);

    if (remaining > 0) then
      Move(fUTF8[fUTF8Pos], fUTF8[0], remaining);

    SetLength(fUTF8, remaining);
  end;


  function TParser.get_Data(const aIndex: Integer): UTF8Char;
  begin
    result := fUTF8[aIndex];
  end;


  procedure TParser.IncPos(var aRemaining: Integer);
  begin
    Inc(fUTF8Pos);

    Dec(aRemaining);
    if aRemaining <= 0 then
      aRemaining := MakeDataAvailable;
  end;


  procedure TParser.Initialise;
  const
    BOM : array[0..4] of TBOMInfo = (
                                     (Data: (#$00,#$00,#$FE,#$FF); Len: 4; Encoding: ceUTF32BE; IsHeuristic: FALSE),
                                     (Data: (#$FF,#$FE,#$00,#$00); Len: 4; Encoding: ceUTF32LE; IsHeuristic: FALSE),
                                     (Data: (#$EF,#$BB,#$BF,#$00); Len: 3; Encoding: ceUTF8;    IsHeuristic: FALSE),
                                     (Data: (#$FE,#$FF,#$00,#$00); Len: 2; Encoding: ceUTF16BE; IsHeuristic: FALSE),
                                     (Data: (#$FF,#$FE,#$00,#$00); Len: 2; Encoding: ceUTF16LE; IsHeuristic: FALSE)
                                    );
  var
    i: Integer;
  begin
    fWhitespace := [#9, #10, #13, ' '];

    for i := Low(BOM) to High(BOM) do
      AddBOMSignature(BOM[i]);
  end;


  function TParser.MakeDataAvailable: Integer;
  begin
    result := fUTF8Size - fUTF8Pos;

    // We still have data from the previous read/decode
    if (result > 0) then
      EXIT;

    // Need to read another block
    if ReadBlock then
      result := (fUTF8Size - fUTF8Pos)
    else
      fEOF := TRUE;
  end;


  procedure TParser.MoveBack;
  begin
    Dec(fUTF8Pos);
  end;


  function TParser.NextChar: UTF8Char;
  begin
    MakeDataAvailable;

    if fEOF then
    begin
      result := #0;
      EXIT;
    end;

    result := fUTF8[fUTF8Pos];
    Inc(fUTF8Pos);
  end;


  function TParser.NextRealChar: UTF8Char;
  var
    remaining: integer;
  begin
    remaining := MakeDataAvailable;
    while NOT fEOF do
    begin
      result := fUTF8[fUTF8Pos];
      IncPos(remaining);

      if NOT (result in fWhitespace) then
        EXIT;
    end;

    // If we reach this point then EOF is TRUE - we found nothing but whitespace
    result := #0;
  end;


  function TParser.NextRealChar(var aWhitespace: String): UTF8Char;
  var
    remaining: integer;
  begin
    aWhitespace := '';

    remaining := MakeDataAvailable;
    while NOT fEOF do
    begin
      result := fUTF8[fUTF8Pos];
      IncPos(remaining);

      if NOT (result in fWhitespace) then
        EXIT;

      aWhitespace := aWhitespace + STR.FromUTF8(result);
    end;

    // If we reach this point then EOF is TRUE - we found nothing but whitespace
    result := #0;
  end;


  procedure TParser.SkipWhitespace;
  var
    ws: String;
  begin
    SkipWhitespace(ws);
  end;


  procedure TParser.SkipWhitespace(var aWhitespace: String);
  var
    l: Integer;
    c: UTF8Char;
    s: UTF8String;
    remaining: integer;
  begin
    l := 0;
    s := '';

    remaining := MakeDataAvailable;
    while NOT fEOF do
    begin
      c := fUTF8[fUTF8Pos];
      IncPos(remaining);

      if (c in fWhitespace) then
      begin
        Inc(l);
        if (l > Length(s)) then
          SetLength(s, Length(s) + 256);

        s[l] := c;
      end
      else
      begin
        SetLength(s, l);
        aWhitespace := STR.FromUTF8(s);
        MoveBack;
        EXIT;
      end;
    end;

    // If we reach this point then EOF is TRUE - we found nothing but whitespace
  end;


  function TParser.PeekChar: UTF8Char;
  begin
    result := NextChar;
    MoveBack;
  end;


  function TParser.PeekRealChar: UTF8Char;
  begin
    result := NextRealChar;
    MoveBack;
  end;


  function TParser.PeekRealChar(var aWhitespace: String): UTF8Char;
  begin
    result := NextRealChar(aWhitespace);
    MoveBack;
  end;


  function TParser.ReadOtherBlock: Boolean;
  begin
    fBufferSize := fSource.Read(fBuffer[0], fBlockSize);
    result := (fBufferSize > 0);

    if result then
      DecodeBlock;
  end;


  function TParser.ReadUTF8Block: Boolean;
  var
    size: Integer;
  begin
    SetLength(fUTF8, fUTF8Size + fBlockSize);

    size := fSource.Read(fUTF8[fUTF8Size], fBlockSize);
    Inc(fUTF8Size, size);

    result := (size > 0);
  end;


  function TParser.NextWideChar: WideChar;
  var
    c: UTF8Char;
  begin
    c := NextChar;

    result := WideChar(c);
    if (Word(result) and $80) <> 0 then
    begin
      result := WideChar(Word(result) and $3f);
      if (Word(result) and $20) <> 0 then
      begin
        // 2nd byte
        c := NextChar;
        if (Byte(c) and $C0) <> $80 then // malformed trail byte
          EXIT;

        result := WideChar((Word(result) shl 6) or (Byte(c) and $3f));
      end;

      c := NextChar;
      if (Byte(c) and $c0) <> $80 then // malformed trail byte
        EXIT;

      result := WideChar((Word(result) shl 6) or (Byte(c) and $3f));
    end;
  end;


  function TParser.NextWideChar(var aWhitespace: String): WideChar;
  begin
    while NOT fEOF do
    begin
      result := NextWideChar;

      if NOT (ANSIChar(result) in fWhitespace) then
        EXIT;

      aWhitespace := aWhitespace + result;
    end;

    result := #0;
  end;


  procedure TParser.set_CodePage(const aValue: integer);
  begin
    fCodePage := aValue;
    // re-encode the chunk (e.g. from default utf-8 codepage to other ansi codepage)
    DecodeBlock;
  end;


  procedure TParser.set_Encoding(const aValue: TCharEncoding);
  begin
    fEncoding := aValue;

    if (fEncoding in [ceASCII, ceUTF8]) then
      fCodePage := CP_UTF8;

    case fEncoding of
      ceANSI,
      ceASCII   : fDecoderMethod := DecodeMBCS;
      ceUTF8    : fDecoderMethod := DecodeUTF8;
      ceUTF16BE : fDecoderMethod := DecodeUTF16BE;
      ceUTF16,
      ceUTF16LE : fDecoderMethod := DecodeUTF16;
    end;

    if (fEncoding = ceUTF8) then
      fReadBlockMethod := ReadUTF8Block
    else
      fReadBlockMethod := ReadOtherBlock;
  end;



// TParser

  procedure TParser.ReadBOM;
  var
    i: Integer;
    oldPos: Int64;
  begin
    fBOMDetected := FALSE;

    // read the BOM if it is there
    oldPos := fSource.Position;
    fSource.Read(fBOM.Data[0], 4);

    for i := Low(fBOMSignature) to High(fBOMSignature) do
    begin
      fBOMDetected := CompareMem(@fBOMSignature[i].Data[0], @fBOM.Data[0], fBOMSignature[i].Len);

      if fBOMDetected then
      begin
        fBOM      := fBOMSignature[i];
        Encoding  := fBOM.Encoding;

        // If the BOM is heuristic this means it is embedded within parseable
        //  data so we need to reset the stream position, otherwise we set
        //  the stream position to the end of the BOM itself

        if fBOM.IsHeuristic then
          fSource.Position := oldPos
        else
          fSource.Position := fBOM.Len;

        BREAK;
      end;
    end;

    if NOT fBOMDetected then
    begin
      // There was no explicit BOM and no heuristic BOM, so we must assume that
      //  the stream is entirely parseable data and will assume UTF-8 encoding
      fSource.Position := oldPos;
      Encoding := ceUTF8;
    end;

    // check for non-supported encodings
    if NOT (fEncoding in [ceANSI, ceUTF8, ceUTF16, ceUTF16BE, ceUTF16LE]) then
      raise Exception.Create('Detected encoding is not supported');
  end;










end.
