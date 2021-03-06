{
  * MIT LICENSE *

  Copyright � 2008 Jolyon Smith

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

  Original author : Jolyon Direnko-Smith
  e-mail          : jsmith@deltics.co.nz
  github          : deltics/deltics.rtl
}

{$i deltics.rtl.inc}

{$ifdef debugDelticsSysUtils}
  {$debuginfo ON}
{$endif}

  unit Deltics.SysUtils;


interface

  uses
  { vcl: }
    Classes,
    SysUtils,
  { deltics: }
    Deltics.Exceptions,
    Deltics.Types;


  const
    EmptyStr: String = '';


  type
    IAutoFree = interface
    ['{9C3B2944-EA08-4301-A6E1-C0EB94D54771}']
      procedure Add(const aReferences: array of PObject); overload;
      procedure Add(const aObjects: array of TObject); overload;
    end;


  // TODO: Move to a VCL namespace
    TComponentProc = procedure(const aComponent: TComponent);
    TFilterFn = function(const aValue): Boolean;


  procedure CloneList(const aSource: TList; const aDest: TList);
  procedure FilterList(const aSource: TList; const aDest: TList; const aFilter: TFilterFn);

  function AutoFree(const aReference: PObject): IUnknown; overload;
  function AutoFree(const aReferences: array of PObject): IUnknown; overload;

  procedure FreeAndNIL(var aObject); overload;
  procedure FreeAndNIL(var aPointer; const aSize: Cardinal); overload;
  procedure FreeAndNIL(const aObjects: array of PObject); overload;
  procedure NILRefs(const aObjects: array of PObject);

  function IfThen(aValue: Boolean; aTrue, aFalse: Boolean): Boolean; overload;
  function IfThen(aValue: Boolean; aTrue, aFalse: TObject): TObject; overload;
  function IfThen(aValue: Boolean; aTrue, aFalse: Integer): Integer; overload;

  function StringIndex(const aString: String; const aCases: array of String): Integer;
  function TextIndex(const aString: String; const aCases: array of String): Integer;

  procedure Exchange(var A, B; aSize: LongWord = 4); overload;
{$ifdef UNICODE}
  procedure Exchange(var A, B: AnsiString); overload;
  procedure Exchange(var A, B: UnicodeString); overload;
{$else}
  procedure Exchange(var A, B: String); overload;
{$endif}
  procedure Exchange(var A, B: WideString); overload;

  procedure AddTrailingBackslash(var aString: String);
  procedure RemoveTrailingBackslash(var aString: String);

  // TODO: Move to a VCL namespace
  procedure ForEachComponent(const aComponent: TComponent;
                             const aProc: TComponentProc;
                             const aRecursive: Boolean = TRUE;
                             const aClass: TComponentClass = NIL);




implementation

  uses
  { vcl: }
    Contnrs,
    Math,
    Windows,
  { deltics: }
    Deltics.Classes;



{ ------------------------------------------------------------------------------------------------ }

  type
    TAutoFree = class(TComInterfacedObject, IAutoFree)
    private
      fObjects: TObjectList;
      fReferences: TList;
    public
      constructor Create; overload;
      constructor Create(const aObjects: array of TObject); overload;
      constructor CreateByRef(const aReferences: array of PObject;
                              const aInitialise: Boolean);
      destructor Destroy; override;
      procedure Add(const aReferences: array of PObject); overload;
      procedure Add(const aObjects: array of TObject); overload;
    end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TAutoFree.Create;
  begin
    inherited Create;

    fObjects    := TObjectList.Create(TRUE);
    fReferences := TList.Create;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TAutoFree.CreateByRef(const aReferences: array of PObject;
                                    const aInitialise: Boolean);
  var
    i: Integer;
  begin
    Create;

    Add(aReferences);

    if aInitialise then
      for i := 0 to Pred(fReferences.Count) do
        Pointer(fReferences[i]^) := NIL;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TAutoFree.Create(const aObjects: array of TObject);
  begin
    Create;

    Add(aObjects);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  destructor TAutoFree.Destroy;
  var
    i: Integer;
  begin
    for i := 0 to Pred(fReferences.Count) do
      FreeAndNIL(fReferences[i]^);

    FreeAndNIL(fReferences);
    FreeAndNIL(fObjects);

    inherited;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TAutoFree.Add(const aReferences: array of PObject);
  var
    i: Integer;
  begin
    for i := 0 to Pred(Length(aReferences)) do
      if (fReferences.IndexOf(aReferences[i]) = -1) then
        fReferences.Add(aReferences[i]);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TAutoFree.Add(const aObjects: array of TObject);
  var
    i: Integer;
  begin
    for i := 0 to Pred(Length(aObjects)) do
      if Assigned(aObjects[i]) and (fObjects.IndexOf(aObjects[i]) = -1) then
        fObjects.Add(aObjects[i]);
  end;







