# s3_storage

> establishes storage & complimentary resources

## general configuration

- **name** - _str_ - name of the component
- **qualifier** - _str_ - value used to distinguish one instance of this component from another in one or more aws accounts ( e.g. 'environment', branch, user, etc )
- **subsystem** - _str_ - value used to group components into subsystems of the solution
- **kms_key_id** - _str_ - id or alias of kms key to use for encryption - if not supplied, a dedicated kms key and alias will be created and used
