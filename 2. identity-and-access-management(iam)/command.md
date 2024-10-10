# IAM

- Viêt tắt của Identity and Access Management
- Nhiệm vụ định danh và phân quyền, quản lý việc ai(who) và cái gì (what) có thể access như thế nào tới các resources trên AWS, quản lý một cách tập trung các quyền chi tiết, phân tích truy cập để tinh chỉnh quyền.

# IAM usecase

• Áp dụng quyền chi tiết và mở rộng quy mô với khả năng kiểm soát truy cập dựa trên thuộc tính. Vd: Phòng ban, job role, tên nhóm.
• Quản lý truy cập theo từng tài khoản hoặc mở rộng quy mô truy cập trên các tài khoản và ứng dụng AWS.
• Thiết lập quy tắc bảo vệ & phòng ngừa cho toàn tổ chức
• Thiết lập, xác minh và điều chỉnh quy mô quyền đối với đặc quyền tối thiểu thông qua việc thiết lập, xác minh, tuỳ chỉnh

# IAM Concept

Để có thể thiết kế & xây dựng hệ thống trên AWS đảm bảo tiêu chí về Security cũng như không gặp trouble, chúng ta cần nắm vững các concept cơ bản của
IAM bao gồm:
• User
• Group
• Role
• Permission (Policy)

# IAM – Policy

Quy định việc ai/cái gì có thể hoặc không thể làm gì.
Một policy thường bao gồm nhiều Statement quy định Allow/Deny hành động trên resource dựa trên condition.
Mỗi statement cần định nghĩa các thông tin:
• Effect: có 2 loại là Allow & Deny. \*Deny được ưu tiên hơn.
• Action: tập hợp các action cho phép thực thi.
• Resource: tập hợp các resource cho phép tương tác.
• [Condition]: Điều kiện kèm theo để apply statement này.
Policy có thể gắn vào `Role/Group/User`

- Policy có 2 loại là: Inline Policy và Managed Policy
  • Inline policy: được đính trực tiếp lên Role/User/Group và không thể tái sử dụng ở Role/User/Group khác.
  • Managed Policy: Được tạo riêng và có thể gắn vào nhiều User/Group/Role.
- Managed Policy lại được chia thành 2 loại là AWS
- Managed và User Managed.
- Việc lựa chọn giữa Inline vs Managed phải được tính toán dựa trên các yếu tố như: tính tái sử dụng, quản lý thay đổi tập trung, versioning & rollback.

