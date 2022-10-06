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
::
++  on-init   on-init:def
++  on-save   on-save:def
++  on-load   on-load:def
++  on-agent  on-agent:def
++  on-fail   on-fail:def
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
      [%customer ~]  ::  TODO: to remote scry
    :_  this
    %-  fact-init-kick:io
    :-  %whitelist-customer
    !>  ^-  (unit customer-by-service:wl)
    (~(get by customers) src.bowl)
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
    =*  e-rice        escrow-rice.u.permission
    =*  fee-schedule  +.config.u.permission
    =*  p-address     proprietor-address.u.permission
    =/  message=@  (jam [e-rice now.bowl fee-schedule])
    =/  =sig:ps  (sign:ps-lib p-address message)
    %-  fact-init-kick:io
    :-  %whitelist-fee-schedule
    !>  ^-  signed-fee-schedule:wl
    [sig p-address e-rice now.bowl fee-schedule]
  ==
::
++  on-peek
  |=  p=path
  |^  ^-  (unit (unit cage))
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
      %whitelist-customer-action
    =^  cards  state
      (handle-customer-action !<(customer-action:wl v))
    [cards this]
  ::
      %whitelist-host-action
    ?>  (team:title our.bowl src.bowl)
    =^  cards  state
      (handle-host-action !<(host-action:wl v))
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
  ++  make-receipt-from-purchase
    |=  [act=customer-action:wl timestamp=@da]
    ^-  receipt:wl
    ?>  ?=(%purchase -.act)
    =/  customer-pubkey=@
      =/  life=@ud
        .^(@ud %j (scry:io %life /(scot %p src.bowl)))
      .^(@ %j (scry:io %vein /(scot %ud life)))
    =/  proprietor-pubkey=@
      =/  life=@ud
        .^(@ud %j (scry:io %life /(scot %p our.bowl)))
      .^(@ %j (scry:io %vein /(scot %ud life)))
    :*  sig.act
        customer-pubkey
        address.act
        proprietor-pubkey
        signed-fee-schedule.act
        tx-hash.act
        timestamp
    ==
  ::
  ++  handle-customer-action
    |=  act=customer-action:wl
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
        ?>  =(@dr unit-type.fs)
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
        tx-hash  (make-receipt-from-purchase act timestamp)
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
    ::
      ::   %refund
      :: ~|  "%whitelist: {<-.act>} not yet implemented"
      :: !!
    ==
  ::
  ++  handle-host-action
    |=  act=host-action:wl
    ^-  (quip card _state)
    =/  permission=(unit permission:wl)
      (~(get by permissions) service-name.act)
    |^
    ::  TODO: on %config, request to contract to set up escrow wallet & watch contract
    :-  ~
    %=  state
        permissions
      %+  ~(put by permissions)  service-name.act
      ?-    -.act
          %add     (handle-add act)
          %remove  (handle-remove act)
          %configure
        ?^  permission
          %=  u.permission
              proprietor-address  proprietor-address.act
              config              config.act
          ==
        =|  p=permission:wl
        %=  p
            proprietor-address  proprietor-address.act
            config              config.act
            allow-public        %.n
            allow-kids          %.n
        ==
      ==
    ==
    ::
    ++  handle-add
      |=  act=host-action:wl
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
      |=  act=host-action:wl
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
