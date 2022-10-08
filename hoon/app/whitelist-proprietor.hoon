::  Gate access by whitelist, blacklist, group membership,
::  or payment to a specified grain address on Uqbar.
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
=|  proprietor-state-0:wl
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
  =+  !<(old=versioned-proprietor-state:wl old-vase)
  ?-  -.old
    %0  `this(state old)
  ==
::
++  on-leave
  |=  p=path
  ^-  (quip card _this)
  ?+  p  (on-leave:def p)
    [%customer ~]              `this
    [%get-fee-schedule @ @ ~]  `this
    [%expiry @ @ ~]            `this
  ==
::
++  on-agent
  |=  [w=wire =sign:agent:gall]
  ^-  (quip card _this)
  ?+    w  (on-agent:def w sign)
      [%wallet-tx-update ~]
    ~&  %wallet-tx-update
    ?+    -.sign  (on-agent:def w sign)
        %kick
      :_  this
      :_  ~
      %+  ~(watch-our pass:io w)
      %uqbar  /wallet/[dap.bowl]/tx-updates
    ::
        %fact
      =+  !<(update=wallet-update:wallet q.cage.sign)
      ~&  %wallet-update
      ~&  update
      =*  my-address  id.from.shell.egg.update
      =*  hash        `@ux`hash.update
      ?.  ?=(%tx-status -.update)    `this
      ?.  ?=(%noun -.action.update)  `this
      =*  tx-noun  +.action.update
      ?~  ledger-rice-id=(~(get by pending-txs) tx-noun)
        `this
      :_  %=  this
              pending-txs  (~(del by pending-txs) tx-noun)
          ==
      :+  ::  watch for transaction to appear on chain
          %+  %~  watch-our  pass:io
              :-  %configure
              /(scot %ux hash)/(scot %ux u.ledger-rice-id)
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
      [%configure @ @ ~]
    =/  tx-hash=@ux         (slav %ux i.t.w)
    =/  ledger-rice=@ux  (slav %ux i.t.t.w)
    ?+    -.sign  (on-agent:def w sign)
        %kick
      :_  this
      :_  ~
      %+  ~(watch-our pass:io w)
      %uqbar  /indexer/[dap.bowl]/egg/0x0/(scot %ux tx-hash)  ::  TODO: hardcode
    ::
        %fact
      =+  !<(egg-update=update:ui q.cage.sign)
      ?~  egg-update
        ~|  "%whitelist-proprietor: got empty egg on {<w>}"
        !!
      =/  [egg=(unit egg:smart) town-id=(unit @ux)]
        ?+    -.egg-update  [~ ~]
            %newest-egg
          [`egg.egg-update `town-id.location.egg-update]
        ::
            %egg
          ?~  e=(~(get by eggs.egg-update) tx-hash)  [~ ~]
          [`egg.u.e `town-id.location.u.e]
        ==
      ?~  egg  ~|("%whitelist-proprietor: expected update type %(newest-)egg, got {<egg-update>}" !!)
      ?>  ?=(^ town-id)
      =*  escrow-contract  contract.shell.u.egg
      =+  .^  =update:ui
              %gx
              %+  scry:io  %uqbar
              %+  weld
                /indexer/newest/holder/(scot %ux u.town-id)
              /(scot %ux escrow-contract)/noun
          ==
      ?~  update
        ~|  "%whitelist-proprietor: got empty holder on {<w>} town {<town-id>} contract {<escrow-contract>}"
        !!
      ?.  ?=(%grain -.update)
        ~|  "%whitelist-proprietor: expected holder update type %grain, got {<update>}"
        !!
      ?~  gs=(~(get ja grains.update) ledger-rice)
        ~|  "%whitelist-proprietor: did not find expected ledger grain {<ledger-rice>}  in {<update>}"
        !!
      ::  TODO: check ledger is as expected
      `this
    ==
  ==
