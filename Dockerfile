FROM python:3.12-slim

RUN apt-get update && apt-get install -y cron && apt-get clean

ENV TZ=UTC

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . /app

COPY crontab.txt /etc/cron.d/crypto-cron

RUN chmod 0644 /etc/cron.d/crypto-cron && \
    crontab /etc/cron.d/crypto-cron

RUN touch /var/log/cron.log

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]
