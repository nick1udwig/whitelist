::  Pay a %whitelist-proprietor for access to services.
::
/-  wallet,
    ps=pairsign,
    r=resource,
    ui=indexer,
    wl=whitelist
/+  agentio,
    dbug,
    default-agent,
    group,
    pairsign,
    verb,
    whitelist,
    smart=zig-sys-smart,
    zigs=zig-contracts-lib-zigs
|%
+$  card  card:agent:gall
--
::
=|  customer-state-0:wl
=*  state  -
::
%-  agent:dbug
%+  verb  |
^-  agent:gall
|_  =bowl:gall
+*  this    .
    def     ~(. (default-agent this %|) bowl)
    io      ~(. agentio bowl)
    ps-lib  ~(. pairsign bowl)
    wl-lib  ~(. whitelist bowl)
::
++  on-fail   on-fail:def
::
++  on-init
  ^-  (quip card _this)
  =/  escrow-wheat-id=@ux  0x2222.2222  ::  TODO: put real value
  :-  :_  ~
      %+  ~(watch-our pass:io /wallet-tx-update)
      %uqbar  /wallet/[dap.bowl]/tx-updates
  %=  this
      zigs-contract-ids
    (~(put by *(map @ux @ux)) 0x0 zigs-wheat-id:smart)
      escrow-contract-ids
    (~(put by *(map @ux @ux)) 0x0 escrow-wheat-id)
  ==
