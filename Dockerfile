FROM louislam/uptime-kuma:base-debian AS build
WORKDIR /app

ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=1

COPY . .
RUN npm install && npm run build && \
    chmod +x /app/extra/entrypoint.sh


FROM louislam/uptime-kuma:base-debian AS release
WORKDIR /app

# Copy app files from build layer
COPY --from=build /app /app

EXPOSE 3001
VOLUME ["/app/data"]
HEALTHCHECK --interval=60s --timeout=30s --start-period=180s --retries=5 CMD node extra/healthcheck.js
ENTRYPOINT ["/usr/bin/dumb-init", "--", "extra/entrypoint.sh"]
CMD ["node", "server/server.js"]


FROM release AS nightly
RUN npm run mark-as-nightly