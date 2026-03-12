# ngrok Tools - macOS Menu Bar App

## 배경

ngrok 대시보드에서 수행하는 터널/에이전트/엔드포인트 관리 작업을 매번 브라우저를 열지 않고,
macOS 메뉴바에서 토글 형태로 간편하게 켜고 끌 수 있는 네이티브 도구가 필요하다.

## 요구사항

### 1. 인증 및 토큰 관리
- 로컬 ngrok CLI 설정 파일(`~/.ngrok2/ngrok.yml` 또는 `~/Library/Application Support/ngrok/ngrok.yml`)에서 authtoken 자동 감지
- API 토큰은 macOS Keychain에 안전하게 저장
- 토큰 미설정 시 설정 화면으로 안내 (직접 입력도 가능)
- 설정 화면에서 토큰 변경/삭제 가능

### 2. 터널 관리 (Tunnels)
- 활성 터널 목록 조회 (GET /tunnels)
- 터널 상세 정보 조회 (GET /tunnels/{id})
- 터널별 public_url, proto, region, started_at 표시
- 터널 상태를 시각적으로 표시 (활성/비활성 아이콘)

### 3. 에이전트 세션 관리 (Tunnel Sessions)
- 활성 세션 목록 조회 (GET /tunnel_sessions)
- 세션 상세 정보 (agent_version, ip, region, os)
- 세션 재시작 (POST /tunnel_sessions/{id}/restart)
- 세션 중지 (POST /tunnel_sessions/{id}/stop)
- 토글 형태: 실행 중인 세션을 stop/restart 가능

### 4. 엔드포인트 관리 (Endpoints)
- 엔드포인트 목록 조회 (GET /endpoints)
- 엔드포인트 상세 정보 (url, proto, upstream_url)
- 엔드포인트 삭제 (DELETE /endpoints/{id})

### 5. 자동 폴링
- 설정 가능한 주기(10초~60초)로 상태 자동 새로고침
- 메뉴바 아이콘에 활성 터널 수 표시 (badge)
- 수동 새로고침 버튼도 제공

### 6. macOS 알림
- 터널 연결/해제 시 시스템 알림
- 세션 종료 시 알림
- API 에러 발생 시 알림

### 7. 메뉴바 UI
- 메뉴바 상주 앱 (NSStatusItem)
- 메뉴 클릭 시 팝오버 형태로 대시보드 표시
- 섹션별 탭: Tunnels / Sessions / Endpoints
- 각 항목에 토글 스위치 또는 액션 버튼
- 설정(Settings) 화면: 토큰 관리, 폴링 주기, 알림 on/off

## 기술 스펙

- **언어/프레임워크**: Swift 5.9+, SwiftUI, AppKit (NSStatusItem)
- **최소 지원 OS**: macOS 14.0 (Sonoma)
- **네트워킹**: URLSession + async/await
- **보안 저장소**: macOS Keychain (Security framework)
- **아키텍처**: MVVM
- **API Base URL**: `https://api.ngrok.com`
- **API 인증 헤더**: `Authorization: Bearer {token}`, `Ngrok-Version: 2`
- **빌드 시스템**: Xcode / Swift Package Manager

## 수용 기준

- [ ] AC-1: 앱 최초 실행 시 로컬 ngrok CLI 설정에서 authtoken을 자동 감지하여 Keychain에 저장한다
- [ ] AC-2: 토큰이 없는 경우 설정 화면에서 직접 입력할 수 있다
- [ ] AC-3: 메뉴바 아이콘 클릭 시 팝오버로 대시보드가 표시된다
- [ ] AC-4: Tunnels 탭에서 활성 터널 목록과 상태를 확인할 수 있다
- [ ] AC-5: Sessions 탭에서 세션 목록 확인 및 restart/stop 토글이 동작한다
- [ ] AC-6: Endpoints 탭에서 엔드포인트 목록 확인 및 삭제가 가능하다
- [ ] AC-7: 설정한 주기(기본 30초)로 자동 폴링이 동작한다
- [ ] AC-8: 메뉴바 아이콘에 활성 터널 수가 badge로 표시된다
- [ ] AC-9: 터널 연결/해제, 세션 종료 시 macOS 시스템 알림이 발생한다
- [ ] AC-10: 설정 화면에서 토큰, 폴링 주기, 알림 on/off를 변경할 수 있다
