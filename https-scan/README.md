## HTTPS Scan

The purpose of this check is to see if a domain is compliant with the the (Information Technology Policy Implementation Notice (ITPIN))[https://www.canada.ca/en/government/system/digital-government/modern-emerging-technologies/policy-implementation-notices/implementing-https-secure-web-connections-itpin.html].

The following environmental variables are required:

| Name      | Description                                                                                          | Default |
| --------- | ---------------------------------------------------------------------------------------------------- | ------- |
| DOMAIN    | The domain to scan                                                                                   | `""`    |
| SATISFIES | The controls this check satisfies ex. 'AB-12'                                                        | `""`    |

The following environmental variables are optional:

| Name        | Description                                                             | Default                 |
| ----------- | ----------------------------------------------------------------------- | ----------------------- |
| COMPONENT   | The component of the application this check refers to ex. `Source code` | `"Missing component"`   |
| DESCRIPTION | A description of what the check does                                    | `"Missing description"` |
| ORIGIN      | The name of the docker container that ran the check                     | `"Missing origin"`      |
| OUT_PATH    | The directory the output JSON gets written to                           | `"/checks/"`            |

A job might look something like this:

```
apiVersion: batch/v1
kind: Job
metadata:
  name: 'https-scan'
  namespace: security-goals
spec:
  template:
    spec:
      restartPolicy: Never
      containers:
        - image: 'gcr.io/security-goals/checks/https-scan:latest'
          imagePullPolicy: Always
          name: 'https-scan'
          env:
            - name: ORIGIN
              value: 'gcr.io/security-goals/checks/https-scan:latest'
            - name: COMPONENT
              value: 'Source code'
            - name: DESCRIPTION
              value: 'This application follows the ITPIN guidelines'
            - name: SATISFIES
              value: 'AB-12'
            - name: DOMAIN
              value: 'digital.canada.ca
          volumeMounts:
            - name: compliance-checks
              mountPath: /checks
      volumes:
        - name: compliance-checks
          persistentVolumeClaim:
claimName: checks-claim
```
