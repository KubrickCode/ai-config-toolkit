set dotenv-load := true

root_dir := justfile_directory()

deps:
    pnpm install

lint target="all":
    #!/usr/bin/env bash
    set -euox pipefail
    case "{{ target }}" in
      all)
        just lint justfile
        just lint config
        ;;
      justfile)
        just --fmt --unstable
        ;;
      config)
        npx prettier --write --cache "**/*.{json,yml,yaml,md}"
        ;;
      *)
        echo "Unknown target: {{ target }}"
        exit 1
        ;;
    esac

# 단일 파일 린트 (hooks에서 호출)
lint-file file:
    #!/usr/bin/env bash
    set -euo pipefail
    case "{{ file }}" in
      */justfile|*Justfile)
        just --fmt --unstable
        ;;
      *.json|*.yml|*.yaml|*.md)
        npx prettier --write --cache "{{ file }}"
        ;;
      *.ts|*.tsx)
        npx prettier --write --cache "{{ file }}"
        npx eslint --fix "{{ file }}" 2>/dev/null || true
        ;;
      *.go)
        gofmt -w "{{ file }}"
        go vet "{{ file }}" 2>/dev/null || true
        ;;
      *)
        echo "No lint rule for: {{ file }}"
        ;;
    esac
