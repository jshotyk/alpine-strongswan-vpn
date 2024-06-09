# Указываем базовый образ Alpine Linux версии edge
FROM alpine:3.18

# Обновляем репозиторий, добавляя edge/testing
RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories

# Устанавливаем StrongSwan
RUN apk --update add strongswan && \
    rm -rf /var/cache/apk/*

# Открываем порты для UDP (500 и 4500), используемых для IPsec
EXPOSE 500/udp \
       4500/udp

# Устанавливаем точку входа для контейнера
ENTRYPOINT ["/usr/sbin/ipsec"]

# Устанавливаем параметры запуска для StrongSwan
CMD ["start", "--nofork"]
