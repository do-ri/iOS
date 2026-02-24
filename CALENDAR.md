## Calendar Feature 구조와 흐름
CalendarView -> dori가 있는 날을 터치시 바텀시트가 올라옴
바텀시트: DayDetailSheet


## API
GET /dori/list
diection은 DoriSegmentControl 로 결정 됨
judori -> Out, baddori -> In

- [query]: 
direction: String (IN/OUT)
year: String
month: String

- [header]
Authorization: Bearer JWT - AuthInterceptor에게 위임된 작업

- 응답
SuccessResponse<data에 맞는 새로운구조체> 작성할 것
- 달력의 year/month에 따른 응답 값 inDoriDayList를 달력에 점으로 표시하면 됨 
- inDoriList, outDoriList 로 바텀시트에 row로 사용하면 됨
- DoriSegmentControl direction에 따른 inDoriTotalAmount, outDoriTotalAmount가 상단 총 주도리에 표시됨
{
  "success": true,
  "data": {
    "userId": 1,
    "year": 2024,
    "month": 5,
    "inDoriTotalAmount": 100000,
    "inDoriDayList": [
      1,
      2
    ],
    "inDoriList": [
      {
        "doriId": 1,
        "userId": 1,
        "partnerId": 1,
        "direction": "IN",
        "partnerName": "홍길동",
        "relationship": "지인",
        "eventType": "생일",
        "amount": 50000,
        "eventDate": "2024-05-01",
        "isVisited": true,
        "memo": "메모",
        "createdAt": "2026-02-17T09:27:50.658160145"
      }
    ],
    "outDoriTotalAmount": 50000,
    "outDoriDayList": [
      3
    ],
    "outDoriList": [
      {
        "doriId": 2,
        "userId": 1,
        "partnerId": 2,
        "direction": "OUT",
        "partnerName": "김영희",
        "relationship": "동료",
        "eventType": "결혼",
        "amount": 50000,
        "eventDate": "2024-05-03",
        "isVisited": false,
        "memo": null,
        "createdAt": "2026-02-17T09:27:50.658193668"
      }
    ]
  },
  "error": null
}
