# Stage 1: Build the MkDocs site
FROM squidfunk/mkdocs-material AS build

WORKDIR /docs

# Copy MkDocs configuration and documentation source
COPY mkdocs.yml .
COPY docs/ docs/

# Build the static site
RUN mkdocs build

# Stage 2: Serve with Nginx
FROM nginx:alpine

# Copy the built static site to Nginx
COPY --from=build /docs/site /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
