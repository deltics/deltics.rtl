
  unit Test.JSON.RFC7159;

interface

  uses
    Deltics.Smoketest;


  type
    TRFC7159 = class(TTestCase)
    private
      procedure ProcessFiles(aPattern: String);
    published
      procedure Indeterminate;
      procedure InvalidJSON;
      procedure ValidJSON;
    end;


implementation

  uses
    Classes,
    SysUtils,
    Deltics.JSON,
    Deltics.FileSystem.FileList,
    Deltics.Strings,
    Deltics.Unicode,
    Test.JSON;


{ TRFC7159 }



  procedure TRFC7159.ProcessFiles(aPattern: String);
  var
    i: Integer;
    files: TFileList;
    filename: String;
    strm: TFileStream;
    testType: Char;
    jv: TJSONValue;
    path: String;
  begin
    path := 'z:\dropbox\dev\src\delphi\libs\libs.dev\+tests\rtl';
//    path := 'x:\dropbox\dev\src\delphi\libs\libs.dev\+tests\rtl';

    files := TFileList.Create(path + '\rfc7159', aPattern);
    try
      for i := 0 to Pred(files.Count) do
      begin
        testType := files[i][1];
        filename := path + '\rfc7159\' + files[i];

        if files[i] = 'n_structure_open_array_object.json' then continue;
        //asm int 3 end;

        strm := TFileStream.Create(filename, fmOpenRead);
        try
          case testType of
            'i' : begin
                    try
                      jv := JSON.ReadValue(strm);
                      try
                        Test(files[i]).Passed('without error');

                      finally
                        jv.Free;
                      end;

                    except
                      on e: Exception do
                        Test(files[i]).Passed('with exception: ' + e.Message);
                    end;
                  end;

            'n' : begin
                    try
                      jv := JSON.ReadValue(strm);
                      try
                        Test(files[i]).Failed('Should have failed/crashed');

                      finally
                        jv.Free;
                      end;

                    except
                      on e: EAccessViolation do
                        Test(files[i]).Failed(e.Message);

                      on e: Exception do
                        Test(files[i]).Passed(' failed (as expected) with error: ' + e.Message);
                    end;
                  end;

            'y' : begin
                    try
                      jv := JSON.ReadValue(strm);
                      try
                        Test(files[i]).Passed;

                      finally
                        jv.Free;
                      end;

                    except
                      on e: Exception do
                        Test(files[i]).Failed(e.Message);
                    end;
                  end;
          end;

        finally
          strm.Free;
        end;
      end;

    finally
      files.Free;
    end;
  end;






  procedure TRFC7159.Indeterminate;
  begin
    ProcessFiles('i*.json');
  end;


  procedure TRFC7159.InvalidJSON;
  begin
    ProcessFiles('n*.json');
  end;


  procedure TRFC7159.ValidJSON;
  begin
    ProcessFiles('y*.json');
  end;










initialization
  Smoketest.Add(TJsonTests, [TRFC7159]);
end.
