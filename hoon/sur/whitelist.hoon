/-  r=resource
|%
+$  whitelist
  $:  public=?
      kids=?
      users=(set ship)
      groups=(set resource:r)
  ==
::
+$  target
  $%  [%public ~]
      [%kids ~]
      [%users users=(set ship)]
      [%groups groups=(set resource:resource)]
  ==
::
+$  command
  $%  [%add-whitelist wt=target]
      [%remove-whitelist wt=target]
  ==
::
+$  return
  $:  cards=(list card:agent:gall)
      =whitelist
  ==
--
