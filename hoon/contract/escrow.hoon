/+  *zig-sys-smart
/=  escrow  /lib/zig/contracts/lib/escrow
=,  escrow
|_  =cart
++  write
  |=  act=action:sur
  ^-  chick
  ?-    -.act
      %proprietor-register-service
    (proprietor-register-service:lib cart act)
      %proprietor-service-finished
    (proprietor-service-finished:lib cart act)
      %proprietor-withdraw
    (proprietor-withdraw:lib cart act)
      %proprietor-mint-nft
    (proprietor-mint-nft:lib cart act)
      %proprietor-contest-customer-refund
    (proprietor-contest-customer-refund:lib cart act)
      %customer-refund
    (customer-refund:lib cart act)
  ==
::
++  read
  |_  =path
  ++  json
    ~
  ::
  ++  noun
    ~
  --
--
