# What is RDS

- Viết tắt của Relational Database Service
- Là một service giúp người dùng tạo và quản lý các Relational Database.

# Đặc trưng cơ bản của RDS

• Là một Database as a Service. User không cần quan tâm tới hạ tầng ở bên dưới.
• Cho phép người dùng tạo ra các database instance độc lập hoặc cụm instance hoạt động dưới mode Cluster.
• Không thể login vào instance level (khác với việc tự cài DB lên 1 EC2 instance).
• Có thể scale theo 2 hình thức
o Scale virtical: tăng hoặc giảm cấu hình instance.
o Scale horizontal: thêm hoặc bớt node tuy nhiên node này chỉ có thể read (read-replica).
• Có giới hạn về dung lượng ổ cứng tối đa (64TB đối với MySQL, Maria,... 16TB đối với Microsoft SQL).

# Features of RDS

RDS cung cấp các tính năng cơ bản sau:
• Cho phép tạo các DB Instance hoặc cụm cluster một cách nhanh chóng.
• Tự động fail-over giữa master-slave instance khi có sự cố.
• High-Availability: tự động cấu hình instance stand by, người dùng chỉ cần chọn.
• Tự động scale dung lượng lưu trữ (optional) (nếu bật lên khi lưu trữ hết dung lượng sẽ tự động tăng dung lương ổ cứng lên database)
• Liên kết với CloudWatch để giám sát dễ dàng.
• Automate backup & manage retention. (sự giự lại)
• Dễ dàng chỉnh sửa setting ở cấp độ Database sử dụng parameter goup.

# RDS supported engines

RDS Hỗ trợ các engines sau:
![alt text]({BA5D6B8B-0099-484D-A72E-BA91EC8E6512}.png)

\*Aurora hiện tại chỉ hỗ trợ 2 engine là Aurora MySQL và Aurora PostgreSQL

# RDS Usecase

- RDS được sử dụng trong hầu hết các trường hợp cần database dạng quan hệ. Vd: lưu trữ thông tin của user, website e-commerce, education,...
- RDS thích hợp cho các bài toán OLAP (Online Analatical Processing) (tập chung vào việc phân tích query) nhờ khả năng truy vấn mạnh mẽ, cấu hình có thể scale theo yêu cầu.

# RDS Pricing

Về cơ bản RDS tính tiền dựa trên các thông số
• Instance size. Instance size càng lớn cost càng cao. Có hỗ trợ reserve instance tương tự EC2.
• Lượng data lưu trữ (GB/month)
• Dung lượng các bản snapshot được tạo ra. (giá snapshot sẽ rẻ hơn)
• Các tính năng khác vd Backtracking đối với Aurora.

# Mô hình triển khai RDS

RDS Có thể được triển khai theo một số mô hình sau
• Single Instance
• Single Instance with Multi-AZ option = yes
• Master – Read Only cluster
• Master – Read Only cluster with Multi-AZ option = yes (bật Multi-AZ cho từng Node)
• Master – Multi Read cluster

## Single Instance

![alt text]({D9338F26-8C6D-4C73-9CFF-0A8912CC2651}.png)

- Chỉ có 1 database instance duy nhất được tạo ra trên 1 Availability Zone (AZ)
- Nếu sự cố xảy ra ở cấp độ AZ, database không thể truy cập.
- Phù hợp cho môi trường Dev-Test để tiết kiệm chi phí

## Single Instance with Multi-AZ option enabled

![alt text]({28B2F4B6-EB5A-4F10-ACED-33FEA326B2D1}.png)

- Một bản sao của instance sẽ được tạo ra ở AZ khác và hoạt động dưới mode standby. (không nhình thấy instance này và không truy cập được vào nó, chỉ biết Amazone sẽ tạo ra 1 con instance ở mode standby)
- Nhiệm vụ của instance standby này là sync data từ master, không thể truy cập instance này. (Nhiệm vụ nó sync data liên tục, khi có sự cố xảy ra thì con này sẽ chuyển thành master)

