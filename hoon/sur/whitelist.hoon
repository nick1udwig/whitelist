/-  resource
|%
+$  whitelist
  $:  public=?
      kids=?
      users=(set ship)
      groups=(set resource:resource)
  ==
::
+$  whitelist-target
  $%  [%public ~]
      [%kids ~]
      [%users users=(set ship)]
      [%groups groups=(set resource:resource)]
  ==
::
+$  whitelist-command
  $%  [%add-whitelist wt=whitelist-target]
      [%remove-whitelist wt=whitelist-target]
  ==
::
+$  whitelist-return
  $:  cards=(list card:agent:gall)
      =whitelist
  ==
--
