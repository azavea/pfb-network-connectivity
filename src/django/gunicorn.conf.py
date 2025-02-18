import os

bind = ":9202"
accesslog = "-"
errorlog = "-"
workers = 3
worker_class = 'gevent'
loglevel = "Info"

ENVIRONMENT = os.getenv("DJANGO_ENV", "dev")

if ENVIRONMENT == "development":
    reload = True
else:
    preload = True

wsgi_app = "pfb_network_connectivity.wsgi"