![alt text]({359DA98E-32EF-407F-8EC8-4256F57F2101}.png)
\*Instance standby được AWS tạo ra tuy nhiên user không thể kết nối tới instance này.

- Khi có sự cố, instance standby sẽ được chuyển lên thành master (việc này được AWS thực hiện tự động, endpoint url được giữ nguyên).
- Nếu enable multi AZ, số tiền bỏ ra sẽ x2.
- Phù hợp cho Database Production.

## Master – Read Only cluster

![alt text]({B4600361-AE05-430E-8D84-8E45F60EE75F}.png)
\*Instance read-only không nhất thiết phải khác AZ với Master

- Một instance với mode ReadOnly sẽ được tạo ra và liên tục replica data từ master instance.
- Instance này chỉ có thể đọc data. Phù hợp cho hệ thống có workload read>write, muốn tối ưu performance của Database.
- Sau khi thiết lập quan hệ, instance được tạo ra sẽ kết hợp thành 1 cluster.

![alt text]({121074CF-9326-4F44-8044-24B82FACBB6D}.png)

- Trong trạng thái 2 instance đã hình thành cluster, nếu Master instance gặp sự cố, failover sẽ được tự động thực hiện, ReadOnly instance được promote lên làm Master.

\* Lưu ý: Nếu 2 instance được tạo ra riêng biệt sau đó mới thiết lập quan hệ read-replica, endpoint của 2 instance sẽ riêng biệt nên sau khi failover, cần chỉnh lại connection từ App.

\* Nên tạo cluster sau đó mới add node read vào để quản lý connection ở cluster level (số lượng node read có thể tuỳ chọn)

# Master – Read Only cluster with Multi-AZ option = yes

![alt text]({6D9B99A7-FEE1-4B16-927B-D507D13719A6}.png)

- Tương tự mô hình Master – Read Only tuy nhiên các node đều được bật multi-AZ enabled.

- Chi phí sẽ gấp 4 lần mô hình Single Instance.

# Master – Multi Read cluster

![alt text]({CD978E73-11D5-47D0-B658-9C2E6FDC1233}.png)

- Với mô hình này, nhiều hơn 1 reader instance sẽ được tạo ra.

## Nên tạo RDS Cluster hay RDS Instance?

- AWS cung cấp cơ chế cho phép tạo ra 1 cluster RDS giúp quản lý node và failover dễ dàng hơn.
- Ưu điểm so với việc tạo RDS instance thông thường:
  • Quản lý endpoint ở cấp độ cluster, không bị thay đổi khi instance trong cluster gặp sự cố. (giả sử instance đó bị faild hoặc amazone có vấn đề thì nó sẽ switch sang cái zone tiếp theo, con slave sẽ thành master )
  • Failover tự động.
  • Scale read instance dễ dàng.

## Nên tạo RDS Cluster hay RDS Instance?

![alt text]({348C87BD-62E7-49A7-B597-4B81DEC6744B}.png)

(Ta tạo một RDS cluster lúc này app server chỉ cần biết đến endpoit read và write của cluster thôi không cần biết endpoint của những con instance ở trong, khi master gặp sự cố thì 1 trong 2 con read sẽ lên làm master, lúc này url sẽ không cần cập nhật lại vì là endpoint của cluster)

# Lab 1 – RDS Basic Operation

\*Yêu cầu cài sẵn MySQL Workbench

