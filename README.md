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
  ClientOpts = #{command_runner_mod => my_command_runner},
  ClientSup = {edis_client_sup, {edis_client_sup, start_link, [ClientOpts]},
               permanent, 1000, supervisor, [edis_client_sup]},

  {ok, {{one_for_one, 5, 10}, [..., ListenerSup, ClientSup]}}.
```

where my\_command\_runner is a module that exports run\_command/2:

```erlang
run_command(Command, Args) ->
    do_stuff_here.
```

Where Command is a binary with the command name in uppercase and args is a list
of binaries with the arguments.

The result from run\_command can be:

```
{ok, _} ->
    replies OK to client

{ok, _, nil} ->
    replies nil to client

{ok, _, Value} ->
    replies Value to client (Value can be integer, string)

no_reply ->
    doesn't send a reply to the client

{error, _, {ErrorCode, ErrorReason, ErrorDetails}} ->
    replies an error with Reason as text to client
```

License
-------

Apache Public License 2.0
