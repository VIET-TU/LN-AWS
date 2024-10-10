# Load Balance

## Load Balance là gì? Tại sao lại phải cần tới Load Balance?

- Khái niệm “single point of failure”
- Khi một sự cố xảy ra ở một thành phần nào đó có thể dẫn đến hệ thống bị dừng hoạt động, không thể phục vụ người dùng, ta gọi đó là single point of failure.
- Ví dụ:
  • Một chương trình bị lỗi và crash
  • Database bị sập không response
  • Hệ điều hành (OS) bị treo
  • Một trong các phần cứng vật lý (RAM, CPU, Disk, Power,…) bị hỏng

- Lên cấp độ cao hơn chúng ta có các sự cố như:
  • Bộ cung cấp nguồn cho cả 1 Server Rack bị sự cố.
  • Xảy ra sự cố cúp điện cả data center (trong trường hợp không có nguồn dự
  phòng), bị lũ lụt, bão, đánh bom, thiên thạch rớt trúng, v.v..
  => Cần nhiều hơn 1 thành phần cho mỗi layer của hệ thống để tránh “single point
  of failure”.

- Nếu hệ thống có nhiều hơn 1 thành phần, cần có 1 cơ chế để phân phối request từ client đến các thành phần ở backend => Sự ra đời của Load Balancer.
- AWS cho phép dễ dàng setup load balance tới nhiều target nằm ở các Availability Zone khác nhau.
  **Lưu ý**: Mỗi Availability Zone (AZ) tương ứng với 1 data center cách nhau từ vài chục tới vài trăm km. Bằng việc phân bổ các instance nằm trên nhiều hơn 1 AZ, hệ thống có thể chịu được các sự cố ở cấp độ data center của AWS mà vẫn hoạt động bình thường.

3 Elastic Load Balancing là gì?

- Một dịch vụ của AWS có nhiệm vụ điều hướng request từ client đến các target backend, đảm bảo request được cân bằng giữa các target.
- ELB là 1 dịch vụ managed hoàn toàn bởi AWS, dễ dàng setup, có đầy đủ các đặc tính cần thiết như:
  • High Availability
  • Scalability: về lý thuyết là không giới hạn
  • High Security: nếu kết hợp với các dịch vụ khác như WAF, Security Group.
  ELB có thể dễ dàng kết hợp với đa dạng backend sử dụng EC2, Container, Lambda.

# Các thành phần cơ bản của Load Balancer

• Load Balancer cho phép setting các listener (trên 1 port nào đó vd HTTP:80, HTTPS:443)
• Mỗi Listener cho phép cấu hình nhiều rule.
• Request sau khi đi vào listener, được đánh giá bởi các rule sẽ được forward tới target group phù hợp.
• Target group có nhiệm vụ health check để phát hiện và loại bỏ target un-healthy

# Type of Load Balancer

## Application Load Balancer

- Là loại Load Balancer thường dùng, phù hợp cho đa số các nhu cầu.
- Hoạt động trên layer 7 – Application.
- Do hoạt động trên layer 7 nên có một số ưu thể vượt trội so với các loại LB khác:
  • Hỗ trợ Path routing condition (/login, /amdin )
  • Hỗ trợ host condition, cho phép dùng nhiều domain cùng trỏ vào 1 ALB
  • Hỗ trợ routing dựa trên thuộc tính của request (header, ip..)
  • Tích hợp được với Lambda, Container service
  • Hỗ trợ trả về custom HTTP response

# Network Load Balancer

• Hoạt động trên layer 4 – Transport
• Hỗ trợ 2 giao thức TCP và UDP
• Không hỗ trợ nhiều hình thức rule routing.
• Thường dùng cho những hệ thống có workoad rất cao, lên tới hàng triệu request/s

# Gateway Load Balancer

• Giúp triển khai, scale và quản lý các Virtual Applicance (3rd party)
• Mục đích: Firewall, Phát hiện ngăn chặn xâm nhập (intrusion detection and prevention systems), kiểm tra gói tin chuyên sâu.
• Hoạt động trên layer 3 (Network) & Layer 4 (Transport).
• GLB listen trên tất cả các port và forward traffic đến các target group dựa trên các rule.
• GLB sử dụng GLB Endpoint để trao đổi traffic giữa VPC của service provider & VPC của consume

# Load Balancer hoạt động như thế nào?

- Load Balancer có thể điều hướng tới nhiều hơn 1 target. Trong trường hợp multi-target, việc điều hướng tới target nào sẽ được quyết định bởi 1 số rule sau:
  • Listener port
  • Path pattern (Application LB only)
  • Fixed ratio. VD Target Group 01 nhận 20%, Target Group 02 nhận 80% traffic.

  \*Điều hướng tới 2 target làm nhiệm vụ khác nhau dựa vào
  path pattern của request đi tới.

