FROM dart:stable AS build
WORKDIR /app
COPY pubspec.* ./
RUN dart pub get
COPY . .
RUN dart compile exe bin/server.dart -o bin/server

FROM debian:stable-slim
COPY --from=build /runtime/ /runtime/
COPY --from=build /app/bin/server /usr/local/bin/server
EXPOSE 8080
CMD ["/usr/local/bin/server"]
