# What is VPC

- Viêt tắt của Virtual Private Cloud
  -Là một service cho phép người dùng tạo một mạng ảo (virtual network) và control toàn bộ network in/out của mạng đó.
  VPC tương đối giống với network ở datacenter truyền thống tuy nhiên các khái niệm đã được AWS đơn giản hoá giúp người dùng dễ tiếp cận.

# Các thành phần cơ bản của VPC

• `VPC`: Một mạng ảo được tạo ra ở cấp độ `region`. (tức là singaport, tokio, region => avability zone(mỗi zone cách nhau vài 100k) )
• `Subnet`: Một dải IP được định nghĩa nằm trong VPC. Mỗi subnet phải được quyết định `Availability Zone` (sinagepor có 3 zone, phải chọn 1 trong 3 zone) tại thời điểm tạo ra.
• IP Address: IP V4 hoặc V6 được cấp phát. Có 2 loại là Public IP và Private IP.
• Routing: xác định traffic sẽ được điều hướng đi đâu trong mạng.
• Elastic IP: IP được cấp phát riêng, có thể access từ internet (public), không bị thu hồi khi instance start -> stop.

• Security Group: Đóng vai trò như một firewall ở cấp độ instance, định nghĩa traffic được đi vào /đi ra. \*Đã học ở bài EC2.
• `Network Access Controll List (ACL)`: được apply ở cấp độ `subnet`, tương tự như security group nhưng có rule Deny và các rule được đánh độ ưu tiên. Mặc định khi tạo VPC sẽ
có 1 ACL được apply cho toàn bộ subnet trong VPC (mở all traffic không chặn gì cả).

• VPC Flow Log: capture (chiếm lấy) các thông tin di chuyển của traffic trong network (phục vụ cho mục đích debug, monitor netowrk)

• VPN Connection: kết nối VPC trên AWS với hệ thống dưới On-premise.
• Elastic Network Interface: đóng vai trò như 1 card mạng ảo. (Mỗi con instance (ec2) có thể gắn nhiều hơn một card mạng ảo)

• Internet Gateway: Kết nối VPC với Internet, là cổng vào từ internet tới các thành phần trong VPC.
• NAT Gateway: dịch vụ NAT của AWS cho phép các thành phần bên trong kết nối tới internet nhưng không cho bên ngoài kết nối tới.
• VPC Endpoint: kênh kết nối private giúp kết nối tới các services khác của AWS mà không thông qua internet.
• Peering connection: kênh kết nối giữa 2 VPC.
• Transit gateways: đóng vai trò như 1 hub đứng giữa các VPCs, VPN Connection, Direct Connect. (dùng cho bài toán vừa có hệt thống trên data center, vừa có hệ thống trên cloud)

# Ví dụ về một VPC có đầy các thành phần cơ bản (Xem hình)

Subnet khi tạo được tạo trên 1 zone thì không thể di chuyển zone này sang zone khác, nếu muốn thay đổi chỉ có xóa đi tạo lại

# Các thành phần của VPC (detail)

## Internet Gateway

(Mặc đinh vpc default đã gắn internet gate)

- Là cửa ngõ để truy cập các thành phần trong VPC.
- Nếu VPC `không được gắn` Internet Gateway thì không thể kết nối SSH tới instance `kể cả instance đó có được gắn public IP.`
- Mặc định default-vpc do AWS tạo sẵn đã có gắn Internet Gateway

## NAT Gateway

(Nat Gateway được tạo trên public subnet)
(lúc này internet không biết đến sự tồn tại ec2, bởi vì nó đứng sau thăng NAT rồi)

- Giúp cho các instance trong Private Subnet có thể đi ra internet mà không cần tới public IP.
- Giúp tăng cường bảo mật cho các resource cần private (App, DB).

## Network Access Control List (ACL)

- Control network in/out đối với subnet được associate
- Mỗi rule sẽ có các thông số:
  • Priority (mức độ ưu tiên, cái nào priority thấp sẽ được đánh trước, và nguyên tắc là đánh giá rule math rồi thì sẽ không dánh giá tiếp)
  • Allow/Deny
  • Protocol (tpc/udp)
  • Port range
  • Source IP (đối với in bount) / Destination IP (đối với outbound)