1. Login to AWS console, navigate to RDS
2. Tạo 1 RDS instance với cấu hình cơ bản db.t3.medium, engine MySQL
   (RDS => Database => create database => method: Standard create => Engine type: Mysql => Engine version: mặc định => Template: Dev/Test => Deployment option: Single DB instance => DB identiier: udemy-db-instance-01 => Master uername: admin => chọn Self managed => Master password: "viettu123" => DB instance class: Burstable class (m, r, x khá mắc tiền) -> db.t3.medium => Stroage type: IOS SSD gp3 => Allocated stroage: 20 (GB) => Stroage autoscaling: tích (nều sài hết sẽ tăng thêm ổ cứng) => vpc: default=> subnet gruop: default (bản chất là 1 nhóm subnet, chỉ ý nghĩa là db trong mod multi AZ sẽ có 1 instance ở subnet này và 1 insatnce ở subnet kia ) => public access: Yes (chọn No không cách nào kết nối Db) => Security group: default => Avaibili zone: (nếu không chọn thì nó sẽ random 1 trong az) => create database )
   (DB => udemy-instance-01 => chọn vào security group => edit rule => add rule => chọn MYSQL/Aurora => srouce: My ip => save rule)
3. Kết nối tới instance sử dụng MySQL Workbench
   ![alt text]({34ECCA76-4E43-488F-9DFC-BFD813BF03F8}.png)
   ![alt text]({9B327F24-6878-4E7F-BC86-4CE91F552DAB}.png)
   ![alt text]({656C4F8B-3944-450C-9934-C35BACCE8D5E}.png)
4. Thực hiện 1 số câu lệnh CRUD cơ bản.
   ![alt text]({2CF52D91-E880-4977-B8DA-20AB9DADE309}.png)
   Sẽ thấy mọt Db đực tạo ra
   ![alt text]({6B728B7D-F176-4C6B-B278-21A2C65AB54B}.png)
   ![alt text]({AA72AF85-E85A-424F-B83F-5B7F5BF50925}.png)
   Update
   ![alt text]({6530F700-5F6B-4A99-878C-4B4B5DFF3351}.png)
5. Tạo thêm instance với role Read Replica.
   (udemy-db-instance-01 => Action => create read replica => identifer: udemy-db-instance-read-replica => db instance class: burstable class -> db.t3.medium (giống với con master) => seting khác mặc định => deployment option: Single DB instance => public access: tích bật lên => create replica)
   (Enpoint của 2 db này không giống nhau => phải tạo kiểu cluster)
   ![alt text]({3C7E6BE1-92CF-4061-92AD-DE1A94CE3E36}.png)
6. Kết nối tới Read instance sử dụng MySQL Workbench
   ![alt text]({AE07C091-7E94-458E-8C59-86C5E80BB767}.png)
   Vì là replica lên setting nó giống con master kể username password
   ![alt text]({BD5BA34A-5DBF-470A-87EE-5104394C947E}.png)
7. Thực hiện 1 số câu lệnh CRUD cơ bản => Read only.
   Có luôn database "company" tạo ở db master (chưa làm gì hết)
   ![alt text]({19563CA4-CB64-447F-AD79-E64E338FF6B0}.png)
   ![alt text]({E6FB650F-8917-4C49-A491-113D93B5724B}.png)
   Bây h ở db master thủ 1 vài thao tác để xem con replica có bị thay đổi theo không => insert thêm
   ![alt text]({C14DEBAB-F93F-4F9A-A571-51220B214B22}.png)
   ![alt text]({FDC34801-8C2B-44B8-B9DD-EACBCEA95C93}.png)
   Bây giờ select ở con replica xem có update data mới không => Thấy có data mới từ con master
   ![alt text]({9B961A20-A22D-45B8-B395-E0BB95CBA385}.png)
   Thủ update data ở replica xem được không => sẽ báo lỗi Mysql server is running with the --read only option so it cannot exec this statement
   ![alt text]({6F419AD3-523D-46F0-8BE8-75C32D82A9C1}.png)
   ==> Bản chất replica sinh ra để share wordload với con master và endpoint sẽ khác do ta tạo 2 instance riêng lẻ xog mới ghép lại với nhau
