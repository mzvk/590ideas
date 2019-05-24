## DESCRIPTION

Script should be triggered by the custom message, which does not have any event specified by Junos, so it has assigned general event id ("SYSTEM"). There are two mechanisms embedded to prevent from multiple execution, one is self-clearing procedure, which will remove configured event policy which enables script execution. Second is script dampening, which will prevent execute for 5min, since last run. Multiple processes can be specified in the comma seperated list. Processess from list are then matched against list of all running processess on the switch/router and all matching hits are then dumped. Given process name is base of regex pattern. Process name must be at least 4 characters long, to prevent greedy regex search and dumping all running processess. 
Logging is done via SYSLOG messages, which use `user.notice` facility and severity string pair (priority of 13 => 1 * 8 + 5), to view this messages, appropriate severity level needs to be saved to files or send to external SYSLOG server.

## USAGE

1. Copy script to the /var/db/script/event and configure it under `[event-options event-script]`.

`set event-options event-script file gcore_es.slax`

2. Create an event policy.

```
[edit event-options]
   policy {{event-policy-name}} {
       events SYSTEM;
       attributes-match {
           SYSTEM.message matches {{custom_trigger_message}};
       }
       then {
           event-script gcore.slax {
               arguments {
                   policy_name {{event-policy-name}};
                   proc_list {{processess_list}};
               }
           }
       }
   }
}
```

3. Commit 

4. Wait for the trigger. 

## EXAMPLE

```
{master:0}[edit]
mzurawski@qfx5100-02# show | compare 
[edit event-options]
+   policy CUSTOM_TRIGGER {
+       events SYSTEM;
+       attributes-match {
+           SYSTEM.message matches "ngworx: start";
+       }
+       then {
+           event-script gcore.slax {
+               arguments {
+                   policy_name CUSTOM_TRIGGER;
+                   proc_list snmpd;
+               }
+           }
+       }
+   }
+   event-script {
+       file gcore.slax {
+           source "scp://mzurawski@10.255.0.4:/home/mzurawski/SLAX/gcore_es.slax";
+       }
+   }

{master:0}[edit]
mzurawski@qfx5100-02# commit and-quit
configuration check succeeds
commit complete

{master:0}
mzurawski@qfx5100-02> file list /var/tmp/ | match snmpd

{master:0}
mzurawski@qfx5100-02> start shell 
% logger "ngworx: start"
% exit
exit

{master:0}
mzurawski@qfx5100-02> show configuration event-options 
event-script {
    file gcore.slax {
        source "scp://mzurawski@10.255.0.4:/home/mzurawski/SLAX/gcore_es.slax";
    }
}

{master:0}
mzurawski@qfx5100-02> file list /var/tmp/ | match snmpd
core_snmpd_live.0
```
