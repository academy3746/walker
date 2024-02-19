# Introduction (수정중)

<h3>당신이 부러운 여행지, 부럽 (외주 프로젝트)</h3>

1. Service Scope: [Web](https://www.boolub.com/) / Android / IOS

- Android / IOS 앱은 3월 중 출시 예정

2. Application Developing Tool: Flutter / Android Studio / X Code
3. Server Configuration: Ubuntu / AWS
4. BackEnd Developing Tool: PHP / PHPMyAdmin (RDBMS) / 고객사 솔루션
5. Native App Performance

- 인 앱 Push 서비스: Firebase Cloud Messaging
- GPS: Geolocator
- 만보기: Pedometer / WorkManager
- In App WebView PG 결제: Toss Payments SDK

# External Plugin List

1. cupertino_icons: ^1.0.2
2. geolocator: ^10.1.0
3. permission_handler: ^11.0.1
4. geocoding: ^2.1.1
5. shared_preferences: ^2.2.2
6. url_launcher: ^6.2.1
7. package_info: ^2.0.2
8. flutter_webview_pro: ^3.0.1+4
9. webview_cookie_manager: ^2.0.6
10. firebase_core: ^2.22.0
11. firebase_crashlytics: ^3.4.4
12. firebase_analytics: ^10.6.4
13. firebase_messaging: ^14.7.4
14. flutter_local_notifications: ^9.1.5
15. get: ^4.6.6
16. get_storage: ^2.1.1
17. http: ^1.1.0
18. geolocator_android: ^4.4.0
19. geolocator_apple: ^2.3.2
20. fluttertoast: ^8.2.4
21. pedometer: ^4.0.1
22. tosspayments_widget_sdk_flutter: ^1.0.2
23. intl: ^0.18.1
24. font_awesome_flutter: ^10.6.0
25. device_info_plus: ^9.1.1
26. android_id: ^0.3.6
27. fk_user_agent: ^2.1.0
28. workmanager: ^0.5.2

# Issue01

<h3>TextField Focusing Issue on Android WebView</h3>

<div style="margin-top: 50px">
    <p>1. 소프트 키보드가 차지한 영역만큼 화면이 밀려 올라가지 않는 문제</p>
    <p>2. 사용자가 선택한 TextField 위치로 Focusing이 되지 않는 문제</p>
    <p><img src="assets/images/issue01.png" style="height: 400px; width: 230px;"></p>
</div>

<div style="margin-top: 50px">
    <p>문제를 바라보는 관점에 따라 접근 방법 역시 달라진다.</p>
    <p>1번 문제라면 네이티브 앱에서만 취할 수 있는 조치들이 있다.</p>
    <p>2번 문제라면 웹에서 취할 수 있는 조치와 연관지어서 접근해야 한다.</p>
</div>

<div style="margin-top: 50px">
    <h4>1. 소프트 키보드가 차지한 영역만큼 화면이 밀려 올라가지 않는 문제</h4>
    <p style="margin-top: 40px">1) SingleChildScrollView</p>
    <p style="margin-left: 25px">대부분의 상황에서는 SingleChildScrollView 위젯을 사용하면 해결된다.</p>
    <p style="margin-left: 25px">화면 전체를 자연스럽게 스크롤이 가능한 영역으로 잡는다는 접근방식이다.</p>
    <p style="margin-left: 25px">TextField 위젯이 소프트 키보드에 가려질 때 가장 먼저 시도 해볼만 하다.</p>
    <p style="margin-left: 25px">기본적으로 List 객체에 담긴 데이터 값들을 Row에서 렌더링할 때 쓰는 방법이다.</p>
    <p style="margin-left: 25px">결과적으로는 문제를 해결하지 못했다.</p>
    <p style="margin-top: 40px">2) Adjust Resize</p>
    <p style="margin-left: 25px">안드로이드 설정 자체를 건드리는 방법도 있다.</p>
    <p style="margin-left: 25px">'AndroidManifest.xml' 파일에서 'activity' 설정 값을 변경하는 것이다.</p>
    <p style="margin-left: 25px">보통 'android:windowSoftInputMode' 값을 'adjustResize'로 설정한다.</p>
    <p style="margin-left: 25px">디버깅 결과, 효과가 전혀 없는 것은 아니었다.</p>
    <p style="margin-left: 25px">결과적으로는 TextField를 터치하였을 때, 키보드 영역만큼 화면이 밀려 올라가기는 했다.</p>
    <p style="margin-left: 25px">문제는 이 동작이 열 번이면 열 번 전부 동일하게 작동하지는 않았다는 것이다.</p>
    <p style="margin-left: 25px">짐작하기로는 MediaQuery가 안드로이드 웹뷰에서 완전하게 동기화 되지는 않는 것 같다.</p>
    <p style="margin-left: 25px">다만, 이제는 접근 방법을 달리 해볼 필요가 있다는 것이다.</p>