- Mặc định Load Balancer sẽ phân phối request từ client đến các target trong 1 Target Group theo tỷ lệ cân bằng (round robin), kể cả khi `target đó nằm trong nhiều hơn 1 target group.` (chồng chéo khi đăng ký 1 con ec2 ở nhiều hơn một target group, alb sẽ không ý thức được con ec2 này được đăng ký ở nhiều target group)
  VD: trong hình bên mỗi instance sẽ nhận ~16.7% số request từ client.
  **\*\*\*\***Lưu ý các `instance có thể nằm ở các zone khác nhau`**\*\***\*\*\***\*\***
  `Tức là trong một targer group thì có các instance (EC2) có thể ở các zone khác nhau`

# Cross zone load balancer

- ELB là 1 dịch vụ hoạt động cross zone (AWS suggest chọn tất cả các zone có thể khi khởi tạo ELB).
- Nếu Cross zone load balance được enable, ELB sẽ điều hướng request từ client `một cách cân bằng tới các target`.

  **Phân bố request tới target trong trường hợp Cross zone enabled** (ELB sẽ điều hướng tới các target mà không cần biết targert đó nằm ở zone nào, và tỉ lệ giữa 2 zone có bằng nhau hay không)
  VD: Hình bên phải khi cross zone LB được bật, mỗi instance nhận 10% traffic mặc dù có sự chênh lệch phân bổ số lượng instances giữa 2 zone.

- Nếu Cross zone load balance được disable, ELB sẽ điều hướng request từ client `một cách cân bằng tới mỗi zone`, trong 1 zone sẽ chia đều tiếp cho các instances.
  ====> `Tức là thế này trong trường hợp cross zone bị tắt, mà trong target group có nhiều ec2 ở nhiều zone khác nhau, thì khi request thì nó sẽ gọi đều 2 zone, không quan trọng target nữa`
  **Phân bố request tới target trong trường hợp Cross zone disabled** (tức là target nào ít server sẽ bị gọi nhiều hơn)
  VD: Hình bên phải khi cross zone LB được tắt, mỗi instance trong zone A nhận 25% traffic trong khi mỗi instance trong zone B nhận 6.25% traffic.

**NOTE:**
• By default, Application Load Balancer sẽ Enable cross zone, không thể tắt.
• By default, Network Load Balancer sẽ Disable cross zone. Cần enable sau khi tạo.

# Lab1: Tạo 2 EC2, cấu hình loadbalancer

Login to AWS console, thực hiện nội dung sau:

1. Tạo 2 instance A và B, trong quá trình tạo sử dụng userdata đã dc chuẩn bị sẵn, mục đích là để có sự khác biệt về GUI khi truy cập 2 instances.
2. Tạo 1 target group tg-01, register 2 instance ở step trước.
   (EC2 => Loadblancing => Target group => Type: Instance (Name tg-01, Port này là port các con ec2 đang lisnting, vd ec2 httpd: 80) => Add 2 instance vừa tạo => Include as peding below )
3. Tạo 1 Application Load Balancer (ALB), cấu hình listener port 80 trỏ vào tg-01
   (EC2 => Loadbance => ALB => `Internet-facing` (cho phép truy cập từ bên ngoài) => IPV4 => chọn nhiều zone nhất có thể (cross zone) => chọn security group (chọn default) => Listner 80 (1 Alb có thể có nhiều listner) => forwad đên target group ) => bây giờ khi truy cập dns của alb qua cổng 80 sẽ forward đến target group
4. Cấu hình Security Group
5. Truy cập ALB thông qua DNS link.
6. Remove instance B khỏi tg-01. tạo 1 target group mới tg-02 và add instance B vào đó.
   (target group => taget => deregister)
   (EC2 => Loadblancing => Target group => Type: Instance (Name tg-02, Port này là port các con ec2 đang lisnting, vd ec2 httpd: 80) => Add 2 instance vừa tạo => Include as peding below )
7. Tạo thêm 1 listener port 8080, trỏ tới tg-02.
8. Truy cập ALB thông qua DNS link với 2 port 80 và 8080
   (lb => chon alb-01 => listner => add listner => add action => port 8080 => default action: forward => chọn tg-02)
   **chú ý chỉnh sg cho phép port 8080**
9. [Optional] Thiết lập tỷ lệ 1:3 cho traffic đến 2 target group tg-01 và tg-02 trên cùng 1 listener port 80, thử truy cập
   xem ALB có điều hướng tới 2 targets theo đúng tỷ lệ không?
   (lb => listner => xóa lisnter 8080 => bấm http:80 => thêm tg group tg-02 => chỉnh weight (tg-1 1 : tg-02 3) )

