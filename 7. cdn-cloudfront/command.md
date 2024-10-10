# What is CloudFront

- Là một CDN service của AWS.

# Vậy CDN là gì?

=> Viết tắt của Content Delivery Network, một mạng lưới giúp delivery nội dung tới người dùng cuối một cách nhanh chóng nhờ vào việc điều hướng request của họ tới các máy chủ chứa tài nguyên gần nhất.

# Mô hình hoạt động của một mạng CDN

- Khi không có CDN, tài nguyên của server sẽ được deliver tới client một cách trực tiếp.
  (có nghĩa là người dùng request và cái tài nguyên đó được trả về với người dùng thông qua đường truyền trực tiếp, và khi không có cdn tùy vào khoảng cách địa - tức khoảng cách giữa người dùng máy chủ mà tốc sẽ nhanh hay chậm: tốc độ load file, tốc độ load trâng, ảnh, video nhanh hay chậm)
  => Tuỳ vào khoảng cách địa lý mà tốc độ truy cập sẽ nhanh hay chậm.

- Khi có CDN, tài nguyên của server sẽ được cache trên các máy chủ Edge, request của user tới một tài nguyên trên CloudFront sẽ được redirect tới máy chủ Edge gần nhất.
  (thay vì người dùng họ sẽ phải nhận cái respone từ máy chủ `GỐC` thì họ nhận các respone từ máy chủ cache và vì các máy chủ cache này được đặt ở khắp nơi trên thới giới lên CloudFront hoàn toàn có thể redirect người ta về một máy chủ chứa tài nguyên gần họ nhất => do vậy tăng tốc độ truy cập website: video, images)

# Các khái niệm cơ bản của CloudFront

• `Distribution`: AWS CloudFront phân phối nội dung từ `origin` đến các` edge location` thông qua một `distribution`. Một distribution định nghĩa cách CloudFront phân phối nội dung, bao gồm địa chỉ của origin, các edge location được sử dụng, các thiết lập security & caching.
(origin của cloudfront ta có thể chọn như là một cái website host static trên S3, một cái api ở trên ec2 hoặc API Gateway, edge location quy định tôi sẽ sử dụng các máy chủ edge nào tùy theo việc người dùng, khách hàng tiềm năng của tôi nằm ở đâu là chủ yếu)

• `Edge Location`: AWS CloudFront sử dụng một mạng lưới toàn cầu các edge location, là các điểm đặt máy chủ trên khắp thế giới, để phân phối nội dung đến người dùng ở gần nhất vị trí đó.
(ở việt nam ta đã có một edge location tại Hà Nội, nên ta cỏ bất location ở Hà Nội để những người dùng Hà Nội không phải truy cập trực tiếp từ máy chủ singapor, nhật bản)

• `Origin`: Đây là nơi lưu trữ nội dung gốc (origin content) của bạn, bao gồm các tập tin, ứng dụng web, API và Database. Origin có thể là một Web server, S3 bucket hoặc các dịch vụ AWS khác.

• `Cache`: AWS CloudFront lưu trữ các tài nguyên tại edge location để giảm thời gian phản hồi và tăng tốc độ tải trang web. Các tài nguyên này bao gồm hình ảnh, tập tin CSS và JavaScript.

• `Logging and Reporting`: AWS CloudFront cung cấp các báo cáo về hoạt động của distribution, bao gồm `lưu lượng và số lần truy cập.`
(ta có thể bật loging và monitoring để qua sát log hoặc cloudfront)

• `Security`: AWS CloudFront hỗ trợ nhiều tính năng bảo mật, bao gồm kết nối HTTPS, chữ ký số (Certificate) và xác thực người dùng.

