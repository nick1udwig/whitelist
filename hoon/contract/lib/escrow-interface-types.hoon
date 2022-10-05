|%
++  types-json
  |^  ^-  (map @tas json)
  %-  ~(gas by *(map @tas json))
  :_  ~
  [%ledger (need (de-json:html ledger-cord))]
  ::
  ++  ledger-cord
    ^-  cord
    '''
    [
      {"proprietor-address": "ux"},
      {"escrow-rice": "ux"},
      {"settled": "ud"}
    ]
    '''
  --
++  interface-json
  |^  ^-  (map @tas json)
  %-  ~(gas by *(map @tas json))
  :~  :-  %proprietor-register-service
      (need (de-json:html proprietor-register-service-cord))
  ::
      :-  %proprietor-service-finished
      (need (de-json:html proprietor-service-finished-cord))
  ::
      :-  %proprietor-withdraw
      (need (de-json:html proprietor-withdraw-cord))
  ::
      :-  %proprietor-mint-nft
      (need (de-json:html proprietor-mint-nft-cord))
  ::
      :-  %proprietor-contest-customer-refund
      %-  need
      (de-json:html proprietor-contest-customer-refund-cord)
  ::
      :-  %customer-refund
      (need (de-json:html customer-refund-cord))
  ==
  ::
  ++  proprietor-register-service-cord
    ^-  cord
    '''
    [
      {"salt": "ux"},
      {"token-contract": "ux"},
      {"token-metadata": "ux"}
    ]
    '''
  ::
  ++  proprietor-service-finished-cord
    ^-  cord
    %:  rap
        '''
        [
          {"ledger-rice": "ux"},
          {"now": "da"},
          {"receipt":
        '''
        receipt-cord
        '}]'
        ~
    ==
  ::
  ++  proprietor-withdraw-cord
    ^-  cord
    '''
    [
      {"ledger-rice": "ux"},
      {"to": "ux"},
      {"amount": "ud"}
    ]
    '''
  ::
  ++  proprietor-mint-nft-cord
    ^-  cord
    '''
    [
      {"foo": "~"}
    ]
    '''
  ::
  ++  proprietor-contest-customer-refund-cord
    ^-  cord
    %:  rap
        '''
        [
          {"ledger-rice": "ux"},
          {"now": "da"},
          {"receipt":
        '''
        receipt-cord
        '}]'
        ~
    ==
  ::
  ++  customer-refund-cord
    ^-  cord
    %:  rap
        '''
        [
          {"now": "da"},
          {"receipt":
        '''
        receipt-cord
        '}]'
        ~
    ==
  ::
  ++  receipt-cord
    ^-  cord
    %:  rap
        3
        '''
        [
          {"sig":
        '''
        sig-cord
        '},'
        '''
          {"customer-ship-pubkey": "ux"},
          {"customer-address": "ux"},
          {"proprietor-ship-pubkey": "ux"},
          {"signed-fee-schedule":
        '''
        signed-fee-schedule-cord
        '},'
        '''
          {"payment-tx-hash": "ux"},
          {"payment-timestamp": "da"}
        ]
        '''
        ~
    ==
  ::
  ++  sig-cord
    ^-  cord
    '''
    [
      {
        "p": [
           {"p": "ux"},
           {"q": "p"},
           {"r": "ud"}
        ],
      },
      {
        "q": [
          {"v": "ux"},
          {"r": "ux"},
          {"s": "ux"}
        ]
      }
    ]
    '''
  ::
  ++  signed-fee-schedule-cord
    ^-  cord
    %:  rap
        3
        '''
        [
          {"sig":
        '''
        sig-cord
        '},'
        '''
          {"proprietor-address": "ux"},
          {"escrow-address": "ux"},
          {"timestamp": "da"},
          {"fee-schedule":
        '''
        fee-schedule-cord
        '}]'
        ~
    ==
  ::
  ++  fee-schedule-cord
    ^-  cord
    '''
    [
      {"unit-description": "tas"},
      {"unit": "ta"},
      {"unit-type": ["each", "ud", "dr"]},
      {"price-per-unit": "ud"}
    ]
    '''
  --
--
