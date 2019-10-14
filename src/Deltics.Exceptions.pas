{
  * MIT LICENSE *

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

  Original author : Jolyon Direnko-Smith
  e-mail          : jsmith@deltics.co.nz
  github          : deltics/deltics.rtl
}

{$i deltics.rtl.inc}

{$ifdef debugDelticsExceptions}
  {$debuginfo ON}
{$endif}

  unit Deltics.Exceptions;


interface

  uses
    SysUtils;


  type
    Exception = SysUtils.Exception;


    EArgumentException      = {$ifdef __DELPHI2009} class(Exception) {$else} SysUtils.EArgumentException {$endif};
    ENotSupportedException  = {$ifdef __DELPHI2009} class(Exception) {$else} SysUtils.ENotSupportedException {$endif};


    ENotImplemented = class(
      {$ifdef __DELPHI2010} Exception
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
 