• `Customize at the Edge`: thông qua cơ chế Lambda@Edge, cho phép bạn thực thi các function trên các sự kiện CloudFront. Lợi thế về tốc độ và hiệu suất so với thực thi ở Origin. Một số use-case có thể kể đến như: Authen/Author, xử lý tính toán đơn giản, SEO, Intelligent routing (không cần đẩy image tới origin mới sử lí được, sử lý trên lamda@edge luôn), Anti Bot, Realtime image transformation, A/B Testing (điều hướng req sang môi trường mới và môi trường cũ bằng một tỉ lệ nhất định), User prioritilization. (ta có user thường và user vip ta sẽ xử lý trên lamda@edge để phân loại user cung câp tới máy chủ hiểu suất cao cho user vip và máy chủ bình thường cho user thông thường)

(Lamda@Edge khác với lamda thông thường là nó không chạy ở trong một region mà nó chạy trên các node cache, như vậy nó sẽ tăng cái respon về phái người dùng)

# How CloudFront deliver content to user?

1. User access website, request một tài nguyên vd HTML file, Image, CSS..
2. DNS điều hướng request của user tới CloudFront edge location gần nhất (dựa theo độ trễ).
3. a) CloudFront forward request tới Origin server (một HTTP server hoặc s3 bucket). (giả sử tài nguyên chưa có trên edg location)
   b) Origin server trả kết quả cho edge location.
   c) Ngay sau khi nhận được firstbyte response, edge location forward object tới end-user đồng thời cache lại nội dung cho request lần sau.
   \*Từ lần request thứ 2 trở đi, mặc định edge location sẽ trả về object được yêu cầu mà không gọi tới origin server -> tăng tốc độ truy cập.
   (cho tới khi thời gian cacing nó chưa hết nó vẫn sẽ chả về cái object đó, nhược điểm ở đay khi user request lên chúng tài nguyên cũ, tuy nhiên một đặc thù nghiệp ta không cần put, update liên tục ta sẽ set thời gian caching hợp lý vd: 1p,3p 1 tiếng)

# Usecase của CloudFront

- CloudFront được sử dụng cho một số usecase sau:
  • Tăng tốc website (Image, CSS, Document, Video,...)
  • On demand video & video streaming. (dùng cloudfront để phục vụ nội dung cho hàng triệu user cùng access các tài nguyên video)
  • Field level encrypt: CloudFront tự động mã hoá data được gửi lên từ người dùng,
  chỉ có backend application có key có thể giải mã.
  • Customize at the edge: Trả về mã lỗi khi server maintain hoặc authorize user
  trước khi forward request tới backend. Cần sử dụng Lambda@Edge.

# CloudFront pricing

- CloudFront tính phí dựa trên các mục sau:
  • No Up-front fee, người dùng chỉ trả tiền cho những gì sử dụng.
  • Lượng data thực tế tranasfer out to internet.
  • CloudFront function, Lambda@Edge.
  • Invalidation Request (clear cache). ( giả sử tôi đang có 1G data trên cloufront tôi cảm thấy data này củ rồi, tôi cần clear cache để nạp nội dung mới cho người dùng, thì hành đạng clear cache)
  • Real-time log.
  • Field level encrypt.

# Usecase sample: hosting static website

