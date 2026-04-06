# Tech Stack

## Current Stack

- Swift 6
- iOS 17.6+
- Xcode 26.2
- TCA
- Kakao SDK
- Security framework based token storage
- Custom network layer + auth interceptor

## Why This Matters

이 문서는 버전 나열보다 구조에 영향을 주는 선택만 남긴다.

- 상태 관리는 TCA가 기준이다.
- 인증은 Kakao SDK, 토큰 저장소, 네트워크 인터셉터의 조합으로 동작한다.
- 동시성 기본 규칙은 Swift 6 + MainActor 기준이다.
