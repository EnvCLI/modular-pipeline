# Global Properties

## ARTIFACT_DIR

All generated artifacts will be placed in /dist or it's subdirectories. The path `dist` can be changed by setting `ARTIFACT_DIR`.

## ARTIFACT_BUILD_ARCHS

The target architecture to build the application for.

Default value: `linux_amd64`

Supported values:

- linux_386
- linux_amd64
- linux_arm32v6
- linux_arm32v7
- linux_arm64v8
- windows_386
- windows_amd64
- darwin_386
- darwin_amd64

The value should be transformed as needed for golang / docker / and others.
