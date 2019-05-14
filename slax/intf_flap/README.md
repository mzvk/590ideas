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