::
++  on-arvo
  |=  [w=wire =sign-arvo:agent:gall]
  ^-  (quip card _this)
  ?+    w  (on-arvo:def w sign-arvo)
      [%expiry @ @ @ @ ~]
    ?+    sign-arvo  (on-arvo:def w sign-arvo)
        [%behn %wake *]
      =/  until=@da          (slav %da i.t.w)
      =/  who=@p             (slav %p i.t.t.w)
      =/  service-name=@tas  `@tas`i.t.t.t.w
      =/  tx-hash=@ux        (slav %ux i.t.t.t.t.w)
      ?:  (lth now.bowl until)  `this
      ?^  error.sign-arvo
        ~|  "%whitelist: error from ping timer: {<u.error.sign-arvo>}"
        !!
      =/  cbs=(unit customer-by-service:wl)
        (~(get by customers) who)
      :_  this
      :_  ~
      %+  fact:io  [%noun !>(`@da`until)]
      [/expiry/[service-name]/(scot %p who)]~
      ::  TODO:
      ::  send card to contract to reduce liabilities
    ==
  ==
::
++  on-watch
  |=  p=path
  ^-  (quip card _this)
  ?+    p  (on-watch:def p)
      [%expiry @ @ ~]  `this
      ?([%customer ~] [%customer-by-service ~]) ::  TODO: to remote scry
    :_  this
    %-  fact-init-kick:io
    :-  %whitelist-proprietor-update
    !>  ^-  proprietor-update:wl
    ?~  c=(~(get by customers) src.bowl)  ~
    [%customer-by-service u.c]
  ::
      [%services ~]  ::  TODO: to remote scry; make public/private list so services need not be public?
    :_  this
    %-  fact-init-kick:io
    :-  %noun
    !>(`(set @tas)`~(key by permissions))
  ::
      [%get-fee-schedule @ @ ~]  ::  TODO: to remote scry
    :_  this
    =/  src=@p             (slav %p i.t.p)
    =/  service-name=@tas  `@tas`i.t.t.p
    ?.  =(src.bowl src)
      ~|("%whitelist: src ({<src>}) must be src.bowl ({<src.bowl>})" !!)
    ?~  permission=(~(get by permissions) service-name)
      ~|("%whitelist: could not find service {<service-name>}" !!)
    =*  p-address     proprietor-address.u.permission
    =*  town-id       town-id.u.permission
    =*  e-rice        escrow-rice.u.permission
    =*  fee-schedule  +.config.u.permission
    =/  message=@
      (sham [town-id e-rice now.bowl fee-schedule])
    =/  =sig:ps  (sign:ps-lib p-address message)
    %-  fact-init-kick:io
    :-  %whitelist-proprietor-update
    !>  ^-  proprietor-update:wl
    :-  %fee-schedule
    [sig p-address town-id e-rice now.bowl fee-schedule]
  ==
::
++  on-peek
  |=  p=path
  |^  ^-  (unit (unit cage))
  ?:  =(/x/dbug/state p)  ``[%noun !>(`_state`state)]
  ?+    p  (on-peek:def p)
      [%is-allowed @ @ ~]  ::  TODO: prepare for remote scry
    =/  service-name=@tas  i.t.p
    =/  src=@p             (slav %p i.t.t.p)
    ``[%noun !>(`?`(is-allowed service-name src))]
  ==
  ::
  ++  is-allowed
    |=  [service-name=@tas user=@p]
    |^  ^-  ?
    ?~  permission=(~(get by permissions) service-name)  %.n
    =*  blacklist         blacklist.u.permission
    =*  allow-public      allow-public.u.permission
    =*  allow-kids        allow-kids.u.permission
    =*  whitelist         whitelist.u.permission
    =*  whitelist-groups  whitelist-groups.u.permission
    ?:  (~(has in blacklist) user)  %.n
    =/  is-customer=?
      =/  customer=(unit customer:wl)
        (~(get by (~(gut by customers) user ~)) service-name)
      ?~  customer  %.n
      ?:  (lth now.bowl expiry.u.customer)  %.y
      %.n
      ::  TODO:
      ::  test NFT existence
    ?|  is-customer
        allow-public
        =(our.bowl user)
        &(allow-kids is-kid)
        (~(has in whitelist) user)
        (is-in-group whitelist-groups)
    ==
    ::
    ++  is-kid
      ^-  ?
      =(our.bowl (sein:title our.bowl now.bowl user))
    ::
    ++  is-in-group
      |=  whitelist-groups=(set resource:r)
      ^-  ?
      =/  gs  ~(tap in whitelist-groups)
      |-
      ?~  gs  %.n
      ?:  (~(is-member group bowl) user i.gs)  %.y
      $(gs t.gs)
    --
  --