8. Test delete Master Intance => Kiể tra xem có failover không
   ![alt text]({10ACCE6E-BFAF-4F9C-B69D-B06EF81CBA18}.png)
   ![alt text]({B21AFDD3-FC93-418B-A912-58A804B26746}.png)
   (chọn con primary => Action => Delete)
   ![alt text]({7D3A4A2E-838C-4DB6-B3BE-E285F1355037}.png)
   2 Con server lúc này sẽ không còn quan hệ cluster nữa
   ![alt text]({C0971799-4BD5-4861-9826-09E2F180C828}.png)
   Con instance replica đã chuyển thành master (thực ra là single instance)
   ![alt text]({67B4F420-7AF4-4C7E-AA50-24753104A283}.png)
   Kiểm tra update, insert, delete trên con instance vừa chuyển thành primary => Thủ update thì thành công
   ![alt text]({1699055E-C9C8-405D-9277-2C3D9D61931F}.png)
   Thử update user
   ![alt text]({81C4EDB2-1480-4D8A-9825-4F131DB659F3}.png)

## Nó thêm về tính năng RDS Snapshot

- Là cơ chế giúp ta recovery database khi có sự cố xảy ra, giống EC2 snapshot
- Bây h tôi có 1 bản snapshot và giả sử data có sự cố tôi muốn recovery về bản snapshot gần nhất
  ![alt text]({E15EB1A8-E104-4C05-965D-56070FD4A969}.png)
  (Chọn snapshot => Action => Resotre snapshot (nó sẽ quy về giao diện tạo db mới, username và password nó sẽ ăn theo giống bản snapshot) )

# Lab 2 – RDS Cluster

1. Login to AWS console, navigate to RDS
2. Tạo 1 RDS Cluster.
   (RDS => Database => Create database => Engine type: Mysql => tmeplate: Dev/test (Producnt thì cấu hình nó cao) => deployment option: Multi-AZ DB Cluster => identifier: "udemy-test-cluster-01" => master username: admin => master password: "viettu123" => Db instance class: Standard classes -> db.m5d.large => Stroage type: IPOS SSD (io1) => Allocated stroage: 100 => Provisioned IOPS: `1000` (để nhiều nó sẽ rất tốn tiền ngay lập tức) => vpc: default => public access: yes => sg: default => create dataabase )

Nó tạo sẽ 3 con read luôn mặc dù ta không chỉ định số lượng read
![alt text]({9FFBD9D0-FBF8-45F2-8887-9F37E83537E5}.png)
và 3 con read này đều được bật MUlti AZ tới 3 Zone lận tổng cộng ta tốn đến 9 lần tiền so với tạo single instance
![alt text]({CB45670F-2677-4489-809B-1B86FB1653F3}.png)
![alt text]({A22ED38D-BD2D-4E43-B23B-FFADE514CC22}.png)

Và nó sẽ phân chia role, 1 con Writer instance và 2 con Reader instnace
![alt text]({A6C305CB-8889-466B-BF1F-A97499CD359C}.png)

Đúng như mô hình đã chình bày thì nó 2 endpoint là 1 endpoint writer không có ký hiệu ro và 1 endpoint reader ký hiệu ro
![alt text]({E4B8C39C-B17F-4DD1-A9FA-509A60539F91}.png)
Tích vô từng con instance db vẫn sẽ có endpoint riêng của từng con tuy nhiên ta sẽ không sử dụng endpoint của từng instance này vì khi faild over sảy ra thì ta sẽ tự cập nhật trên application => thay vào đó ta sẽ dùng 2 endpoint của cluster
![alt text]({D96A2001-DBD0-455C-82C8-F4B8241563E1}.png) 3. Kết nối với Cluster thông qua Cluster Write Endpoint.
(chý ý: kiểm tra security group xem có mở port chưa và MY IP đúng chưa)
![alt text]({0AEEA0B3-0F4C-4CA6-82BD-44B65BCCAC0D}.png) 4. Thực hiện 1 số câu lệnh CRUD cơ bản.
![alt text]({9EA4566E-965B-4B7D-8278-E9220D498B3A}.png)
![alt text]({FE6416F9-4713-4775-85D0-57169F9D0441}.png) 5. Kết nối với Cluster thông qua Cluster Read Endpoint.
![alt text]({82F8673D-F307-4DB8-98C9-A4D1ACDF4599}.png)
Thủ insert xem được không => lỗi không insert được
![alt text]({57F2909E-3B86-4C02-B5E7-AC38589FBA9C}.png)
![alt text]({18E29769-D46C-4207-94C3-D12E8F98EC8A}.png) 6. Thực hiện 1 số câu lệnh CRUD cơ bản.

