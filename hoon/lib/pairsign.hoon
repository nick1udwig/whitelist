/-  ps=pairsign
/+  ethereum,
    agentio
|_  =bowl:gall
+*  io  ~(. agentio bowl)
::
++  sign
  |=  [address=@ux message=@]
  ^-  sig:ps
  :-  (sign:crub message)
  (sign:ecdsa address message)
::
++  is-sig-valid
  |=  [=sig:ps address=@ux message=@]
  ^-  ?
  ?&  (is-sig-valid:crub p.sig message)
      (is-sig-valid:ecdsa q.sig address message)
  ==
::
++  crub
  ::  adapted from landscape/lib/signatures.hoon
  |%
  ++  jael-scry
    |*  [=mold desk=term =path]
    .^  mold
      %j
      (scot %p our.bowl)
      desk
      (scot %da now.bowl)
      path
    ==
  ::
  ++  sign
    |=  message=@
    ^-  crub-sig:ps
    =+  (jael-scry ,=life %life /(scot %p our.bowl))
    =+  (jael-scry ,=ring %vein /(scot %ud life))
    :+  `@ux`(sign:as:(nol:nu:crub:crypto ring) message)
      our.bowl
    life
  ::
  ++  is-sig-valid
    ::  modified from landscape/lib/signatures.hoon to only
    ::   return %.y when we can validate signature
    |=  [signature=crub-sig:ps message=@]
    ^-  ?
    =+  (jael-scry ,lyf=(unit @) %lyfe /(scot %p q.signature))
    ::  we do not have a public key from ship at this life
    ::
    ?~  lyf  %.n
    ?.  =(u.lyf r.signature)  %.n
    =+  %:  jael-scry
          ,deed=[a=life b=pass c=(unit @ux)]
          %deed  /(scot %p q.signature)/(scot %ud r.signature)
        ==
    ?.  =(a.deed r.signature)  %.n
    ::  verify signature from ship at life
    ::
    =/  them
      (com:nu:crub:crypto b.deed)
    =(`message (sure:as.them p.signature))
  --
::
++  ecdsa
  |%
  ++  sign
    |=  [address=@ux message=@]
    ^-  ecdsa-sig:ps
    .^  ecdsa-sig:ps
        %gx
        %+  scry:io  %wallet
        %+  weld
          /sign-message/(scot %ux address)
        /(scot %ud message)/noun
        :: %+  scry:io  %uqbar  ::  TODO: need unified wallet scry type for %uqbar
        :: %+  weld
        ::   /wallet/sign-message/(scot %ux address)
        :: /(scot %ud message)/noun
    ==
  ::
  ++  is-sig-valid
    |=  [signature=ecdsa-sig:ps address=@ux message=@]
    ^-  ?
    .=  address
    %-  address-from-pub:key:ethereum
    %-  serialize-point:secp256k1:secp:crypto
    %+  ecdsa-raw-recover:secp256k1:secp:crypto  message
    signature
  --
--
