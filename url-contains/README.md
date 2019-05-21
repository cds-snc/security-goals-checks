## URL Contains check

The purpose of this check is to see if a URL returns a body that contains a needle. The needle can either be a string or a regular expression,

The following environmental variables are required:

| Name      | Description                                                                                          | Default |
| --------- | ---------------------------------------------------------------------------------------------------- | ------- |
| NEEDLE    | The string to search for, ex: "Lipsum"                                                               | `""`    |
| URL       | The URL to check ex. `https://lipsum.com/`                                                           | `""`    |
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
  name: 'url-contains'
  namespace: security-goals
spec:
  template:
    spec:
      restartPolicy: Never
      containers:
        - image: 'gcr.io/security-goals/checks/url-contains:latest'
          imagePullPolicy: Always
          name: 'url-contains'
          env:
            - name: ORIGIN
              value: 'gcr.io/security-goals/checks/url-contains:latest'
            - name: COMPONENT
              value: 'Source code'
            - name: DESCRIPTION
              value: 'This application uses X because it is found in Y file.'
            - name: SATISFIES
              value: 'AB-12'
            - name: URL
              value: 'https://lipsum.com'
            - name: NEEDLE
              value: 'lipsum'
          volumeMounts:
            - name: compliance-checks
              mountPath: /checks
      volumes:
        - name: compliance-checks
          persistentVolumeClaim:
claimName: checks-claim
```
