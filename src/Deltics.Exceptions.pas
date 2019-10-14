
  unit Deltics.Exceptions;

{$i deltics.rtl.inc}

interface

  uses
    SysUtils;


  type
    Exception = SysUtils.Exception;


    EArgumentException      = {$ifdef __DELPHI2009} class(Exception) {$else} SysUtils.EArgumentException {$endif};
    ENotSupportedException  = {$ifdef __DELPHI2009} class(Exception) {$else} SysUtils.ENotSupportedException {$endif};


    ENotImplemented = class(
      {$ifdef __DELPHI2007} Exception
                    {$else} SysUtils.ENotImplemented
                   {$endif})
    public
      constructor Create(const aClass: TClass; const aSignature: String); overload;
      constructor Create(const aObject: TObject; const aSignature: String); overload;
    end;


    EAccessDenied = class(EOSError);



implementation


{ ENotImplemented -------------------------------------------------------------------------------- }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor ENotImplemented.Create(const aClass: TClass;
                                     const aSignature: String);
  begin
    inherited CreateFmt('%s.%s has not been implemented', [aClass.ClassName, aSignature]);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor ENotImplemented.Create(const aObject: TObject;
                                     const aSignature: String);
  begin
    inherited CreateFmt('%s.%s has not been implemented', [aObject.ClassName, aSignature]);
  end;




end.
 