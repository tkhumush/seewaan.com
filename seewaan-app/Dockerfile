# Multi-stage build for Seewaan React app
FROM node:20-alpine AS builder

WORKDIR /app

# Clone the Seewaan repository
RUN apk add --no-cache git && \
    git clone https://github.com/tkhumush/Seewaan.git . && \
    npm install && \
    npx vite build

# Production stage with nginx
FROM nginx:alpine

# Copy built assets from builder stage
COPY --from=builder /app/dist /usr/share/nginx/html

# Create directory for public files (.well-known, favicon)
RUN mkdir -p /usr/share/nginx/html/public

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s \
  CMD wget --quiet --tries=1 --spider http://localhost:80 || exit 1

CMD ["nginx", "-g", "daemon off;"]
