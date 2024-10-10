## What is S3

- Viêt tắt của Simple Storage Service
- Là một dịch vụ lưu trữ dạng Object cung cấp khả năng mở rộng availability, performance.
- Có thể sử dụng S3 để lưu trữ và bảo vệ nhiều loại data cho các usecase như: data lake, website, mobile, backup & restore, archive, enterprise application, IoT device, Big Data & Analytic.
- S3 cung cấp nhiều managed feature giúp tối ưu, tổ chức và cấu hình access tới data đáp ứng nhu cầu về business, organization & complicance.

# Đặc trưng cơ bản của S3

• Là một Managed Service. User không cần quan tâm tới hạ tầng ở bên dưới.
• Cho phép lưu file dưới dạng object với size từ 0 - 5TB (object khác với blog là không chỉnh sủa được, muốn sửa ta phải download về máy mới sửa được, xog up ngược lại)
• High Durability (11 9s), Scalability, High Availability (99.99%), High performance.
• Usecase đa dạng (mọi bài toán về lưu trữ từ lớn tới nhỏ đều có thể sd S3).
• Cung cấp nhiều class lưu trữ để tiết kiệm chi phí cho từng loại data.
• Cung cấp khả năng phân quyền và giới hạn truy cập một cách chi tiết.
• Dễ sử dụng, có thể kết hợp với nhiều service khác cho bài toán automation và data processing.

## Features of S3

- S3 cung cấp các tính năng cơ bản sau:
  • Storage classes: cung cấp nhiều hình thức lưu trữ phù hợp cho nhiều loại data khác nhau về nhu cầu access, yêu cầu về durability, thời gian lưu trữ khác nhau giúp KH tuỳ chọn được class lưu trữ phù hợp từ đó tối ưu chi phí.
  • Storage management: Cung cấp nhiều tính năng liên quan quản lý như: Life Cycle, Object Lock, Replication, Batch Operation
  • Access Management: quản lý truy cập đến bucket và các thư mục thông qua cơ chế resource permission & access list. Block public access, control access via IAM, bucket policy, S3 access point, Access Control List, Ownership, Access Analyzer.
  • Data processing: : kết hợp với lambda, SNS, SQS để hỗ trợ xử lý data 1 cách nhanh chóng (bất kì khi nào có data up lên s3 ta có thể tạo một luồng tự dộng sử lý, dùng cho bài toán cleaning data để bóc tách những thông tin cần thiết đưa vào database)
  • Auto Logging and Monitoring: cung cấp công cụ monitor S3 bucket và truy vết sử dụng CloudTrail.
  • Manual Monitoring Tool: Log lại từng record thực hiện trên bucket.
  • Analytic and insight: phân tích storage để optimize.
  • Strong consistency: Provice strong read-after-write consistency for PUT and DELETE object.

# S3 có thể kết hợp với các dịch vụ nào?

![alt text](image.png)

• Dùng làm nơi lưu trữ file cho các ứng dụng chạy trên EC2, Container, Lambda. Các file có thể đa dạng về loại & kích thước (Image, Video, Document,...)
• Dùng làm nơi chứa/archive log cho hầu hết các dịch vụ khác của AWS (VPC, ALB, APIGateway,...) (ghi log ra s3 khi ta cần truy suất ta có thể xem log của các dịch vụ này)
• Dùng làm data source cho các bài toán big data & data warehouse
• Nơi lưu dữ liệu gửi lên từ các thiết bị IoT
• Vùng lưu trữ tạm thời cho bài toán ETL (Extract – Transform - Load) khi kết hợp với lambda
• Host 1 website tĩnh (html,css,js) khi kết hợp với CloudFront

# Lab 1 – S3 Basic Operation

1. Login to AWS console, navigate to S3
2. Tạo 1 bucket \*Lưu ý tên s3 bucket là global unique.
3. Thực hiện tạo folder
4. Thực hiện upload file/folder
5. Thực hiện move file
   (bấm vào file đó => Action => Move => Browse S3 => chọn thư mục muốn move => Chose destination => Move)
6. Download file
7. Chỉnh sửa object metadata để trình duyệt quyết định hành động default với file khi open (view trực tiếp hoặc popup download) (tức là khi open thay vì mở ảnh thì download về)
   (chọn ảnh đó => Object actions => edit metadata => metadata -> binary/octet-stream => save change) => Bấm open (xem có download không)
