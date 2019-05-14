intf_flap.slax - event script
syslog_trigger.slax - op script

Usage:

configure intf_flap.slax as an event script, it already contains event policy definition inside it's body
configure syslog_trigger as an op script, it is used to generate syslog message upon which intf_flap reacts. 

Junos config:

`set event-options event-scripts file intf_flap.slax`
`set system scripts op file syslog_trigger.slax command intf_bounce`
