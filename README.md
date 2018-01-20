edis_proto
==========

A Library extracted from [edis](https://github.com/cbd/edis) to allow applications
exposing a Redis compatible protocol.

Usage
-----

In your supervisor add this two

```erlang
  ListenerOpts = #{min_port => MinPort, max_port => MaxPort},
  ListenerSup = {edis_listener_sup, {edis_listener_sup, start_link, [ListenerOpts]},
                 permanent, 1000, supervisor, [edis_listener_sup]},
  ClientOpts = #{command_runner_mod => ameo},
  ClientSup = {edis_client_sup, {edis_client_sup, start_link, [ClientOpts]},
               permanent, 1000, supervisor, [edis_client_sup]},

  {ok, {{one_for_one, 5, 10}, [..., ListenerSup, ClientSup]}}.
```

License
-------

Apache Public License 2.0
