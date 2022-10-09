# Whitelist

Restrict access to your provider Gall app.

## Uqbar protocol (TODO: clean this up)

The Uqbar-connected-portion of this repo consists of three pieces:

1. A smart contract running on the Uqbar rollup.
   The contract manages escrow wallets that customers pay in to, only releasing funds once, e.g., the membership period is over.
   Escrowing funds provides customers with some recourse if a proprietor is not holding up their deal of the bargain, or if the service provided is not what the customer expected.
   Each proprietor has one escrow ZIG rice ID per service, and one ledger rice ID.
   The ledger rice ID has two numbers: assets and liabilities.
   When payment is received, assets and liabilities are both increased by the payment amount.
   Once a membership is completed, liabilities is reduced by the payment amount for that membership.
   Only the difference of `(sub assets liabilities)` can be withdrawn by a proprietor, as the rest of the funds may need to available for refunds to customers.
   TODO: enable arbitrary fungible tokens.
2. A Gall app running on the proprietor's ship.
   The proprietor Gall app tracks customer state and serves as a storefront for the proprietor.
   Prices for services are advertised, and customers can interact with the app to purchase access to those services.
   The app will handle unlocking funds held in escrow once the services have been provided.
   The app will also handle customer refund requests.
3. A Gall app running on the customer's ship.
   The customer Gall app tracks a customer's membership/service state with proprietors and automates the protcol for purchasing services.

### Step-by-step description of the protocol for a membership/subscription

Imagine a proprietor wishes to gate access to a blog, like an Urbit version of Substack.
The protocol below describes how the suite of apps in this repo allows a customer to create a membership.
It also describes how a customer can request a refund.

1. Customer queries proprietor for fee schedule of service.
2. Proprietor responds with signed fee schedule and escrow wallet rice ID.
3. Customer checks that rice ID is held by the smart contract and sends payment.
   Payment is some whole-number multiple of the price in the fee schedule (e.g., if the fee schedule is 1 ZIG per month, a valid payment is 1, 2, 3, ... ZIGs).
4. Contract adds assets and liabilities equal to the payment to the proprietor's account rice.
   Only `(sub assets liabilities)` can be withdrawn by the proprietor.
5. Customer sends signed transaction hash to proprietor.
6. Proprietor starts service upon receipt and confirmation of payment by customer.
7. 1. In simplest case, once membership period has expired, proprietor sends customer-signed-transaction-hash to contract.
      Contract confirms customer signature and proper time has elapsed, then reduces liabilities by amount paid for that period.
   2. 1.  However, if customer is unsatisfied with service, can initiate a refund request by sending customer-signed-transaction-hash to contract.
      2. Provider has some period (`~h1`? `~d1`?) to produce same customer-signed-transaction-hash to contract.
         There are three cases to consider:
         1. Provider does not produce signature.
            Then customer gets a 100% refund.
            Prevents customer from losing money if a provider was never online.
         2. Provider produces signature that matches customer.
            Customer gets refund proportional to the amount of time that has passed relative to the total subscription period.
         3. Provider produces valid signature that differs from customer.
            Customer attempted to cheat by making a new signature.
            Customer receives nothing.

The protocol described above favors proprietors, and customers can lose money to evil proprietors.
It is challenging to stop evil proprietors, since they can scam entirely outside the protocol, e.g. stopping producing content.
Thus, customers should choose proprietors judiciously.
To gain customer trust, it is recommended for proprietors to offer a free trial period, enabled by this app. (TODO: make setting up free trial easy).

## The `whitelist` type

TODO: rewrite these docs.
The repo is now dedicated to a Gall app, not a library.
As such, the docs below are out of date.
Rather than, e.g., placing a
```hoon
?.  (is-allowed foo)
  ~|("not allowed!" !!)
::  do allowed stuff
```
within the app/service you wish to gate, usage will now look something like
```hoon
?.  .^  ?
        %gx
        %+  scry:agentio  %whitelist
        /is-allowed/my-substack/(scot %p user)
    ==
  ~|("not allowed!" !!)
::  do allowed stuff
```

The `whitelist` type contains two `?`s: `public` and `kids`, and two `set`s: `users` and `groups`.

