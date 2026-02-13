# ===============================
# Stage 1: Builder
# ===============================
# هنستخدم slim بدل alpine عشان نحل مشاكل الـ SSL
FROM node:18-slim AS builder

# لازم نسطب OpenSSL عشان بريزما تشتغل
RUN apt-get update -y && apt-get install -y openssl

WORKDIR /usr/src/app

COPY package*.json ./
RUN npm ci

COPY . .

# توليد ملفات بريزما (دلوقتي هتشتغل على debian)
RUN npx prisma generate

# ===============================
# Stage 2: Runner
# ===============================
FROM node:18-slim

# لازم نسطب OpenSSL في المرحلة النهائية برضه
RUN apt-get update -y && apt-get install -y openssl

WORKDIR /usr/src/app

COPY --from=builder /usr/src/app/node_modules ./node_modules
COPY --from=builder /usr/src/app .

EXPOSE 3000

CMD ["npm", "start"]
