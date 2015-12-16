FROM alpine:edge

# install common packages
RUN apk update && \
	apk add iptables pptpd ppp ppp-radius freeradius-radclient freeradius-client

COPY entrypoint.sh /usr/bin/entrypoint.sh
COPY pptpd.conf /etc/pptpd.conf

VOLUME ["/var/lib/pptpd"]

ENTRYPOINT ["/usr/bin/entrypoint.sh"]
CMD [""]

EXPOSE 1723