# Aurora

- Aurora là công nghệ database độc quyền của AWS, hỗ trợ 2 loại engine là MySQL và PostgreSQL.
- Aurora có 2 hình thức triển khai:
  o Cluster (Master + Multi Read Replica)
  o Serverless
- Những tính năng vượt trội của Aurora so với RDS thông thường
  o Hiệu năng tốt hơn (so với RDS instance cùng cấu hình. \*Cái này là AWS quảng cáo ☺)
  o Hỗ trợ backtracking (1 tính năng cho phép revert database về trạng thái trong quá khứ tối đa 72h). Khác với restore từ snapshot đòi hỏi tạo instance mới backtracking restore ngay trên chính cluster đang chạy.
  o Tự động quản lý Write endpoint , Read endpoint ở cấp độ cluster.

# Mô hình cluster của Aurora

![alt text]({6D128EF5-E439-401E-8D76-CAF5A5E5D843}.png)

- Cluster Aurora bao gồm:
  • 1 Master node (Primary instance)
  • 1 hoặc nhiều Replica node (tối đa 15)
- Data của Aurora cluster được lưu trên một storage layer gọi là Cluster Volume span trên nhiều AZ để tăng HA.
- Data được Cluster Volume tự động replicate trên nhiều AZ. \*Số lượng copy không phụ thuộc vào số lượng instance của cluster. (giả sử ta có 3 con instance thì số lượng bản copy sẽ được tự động amazon tính toán và nó lưu phù hợp trên các zone làm sao khi có sự có zone xảy ra thì nó không bị biến mất, nó không phụ thuộc việc ta chỉ có 1 instance thì nó chỉ copy ở một zone)
- Cluster Volume tự động tăng size dựa vào nhu cầu của người dùng (không thể fix cứng size).

# Mô hình cluster của Aurora

## Aurrora Global Cluster

![alt text]({2CA83724-626B-4898-B287-0D4BF022ACC8}.png)

\* Khác với RDS thông thường, Aurora sử dụng tầng Storage để replicate data giữa master-read nodes (điều này sẽ khiến cho việc replica data từ Node primary sang node replica không tiêu tốn cpu và memory của bản thân con instance => cho nên tốt hơn về mặt hiệu năng)

- Là một cơ chế cho phép tạo ra cụm cluster cross trên nhiều regions.
  • Tăng tốc độ read tại mỗi region tương đương với local read. (giả sử ta có server đặt tại tokio nhưng lại có lượng khách hàng tiềm năng ở đặt ở singapor, ta muốn người ta có thể read data ở tốc độ nhanh thì ta dùng mô hình Global Cluster)
  • Mở rộng khả năng scale số lượng node read (limit 15 read nodes cho 1 cluster).
  • Failover, Disaster recovery: rút ngắn RTO và giảm thiểu RPO khi xảy ra sự cố ở cấp độ region. (giả sử người dùng ta có 2 region ở tokio và singapor, khi xảy ra hỏng hóc ở toàn region tokio chúng ta vẫn có thể switch wordload đó sang singapor )
- Mặc dịnh cluster ở region thứ 2 trở đi chỉ có thể read, tuy nhiên có thể enable write forwarding để điều hướng request tới primary cluster. (write ở region thư 2 sẽ được forward lại region thứ nhất)

