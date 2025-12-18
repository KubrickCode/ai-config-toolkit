---
allowed-tools: Glob, Grep, Read, Edit, Bash(npm:*), Bash(pnpm:*), Bash(yarn:*), Bash(go:*), Bash(git status:*), Bash(tsc:*), Task
description: 코드베이스에서 죽은 코드, deprecated 코드, 미사용 export를 식별하고 안전하게 제거
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

### 특수 케이스

**Export되었지만 내부에서 미사용**:

- Public 라이브러리 → 보존 (외부 소비자 알 수 없음)
- Private 앱 → 리뷰 대상으로 플래그

**타임라인이 있는 Deprecated**:

- 기한 미경과 → 보존
- 기한 경과 + 미사용 → 삭제

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

**1.2 패키지 범위 식별**

```bash
# Public 라이브러리 vs Private 앱
grep '"private": false' package.json && echo "PUBLIC_LIBRARY"
```

**1.3 Public API 표면 매핑**

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

평가:

- 마이그레이션 기한 있음? 경과 여부 확인
- 대체제 있음? 사용이 마이그레이션되었는지 확인
- 타임라인 없음? 리뷰 대상으로 플래그

**2.3 고아 파일**

어디서도 import되지 않는 파일:

- 제외: 진입점, 설정 파일, 스크립트
- 제외: 테스트 파일, 타입 선언
- 플래그: import가 없는 유틸리티 파일

**2.4 도달 불가능 코드**

- return/throw 뒤의 코드
- 항상 false인 조건
- Dead switch case

### Phase 3: 검증

**각 후보에 대해**:

1. **교차 참조 확인**: 모든 가능한 import 패턴 검색
2. **문자열 참조 확인**: 파일명이 문자열로 (동적 로딩)
3. **주석 참조 확인**: 미래 사용을 언급하는 TODO/FIXME
4. **보존 규칙 확인**: 위의 규칙 적용

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

**4.4 실패 시 롤백**

```bash
git checkout -- {failed_files}
```

---

## 출력 형식

### 진행 상황 업데이트 (분석 중)

```markdown
🔍 코드베이스 분석 중...

**프로젝트**: TypeScript (Next.js)
**범위**: 전체 코드베이스
**모드**: 표준

---

## 컨텍스트 ✓

- Public API: src/index.ts에서 12개 export
- 프레임워크: Next.js (pages/, app/, api/ 보존)
- 테스트 유틸: 5개 공유 유틸리티

## 탐지 진행

- Export 스캔 중... (45/120)
- Deprecated 마커 확인 중...
```

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

## 🟢 보존됨 (규칙 매칭)

### {file_path}:{line}

- **규칙**: {어떤 보존 규칙}
- **상세**: {구체 사항}

---

## ⚠️ 수동 리뷰 필요

사람의 판단이 필요한 항목:

1. **{file_path}:{line}**
   - 탐지 내용: {발견된 것}
   - 우려 사항: {왜 불확실한지}
   - 제안: {권장 조치}

---

## ✅ 검증 결과

- 빌드: {PASS/FAIL}
- 테스트: {PASS/FAIL} ({passed}/{total})
- 린트: {PASS/FAIL}

---

## 📋 다음 단계

### 즉시

- [ ] {n}개 스킵 항목 리뷰
- [ ] {n}개 수동 리뷰 항목 조사

### 권장

- [ ] LOW 신뢰도 항목 제거 전 deprecation 공지 추가
- [ ] 제거된 API에 대한 문서 업데이트
- [ ] 미래 죽은 코드 방지를 위한 린트 규칙 설정

---

## 📝 세션 요약

- 분석됨: {total_files}개 파일, {total_lines} 라인
- 삭제됨: {deleted_count}개 항목 ({deleted_lines} 라인)
- 스킵됨: {skipped_count}개 항목 (위의 사유 참조)
- 보존됨: {preserved_count}개 항목 (규칙 매칭)
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

## 실행 지침

### Step 1: 입력 파싱

- `--dry-run`, `--auto` 플래그 확인
- 대상 경로 결정 (기본값: 전체 코드베이스)

### Step 2: 안전 점검

```bash
git status --porcelain
```

- 커밋되지 않은 변경사항 있으면 경고
- 제안: "변경사항을 먼저 커밋하거나 stash하세요"

### Step 3: 컨텍스트 수집 (Phase 1)

1. 프로젝트 타입과 프레임워크 탐지
2. Public 라이브러리인지 식별
3. Public API 표면 매핑
4. 테스트 인프라 나열

### Step 4: 탐지 (Phase 2)

TypeScript/JavaScript의 경우:

```bash
# Export 찾기
grep -rn "export \(function\|class\|const\|interface\|type\)" src/

# 각각에 대해 import 확인
grep -r "import.*{.*ExportName.*}" --exclude-dir=node_modules
```

Go의 경우:

```bash
# Exported 심볼 찾기
grep -rn "^func [A-Z]" --include="*.go"
grep -rn "^type [A-Z]" --include="*.go"
```

### Step 5: 검증 (Phase 3)

각 후보에 대해:

1. 교차 참조 확인 실행
2. 보존 규칙 적용
3. 신뢰도 레벨 분류

### Step 6: 조치 (Phase 4)

모드에 따라:

- `--dry-run`: 보고서만 생성
- `--auto`: HIGH 신뢰도 삭제, 나머지 보고
- 기본값: 각 삭제에 대해 확인 요청

### Step 7: 검증

각 배치 후:

```bash
# 패키지 매니저 탐지 후 실행
npm run build && npm test
# 또는
pnpm build && pnpm test
# 또는
go build ./... && go test ./...
```

### Step 8: 최종 보고서

종합 보고서 생성:

- 모든 삭제 항목
- 모든 스킵 항목과 사유
- 모든 보존 항목과 규칙
- 수동 리뷰 권장사항
- 검증 결과

**중요**: 최종 보고서에 스킵 항목을 반드시 포함.

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

---

## 문제 해결

### False Positives

**증상**: 코드가 플래그되었지만 실제로 필요함

**확인**:

- 변수가 있는 동적 import
- 프레임워크 라이프사이클 메서드
- 외부 소비자 사용

### 빌드 실패

**조치**:

1. 롤백: `git checkout -- .`
2. 실패 항목 검토
3. 정당하면 보존 규칙에 추가

### 놓친 죽은 코드

**해결책**:

- 보존 규칙에 잘못 매칭되는지 확인
- 더 공격적인 grep 패턴으로 실행
- 수동 검증
