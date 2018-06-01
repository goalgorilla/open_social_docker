FROM alpine:3.6

RUN apk add --update nginx

RUN set -ex \
    && apk update \
	&& apk add --no-cache --virtual .build-deps \
		nginx \
		bash \
        bash-completion \
        nano \
        vim \
        curl

ADD nginx.conf /etc/nginx/

RUN adduser -D -g '' -G www-data www-data

# Add .bashrc
RUN touch /root/.bashrc \
    && echo 'export PS1="\w \\$ "' >> /root/.bashrc

CMD ["nginx"]

EXPOSE 80
EXPOSE 443
