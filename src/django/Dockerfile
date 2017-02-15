FROM quay.io/azavea/django:1.10.3

MAINTAINER Azavea

RUN pip install --upgrade pip

COPY requirements.txt /tmp/
RUN pip install --no-cache-dir -r /tmp/requirements.txt

COPY . /usr/src
WORKDIR /usr/src

EXPOSE 9210

CMD ["-w", "1", \
     "-b", "0.0.0.0:9202", \
     "--reload", \
     "--log-level", "info", \
     "--error-logfile", "-", \
     "--forwarded-allow-ips", "*", \
     "-k", "gevent", \
     "base.wsgi"]
