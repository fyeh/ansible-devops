cp4d_db2wh_backup
==========

This role runs a backup procedure from a CloudPak for Data DB2 Warehouse instance and stores the backup files in a targetted local folder.
At the end of the backup process, you will find the required files to run a successful restore process in the chosen `DB2WH_BACKUP_DIR`:

- DB2 backup files i.e `BLUDB.0.db2inst1.DBPART000.202XXXXXXXXXXX.001`
- DB2 keystore files (.p12 and .sth)
- DB2 instance master key label file (.kdb)

Role Variables
--------------

### db2wh_backup_dir
Required. Local directory that will store the backup files taken from the DB2 Warehouse instance i.e `/Users/Documents/db_backup`.

- Environment Variable: `DB2WH_BACKUP_DIR`
- Default: None

### db2wh_instance_name
Required. DB2 Warehouse source instance to take the backup from i.e `db2wh-iot`.

- Environment Variable: `DB2WH_INSTANCE_NAME_SOURCE`
- Default: None

Example Playbook
----------------

```yaml
- hosts: localhost
  any_errors_fatal: true
  vars:
    db2wh_backup_folder: "{{ lookup('env', 'DB2WH_BACKUP_DIR') }}"
    db2wh_instance_name: "{{ lookup('env', 'DB2WH_INSTANCE_NAME_SOURCE') }}"
  roles:
    - ibm.mas_devops.cp4d_db2wh_backup
```

License
-------

EPL-2.0

Note: Support for DB2 Warehouse instances running on CP4D v3.5
--------
Smart detection of CPD namespace is in place for this role, which means it will use default namespaces accordingly to the CPD version identified.
If running this role against a DB2 Warehouse instance in CPD v3.5 version, it will expect you to have a config map named `"mas-automation-config-{{ db2wh_instance_name }}"` in the same namespace as your CP4D is installed, in order for `db2wh_instance_id` property to be correctly defined, such as below:

```
kind: ConfigMap
apiVersion: v1
metadata:
  name: mas-automation-config-db2wh-iot
  namespace: cpd-meta-ops
data:
  db2wh_instance_id: '1618938039379016'
```

This config-map is automatically generated if you used `ibm/mas_devops/roles/cp4d_db2wh` role to create your DB2 Warehouse instance.
However, if running this role as a standalone playbook and such config map is not found, the backup/restore process will fail.
For DB2 Warehouse instance in CPD v4.0 version, no action regarding config map setup is needed, as the required `db2wh_instance_name` property is enough, therefore the role will be executed properly without further interventions.