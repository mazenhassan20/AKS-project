# ===============================
# Stage 1: Builder
# ===============================
FROM node:18-slim AS builder

RUN apt-get update -y && apt-get install -y openssl

WORKDIR /usr/src/app

COPY package*.json ./
RUN npm ci

COPY . .

RUN npx prisma generate

# ===============================
# Stage 2: Runner
# ===============================
FROM node:18-slim

RUN apt-get update -y && apt-get install -y openssl

WORKDIR /usr/src/app

COPY --from=builder /usr/src/app/node_modules ./node_modules
COPY --from=builder /usr/src/app .

EXPOSE 3000

CMD ["npm", "start"]
