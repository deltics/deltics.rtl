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

{$ifdef debugDelticsTypes}
  {$debuginfo ON}
{$endif}

  unit Deltics.Types;


interface

  uses
  { vcl: }
    Classes,
    SysUtils;


  type
  {$ifdef __DELPHIXE}
    {$ifdef WIN32}
      NativeUInt  = Cardinal;
      NativeInt   = Integer;
    {$else}
      NativeUInt  = UInt64;
      NativeInt   = Int64;
    {$endif}
  {$endif}

    IntPointer  = NativeUInt;
    PObject     = ^TObject;
    PUnknown    = ^IUnknown;


    TMilliseconds = type Cardinal;
    TSeconds = type Cardinal;


  type
    NullableBoolean = (
                       nbNull,
                       nbFALSE,
                       nbTRUE
                      );

  function IsTRUE(const aBool: NullableBoolean): Boolean;
  function IsFALSE(const aBool: NullableBoolean): Boolean;
  function IsNull(const aBool: NullableBoolean): Boolean;
  function IsNotNull(const aBool: NullableBoolean): Boolean;


implementation


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function IsTRUE(const aBool: NullableBoolean): Boolean;
  begin
    result := (aBool = nbTRUE);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function IsFALSE(const aBool: NullableBoolean): Boolean;
  begin
    result := (aBool = nbFALSE);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function IsNull(const aBool: NullableBoolean): Boolean;
  begin
    result := (aBool = nbNull);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function IsNotNull(const aBool: NullableBoolean): Boolean;
  begin
    result := (aBool <> nbNull);
  end;



end.

