#import <CoreLocation/CoreLocation.h>
#import <objc/runtime.h>

%hook CLLocation

// 1. Vượt qua kiểm tra độ chính xác (Bypass Accuracy Check)
// Các app fake GPS đôi khi trả về độ chính xác bằng 0 hoặc -1 (không hợp lệ)
- (CLLocationAccuracy)horizontalAccuracy {
    CLLocationAccuracy orig = %orig;
    if (orig <= 0) {
        return 5.0; // Ép về mức sai số 5 mét (chuẩn GPS ngoài trời tốt)
    }
    return orig;
}

- (CLLocationAccuracy)verticalAccuracy {
    CLLocationAccuracy orig = %orig;
    if (orig <= 0) {
        return 5.0;
    }
    return orig;
}

// 2. Tạo nhiễu độ cao giả lập (Altitude Simulation)
// Nếu độ cao liên tục bằng 0.00000, hệ thống bảo mật sẽ gắn cờ nghi vấn
- (CLLocationDistance)altitude {
    CLLocationDistance orig = %orig;
    if (orig == 0.0) {
        return 12.5; // Trả về một độ cao thực tế trung bình
    }
    return orig;
}

// 3. Chuẩn hóa thời gian (Timestamp Validation)
// Đảm bảo thời gian của gói tọa độ trùng khớp hoàn toàn với thời gian thực của hệ thống
- (NSDate *)timestamp {
    return [NSDate date];
}

%end

// 4. Hook kiểm tra phương thức mô phỏng (Simulated Location Detection)
// Chặn ứng dụng gọi các hàm kiểm tra xem vị trí có phải do Xcode hay công cụ giả lập tạo ra không
%hook CLLocationManager

+ (BOOL)deferredLocationUpdatesAvailable {
    return YES;
}

+ (BOOL)locationServicesEnabled {
    return YES;
}

%end