[file:///D:/devops-linh%20nguyen/AWS/0.Slide-PDF%20-%20AWS/16.%20CDN-CloudFront.pdf]

- Website static (chỉ gồm HTML/css/js...) có thể được deploy lên S3 kết hợp với CloudFront.
- Hâu hết các framework hiện nay như Angular, Vue, Nodejs đều hỗ trợ build website thành dạng satic chỉ gồm HTML, css, javascript để deploy lên S3.
  (cloudfront đứng trước đê ta có thể tăng tốc workload, nội dung của người dùng khi req lên trên cloudfront này thì data sẽ được trả về từ edge location )

# Usecase sample: serve media (video, image)

- Media được phân phối tới end user thông qua CloudFront cho trải nghiệm tốt hơn do nội dung được redirect tới Edge Location gần với User nhất.

# Usecase sample: customize at the edge

- Sử dụng Lambda@Edge để phân biệt user sử dụng
  subsciption information lưu ở DynamoDB (có enable Global table).
- Tuỳ theo subscription khác nhau (premium/normal) mà sẽ có các ưu tiên về xử lý khác nhau, vd user premium được redirect tới máy chủ mạnh hơn user normal.

# CloudFront behavior

- Một CloudFront distribution có thể có nhiều hơn một Origin server phía sau.
  VD: một hệ thống gồm có 1 S3 bucket host static website, 1 backend server gồm ALB + Container muốn sử dụng chung một CloudFront distribution.
  => Cần có cơ chế phân biệt request nào sẽ điều hướng tới đâu. Behavior cho phép định nghĩa request với các pattern khác nhau sẽ được forward tới các origin khác nhau.

vd: tôi sẽ set 4 cái behavior để call đến các service khác

```plaintext
- /api/*     -> api gateway (origin)
- /images/*  -> s3 (origin)
- /video/*   -> medi bucket (origin)
- /*         -> website bucket (static website) (origin)
```

**Chú ý** tự của các behavior rất quan trọng, trong hình nếu để /_ lên trên cùng, sẽ làm các behavior bên dưới bị sai lệch. (tức là nó vô hết /_)

# CloudFront Cache Policy

(là một cấu hình định nghĩa cloudfront sẽ cache và phục vụ người dùng cuối như thế nào, cache policy có định nghĩa riêng cho từng distribution, hoặc behavior)
• `CloudFront cache policy`là một cấu hình định nghĩa CloudFront sẽ cache và serves content như thế nào đối với User.
• Cache policy có thể được định nghĩa riêng cho từng distribution hoặc behavior. Một số rule có thể định nghĩa vd: thời gian content được cache, compress hay khôn ?, forward cookies & query strings hay không?
• Việc apply caching policy khác nhau cho từng distribution hoặc behavior, cho phép tinh chỉnh việc control caching cho từng URL hoặc request pattern. Việc này giúp tối ưu hoá caching behavior cho từng loại content khác nhau, vd: Static assets (image, css, js, video...) hoặc dynamic API response.

(giả sử ta có những orin như trên thì backend api thì ta phải luôn yêu cầu trả về respone tương ứng với request đó và không có nhu cầu caching thì ta có thể setting một `cache policy` apply cho origin API gateway, caching policy quy không caching bất cứ cái gì hết, luôn luôn trả về nội dung native từ `origin`)
(nếu ta dùng caching trên api có một sử nguy hiểm là nó sẽ lấy chúng nội dung req của ngưởi dùng nào đó trước đó đã request)

# CloudFront Origin request policy

• CloudFront origin request policy định nghĩa cách CloudFront xử lý request tới origin.
• Khi user request content trên CloudFront, request được forward tới các origin như S3, EC2, ALB. Origigin Request Policy cho phép modify request trước khi forward tới origin.
(ta có thể chỉnh sủa hoặc là bỏ bớt một cái header hoặc query string để tối ưu việc caching, tăng performance, hoặc là cấu hình bảo vệ backend api từ các access không phải từ cloudfront)
• Bạn có thể add/modify/remove header hoặc query string để optimize caching, tăng performance. Ngoài ra bạn có thể cấu hình CloudFront sign hoặc encrypt request để bảo vệ backend khỏi những access unauthorized.
• Origin request policy hữu dụng khi có kiến trúc backend phức tạp vd như có nhiều loại origin server. (modify request trước khi gửi cho backend)

==> usecase security: là tất cả request đi qua cloudfront ta có thể cấu hình một cái `origin request policy` add thêm một cái header, header này do ta quy định và chỉ ta mới biets header này là cái gì, và ta có thể cấu hình backend chỉ khi có header này, chúng ta mới sử lý => tránh người dùng request trực tiếp từ client đến backend thông ALB trong trường biết url

# Lab 1 – Sử dụng CloudFront để host static web

\*Yêu cầu đã học qua bài S3, biết cách host một website tĩnh lên S3 bucket.

[https://github.com/cloudacademy/static-website-example]

- s3 => create bucket => name: udemy-s3-bucket => bỏ chọn block all pulic acess
- locacl => aws s3 cp static-website-example/ s3://
- s3 => udemy-s3-bucket => preperties => Static website hosting => edit => enable => index document: index.html, error document: eror.html => save change
- s3 => udemy-s3-bucket => permissions => block public access => edit => block all public access: turn off
- s3 => udemy-s3-bucket => permissions => bucket policy => edit =>

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "statement1",
      "Principal": "*",
      "Effect": "Allow",
      "Action": ["s3:GetObject"],
      "Resource": "arn:aws:s3:::udemy-s3-bucket/*"
    }
  ]
}
```

## ==> truy cập dns: udemy-s3-bucket.s3-website-appsoutheast-1.amazones.com

---

1. Chuẩn bị 1 website tĩnh, nếu có vài hình size lớn (>5mb) thì càng tốt.
   (s3 => udemy-s3-bucket => fodler: images => upload: image tầm 4.5 mb)
   (truy cập => udemy-s3-bucket.s3-website-appsoutheast-1.amazones.com/images/xxx.jpg)
2. Thực hiện host website tĩnh sử dụng S3.
3. Tạo CloudFront distribution, đăng ký S3 làm origin.
   ( cloudfront => `distributions` => create => name: udemy-aws-could_origin => origin domain: udemy-s3-bucket.s3.amazones.com => orgin path: không điền gì => origin access: public => compress object: yes => Viewer -> viewer protocol policy: Redirect HTTP to HTTPS => WAF: do not enable => Settings -> price class: use all edge location => domain anme: tạm thời chưa dùng => create)
   (mất 3-5 minute cho tới khi distribution nó available và triển khai toàn bộ nội dung ở origin nên các edge location trên toàn thế giới)
   (`distributions` => origin => (ta mới có một origin thôi, ta có thể add thêm một origin khác))
   (`distributions` => behaviors: Default(/\*) (tức là tất cả rquest đều điều hướng sang s2 và caching policy đang là CachingOptimimized (recommend của amazon dành cho s3), nếu ta có nhiều hơn 1 origin, giả sử ta có thêm môt cái api gateway nữa ta cần cấu hình phân biệt là req nào sẽ api gateway, req nào vô s3)
   (`invalidation`: clear cache, khi tôi deploy code mới lên tôi muốn người dùng cuối ngay lập tức có nội dung đó hoặc ovwride nội dung cũ ta có create invalidation => nếu để /\* là toàn bộ, hoặc /images/2023/\*)
4. Thử truy cập thông qua CloudFront, `so sánh tốc độ` khi truy cập trực tiếp S3. (trọn oringin bên mĩ để trải nhiệm rõ nhất)
   (`distributions` => general => distributions domain name => xxx.cloudfront.net/index.html)
   (truy cập => xxx.cloudfront.net/images/xxx.jpg (lần đầu tiên nó sẽ request đến origin))
5. Disable public access cho S3, tạo OAI cho CloudFront, thiết lập policy chỉ cho phép truy cập resource thông qua CloudFront.
   ( đang để s3 là `public` => bh muốn user chỉ truy cập cloudfront mà không truy cập trực tiếp s3)
   (`distributions`=> origin => udemy-aws-could_origin => edit => origin acces: origin access control setting => origi access control -> create control setting -> signing behavior: sign request (không tích do not) -> origin type: s3 -> create origin acces control -> select udemy-aws-could-orin (cái vừa tạo) => bucket policy: copy policy (tự động tạo policy để bỏ vào s3, với policy này chỉ cho phép access từ cloudfront thôi) => save change )
   (`s3` => udemy-s3-bucket => permission => block public access => edit => tích block all public access => save change)
   (`s3` => udemy-s3-bucket => permission => bucket policy => edit => dán policy vừa này vào chỗ policy (ctrl A, ctrl V) => save changes)
6. [Optional] phát hành SSL certificate và sử dụng CloudFront custom domain. Mua 1 tên miền và trỏ sang CloudFront, truy cập thông qua domain đã setting. \*Phần này bài Route53 sẽ được trình bày rõ hơn.
   (tạo `hosted zone` và `AWS certificate` )
   (`distributions` => general => Stting: edit => Alternate domain name: Add item -> 'udemyviettu.vn.id' => custom ssl: chọn tương ứng với domain name đó => save change)
   (`route 53` => viettu.vn.id => create record => record name: "udemy -> record type: CNAME" => value/destination: xxx.cloudfront.net => ttl: 60 => create record)
   ==> truy cập: `udemy.viettu.id.vn/index.html`
   \*\*chú ý: nếu muốn setting một tên miền trỏ tới cloudfront custom domain thì ta cần làm 2 bước, 1 là setting trong phần general của distribution (lưu ý ta có thể setting nhiều hơn một domain, và tạo một ssl certificate (cái này miễn phí))

# Lab 2 – CloudFront + API Gateway + S3

\*Yêu cầu đã học qua bài S3, biết cách host một website tĩnh lên S3 bucket.
\*Yêu cầu đã học qua bài API Gateway, biết cách deploy một API đơn giản.

1. Chuẩn bị 1 website tĩnh deploy lên S3.
2. Tạo một API Gateway đơn giản, deploy thành một stage.
3. Tạo CloudFront distribution, đăng ký S3 làm origin (hoặc tái sử dụng lại bài lab 1)
4. Add thêm origin cho API Gateway.
   (`distributions` => origin => create origin =>Setting -> origin domain: `api gateway` -> `udemy-test-api` -> protocol: HTTPS only => create origin)
5. Cấu hình behavior phù hợp cho API Gateway và S3.
6. Cấu hình Caching Behavior No-Cache cho API Gateway.
   (`distributions` => behaviors => create behavior => path pattern: /dev/caculate\* (nó sẽ call đến api gateway) => origin: chọn cái origin api gateway vừa tạo => compress: yes => viewer protocol: HTTPS only => Allowsd HTTP method: GET, PUT, POST, PATCH => Caching key and origin requests -> cache policy -> CachingDisabled (vì nội dung trả về cho api gateway nó lấy kết quả người trước trả về cho người sau không đúng nx => luôn luôn request đến origin tính toán sau đó mới trả về) -> origin request policy (nó quy định forward những cái query string nào đến backend): chọn policy được recommend)

   (vô postman => POST => https://xxx.cloudfront.net/dev/caculate => send)

```json
{
  "fitstNum": 13,
  "secondNum": 223,
  "operator": "ADD"
}
```

- (test website s3 xem có hoạt động bình thường không)
  (Chú ý: thứ tự behavi rất quan trọng, nếu đảo default(_) nên trước caculate thì không chạy được api gateway, ví _ độ phủ lớn hơn)

7. Modify code backend thử in ra request header (`cần enable Proxy trên API GW`)
   (in ra request header từ bên lamda khi nhận được một req từ api gateway)
   (`api gateway` => resource => "caculate" => "POST" => Integration Request => tích vào ô "use lambada proxy integration" => save change)
   (`api gateway` => resource => Action => Delpoy API => chọn stage dev => deploy)
   (nếu không bật proxy thì chỉ request đến body thôi, bật proxy thì nó forward toàn bộ như http req: header, một số thông số khác, body kèm theo, thì ta cần modify source một xíu => tức dùng source code mới ở lamda (source code cũ dùng cơ chớ là api gateway không bật proxy) , bây h bật proxy thì sủa code một xíu) => souce code: `caculaotr-lamda-new.py` => lamda => copy => pate => deploy
   (vô postman => POST => https://xxx.cloudfront.net/dev/caculate)

```json
{
  "firstNum": 100,
  "secondNum": 23,
  "operator": "ADD"
}

