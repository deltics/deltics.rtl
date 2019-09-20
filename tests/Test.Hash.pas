

  unit Test.Hash;


interface

  uses
    Deltics.Smoketest;

  type
    TCodecTests = class(TTestCase)
      procedure Base64;
    end;


    THashTests = class(TTestCase)
      procedure CRC32;
      procedure MD5;
      procedure WinDiff;
    end;



implementation

  uses
    Deltics.Crypto,
    Deltics.Strings;



{ TCodecTests }

  procedure TCodecTests.Base64;
  begin
    Test('Base64.Encode(''Base64'')').Expect(Deltics.Crypto.Base64.Encode(ANSI('Base64'))).Equals('QmFzZTY0');
    Test('Base64.Decode(''QmFzZTY0'')').Expect(Deltics.Crypto.Base64.Decode(ANSI('QmFzZTY0'))).Equals('Base64');
  end;





{ THashTests }

  procedure THashTests.CRC32;
  begin

  end;


  procedure THashTests.MD5;
  begin
    Test('MD5.Hash(''MD5'')').Expect(Deltics.Crypto.MD5.Hash(ANSI('MD5')).Hex).Equals('7f138a09169b250e9dcb378140907378');
  end;


  procedure THashTests.WinDiff;
  begin

  end;



initialization
  Smoketest.Add([TCodecTests, THashTests]);

end.
