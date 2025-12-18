# NestJS 개발 표준

## 모듈 조직 원칙

### 도메인 중심 모듈화

기능이 아닌 비즈니스 도메인별로 모듈 구성.

- Bad: `controllers/`, `services/`, `repositories/`
- Good: `users/`, `products/`, `orders/`

### 단일 책임 모듈

각 모듈은 하나의 도메인에만 책임.

- 공통 기능은 `common/` 또는 `shared/` 모듈로 분리
- 도메인 간 통신은 반드시 Services를 통해서만

## 의존성 주입 규칙

### Constructor Injection만 사용

Property injection (@Inject) 금지.

```typescript
// Good
constructor(private readonly userService: UserService) {}

// Bad
@Inject() userService: UserService;
```

### Provider 등록 위치

Provider는 사용되는 모듈에서만 등록.

- 전역 provider 최소화
- forRoot/forRootAsync는 AppModule에서만 사용

## 데코레이터 사용 규칙

### 커스텀 데코레이터 우선

반복되는 데코레이터 조합은 커스텀 데코레이터로 추상화.

```typescript
// 3개 이상 데코레이터 조합 시 커스텀 데코레이터 생성
@Auth() // @UseGuards + @ApiBearerAuth + @CurrentUser 통합
```

### 데코레이터 순서

실행 순서대로 위에서 아래로 배치.

1. 메타데이터 데코레이터 (@ApiTags, @Controller, @Resolver)
2. Guards/Interceptors (@UseGuards, @UseInterceptors)
3. 라우트 데코레이터 (@Get, @Post, @Query, @Mutation)
4. 파라미터 데코레이터 (@Body, @Param, @Args)

## DTO/Entity 규칙

### DTO는 순수 데이터 전송

비즈니스 로직 금지; 검증만 허용.

```typescript
// Good: 검증만
class CreateUserDto {
  @IsEmail()
  email: string;
}

// Bad: 비즈니스 로직 포함
class CreateUserDto {
  toEntity(): User {} // 금지
}
```

### Entity와 DTO 분리

Entity 직접 반환 금지; 항상 DTO로 변환.

- Request: CreateInput, UpdateInput (GraphQL) / CreateDto, UpdateDto (REST)
- Response: Type 정의 또는 plain object

## 에러 처리

### 도메인별 Exception Filter

각 도메인에 자체 Exception Filter.

```typescript
@Module({
  providers: [
    {
      provide: APP_FILTER,
      useClass: UserExceptionFilter,
    },
  ],
})
```

### 명시적 에러 던지기

모든 에러 상황에서 Exception 명시적 throw.

- REST: HttpException 시리즈 사용
- GraphQL: GraphQLError 또는 커스텀 에러 사용
- 암묵적 null/undefined 반환 금지
- 에러 메시지는 사용자가 이해 가능하게