## Sample of an IAM Policy

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["ec2:StartInstance", "ec2:StopInstance"],
      "Resource": "arn:aws:ec2:*:*:instance/*",
      "Condition": {
        "StringEquals": {
          "aws:ResourceTag/Environment": "Dev"
        }
      }
    }
  ]
}
```

==> \*Policy này quy định đối tượng được gán policy này được phép thực hiện 2 hành động là StartInstance và StopInstance trên toàn bộ các EC2 instance với điều kiện instance đó có 1 thẻ tag tên Environment và giá trị = Dev.

# IAM – User

- Đại diện cho 1 profile của 1 người dùng trên AWS account.
  = User có thể login vào AWS Console sử dụng username/password.
- User mặc định khi tạo ra sẽ không có quyền gì. Cần cấp quyền cho user thông qua Policy hoặc Group (slide sau).
- User có thể phát hành access-key/secret-key để sử dụng cho CLI hoặc test SDK trong quá trình test code. Cặp access/secret key này cũng sẽ đại diện cho user (thay vì dùng username/password).

# IAM – Role

- Đại diện cho 1 quyền trên AWS. Không giống như khái niệm Role của 1 user như trong phân quyền hệ thống, cần lưu ý để tránh nhầm lẫn.
- Sử dụng khi muốn cấp quyền cho 1 thực thể có thể tương tác với các resources khác trên AWS. Thường dùng để gắn vào EC2, Lambda, Container,...
- Có thể sử dụng để cấp quyền cho 1 user nằm ở AWS account khác mà không muốn tạo ra user profile cho họ trên account AWS của mình. Bằng cách cho phép 1 user assume-role tới 1 role trên account, user có thể có các quyền tạm thời để thực hiện thao tác.

===> \*Lưu ý: `một resource trên AWS không thể tương tác` với resource khác nếu không được gán Role với các quyền thích hợp. Đây cũng chính là lý do khiến cho việc Role & Permission khiến cho mọi người tốn thời gian trouble shooting nếu không nắm rõ dịch vụ mà mình đang sử dụng.

# IAM – Group

- Đại diện cho 1 nhóm user trên hệ thống.
- Sử dụng khi muốn phân chia quyền dựa theo vai trò trong dự án, phòng ban,...
- Nên thiết kế các nhóm user và phân quyền hợp lý, sau đó khi có người mới chúng ta chỉ cần add user đó vào các nhóm cần thiết giúp tiết kiệm thời gian và tránh sai sót (cấp dư hoặc thiếu quyền).
- Lưu ý tránh bị chồng chéo quyền (vd 1 group allow action A nhưng group khác lại deny action A).
- Một group không thể chứa group khác (lồng nhau).
- Một user có thể không thuộc group nào hoặc thuộc nhiều groups.
- Một group có thể không có user nào hoặc có nhiều users.

==> gán cho user `chú ý ROLE và GROUP không liên quan gì đến nhau`

# Lab 1: IAM User, Group, Policy

Login to AWS console, thực hiện nội dung sau:

1. Tạo 1 Group “developer-group” có quyền AdministratorAccess (managed policy)
   (=> chọn Provide user access to the AWS Management Console - optional, => I want to create an IAM user, bỏ tích Users must create a new password at next sign-in - Recommended)
2. Create 1 user “developer-01” Add 1 user vào “developer-group”
3. Login vào console, thử thực hiện 1 vài thao tác vd Launch Instance, create S3 bucket, upload, download.
4. Tạo thêm group “tester-group” có quyền “Readonly Access” (managed policy)
5. Thêm custom policy “deny-delete-object-s3” vào group “tester-group” (`Tạo Inline policy`)
6. Add user “developer-01” vào “tester-group”
7. Thử dùng “developer-01” xóa 1 object trên s3 => expect deny.

# IAM Policy vs Resource Policy

- Một số resouce như S3, SQS, KMS hỗ trợ định nghĩa policy ở cấp độ resource.
- Về cơ bản cấu trúc resource policy tương tự IAM policy nhưng được gán cho một resource cụ thể.
- `Quyền của một user (group/role) đối với resource sẽ là kết hợp của IAM Policy & Resource Policy sau khi đã loại trừ Deny.`
- Một số resource cần security cao sẽ thường được ưu tiên setting resource policy.
- **Lưu ý**: IAM Policy nói chung không có tác dụng đối với account root.
- =>Nếu lỡ tay setting deny all không thao tác được trên một resource, có thể login = account root để chỉnh
  lại.

# Lab2: Resource policy for S3

Login to AWS console, thực hiện nội dung sau:
\*Sử dụng lại user đã tạo ở lab1

1. Gỡ user developer-01 ra khỏi group tester (mục đích nhằm gỡ rule deny).
2. Thử thao tác lại trên s3.
3. Tạo S3 bucket policy Deny toàn bộ thao tác đối với bucket S3.
   (chọn bucket, chọn permision, kéo xuống chọn bucket plicy)

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "deny developer-01",
      "Effect": "Deny",
      "Principal": {
        "AWS": ["arn:aws:iam::430950558682:user/developer-01"]
      },
      "Action": ["s3:*"],
      "Resource": [
        "arn:aws:s3:::DOC-EXAMPLE-BUCKET",
        "arn:aws:s3:::DOC-EXAMPLE-BUCKET/*"
      ]
    }
  ]
}
```

`4. Thử upload, download file lên bucket -> Deny`
===> Mặc dù user developer-01 có quyên admin, nhưng s3 resource poilicy có deny tới user đó, kết qua allow + deny ==> deny

# Lab3: AWS CLI, MFA with CLI

**file iam-cli.sh**
gg: aws cli latest
Login to AWS console, thực hiện nội dung sau:
\*Yêu cầu máy cài sẵn AWS CLI latest.

1. Phát hành access key/secret key cho user đã tạo ở Lab1
2. Thiết lập access key/ secret key cho AWS CLI.
3. Tương tác với 1 vài service bằng CLI.
4. Tạo policy enforce-mfa-policy và gắn vào “developer-group”
   (vào group "developer-group" chọn permison, thêm một policy yêu cầu tài khoản đó phải bật "mfa" thì mới được truy cập các resource) ==> gg `aws enforce mfa policy`, tìm copy json và tạo một policy paste json đó vào và tạo

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowViewAccountInfo",
      "Effect": "Allow",
      "Action": "iam:ListVirtualMFADevices",
      "Resource": "*"
    },
    {
      "Sid": "AllowManageOwnVirtualMFADevice",
      "Effect": "Allow",
      "Action": ["iam:CreateVirtualMFADevice"],
      "Resource": "arn:aws:iam::*:mfa/*"
    },
    {
      "Sid": "AllowManageOwnUserMFA",
      "Effect": "Allow",
      "Action": [
        "iam:DeactivateMFADevice",
        "iam:EnableMFADevice",
        "iam:GetUser",
        "iam:GetMFADevice",
        "iam:ListMFADevices",
        "iam:ResyncMFADevice"
      ],
      "Resource": "arn:aws:iam::*:user/${aws:username}"
    },
    {
      "Sid": "DenyAllExceptListedIfNoMFA",
      "Effect": "Deny",
      "NotAction": [
        "iam:CreateVirtualMFADevice",
        "iam:EnableMFADevice",
        "iam:GetUser",
        "iam:ListMFADevices",
        "iam:ListVirtualMFADevices",
        "iam:ResyncMFADevice",
        "sts:GetSessionToken"
      ],
      "Resource": "*",
      "Condition": {
        "BoolIfExists": { "aws:MultiFactorAuthPresent": "false" }
      }
    }
  ]
}
```

5. Thử gõ lại CLI xem còn xài dc ko?
6. Cài MFA cho user “developer-01”
7. Thiết lập sesssion_token sử dụng MFA code.

```bash
# chú ý arn của mfa
aws sts get-session-token --serial-number 	arn:aws:iam::287925497349:mfa/developer-01-oppo --token-code 123456

