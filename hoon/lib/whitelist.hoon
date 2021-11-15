/-  *whitelist
/+  group
|%
++  handle-command
  |=  [comm=whitelist-command =whitelist client-path=(unit path) =bowl:gall]
  ^-  whitelist-return
  ?-  -.comm
      %add-whitelist
    ?-  -.wt.comm
        %public
      `whitelist(public %.y)
      ::
        %kids
      `whitelist(kids %.y)
      ::
        %users
      `whitelist(users (~(uni in users.whitelist) users.wt.comm))
      ::
        %groups
      `whitelist(groups (~(uni in groups.whitelist) groups.wt.comm))
    ==
    :: 
      %remove-whitelist
    %^  clean-client-list  client-path  bowl
    ?-  -.wt.comm
        %public
      whitelist(public %.n)
      ::
        %kids
      whitelist(kids %.n)
      ::
        %users
      whitelist(users (~(dif in users.whitelist) users.wt.comm))
      ::
        %groups
      whitelist(groups (~(dif in groups.whitelist) groups.wt.comm))
    ==
  ==
::
++  clean-client-list
  |=  [client-path=(unit path) =bowl:gall =whitelist]
  ^-  whitelist-return
  =/  to-kick=(set ship)
    %-  silt
    %+  murn  ~(tap in users.whitelist)
    |=  c=ship  ^-  (unit ship)
    ?:((is-whitelisted c whitelist bowl) ~ `c)
  =.  users.whitelist  (~(dif in users.whitelist) to-kick)
  :_  whitelist
  ?~  client-path
    ~
  %+  turn  ~(tap in to-kick)
  |=(c=ship [%give %kick ~[u.client-path] `c])
::
++  is-whitelisted
  |=  [user=ship =whitelist =bowl:gall]
  ^-  ?
  |^
  ?|  public.whitelist
      =(our.bowl user)
      ?&(kids.whitelist (is-kid bowl))
      (~(has in users.whitelist) user)
      (in-group bowl)
  ==
  ++  is-kid
    |=  =bowl:gall
    =(our.bowl (sein:title our.bowl now.bowl user))
  ::
  ++  in-group
    |=  =bowl:gall
    =/  gs  ~(tap in groups.whitelist)
    |-
    ?~  gs  %.n
    ?:  (~(is-member group bowl) user i.gs)
      %.y
    $(gs t.gs)
  --
--
