FROM rust:latest AS builder
WORKDIR /usr/src/app
COPY . .

RUN cargo install --path .

FROM debian:buster-slim
COPY --from=builder /usr/local/cargo/bin/sfdc_realtime /usr/local/bin/sfdc_realtime

EXPOSE 8080

CMD ["sfdc_realtime"]

