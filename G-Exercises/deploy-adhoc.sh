#/bin/bash
mkdir ~/deploy-adhoc
echo -e "[defaults]\ninventory=inventory" > ~/deploy-adhoc/ansible.cfg
echo -e "[control_node]\nlocalhost\n[intranetweb]\servera.lab.example.com" > ~/deploy-adhoc/inventory