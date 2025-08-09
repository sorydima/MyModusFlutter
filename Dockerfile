# Dockerfile for Dart Shelf backend
FROM dart:stable AS build

WORKDIR /app
COPY pubspec.* /app/
RUN dart pub get

COPY . /app
RUN dart compile exe bin/server.dart -o /app/bin/server

FROM gcr.io/distroless/cc-debian11
COPY --from=build /runtime/ /
COPY --from=build /app/bin/server /app/bin/server
EXPOSE 8080
CMD ["/app/bin/server"]
