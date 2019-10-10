
{$i deltics.rtl.inc}

{$ifdef debugDelticsRtl}
  {$define debugDelticsStrings}
{$endif}

{$ifdef debugDelticsStrings}
  {$undef InlineMethods}
  {$debuginfo ON}
{$endif}
