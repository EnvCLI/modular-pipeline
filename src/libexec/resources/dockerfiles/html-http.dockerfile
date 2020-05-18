##
# Base:
# * alpine
# * nginx
#
# Features:
# * unprivileged execution
#
# Networking:
# * 8080/tcp: HTTP Access
#
# Forwarding
# - NGINX_FORWARDING_ENABLED: false
# - NGINX_FORWARDING_PATH: /api
# - NGINX_FORWARDING_TARGET_HOST: google.com
# - NGINX_FORWARDING_TARGET_PATH: /api
##

############################################################
# Base Image
############################################################

# Build Args
ARG BASE_IMAGE

# Base Image
FROM ${BASE_IMAGE:-docker.io/nginxinc/nginx-unprivileged:1.18-alpine}

# Environment
ENV NGINX_FORWARDING_ENABLED false
ENV NGINX_FORWARDING_PATH "/api"
ENV NGINX_FORWARDING_PROTOCOL "http"
ENV NGINX_FORWARDING_TARGET_HOST "jsonplaceholder.typicode.com"
ENV NGINX_FORWARDING_TARGET_PATH ""
ENV NGINX_RESOLVER_IP "8.8.8.8"

############################################################
# Installation
############################################################

# dependencies
USER root
RUN apk add --no-cache curl bash gettext &&\
  # helper to escape bash values
  printf "#!/usr/bin/env bash\n(echo \"\$1\" | sed -e 's/[]\/\$*.^[]/\\\\\\&/g')" >> /usr/local/bin/helper-escape-value &&\
  chmod +x /usr/local/bin/helper-escape-value &&\
	# Entrypoint
	printf '#!/usr/bin/env bash\n\
set -euo pipefail\n\
\n\
# provide env configuration\n\
# - get all available env variables\n\
tmpVariablesFile=$(mktemp)\n\
compgen -v > $tmpVariablesFile\n\
readarray -t ALL_VARIABLES < $tmpVariablesFile\n\
rm $tmpVariablesFile\n\
unset tmpVariablesFile\n\
\n\
# - try to search for common configuration files and replace the values\n\
for KEY in "${ALL_VARIABLES[@]}"; do\n\
  # ignore\n\
  if [[ $KEY =~ ^(_|ALL_VARIABLES|KEY|VALUE|PWD|SUDO_COMMAND|LC_.*|FUNCNAME|EPOCHREALTIME|DOCKER_.*|SSH_CLIENT|SSH_CONNECTION|SSH_TTY|LESSCLOSE|WSLENV|WSL_DISTRO_NAME|XDG_DATA_DIRS|COMP_WORDBREAKS|LS_COLORS|PROMPT_COMMAND|XDG_RUNTIME_DIR|PS[0-9]|SHELL|LOGNAME|OPTERR|OPTIND|OSTYPE|PATH|SHELLOPTS|UID|USER|colors|MACHTYPE|MAIL|LESSOPEN|IFS|ID|HOSTTYPE|HOSTNAME|HOME|HIST.*|GROUPS|COLUMNS|DIRSTACK|LANG|LINES|LINENO|PPID|PIPESTATUS|RANDOM|SECONDS|SHLVL|TERM|BASH.*)$ ]]; then\n\
    continue\n\
  fi\n\
\n\
  VALUE=${!KEY:-}\n\
  VALUE_ESC=$(helper-escape-value "$VALUE")\n\
\n\
  # script syntax: window.VAR_NAME (only replace if the var is found)\n\
  if cat /usr/share/nginx/html/index.html | grep -q "$KEY"; then\n\
    sed -i "s/window.${KEY}.*$/window.${KEY} = \\"${VALUE_ESC}\\"/g" /usr/share/nginx/html/index.html\n\
  fi\n\
  # nginx config templates:\n\
  if cat /etc/nginx/conf.d/default.apiforwarding | grep -q "$KEY"; then\n\
    sed -i "s/\$${KEY}/${VALUE_ESC}/g" /etc/nginx/conf.d/default.apiforwarding\n\
  fi\n\
done\n\
\n\
if echo "$NGINX_FORWARDING_ENABLED" | grep -q "true"; then\n\
  echo "Overwriting /etc/nginx/conf.d/default.conf for configurable path forwarding"\n\
  cp /etc/nginx/conf.d/default.apiforwarding /etc/nginx/conf.d/default.conf\n\
fi\n\
\n\
# real entrypoint\n\
exec "$@"\n\
\n' >> /entrypoint.sh &&\
cat /entrypoint.sh &&\
    chmod +x /entrypoint.sh &&\
    printf 'server {\n\
    listen       8080;\n\
    server_name  localhost;\n\
\n\
    location / {\n\
        root   /usr/share/nginx/html;\n\
        index  index.html index.htm;\n\
    }\n\
\n\
    location ~$NGINX_FORWARDING_PATH(.*)$  {\n\
      resolver $NGINX_RESOLVER_IP ipv6=off;\n\
      proxy_redirect off;\n\
      proxy_set_header Host $NGINX_FORWARDING_TARGET_HOST;\n\
      proxy_set_header X-Real-IP $remote_addr;\n\
      proxy_set_header X-Forwarded-Host $http_host;\n\
      proxy_pass "$NGINX_FORWARDING_PROTOCOL://$NGINX_FORWARDING_TARGET_HOST$NGINX_FORWARDING_TARGET_PATH$1";\n\
    }\n\
}' >> /etc/nginx/conf.d/default.apiforwarding

# copy files from rootfs to the container
ADD dist /usr/share/nginx/html

# permissions
RUN chown -R 101:0 /usr/share/nginx/html &&\
    chmod 775 -R /usr/share/nginx/html &&\
    chown -R 101:0 /etc/nginx &&\
    chmod 775 -R /etc/nginx

############################################################
# Execution
############################################################

# execution user
USER 101

# working directory
WORKDIR /usr/share/nginx/html

# expose
EXPOSE 8080/tcp

# entrypoint
ENTRYPOINT [ "/entrypoint.sh" ]

# cmd
CMD ["nginx", "-g", "daemon off;"]
