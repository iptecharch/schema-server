*** Settings ***
Resource          ../keywords/server.robot
Resource          ../keywords/client.robot
Library           OperatingSystem
Library           String
Library           Process
#Suite Setup       Setup    True    ${server-bin}    ${schema-server-config}    ${schema-server-process-alias}    ${schema-server-stderr}    ${data-server-config}    ${data-server-process-alias}    ${data-server-stderr}   
#Suite Teardown    Teardown

*** Variables ***
${server-bin}    ./bin/server
${client-bin}    ./bin/client
${schema-server-config}    ./lab/distributed/schema-server.yaml
${data-server-config}    ./lab/distributed/data-server.yaml
${schema-server-ip}    127.0.0.1
${schema-server-port}    55000
${data-server-ip}    127.0.0.1
${data-server-port}    56000

# TARGET
${srlinux1-name}    srl1
${srlinux1-candidate}    default
${srlinux1-schema-name}    srl
${srlinux1-schema-version}    22.11.2
${srlinux1-schema-Vendor}    Nokia



# internal vars
${schema-server-process-alias}    ssa
${schema-server-stderr}    /tmp/ss-out
${data-server-process-alias}    dsa
${data-server-stderr}    /tmp/ds-out


*** Test Cases ***
Check Server State
    CheckServerState    ${schema-server-process-alias}    ${data-server-process-alias}

Set system0 admin-state disable
    LogMustStatements    ${srlinux1-schema-name}    ${srlinux1-schema-version}    ${srlinux1-schema-vendor}    interface[name=system0]/admin-state

    CreateCandidate    ${srlinux1-name}    ${srlinux1-candidate}
    ${result} =     Set    ${srlinux1-name}    ${srlinux1-candidate}    interface[name=system0]/admin-state:::disable

    Should Contain    ${result.stderr}    admin-state must be enable
    Should Be Equal As Integers    ${result.rc}    1

    DeleteCandidate    ${srlinux1-name}    ${srlinux1-candidate}

Set lag-type without 'interface[name=xyz]/lag/lacp' existence
    LogMustStatements    ${srlinux1-schema-name}    ${srlinux1-schema-version}    ${srlinux1-schema-vendor}    interface[name=lag1]/lag/lag-type

    CreateCandidate    ${srlinux1-name}    ${srlinux1-candidate}
    ${result} =     Set    ${srlinux1-name}    ${srlinux1-candidate}    interface[name=lag1]/lag/lag-type:::lacp

    Should Contain    ${result.stderr}    lacp container must be configured when lag-type is lacp
    Should Be Equal As Integers    ${result.rc}    1

    DeleteCandidate    ${srlinux1-name}    ${srlinux1-candidate}

Set lag-type with 'interface[name=xyz]/lag/lacp' existence
    LogMustStatements    ${srlinux1-schema-name}    ${srlinux1-schema-version}    ${srlinux1-schema-vendor}    interface[name=lag1]/lag/lacp/admin-key
    LogMustStatements    ${srlinux1-schema-name}    ${srlinux1-schema-version}    ${srlinux1-schema-vendor}    interface[name=lag1]/lag/lag-type

    CreateCandidate    ${srlinux1-name}    ${srlinux1-candidate}

    ${result} =     Set    ${srlinux1-name}    ${srlinux1-candidate}    interface[name=lag1]/lag/lacp/admin-key:::1
    Should Be Equal As Integers    ${result.rc}    0
    ${result} =     Set    ${srlinux1-name}    ${srlinux1-candidate}    interface[name=lag1]/lag/lag-type:::lacp
    Should Be Equal As Integers    ${result.rc}    0

    DeleteCandidate    ${srlinux1-name}    ${srlinux1-candidate}

Set auto-negotiate on non allowed interface
    LogMustStatements    ${srlinux1-schema-name}    ${srlinux1-schema-version}    ${srlinux1-schema-vendor}    interface[name=ethernet-0/1]/ethernet/auto-negotiate

    CreateCandidate    ${srlinux1-name}    ${srlinux1-candidate}

    ${result} =     Set    ${srlinux1-name}    ${srlinux1-candidate}    interface[name=ethernet-0/1]/ethernet/auto-negotiate:::true
    Should Contain    ${result.stderr}    auto-negotiation not supported on this interface
    Should Be Equal As Integers    ${result.rc}    1

    DeleteCandidate    ${srlinux1-name}    ${srlinux1-candidate}