#Step 2: config credential file.
"C:\Users\<your user name>\.aws\credentials" (Copy đoạn anyf vào file này)
#--------------------
[udemy-mfa]
aws_access_key_id = ASIAWIVVHVPNI6WO5AOW
aws_secret_access_key = KKqlnJn6XT2RQWeNwuxQvhOWAjVbvSCbkRMEny9f
aws_session_token = IQoJb3JpZ2luX2VjEK///////////wEaDmFwLXNvdXRoZWFzdC0xIkgwRgIhAO1Z8dMTyKyyDIcJBSSPBtnAUHpMUpQ3+mCeTyDpiK5PAiEAujswq262YxMSuHSmzU+1ZzoUqQfuZ19/Ut4NXqHgPfQq+AEIqP//////////ARAAGgw0MzA5NTA1NTg2ODIiDMkOIirsIpfYG0BbTirMAWDz7GCM632sxd6mGDY4ZfBmfBZuaVSm55P0ECkKt2qijTx8HsnijcOlwcnrXBjCdKwp126YaU6INtpecdCAYJGL4GH9enkwn+zQdT7eYN+io0Y8ciHMnA9MPPRAE8rJCAjA+FHVBZEY0zDqjGQQTr/BgWNiCR/e43orrikVXX+w3SfVRriTVsyma05A6o7bz1J0uz5mqG+AIHazGmr8Mek8fybV1t9YQDGmPxeYGfyausSOquitvJhJCocASWYUkSPCu12PMd9j4MdWYDCg0IqiBjqXAVLYQ7FVcMujq99V4azMjIDpIzLyasX9W/0J/VUIrxekFzdQE1SEfBNxInYgV8ER1TJ2WltKPmVH4rRb8n6Abtc4C40f1WDjDCcAqYdsrLQtk9hdKgSFD2pvnKK+vxvm8Wpexw6oVX4t77tncXAhqPAnQ8RnNcFSwtynszgIRZUqhGcapaEHQlrQ/4JKB0kXaxv8DlsiSF0=
#-------------

```

**Chi tiết ở file iam-cli.sh**

- 8. Gõ lệnh CLI sử dụng profile đã có MFA.

```bash
#Step 3: specify --profile when run command.
aws s3 ls --profile udemy-mfa
aws s3 ls s3://<your-bucket-name>/ --profile udemy-mfa

```

# Lab4: IAM Role for EC2

Login to AWS console, thực hiện nội dung sau:

1. Tạo 1 Role cho phép access full tới một S3 bucket chỉ định.
2. Tạo 1 ec2, gán role vừa tạo. (chọn ec2 => action => security => modify iam role)
3. Login vào EC2.
4. Thực hiện các action uload, download, delete file dùng CLI (AMZ Linux 2 có cài sẵn AWS CLI)

# Best practices for IAM

• Sử dụng group để gán quyền cho các user.
• Cấp quyền vừa đủ cho user, không cấp quá dư thừa.
• Chú ý các deny rule khi thiết kế policy để tránh bị conflict permission giữa các group (group này allow nhưng group kia deny).
• Luôn force MFA cho các IAM user (không bật MFA sẽ không xài dc console).
\*Sẽ hơi phiền nếu dùng CLI kết hợp MFA nhưng nếu làm quen sẽ không mất nhiều thời gian.
• Sử dụng Role khi muốn cấp quyền cho server/ứng dụng. Access/Secret key chỉ dùng để sử dụng khi gõ CLI trên local hoặc test các app đang trong quá trình phát triển.
• Tuyệt đối KHÔNG share User hoặc Access/Secret key giữa các member trong dự án.
