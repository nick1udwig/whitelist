/-  ps=pairsign,
    r=resource
|%
+$  versioned-proprietor-state
  $%  proprietor-state-0
==
+$  proprietor-state-0
  $:  %0
      zigs-contract-ids=(map town-id=@ux @ux)
      escrow-contract-ids=(map town-id=@ux @ux)
      pending-txs=(map * @ux)  ::  to automatically confirm payment
      =permissions
      =customers
      open-receipts=receipts-by-name
      closed-receipts=receipts-by-name
  ==
::
+$  versioned-customer-state
  $%  customer-state-0
==
+$  customer-state-0
  $:  %0
      zigs-contract-ids=(map town-id=@ux @ux)
      escrow-contract-ids=(map town-id=@ux @ux)
      pending-payments=(map * dock)  ::  to automatically confirm payment
      fee-schedules=(map dock signed-fee-schedule)
      open-receipts=receipts-by-dock
      closed-receipts=receipts-by-dock
  ==
::
+$  permissions  (map service-name=@tas permission)
+$  permission
  $:  proprietor-address=@ux
      town-id=@ux
      ledger-rice=@ux
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
      unit-type=?(%ud %dr)   ::  e.g., @ud , @ud, @dr        , @dr
      price-per-unit=@ud
      fee-schedule-expiry=@dr  ::  how long a signed fee schedule is valid
      ::  price-units=@tas  ::  TODO: add; e.g., ZIG, DOGE, ...
  ==
+$  signed-fee-schedule  ::  TODO: rethink config/fee-schedule
  $:  =sig:ps
      proprietor-address=@ux
      town-id=@ux
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
+$  receipts-by-dock
  (map dock receipts)
+$  receipts-by-name
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
  $%  [%get-fee-schedule proprietor-ship=@p service-name=@tas]
      [%mint-nft =sig:ps address=@ux tx-hash=@ux service-name=@tas]
      [%refund =sig:ps address=@ux tx-hash=@ux]
      [%purchase my-address=@ux my-payment-rice=@ux service-dock=dock]
  ==
::
+$  customer-to-proprietor-action
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
+$  proprietor-action
  $%  [%configure service-name=@tas my-address=@ux town-id=@ux my-payment-rice=@ux =config]
      [%add service-name=@tas type=?(%blacklist %whitelist) =target]
      [%remove service-name=@tas type=?(%blacklist %whitelist) =target]
  ==
+$  target
  $%  [%public ~]
      [%kids ~]
      [%users users=(set @p)]
      [%groups groups=(set resource:r)]
  ==
::
+$  proprietor-update
  $@  ~
  $%  [%fee-schedule =signed-fee-schedule]
      [%customer-by-service =customer-by-service]
  ==
--
