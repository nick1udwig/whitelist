/-  r=resource
|%
+$  versioned-state
  $%  state-0
==
+$  state-0  [%0 =permissions =customers]
::
+$  permissions
  (map @tas permission)
+$  permission
  [address=@ux =config whitelist blacklist=(set @p)]
+$  config
  $%  [%subscription cost-spec]
      [%rent cost-spec]
  ==
+$  whitelist
  $:  public=?
      kids=?
      whitelist=(set @p)
      whitelist-groups=(set resource:r)
  ==
+$  cost-spec  [unit=@dr price-per-unit=@ud]  ::  TODO: specify unit of price?
::
+$  customers  (map @p customer)
+$  customer
  [address=@ux balance=@ud expiry=(each @dr @da)]  ::  TODO: do better with expiry: face & types?
::
::  TODO: think more about %withdraw; introduces weirdness where provider should not remove
::        entire balance from wallet, but is not restricted from doing so
+$  customer-action
  $%  [%register address=@ux]
      [%mint-nft ~]
      [%purchase ~]
      [%withdraw amount=@ud]
  ==
+$  host-action
  $%  [%configure app-name=@tas address=@ux =config]
      [%add app-name=@tas type=?(%blacklist %whitelist) =target]
      [%remove app-name=@tas type=?(%blacklist %whitelist) =target]
  ==
+$  target
  $%  [%public ~]
      [%kids ~]
      [%users users=(set ship)]
      [%groups groups=(set resource:resource)]
  ==
--
