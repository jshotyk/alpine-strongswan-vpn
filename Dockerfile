# Указываем базовый образ Alpine Linux версии 3.18
FROM alpine:3.18

# Переменные окружения для генерации PKI
ENV CONFIG_DIR=/etc/ipsec.d \
    IPSEC="ipsec" \
    C="RU" \
    O="MyOrganization" \
    CA_CN="MyCA" \
    SERVER_CN="server.myorganization.com" \
    SERVER_SAN="server.myorganization.com" \
    CLIENT_CN="client.myorganization.com"

# Обновляем репозиторий и устанавливаем StrongSwan и OpenSSL
RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    apk --no-cache update && \
    apk --no-cache add strongswan openssl

# Создаем необходимые директории для хранения PKI
RUN mkdir -p $CONFIG_DIR/private $CONFIG_DIR/cacerts $CONFIG_DIR/certs

# Генерация ключа и сертификата CA
RUN eval $IPSEC pki --gen --outform pem > $CONFIG_DIR/private/caKey.pem && \
    eval $IPSEC pki --self --in $CONFIG_DIR/private/caKey.pem --dn "C=$C, O=$O, CN=$CA_CN" --ca --outform pem > $CONFIG_DIR/cacerts/caCert.pem && \
    echo "CA ключ и сертификат созданы:" && \
    ls -l $CONFIG_DIR/private/ && ls -l $CONFIG_DIR/cacerts/

# Генерация ключа и сертификата сервера
RUN eval $IPSEC pki --gen --outform pem > $CONFIG_DIR/private/serverKey.pem && \
    eval $IPSEC pki --issue --in $CONFIG_DIR/private/serverKey.pem --type priv --cacert $CONFIG_DIR/cacerts/caCert.pem --cakey $CONFIG_DIR/private/caKey.pem --dn "C=$C, O=$O, CN=$SERVER_CN" --san="$SERVER_SAN" --flag serverAuth --flag ikeIntermediate --outform pem > $CONFIG_DIR/certs/serverCert.pem && \
    echo "Серверный ключ и сертификат созданы:" && \
    ls -l $CONFIG_DIR/private/ && ls -l $CONFIG_DIR/certs/

# Генерация ключа и сертификата клиента
RUN eval $IPSEC pki --gen --outform pem > $CONFIG_DIR/private/clientKey.pem && \
    eval $IPSEC pki --issue --in $CONFIG_DIR/private/clientKey.pem --type priv --cacert $CONFIG_DIR/cacerts/caCert.pem --cakey $CONFIG_DIR/private/caKey.pem --dn "C=$C, O=$O, CN=$CLIENT_CN" --san="$CLIENT_CN" --outform pem > $CONFIG_DIR/certs/clientCert.pem && \
    openssl pkcs12 -export -inkey $CONFIG_DIR/private/clientKey.pem -in $CONFIG_DIR/certs/clientCert.pem -name "$CLIENT_CN" -certfile $CONFIG_DIR/cacerts/caCert.pem -caname "$CA_CN" -out $CONFIG_DIR/clientCert.p12 -passout pass:your_password_here && \
    echo "Клиентский ключ и сертификат созданы:" && \
    ls -l $CONFIG_DIR/private/ && ls -l $CONFIG_DIR/certs/ && ls -l $CONFIG_DIR/

# Открываем порты для UDP (500 и 4500), используемых для IPsec
EXPOSE 500/udp \
       4500/udp

# Устанавливаем точку входа для контейнера
ENTRYPOINT ["/usr/sbin/ipsec"]

# Устанавливаем параметры запуска для StrongSwan
CMD ["start", "--nofork"]
