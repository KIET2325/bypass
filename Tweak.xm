#import <CoreLocation/CoreLocation.h>
#import <objc/runtime.h>
#import <Foundation/Foundation.h>

%hook CLLocation

// 1. Vượt qua thuộc tính cốt lõi của iOS 15+
// Sử dụng kiểu trả về 'id' thay vì gọi trực tiếp lớp con để tránh xung đột SDK
- (id)sourceInformation {
    return nil; // Trả về nil để báo hiệu vị trí hoàn toàn từ phần cứng thật
}

// 2. Vượt qua kiểm tra độ chính xác (Bypass Accuracy Check)
- (CLLocationAccuracy)horizontalAccuracy {
    CLLocationAccuracy orig = %orig;
    if (orig <= 0) {
        return 5.0; // Ép về mức sai số cố định 5 mét
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

// 3. Tạo nhiễu độ cao giả lập (Altitude Simulation)
- (CLLocationDistance)altitude {
    CLLocationDistance orig = %orig;
    if (orig == 0.0) {
        return 21.35; // Giá trị độ cao giả lập thực tế
    }
    return orig;
}

// 4. Chuẩn hóa thời gian (Timestamp Validation)
- (NSDate *)timestamp {
    return [NSDate date];
}

%end

// 5. Chống quét môi trường / Ẩn ứng dụng cấu hình lạ
%hook NSFileManager

- (BOOL)fileExistsAtPath:(NSString *)path {
    if (path) {
        if ([path containsString:@"Library/MobileSubstrate"] || 
            [path containsString:@"Sideloadly"] || 
            [path containsString:@"FakeGPS"] ||
            [path containsString:@"frida"]) {
            return NO;
        }
    }
    return %orig;
}

%end

// 6. Sửa cấu trúc Khởi tạo (Constructor) chuẩn của Logos
%ctor {
    %init(_ungrouped);
    NSLog(@"[TimeMarkShield] Đã kích hoạt hệ thống định vị an toàn thành công!");
}
