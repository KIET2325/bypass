#import <CoreLocation/CoreLocation.h>
#import <objc/runtime.h>
#import <Foundation/Foundation.h>

// Định nghĩa giao diện lớp con của iOS để tránh lỗi biên dịch
@interface CLLocationSourceInformation : NSObject
@property (readonly, isSimulatedBySoftware: BOOL) BOOL isSimulatedBySoftware;
@end

%hook CLLocation

// 1. Vượt qua thuộc tính cốt lõi của iOS 15+ (Quan trọng nhất)
// iOS 15 bổ sung sourceInformation để chỉ đích danh vị trí có bị phần mềm giả lập hay không.
- (id)sourceInformation {
    return nil; // Trả về nil để báo hiệu vị trí hoàn toàn từ phần cứng thật
}

// 2. Vượt qua kiểm tra độ chính xác (Bypass Accuracy Check)
- (CLLocationAccuracy)horizontalAccuracy {
    CLLocationAccuracy orig = %orig;
    if (orig <= 0) {
        return 5.0; // Ép về mức sai số 5 mét
    }
    return orig;
}

- (CLLocationAccuracy)verticalAccuracy {
    CLLocationAccuracy orig = %orig;
    if (orig <= 0) {
        return 5.0; //
    }
    return orig;
}

// 3. Tạo nhiễu độ cao giả lập (Altitude Simulation)
- (CLLocationDistance)altitude {
    CLLocationDistance orig = %orig;
    if (orig == 0.0) {
        return 21.3; // Thay đổi số thập phân để trông tự nhiên hơn
    }
    return orig;
}

// 4. Chuẩn hóa thời gian (Timestamp Validation)
- (NSDate *)timestamp {
    return [NSDate date]; // Trả về thời gian thực tại thời điểm gọi
}

%end

// 5. Chống quét môi trường / Ẩn ứng dụng nhân bản hoặc công cụ bẻ khóa
%hook NSFileManager

- (BOOL)fileExistsAtPath:(NSString *)path {
    // Nếu Timemark quét các đường dẫn chứa dylib, ứng dụng fake, hoặc jailbreak, báo không tồn tại
    if ([path containsString:@"Library/MobileSubstrate"] || 
        [path containsString:@"Sideloadly"] || 
        [path containsString:@"FakeGPS"] ||
        [path containsString:@"frida"]) {
        return NO;
    }
    return %orig;
}

%end

// 6. Khởi tạo hệ thống ẩn danh
%ctl() {
    %init(_ungrouped);
    NSLog(@"[TimeMarkShield] Đã kích hoạt hệ thống Bypass GPS nâng cao!");
}