# Mô hình Serverless của Aurora

• Aurora Serverless là 1 công nghệ cho phép tạo Database dưới dạng serverless. (không có các Node)
• Thay vì điều chỉnh cấu hình của DB instance, người dùng sẽ điều chỉnh ACU (Aurora Capacity Unit), ACU càng cao hiệu suất DB càng mạnh.
• Phù hợp cho các hệ thống chưa biết rõ workload, hoặc workload có đặc trưng thay đổi lên xuống thường xuyên.

# Lab 3 – Aurora

1. Tạo Aurora Cluster với 2 instance (một Write, một Read-replica).
   (RDS => Create database => engine type: Aurora Mysql => Mysql version: mysql 5.7 (tại sao không dùng mới nhất, vì version 8 chưa hộ trỡ back tracking) => Template: Dev/Test => Identifier: "aurora-cluster-01" => master username: admin => master password: "viettu123" => Db instance class: Burstable class -> db.t3.medium => Multi-AZ deployment: Create an Aurora Replica or Reader node (tạo sẵn Node Read, chải nhiệm khả năng có một `node` write và read) (tạo thêm 1 bản sao cho mỗi instance và bản sao chạy dưới mode slave và ta không kết nối được đến nó, khi nào có sự cố ở bản chính thì nó mới swtitch qua thôi) => vpc: default => public access: yes => sg: default => Additional configuration -> Back track: tích Enable Bactrack -> 24 (để càng lâu càng tốn tiền)(chọn thời gian tua ngược, tối đa 72 tiếng, nêu ta chỉnh sửa data có bị mất data, ta hoàn toàn có thể backtrack lại 72 tiếng trước) => Log export -> bật erro log, bật slow query log => Maintenance: (nếu bật lên thì khoảng thời gian nào đó nó sẽ tự động nâng cấp, bởi vì rds là manage service lên amazon làm cho ta rồi) => create database )

Nó sẽ tạo 1 cluster có 2 con instance, 1 con write và 1 con read
![alt text]({9176ECB8-D5D4-4064-B9D9-4FCBB36DEF0C}.png)
![alt text]({9FC31C65-C4E4-4377-808B-2A3CACF851E6}.png)
Cluster endpoint (không sử dụng instance endpoint)
![alt text]({0B7F6342-1AFC-47AD-973F-42D7396D44CB}.png)
![alt text]({4F32EF6B-59D3-4AB3-9590-BA0D68DAC1FA}.png)
Chú ý scurity group đã mở port MYSQL/Aurora 2. Kết nối đến Cluster sử dụng Write endpoint.
![alt text]({8C574773-2075-415B-9BB9-82C4A4C8925D}.png)
Tạo db và table
![alt text]({E94556D4-4285-45D2-9A81-7B026A932E21}.png) 3. Thực hiện một số thao tác đơn giản (CRUD).
![alt text]({3DBA9E7C-23E6-4494-852F-B409B7C2ACC9}.png)
Update lại
![alt text]({E5B4F9C3-F50B-4C6A-A46D-0F6B7266A2D7}.png) 4. Enable tính năng back tracking
(Nếu trưa enable => chọn cluster => chọn Modify => Enable backtrack => save )
![alt text]({84039C0B-1FC7-4A82-8211-CC691E7E9B1A}.png) 5. Đợi khoảng 5 phút. 6. Xoá toàn bộ data.
Chạy câu lệnh delete vài row data
![alt text]({0916781C-5E85-40D4-87C1-74405508C61C}.png)
![alt text]({822CC07D-89DA-4A73-89CD-A3F3EB870D60}.png)
![alt text]({934C568A-0E81-436C-ACF9-473DE43E74BC}.png)

7. Thực hiện back tracking về 5 phút trước đó. (lúc 9h40 xóa data) (tua ngược thời gian trên chính cái database này và nó không tạo lại cái cluster mới, bản chất back tracking nó dùng transaction log)

