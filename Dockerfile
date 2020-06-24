FROM openresty/openresty:alpine

RUN apk --no-cache add net-tools tcpdump curl tzdata gettext && \
    cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

#ADD nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
ADD nginx.conf.template /tmp/nginx.conf.template

#CMD ["/usr/local/openresty/bin/openresty","-g","daemon off;"]
#CMD ["/bin/sh -c envsubst '$SERVICE-FQDN $WEBP-SERVER $ORG-SERVER' \
#CMD ["envsubst '$$SERVICE-FQDN$$WEBP-SERVER$$ORG-SERVER' < /tmp/nginx.conf.template > /usr/local/openresty/nginx/conf/nginx.conf && /usr/local/openresty/bin/openresty -g daemon off; ","",""]
CMD envsubst '$$SERVICE_FQDN$$WEBP_SERVER$$ORG_SERVER$$ORG_PORT$$ORG_PREFIX' < /tmp/nginx.conf.template > /usr/local/openresty/nginx/conf/nginx.conf && /usr/local/openresty/bin/openresty -g 'daemon off;'