8. Thực hiện xoá file

# S3 Bucket Policy and Acess Control List

• S3 là một trong số các resource hỗ trợ Resource Level Policy để giới hạn quyền truy cập bên cạnh IAM Policy (đã học ở bài IAM).
• Bản chất S3 bucket policy hoạt động như 1 IAM Policy nhưng chỉ trong phạm vi bucket và những resource bên trong nó (folder/file).
• S3 bucket policy sẽ cho phép (allow) hoặc chặn (deny) truy cập tới bucket hoặc các resource bên trong.
• Áp dụng cho những bucket yêu cầu security cao, cần được setting giới hạn truy cập một cách chặt chẽ.

# S3 Bucket Policy and Acess Control List

S3 bucket policy example: Ví dụ về 1 bucket policy cho phép user “riccardo” có quyền GetObject trên tất cả resource của bucket
"abc-bucket-sample-001"

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Allow_riccardo_read",
      "Effect": "Allow",
      "Principal": {
        "AWS": ["arn:aws:iam::614073292094:user/riccardo"]
      },
      "Action": ["s3:GetObject"],
      "Resource": "arn:aws:s3:::abc-bucket-sample-001/*"
    }
  ]
}
```

Ví dụ về 1 bucket policy deny user “ronaldo” không được phép làm bất kì action nào trên tất cả resource của bucket “abc-bucket-sample-001”

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Deny_ronaldo_all",
      "Effect": "Deny",
      "Principal": {
        "AWS": ["arn:aws:iam::614073292094:user/ronaldo"]
      },
      "Action": ["s3:*"],
      "Resource": "arn:aws:s3:::abc-bucket-sample-001/*"
    }
  ]
}
```

**Lưu ý:** Khi ta có một policy gán cho User cho phép user đó có quyền trên bucket đó, tuy nhiên buckent lại có 1 statement quy định user đó không được access, thì kết quả cuối cùng là user đó không được access => deny ưu tiên cao hơn

# S3 Bucket Policy and Acess Control List

• Access Control List: quy định quyền access của một AWS Account hoặc nhóm user (Group) đến bucket hoặc resource bên trong.
• Thường dùng trong trường hợp muốn cấp access cho một resource cụ thể bên trong bucket mà không muốn thay đổi bucket policy.
(cụ thể là muốn cấp quyền truy cập cho một cái user nào đó vô một file cụ thể trong bucket, tuy nhiên ta lại không muốn sửa buckent policy, vì sửa bucket policy sẽ ảnh hưởng tới toàn bucket)
• \*Gần đây AWS khuyến nghị người dùng KHÔNG nên xài ACL trừ khi có yêu cầu đặc biệt, thay vào đó hay sử dụng bucket policy, iam policy & pre-sign URL (cơ chế phát hành access tạm thời) là đủ để cover hầu hết các usecase.

![alt text](image-1.png)

# S3 Versioning

(đơn giản là quản lý nhiều version cùng tên (hay object))
• Sử dụng khi có nhu cầu lưu trữ nhiều version của cùng 1 object.
• Tránh được việc mất mát khi thao tác xoá nhầm hoặc ghi đè (có thể lấy lại version trước đó). (ghi đè tức là upload 1 file cùng tên với 1 file trước đó đã upload thì sẽ ghi đè mất và ta không thể lấy lại được file trước đó, nếu có versioning ta sẽ lấy lại được file trước đó)
• Chi phí theo đó sẽ tăng lên so với khi không bật versioning.
• Sau khi bật versioning, nếu tắt versioning thì những object trước khi tắt vẫn sẽ có nhiều version, những object sinh ra sau khi tắt sẽ không có version.

Lab 3 – Versioning

1. Yêu cầu chuẩn bị một file text có nội dung bất kỳ
2. Bật tính năng versioning của Bucket lên. (ở phần property => bucket versioning: edit => enable => save change)
3. Upload file lên S3.
4. Chỉnh sửa nội dung, upload file với cùng tên. Confirm xem có một version mới được tạo ra?
   (chọn file đó => qua tap version kiểm tra => sẽ thấy 2 version)