(Chọn cluster => Action => Backtrack => chọn thời điểm 9h38 lúc đó chưa xóa data => Backtrack DB cluster )
![alt text]({206994E9-E6DC-4A72-99CB-30DED24F10D1}.png)
![alt text]({14AF9E43-DD24-40DF-AE1D-F09C54DE8EF4}.png)
Đợi vài phút thì backtracking xog
![alt text]({BF07118F-07B8-41DB-B354-C7BD70144ADC}.png) 8. Kiểm tra data đã được phục hồi lại trạng thái trước khi bị xoá.
Kiểm tra data có được khôi phục không

Đã phục hôi lại data => lục 9h40 xóa chỉ giữ lại 1 row, bh đã có lại toàn bộ data (Backtraking muốn chạy bao nhiêu lần cũng được nếu còn trong khoảng thời gian setting)
![alt text]({98710483-5491-4D97-97A6-B31C41E9EE72}.png)

# Parameter Groups

• RDS là một managed service do đó `không thể login vào instance`. Nếu muốn can thiệp vào setting ở cấp độ DB (không phải setting OS) ta cần thông qua 1 cơ chế
gián tiếp là Parameter Groups.
• Khi tạo RDS nếu không chỉ định gì AWS sẽ sử dụng Parameter Group default của hệ database đang chọn. Default Parameter Group không thể chỉnh sửa.
![alt text]({3C94083C-B444-472C-98B0-93A9B45A379F}.png)
![alt text]({EBBD56B3-1DFE-443E-A605-AC2B38A1CA58}.png)
• Custom Parameter Group được tạo ra bằng cách copy default Parameter Group sau đó chỉnh sửa những tham số phù hợp với nhu cầu.
• Parameter Groups có 2 loại là Cluster Parameter Groups và Instance Parameter Group. Hai loại này khác nhau về scope có thể apply. (cluster thì apply cho cluster, instance apply cho instance, khi apply cho cluster prameter goup thì bản thân nó sẽ đồng bộ setting xuống từng con instance trong thôi)
![alt text]({5039DD3F-5C23-4EF1-BCB7-A01D8DB2A750}.png)

# Parameter Groups

Một số Parameter thường được custom riêng theo nhu cầu hệ thống

![alt text]({50914235-D2DE-4670-B869-205B7B59D63D}.png)

# Option Groups

- Tương tự Parameter Group tuy nhiên Option Group định nghĩa những setting liên
  quan tới Security là chủ yếu
- Một số ví dụ về option group:
  o SERVER_AUDIT_EVENTS: Loại action sẽ được log ra, vd: CONNECT, QUERY, QUERY_DDL, QUERY_DML, QUER
  o SERVER_AUDIT_INCL_USERS: Inlcude users vào audit log.(User nào khi thực hiện một số hành động thì log ra log audit)
  o SERVER_AUDIT_EXCL_USERS: Loại trừ users khỏi audit log (vd system user).
  o SERVER_AUDIT_LOGGING: Bật tắt audit logging.

# Lab 4 – RDS Parameter Groups

![alt text]({7DEE9752-00F7-4A60-BEFE-5AFA21494E80}.png)

1. Tạo 1 Parameter Group từ default MySQL 5.x
   (RDS => Parameter groups => create parameter group => family: aurora-mysql5.7 (bởi vì mysql đang chạy là 5.7) => type: DB cluster Parameter Group => group name: "udemy-mysql-custon-cluster-parameter-group" => create)
2. Setting các thông số như bảng sau
   (Bấm vô udemy-mysql-custon-cluster-parameter-group => Edit parameter => đầu tiên: max_connections: 100 => max_allowed_packet: 100MB (như ảnh) => long_query_time: 0.5 (query nào chạy chậm hơn 0.5s coi là slow query) => show_query_log: 1 (có log ra show query không) => Save change )
