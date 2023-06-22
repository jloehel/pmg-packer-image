Host azure.jumpbox.pmg
    HostName ${jumpbox_host}
    Port 22
    User ${ansible_user}
    IdentityFile ${ansible_key}

Host ${pmg_nodes}
    Port 22
    ProxyJump azure.jumpbox.pmg
    User ${ansible_user}
    IdentityFile ${ansible_key}

