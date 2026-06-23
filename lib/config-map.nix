{ lib }:

{
  compactAttrs = attrs:
    lib.filterAttrs (_: value:
      if builtins.isAttrs value then
        value != { }
      else
        value != null
    ) attrs;
}
