## GitHub Snyk Check container

The purpose of this check is to see if Snyk is running checks on a GitHub repo.

The following environmental variables are required:

| Name      | Description                                                                          | Default |
| --------- | ------------------------------------------------------------------------------------ | ------- |
| REPO_URL  | The full URL of the GitHub repo to check ex. `https://github.com/cds-snc/security-goals` | `""`    |
| SATISFIES | The controls this check satisfies ex. 'AB-12'                                        | `""`    |

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
  name: 'github-snyk'
  namespace: security-goals
spec:
  template:
    spec:
      restartPolicy: Never
      containers:
        - image: 'gcr.io/security-goals/checks/github-snyk:latest'
          imagePullPolicy: Always
          name: 'github-snyk'
          env:
            - name: ORIGIN
              value: 'gcr.io/security-goals/checks/github-snyk:latest'
            - name: COMPONENT
              value: 'Source code'
            - name: DESCRIPTION
              value: 'The application uses Snyk to do security analysis on GitHub repos.'
            - name: SATISFIES
              value: 'AB-12'
            - name: REPO
              value: 'https://github.com/cds-snc/security-goals'
          volumeMounts:
            - name: compliance-checks
              mountPath: /checks
      volumes:
        - name: compliance-checks
          persistentVolumeClaim:
claimName: checks-claim
```
