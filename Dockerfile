# -------------------------------------------------
# 1) Build-Stage
# -------------------------------------------------
FROM node:22.16.0-alpine AS builder

# Arbeitsverzeichnis im Container
WORKDIR /app

# Nur package.json und lockfile kopieren, um Layer-Caching zu ermöglichen
COPY package*.json ./

# Abhängigkeiten installieren
RUN npm ci --legacy-peer-deps

# Rest des Quellcodes kopieren
COPY . .

# Angular CLI lokal installieren (falls nicht in devDependencies)
RUN npm install @angular/cli@latest --no-save

# Anwendung bauen
RUN npx ng build --configuration=production

# -------------------------------------------------
# 2) Production-Stage
# -------------------------------------------------
FROM nginx:1.25-alpine AS production

# Entferne standardmäßiges nginx HTML
RUN rm -rf /usr/share/nginx/html/*

# Kopiere die gebauten Dateien aus dem Builder
COPY --from=builder /app/dist/angular-demo-application /usr/share/nginx/html

# Exponiere Port
EXPOSE 80

# Default-Command
CMD ["nginx", "-g", "daemon off;"]