// result
{
  "message": "Request processed succefully",
  "result": 36
}
```

==> coi log của lamda => lamda => caculator => Monitor => View CloudWatch logs => chọn logs stram có thời gian gần nhất => kiểm ta log DEBUG INPUT FROM CLIENT", "DEBUG HEADER FROM CLIENT", => sẽ thấy rẩt nhiều thông số HEADER: {...} => DEBUG BODY FROM CLINET: { "firstNum": 100, "secondNum": 23 "operator": "ADD" }

8. Cấu hình forward một header vd “Source” = “CloudFront”
   (cấu hình cloudfront forward một header custom về backend)
   (cloudfront => `distributions` => origin => chọ oringin: api gateway => edit => kêos xuống: Add custom header => add header => header name: "Source", value: “CloudFront-udemy” => save change )
   ==> bây giờ chở đi cloudfront forward đến api gateway nó sẽ đính thêm một header có trị “Source” = "CloudFront-udemy"

   (vô postman => POST => https://xxx.cloudfront.net/dev/caculate)

```json
{
  "firstNum": 100,
  "secondNum": 25,
  "operator": "ADD"
}
=> vô lamda => cacucalte => monitor => View CloudWatch logs => chọn logs stram có thời gian gần nhất => kiddmr tra ở mục "DEBUG HEADER FROM CLIENT" kiểm tra xem có keyword "CloudFront-udemy"
```

==> tức là lúc khi cấu hình custom hader đó, thì cloudfront trước khi nó forward đến backend cụ thể là api gateway và lamda thì nó đính thêm header
==> và tùy theo header này ta có thể ràng buộc policy là phải đúng là request từ cloudfront vô tôi mới sử lý, hoặc reject

== ngoài ra có tính năng tại edge location ta có thể gán lamda adge vô có khả năng phân biệt người dùng thường và người dùng vip tại edgae => tốc độ nhanh hơn không tới origin

# Lab 3 – Sử dụng CloudFront cho single-page

\*Yêu cầu đã xem qua bài S3, biết cách host một website tĩnh lên S3 bucket.

1. Upload source lên S3, enable static website, liên kết với CloudFront, test truy cập thông qua cloudfront (`nhớ thêm /index.html phía sau`).
   => `https://xxx.cloudfront.net/index.html`
   (nhược diểm này phải thêm /index.html thì mới vô được, nếu chỉ nhớ tên miền thôi không nhớ /index.html => lỗi 403) => lamda edge
