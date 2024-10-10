# Route 53 là gì

• DNS – Domain Name System: là một hệ thống quản lý các tên miền và ánh xạ chúng thành địa chỉ IP của máy chủ, cho phép các ứng dụng truy cập vào các dịch vụ trên internet bằng tên miền thay vì sử dụng địa chỉ IP.
• AWS Route 53 là một dịch vụ quản lý tên miền và DNS (Domain Name System) được cung cấp bởi Amazon Web Services (AWS). DNS AWS Route 53 cho phép bạn đăng ký và quản lý tên miền, tạo và cấu hình các bản ghi DNS, và điều hướng các yêu cầu từ tên miền đến các nguồn tài nguyên khác nhau trên AWS và bên ngoài. Điều này bao gồm điều hướng yêu cầu đến máy chủ web, máy chủ email, CDN và các tài nguyên khác.
• Route 53 cung cấp một loạt tính năng như đám mây DNS, chống chịu tải, đám mây phân phối nội dung, bảo mật và theo dõi tình trạng tài nguyên. Nó cũng tích hợp tốt với các dịch vụ khác của AWS, cho phép bạn tự động cập nhật bản ghi DNS khi tạo hoặc xoá các nguồn tài nguyên trên AWS.

==> Route 53 đóng vai trò như DNS, khi người dùng request tới nó sẽ trỏ sang resouce đằng sau VD: Instacne (EC2, Cloudfront), ngoài ra có một số tính năng như `health check`, kết hợp chặt chẻ với `Cloudwatch` để monitor và Alarm, quản lý `Route 53` qua `SDK` hoặc `Console`, giúp quản lý domain, hosted zone, cx như các recored

# Tính năng của Route 53

- Route 53 cung cấp 3 tính năng chính bao gồm:
  • Register Domain name: cho phép bạn mua và quản lý tên miền, tự đông gia hạn (optional). Bạn cũng có thể đem một domain đã mua của bên thứ 3 và quản lý trên Route 53.
  • DNS Routing: điều hướng internet traffic tới một resource nhất định vd: `EC2 IP, Application Load Balancer, Cloud Front, API Gateway, RDS,...`
  • Health checking: tự động gửi request đến các resource để check tình trạng hoạt động. Có thể kết hợp với Cloud Watch alarm để notify khi có resource unhealthy.

## DNS Resolver