# Một số lưu ý về Load Balancer

• Load Balancer là 1 dịch vụ Cross Zone, lưu ý khi tạo ELB nhớ chọn tối đa số zone có thể chọn.
• Nếu Load Balancer được tạo không chọn zone có chứa ec2 instance, khi access sẽ bị lỗi không kết nối được (502 Bad Gateway).
(nếu không chọn tối đa thì zome, chứa ec2 instance không được chọn từ đầu => truy cập sẽ bị lỗi 502, nghĩa nó froward đến zone không chứa instance đó)

# Scaling là gì?

- Là việc điều chỉnh cấu hình của các tài nguyên để đáp ứng với nhu cầu workload (số request từ người dung, số lượng công việc phải xử lý,…)
  Có 2 hình thức scale:
  • Scale Up/Down: Tăng/Giảm cấu hình của resources (vd tăng CPU/Ram cho Server, database, tăng dung lượng ổ cứng,…)
  • Scale Out/In: Tăng/giảm số lượng thành phần trong 1 cụm chức năng. (Vd add thêm server vào cụm application, add thêm node vào k8s cluster,…)

# Auto Scaling Group

- Có nhiệm vụ điều chỉnh số lượng của instance cho phù hợp với workload.
- Mục đích:
  • Tiết kiệm chi phí
  • Tự động hóa việc mở rộng & phục hồi sự cố.
- ASG Sử dụng Launch Template để biết được cần phải launch EC2 như thế nào (next slide)
- Để thực hiện được việc scale, Auto Scaling Group phải kết hợp với việc monitor các thông số của các thành phần trong hệ thống để biết được khi nào cần scale-out, khi nào cần scale-in
  => Sự cần thiết của CloudWatch

# Launch Configuration and Launch Template (thường dụng launch template)

- Mục đích: Chỉ dẫn cho Auto Scaling Group biết được cần phải launch instance như thế nào.
- Các thông tin có thể định nghĩa trong launch template:
  • AMI (window hay linux)
  • Instance Type (sài bao nhiêu cpu, ram)
  • Keypair (trong trường hợp bạn cần login vào instance sau khi tạo)
  • Subnet (Thường không chọn mà để Auto Scaling Group quyết định)
  • Security Group(s)
  • Volume(s)
  • Tag(s)
  • Userdata (script tự động chạy khi instance start)
  **Một số thông tin như Instance Type, Subnet, Security Group có thể được overwrite bởi AutoScaling Group.**
  **Launch Template thường được sử dụng hơn bởi nó có thể quản lý được version.**

# Các phương pháp scale hệ thống

- Có các option sau để scale một Auto Scaling Group
  • No Scale: Duy trì 1 số lượng cố định instances (nếu instance die thì tạo con mới để bổ sung, ngoài ra không làm gì cả)
  • Manually Scaling: điều chỉnh 3 thông số: min/max/desire để quyết định số lượng instance trong ASG.
  • Dynamic Scaling: Scale tự động dựa trên việc monitor các thông số.
  o Target tracking scaling: Monitor thông số ngay trên chính cluster, vd CPU, Memory, Network in-out.
  o Step scaling: điều chỉnh số lượng instance (tăng/giảm) dựa trên 1 tập hợp các alarm (có thể đến từ các resource khác không phải bản thân cluster).
  o Simple scaling: Tương tự Step scaling tuy nhiên có apply “cool down period" tức là có khoảng thời gian nghỉ giữa các lần scale, tránh thời gian scale liên tục
  • Schedule Scaling: Đặt lịch để tự động tăng giảm số instance theo thời gian, phù hợp
  với các hệ thống có workload tăng vào 1 thời điểm cố định trong ngày.
  • Predict Scaling: AWS đưa ra dự đoán dựa vào việc học từ thông số hằng ngày, hằng
  tuần để điều chỉnh số lượng instance một cách tự động. Độ chính xác phụ thuộc vào
  thời gian application đã vận hành và tính ổn định của traffic đi vào hệ thống.

# Ví dụ về trường hợp scale sử dụng metrics đến từ bên ngoài cluster

