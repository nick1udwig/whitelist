/-  wl=whitelist
/+  agentio,
    dbug,
    default-agent,
    group
|%
+$  card  card:agent:gall
--
::
=|  state-0
=*  state  -
::
%-  agent:dbug
%+  verb  |
^-  agent:gall

|_  =bowl:gall
+*  this            .
    def             ~(. (default-agent this %|) bowl)
    io              ~(. agentio bowl)
++  on-init   on-init:def
++  on-save   on-save:def
++  on-load   on-load:def
++  on-watch  on-watch:def
++  on-leave  on-leave:def
++  on-agent  on-agent:def
++  on-arvo   on-arvo:def
++  on-fail   on-fail:def
::
++  on-poke
  |=  [m=mark v=vase]
  |^  ^-  (quip card _this)
  ?+    m  on-poke:def
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
  ++  handle-customer-action
    |=  act=customer-action:wl
    ^-  (quip card _state)
    ?-    -.act
        %register
      :-  ~
      %=  state
          customers
        =/  =customer:wl
          (~(gut by customers) src.bowl *customer:wl)
        %+  ~(put by customers)  src.bowl
        customer(address address.act)
      ==
    ::
        %mint-nft
      ~|  "%whitelist: {<-.act>} not yet implemented"
      !!
    ::
        %purchase
      ~|  "%whitelist: {<-.act>} not yet implemented"
      !!
    ::
        %withdraw
      ~|  "%whitelist: {<-.act>} not yet implemented"
      !!
    ==
  ::
  ++  handle-host-action
    |=  act=host-action:wl
    |^  ^-  (quip card _state)
    ?~  permission=(~(get by permissions) app-name.act)
      ~&  >>>  "%whitelist: did not find app {<app-name>}"
      !!
    :-  ~
    %=  state
        permissions
      %+  ~(put by permissions)  app-name.act
      ?-    -.act
          %add     (handle-add act)
          %remove  (handle-remove act)
          %configure
        u.permission(address address.act, config config.act)
      ==
    ==
    ::
    ++  handle-add
      |=  act=host-action:wl
      ^-  permission:wl
      ?:  ?=(%blacklist type.act)
        ?.  ?=(%users target.act)
          ~&  >>>  "%whitelist: type=%blacklist requires target=%users"
          !!
        %.  users.target.act
        ~(uni in blacklist.u.permission)
      ?-  -.target.act
          %public  u.permission(public %.y)
          %kids    u.permission(kids %.y)
          %users
        %.  users.target.act
        ~(uni in whitelist.u.permission)
      ::
          %groups
        %.  groups.target.act
        ~(uni in whitelist-groups.u.permission)
      ==
    ::
    ++  handle-remove
      |=  act=host-action:wl
      ^-  permission:wl
      ?:  ?=(%blacklist type.act)
        ?.  ?=(%users target.act)
          ~&  >>>  "%whitelist: type=%blacklist requires target=%users"
          !!
        %.  users.target.act
        ~(dif in blacklist.u.permission)
      ?-  -.target.act
          %public  u.permission(public %.n)
          %kids    u.permission(kids %.n)
          %users
        %.  users.target.act
        ~(dif in whitelist.u.permission)
      ::
          %groups
        %.  groups.target.act
        ~(dif in whitelist-groups.u.permission)
      ==
    --
  --
::
++  on-peek
  |=  p=path
  |^  ^-  (unit (unit cage))
  ?+    path  on-peek:def
      [%is-allowed @ @ ~]
    =/  app-name=@tas  i.t.p
    =/  src=@p         (slav %p i.t.t.p)
    ``[%noun !>(`?`(is-allowed app-name src))]
  ==
  ::
  ++  is-allowed
    |=  [app-name=@tas user=@p]
    |^  ^-  ?
    ?~  permission=(~(get by permissions) app-name)  %.n
    =*  blacklist  blacklist.u.permission
    =*  whitelist  whitelist.u.permission
    ?:  (~(has in blacklist) user)  %.n
    =/  is-customer=?
      ?~  customer=(~(get by customers) src)  %.n
      %.n
      ::  TODO: 
      ::  test expiry. if fails,
      ::  test NFT existence
    ?|  is-customer
        public.whitelist
        =(our.bowl user)
        &(kids.whitelist is-kid)
        (~(has in users.whitelist) user)
        is-in-group
    ==
    ::
    ++  is-kid
      ^-  ?
      =(our.bowl (sein:title our.bowl now.bowl user))
    ::
    ++  is-in-group
      ^-  ?
      =/  gs  ~(tap in groups.whitelist)
      |-
      ?~  gs  %.n
      ?:  (~(is-member group bowl) user i.gs)  %.y
      $(gs t.gs)
    --
  --
--
