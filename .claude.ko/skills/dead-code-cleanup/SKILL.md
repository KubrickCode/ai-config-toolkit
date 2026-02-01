---
name: dead-code-cleanup
description: 코드베이스에서 죽은 코드, deprecated 코드, 미사용 export를 식별하고 안전하게 제거
allowed-tools: Glob, Grep, Read, Edit, Bash(npm:*), Bash(pnpm:*), Bash(yarn:*), Bash(go:*), Bash(git status:*), Bash(tsc:*), Task
disable-model-invocation: true
---

# 죽은 코드 정리 커맨드

## 목적

프로젝트 무결성을 유지하면서 미사용 코드를 체계적으로 식별하고 제거.

**대상 코드**:

- 참조가 없는 미사용 export/함수/클래스
- 활성 마이그레이션 계획이 없는 deprecated 코드
- 어디서도 import되지 않는 고아 파일
- 도달 불가능한 코드 경로

**핵심 제약**: 정리 후 프로젝트가 반드시 빌드되고 모든 테스트를 통과해야 함.

---

## 사용자 입력

```text
$ARGUMENTS
```

**해석**:

| 입력                     | 동작                            |
| ------------------------ | ------------------------------- |
| 비어있음                 | 전체 코드베이스 분석            |
| 경로 (예: `src/legacy/`) | 지정된 디렉토리 분석            |
| `--dry-run`              | 보고만, 삭제 없음               |
| `--auto`                 | HIGH 신뢰도 항목 확인 없이 삭제 |

---

## 보존 규칙 (절대 삭제 금지)

### 절대 보존 대상

| 카테고리            | 탐지 방법                                     | 예시                         |
| ------------------- | --------------------------------------------- | ---------------------------- |
| **Public API**      | `package.json` exports, `index.ts` re-exports | 라이브러리 진입점            |
| **계획된 기능**     | 티켓/이슈가 있는 TODO/FIXME                   | `// TODO(#123): 구현 예정`   |
| **프레임워크 규칙** | 경로 기반 (pages/, app/, api/)                | Next.js 라우트, NestJS 모듈  |
| **테스트 인프라**   | `*.test.*`, `*.spec.*`에서 import             | Fixtures, mocks, 테스트 유틸 |
| **동적 Import**     | `import()`, `require()` 패턴                  | Lazy loading, code splitting |
| **빌드 의존성**     | package.json scripts에서 참조                 | 빌드 도구, CLI 스크립트      |
| **외부 계약**       | GraphQL 타입, API 스키마                      | 스키마 정의                  |

---

## 분석 워크플로우

### Phase 1: 컨텍스트 수집

**1.1 프로젝트 타입 탐지**

```bash
# 프레임워크 탐지
[ -f "next.config.js" ] && echo "Next.js"
[ -f "tsconfig.json" ] && echo "TypeScript"
[ -f "go.mod" ] && echo "Go"
```

**1.2 Public API 표면 매핑**

- `package.json` exports 필드 확인
- `index.ts` re-exports 찾기
- Go exported 심볼 나열 (대문자 시작)

### Phase 2: 죽은 코드 탐지

**2.1 미사용 Exports**

각 export 문에 대해:

1. 코드베이스 전체에서 import 참조 검색
2. 동적 import 패턴 확인
3. Public API 표면에 없는지 확인

**2.2 Deprecated 코드**

```bash
grep -rn "@deprecated" --include="*.ts" --include="*.go"
grep -rn "DEPRECATED" --include="*.ts" --include="*.go"
```

### Phase 3: 검증

**신뢰도 분류**:

| 레벨   | 기준                                        | 동작                    |
| ------ | ------------------------------------------- | ----------------------- |
| HIGH   | 참조 없음, 보존 대상 아님, 명확한 죽은 코드 | 자동 삭제 (`--auto` 시) |
| MEDIUM | 직접 참조 없음, 문자열/주석 언급 있음       | 확인 요청               |
| LOW    | Public으로 export됨, 모호한 사용            | 보고만                  |

### Phase 4: 안전한 삭제

**4.1 삭제 전**

```bash
# 커밋되지 않은 변경사항 경고
git status --porcelain | grep -q . && echo "⚠️ 커밋되지 않은 변경사항 있음"
```

**4.2 점진적 삭제**

- 배치 단위로 삭제 (5-10개)
- 각 배치 후 검증
- 첫 실패 시 중단

**4.3 삭제 후 검증**

```bash
# 각 배치 후 통과해야 함
{build_command}  # npm run build / go build ./...
{test_command}   # npm test / go test ./...
{lint_command}   # npm run lint / golangci-lint run
```

---

## 출력 형식

### 최종 보고서

```markdown
# 🧹 죽은 코드 정리 보고서

**생성일시**: {timestamp}
**범위**: {analyzed_paths}

---

## 📊 요약

| 카테고리        | 개수    | 라인        |
| --------------- | ------- | ----------- |
| 미사용 Exports  | {n}     | {lines}     |
| Deprecated 코드 | {n}     | {lines}     |
| 고아 파일       | {n}     | {lines}     |
| **합계**        | **{n}** | **{lines}** |

---

## 🔴 삭제됨 (HIGH 신뢰도)

### {file_path}:{line}

- **타입**: {function/class/variable}
- **사유**: 참조 없음
- **검증**: 빌드 ✓ 테스트 ✓

---

## 🟡 스킵됨 - 리뷰 필요

### {file_path}:{line}

- **타입**: {function/class/variable}
- **탐지 사유**: {왜 죽은 코드로 탐지되었는지}
- **스킵 사유**: {왜 보존했는지}
- **권장 조치**: {다음 단계}

---

## ✅ 검증 결과

- 빌드: {PASS/FAIL}
- 테스트: {PASS/FAIL} ({passed}/{total})
- 린트: {PASS/FAIL}
```

---

## 핵심 규칙

### ✅ 반드시 해야 할 것

- 모든 삭제 배치 후 빌드 + 테스트 실행
- 모든 보존 항목에 대해 스킵 사유 문서화
- 최종 요약에 모든 스킵 항목 보고
- 보존 규칙에 매칭되는 항목 보존

### ❌ 절대 하지 말 것

- 검증 없이 삭제
- 보존 규칙 무시
- 최종 보고서 생성 건너뛰기
- 너무 많은 삭제를 배치 (최대 10개)

### 🛡️ 안전 우선

- 불확실할 때 → 스킵하고 보고
- 모호할 때 → 사용자에게 질문
- 빌드 실패 시 → 즉시 롤백

---

## 사용 예시

```bash
# 보고만 (삭제 없음)
/dead-code-cleanup --dry-run

# 특정 디렉토리 분석
/dead-code-cleanup src/legacy/

# HIGH 신뢰도 항목 자동 삭제
/dead-code-cleanup --auto

# 기본값: 인터랙티브 모드
/dead-code-cleanup
```
