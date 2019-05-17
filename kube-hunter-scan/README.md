## Kube Hunter scan container

The purpose of this check is to see if [Kube Hunter](https://github.com/aquasecurity/kube-hunter) can find any vulnerabilities in your kubernetes cluster. If you specify a `DOMAIN_NAME` environmental variable it will run the scan as if from the outside. If it is not provided, it will run the scan as a pod in the cluster.

The following environmental variables are required:

| Name      | Description                                                                          | Default |
| --------- | ------------------------------------------------------------------------------------ | ------- |
| SATISFIES | The controls this check satisfies ex. 'AB-12'                                        | `""`    |

The following environmental variables are optional:

| Name        | Description                                                             | Default                 |
| ----------- | ----------------------------------------------------------------------- | ----------------------- |
| DOMAIN_NAME | The domain name to scan. ex: `security-goals-demo.cdssandbox.xyz`       | False                   |
| COMPONENT   | The component of the application this check refers to ex. `Source code` | `"Missing component"`   |
| DESCRIPTION | A description of what the check does                                    | `"Missing description"` |
| ORIGIN      | The name of the docker container that ran the check                     | `"Missing origin"`      |
| OUT_PATH    | The directory the output JSON gets written to                           | `"/checks/"`            |

A job might look something like this:

```
apiVersion: batch/v1
kind: Job
metadata:
  name: 'kube-hunter-scan'
  namespace: security-goals
spec:
  template:
    spec:
      restartPolicy: Never
      containers:
        - image: 'gcr.io/security-goals/checks/kube-hunter-scan:latest'
          imagePullPolicy: Always
          name: 'kube-hunter-scan'
          env:
            - name: ORIGIN
              value: 'gcr.io/security-goals/checks/kube-hunter-scan:latest'
            - name: COMPONENT
              value: 'Infrastructure'
            - name: DESCRIPTION
              value: 'The uses Kube Hunter to scan for vulnerabilities.'
            - name: SATISFIES
              value: 'AB-12'
            - name: DOMAIN_NAME
              value: 'security-goals-demo.cdssandbox.xyz'
          volumeMounts:
            - name: compliance-checks
              mountPath: /checks
      volumes:
        - name: compliance-checks
          persistentVolumeClaim:
claimName: checks-claim
```
