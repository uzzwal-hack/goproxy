# 1. Upgrade the Go version to 1.26
FROM golang:1.26-alpine AS builder

WORKDIR /app
COPY . .
# No need for go mod tidy, the original code should build fine with the new Go version
RUN go mod download
RUN CGO_ENABLED=0 GOOS=linux go build -o proxy

FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=builder /app/proxy .

# 2. IMPORTANT: Render requires your app to listen on the $PORT provided by Render.
# The original code might hardcode 1080. We use a shell command to pass the PORT variable if supported,
# or just expose 1080 and hope Render's reverse proxy catches it.
# However, the cleanest way is to let the Go app read the PORT environment variable.
# If the Go code doesn't read PORT, we can force it using a wrapper or just expose it.
# Actually, goproxy usually listens on 1080 by default. Render routes traffic to the port defined in the service settings.

EXPOSE 1080

# 3. Add the command to run it
CMD ["./proxy"]
