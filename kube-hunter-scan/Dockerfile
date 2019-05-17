FROM aquasec/kube-hunter:195

RUN pip install PyYAML==5.1

WORKDIR /usr/src/kube-hunter
COPY ./run.py /usr/src/kube-hunter/.

ENTRYPOINT ["python", "run.py"]