::
++  on-poke
  |=  [m=mark v=vase]
  |^  ^-  (quip card _this)
  ?+    m  (on-poke:def m v)
    ::  TODO: %set-zigs-contract-id & %..escrow..
      %whitelist-customer-to-proprietor-action
    =^  cards  state
      %-  handle-customer-to-proprietor-action
      !<(customer-to-proprietor-action:wl v)
    [cards this]
  ::
      %whitelist-proprietor-action
    ?>  (team:title our.bowl src.bowl)
    =^  cards  state
      (handle-proprietor-action !<(proprietor-action:wl v))
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
  ++  handle-customer-to-proprietor-action
    |=  act=customer-to-proprietor-action:wl
    ^-  (quip card _state)
    ?-    -.act
        %mint-nft
      ~|  "%whitelist: {<-.act>} not yet implemented"
      !!
    ::
        %purchase
      =*  tx-hash       tx-hash.act
      =*  service-name  service-name.act
      ?.  =(src.bowl q.p.sig.act)
        ~|("%whitelist: request must be from signing ship" !!)
      ?:  %.  tx-hash
          ~(has by (~(gut by open-receipts) service-name ~))
        ~|("%whitelist: transaction already claimed" !!)
      ?~  permission=(~(get by permissions) service-name)
        ~|("%whitelist: no such service as {<service-name>}" !!)
      ?.  (is-sig-valid:ps-lib [sig address tx-hash]:act)
        ~|("%whitelist: signature not valid" !!)
      =/  =update:ui
        .^  update:ui
            %gx
            %+  scry:io  %uqbar
            /indexer/egg/(scot %ux tx-hash)/noun
        ==
      ?~  update
        ~|("%whitelist: indexer could not find tx {<tx-hash>}" !!)
      ?.  ?=(%egg -.update)
        ~|("%whitelist: unexpected update type {<update>}" !!)
      ?~  e=(~(get by eggs.update) tx-hash)
        ~|("%whitelist: could not find tx {<tx-hash>}" !!)
      =*  timestamp  timestamp.u.e
      =*  shell      shell.egg.u.e
      =*  yolk       yolk.egg.u.e
      =/  tx-act=action:sur:zigs  ;;(action:sur:zigs yolk)
      ?.  ?=(%give -.tx-act)
        ~|("%whitelist: tx must be a zigs %give" !!)  ::  TODO: generalize to fungible
      =*  escrow-rice  escrow-rice.u.permission
      ?.  =(escrow-rice (need to-account.tx-act))
        ~|("%whitelist: tx must be to escrow address {<escrow-rice>}" !!)
      =*  fs  +.config.u.permission
      ?.  =(price-per-unit.fs amount.tx-act)  ::  TODO: generalize to multiple units
        ~|("%whitelist: payment must exactly match price-per-unit" !!)
      =/  maybe-customer=(unit customer:wl)
        %.  service-name
        ~(get by (~(gut by customers) src.bowl ~))
      =/  old-expiry=@da
        ?~  maybe-customer  timestamp
        ?:  (lth now.bowl expiry.u.maybe-customer)
          expiry.u.maybe-customer
        timestamp.u.e  ::  TODO: check for NFTs
      =/  expiry-addend=@dr  ::  TODO: generalize
        ?>  ?=(%membership unit-description.fs)
        ?>  =(%dr unit-type.fs)
        (slav %dr unit.fs)
        :: %+  mul  (slav %dr unit.fs)  ::  TODO: generalize to multiple units
        :: (div amount.tx-act price-per-unit.fs)
      =/  new-expiry=@da  (add old-expiry expiry-addend)
      :-  %:  make-timer-cards
              new-expiry
              service-name
              tx-hash
              ?~  =(timestamp old-expiry)   ~
              ?~  maybe-customer            ~
              ?~  history.u.maybe-customer  ~
              :+  ~
                old-expiry
              payment-tx.i.history.u.maybe-customer
          ==
      %=  state
          open-receipts
        %+  ~(put by open-receipts)  service-name
        %+  %~  put  by
            (~(gut by open-receipts) service-name ~)
          tx-hash
        (make-receipt-from-purchase:wl-lib act timestamp)
      ::
          customers
        %+  ~(put by customers)  src.bowl
        %+  %~  put  by
            (~(gut by customers) src.bowl ~)
          service-name
        :-  new-expiry
        ?~  maybe-customer  ~[[address.act tx-hash]]
        [[address.act tx-hash] history.u.maybe-customer]
      ==
    ==
  ::
  ++  handle-proprietor-action
    |=  act=proprietor-action:wl
    ^-  (quip card _state)
    =/  permission=(unit permission:wl)
      (~(get by permissions) service-name.act)
    |^
    ::  TODO: on %config, request to contract to set up escrow wallet & watch contract
    ?-    -.act
        ?(%add %remove)
      :-  ~
      %=  state
          permissions
        %+  ~(put by permissions)  service-name.act
        ?-  -.act
          %add     (handle-add act)
          %remove  (handle-remove act)
        ==
      ==
    ::
        %configure
      ?^  permission
        ~|  "%whitelist-proprietor: changing config not yet enabled"
        !!
      =/  zigs-contract-id=(unit @ux)
        (~(get by zigs-contract-ids) town-id.act)
      ?~  zigs-contract-id
        ~|  "%whitelist-proprietor: set zigs contract id for town {<town-id.act>} and try again"
        !!
      =/  escrow-contract-id=(unit @ux)
        (~(get by escrow-contract-ids) town-id.act)
      ?~  escrow-contract-id
        ~|  "%whitelist-proprietor: set escrow contract id for town {<town-id.act>} and try again"
        !!
      =/  salt=@
        (cat 3 (scot %ux my-address.act) service-name.act)
      =/  ledger-rice=@ux
        %:  fry-rice:smart
            u.escrow-contract-id
            u.escrow-contract-id
            town-id.act
            salt
        ==
      =/  escrow-rice=@ux
        %:  fry-rice:smart
            u.zigs-contract-id
            u.escrow-contract-id
            town-id.act
            salt
        ==
      =/  tx-noun
        :-  %noun
        :^    %proprietor-register-service
            service-name.act
          u.zigs-contract-id
        `@ux`'zigs-metadata'  ::  TODO: hardcoded for zigs
      :_  %=  state
              pending-txs
            %+  ~(put by pending-txs)  +.tx-noun
            ledger-rice
          ::
              permissions
            %+  ~(put by permissions)  service-name.act
            :: ?^  permission
            ::   %=  u.permission
            ::       proprietor-address  my-address.act
            ::       config              config.act
            ::   ==
            =|  p=permission:wl
            %=  p
                proprietor-address  my-address.act
                town-id             town-id.act
                ledger-rice         ledger-rice
                escrow-rice         escrow-rice
                config              config.act
                allow-public        %.n
                allow-kids          %.n
            ==
          ==
      :_  ~
      %+  %~  poke-our  pass:io
          /configure/(scot %ux my-address.act)
        %uqbar
      :-  %zig-wallet-poke
      !>  ^-  wallet-poke:wallet
      :-  %transaction
      :^    from=my-address.act
          contract=u.escrow-contract-id
        town=town-id.act
      action=tx-noun
    ==
    ::
    ++  handle-add
      |=  act=proprietor-action:wl
      ^-  permission:wl
      ?~  permission
        ~|  "%whitelist: did not find service {<service-name.act>}"
        !!
      ?>  ?=(%add -.act)
      ?:  ?=(%blacklist type.act)
        ?.  ?=(%users -.target.act)
          ~|  "%whitelist: type=%blacklist requires target=%users"
          !!
        %=  u.permission
            blacklist
          %.  users.target.act
          ~(uni in blacklist.u.permission)
        ==
      ?-  -.target.act
          %public  u.permission(allow-public %.y)
          %kids    u.permission(allow-kids %.y)
          %users
        %=  u.permission
            whitelist
          %.  users.target.act
          ~(uni in whitelist.u.permission)
        ==
      ::
          %groups
        %=  u.permission
            whitelist-groups
          %.  groups.target.act
          ~(uni in whitelist-groups.u.permission)
        ==
      ==
    ::
    ++  handle-remove
      |=  act=proprietor-action:wl
      ^-  permission:wl
      ?~  permission
        ~|  "%whitelist: did not find service {<service-name.act>}"
        !!
      ?>  ?=(%remove -.act)
      ?:  ?=(%blacklist type.act)
        ?.  ?=(%users -.target.act)
          ~|  "%whitelist: type=%blacklist requires target=%users"
          !!
        %=  u.permission
            blacklist
          %.  users.target.act
          ~(dif in blacklist.u.permission)
        ==
      ?-  -.target.act
          %public  u.permission(allow-public %.n)
          %kids    u.permission(allow-kids %.n)
          %users
        %=  u.permission
            whitelist
          %.  users.target.act
          ~(dif in whitelist.u.permission)
        ==
      ::
          %groups
        %=  u.permission
            whitelist-groups
          %.  groups.target.act
          ~(dif in whitelist-groups.u.permission)
        ==
      ==
    --
  --
--
