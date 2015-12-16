//
//  ConvertToPDFViewController.m
//  QRCodeToPDF
//
//  Created by IcomsMacbookPro on 12/16/15.
//  Copyright © 2015 Icoms. All rights reserved.
//

#import "ConvertToPDFViewController.h"

@interface ConvertToPDFViewController ()
{
    IBOutlet UIImageView *qrCodeImageView;
    CGSize pageSize;
    CGFloat yPosition;
}
@end

@implementation ConvertToPDFViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    yPosition = 20;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)createPDFButtonPressed:(id)sender {
    pageSize = CGSizeMake(612, 792);
    NSString *fileName = @"demo.pdf";
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *pdfFileName = [documentsDirectory stringByAppendingPathComponent:fileName];
    [self generatePdfWithFilePath:pdfFileName];
    [self sendPDFInEmailWithFilePath:pdfFileName];
}

- (void) generatePdfWithFilePath:(NSString *)filePath
{
    yPosition = 20; // Initial position
    UIGraphicsBeginPDFContextToFile(filePath, CGRectZero, nil);
    NSInteger currentPage = 0;
    BOOL done = NO;
    do {
        // Mark the beginning of a new page.
        UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, pageSize.width, pageSize.height), nil);
        //Draw an image
        [self drawImage];
        // Draw text
        [self drawText];
        done = YES;
    }
    while (!done);
    
    // Close the PDF context and write the contents out.
    UIGraphicsEndPDFContext();
}

- (void) drawText
{
    NSString *textToDraw = @"QR Code Text";
    UIFont *font = [UIFont systemFontOfSize:14.0];
    CGFloat width = 100;
    UIImage *image = [self imageWithString:textToDraw font:font width:width];
    [image drawInRect:CGRectMake(20, yPosition, image.size.width, image.size.height)];
    yPosition += image.size.height + 10;
}

- (void) drawImage
{
    UIImage *demoImage = qrCodeImageView.image;
    [demoImage drawInRect:CGRectMake(20, yPosition, demoImage.size.width, demoImage.size.height)];
    yPosition += demoImage.size.height + 10;
}

- (void)sendPDFInEmailWithFilePath:(NSString *)filePath {
    dispatch_async(dispatch_get_main_queue(), ^{
        if([MFMailComposeViewController canSendMail]){
            MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
            mailViewController.mailComposeDelegate = self;
            NSData *myData;
            if([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                myData = [[NSFileManager defaultManager] contentsAtPath:filePath];
            } else {
                NSLog(@"File not exits");
                return;
            }
            [mailViewController setSubject:@"Demo PDF"];
            [mailViewController addAttachmentData:myData mimeType:@"application/pdf" fileName:[filePath lastPathComponent]];
            
            [self.parentViewController presentViewController:mailViewController animated:YES completion:nil];
            
        }else{
            NSLog(@"No email account set up on device.");
        }
    });
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
    if(result == MFMailComposeResultSent){
        NSLog(@"Email sent.");
    }
}

- (UIImage *)imageWithString:(NSString *)string font:(UIFont *)font width:(CGFloat)width
{
    CGSize size = CGSizeMake(width, 10000);
    float systemVersion = UIDevice.currentDevice.systemVersion.floatValue;
    
    CGSize messuredSize;
    if (systemVersion >= 7.0) {
        messuredSize = [string boundingRectWithSize:size
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:@{NSFontAttributeName: font}
                                            context:nil].size;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        messuredSize = [string sizeWithFont:font constrainedToSize:size];
#pragma clang diagnostic pop
    }
    
    if ([UIScreen.mainScreen respondsToSelector:@selector(scale)]) {
        if (UIScreen.mainScreen.scale == 2.0) {
            UIGraphicsBeginImageContextWithOptions(messuredSize, NO, 1.0);
        } else {
            UIGraphicsBeginImageContext(messuredSize);
        }
    } else {
        UIGraphicsBeginImageContext(messuredSize);
    }
    
    CGContextRef ctr = UIGraphicsGetCurrentContext();
    UIColor *color = [UIColor whiteColor];
    [color set];
    
    CGRect rect = CGRectMake(0, 0, messuredSize.width + 1, messuredSize.height + 1);
    CGContextFillRect(ctr, rect);
    
    color = [UIColor blackColor];
    [color set];
    
    if (systemVersion >= 7.0) {
        [string drawInRect:rect withAttributes:@{NSFontAttributeName: font}];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [string drawInRect:rect withFont:font];
#pragma clang diagnostic pop
    }
    
    UIImage *imageToPrint = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return imageToPrint;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
