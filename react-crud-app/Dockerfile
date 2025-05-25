# Build React app
FROM node:22 AS build
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Production image
FROM node:22-alpine
WORKDIR /app

# Install only production dependencies
COPY package*.json ./
RUN npm install --only=production

# Copy build output and server files
COPY --from=build /app/build ./build
COPY server.js ./
COPY newrelic.js ./
COPY .env ./

# Expose port
EXPOSE 5000

# Start the server
CMD ["node", "server.js"]
