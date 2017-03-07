FROM python:3-slim

MAINTAINER Azavea

RUN apt-get update && apt-get install -y --no-install-recommends \
    ipython \
    python3-pip \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt /tmp/
RUN pip3 install --upgrade pip && pip3 install --no-cache-dir -r /tmp/requirements.txt

COPY ./ /opt/verifier

WORKDIR /opt/verifier

ENTRYPOINT ["./compare_outputs.sh"]

CMD []
