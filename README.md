# Whitelist

Tools to make whitelisting easier for providers.

## Interface

The `whitelist` type contains two `?`s: `public` and `kids`, and two `set`s: `users` and `groups`.

Attribute | Type             | Description
--------- | ---------------- | -----------
`public`  | `?`              | Whether provider is publically accessible.
`kids`    | `?`              | Whether provider is accessible to kids of provider.
`users`   | `(set ship)`     | Specific `@p`s to whom provider is accessible.
`groups`  | `(set resource)` | Groups whose members will have access.

If a ship is a member of one or more of these attributes, it will be whitelisted.

## App state

Your app will need to maintain a `whitelist` state.
It is recommended to initialize the `whitelist` with `public` and `kids` set to `%.n`, so that providers must explicitly enable connections from the outside.

## Restricting access

To restrict access to a particular feature of the provider, say, a poke with a certain mark, branch on the `is-whitelisted` generator.
This is the same pattern as restricting access to a poke to `our` and moons using `team:title`.
For example, in the pseudocode below, pokes with `%paylod` mark are only served to ships belonging to the `whitelist`:

```
  %payload
?.  (is-whitelisted:wl-lib src.bowl whitelist.state bowl)
  :: Reject request: not on whitelist.
  ::
  `this
:: Accept request: on whitelist.
::
=^  cards  state
(handle-payload:hc !<(payload vase))
[cards this]
```

## Modifying the `whitelist`

Add a poke mark of `%whitelist-command` to your Gall app.
If your app state contains a `whitelist` as recommended, an example code snippet from a switch over poke marks is

```
  %whitelist-command
?>  (team:title our.bowl src.bowl)
=^  cards  whitelist.state
%:  handle-command:wl-lib
    !<(whitelist-command:wl vase)
    whitelist.state
    ~
    bowl
==
[cards this]
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
  %whitelist-command
?>  (team:title our.bowl src.bowl)
=^  cards  whitelist.state
%:  handle-command:wl-lib
    !<(whitelist-command:wl vase)
    whitelist.state
    [~ /client-path]
    bowl
==
[cards this]
```

## Whitelist in action

Some Gall apps that make use of the Whitelist toolkit include:

* [UrSR Provider](https://github.com/hosted-fornet/ursr/blob/b1fd73d4f48bb48f3ec129e47f087fab1fca477b/hoon/ursr-provider/app/ursr-provider.hoon)

Message me at `~hosted-fornet` or send a PR on the [Whitelist repo](https://github.com/hosted-fornet/whitelist) if you make use of Whitelist and want your Gall app included on this list.

## Acknowledgements

Code ripped from `~timluc-miptev`s [btc-agents](https://github.com/timlucmiptev/btc-agents), with modifications.
