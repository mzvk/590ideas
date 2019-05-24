## DESCRIPTION

Script should be triggered by the custom message, then it will automatically enter dumpen mode to suppress any additional execution of the script. First action of the script is to remove configured event policy, to further prevent future execution, since script should be run only once. 
Logging is done via syslog messages with facility and severity string pair of `user.notice`, so to view them configuration should allow that.

## USAGE

1. Create an event policy

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

2. Wait for the trigger. 

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
        source "scp://mzurawski@10.255.0.4:/home/mzurawski/SLAX/gcore.slax";
    }
}

{master:0}
mzurawski@qfx5100-02> file list /var/tmp/ | match snmpd
core_snmpd_live.0
```