Attribute | Type             | Description
--------- | ---------------- | -----------
`public`  | `?`              | Whether provider is publically accessible.
`kids`    | `?`              | Whether provider is accessible to kids of provider.
`users`   | `(set ship)`     | Specific `@p`s to whom provider is accessible.
`groups`  | `(set resource)` | Groups whose members will have access.

If a ship is a member of one or more of these attributes, it will be whitelisted (see [Restricting access](#restricting-access) below).

## App state

Your app will need to maintain a `whitelist` state.
It is recommended to initialize the `whitelist` with `public` and `kids` set to `%.n`, so that providers must explicitly enable connections from the outside.

## Restricting access

To restrict access to a particular feature of the provider, say, a poke with a certain mark, branch on the `is-allowed` generator.
This is the same pattern as restricting access to a poke to `our` and moons using `team:title`.
For example, in the pseudocode below, pokes with `%payload` mark are only served to ships belonging to the `whitelist`:

```
?-    mark
    %payload
  ?.  (is-allowed:wl-lib src.bowl whitelist.state bowl)
    :: Reject request: not on whitelist.
    ::
    `this
  :: Accept request: on whitelist.
  ::
  =^  cards  state
  (handle-payload !<(payload vase))
  [cards this]
  :: Handle other marks...
  ::
==
```

## Modifying the `whitelist`

Add a poke mark of `%whitelist-command` to your Gall app.
If your app state contains a `whitelist` as recommended, an example code snippet from a switch over poke marks is

```
?-    mark
    %whitelist-command
  ?>  (team:title our.bowl src.bowl)
  =^  cards  whitelist.state
  %:  handle-command:wl-lib
      !<(command:wl vase)
      whitelist.state
      ~
      bowl
  ==
  [cards this]
  :: Handle other marks...
  ::
==
```

where `wl` and `wl-lib` are the faces given to `sur/whitelist.hoon` and `lib/whitelist.hoon`, respectively, upon import.

Using the snippet above, modifications to the `whitelist` might look like (for the Gall app `ursr-provider`):

```
:: Make provider public.
:ursr-provider &whitelist-command [%add-whitelist ~[%public]]

:: Remove permission from kids.
:ursr-provider &whitelist-command [%remove-whitelist ~[%kids]]

:: Add specific ship(s) to whitelist.
:ursr-provider &whitelist-command [%add-whitelist [%users (silt ~[~hosted-fornet ~hosted-labweb])]]

:: Remove specific ship(s) from whitelist.
:ursr-provider &whitelist-command [%remove-whitelist [%users (silt ~[~hosted-fornet])]]

:: Add group to whitelist (i.e. group membership means a ship can use your provider).
:ursr-provider &whitelist-command [%remove-whitelist [%groups (silt ~[[~wisdem-hosted-labweb %homunculus]])]]
```

## A subtlety: `clean-client-list`

When removing `users` from the `whitelist`, `%kick`s can be `%give`n to a `path`.
This behavior is controlled by the `client-path=(unit path)` argument of `handle-command`.
If `~` is passed to `client-path`, no `%kick` `card`s will be returned.
If a non-null `(unit path)` is given, however, `%kick`s will be issued on that `path`.
For example, the snippet [above](#modifying-the-whitelist) will not return any `%kick` `card`s, since `~` is passed for `client-path`.
To modify it to kick on `/client-path`:

```
?-    mark
    %whitelist-command
  ?>  (team:title our.bowl src.bowl)
  =^  cards  whitelist.state
  %:  handle-command:wl-lib
      !<(command:wl vase)
      whitelist.state
      [~ /client-path]
      bowl
  ==
  [cards this]
  :: Handle other marks...
  ::
==
```

## Whitelist in action

Some Gall apps that make use of the Whitelist toolkit include:

* [UrSR Provider](https://github.com/hosted-fornet/ursr/blob/b1fd73d4f48bb48f3ec129e47f087fab1fca477b/hoon/ursr-provider/app/ursr-provider.hoon)

Message me at `~hosted-fornet` or send a PR on the [Whitelist repo](https://github.com/hosted-fornet/whitelist) if you make use of Whitelist and want your Gall app included on this list.

## Acknowledgements

Code ripped from `~timluc-miptev`s [btc-agents](https://github.com/timlucmiptev/btc-agents), with modifications.