::
++  on-save   !>(state)
::
++  on-load
  |=  old-vase=vase
  ^-  (quip card _this)
  =+  !<(old=versioned-customer-state:wl old-vase)
  ?-  -.old
    %0  `this(state old)
  ==
::
++  on-leave
  |=  p=path
  ^-  (quip card _this)
  (on-leave:def p)
::
++  on-arvo
  |=  [w=wire =sign-arvo:agent:gall]
  ^-  (quip card _this)
  ?+    w  (on-arvo:def w sign-arvo)
      [%expiry @ @ @ ~]
    ?+    sign-arvo  (on-arvo:def w sign-arvo)
        [%behn %wake *]
      =/  until=@da          (slav %da i.t.w)
      =/  service-name=@tas  `@tas`i.t.t.w
      =/  tx-hash=@ux        (slav %ux i.t.t.t.w)
      ?:  (lth now.bowl until)  `this
      ?^  error.sign-arvo
        ~|  "%whitelist-customer: error from ping timer: {<u.error.sign-arvo>}"
        !!
      ::  TODO: add to and change the above to be an alter on
      ::  soon-expiring subscription
      `this
    ==
  ==
::
++  on-watch
  |=  p=path
  ^-  (quip card _this)
  (on-watch:def p)
::
++  on-peek
  |=  p=path
  ^-  (unit (unit cage))
  ?:  =(/x/dbug/state p)  ``[%noun !>(`_state`state)]
  (on-peek:def p)
::
++  on-agent
  |=  [w=wire =sign:agent:gall]
  ^-  (quip card _this)
  ?+    w  (on-agent:def w sign)
      [%fee-schedule @ @ ~]
    ?+    -.sign  (on-agent:def w sign)
        %kick  `this
        %fact
      =/  proprietor-ship=@p  (slav %p i.t.w)
      =/  service-name=@tas   `@tas`i.t.t.w
      =+  !<(update=proprietor-update:wl q.cage.sign)
      ?.  ?=(%fee-schedule -.update)
        ~|("%whitelist-proprietor: %fee-schedule sign requires %fee-schedule update" !!)
      =*  sfs        signed-fee-schedule.update
      =*  sig        sig.sfs
      =*  town-id    town-id.sfs
      =*  e-rice     escrow-rice.sfs
      =*  timestamp  timestamp.sfs
      =*  p-address  proprietor-address.sfs
      =*  fee-schedule  +.+.+.+.+.sfs
      =/  message=@
        (sham [town-id e-rice timestamp fee-schedule])
      ?.  (is-sig-valid:ps-lib sig p-address message)
        ~|("%whitelist-customer: signature not valid" !!)
      :-  ~
      %=  this
          fee-schedules
        %+  ~(put by fee-schedules)
        [proprietor-ship service-name]  sfs
      ==
    ==
  ::
      [%wallet-tx-update ~]
    ?+    -.sign  (on-agent:def w sign)
        %kick
      :_  this
      :_  ~
      %+  ~(watch-our pass:io w)
      %uqbar  /wallet/[dap.bowl]/tx-updates
    :: 
        %fact
      =+  !<(update=wallet-update:wallet q.cage.sign)
      =*  my-address  id.from.shell.egg.update
      =*  hash        `@ux`hash.update
      ?.  ?=(%tx-status -.update)    `this
      ?.  ?=(%noun -.action.update)  `this
      =*  tx-noun  +.action.update
      ?~  proprietor=(~(get by pending-payments) tx-noun)
        `this
      =/  p-ship=@tas   (scot %p p.u.proprietor)
      =*  service-name  q.u.proprietor
      :_  %=  this
              pending-payments
            (~(del by pending-payments) tx-noun)
          ==
      :+  ::  watch for transaction to appear on chain
          %+  %~  watch-our  pass:io
              /payment/(scot %ux hash)/[p-ship]/[service-name]
          %uqbar  /indexer/[dap.bowl]/egg/0x0/(scot %ux hash)  ::  TODO: hardcode
        ::  sign payment, sending to %sequencer
        %+  ~(poke-our pass:io /purchase/tx-to-chain)  %uqbar
        :-  %zig-wallet-poke
        !>  ^-  wallet-poke:wallet
        :^    %submit
            from=my-address
          hash=hash.update
        gas=[rate=1 budget=1.000.000]  ::  TODO: hardcode
      ~
    ==
  ::
      [%payment @ @ @ ~]
    =/  tx-hash=@ux  (slav %ux i.t.w)
    =/  proprietor-dock=dock
      [(slav %p i.t.t.w) `@tas`i.t.t.t.w]
    ?+    -.sign  (on-agent:def w sign)
        %kick
      :_  this
      :_  ~
      %+  ~(watch-our pass:io w)
      %uqbar  /indexer/[dap.bowl]/egg/0x0/(scot %ux tx-hash)  ::  TODO: hardcode
    ::
        %fact
      =+  !<(=update:ui q.cage.sign)
      =/  [egg=(unit egg:smart) timestamp=(unit @da)]
        ?+    -.update  [~ ~]
            %newest-egg  [`egg.update `timestamp.update]
            %egg
          ?~  e=(~(get by eggs.update) tx-hash)  [~ ~]
          [`egg.u.e `timestamp.u.e]
        ==
      ?~  egg  ~|("%whitelist-customer: expected update type %(newest-)egg, got {<update>}" !!)
      ?>  ?=(^ timestamp)
      =/  sfs=(unit signed-fee-schedule:wl)
        (~(get by fee-schedules) proprietor-dock)
      ?~  sfs
        ~|  "%whitelist-customer: fee-schedule for {<proprietor-dock>} missing"
        !!
      ::  confirm ours
      ::  send %purchase
      =*  address  id.from.shell.u.egg
      =/  =sig:ps
        %+  sign:ps-lib  address
        (sham [sfs tx-hash q.proprietor-dock])
      =/  act=customer-to-proprietor-action:wl
        :*  %purchase
            sig=sig
            address=address
            signed-fee-schedule=u.sfs
            tx-hash=tx-hash
            service-name=q.proprietor-dock
        ==
      :-  :+  (~(leave-our pass:io w) %uqbar)
            %+  ~(poke pass:io /purchase/to-proprietor)
              proprietor-dock
            :-  %whitelist-customer-to-proprietor-action
            !>(`customer-to-proprietor-action:wl`act)
          ~
      %=  this
          open-receipts
        %+  ~(put by open-receipts)  proprietor-dock
        %+  %~  put  by
            (~(gut by open-receipts) proprietor-dock ~)
          tx-hash
        (make-receipt-from-purchase:wl-lib act u.timestamp)
      ==
    ==
  ==
::
++  on-poke
  |=  [m=mark v=vase]
  |^  ^-  (quip card _this)
  ?>  (team:title our.bowl src.bowl)
  ?+    m  (on-poke:def m v)
    ::  TODO: %set-zigs-contract-id & %..escrow..
      %whitelist-customer-action
    =^  cards  state
      (handle-customer-action !<(customer-action:wl v))
    [cards this]
  ==
  ::
  ++  make-wait-card
    |=  [until=@da p=path]
    ^-  card
    %.  until
    %~  wait  pass:io
    (weld /expiry/(scot %da until) p)
  ::
  ++  make-rest-card
    |=  [until=@da p=path]
    ^-  card
    %.  until
    %~  rest  pass:io
    (weld /expiry/(scot %da until) p)
  ::
  ++  make-timer-cards
    |=  $:  until=@da
            service-name=@tas
            tx-hash=@ux
            previous=(unit (pair @da @ux))
        ==
    ^-  (list card)
    =/  wait-card=card
      %+  make-wait-card  until
      /[service-name]/(scot %ux tx-hash)
    ?~  previous  [wait-card]~
    :+  wait-card
      %+  make-rest-card  p.u.previous
      /[service-name]/(scot %ux q.u.previous)
    ~
  ::
  ++  handle-customer-action
    |=  act=customer-action:wl
    ^-  (quip card _state)
    ?-    -.act
        %mint-nft  !!
        %refund  !!
    ::
        %get-fee-schedule
      :_  state
      :_  ~
      %+  %~  watch  pass:io
          :-  %fee-schedule
          /(scot %p proprietor-ship.act)/[service-name.act]
        [proprietor-ship.act %whitelist-proprietor]
      /get-fee-schedule/(scot %p our.bowl)/[service-name.act]
    ::
        %purchase
      ?~  sfs=(~(get by fee-schedules) service-dock.act)
        ~|  "%whitelist-customer: fetch new fee-schedule before %purchase"
        !!
      =*  town-id      town-id.u.sfs
      =*  escrow-rice  escrow-rice.u.sfs
      =*  price        price-per-unit.u.sfs
      ?~  zigs-c-id=(~(get by zigs-contract-ids) town-id)
        ~|  "%whitelist-customer: add zigs contract id for town {<town-id>} and try again"
        !!
      ?~  escrow-c-id=(~(get by escrow-contract-ids) town-id)
        ~|  "%whitelist-customer: add escrow contract id for town {<town-id>} and try again"
        !!
      :: =/  transaction-text=@t
      ::   %-  crip
      ::   "[%give {<u.escrow-c-id>} {<price>} {<my-payment-rice.act>} `{<escrow-rice>}]"
      =/  transaction-noun
        :-  %give
        :^    u.escrow-c-id
            price
          my-payment-rice.act
        `escrow-rice
      ~&  transaction-noun
      :_  %=  state
              pending-payments
            %+  ~(put by pending-payments)  transaction-noun
            service-dock.act
          ==
      :_  ~
      %+  ~(poke-our pass:io /purchase/tx-to-wallet)  %uqbar
      :-  %zig-wallet-poke
      !>  ^-  wallet-poke:wallet
      :*  %transaction
          from=my-address.act
          contract=u.zigs-c-id
          town=town-id
          [%noun transaction-noun]
      ==
    ==
  --
--