5. Tiến hành xoá file. Kiểm tra versioning với Delete flag.
   ( chọn file đó => Delete => lúc này sẽ không thấy file xóa nữa => bấm show version => sẽ thấy file ta vừa xóa mặc dù đã xóa vì trong trại versioning được bật thì xóa thì xóa ở mặt logical tức thêm cờ delete thôi, bản chất nó vẫn còn)
6. Phục hồi file đã bị xoá bằng cách xoá Delete marker.
   (khôi phục => chọn file đó => qua tab versioning => chọn type Delete marker => Delete (xóa marker) => file được khôi phục )
7. Tắt versioning.
8. Chỉnh sửa nội dung, upload file với cùng tên. Confirm xem file có bị ghi đè? Các version trước khi tắt versioning có còn không?

==> tính năng version được tạo ra để bảo vệ những file quan trọng, tránh tình trạng xóa nhầm, ghi đè nội dung cùng tên, khôi phục lại khi cần thiết, tăng chi phí 2 version (1GB => 2GB)

# S3 Presign URL

- Khi muốn cấp access tạm thời cho người dùng public tới một object trên S3, AWS cung cấp cơ chế Presign URL. (không muốn thay đổi bucket policy or access list)
- User có thể dùng Presign URL để download/upload object trên s3 trong thời gian quy định (setting lúc phát hành URL).
- Usecase
  • Muốn cấp access public cho 1 object nhưng không muốn thay đổi ACL hoặc tạo thêm bucket policy.
  • `Cần authen người dùng hoặc yêu cầu họ làm gì đó trước khi được download file (vd xem quảng cáo).`
  • Ngăn chặn resource để public vô thời hạn khiến cho tài nguyên bị khai thác bởi bên khác.

## Flow for Presign URL (download/upload)

![alt text](image-2.png)

req client muốn download file tài liệu => backend server (phải có quyền tương tác s3 bucket với tài liệu đó, phải gán role vô ec2) => nó sẽ yêu cầu s3 trả về Presign URL => s3 phát hành Presign URL => nó trả vể url cho server và server trả về cho client => từ URL đó ta sẽ redirect client sang URL đó (cho coi 5s quảng cáo rồi cho Click here dowload chẳng hạn ) bước này download trực tiếp từ S3 mà không thông qua backend server, backend server chỉ có nhiệm vụ phát hành URL
==> Mô hình này có ưu điểm perfomance user client sẽ không download thông qua backend server không tiêu tốn cpu với mememory
==> Use case upload cũng tương tự

# Lab 4 – Pre-sign URL (sử dụng CLI)

1. Yêu cầu đã cài sẵn AWS CLI và thiết lâp profile tại máy local
2. Upload 1 file bất kì lên S3 (để permison là block public)
3. Tham khảo câu lệnh sau để phát hành 1 presign url cho object trên s3 https://docs.aws.amazon.com/cli/latest/reference/s3/presign.html

```bash
aws s3 presign s3://udemy-bucket-02/image/20944201.jpg --expires-in 60

# https://udemy-bucket-02.s3.ap-southeast-1.amazonaws.com/image/20944201.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAUGCNSNYC2AKO56VA%2F20240822%2Fap-southeast-1%2Fs3%2Faws4_request&X-Amz-Date=20240822T082719Z&X-Amz-Expires=60&X-Amz-SignedHeaders=host&X-Amz-Signature=399a39a9c53c84e5396befd7e951319b43c092df7cfa85041c81cb59532a572e

```

4. Sử dụng URL để download file trên trình duyệt.
5. Đợi hết thời gian hiệu lực của url, thử lại => expired.

==> trong use case thực tế không dùng cli, ta có một server có role s3 và nó sẽ phát hành url liên quan đế resouce, và họ chỉ download trong thời gian nhất định thôi tránh việc bên thứ 3 khai thác, và tăng hiệu suất không phải download trên server

# S3 Storage Classes

- S3 cung cấp nhiều storage class khác nhau nhằm giúp người dùng linh động trong việc lựa chọn class phù hợp với nhu cầu, tiết kiệm chi phí.
- Việc lựa chọn class phụ thuộc vào các yếu tố như:
  • Durability, High Availability
  • Thời gian lưu trữ (1 tháng, 1 năm, 5 năm...)
  • Tần suất truy cập, thời gian cần có file khi có yêu cầu
  • Mục đích sử dụng: document, image, log file, backup file, archive