- Default ACL sẽ allow all. (cho phép truy cập tất cả) (không chặn, vd tất cả con server (ec2) được tạo ra trên subnet đó phải chịu cái control về network traffice, tức là cho phép access từ một rải cố định thôi => thì ta nên apply ACL cho nó )
- Sử dụng quá nhiều rule của ACL sẽ làm giảm performance.
- Rule của ACL là stateless. (tức là cho inbound mà không cho phép outbound một cách tường minh thì req đến sẽ không nhận được repspon, khác với security group là chỉ cần cho phép inbound thì tự đông out bound sẽ nhận được respon)

**Chú ý:** ACL có 2 rule inbound outbound `apply ở cấp sộ subnet` (không apply với ec2, tức là con ec2 nằm trong subnet đó đều chịu ảnh hưởng bởi Access Contro List)

## Security Group

- Thường được dùng để gom nhóm các resource có chung network setting (in/out, protocol, port).
- Khi thiết kế cần quan tâm tới tính tái sử dụng, dễ quản lý.
- Source của một Security Group có thể là `CIDR` hoặc `id của một Security Group khác.`
- Rule của Security Group là stateful và không có deny rule.
- **\*Statefull** có nghĩa là nếu Inbound cho phép traffic đi vào thì khi request tới sẽ nhận được response mà không cần explicit allow Outbound. Khác với Network ACL

## Route Table

- Định tuyến traffic trong subnet hoặc gateway sẽ được điều hướng đi đâu
- `Route Table` sẽ `quyết định` một `subnet` sẽ là `Private` hay `Public`. (tức có route đi tới internet thì bên ngoài internet nhìn thấy những con instance hoặc servce lằm trong subnet đó nếu public id, nếu không không đi qua internet gateway không có cách nào đi qua internet mà chúng ta nhìn thấy các instance đó gọi là private )
- Subnet được gọi là Public khi có route đi tới Internet Gateway và ngược lại.
- Một `Subnet` chỉ có thể associate `1 route table.`
- \* Default VPC do AWS tạo sẵn sẽ có 1 main route table associate với toàn bộ subnet.

==> Một route table đơn có nhiều route, mỗi một dòng nó sẽ define IP range và Destination (tức là gắn với giải ip này thì đi đâu) được gọi là 1 rule
VD 10.x.x.x/x => local (nếu nhu gọi đến ip thuộc rải ip này thì chỉ tìm đến local mà thôi) đây rule default không xóa được
0.0.0.0/0 => Internet Gateway/ NAT gateway (ip cha của các ip, không math với rule (tức là không thuộc các rải ip khai báo) thì nó sẽ kiểm rule này ), ví dụ ta ping google, thì ip google sẽ không match bất kì ip nào thì nó sẽ ra 0.0.0.0 tức ra intenet,

==> Đối với public subnet thì đi ra Internet gateway, private subnet thì đi ra NAT gateway

VD: một rule vpc hàng xóm là vd ta ở vpc hiện tại thuộc rải 10.x.x.x/x muốn perring với dải 172.x.x.x/x, khi ta muốn 2 dải này nhận được nhau ta cần có một cái root thì cho biết là nếu anh muốn tìm ip 172.x.x.x thì anh sang cái vpc hàng xóm mà anh tim thông qua VPC Peering ID

## VPC Endpoint

(giả các con instance muốn connect tới các resource của amazon thì nó có 1 các là đi ra internet, hoặc đia qua NAT gateway, tuy nhiên ta không muốn việc đó xảy ra vì rủi ro về data bị truyền ra internet và hiệu suất không đạt) ==> khắc phục endpoint

- Giúp các resource trong VPC có thể kết nối tới các dịch vụ khác của AWS thông qua private connection. (không đi ra ngoài internet)
- Công dụng: secure, tăng tốc độ.
- Có 2 loại endpoint là Gateway Endpoint (S3, Dynamodb) và Interface Endpoint cho các dịch vụ còn lại (SQS, CloudWatch, ...)
- Endpoint có thể được cấu hình Security (cho phép 1 nhóm instance có thể truy cập thôi, chứ không phải bất kì ai có thể truy cập) tăng cường security về mặt network
- Group để hạn chế truy cập.