{ ------------------------------------------------------------------------------------------------ }



  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure CloneList(const aSource: TList; const aDest: TList);
  begin
    aDest.Count := aSource.Count;
    Move(PByte(aSource.List)^, PByte(aDest.List)^, (aSource.Count * sizeof(Pointer)));
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure FilterList(const aSource: TList;
                       const aDest: TList;
                       const aFilter: TFilterFn);
  var
    i: Integer;
    item: Pointer;
  begin
    aDest.Clear;
    aDest.Capacity := aSource.Count;

    if aSource.Count = 0 then
      EXIT;

    for i := 0 to Pred(aSource.Count) do
    begin
      item := aSource[i];
      if aFilter(item) then
        aDest.Add(item);
    end;

    aDest.Capacity := aDest.Count;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function AutoFree(const aReference: PObject): IUnknown;
  begin
    result := TAutoFree.CreateByRef([aReference], FALSE);
  end;

  function AutoFree(const aReferences: array of PObject): IUnknown;
  begin
    result := TAutoFree.CreateByRef(aReferences, FALSE);
  end;



  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure FreeAndNIL(var aObject); overload;
  begin
    SysUtils.FreeAndNIL(aObject);
  end;

  procedure FreeAndNIL(var aPointer; const aSize: Cardinal); overload;
  var
    ptr: Pointer;
  begin
    ptr := Pointer(aPointer);

    if NOT Assigned(ptr) then
      EXIT;

    Pointer(aPointer) := NIL;

    FreeMem(ptr, aSize);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure FreeAndNIL(const aObjects: array of PObject); overload;
  var
    i: Integer;
    obj: TObject;
    {$ifopt C+}
    errs: Integer;
    errMsg: String;
    {$endif}
  begin
    {$ifopt C+}errs := 0;{$endif}

    for i := Low(aObjects) to High(aObjects) do
    begin
      try
        obj := aObjects[i]^;
        aObjects[i]^ := NIL;
        obj.Free;
      except
        {$ifopt C+}
        on E: Exception do
        begin
          Inc(errs);
          errMsg := errMsg + Format('Object #%d : %s', [i, e.Message + #13]);

        end;
        {$endif}
      end;
    end;

    {$ifopt C+}
    if (errs > 0) then
      raise Exception.CreateFmt('%d of %d objects when free''d caused an exception:'#13#13'%s',
                                [errs, High(aObjects), errMsg]);
    {$endif}
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure NILRefs(const aObjects: array of PObject);
  var
    i: Integer;
  begin
    for i := Low(aObjects) to High(aObjects) do
      aObjects[i]^ := NIL;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function IfThen(aValue: Boolean; aTrue, aFalse: Boolean): Boolean;
  begin
    if aValue then
      result := aTrue
    else
      result := aFalse;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function IfThen(aValue: Boolean; aTrue, aFalse: Integer): Integer;
  begin
    if aValue then
      result := aTrue
    else
      result := aFalse;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function IfThen(aValue: Boolean; aTrue, aFalse: TObject): TObject;
  begin
    if aValue then
      result := aTrue
    else
      result := aFalse;
  end;




  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure Exchange(var A, B; aSize: LongWord);
  var
    a8: Byte absolute A;
    b8: Byte absolute B;
    a16: Word absolute A;
    b16: Word absolute B;
    a32: LongWord absolute A;
    b32: LongWord absolute B;
    a64: Int64 absolute A;
    b64: Int64 absolute B;
    aE: Extended absolute A;
    bE: Extended absolute B;
    i8: Byte;
    i16: Word;
    i32: LongWord;
    i64: Int64;
  {$ifNdef WIN64}
    iE: Extended;
  {$endif}
    ap8: PByte;
    bp8: PByte;
  begin
    case aSize of
      sizeof(Byte)      : begin
                            i8 := a8;
                            a8 := b8;
                            b8 := i8;
                          end;

      sizeof(Word)      : begin
                            i16 := a16;
                            a16 := b16;
                            b16 := i16;
                          end;

      sizeof(LongWord)  : begin
                            i32 := a32;
                            a32 := b32;
                            b32 := i32;
                          end;

      sizeof(Int64)     : begin
                            i64 := a64;
                            a64 := b64;
                            b64 := i64;
                          end;

    {$ifNdef WIN64} // Extended is an alias for "Double" on Win64 and thus 8-bytes, not 10 as on Win32
      sizeof(Extended)  : begin
                            iE := aE;
                            aE := bE;
                            bE := iE;
                          end;
    {$endif}
    else
      ap8 := PByte(@A);
      bp8 := PByte(@B);
      i32 := aSize;
      while (i32 > 0) do
      begin
        i8   := ap8^;
        ap8^ := bp8^;
        bp8^ := i8;
        Inc(ap8);
        Inc(bp8);
        Dec(i32);
      end;
    end;
  end;


{$ifdef UNICODE}

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure Exchange(var A, B: UnicodeString);
  var
    T: UnicodeString;
  begin
    T := A;
    A := B;
    B := T;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure Exchange(var A, B: AnsiString);
  var
    T: AnsiString;
  begin
    T := A;
    A := B;
    B := T;
  end;

{$else}

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure Exchange(var A, B: String);
  var
    T: String;
  begin
    T := A;
    A := B;
    B := T;
  end;

{$endif}

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure Exchange(var A, B: WideString);
  var
    T: WideString;
  begin
    T := A;
    A := B;
    B := T;
  end;



  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure AddTrailingBackslash(var aString: String);
  var
    len: Integer;
  begin
    len := Length(aString);
    case len of
      0: { NO-OP };
    else
      case aString[len] of
        '\': { NO-OP };
      else
        aString := aString + '\';
      end;
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure RemoveTrailingBackslash(var aString: String);
  var
    len: Integer;
  begin
    len := Length(aString);
    case len of
      0: { NO-OP };
    else
      case aString[len] of
        '\': SetLength(aString, len - 1);
      else
        { NO-OP }
      end;
    end;
  end;






  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure ForEachComponent(const aComponent: TComponent;
                             const aProc: TComponentProc;
                             const aRecursive: Boolean;
                             const aClass: TComponentClass);
  var
    i: Integer;
    comp: TComponent;
  begin
    for i := 0 to Pred(aComponent.ComponentCount) do
    begin
      comp := aComponent.Components[i];

      if NOT Assigned(aClass) or comp.InheritsFrom(aClass) then
        aProc(comp);

      if aRecursive then
        ForEachComponent(comp, aProc, TRUE, aClass);
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function StringIndex(const aString: String;
                       const aCases: array of String): Integer;
  begin
    for result := 0 to Pred(Length(aCases)) do
      if ANSISameText(aString, aCases[result]) then
        EXIT;

    result := -1;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TextIndex(const aString: String;
                     const aCases: array of String): Integer;
  begin
    for result := 0 to Pred(Length(aCases)) do
      if ANSISameStr(aString, aCases[result]) then
        EXIT;

    result := -1;
  end;




end.
