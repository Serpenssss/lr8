FROM postgres:latest
ENV POSTGRES_PASSWORD=dbpass
ENV POSTGRES_USER=dbuser
ENV POSTGRES_DB=dbname
COPY lr-8_scripts/lr-8.sql /docker-entrypoint-initdb.d/lr-8.sql
VOLUME /d_data:/var/lib/postgresql/data