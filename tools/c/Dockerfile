FROM python:2.7-alpine

# build args
ARG OMVERSION=
ARG GIT_COMMIT=dev
ARG GIT_COMMIT_SHORT=dev
ARG GIT_BRANCH=dev
ARG VERSION=dev

# install base requirements
RUN pip install --no-cache-dir flask environs redis

ADD app.py /
CMD ["python", "/app.py"]
