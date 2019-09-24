
  unit Deltics.Exceptions;

{$i deltics.rtl.inc}

interface

  uses
    SysUtils;


  type
    EArgumentException      = {$ifdef __DELPHI2009} class(Exception) {$else} SysUtils.EArgumentException {$endif};
    ENotSupportedException  = {$ifdef __DELPHI2009} class(Exception) {$else} SysUtils.ENotSupportedException {$endif};



implementation

end.
 