2. Cấu hình Lambda@Edge cho origin Website, nhiệm vụ của Lambda@Edge này là thêm index.html vào mỗi request rồi forward tiếp.
   `\*Đặc trưng của single page là luôn luôn phải có index.html, nếu client không được redirect tới 1 file có trên origin, CloudFront sẽ trả về lỗi 403.`
   => srouce code lamda edge => `lamda-edge.js`
   - `cloudfront` => funtions => (có 2 cách để dùng lamda edge, 1 dùng cloudfront function, 2 là tạo một lamda) => create functions => name: udemy-test-lamda-edge => create function (tạo xog có dao diện edit code) => build => copy: `lamda-edge.js` -> paste (bản chất cloudfront function này nó không phải chạy ở origin, mà chạy ở edge location, nên không có role) => save change => vô tap Publish => publish function
   - `cloudfront` => distribution => chọn distribution bài lab trc => `behaviors` => chọn cái forward sang s3 => kéo xuống Function associate (`viewer request`: khi có request đến lamda sẽ được kích hoạt,`view reponse`: được kích hoạt trước khi gửi respone về cho client, `origin request`: trước khi gửi request xuống cho origin (s3, api backend), `origin reponse`: khi nhận được reponse từ origin sẽ kích hoạt function ) => chọn `View request` => chọn CloudFront Function => chọn function "udemy-test-lamda-edge" => save change

===> truy cập `https://xxx.cloudfront.net/` ==> vừa nãy không /index.html nó báo lỗi liền

3. Thử truy cập website mà không cần có index.html ở phía sau.
