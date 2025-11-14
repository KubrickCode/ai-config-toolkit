---
name: dependency-management
description: |
  모든 패키지 매니저에서 고정 버전 의존성 설치를 강제합니다. 재현 가능한 빌드, 공급망 보안, 안정성을 보장합니다.
  Use when: 패키지 설치, 의존성 업데이트, package.json/requirements.txt/go.mod/Cargo.toml/pom.xml/build.gradle/composer.json/Gemfile/.csproj 작업, 의존성 설정 검토, CI/CD 파이프라인 구성
---

# Dependency Management

## Basic Principles

### Always Use Exact Versions

- 고정 버전만 사용: `package@1.2.3`
- 금지: `^1.2.3`, `~1.2.3`, `latest`, `*`, version ranges
- 예외: 라이브러리 peerDependencies만 허용

### Lock Files Are Mandatory

- 항상 버전 관리에 커밋
- 수동 편집 금지
- CI/CD는 frozen/locked 모드 필수

### Security Audit First

- 설치 전 취약점 확인
- 정기 감사 자동화

## Installation Commands

```bash
# Node.js
npm install --save-exact package@1.2.3
pnpm add --save-exact package@1.2.3
yarn add --exact package@1.2.3

# Python
pip install package==1.2.3
poetry add package@1.2.3

# Go
go get package@v1.2.3

# Rust
cargo add package@=1.2.3

# PHP
composer require vendor/package:1.2.3

# Ruby (Gemfile)
gem 'package', '1.2.3'

# Java/Kotlin
implementation("group:artifact:1.2.3")  # Gradle
<version>1.2.3</version>                # Maven

# .NET
dotnet add package PackageName --version 1.2.3
```

## CI/CD Commands

```bash
npm ci                          # npm
pnpm install --frozen-lockfile  # pnpm
yarn install --frozen-lockfile  # yarn
poetry install --no-update      # poetry
go mod verify                   # go
cargo build --locked            # rust
composer install --no-update    # php
bundle install --frozen         # ruby
dotnet restore --locked-mode    # .NET
```

## Common Mistakes

| ❌ 잘못된 사용       | ✅ 올바른 사용         |
| -------------------- | ---------------------- |
| `npm install` (CI)   | `npm ci`               |
| `package@latest`     | `package@1.2.3`        |
| `package@^1.2.3`     | `package@1.2.3`        |
| Lock 파일 .gitignore | Lock 파일 커밋         |
| Lock 파일 수동 편집  | 패키지 매니저로 재생성 |
