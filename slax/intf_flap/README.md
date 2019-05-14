## Description

Junos does give user possibility to quickly flap interface, since this requires two commit operations. Idea behind this script was to use underlying linux/unix shell to quickly bring interface down and then restore it after give delay. Since only root user can manipulate interfaces, solution to elevate privilated was needed, as it's not convinient to allow users to use root account.

One of the properties of Junos SLAX event scripts is that they are run as root user. To use that and still be able to give user freedom of using it as an operational (op) scripts, apporach to combine this two types was taken. 

This script consist of two entities:
- intf_flap.slax - event script
- syslog_trigger.slax - op script


If script execution is triggered by the event, it would be run with the system privileges (root).
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
