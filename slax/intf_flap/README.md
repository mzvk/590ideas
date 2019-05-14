## Description

Since it's not convinent that all users would be logged as root, and only root can manipulate interfaces from the shell level, this scripts really requires two scripts. If script execution is triggered by the event, it would be run with the system privileges (root).
This explains why there are actually two scripts. First one `intf_flap.slax` is event script, which already contains event policy definition inside it's body, hence no additional config is required. Event script is the one doing actual work on the interfaces, but to be executed it requires a specific event to be triggered in the system. 
In the event body all argument are passed to the event script. As name implies, the second script `syslog_trigger.slax` is an op (operational) script used plainly for the generation of custom event. 

## Junos config:

```
set system scripts op file syslog_trigger.slax command bounce
set event-options event-script file intf_flap.slax
```

## Usage
```
{master:0}
mzvk@ex2300> show interfaces ge-0/0/0 | match flap    
  Last flapped   : 2019-05-14 20:01:51 UTC (00:02:56 ago)

{master:0}
mzvk@ex2300> op bounce intf ge-0/0/0 delay 1                    

{master:0}
mzvk@ex2300> show interfaces ge-0/0/0 | match flap              
  Last flapped   : 2019-05-14 20:05:08 UTC (00:00:10 ago)
```