</div>

<div style="margin-top: 50px">
    <h4>2. 사용자가 선택한 TextField 위치로 Focusing이 되지 않는 문제</h4>
    <p style="margin-top: 40px">문제의 원인을 네이티브가 아닌 웹에서 찾으려고 한다면 관점이 살짝 달라진다.</p>
    <p>소프트 키보드가 차지한 영역만큼 화면이 밀려 올라가는 것과</p>
    <p>사용자가 터치한 TextField 위치로 시점이 전환되는 것은 사뭇 다르다.</p>
    <p>부럽 앱은 기본적으로 반응형 웹을 패키징한 구조이기 때문에 이 부분은 JavaScript로 해결할 수 있다.</p>
    <p>TextField를 터치하면 약 200ms 정도의 텀을 두고 해당 영역으로 Focusing이 되는 것이다.</p>
    <p>WebView 위젯에서는 'runJavascript'를 사용하여 Javascript를 Enabled 시킬 수 있다.</p>
    <p>해당 <a href="https://github.com/academy3746/walker/blob/main/lib/features/main_screen/main_screen.dart#L475">라인</a>을 참조 바란다.</p>
    <p>위, 아래 TextField 어디를 터치하든지 간에 자연스럽게 Focusing이 됨을 확인할 수 있다.</p>
    <p>당연히 소프트 키보드가 해당 영역을 가리지도 않는다.</p>
</div>

# Issue02 (수정중)

<h3>In App WebView PG (Payment Gate) Issue</h3>

<div style="margin-top: 50px">
    <p>1. 기구축된 Toss Payments 결제 서비스가 앱에서 정상작동 하지 않는 문제</p>
    <p>2. URL Type Scheme (Intent) Error</p>
    <p><img src="assets/images/issue02.jpeg" style="height: 350px; width: 250px;"></p>
</div>

<div style="margin-top: 50px">
    <p>Toss Payments는 다양한 형태의 간편 결제 서비스를 지원한다.</p>
    <p>온갖 카드결제 항목은 사실상 옵션에 불과하다.</p>
    <p>One Touch 결제가 가능한 네이버, 카카오페이야말로 서비스의 핵심 요소라고 할 수 있을 것이다.</p>
    <p>문제는 플랫폼마다 서로 다른 URL 스키마를 결과값으로 반환한다는 것이다.</p>
    <p>가령, 카카오페이의 경우는 'kakao://'와 같은 포맷으로 결제를 요청한다.</p>
    <p>각종 카드사들은 말할 것도 없을 것이다.</p>
</div>

<div style="margin-top: 50px">
    <p>물론, TOSS사의 백엔드 개발자들이 이 점을 간과했을 리가 없다.</p>
    <p>그 증거로 Toss Payments 제공하는 결제 방식은 모두 일관된 URL 타입으로 파싱이 된 상태이다.</p>
    <p><strong>https://payment-gateway.tosspayments.com/pc/payment-method/digital-wallet/option?token=${SAMPLE}&gtid=${SAMPLE}&cardCode=KAKAOPAY</strong></p>
    <p>네이버페이는 cardCode의 GET값이 'NAVERPAY', 토스페이는 'TOSSPAY'이다.</p>
</div>

<div style="margin-top: 50px">
    <p>하지만 TOSS 개발자들의 세심한 일처리는 딱 거기까지이다.</p>
    <p>본인이 짐작하기에 해당 파싱 처리는 Mobile Web을 염두에 둔 조치 같다.</p>
    <p>Flutter 앱에서 간편 결제를 진행하였을 때는 여전히 URL Scheme 에러가 발생하지만...</p>
    <p>스마트폰의 크롬 브라우저에서 디버깅을 해봤을 때는 해당사항이 없었기 때문이다.</p>
    <p>하이브리드 앱은 이러한 부분에서 오히려 시간을 더 많이 잡아먹을 때가 있다.</p>
    <p><img src="assets/images/issue03.jpeg" style="height: 350px; width: 250px;"></p>
</div>

# Issue03
