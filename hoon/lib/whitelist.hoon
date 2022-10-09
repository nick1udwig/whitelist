/-  wl=whitelist
/+  io=agentio
|_  =bowl:gall
++  make-receipt-from-purchase
  |=  [act=customer-to-proprietor-action:wl timestamp=@da]
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
--