==> nếu muốn sài bao nhiêu dịch vụ mà đi qua `private` thì phải tạo bấy nhiêu endpoint chứ không phải 1 end point kết nối tới hết dịch vụ

- endpont tính tiền theo giờ và lưu traffic đi qua endpoint, thương thì để data ở subnet private kết nối tới resource aws thông qua internet (NAT) còn đắt hơn sử dụng endpoint

# Làm sao định nghĩa một VPC?

- VPC được định nghĩa bằng 1 dải CIDR.
- AW S cho recommend chọn 1 trong 3 dải CIDR sau (theo chuẩn RFC-1918)
  • 192.168.0.0 – 192.168.255.255. Ex: 192.168.0.0/20
  • 10.0.0.0 – 10.255.255.255. Ex: 10.0.0.0/16
  • 172.16.0.0 – 172.31.255.255. Ex: 172.31.0.0/16
- Việc định nghĩa CIDR của IP cần tuân thủ một số tiêu chí sau:
  • Cover được số lượng IP private cần cấp phát trong tương lai.
  • Tránh overlap với các hệ thống sẵn có (kể cả on-premise) nếu không sẽ không thể peering.

# Phân chia subnet như thế nào?

- Subnet được coi như một thành phần con của VPC.
- Một VPC có thể chứa nhiều subnet không overlap nhau.
- Khi tạo subnet phải chọn Availability Zone.
- Chọn CIDR cho subnet cần lưu ý:
  • Số lượng IP cho các resource cần cấp phát (EC2, Container, Lambda,...)
  VD: bạn tạo 1 subnet 10.0.1.0/24 sẽ chứa được 256 IP `trừ đi 5 reserve ip của AWS`
  -> 251 IP khả dụng.
  • Số lượng subnet dự tính sẽ tạo trong tương lai.
  • Đặt số sao cho dễ quản lý

# Sử dụng tool để chia VPC và Subnet

