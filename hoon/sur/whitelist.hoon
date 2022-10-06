/-  ps=pairsign,
    r=resource
|%
+$  versioned-proprietor-state
  $%  proprietor-state-0
==
+$  proprietor-state-0
  $:  %0
      =permissions
      =customers
      open-receipts=receipts-by-service
      closed-receipts=receipts-by-service
  ==
::
+$  permissions  (map service-name=@tas permission)
+$  permission
  $:  proprietor-address=@ux
      escrow-rice=@ux
      =config
      whitelist
      blacklist=(set @p)
  ==
+$  config
  $%  [%membership fee-schedule]
      :: [%rent fee-schedule]  ::  TODO: rethink config/fee-schedule
  ==
+$  whitelist
  $:  allow-public=?
      allow-kids=?
      whitelist=(set @p)
      whitelist-groups=(set resource:r)
  ==
+$  fee-schedule  ::  TODO: rethink config/fee-schedule
  ::  $:  unit-description=@tas  ::  e.g., jobs, kBs, cpu-minutes, membership
  $:  unit-description=%membership  ::  TODO: generalize
      unit=@ta               ::  e.g., '1' , '1', '~m1'      , '~d30'
      unit-type=?(@ud @dr)   ::  e.g., @ud , @ud, @dr        , @dr
      price-per-unit=@ud
      ::  price-units=@tas  ::  TODO: add; e.g., ZIG, DOGE, ...
  ==
+$  signed-fee-schedule  ::  TODO: rethink config/fee-schedule
  $:  =sig:ps
      proprietor-address=@ux
      escrow-rice=@ux
      timestamp=@da
      fee-schedule
  ==
::
+$  customers  (map @p customer-by-service)
+$  customer-by-service
  (map service-name=@tas customer)
+$  customer
  [expiry=@da history=(list [address=@ux payment-tx=@ux])]  ::  TODO: do better with expiry: face & types?
::   :: [address=@ux balance=@ud expiry=(each @dr @da)]  ::  TODO: do better with expiry: face & types?
::
+$  receipts-by-service
  (map service-name=@tas receipts)
+$  receipts
  (map tx-hash=@ux receipt)
+$  receipt
  $:  =sig:ps
      customer-ship-pubkey=@
      customer-address=@ux
      proprietor-ship-pubkey=@
      =signed-fee-schedule
      payment-tx-hash=@ux
      payment-timestamp=@da
  ==
::
+$  customer-action
  $%  [%mint-nft =sig:ps address=@ux tx-hash=@ux service-name=@tas]
      $:  %purchase
          =sig:ps
          address=@ux
          =signed-fee-schedule
          tx-hash=@ux
          service-name=@tas
      ==
      :: [%refund =sig:ps address=@ux tx-hash=@ux]
  ==
+$  host-action
  $%  [%configure service-name=@tas proprietor-address=@ux =config]
      [%add service-name=@tas type=?(%blacklist %whitelist) =target]
      [%remove service-name=@tas type=?(%blacklist %whitelist) =target]
  ==
+$  target
  $%  [%public ~]
      [%kids ~]
      [%users users=(set @p)]
      [%groups groups=(set resource:r)]
  ==
--
