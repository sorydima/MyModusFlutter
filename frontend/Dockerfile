# Build stage (requires Flutter tooling)
# This Dockerfile assumes the web build is produced outside or using CI.
# Final image serves static build via nginx.
FROM nginx:alpine AS runtime
COPY build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