Set auto-negotiate on allowed interface
    LogMustStatements    ${srlinux1-schema-name}    ${srlinux1-schema-version}    ${srlinux1-schema-vendor}    interface[name=ethernet-1/1]/ethernet/auto-negotiate

    CreateCandidate    ${srlinux1-name}    ${srlinux1-candidate}

    ${result} =     Set    ${srlinux1-name}    ${srlinux1-candidate}    interface[name=ethernet-1/1]/ethernet/auto-negotiate:::true
    Should Be Equal As Integers    ${result.rc}    0

    DeleteCandidate    ${srlinux1-name}    ${srlinux1-candidate}

Set auto-negotiation on breakout-mode port
    LogMustStatements    ${srlinux1-schema-name}    ${srlinux1-schema-version}    ${srlinux1-schema-vendor}    interface[name=ethernet-1/1]/ethernet/auto-negotiate
    LogMustStatements    ${srlinux1-schema-name}    ${srlinux1-schema-version}    ${srlinux1-schema-vendor}    interface[name=ethernet-1/1]/breakout-mode/num-breakout-ports
    
    CreateCandidate    ${srlinux1-name}    ${srlinux1-candidate}
    
    ${result} =     Set    ${srlinux1-name}    ${srlinux1-candidate}    interface[name=ethernet-1/1]/breakout-mode/num-breakout-ports:::4
    Should Be Equal As Integers    ${result.rc}    0
    ${result} =     Set    ${srlinux1-name}    ${srlinux1-candidate}    interface[name=ethernet-1/1]/ethernet/auto-negotiate:::true
    Should Contain    ${result.stderr}    auto-negotiate not configurable when breakout-mode is enabled
    Should Be Equal As Integers    ${result.rc}    1

    DeleteCandidate    ${srlinux1-name}    ${srlinux1-candidate}

Set breakout-port num to 2 and port-speed to 100G
    LogMustStatements    ${srlinux1-schema-name}    ${srlinux1-schema-version}    ${srlinux1-schema-vendor}    interface[name=ethernet-1/1]/breakout-mode/breakout-port-speed
    LogMustStatements    ${srlinux1-schema-name}    ${srlinux1-schema-version}    ${srlinux1-schema-vendor}    interface[name=ethernet-1/1]/breakout-mode/num-breakout-ports

    CreateCandidate    ${srlinux1-name}    ${srlinux1-candidate}
    
    ${result} =     Set    ${srlinux1-name}    ${srlinux1-candidate}    interface[name=ethernet-1/1]/breakout-mode/breakout-port-speed:::25G
    Should Be Equal As Integers    ${result.rc}    0

    ${result} =     Set    ${srlinux1-name}    ${srlinux1-candidate}    interface[name=ethernet-1/1]/breakout-mode/num-breakout-ports:::2
    Should Be Equal As Integers    ${result.rc}    1
        Should Contain    ${result.stderr}    breakout-port-speed must be 100G when num-breakout-ports is 2

    DeleteCandidate    ${srlinux1-name}    ${srlinux1-candidate}



Set interface ethernet l2cp-transparency lldp tunnel true
    LogMustStatements    ${srlinux1-schema-name}    ${srlinux1-schema-version}    ${srlinux1-schema-vendor}    interface[name=ethernet-1/1]/ethernet/l2cp-transparency/lldp/tunnel

    CreateCandidate    ${srlinux1-name}    ${srlinux1-candidate}
    
    ${result} =     Set    ${srlinux1-name}    ${srlinux1-candidate}    interface[name=ethernet-1/1]/ethernet/l2cp-transparency/lldp/tunnel:::true
    Should Be Equal As Integers    ${result.rc}    0

    DeleteCandidate    ${srlinux1-name}    ${srlinux1-candidate}
