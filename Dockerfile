# Use a lightweight web server
FROM nginx:alpine

# Copy your static site into the nginx default directory
COPY . /usr/share/nginx/html

EXPOSE 80
