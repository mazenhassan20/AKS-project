# Stage 1: Build Stage
FROM node:18-alpine AS build

WORKDIR /usr/src/app

COPY package*.json ./
RUN npm install

COPY . .
# عمل Build للمشروع (هيطلع فولدر اسمه build أو dist)
RUN npm run build

# Stage 2: Production Stage
FROM nginx:stable-alpine

# نسخ الملفات الناتجة من الـ Build لسيرفر Nginx
COPY --from=build /usr/src/app/build /usr/share/nginx/html

# نسخ ملف إعدادات Nginx (اختياري بس يفضل)
# EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
