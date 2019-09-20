
  unit Test.Strings.STR;

{$i deltics.inc}

interface

  uses
    Deltics.Smoketest;


  type
    TSTRTests = class(TTestCase)
    published
      procedure Runtime;
      procedure Alloc;
      procedure Transcoding;
    end;




implementation

  uses
    Math,
    Windows,
    Deltics.Contracts,
    Deltics.Strings,
    Deltics.Strings.ANSI,
    Deltics.Strings.WIDE,
    Test.Strings;


{ TSTRTests -------------------------------------------------------------------------------------- }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TSTRTests.Runtime;
  begin
  {$ifdef __DELPHI2007}
    Note('Delphi 2007 and earlier');

    {$ifdef UNICODE}
      Test('UNICODE NOT defined!').Expect(TRUE).IsFALSE;
    {$else}
      Test('UNICODE NOT defined!').Expect(TRUE).IsTRUE;
    {$endif}

    Test('STR is ANSI!').Expect(STR.InheritsFrom(Deltics.Strings.ANSI.ANSIFn)).IsTRUE;
    Test('BytesPerChar').Expect(BytesPerChar).Equals(1);
  {$endif}
  {$ifdef DELPHI2009__}
    Note('Delphi 2009 and later');

    {$ifdef UNICODE}
      Test('UNICODE defined!').Expect(TRUE).IsTRUE;
    {$else}
      Test('UNICODE defined!').Expect(TRUE).IsFALSE;
    {$endif}

    Test('STR is WIDE!').Expect(STR.InheritsFrom(Deltics.Strings.WIDE.WIDEFn)).IsTRUE;
    Test('BytesPerChar').Expect(BytesPerChar).Equals(2);
  {$endif}
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TSTRTests.Alloc;
  var
    p: Pointer;
    pSTR: PChar absolute p;
    pANSI: PANSIChar absolute p;
    pWIDE: PWIDEChar absolute p;
    pUTF8: PUTF8Char absolute p;
  begin
    pANSI := STR.AllocANSI(SRCS);

    Test('STR.AllocANSI result').Expect(p).IsAssigned;
    Test('STR.AllocANSI buffer length').Expect(ANSI.Len(pANSI)).Equals(Length(SRCA));
    Test('STR.AllocANSI buffer content').Expect(p).Equals(PANSIString(SRCA), Length(SRCA));

    FreeMem(pANSI);

    pWIDE := STR.AllocWIDE(SRCS);

    Test('STR.AllocWIDE result').Expect(p).IsAssigned;
    Test('STR.AllocWIDE buffer length').Expect(WIDE.Len(pWIDE)).Equals(Length(SRCW));
    Test('STR.AllocWIDE buffer content').Expect(p).Equals(PWIDEString(SRCW), Length(SRCW) * 2);

    FreeMem(pWIDE);

    pUTF8 := STR.AllocUTF8(SRCS);

    Test('STR.AllocUTF8 result').Expect(p).IsAssigned;
    Test('STR.AllocUTF8 buffer length').Expect(UTF8.Len(pUTF8)).Equals(Length(SRCU));
    Test('STR.AllocUTF8 buffer content').Expect(p).Equals(PUTF8String(SRCU), Length(SRCU));

    FreeMem(pUTF8);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TSTRTests.Transcoding;
  begin
    Test('FromANSI!').Expect(STR.FromANSI(SRCA)).Equals(SRCS);

    Test('FromUTF8(string)!').Expect(STR.FromUTF8(SRCU)).Equals(SRCS);
    Test('FromUTF8(buffer)!').Expect(STR.FromUTF8(PUTF8Char(SRCU))).Equals(SRCS);

    Test('FromWIDE(string)!').Expect(STR.FromWIDE(SRCW)).Equals(SRCS);
    Test('FromWIDE(buffer)!').Expect(STR.FromWIDE(PWIDEChar(SRCW))).Equals(SRCS);
  end;







end.
