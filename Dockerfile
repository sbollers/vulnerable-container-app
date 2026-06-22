# DEMO ONLY — deliberately insecure container image.
# - End-of-life base image (node:8) with hundreds of known CVEs
# - Runs as root, installs build tools, no pinning
# Microsoft Defender for Cloud DevOps security + Trivy will flag this.
FROM node:8

# Run everything as root (CIS / Trivy: "Image user should not be 'root'")
USER root

WORKDIR /app

# Install deps from a vulnerable manifest
COPY app/package*.json ./
RUN npm install --unsafe-perm

COPY app/ .

# Secret baked into the image layer (credential scanner finding)
ENV API_TOKEN="ghp_DEMO000000000000000000000000000000"

EXPOSE 3000

# No healthcheck, no non-root user, no read-only fs
CMD ["node", "server.js"]