- S3 Standard: loại mặc định khi tạo object mà không chỉ định classes. Phù hợp cho hầu hết các usecase.
- S3 Intelligent Tiering: Monitor tần suất access của các object một cách tự động để move xuống các class rẻ tiền hơn giúp tiết kiệm chi phí. Chỉ apply cho object >=128KB. KH phải chịu thêm chi phí monitor.
- S3 standard infrequently access (Standard IA): phù hợp cho các data ít khi được access nhưng khi request cần có ngay. Availability 99.9 (nhỏ hơn standard 99.99%).
- S3 One-zone infrequently access (One zone IA): rẻ hơn standard IA 20% do chỉ lưu trữ trên 1 AZ. Phù hợp cho các data có thể dễ dàng tạo ra nếu không may bị mất (report, file image resized). Availability 99.5%

- S3 Glacier: phù hợp cho việc lưu trữ những data có yêu cầu thời gian lưu trữ lên tới vài năm nhưng ít khi được sử dụng. Tuỳ theo nhu cầu khi access mà Glacier lại chia ra 1 số sub class:
  • Glacier Instant Retrieval: rẻ hơn tới 68% so với S3 Standard IA. Cho phép access 1 file với thời gian ngắn khi có nhu cầu. VD hồ sơ phim chụp của bệnh nhân ở bệnh viện rất ít khi cần lục lại nhưng muốn xem phải có ngay.
  • Glacier Flexible Retrieval (Normal Glacier): phù hợp cho data không yêu cầu access ngay hoặc chưa rõ, thời gian cần để access file có thể từ vài phút tới vài giờ. Phù hợp cho việc lưu data backup hoặc archive.
  • S3 Glacier Deep Archive: phù hợp cho việc lưu trữ lâu dài lên tới 7-10 năm tuỳ theo tiêu chuẩn ngành như tài chính, y tế,... Data dược lưu trên các băng đĩa từ (magnetic tap). AWS cam kết có thể access data trong vòng 12h khi cần.
- S3 on Outposts: Cho phép sử dụng S3 ở on-premise.

## So sánh các Storage Classes

![alt text](image-3.png)

# Lab 5 – Practice Storage Class

\*Lưu ý không upload file quá lớn.

(chọn bucket bất kì => tạo folder => upload file -> property -> chọn class cho nó -> upload)

1. Upload 1 file và chọn storage class là Standard IA
2. Upload 1 file và chọn storage class là OneZone IA
3. Upload 1 file và chọn storage class là Glacier Instant Retrieval
4. Upload 1 file và chọn storage class là Glacier Flexible Retrival
   (đối với loại này thì không thể download được ngay, muốn dowload phải chọn action => chọn Initiate restore => số ngày tồn tại (hết số ngày tồn tạo nó lại remove xuống class Glacier Flexible Retrival) => chọn các option Retrivel tier)
5. Access 1 file được lưu trữ dưới class Glacier Deep Archive
6. Xoá các file đã upload

# S3 Lyfe Cycle

• Tính năng cho phép tự động move object xuống các class lưu trữ thấp hơn hoặc xoá luôn sau một khoảng thời gian nhằm tiết kiệm chi phí.
• Khác với Intelligent Tiering, người dùng sẽ tự quyết định life cycle cho objects (hoặc 1 thư mục), vd sau 90 ngày thì cho xuống Glacier, sau 270 ngày thì xoá hoàn toàn.
( ta có đặt 3 rule => move xuống layer rẻ tiền hơn sau 90 ngày => rồi sau 3 năm thì xóa luôn)
• Phù hợp cho các bài toán lưu trữ Log đã biết trước thời gian thường xuyên access và thời gian có thể xoá.

# Lab 4 - S3 Lyfe Cycle

1. Tạo 1 life cycle rule move object trong 1 folder vd /log xuống Glacier sau 90 ngày.
   (s3 => chọn bucket => tab management => lifecycle rule => create => name: move-log-to-glacier-after-90-day => prefix: /log (tức tất cả file nằm trong thư mục /log) => lifecycle rule actions: Move current versions và Move noncurrent vsersion (version cũ trong trường hợp bật versioning và ta upload version mới, thì cái cũ sẽ thành noncurrent vsersion) => Transition current -> chose strorage class transtions:Glacier Flexible -> day after object creation: 90 (chưa biết lấy khi nào -> cho rẻ) => Transition noncurrent -> chose strorage class transtions:Glacier Flexible -> day after object become noncurrent: 90 -> number of never versions to retain: 1 => create rule )