[URL][https://www.ipaddressguide.com/cidr]

VD: một dải ip 10.0.0.0/16 sẽ có thể chứa tổng cộng 65536 IPs. 2^(32-16) = 65536

# Sử dụng tool để chia VPC và Subnet

VD: một dải ip 10.0.0.0/22 sẽ có thể chứa tổng cộng 1024 IPs. 2^(32-22) = 1024
==> Số lượng subnet của một VPC = Tổng IP / Số IP của mỗi Subnet = 65536/1024 = 64 subnet
Lưu ý: Các subnet trong một VPC không nhất thiết phải có số lượng IP giống nhau

# Giả sử VPC sử dụng CIDR /16 và Subnet sử dụng CIDR /22 ta sẽ có sơ đồ sau.

\*Việc phân chia bao nhiêu loại subnet phụ thuộc vào yêu cầu về độc lập network cho các component
(gỉa sử tôi có 4 nhóm dành cho ALB, apilication server, data server, management server, phụ thuộc vào yêu câu dự án)
\*Các subnet không sử dụng hết IP của VPC nên trong tương lai vẫn có thể mở rộng tạo thêm subnet nếu cần

# Pricing of VPC

- VPC là một dịch vụ miễn phí tuy nhiên user phải trả phí cho các resource liên quan
  • NAT Gateway: tính tiền theo giờ, ~$45/month/Gateway.
  • VPC Endpoint: Tính tiền theo giờ và lưu lượng traffic.
  • VPN Connection: tính tiền theo giờ.
  • Elastic IP: Tính tiền theo giờ x số IP.
  • Traffic: data đi ra ngoài internet.
  • ...and more

# Lab 1 – Thiết kế VPC Đơn giản

[][cidr icon apt]

- Thiết kế một VPC như sau (sử dụng drawio hoặc Powerpoint)
  • VPC CIDR: 10.0.0.0/16
  • Có 2 loại subnet Public, Private. Mỗi subnet chứa ít nhất 1000 IPs.
  • Mỗi loại subnets nằm ở ít nhất 2 AZ.
  • Có 1 Internet Gateway, cấu hình route table tới Internet Gateway.
  • Có 1 NAT Gateway, cấu hình route table tới NAT Gateway.
- Thiết kế security group cho 4 nhóm đối tượng:
  • Application Load Balancer (ALB): expose port HTTPS 443.
  • App Server cho phép port 80 từ ALB, 22 từ Bastion server.
  • Database Server sử dụng MySQL sd port: 3306. Elastic Search sd port: 9200.
  • Bastion Server: SSH port 22 từ IP công ty.
  • Thiết kế VPC Endpoint cho S3 service.

# Lab 2 – Tạo VPC và các thành phần

- Yêu cầu: Sử dụng AWS Console để tạo các resource đã thiết kế trong bài Lab 1
- \*Lưu ý, trong bài lab này sẽ làm step-by-step để các bạn nắm lý thuyết.
- Thứ tự tạo resources:

1. VPC
   (vpc -> create -> vpc only -> name: udemy-test-vpc -> IPv4: 10.0.0.0/16 -> tenacy: default -> create vpc)
2. Subnets
   (subnet -> create subnet -> chọn vpc vừa tạo (udemy-test-vpc ) -> name: public-subnet-01 -> avaibility zone: ap-southeast-1a -> cidr: 10.0.0.0/22 )
   (add new subnet -> name: public-subnet-02 -> av: ap-southest:-1b -> cidr: 10.0.4.0/22)
   (add new subnet -> name: private-subnet-01 -> av: ap-southest:-1a -> cidr: 10.0.8.0/22)
   (add new subnet -> name: private-subnet-02 -> av: ap-southest:-1b -> cidr: 10.0.12.0/22)
   -> create subnet
3. IGW
   (internet gateway -> create -> name: udemy-internet-gateway -> create -> Action -> attach vpc -> chọn vpc: udemy-test-vpc -> attach)
   mỗi vpc chỉ được gán 1 internet gateway
4. NAT GW
   (NAT gateway -> create -> name: udemy-nat-gateway -> chọn 1 trong 2 subnet public: public-subnet-01 -> Conectivity type: public -> elastic ip: allocate elastic ip -> create)
5. RouteTables (Public and Private). Attach vào subnets tương ứng.
   ----------------------------tạo route table public-------------------
   ==> taọ 2 route table public (sẽ có 1 route đi ra internet gateway) và private (đi ra nat gateway)
   ( routes table -> create -> name: udemy-public-rtb -> vpc: udemy-test-vpc -> create ) -> biến thành public route table, để ý có 1 route table default: destination 10.0.0.0/16, tagert: local (không xóa được, nếug gặp dải ip 10.0.0.0/16 thì đi vao local cho tôi, bởi vì ip đó chính là ip ở trong vpc không phải đi đâu kiếm
   ) => route => edit route => add route => destination: 0.0.0.0/0, target: INTERNET gateway (chọn IG vừa tạo) => save change
   (rule đi ra ngoài IG gọi là public)
   subnet association (ta sẽ association với 2 subnet public, bởi vì route table phải gắn với subnet) => edit subent => associations => chọn public-subnet-01 và public-subnet-02 => save change
   ----------------------------tạo route table private-------------------
   route table => create => name: udemy-private-rtb => vpc: udemy-test-vpc => create vpc
   edit routes => add routes => destination: 0.0.0.0/0 (đại điện cho internet), target: Nat gateway (NAT vừa tạo) => save change
   subnet associations => edit subnet association => chọn 2 private subnet => save change
6. VPC Endpoint for S3, Cấu hình route table private đi ra S3 End Point.
   (end point -> create -> name: udemy-3-endpoint -> service category: AWS service -> search service: s3: chọn ap-southest-1-s3, type: gateway -> vpc: udemy-test-vpc -> route table (nó cho phép ta chọn sẵn route table để tự động add thêm rule vào đây, tôi dự tính chỉ private subnet của tôi mới có những con instance cần kết nối với s3 thông qua endpoint)) => chỉ chọn private route table vửa tạo => policy : full access => create
   (endpoint tạo ra xog sẽ tự động gán vào vpc,`ta quay lại kiểm tra route table private: phần route: sẽ thấy một route được add vào của vpc endpoint, destination: plxxx ip viết tắt cho việc đi sang serivce S3`)
7. Security Group (HÌnh [file:///D:/devops-linh%20nguyen/AWS/0.Slide-PDF%20-%20AWS/14.%20Networking%20-%20VPC%5EJ%20Peering%5EJ%20Endpoint.pdf])
   (sg không liên quan đến subnet, ta muốn apply con instance nào cx được hết, `sg thuộc vpc`)
   (sg => create => name: udemy-public-sg => (xóa đi rồi chọn lại) vpc: udemy-test-vpc => inbound rules: https to anywhere , desc: allow https from anywhre => create ) ==> cho loadblancing
   (sg => create => name: udemy-bastion-sg => vpc: udemy-test-vpc => inbound rule: ssh: myip => tag: Name: sg-> udemy-bastion-sg)
   (sg => create => name: udemy-app-sg => vpc: udemy-test-vpc => inbound rule: http:80 => sg group: udemy-public-sg | add inbound rule: ssh:22 => sg group: sg -> udemy-bastion-sg => tag: Name: udemy-app-sg )
   (sg => create => name: udemy-database-sg => vpc: udemy-test-vpc => inbound: custom tpc -> 9200 -> sg -> udemy-app-sg | inbound: mysql aurora -> sg -> udemy-app-sg | inbound: mysql aurora: sg -> udemy-bastion-sg => tag: Name: udemy-database-sg)

# Lab 3 – Test connection trên VPC vừa tạo

Yêu cầu sử dụng lại VPC của bài lab 2

1. Tạo 1 instance trong Public subnet, gán bastion-sg, thử kết nối.
   (ec2 => create => name: public-subent-instance => network setting: edit -> vpc: udemy-test-vpc -> subnet: public-subent-01 (1 trong 2 subnet public) -> assign public ip: enale -> sg: udemy-bastion-sg => launch template)
   (ping thử gg để xem IG có hoạt động ok không)
2. Gán Elastic IP cho Instance, thử kết nối qua Elastic IP.
   (elastic ip => allocate ip address => ap-southeast-1 => Allocate)
   (lestic ip => action => associate ip address => resource type: instance: udemy-pulic-instance => private id => associate)
3. Tạo 1 instance trong Private subnet, gán app-sg, thử kết nối từ bastion.
   (chú ý không cấp phát public ip cho instance, vì có ip public thì nó không còn là private nữa)
   (ec2 => launch instance => name: udemy-private-instance => os: amazon => network setting: edit -> udemy-test-vpc -> subnet: private-subnet-01 -> public ip: disable -> sg: udemy-app-sg => launch instance)
   (ssh server: public-subent-instance -> sudo vi udemy-singapor-key.pem (copy file key pem máy local vào) -> sudo chmod 400 udemy-singapor-key.pem -> sudo chown ec2-user:ec2-user udemy-singapor-key.pem -> bấm vào private-instacn copy câu lệnh ssh client, chú kết nôi thông qua private ip, vì không có public ip )
4. Ping từ private instance ra internet (vd google.com).
   (ping google.com -> kiểm tra nat gateway)
5. Thử gỡ bỏ route đi ra NAT từ private subnet, thử thao tác với S3 từ private
   instance để check xem S3 Endpoint có hoạt động không. \*\\Chú ý gán Role cho EC2
   instance.`
   (route table => routes => edit routes => bỏ routes: 0.0.0.0/0 -> nat => save change => ping thử gg)
   (iam => role => create => aws service => ec2 => s3fullaccess => name: udemy-test-ec2-s3-role => create)
   (ec2 => udemy-private-instance => action => security => modify iam role => udemy-test-ec2-s3-role => update)
   (ssh vô ec2: udemy-private-instance => aws s3 ls => dùng lệnh để download một file ở s3, nếu download được về thì chứng tỏ nó không thông qua internet vì đã gở nat ra rồi)

# `Trouble shoot lỗi connect`

## Khi các bạn bị lỗi không kết nối được tới EC2, có thể trouble shoot theo các step sau:

1. Check xem VPC có Internet Gateway chưa?
2. Check xem Security Group gán với instance có mở cho SSH từ ip của mình vô
   chưa?
3. Check xem Route Table gán vô subnet chưa EC2 có rule đi ra Internet Gateway
   chưa?
4. Check xem EC2 có Public IP hoặc Elastic IP chưa?
5. Check xem Network ACL gán với subnet chứa EC2 có allow cả 2 chiều
   Inbound/Outbound chưa?
6. Nếu check hết các issue trên vẫn OK có thể do OS treo -> Restart EC2.

## Nhắc các bạn học viên clear resource!!! ☺

Nếu các bạn làm tới đây mà bận chưa thể follow tiếp thì hãy xoá các resorce để tránh mất phí (hôm sau tạo lại).

1. Terminate instance (nếu có)
2. Xoá NAT Gateway (nếu còn lại)
3. Xoá Elastic IP (nếu còn lại)
4. Xoá VPC
5. Xoá snapshot (nếu còn lại)
6. Xoá volume (nếu còn lại)

# Lab 2 – Bonus: Tạo VPC all-in-one-step.

(nó sẽ tạo sẵn vpc, subnet, nat gateway, internet gateway, vpc endpoint)
Yêu cầu:

1. Tạo VPC và các resource liên quan bằng cách sử dụng giao diện VPC mới của AWS.
2. Số lượng public subnet: 2
3. Số lượng private subnet: 4
4. Có gắn NAT, số lượng NAT: 1
5. Có gắn VPC Endpoint cho S3.
6. Riêng security group các bạn phải tự tạo (tương tự bài lap trước nên không cần
   thực hiện lại).
7. Confirm các resource được tạo ra.
8. Xoá VPC đã tạo để tránh phát sinh chi phí

(vpc => create vpc => vpc setting: vpc and more => tích auto-generate => name: udemy-all-in-one-vpc => cidr: 10.0.0.0/16 => tenancy: default => avaibility zone: 2 => ap-1a,ap-1b => public subnet: 2 => private subnet: 2 => nếu muốn custom cidr block => nat: IN 1 AZ hãy mỗi Zone một NAT => VCP endpoint: S3 )

# VPC Advanced section

## VPC Peering

- Là hình thức đơn giản nhất để kết nối 2 VPC trên AWS. 2 VPC có thể cùng account hoặc khác account.
- Để thiết lập, một phía sẽ phải đưa ra peering request (requester) và bên còn lại sẽ accept request (accepter).
- Sau khi đã thiết lập quan hệ peering, cần cấu hình lại Route Table (thêm route đi ra peering connection) và setting Security Group thích hợp để resource ở 2 VPC có thể connect lẫn nhau thông qua private IP (không đi ra internet).
  (peering thông qua private ip)

\*Lưu ý:
• VPC Peering không có tính chất bắc cầu.
VD VPC-A peer VPC-B, VPC-B peer VPC-C ckhông có nghĩa là VPC-A cũng peer với VPC-C.
• Hai VPC muốn peering được với nhau phải có dải IP CIDR không overlap.

# Transit Gateway

(perring không có tính chất bắc cầu)

- Đóng vai trò như 1 hub trung chuyển giữa OnPremise và AWS Cloud hoặc giữa nhiều VPC trên Cloud.
- Thường sử dụng kết hợp với Site-to-Site VPN hoặc Direct Connect. (peering từ on permise lên rất nhiều vpc)

# VPC Advanced section

## Site to Site VPN

- Là hình thức kết nối network Onpremise với network trên AWS Cloud.
- Customer Gateway: thiết bị vật lý hoặc virtual appliance ở phía On-Premise có nhiệm vụ điều hướng traffic.
- Thông tin truyền đi giữa On-Premise và AWS Cloud được mã hoá.
- Bandwidth khoảng ~4Gbps.

## Dirrect Connect

- Hình thức kết nối từ On-Premise lên AWS Cloud thông qua một kênh connect low latency, high speed.
- Connection được duy trì thông qua một đường truyền chuyên dụng không qua public internet.
- Thông tin truyền đi giữa On-Premise và AWS Cloud không được mã hoá by default.
- Bandwidth dao động từ 50Mbps100Gbps.
- Khó setup hơn so với VPN, cần làm việc với nhà cung cấp Direct Connect.

# Lab 3 – VPC Peering

Steps:

1. Tạo nhanh 2 VPC có CIDR không overlap (vd 10.0.0.0/16 và 10.1.0.0/16). Không cần tạo Nat Gateway. Mỗi VPC có 2 subnet public. \*hai VPC có thể khác account.

- account 1: udemy-test-vpc-a -> cidr: 10.0.0.0/16 -> az: 2 -> tendancy: default -> public subnet: 2 -> private subnet: 0 -> nat gateway: none, vpc end point: none -> create vpc

- account 2: udemy-test-vpc-b -> cidr: 10.1.0.0/16 -> az: 2 -> tendancy: default -> public subnet: 2 -> private subnet: 0 -> nat gateway: none, vpc end point: none -> create vpc

2. Tạo 2 security group đơn giản vd: vpc-01-sg, vpc-02-sg

- account 1: security group => name: udemy-test-vpc-a-sg => vpc: udemy-test-vpc-a => create
- - account 2: security group => name: udemy-test-vpc-b-sg => vpc: udemy-test-vpc-a => create

3. Tạo và accept VPC Peering cho 2 VPC.
   (accouont nào được req cũng được hết)
   -account 1: vpc => peering connections => create peering => name: udemy-test-peering-a-b => vpc: udemy-test-vpc-a => Select another VPC to peering with: Another account (or My account) => account Id: xxxx => create peering connection

- account 2: vpc => peering connections: sẽ có một yêu cầu gửi đến để xác nhận => acion: access request
  (vây lúc này 2 vpc peering về mặt danh nghĩa, tuy nhiên cả 2 vpc này chư có route table định nghĩa dải ip của nhau nên traffic đia qua đi lại sẽ không biết sự có mặt của nhau, nhiệm vụ tiếp theo là ta đi moddify route table cho biết cả 2 vpc biết cidr của nhau)

(trong trường này tạo một vpc đơn giản có một route table , còn nếu tạo vpc có 2 cái route table , 1 cái route table cho public subnet, 1 cái cho private subnet)

4. Modify route table cho cả 2 VPC để nhận biết CIDR của nhau.

- account 1: vpc => route table => tích udemy-test-vpc-rtb-public => routes => edit => add route => 10.1.0.0/16 (dải ip của vpc account 2, nếu như một cái ip rơi vào dải này thì điều hướng req đó sang vpc hàng xóm tức account 2, đi qua vpc peering) => chọn peering Connection => chọn udemy-test-peering-a-b => save change

- account 2: vpc => rouate table => chọn cái route table => route => edit => add route => 10.0.0.0/16 => perring connection => chọn udemy-test-peering-a-b => save change

5. Modify security group của VPC-02, allow traffic từ CIDR của VPC-01
   (ta allow một chiều chiều ngược lại tương tự)

- account 2: security group => udemy-test-vpc-b-sg => inbound rules => edit => add rule => all icmp - ipv4 (dùng để ping) => 10.0.0.0/16 => allow ping from ping vpc a => save change

6. Tạo 2 EC2 instance nằm trong 2 VPCs, thử ping từ Instance trong VPC-01 sang instance trong VPC-02 bằng private IP.

- account 2: ec2 => udemy-test-vpc-b-server => vpc: udemy-test-vpc-b-sg => subnet trọn 1 trong 2 cái đều được => auto-asign public ip: disable (kết 2 ec2 bằng private ip) => sg: udemy-test-vpc-b-sg => launch

- account 1: ec2 => udemy-test-vpc-a-server => vpc: udemy-test-vpc-a-sg => subnet trọn 1 trong 2 cái đều được => auto-asign public ip: enable (để ssh vào test ping ) => sg: udemy-test-vpc-a-sg => launch
  ( chú ý udemy-test-vpc-a-sg mở cổng 22 để ssh)

- acount 1: ssh => ping -> private ip của ec2 (account 2)
  ===> vpc 1 đã kết nối được sang vpc 2 thông qua kênh peering, hoàn toàn không dử dụng public ip (tức là vpc 1 không truy cập từ internet rồi mới tới vpc 2, mà thông qua cơ chế peering)

( trong thực tế dự án cần kết nối các port khác như server app bên a cần nối sang server database bên b, thỉ chỉ cần mở port 3306, chỉ cần chỉnh sửa sucriy group thôi, còn về route table cấu hình như vậy là ok rồi, hoặc elasticsearch cấu hình 9200 thì chỉ cần mở 9200 thôi)

7. Clear các resource đã tạo để tránh phát sinh chi phí.
