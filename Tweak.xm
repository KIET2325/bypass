#import <CoreLocation/CoreLocation.h>
#import <objc/runtime.h>
#import <Foundation/Foundation.h>

%hook CLLocation

// 1. Vượt qua thuộc tính cốt lõi của iOS 15+ (Giữ nguyên - Rất tốt)
- (id)sourceInformation {
    return nil; 
}

// 2. Tối ưu hóa kiểm tra độ chính xác (Ép cứng sai số chuẩn, không kiểm tra điều kiện orig <= 0)
// Ứng dụng Masan quét độ chính xác rất kỹ, ép về 5.0 - 10.0m là khoảng an toàn như GPS thật.
- (CLLocationAccuracy)horizontalAccuracy {
    return 8.5; 
}

- (CLLocationAccuracy)verticalAccuracy {
    return 8.5;
}

// 3. Tạo nhiễu độ cao giả lập
- (CLLocationDistance)altitude {
    CLLocationDistance orig = %orig;
    if (orig == 0.0 || orig == -1.0) {
        return 21.35; 
    }
    return orig;
}

// 4. SỬA LỖI TIMESTAMP: Không tự tạo [NSDate date] bừa bãi
// Chúng ta chỉ đồng bộ lại thời gian nếu sai lệch quá lớn so với thực tế (quá 2 giây)
- (NSDate *)timestamp {
    NSDate *origDate = %orig;
    if (!origDate || fabs([origDate timeIntervalSinceNow]) > 2.0) {
        return [NSDate date]; // Chỉ sửa khi dữ liệu thời gian cũ bị "đóng băng" quá lâu
    }
    return origDate; // Trả về thời gian đồng bộ của hệ thống để tránh lỗi kCLErrorDomain
}

%end

// 5. Chống quét môi trường (Bổ sung thêm một số đường dẫn bảo mật phổ biến)
%hook NSFileManager

- (BOOL)fileExistsAtPath:(NSString *)path {
    if (path) {
        if ([path containsString:@"Library/MobileSubstrate"] || 
            [path containsString:@"Sideloadly"] || 
            [path containsString:@"FakeGPS"] ||
            [path containsString:@"frida"] ||
            [path containsString:@"TrollStore"] || 
            [path containsString:@"Applications/ChOPrA.app"]) { // Thêm app bypass phổ biến nếu có
            return NO;
        }
    }
    return %orig;
}

%end

// 6. Khởi tạo cấu trúc
%ctor {
    %init(_ungrouped);
    NSLog(@"[TimeMarkShield] Hệ thống định vị an toàn đã được vá lỗi kCLErrorDomain!");
}
