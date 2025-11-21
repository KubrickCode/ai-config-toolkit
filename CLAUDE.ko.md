# CLAUDE.md

이 파일은 Claude Code(claude.ai/code)가 이 저장소의 코드 작업 시 참고하는 가이드입니다.

**필수 (CRITICAL)**

- 주요 작업이나 문서 내용에 필수적인 변경이 있을 때는 항상 CLAUDE.md와 README.md를 업데이트할 것. 사소한 변경은 무시해도 됨.
- 절대로 브랜치 생성이나 커밋을 자율적으로 하지 말 것 - 항상 사용자에게 수동으로 하도록 요청
- ⚠️ 스킬 강제 로드 - 파일 편집 전 관련 스킬 반드시 읽기:
  - .ts → typescript
  - .tsx → typescript + react
  - .go → golang
  - .test.ts, .spec.ts → typescript-test + typescript
  - .test.go, \_test.go → go-test + golang
  - .graphql, resolvers, schema → graphql + typescript
  - package.json, go.mod → dependency-management
  - 경로 기반 (필요시 추가): apps/web/** → nextjs, apps/api/** → nestjs
  - 스킬 경로: .claude/skills/{name}/SKILL.md
  - 📚 필수: 응답 끝에 로드한 스킬 표시: `📚 Skills loaded: {skill1}, {skill2}, ...`
- Claude가 같은 실수를 반복하면 CLAUDE.md에 명시적 금지 사항 추가 (실패 기반 문서화)
- 생성하는 모든 콘텐츠(주석, 에러 메시지, 로그, 테스트 설명, 문서)는 프로젝트 언어 컨벤션을 따를 것
  - 기존 코드베이스를 확인하여 프로젝트 언어 감지 (한국어/영어 등)
  - 대화 언어와 무관하게 항상 프로젝트 컨벤션을 따를 것
  - 예시: 영어 프로젝트 → `describe("User authentication")`, `describe("사용자 인증")` 금지
- 워크스페이스 도구 컨벤션 준수
  - 항상 워크스페이스의 패키지 매니저 사용 (락 파일로 감지: pnpm-lock.yaml → pnpm, yarn.lock → yarn, package-lock.json → npm)
  - justfile에 태스크가 있거나 반복 작업 추가 시 just 명령어 선호
  - 일회성 작업은 직접 명령어 실행 가능

**중요 (IMPORTANT)**

- 근거 없는 추측 금지 - 중요한 세부사항은 반드시 확인
  - 파일 경로 추측 금지 - Glob/Grep으로 찾을 것
  - API 계약이나 함수 시그니처 추측 금지 - 실제 코드를 읽을 것
  - 패턴 기반의 합리적인 추론은 허용
  - 중요한 결정에 대해 정말 불확실할 때는 사용자에게 질문
- 작업 시작 전 항상 컨텍스트 수집
  - 관련 파일 먼저 읽기 (맹목적으로 작업하지 말 것)
  - 코드베이스의 기존 패턴 확인
  - 프로젝트 컨벤션 검토 (네이밍, 구조 등)
- 항상 이슈 크기와 범위를 정확히 평가 - 단순 작업에 과잉 엔지니어링 금지
  - 구현과 문서화 모두에 적용
  - 장황한 문서는 사람에게 리뷰 부담을 줌
