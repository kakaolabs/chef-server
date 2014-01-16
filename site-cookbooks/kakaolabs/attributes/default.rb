# meetme plugin
default[:meetme][:plugins] = [
  "nginx",
  "redis",
  "rabbitmq",
  "uwsgi"
]

default[:meetme][:nginx][:status_port] = 8090
