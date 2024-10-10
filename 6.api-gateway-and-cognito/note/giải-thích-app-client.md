# App Client trong AWS Cognito là gì?

- App Client giống như một "chìa khóa" để ứng dụng của bạn (ví dụ như một ứng dụng web hay di động) có thể nói chuyện với hệ thống quản lý người dùng (Cognito).
- Nó giúp ứng dụng của bạn đăng nhập người dùng, đăng ký người dùng mới, và xác thực (kiểm tra danh tính) của người dùng.

# Ví dụ App Client dùng làm gì?

- Ứng dụng di động: Khi bạn mở một ứng dụng trên điện thoại, bạn cần đăng nhập. App Client giúp ứng dụng của bạn gửi thông tin đăng nhập (như email và mật khẩu) tới Cognito, và Cognito sẽ trả lại cho bạn thông tin xác thực nếu đăng nhập thành công.

- Ứng dụng web: Khi bạn vào một trang web yêu cầu đăng nhập (như Facebook hoặc Gmail), App Client giúp trang web này xác thực người dùng.

- Đăng nhập bằng Google/Facebook: Nếu bạn muốn cho phép người dùng đăng nhập vào ứng dụng của mình bằng tài khoản Google hay Facebook, App Client sẽ giúp ứng dụng của bạn kết nối với Google/Facebook để lấy thông tin đăng nhập.

==> Tóm lại: App Client là công cụ để ứng dụng của bạn có thể xác thực người dùng, giúp họ đăng nhập, đăng ký, và truy cập các tính năng yêu cầu đăng nhập.
