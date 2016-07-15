Ansible and Docker-Skydive OVN Emulation Guide
============================================

Overview
--------

Deploy an OVN-Skydive emulation environment using Docker containers and Ansible

**Why use Docker?**

Docker allows deploying OVN emulation in a fast and consistent fashion.
Compiling OVS/OVN source is done once in one docker host, rather than
repetitively in every host. The same docker image will be distributed to all the
physical hosts by Ansible.


Host machine requirements
-------------------------

The recommended emulation target requirements:

- 1 deploy node to run Ansible deployment script
- 1 host to run OVN database node
- 2 hosts to run emulated OVN chassis container
- 1 host to run skydive analyzer (could be the same as the OVN database node)

In the image below, it should be Skydive Analyzer instead of Rally-OVN.

.. image:: ovn-emulation-deployment.png
   :alt: OVN emulation deployment


.. note:: The above setting is just an example. For example, all OVN emulated
   chassis could be run on one host. For example, an all-in-one configuration
   deploys all containers on a single host.


Installing Dependencies
-----------------------

The deployer node needs Ansible. All the other nodes should have docker engine
installed. The following python package are required on all the nodes as well.

NOTE: These dependencies will be automatically installed by setting
``enable_docker_install:`` to true in ``ansible/group_vars/all.yml``. Once all
is installed in the nodes, make sure to set the value back to false to avoid
running the install scripts all over again.

::

    pip install -U docker-py netaddr


.. note:: If you are a first time user, please run all the following commands as
   ``root`` user literally, not sudo and set ``deploy_user: "root"`` in
   ``ansible/group_vars/all.yml``. As getting familiar with the framework,
   variable ``deploy_user`` can be configured.


Setup the emulation environment
-------------------------------
.. _Deploy:

Add hosts to the ansible inventory file

::

    ansible/inventory/ovn-hosts

The ansible node should be able to access the other nodes password-less. So ssh
key of the ansible node should be added to the other nodes.

Start by editing ansible/group_vars/all.yml to fit your testbed.

For example, to define the total number of emulated chasis in the network:

::

    ovn_db_image: "sivakom/ovn-scale-test"
    ovn_chassis_image: "sivakom/ovn-scale-test"
    ovn_number_chassis: 10

During deployment, these chassis will be evenly distributed on the emulation
hosts, which are defined in the inventory file.

OVN control containers can also be pinned to particular cores by setting the
following variables.

::

   north_db_cpu_set: "1"
   south_db_cpu_set: "2"
   northd_cpu_set: "3"

The skydive config files would also have to have to be slightly modified. Within
the ``ansible/roles/skydive/templates/skydive.yml``, make sure to change the
values for ``agent.analyzers`` and ``storage.elasticsearch`` in order to get
skydive agents to communicate with the skydive analyzer. Specifically, the ip
address of the host machine housing the skydive analyzer container along with
the port should be inserted.

For example
::
   agent:
     analyzers: <IP of analyzer container's host>:8082
   .
   .
   .
   storage:
     elasticsearch: <IP of analyzer container's host>:9200


Deploying OVN Emulation
-----------------------

Run the ansible playbook

::

    ansible-playbook  -i ansible/inventory/ovn-hosts ansible/site.yml -e action=deploy

The above command deploys ovn control plane containers and the emulated chassis.

Ansible allows you to overide the variables in group_vars/all.yml. For example,
some variables are defined in a separate file, named
/etc/new-nodes-variables.yml. To ask ansible to override the default variables,
run the playbook as follows:

::

    ansible-playbook  -i ansible/inventory/ovn-hosts ansible/site.yml -e @/etc/new-nodes-variables.yml -e action=deploy

The fastest way during evaluation to re-deployment is to remove the OVN
containers and re-deploy.

To clean up the existing emulation deployment,

::

    ansible-playbook  -i ansible/inventory/ovn-hosts ansible/site.yml -e action=clean


Setting up Skydive
------------------

After finishing up the deploy, the skydive analyzer container should be up
and running but we still have to setup the agent processes. In order to get those
kicked off, run the following on each of the chassis hosts.

::

    port=8081
    for i in $(docker ps | tail -n +2 |  awk '{print $NF}' | sort); do
      docker exec -it $i sed -i "s/  listen: 8081/  listen: $port/g" /go/src/github.com/redhat-cip/skydive/etc/skydive.yml
      docker exec -dit $i skydive agent --conf /go/src/github.com/redhat-cip/skydive/etc/skydive.yml
      port=$((port+1))
    done

After this, take a look at the analyzer GUI to see if the agent processes are
showing up. Alternately, you can go over into the analyzer host and try running
the following and see if you can get any output.

::

    curl http://localhost:8082/api/topology