2. Tạo 1 life cycle rule xoá hoàn toàn object trong /log sau 270 ngày.
   (s3 => chọn bucket => tab management => lifecycle rule => create => name: delete-log-after-90-day => prefix: /log => lifecycle rule action: Expire current version object & Permanently delete noncurent version & Delete expired object delete marker (tức delete hẳn, xóa marker) => Expire current -> day after object creation: 270 -> day after object become noncurrent: 270 => Incomeplete multipath upload: tích delete incomplete -> number ò dáy: 270 => create )

==> Mục đính lyfe Cycle dùng để di chuyển cái file (hay object) giữa các class để ta đỡ tốn tiền thường là di chuyển xuống tiết kiệm chi phí, 2 là xóa luôn sau khoảng một thời gian

# S3 Static Website Hosting

• S3 có hỗ trợ người dùng host 1 website tĩnh (chỉ bao gồm html, css, js, image...)
• Được thừa hưởng toàn bộ đặc tính của S3 (Durability, HA)
• Không cần duy trì server, giảm effort Administration.
• Hỗ trợ setting CORS nhằm tránh tài nguyên bị khai thác bởi website khác.
• Kết hợp với dịch vụ CDN (CloudFront) có thể giúp tăng tốc độ truy cập khi user nằm ở các region khác nhau.
\*Hầu hết các framework frontend hiện nay như Angular, Vue, NodeJS đều hỗ trợ build ra 1 website tĩnh để có thể deploy lên S3 sau khi code xong.

# Lab 6 – S3 Static Website Hosting

1. Chuẩn bị 1 bộ source HTML tĩnh (có thể là static files build ra từ Angular/NodeJS...).
2. Upload source lên s3 (lưu ý file index.html phải ở level gốc)
3. Bật s3 static web hosting
4. Cấu hình open public access cho bucket
5. Cấu hình bucket policy cho phép mọi người access.
6. Test truy cập từ trình duyệt.

# S3 event trigger

- S3 cung cấp cơ chế trigger 1 event sang dịch vụ khác khi có thay đổi đối với object (upload, delete)
- Target của trigger có thể là Lambda Function, SNS, SQS.
- Sample usecase:
  o `Resize image khi có người upload image lên s3 bucket, lưu vào các thư mục size khác nhau`
  o `Giải nén 1 file zip khi có người upload.`
  o Extract csv file, xử lý data rồi lưu vào database
  o Notification tới Operator khi có ai xoá 1 file

# Lab 7 – Combine S3 event with Lambda

1. Tạo 1 lambda function đơn giản với chức năng in ra event nhận được từ S3 bao gồm tên bucket, object key (code python)
   \*Lưu ý vì chưa học tới bài lambda nên code simple nhất có thể, chủ yếu để các bạn nắm concept.
   (lamda => create funtion => athor from scratch => Basic info -> name: test-s3-trigger-fution -> Runtime: python 3.10 -> Architecture: x86 => create)

```python
import json
def lambda_handler(event, context):
    ## TODO implement
    print(event)
    return {
    'statusCode: 200,
    'body': json.dumps('Hello from Lambda!')
    }
```

==> Deploy

==> Test => event name: s3-test => template: S3-put (tương ứng event đẩy file lên s3)

2. Thiết lập s3 trigger sang lambda khi có ai đó upload file.
   (s3 => bucket => create folder: test-trigger => create)
   (bucket => properties => Event notification => create => event name: trigger-lambda-test -> prefix: test-trigger/ -> (suffix: .zip (xử lý file .zip thôi)) => Event type -> Object creation: All object create events(PUT, POST, COPY,...) => Specify Lamdafuntion: Choose from you lamda -> test-s3-trigger-fution => save change)
   ![alt text](image-4.png)
3. Test upload 1 file bất kì.
4. Check xem lambda có được kích hoạt và chạy thành công không.
   (lamda => monitor => tab Log => View Cloudwatch Logs )
