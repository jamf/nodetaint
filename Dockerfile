FROM --platform=$BUILDPLATFORM golang:1.25.3 AS build-controller

WORKDIR /build

# Cache dependencies
COPY go.mod . go.sum ./
RUN go mod download && go mod verify

ARG TARGETARCH TARGETOS

# Copy source and build
COPY . .
RUN CGO_ENABLED=0 GOARCH=${TARGETARCH} GOOS=${TARGETOS} go build -o nodetaint -a -installsuffix cgo .

FROM gcr.io/distroless/static:nonroot

ENV VERSION=prod

LABEL maintainer="kube-express" \
      description="Node taint controller for Kubernetes" \
      version="${VERSION}"

COPY --from=build-controller --chown=nonroot:nonroot /build/nodetaint /nodetaint

ENTRYPOINT ["/nodetaint"]