- Hình bên mô tả 1 cụm server (cluster) có nhiệm vụ xử lý video encoding.
- Danh sách video được lấy từ SQS (một dịch vụ message queue sẽ được trình bày sau).
- Message producer (1 process nào đó) có nhiệm vụ đăng ký video cần xử lý vào queue.
- Nếu số lượng message trên queue quá nhiều hoặc message được ghi vào queue nhưng quá lâu không được xử lý xong, ta có thể monitor queue để ra quyết định có scale-out (add instance vào cụm cluster) hay không.
  (monitor 2 thông số, số lượng message trên queue, nếu vượt quá 100 video thì át thêm insance vô dưới thì remove bớt instance, 2 là monitor tuổi thọ lâu nhất của một message trên queue, nếu video được gửi vào queue quá 30 phút mà không được sử lý thì ta sẽ át thêm instance vô)

# Lab2: Tạo hệ thống có Auto Scaling

1. Enable auto start for service httpd
2. Tạo AMI từ 1 instance đang chạy.
   (Tại sao cần ami, tất nhiên ta có thể dùng user data để cài cắm software tại thời điểm instance được tạo lên, tuy nhiên điều đó sẽ khiến ta bị chậm phải down software đó về, khiến trải nhiệm không được tốt)
   (chọn instance (ec2) => Action => image => create image => try cập ami (images))
3. Tạo Launch Template (chỉ dẫn đểu autoscaling group biết được biết được cần phải launch instance như thế nào)
   (lauch template (instance) => create launch => chọn MyAmis => chọn ami vừa tạo => chọn instance type => keypair => network setting: don't include in lanch template (để cho asg tự quyết định network => sg => tag {key: Name, value: Webserver, Resource type: instance , volumes}))
4. Tạo Auto Scaling Group, chọn target group cho ASG là tg-01
   (chọn asg => chọn template ta vừa tạo => chọn version => vpc default => chọn tối đa subnet có thể => instance type: chọn overide lauch template => chọn manually add instance type => chọ t2micro (chọn lớn hơn nó ghi đè) => chọn attach to exit lb (nếu đã tạo lb rồi) => chọn you lb target groups => chonj tg-01 => chọn no vpc latice service => chọn health checks => chọn enable default warmup (time instance start không tính vô metric) => min 2, deesired, 2min,4max => scale policies: none => bỏ qua nofication =>add tag: {Name: webserver })
5. Cấu hình Application Load Balancer trỏ vào tg-01
6. Kiểm tra số lượng instance tạo ra có phù hợp chưa.
7. Thử terminate 1 instance xem ASG có tự tạo lại instance khác để bổ sung không?
8. Điều chỉnh số lượng instance trong ASG (tăng hoặc giảm size min + desire capacity)
   (asg => detail => edit)
9. Thử access liên tục xem ASG có tự add thêm instance không? (trước đó có cấu hình bật auto-scale).
   (asg => automatic scaling => dynamic scaling policies => create => policy type: target tracking scaling (monitor trên chính cluster này tức asg) => Metric type: Average network in => 2000 (rất ít) => instance need 300 (thời gian chờ trước khi metrics) => qua cloudwatch kiểm tra => all alarms (tạo 2 alarm là high 2000 và low 1800))
10. Thử setting Schedule Auto Scaling (Lưu ý: chọn thời gian gần để test)
    (asg => automatic scaling => Scheduled action => create => 444 => every day => timezone => đặt giờ)

11. tạo version mới
    (launch template => action: modify template => v1.2 (từ version 1) => ami có dùng cũ hoặc mới (quick start) => advan detail => userdata => dán bashscript vô) => khi ta update nó không thay đổi version ngay lập tứ => vô asg chỉnh thông số để tạo thêm 2 từ 2 instance bân đâu, cluster ổn định thì chỉnh xuống 2

# Hiểu rõ về 3 thông số Min, Max, Desire capacity

- Về bản chất ASG nhìn vào thông số Desire capacity để
  biết được cần thêm hay bớt instance trong cluster.
  Vd:
- Cluster đang có 2 instances, set desire = 4 => ASG sẽ add thêm 2 instance.
- Cluster đang có 4 instances, set desire = 3 => ASG sẽ terminate bớt 1 instance
- Min: Sau khi số lượng instance bằng với min, ASG sẽ không terminate bớt instance vì bất cứ lý do gì.
- Max: Sau khi số lượng instance bằng với max, ASG sẽ không add thêm instance vì bất cứ lý do gì.

# Elastic Load Balancer stickiness session

• Cho phép điều hướng một client cụ thể tới target cố định trong một khoảng thời gian. (tức là một server cố định trong taget group, giả sử có 2 con thì nó chỉ điều hướng đến 1 con)
• Phù hợp cho các website sử dụng công nghệ cũ quản lý session của user trên RAM.
(lb => chọn lisners => chọn port 80 => chọn action => chọn edit => enable group level stickines => 1 hours)
(tg => chọn tg-01 => action => edit tagret grup attribute => bật stackness => 1 hour)