[file:///D:/devops-linh%20nguyen/AWS/0.Slide-PDF%20-%20AWS/17.%20Domain%20Name%20Sysstem%20-%20Route53.pdf]
Hình bên mô tả một flow từ khi người dùng gõ địa chỉ của một trang web vd: www.example.com lên trình duyệt cho tới khi nội dung thực sự được trả về từ máy chủ.
==> mô hình => www.example.com => thì nó sẽ đi qua các bước, đầu tiên nó luôn call tới TLD dgl `top lever domain server` level cao nhất (DNS root) => nó sẽ phân giải tiếp tên miên này được quản lý bởi nhà cung cấp nào (giả sử: mua tên miền của Route 53, thì nó sẽ trỏ đến Route 53) => tại Route 53 nó về cho người dùng một cái IP, bước cuối cùng thì thực sự người dùng mới nói chuyên với server thông qua IP, nó phần giải rồi lần sau nó sẽ nhới IP này không còn call sang dns nữa (TTL)

Route 53 hosted zone là gì?
• Route 53 hosted zone là một khái niệm trong AWS Route 53. Một hosted zone đại diện cho một tên miền hoặc một tên miền con trong hệ thống DNS. Nó là nơi bạn quản lý các bản ghi DNS (DNS Record) và cấu hình liên quan cho tên miền cụ thể.

• Hosted zone public sẽ map với một tên miền cụ thể (`có thể mua bởi Route 53 hoặc bên thứ 3`). Private hosted zone cũng map với tên miền tuy nhiên chỉ có tác dụng trong scope một VPC. (private hosted zone nó sẽ map với những tên miền cho Database, hay các service communication nội bộ với nhau => tác dụng private hosted zone)

• Sau khi tạo hosted zone, bạn có thể thêm các bản ghi DNS vào nó như `A Record, CNAME Record, MX Record` và nhiều loại bản ghi khác. Bạn có thể cấu hình các bản ghi này để điều hướng yêu cầu tới các tài nguyên khác nhau, chẳng hạn như máy chủ web, máy chủ email hoặc dịch vụ khác trên internet.

• Có thể tương tác với Hostedzone thông qua Console hoặc AWS API từ đó cho phép update tự động các DNS Record.

# Các loại DNS Record (nằm trên hosted zone, mục đích map tên miền hay sub domain nào đó với một target)

• A Record (Address Record): Xác định một địa chỉ `IPv4` cho tên miền. Nó ánh xạ một tên miền vào `một địa chỉ IP v4`

• AAAA Record (`IPv6` Address Record): Tương tự như A Record, nhưng sử dụng để xác định một địa chỉ IPv6 cho tên miền.

• CNAME Record (Canonical Name Record): Nó được sử dụng `để tạo đường dẫn từ một tên miền thứ cấp` (`subdomain`) `đến một tên miền ở bất cứ đâu trên internet`.

• MX Record (Mail Exchanger Record): Xác định các máy chủ chịu trách nhiệm nhận và xử lý thư điện tử cho một tên miền. Nó được sử dụng để `định vị máy chủ email.`

• TXT Record (Text Record): Cho phép bạn lưu trữ các dữ liệu văn bản tùy ý cho tên miền. Nó thường được sử dụng để xác thực tên miền và cung cấp thông tin khác nhau cho các dịch vụ khác. (tức là nó trả về text thôi, chứ không trỏ đi đâu hết, nhiệm vụ xác thực xem chúng ta có phải chủ tên miền không)

• SRV Record (Service Record): Xác định vị trí và cấu hình dịch vụ cụ thể trên mạng. Nó được sử dụng chủ yếu trong việc xác định các máy chủ chịu trách nhiệm cho các dịch vụ như VoIP (Voice over IP) và IM (Instant Messaging). (ít dùng)

• NS Record (Name Server Record): Xác định máy chủ tên miền (name server) chịu trách nhiệm quản lý các bản ghi DNS cho tên miền cụ thể. Nó cho phép bạn chỉ định máy chủ DNS mà bạn muốn sử dụng cho tên miền của mình. (dùng khi muốn mang tên miền bên thứ 3, nhưng lại quản lý bên Route 53, thì ta phải cấu hình `NS Recrod` này bên cái provider mua tên miền)

• PTR Record (Pointer Record): Sử dụng để thực hiện ánh xạ địa chỉ IP thành tên miền. Nó được sử dụng chủ yếu trong việc xác định tên miền từ một địa chỉ IP cụ thể. (ít dùng)

# Routing policy

- `Khi bạn tạo một DNS Record, bạn cần quyết định routing policy sẽ sử dụng cho record đó`:
  • `Simple routing policy` – Sử dụng trong trường hợp bạn trỏ DNS Record tới một resource riêng lẻ vd `CloudFront`, `Web Server run on EC2.`
  • `Failover routing policy` – Sử dụng khi cấu hình một cặp resource hoạt động theo cơ chế `activepassive failover`. `Thường sử dụng trong private hosted zone.` (VD: ta có 2 con database hoặc server, default dùng làm con active, con stand by dùng khi con active có sự cố thì ta mới điều hướng rquest sang, thì nó hoạt động theo cặp )
  • `Geolocation routing policy` – điều hướng traffic từ user tới các target dựa trên vị trí địa lý của user.  
  • `Geoproximity routing policy` – sử dụng khi bạn muốn điều hướng traffic dựa trên vị trí của resource. Bạn cũng có thể shift traffic từ resource location này sang resource ở location khác. (sử dụng trong tình huống, ta có nhiều resouce lằm rải rác trên các `Region` khác nhau (Ví dụ Mĩ, Singapor))
  • `Latency routing policy` –Sử dụng khi bạn có nhiều resource trên multi regions và muốn điều hướng traffic tới region có latency tốt nhất. (aws nó sẽ tự động detach xem region nào chưa quá tôi thì nó điều hướng tới)
  •` IP-based routing policy` –Điều hướng traffic dựa trên location của user và dựa trên IP address mà traffic bắt nguồn.
  • `Multivalue answer routing policy` –Sử dụng khi bạn muốn query up-to 8 record healthy được lựa chọn ngẫu nhiên. (trong trường nhiều server backend)
  • `Weighted routing policy` – Phân chia tỉ lệ điều hướng tới target theo một tỷ lệ nhất định mà bạn mong muốn. (giả sử ta có 2 con server, một con chạy code cũ, một con chạy code mới, ta muốn delivery 10% traffic sang server chạy code mới) (gần giống cấu hình tỉ lện trên alb)

# Ví dụ về DNS Record

==> ta có têm miền `linhnguyen.click` và tôi muốn cấu hình là 2 cái subdomain một cái `web.linhnguyen.click` trỏ sang xxx.cloudfront.net, `api.linhnguyen.click` thì trỏ sang ip của con ec2 instance (ip: 34.56.78.90)
Q: DNS Record web.linhnguyen.click và api.linhnguyen.click thuộc loại nào?
==> `api.linhnguyen.click`: A Record
==> `web.linhnguyen.click`: CNAME Recrod (một tên miền sub mà trỏ sang tên mền khác)

# Lab 1 – Mua tên miền sử dụng Route 53

Yêu cầu chuẩn bị sẵn $3 trong thẻ liên kết với AWS
Steps:

1. Login vào AWS Console, vào dịch vụ Route 53
2. Kiểm tra một tên miền xem còn available không?
   \*Có thể chọn tên miền .click, giá khoảng $3/năm cho rẻ.
3. Sau khi kiểm tra tên miền available, tiến hành add to cart và thanh toán.
4. Đợi tên miền activate thành công.
5. Kiểm tra hosted zone được tạo ra với type là public

# Lab 2 – Thực hành với A Record

Yêu cầu có sẵn một tên miền với public hosted zone (Lab 1)
Steps:

1. Login vào AWS Console, tạo một EC2 instance với website đơn giản (xem lại bài EC2).
2. Test access thành công bằng public IP.
3. Vào dịch vụ Route 53
   (`route 53` => `viettu.id.vn` => create record => Record name: testserver, type: A Record => Value: public Ip EC2 => Routing plicy: simple routing => TTL: 120s => create record) => truy cập `testserver.viettu.id.vn` , kiểm tra: nslookup, nếu không được => control plan => Network and sharing => nhấp vô wifi => Property => tìm dòng Internet Protocol IPv4 (click) => chọn USE the DNS (cái dưới) => 8.8.8.8,8.8.4.4
4. Tạo một sub domain với type A-Record. Vd testserver.linhnguyen.click, value trỏ đến Public
   IP của Instance.
5. Test truy cập bằng sub-domain vừa tạo.

# Lab 3 – Thực hành với C-Name

\*Yêu cầu có sẵn một tên miền với hosted zone (public)
\*Yêu cầu có sẵn một CloudFront trỏ tới website đang hoạt động (Xem lại bài CloudFront)

Steps:

1. Login vào AWS Console, vào dịch vụ Route 53
2. Tạo một sub domain với type C-Name. Vd website.linhnguyen.click, value trỏ đến DNS của
   cloudfront. (tạo sẵn cloudfront trỏ tới S3 từ bài lab trước)
   (`route 53` => viettu.id.vn => create record => name: website, type: CNAME Record, value: xxx.cloudfront.net => create)
   (Chỉ tạo CNAME ở Route 53 trỏ tới cloudfront thì chưa thể hoạt động, phái cấu ở cả cloudfront) truy cập => 403 ERROR (Cloudfront chưa chop phép tên miền trỏ đến)
   (Cấu hình domain name ở cloudfront phải có cerfiticate cho tên miền)
   FREE (`Certificate Manager` => Request => type: Request a public certificate => next => domain name: website.viettu.id.vn (or \*.viettu.id.vn) => validation: DNS validation => setting để default hết => Request )
   ===> và khi tạo certificate ta phải vertify nó (status: pending,chứng mà chủ tên miền) => nó sẽ `tự tạo một CNAME name`: `xxx.website.viettu.id.vn`, CNAME value: `xxx.acm-validation.aws.`(`Export to CSV`) => Route 53 => create record => Record name: `xxx.website`, type: CNAME => Value: `xxx.acm-validation.aws.`
   ==> Cách khác => `Create records in Route 53` (nó sẽ chọn sẵn domain) => Create Record (tương đương với việc tạo bằng tay) => trong hosted zone sẽ xuất hiện một record để vertify cho website `viettu.id.vn`
   ==> kiểm tra Certificate xem Status đã `Issued` chưa

   (cloudfront => distribution => General => Stting => Edit => Alternate domain name -> add item -> `website.viettu.id.vn` => Custom SSL certificate: Chọn cerfiticate tương ứng với domain (báo xanh là ok) => save change)

3. Test truy cập bằng sub-domain vừa tạo.

   ==> truy cập: `https://website.viettu.id.vn` (Cloudfront là một zero idle code, lên để lại )

# Route 53 Health check

- Route 53 định kỳ thực hiện các call tới endpoint bạn muốn thực hiện healthcheck. Nếu response failed hoặc không trả về response, Route 53 sẽ raise alarm tới CloudWatch Alarm kết hợp với SNS để notify tới người nhận (vd đội operator).
  Các thông số có thể setting cho healthcheck bao gồm:
  • IP/Domain name cần check
  • Protocol (TCP, HTTP, HTTPS)
  • Interval (bao lâu check 1 lần)
  • Failure threshold vd 3 lần ko có resposne thì tính là fail.
  • Notification (optional) kết hợp với CloudWatch Alarm
  và SNS

# Lab 4 – Thực hành với Route53 Healthcheck

`Yêu cầu sử dụng lại EC2 có website đã hoạt động (hoặc tạo lại nếu xoá rồi).`
(thưc hiện heath check đối với con instance này thông qua IP)
Steps:

(`route 53` => Health checks => Create health check => name: udemy-ec2-health-check => What to monitor: Endpoint => Specify endpoint buy: Ip address -> protocol: http -> IP address: 3.1.201.127 -> port: 80 -> path (không điền gì) => Advanced configure -> interval: 10s check 1 lần -> failure: 3 -> `Health check regions`: use recommend => next => Create alarm: yes => Send notification: New SNS topic => topic name: `route53-healthcheck-topic` => Recipient email address: `ll6012065@gmail.com` => create helth check)

(vô mail đẻ confim SNS)

(vô server ec2 stop enable httpd)

(`route 53` -> Health checks -> kiểm tra Status: `Unhealth`) => vô mail kiểm tra

1. Login vào AWS Console, vào dịch vụ Route 53
2. Tạo một Health Check trỏ tới Instance Public IP
3. Setting các thông số: protocol: HTTP, Interval: 10s, threshold: 3.
4. Setting CloudWatch alarm -> SNS -> Email.
5. Login vào server, stop service httpd.
6. Kiểm tra Alarm status và Notification tới Email đã subscribe

# Lab 5 – Thực hành với Private Hosted zone

\*Lưu ý bài lab sẽ mất phí khoảng $0.5
Steps:

1. Tạo nhanh 2 EC2 instance (không cần cài web), login thành công. Đặt tên là Server A/B
2. Vào dịch vụ Route 53
3. Tạo một Private Hosted zone tương ứng với một VPC. Vd: udemy.local
   (`route 53` => hosted zone => create hosted zone => name: udemy.local (vì là private lên đặt trùng tên cx ko sao) => type: `Private` => region: singapor => vpc: default vpc => tag: Name=Test private hosted zone => create) (chú `hosted zone` chỉ có tác dụng `trong vpc thôi`)
4. Tạo một A-Record trên hosted zone trỏ tới Server A/B `private IP` tương ứng
   vd: `server-a.udemy.local, server-b.udemy.local` ==> chú ý copy: private IP

   ==> sử dụng trong th muốn aplication (server) kết nối tới database thông qua `subdomain` thay vì sử dụng domain trực tiếp db, lợi ích là ta có thể switch qua lại một cách dễ dàng chỉ điều chính cái domain này thôi không phần cấu hình lại server

5. Cấu hình `security group` cho phép 2 server ping nhau.
   (sg => edit => add rule => type: All traffic (trong nội bộ kết nối với nhau) hoặc All ICMP IPv4 , source `gán ip sucrity group của chính nố` thì mặc định nó sẽ cho ping nội bộ)
6. Thử ping lẫn nhau bằng Private IP
   (ssh => ec2-A => ping Private IP)
7. Thử ping lẫn nhau bằng sub-domain đã tạo ở bước trên.
   (ssh => ec2-A => ping server-b.udemy.local)

==> Dùng trong trường hợp dùng để trỏ tới DATABASE và cái DB đó được access Backend, tôi không mỗi lần update cái gì đó DB, ta phải switch lại phải update backend => thì ta hãy trỏ tới 2 record này và nếu DB ta có vấn đề, ta muốn switch sang DB khác chỉ cần sủa Record này thôi

(tốn 0.5$/month)

# Route 53 pricing

- Về cơ bản Route 53 tính tiền dựa trên các yếu tố:
  • Giá của tên miền (khác nhau tuỳ đuôi vd .com, .net, .click...sẽ có phí thường niên
  khác nhau).
  • Hosted zone: $0.5/month.
  • Query: vd $0.4/1M query standard, $0.6/1M query latency.
  • Health check: $0.5/health check/month.
  • Log: phụ thuộc vào giá của CloudWatch.

# Hướng dẫn trỏ một `root domain` (`viettu.vn.id`) đến một con server

\* Tạo trước một record: name: `test-web.viettu.id.vn` trỏ tới public IP EC2 và truy cập thử
(`route 53` => 'viettu.id.vn' => create record => Record name: `để trống`, Record type: A-Recrod => Bật Alias => Route traffic to: `Alias to Appliction and Classic Load Blance` (tuy nhiên ec2 của ta chỉ có 1 con bình thướng thôi, nếu nó đứng loadblance thì ta chọn cái này chọn region và LoadBalance là xog) => nếu con EC2 của ta chưa lằm trong ALB thì chọn `Alias to another record in this hosted zome` và chọn record `test-web.vietu.id.vn` (`test-web.vietu.id.vn` record này đang trỏ tới Ip EC2, cái này tạo ban đầu) => Create )

==> truy cập `viettu.id.vn`, nếu TH `API gateway hoặc EC2` đứng sau một `ALB hoặc Network LB` thì mõi chuyện qua đơn giản chỉ cần chọn rồi trỏ tới thôi