3. Apply Parameter Group đó cho 1 cluster.
   ( RDA => Database => chọn cluster => Modify => DB option -> Db cluster parameter goup -> chọn cái "udemy-mysql-custon-cluster-parameter-group" => continue => chọn Apply immediately (Sẽ có nữa chọn apply ngay lập tức hay apply vào thời điểm maintein) => modify cluster)

![alt text]({0B4845D5-93F1-47F3-9EF7-87174BDCB034}.png)
![alt text]({EA0543EB-347C-40F6-AAC4-E8CCE66A1555}.png)

Phải rebot lại instance
![alt text]({A36ABE31-35C5-4F95-8EC4-3ED9789F9EDF}.png)
Kiểm tra
![alt text]({0B634A22-5587-46F7-B30E-9D587E7A3D77}.png)
Vô cloudwatch kiểm tra xem nó log ra không
(cw => log groups => query nào slow nó sẽ log ra, câu query nào chạy chậm để sớm phát hiện ra query nào chạy chậm)
![alt text]({536671CD-F9F4-4D8E-8A8D-0D5F7A8FD066}.png)

Câu lệnh chạy giả lập phần slow_query

```sql
-- SIMULATE SLOW QUERY
DELIMITER $$
DROP FUNCTION IF EXISTS `iterateSleep` $$
CREATE FUNCTION `iterateSleep` (iterations INT)
RETURNS INT DETERMINISTIC
BEGIN
    DECLARE remainder INT;

    SET remainder = iterations;

    read_loop: LOOP
        IF remainder=0 THEN
            LEAVE read_loop;
        END IF;

        SELECT SLEEP(2) INTO @test;
        SET remainder = remainder - 1;
    END LOOP;

    RETURN iterations;
END $$
DELIMITER ;

-- TO TEST IT OUT
SELECT iterateSleep(2);

```

![alt text]({CD3A188B-4B1F-48B6-8A34-AB6897D6D845}.png)
![alt text]({D10C315A-5A44-4416-B828-0AFDF99C7551}.png)
Chạy lệnh select (câu query sẽ chạy mất 2s sẽ lơn hơn 0.5 mà ta setting trên cluster)
![alt text]({21FFCD79-5DCE-4EEF-82AA-189A32E7BED4}.png)
![alt text]({D532CFA2-605B-4763-9762-8E7876339E62}.png)

Qua cloudwatch log group
![alt text]({C3E72399-8EFF-42DA-8575-2B8F66065AF2}.png)
Nó sẽ log ra câu query đó chạy chậm
![alt text]({A5451F0C-E489-4BDC-90BE-549EC6DE65F9}.png)

# RDS Proxy

• RDS cung cấp cơ chế proxy giúp quản lý connection tới các instance một cách
hiệu quả, hạn chế bottle neck (VD: do application quản lý connection không tốt gây ra).
• Khi sử dụng proxy, application sẽ không kết nối trực tiếp tới RDS mà thông qua proxy endpoint.
• Chi phí sẽ phát sinh thêm cho proxy.
• Hiện tại hỗ trợ 3 engine: MySQL, PostgreSQL, SQL Server

## Sở đồ hệ thống

(Proxy sinh ra để quản lý connection, làm tăng connection tối đa mà client có thể request, vừa nãy có đề cập vấn đề số lượng connection của db nó phụ thuộc vào cái site của instance và giới hạn về mặt số lượng)
![alt text]({55CCCCA5-C278-4E69-B688-94F3EFC05492}.png)

# Clear resources

Login vào AWS Console và thực hiện những nội dung sau

1. Xoá RDS Instance
2. Xoá RDS Cluster (cỏ thể xóa toàn bộ)
3. Xoá Aurora Cluster (Xóa từ instance xóa lên)
4. Xoá các bản snapshot còn sót lại
5. Terminate EC2 instance nếu có
