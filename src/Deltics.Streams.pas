{
  * X11 (MIT) LICENSE *

  Copyright © 2008 Jolyon Smith

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

{$debuginfo ON}

  unit Deltics.Streams;


interface

  uses
  { vcl: }
    Classes,
    SysUtils,
  { deltics: }
    Deltics.Classes,
    Deltics.Memento,
    Deltics.Strings,
    Deltics.Unicode;


  type
    TStreamDecorator = class(TStream)
    private
      fOwnsStream: Boolean;
      fStream: TStream;
      function get_EOF: Boolean;
    protected
      function GetSize: Int64; override;
      function GetStream: TStream; virtual;
      procedure SetSize(const aValue: Int64); override;
      procedure AcquireStream(const aStream: TStream; const aIsOwn: Boolean); virtual;
      procedure ReleaseStream; virtual;
      property EOF: Boolean read get_EOF;
      property Stream: TStream read GetStream;
    public
      constructor Create(const aStream: TStream);
      destructor Destroy; override;
      function Read(var aBuffer; aCount: Integer): Integer; override;
      function Seek(const aOffset: Int64; aOrigin: TSeekOrigin): Int64; override;
      function Write(const aBuffer; aCount: Integer): Integer; override;
      property Size: Int64 read GetSize write SetSize;
    end;


  {$ifdef __DELPHI2007}
    TStringStream = class(Classes.TStringStream)
    public
      constructor Create; reintroduce; overload;
      procedure SaveToFile(const aFilename: String);
    end;
  {$endif}


  type
    TBufferedStream = class;
    TBufferedStreamReader = class;
    TBufferedStreamWriter = class;

    EBufferedStream = class(Exception);


    IStreamBase = interface
    ['{E7B89208-5C2C-4330-B12C-19540F05A5A8}']
      function get_Position: Int64;
      procedure set_Position(aValue: Int64);

      procedure Rewind(aBytes: Int64);
      function Seek(const aOffset: Int64; aOrigin: TSeekOrigin = soBeginning): Int64;
      procedure Skip(aBytes: Int64);

      property Position: Int64 read get_Position write set_Position;
    end;


    IStream = interface(IStreamBase)
    ['{6B4A0BFA-D1A4-4BFA-9DF1-3B741848607C}']
      function Read(var aBuffer; aCount: Integer): Integer;
      function Write(const aBuffer; aCount: Integer): Integer;
    end;


    IBufferedStreamReader = interface(IStreamBase)
    ['{8E65DAC5-24DF-4D1C-B070-58F0C459952B}']
      function get_EOF: Boolean;
      function get_Remaining: Int64;
      function get_Size: Int64;

      function Read(var aBuffer; aCount: Integer): Integer;
      function ReadInto(const aStream: TStream; aCount: Integer): Integer;

      property EOF: Boolean read get_EOF;
      property Remaining: Int64 read get_Remaining;
      property Size: Int64 read get_Size;
    end;


    IBufferedStreamWriter = interface(IStreamBase)
    ['{8B92CCF9-F963-4512-AAEB-B2A7DD9EE8B8}']
      function CopyFrom(const aStream: TStream; aCount: Integer): Integer;
      function Write(const aBuffer; aCount: Integer): Integer;
      function Rewrite(aOffset: Int64; const aBuffer; aCount: Integer): Integer;
    end;


    TBufferedStream = class(TStreamDecorator, IUnknown)
    private
      fRefCount: Integer;
      function QueryInterface(const aIID: TGUID; out aObj): HResult; stdcall;
      function _AddRef: Integer; stdcall;
      function _Release: Integer; stdcall;
    protected
      fBuffer: PByte;
      fBufCurr: PByte;
      fBufSize: Integer;
      fBufStartPos: Int64;
    protected
      function get_Position: Int64; virtual;
      procedure set_Position(aValue: Int64);
      function GetSize: Int64; override;
      procedure SetSize(const aValue: Int64); override;
      constructor Create(const aStream: TStream; const aBufSize: Integer);
    public
      class function CreateReader(const aStream: TStream;
                                  const aBufSize: Integer = 4096): IBufferedStreamReader;
      class function CreateWriter(const aStream: TStream;
                                  const aBufSize: Integer = 4096): IBufferedStreamWriter;
      destructor Destroy; override;
      procedure Rewind(aBytes: Int64);
      function Seek(const aOffset: Int64; aOrigin: TSeekOrigin): Int64; override;
      procedure Skip(aBytes: Int64);

      property Position: Int64 read get_Position write set_Position;
    end;


    TBufferedStreamReader = class(TBufferedStream, IBufferedStreamReader)
    private
      fBufEnd: PByte;
      function FillBuffer: Integer; {$if CompilerVersion > 18} inline; {$ifend}
    protected
      function get_EOF: Boolean;
      function get_Remaining: Int64;
      function get_Size: Int64;
      procedure AcquireStream(const aStream: TStream; const aIsOwn: Boolean); override;
      procedure ResetBuffer;
    public
      constructor Create(const aStream: TStream; const aBufSize: Integer);
      function Read(var aBuffer; aCount: Integer): Integer; override;
      function ReadInto(const aStream: TStream; aCount: Integer): Integer;
      function Seek(const aOffset: Int64; aOrigin: TSeekOrigin): Int64; override;
      function Write(const aBuffer; aCount: Integer): Integer; override;
    end;


    TBufferedStreamWriter = class(TBufferedStream, IBufferedStreamWriter)
    protected
      procedure AcquireStream(const aStream: TStream; const aIsOwn: Boolean); override;
      function GetSize: Int64; override;
    public
      constructor Create(const aStream: TStream; const aBufSize: Integer);
      destructor Destroy; override;
      function CopyFrom(const aStream: TStream; aCount: Integer): Integer;
      procedure Flush; {$if CompilerVersion > 18} inline; {$ifend}
      function Read(var aBuffer; aCount: Integer): Integer; override;
      function Rewrite(aOffset: Int64; const aBuffer; aCount: Integer): Integer;
      function Seek(const aOffset: Int64; aOrigin: TSeekOrigin): Int64; override;
      function Write(const aBuffer; aCount: Integer): Integer; override;
    end;


    TReadMemoryStream = class(TCustomMemoryStream)
    public
      constructor Create; overload;
      constructor Create(const aBase: Pointer; const aBytes: Int64); overload;
      procedure Overlay(const aBase: Pointer; const aBytes: Int64); overload;
      function Write(const Buffer; Count: Longint): Longint; override;
    end;


    IStreamPositionMemento = interface(IMemento)
    ['{33F5550E-47E1-492B-8CCE-9254F7389FB4}']
      function get_Position: Int64;
      procedure set_Position(const aValue: Int64);
      property Position: Int64 read get_Position write set_Position;
    end;


  function StreamPositionMemento(const aStream: TStream): IStreamPositionMemento;




implementation

  uses
  { vcl: }
  {$ifdef DELPHI2009__}
    Character,
  {$endif}
    Math,
    TypInfo,
    Windows,
  { deltics: }
    Deltics.SysUtils;



  procedure ByteMove(const Source; var Dest; Count: Integer); overload;
{$ifdef WIN64}
  begin
    CopyMemory(@Dest, @Source, Count);
  end;
{$else}
  asm
                      // ECX = Count
                      // EAX = Const Source
                      // EDX = Var Dest
                      // If there are no bytes to copy, just quit
                      // altogether; there's no point pushing registers.
    Cmp   ECX,0
    Je    @JustQuit
                      // Preserve the critical Delphi registers.
    push  ESI
    push  EDI
                      // Move Source into ESI (SOURCE register).
                      // Move Dest into EDI (DEST register).
                      // This might not actually be necessary, as I'm not using MOVsb etc.
                      // I might be able to just use EAX and EDX;
                      // there could be a penalty for not using ESI, EDI, but I doubt it.
                      // This is another thing worth trying!
    Mov   ESI, EAX
    Mov   EDI, EDX
                      // The following loop is the same as repNZ MovSB, but oddly quicker!
  @Loop:
    Mov   AL, [ESI]   // get a source byte
    Inc   ESI         // bump source address
    Mov   [EDI], AL   // Put it into the destination
    Inc   EDI         // bump destination address
    Dec   ECX         // Dec ECX to note how many we have left to copy
    Jnz   @Loop       // If ECX <> 0, then loop.
                      // Pop the critical Delphi registers that we've altered.
    pop   EDI
    pop   ESI
  @JustQuit:
  end;
{$endif}

  procedure ByteMove(const Source; var Dest; Offset: Integer; Count: Integer); overload;
  var
    destBytes: PByte;
  begin
    destBytes := PByte(Int64(@Dest) + Offset);
    ByteMove(Source, destBytes^, Count);
  end;



{$ifdef __DELPHI2007}
  constructor TStringStream.Create;
  begin
    inherited Create('');
  end;


  procedure TStringStream.SaveToFile(const aFilename: String);
  var
    s: String;
    strm: TStream;
  begin
    strm := TFileStream.Create(aFileName, fmCreate);
    try
      s := DataString;
      strm.Write(s[1], Length(s) * SizeOf(Char));

    finally
      strm.Free;
    end;
  end;
{$endif __DELPHI2007}



{ TStreamDecorator ------------------------------------------------------------------------------- }

  constructor TStreamDecorator.Create(const aStream: TStream);
  begin
    inherited Create;

    AcquireStream(aStream, FALSE);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  destructor TStreamDecorator.Destroy;
  begin
    ReleaseStream;

    inherited;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TStreamDecorator.get_EOF: Boolean;
  begin
    result := (Position = Size);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TStreamDecorator.AcquireStream(const aStream: TStream;
                                           const aIsOwn: Boolean);
  begin
    if Assigned(fStream) then
      ReleaseStream;

    fStream := aStream;

    fOwnsStream := aIsOwn and Assigned(fStream);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TStreamDecorator.GetSize: Int64;
  begin
    result := Stream.Size;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TStreamDecorator.GetStream: TStream;
  begin
    result := fStream;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TStreamDecorator.Read(var aBuffer; aCount: Integer): Integer;
  begin
    result := Stream.Read(aBuffer, aCount);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TStreamDecorator.ReleaseStream;
  begin
    if fOwnsStream then
      fStream.Free;

    fStream := NIL;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TStreamDecorator.Seek(const aOffset: Int64; aOrigin: TSeekOrigin): Int64;
  begin
    result := Stream.Seek(aOffset, aOrigin);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TStreamDecorator.SetSize(const aValue: Int64);
  begin
    Stream.Size:= aValue;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TStreamDecorator.Write(const aBuffer; aCount: Integer): Integer;
  begin
    result := Stream.Write(aBuffer, aCount);
  end;








{ TBufferedStream -------------------------------------------------------------------------------- }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function TBufferedStream.CreateReader(const aStream: TStream;
                                              const aBufSize: Integer): IBufferedStreamReader;
  begin
    result := TBufferedStreamReader.Create(aStream, aBufSize) as IBufferedStreamReader;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function TBufferedStream.CreateWriter(const aStream: TStream;
                                              const aBufSize: Integer): IBufferedStreamWriter;
  begin
    result := TBufferedStreamWriter.Create(aStream, aBufSize) as IBufferedStreamWriter;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TBufferedStream.Create(const aStream: TStream;
                                     const aBufSize: Integer);
  begin
    GetMem(fBuffer, aBufSize);
    fBufSize := aBufSize;

    inherited Create(aStream);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  destructor TBufferedStream.Destroy;
  begin
    FreeMem(fBuffer);

    inherited;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TBufferedStream.QueryInterface(const aIID: TGUID; out aObj): HResult;
  begin
    if GetInterface(aIID, aObj) then
      result := 0
    else
      result := E_NOINTERFACE;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TBufferedStream._AddRef: Integer;
  begin
    result := InterlockedIncrement(fRefCount);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TBufferedStream._Release: Integer;
  begin
    result := InterlockedDecrement(fRefCount);

    if (fRefCount = 0) then
      Free;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TBufferedStream.GetSize: Int64;
  begin
    result := fStream.Size;
  end;


  function TBufferedStream.get_Position: Int64;
  begin
    result := fBufStartPos + (Int64(fBufCurr) - Int64(fBuffer));
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TBufferedStream.set_Position(aValue: Int64);
  begin
    Seek(aValue, soBeginning);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TBufferedStream.Rewind(aBytes: Int64);
  begin
    Seek(-aBytes, soCurrent);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TBufferedStream.Seek(const aOffset: Int64; aOrigin: TSeekOrigin): Int64;
  resourcestring
    rsfSeekNotSupported = 'Seek operations are not supported by %s';
  begin
    raise EBufferedStream.CreateFmt(rsfSeekNotSupported, [ClassName]);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TBufferedStream.Skip(aBytes: Int64);
  begin
    Seek(aBytes, soCurrent);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TBufferedStream.SetSize(const aValue: Int64);
  begin
    fStream.Size := aValue;
  end;









{ TBufferedStreamReader -------------------------------------------------------------------------- }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TBufferedStreamReader.AcquireStream(const aStream: TStream;
                                                const aIsOwn: Boolean);
  begin
    inherited;
    FillBuffer;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TBufferedStreamReader.ResetBuffer;
  begin
    fBufCurr  := fBuffer;
    fBufEnd   := fBuffer;

    // Next read will start from current stream position

    fBufStartPos := fStream.Position;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TBufferedStreamReader.Create(const aStream: TStream;
                                           const aBufSize: Integer);
  begin
    inherited;
  end;


  function TBufferedStreamReader.FillBuffer: Integer;
  begin
    fBufStartPos  := fStream.Position;

    result := fStream.Read(fBuffer^, fBufSize);

    fBufEnd   := PByte(Integer(fBuffer) + result);
    fBufCurr  := fBuffer;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TBufferedStreamReader.get_EOF: Boolean;
  begin
    result := (fBufCurr = fBufEnd) and (fStream.Position = fStream.Size);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TBufferedStreamReader.get_Remaining: Int64;
  begin
    result := Stream.Size - Position;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TBufferedStreamReader.get_Size: Int64;
  begin
    result := Stream.Size;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TBufferedStreamReader.Read(var aBuffer; aCount: Integer): Integer;
  var
    bufferedBytes: Integer;
  begin
    result := 0;

    if (fBufCurr = fBufEnd) then
      if (FillBuffer = 0) then
        EXIT;

    bufferedBytes := Integer(fBufEnd) - Integer(fBufCurr);

    if (aCount >= bufferedBytes) then
    begin
      ByteMove(fBufCurr^, aBuffer, bufferedBytes);
      Dec(aCount, bufferedBytes);

      result := bufferedBytes;

      if aCount > 0 then
        result := result + fStream.Read(PByte(Int64(@aBuffer) + bufferedBytes)^, aCount);

      ResetBuffer;
    end
    else
    begin
      ByteMove(fBufCurr^, aBuffer, aCount);

      Inc(fBufCurr, aCount);
      result := aCount;
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TBufferedStreamReader.ReadInto(const aStream: TStream;
                                                aCount: Integer): Integer;
  const
    MAX_BYTES = 64 * 1024;
  var
    dest: TMemoryStream absolute aStream;
    buf: array[1..MAX_BYTES] of Byte;
    cnt: Integer;
    buffered: Integer;
    writer: IBufferedStreamWriter;
  begin
    if aStream is TMemoryStream then
    begin
      dest.Size := dest.Size + aCount;

      buffered := Int64(fBufEnd) - Int64(fBufCurr);
      if buffered > 0 then
      begin
        ByteMove(fBufCurr^, ByteOffset(dest.Memory, dest.Position)^, buffered);
        ResetBuffer;

        Dec(aCount, buffered);
      end;

      result := buffered + fStream.Read(PByte(Int64(dest.Memory) + dest.Position + buffered)^, aCount);

      fBufStartPos := fStream.Position;
    end
    else
    begin
      result := 0;
      writer := TBufferedStream.CreateWriter(aStream);

      repeat
        cnt := Read(buf, MAX_BYTES);
        writer.Write(buf, cnt);

        Inc(result, cnt);
      until cnt = 0;
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TBufferedStreamReader.Seek(const aOffset: Int64;
                                            aOrigin: TSeekOrigin): Int64;
  var
    newPos: Int64;
  begin
    case aOrigin of
      soBeginning : newPos := aOffset;
      soCurrent   : newPos := Position + aOffset;
      soEnd       : newPos := Size - aOffset;
    else
      newPos := Position;
    end;

    result := newPos;

    if newPos = Position then
      EXIT;

    if (newPos < fBufStartPos) or (newPos >= fBufStartPos + fBufSize) then
    begin
      fStream.Seek(newPos, soBeginning);
      Resetbuffer;
    end
    else
      fBufCurr := PByte(Int64(fBuffer) + (newPos - fBufStartPos));
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TBufferedStreamReader.Write(const aBuffer; aCount: Integer): Integer;
  resourcestring
    rsfWriteNotSupported = 'Write operations are not supported by %s';
  begin
    raise EBufferedStream.CreateFmt(rsfWriteNotSupported, [ClassName]);
  end;








{ TBufferedStreamWriter -------------------------------------------------------------------------- }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TBufferedStreamWriter.AcquireStream(const aStream: TStream;
                                                const aIsOwn: Boolean);
  begin
    inherited;
    fBufCurr := fBuffer;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TBufferedStreamWriter.Create(const aStream: TStream; const aBufSize: Integer);
  begin
    inherited;
  end;


  destructor TBufferedStreamWriter.Destroy;
  begin
    Flush;

    inherited;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TBufferedStreamWriter.Flush;
  begin
    if (fBufCurr = fBuffer) then  // Nothing to write
      EXIT;

    fStream.Write(fBuffer^, Integer(fBufCurr) - Integer(fBuffer));
    fBufCurr := fBuffer;

    fBufStartPos := fStream.Position;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TBufferedStreamWriter.GetSize: Int64;
  begin
    result := fStream.Size;
    if (fStream.Position = fStream.Size) then
      Inc(result, Integer(fBufCurr) - Integer(fBuffer));
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TBufferedStreamWriter.CopyFrom(const aStream: TStream;
                                                aCount: Integer): Integer;
  begin
    Flush;

    result := aCount;

    while aCount > fBufSize do
    begin
      Inc(fBufCurr, aStream.Read(fBuffer^, fBufSize));
      Flush;

      Dec(aCount, fBufSize);
    end;

    if aCount > 0 then
      Inc(fBufCurr, aStream.Read(fBuffer^, aCount));
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TBufferedStreamWriter.Read(var aBuffer; aCount: Integer): Integer;
  resourcestring
    rsfReadNotSupported = 'Read operations are not supported by %s';
  begin
    raise EBufferedStream.CreateFmt(rsfReadNotSupported, [ClassName]);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TBufferedStreamWriter.Rewrite(aOffset: Int64; const aBuffer; aCount: Integer): Integer;
  begin
    // TODO: Optimise for cases where aOffset is within the current write buffer

    // For now, we simply ensure that any pending writes are flushed before re-writing
    //  directly using the stream itself.  The next Write operation will resume
    //  employing the buffer.

    Flush;

    fStream.Position := aOffset;
    fStream.Write(aBuffer, aCount);
    fStream.Position := fStream.Size;

    fBufStartPos := fStream.Position;

    result := aCount;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TBufferedStreamWriter.Seek(const aOffset: Int64;
                                            aOrigin: TSeekOrigin): Int64;
  begin
    Flush;
    fStream.Seek(aOffset, aOrigin);

    fBufStartPos := fStream.Position;

    result := Position;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TBufferedStreamWriter.Write(const aBuffer; aCount: Integer): Integer;
  begin
    result := aCount;

    if (aCount = 0) then
      EXIT;

    // If we're writing more than will fit into the buffer then flush the
    //  current buffer and write directly to the stream.

    if (aCount >= fBufSize) then
    begin
      Flush;
      result := fStream.Write(aBuffer, aCount);
      EXIT;
    end;

    // If what we are writing will overflow the buffer then flush the buffer then
    //  replace the buffer with what we were asked to write.

    if (aCount >= (fBufSize - (Integer(fBufCurr) - Integer(fBuffer)))) then
      Flush;

    ByteMove(aBuffer, fBufCurr^, aCount);
    Inc(fBufCurr, aCount);
  end;







{ TStreamMemento --------------------------------------------------------------------------------- }

  type
    TStreamPositionMemento = class(TMemento, IStreamPositionMemento)
    private
      fStream: TStream;
      fPosition: Int64;
    protected
      constructor Create(const aStream: TStream);
      procedure DoRecall; override;
    { IStreamMemento - - - - - - - - - - - - - - - - - - - - }
    private
      function get_Position: Int64;
      procedure set_Position(const aValue: Int64);
    end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TStreamPositionMemento.Create(const aStream: TStream);
  begin
    inherited Create;

    fStream   := aStream;
    fPosition := fStream.Position;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TStreamPositionMemento.get_Position: Int64;
  begin
    result := fPosition;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TStreamPositionMemento.set_Position(const aValue: Int64);
  begin
    fPosition := aValue;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TStreamPositionMemento.DoRecall;
  begin
    fStream.Position := fPosition;
  end;



{ StreamPositionMemento factory ------------------------------------------------------------------ }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function StreamPositionMemento(const aStream: TStream): IStreamPositionMemento;
  begin
    result := TStreamPositionMemento.Create(aStream);
  end;







{ TReadMemoryStream }

  constructor TReadMemoryStream.Create;
  begin
    inherited Create;
  end;


  constructor TReadMemoryStream.Create(const aBase: Pointer; const aBytes: Int64);
  begin
    inherited Create;
    SetPointer(aBase, aBytes);
    Position := 0;
  end;


  procedure TReadMemoryStream.Overlay(const aBase: Pointer; const aBytes: Int64);
  begin
    SetPointer(aBase, aBytes);
    Position := 0;
  end;

  function TReadMemoryStream.Write(const Buffer; Count: Integer): Longint;
  begin
    raise Exception.Create('Cannot write to a TReadMemoryStream');
  end;







end.
