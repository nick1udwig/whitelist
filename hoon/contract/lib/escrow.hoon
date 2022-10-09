:: /+  *zig-sys-smart
|%
++  sur
  |%
  +$  ledger
    $:  proprietor-address=id
        escrow-rice=id
        settled=@ud
    ==
  ::
  +$  action
    $%  proprietor-register-service
        proprietor-service-finished
        proprietor-withdraw
        proprietor-mint-nft
        proprietor-contest-customer-refund
        customer-refund
    ==
  ::
  +$  proprietor-register-service
    $:  %proprietor-register-service
        salt=@  ::  service-name or other unique per-proprietor salt
        token-contract=id  ::  ZIGs; TODO: generalize
        token-metadata=id  ::  TODO: better method to input?
    ==
  +$  proprietor-service-finished
    $:  %proprietor-service-finished
        ledger-rice=id
        now=@da  ::  TODO: replace with oracle time
        =receipt
    ==
  +$  proprietor-withdraw
    $:  %proprietor-withdraw
        ledger-rice=id
        to=id  ::  rice must be held by proprietor-address
        amount=@ud
    ==
  +$  proprietor-mint-nft
    $:  %proprietor-mint-nft
        foo=~
    ==
  +$  proprietor-contest-customer-refund
    $:  %proprietor-contest-customer-refund
        ledger-rice=id
        now=@da  ::  TODO: replace with oracle time
        =receipt
    ==
  +$  customer-refund
    $:  %customer-refund
        now=@da  ::  TODO: replace with oracle time
        =receipt
    ==
  ::
  +$  receipt
    $:  =sig
        customer-ship-pubkey=@
        customer-address=address
        proprietor-ship-pubkey=@
        =signed-fee-schedule
        payment-tx-hash=id
        payment-timestamp=@da
    ==
  ::
  +$  sig  (pair crub-sig ecdsa-sig)
  +$  crub-sig   [p=@ux q=@p r=@ud]
  +$  ecdsa-sig  [v=@ r=@ s=@]  ::  ETH compatible ECDSA signature
  ::
  +$  fee-schedule  ::  TODO: rethink config/fee-schedule
    ::  $:  unit-description=@tas  ::  e.g., jobs, kBs, cpu-minutes, membership
    $:  unit-description=%membership  ::  TODO: generalize
        unit=@ta               ::  e.g., '1' , '1', '~m1'      , '~d30'
        unit-type=?(@ud @dr)   ::  e.g., @ud , @ud, @dr        , @dr
        price-per-unit=@ud
        ::  price-units=@tas  ::  TODO: add; e.g., ZIG, DOGE, ...
    ==
  +$  signed-fee-schedule  ::  TODO: rethink config/fee-schedule
    $:  =sig
        proprietor-address=address
        escrow-rice=@ux
        timestamp=@da
        fee-schedule
    ==
  --
::
++  lib
  |%
  ++  proprietor-register-service
    |=  [=cart act=proprietor-register-service:sur]
    ^-  chick
    =*  proprietor-address  id.from.cart
    =/  salt=@
      (cat 3 (scot %ux proprietor-address) salt.act)
    ::  build escrow grain
    ::
    =/  escrow-id=id
      (fry-rice token-contract.act me.cart town-id.cart salt)
    =/  escrow-rice-data
      :^    balance=0
          allowances=~
        metadata=token-metadata.act
      nonce=0
    =/  escrow-grain=grain
      :*  %&
          salt
          %account
          escrow-rice-data
          escrow-id
          token-contract.act
          me.cart
          town-id.cart
      ==
    ::  build ledger grain
    ::
    =/  ledger-id=id
      (fry-rice me.cart me.cart town-id.cart salt)
    =/  ledger-rice-data=ledger:sur
      :+  proprietor-address
        escrow-id
      settled=0
    =/  ledger-grain=grain
      :*  %&
          salt
          %ledger
          ledger-rice-data
          ledger-id
          me.cart
          me.cart
          town-id.cart
      ==
    ::
    (result ~ ~[escrow-grain ledger-grain] ~ ~)
  ::
  ++  proprietor-service-finished
    |=  [=cart act=proprietor-service-finished:sur]
    ^-  chick
    ?>  (is-receipt-valid receipt.act)
    =*  payment-timestamp  payment-timestamp.receipt.act
    =*  fee-schedule
      +.+.+.+.signed-fee-schedule.receipt.act
    =/  service-expiry=@da
      (compute-expiry payment-timestamp fee-schedule)
    ?>  (gte now.act service-expiry)  ::  TODO: replace with oracle time
    =/  ledger
      %:  husk
          ledger:sur
          (need (scry ledger-rice.act))
          `me.cart
          `me.cart
      ==
    =*  price  price-per-unit.fee-schedule
    ~!  data.ledger
    =.  settled.data.ledger  (add settled.data.ledger price)
    (result ~[%&^ledger] ~ ~ ~)
  ::
  ++  proprietor-withdraw
    |=  [=cart act=proprietor-withdraw:sur]
    ^-  chick
    !!
  ::
  ++  proprietor-mint-nft
    |=  [=cart act=proprietor-mint-nft:sur]
    ^-  chick
    !!
  ::
  ++  proprietor-contest-customer-refund
    |=  [=cart act=proprietor-contest-customer-refund:sur]
    ^-  chick
    ?>  (is-receipt-valid receipt.act)
    !!
  ::
  ++  customer-refund
    |=  [=cart act=customer-refund:sur]
    ^-  chick
    ?>  (is-receipt-valid receipt.act)
    !!
  ::
  ++  compute-expiry  ::  TODO: generalize
    |=  [start=@da =fee-schedule:sur]
    ^-  @da
    ?>  ?=(%membership unit-description.fee-schedule)
    ?>  =(@dr unit-type.fee-schedule)
    (add start (slav %dr unit.fee-schedule))
  ::
  ++  is-receipt-valid
    |=  receipt:sur
    ^-  ?
    =*  escrow-rice   escrow-rice.signed-fee-schedule
    =*  timestamp     timestamp.signed-fee-schedule
    =*  fee-schedule  +.+.+.+.signed-fee-schedule
    ?&  ::  check customer sig on receipt
        ::
        %:  is-sig-valid
            sig
            customer-ship-pubkey
            customer-address
            %-  sham
            :+  signed-fee-schedule
              payment-tx-hash
            payment-timestamp
        ==
        ::  check proprietor sig on fee schedule
        ::
        %:  is-sig-valid
            sig.signed-fee-schedule
            proprietor-ship-pubkey
            proprietor-address.signed-fee-schedule
            (sham [escrow-rice timestamp fee-schedule])
        ==
    ==
  ::
  ++  is-sig-valid
    ::  adapted from whitelist/lib/pairsign.hoon
    |=  [=sig:sur ship-pubkey=@ address=@ux message=@]
    |^  ^-  ?
    &(is-sig-valid-crub is-sig-valid-ecdsa)
    ::
    ++  is-sig-valid-crub
      ::  adapted from landscape/lib/signatures.hoon
      ^-  ?
      .=  `message
      (sure:as:(com:nu:crub:crypto ship-pubkey) p.p.sig)
    ::
    ++  is-sig-valid-ecdsa
      ^-  ?
      .=  address
      %-  address-from-pub
      %-  serialize-point:secp256k1:secp:crypto
      %+  ecdsa-raw-recover:secp256k1:secp:crypto  message
      q.sig
    --
  --
--
