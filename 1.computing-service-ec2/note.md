# Một số khái niệm cơ bản

• EC2 là một máy chủ ảo chạy trên Hypervisor (Trình ảo hóa) của AWS, bên dưới là các phần cứng.

• AMI: Amazon Machine Image. Giống như 1 file ISO/Ghost chứa toàn bộ thông tin của hệ điều hành. EC2 được khởi động lên từ 1 AMI tương tự như việc cài Win lần đầu cho PC/Laptop.

• EBS Volume: Ổ cứng ảo được cấp phát bởi Amazon. Chỉ có thể đọc được dữ liệu khi được gắn vào 1 Instance.

• Snapshot: Ảnh chụp của 1 EBS Volume tại 1 thời điểm. Có thể sử dụng để phục hồi dữ liệu khi có sự cố

• Instance: 1 Máy chủ ảo được cấp phát tài nguyên CPU, RAM, GPU,… tuỳ theo dòng instance mà sẽ có một số giới hạn nhất định.

# Giới hạn truy cập tới 1 EC2 instance

Để giới hạn truy cập tới EC2 và từ EC2 ra bên ngoài, AWS cung cấp 1 khái niệm là Secutiry Group.

NOTE
• Rule của security group là stateful, crequest đến sẽ tự nhận được response mà không phải định nghĩa 1 cách tường minh cho phép đi ra.
• Default nếu không có yêu cầu gì đặc biệt thì Outbound (từ trong đi ra) sẽ mở all.
• Rule của Security Group chỉ có Allow không có Deny.
• Một EC2 có thể gắn nhiều hơn 1 Security Groups.

# Tạo snapshot cho volume, trong trường cài nhiều software trên volume í, nếu không muốn shi stop hay tearminate mất dữ liệu, thì tạo snapshot

==> Tạo volume sử dụng snapshot vừa tạo và gắn nó vào ec2

# Lab 1: Tạo EC2, thao tác cơ bản

1. Tạo 1 EC2 instance từ AMI Amazon Linux 2
2. Cấu hình security group (default) mở 2 rule là SSH:22 và HTTP:80 từ địa chỉ IP của nhà bạn.
3. Login vào server
4. Cài httpd, cấu hình website cơ bản.
5. Truy cập website.
6. Tạo snapshot cho volume root.
7. Tạo AMI từ EC2 đang chạy.
8. Tạo 1 con EC2 instance mới từ AMI vừa tạo. (vd ami này được tạo một con ec2 đang chạy httpd), ami cần volume để lưu ami
9. Truy cập vào EC2 vừa tạo xem website có được cài sẵn ko (thì khi sử dụng ami vừa tạo thì đã có sẵn httd)

# User-data, meta-data

EC2 cung cấp một cơ chế cho phép chạy script tại thời điểm launch gọi là user data
Có thể sử dụng user data để thực thi một số hành động
• Install software
• Download source code/artifact
• Customize settings
Lưu ý không nên để các thông tin nhạy cảm như DB username/pw vào trong user data.
Mỗi EC2 có một bộ thông tin được nạp lên sau khi khở động gọi là meta data.
Thông tin bao gồm địa chỉ IP public/private, security group, AMI-ID, Role,... phục vụ truy xuất khi cần thiết.
Meta data được lưu tại địa chỉ: http://169.254.169.254/latest/meta-data (cố định cho cả windows và linux)

# EC2 Pricing

Về cơ bản, EC2 tính tiền instance dựa trên thời gian chạy và kích thước của instance. Mỗi instance sẽ có mức giá khác nhau tùy theo cấu hình (càng bự càng mắc).
Các mô hình tính tiền của EC2 (Pricing Model)
• On-Demand: Xài nhiêu trả nhiêu, không cần trả trước. Phù hợp cho đa số mục đích (học tập, môi trường dev,…)
• Reserve Instance or Saving Plan: Mua trước 1-3 năm hoặc commit số tiền sẽ xài hằng tháng để được discount so với On-Demand (tối đa discount lên tới ~72%). Phù hợp cho môi trường production.
• Spot Instance: Đấu giá để được sd EC2 instance vào các khung giờ thấp điểm. Phù hợp cho các tác vụ xử lý hàng loạt, cần giá rẻ, xử lý có thể resume lại khi bị dừng đột ngột.
• Dedicated Host: Thuê riêng phần cứng nếu có yêu cầu đặc biệt về compliance.

# Elastic Block Storage (EBS)

Đặc trưng
• Là một cơ chế lưu trữ dạng block.
• Đơn vị quản lý là các EBS Volume.
• Chỉ có thể access data khi được gắn vào 1 EC2 instance (dùng làm ổ root, C: hoặc ổ data)
• Một số loại EBS đặc biệt cho phép gắn vào nhiều hơn 1 EC2 instance (multi attach).
• Có thể tăng size một cách dễ dàng ngay cả khi server đang chạy (lưu ý: không thể giảm size).
Tính tiền:
• Dung lượng của volume ($/GB/Month), không xài hết cũng mất tiền 100% trên dung lượng vì đã cấp phát rồi.
• IOPS: Tốc độ đọc ghi càng cao, càng phát sinh phí.
• Dung lượng của các bản snapshot của ổ cứng ($/GB/Month) tuy nhiên giá rẻ hơn lưu trữ.

# Các loại EBS thường dùng

General purpose (default): gp2, gp3: Phù hợp cho hầu hết các mục đích sử dụng.
IOPS Provisioned: io1, io2: Phù hợp cho các ứng dụng đòi hỏi tốc độ đọc ghi cao.
Throughput optimized HDD: Dùng cho các hệ thống về Bigdata, Data warehouse, cần throughput cao.
Cold HDD: Lưu trữ giá rẻ cho các file ít khi được access (VD File server của công ty).
Magnetic: Thế hệ trước của HDD, ít được sd.
