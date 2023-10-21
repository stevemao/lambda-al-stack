# Loosely based on https://timwspence.github.io/blog/posts/2019-08-02-optimized-docker-builds-for-haskell-stack.html
# And https://github.com/theam/aws-lambda-haskell-runtime/blob/main/stack-template.hsfiles#L69
ARG OUTPUT_DIR=/root/output
ARG EXECUTABLE_NAME=bootstrap

FROM public.ecr.aws/lambda/provided:al2 as dependencies

SHELL ["/bin/bash", "--rcfile", "~/.profile", "-c"]

USER root

RUN yum groupinstall -y "Development Tools"

# Installing Haskell Stack
RUN curl -sSL https://get.haskellstack.org/ | sh

WORKDIR /root/lambda-function-cache/

# Build the deps
RUN stack clean --full
RUN yum install -y gmp-devel ncurses-devel postgresql-devel

COPY stack.yaml stack.yaml.lock *.cabal package.yaml /root/lambda-function-cache/
RUN stack build --test --bench --dependencies-only

LABEL org.opencontainers.image.source="https://github.com/stevemao/lambda-al-stack"
LABEL org.opencontainers.image.description="Pre-build dependencies for Haskell stack on AWS Lambda using Amazon Linux"
