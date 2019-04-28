FROM alpine:3.9 AS builder

RUN apk add --update-cache --no-cache curl openssl ca-certificates

WORKDIR /tmp

ENV KUBECTL_VERSION=1.12.7
ENV KUBECTL_DOWNLOAD_URL=https://storage.googleapis.com/kubernetes-release/release/v$KUBECTL_VERSION/bin/linux/amd64/kubectl
RUN curl -sSLO $KUBECTL_DOWNLOAD_URL && \
    echo "$(curl -sSL $KUBECTL_DOWNLOAD_URL.sha512)  kubectl" | tee kubectl.sha512 && \
    sha512sum -cw kubectl.sha512

ENV AWS_IAM_AUTHENTICATOR_VERSION=1.12.7
ENV AWS_IAM_AUTHENTICATOR_RELEASE_DATE=2019-03-27
ENV AWS_IAM_AUTHENTICATOR_DOWNLOAD_URL=https://amazon-eks.s3-us-west-2.amazonaws.com/$AWS_IAM_AUTHENTICATOR_VERSION/$AWS_IAM_AUTHENTICATOR_RELEASE_DATE/bin/linux/amd64/aws-iam-authenticator
RUN curl -sSLO $AWS_IAM_AUTHENTICATOR_DOWNLOAD_URL && \
    curl -sSL $AWS_IAM_AUTHENTICATOR_DOWNLOAD_URL.sha256 | sed 's/ /  /' | tee aws-iam-authenticator.sha256 && \
    sha256sum -cw aws-iam-authenticator.sha256

WORKDIR /tmp/prepared

RUN cp /tmp/kubectl . && \
    cp /tmp/aws-iam-authenticator . && \
    chmod +x *

FROM alpine:3.9

RUN apk add --update-cache --no-cache docker python3 && \
    pip3 install --upgrade --progress-bar off awscli

COPY --from=builder /tmp/prepared /usr/local/bin
