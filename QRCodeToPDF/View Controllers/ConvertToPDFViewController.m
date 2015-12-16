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
}
@end

@implementation ConvertToPDFViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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
    UIGraphicsBeginPDFContextToFile(filePath, CGRectZero, nil);
    
    NSInteger currentPage = 0;
    BOOL done = NO;
    do {
        // Mark the beginning of a new page.
        UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, pageSize.width, pageSize.height), nil);
        //Draw an image
        [self drawImage];
        done = YES;
    }
    while (!done);
    
    // Close the PDF context and write the contents out.
    UIGraphicsEndPDFContext();
}

- (void) drawText
{
    CGContextRef    currentContext = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(currentContext, 0.0, 0.0, 0.0, 1.0);
    
    NSString *textToDraw = @"QR Code Text";
    
    UIFont *font = [UIFont systemFontOfSize:14.0];
    
    CGSize stringSize = [textToDraw sizeWithFont:font
                               constrainedToSize:CGSizeMake(100, 30)
                                   lineBreakMode:UILineBreakModeWordWrap];
    
    CGRect renderingRect = CGRectMake(kBorderInset + kMarginInset, kBorderInset + kMarginInset + 50.0, pageSize.width - 2*kBorderInset - 2*kMarginInset, stringSize.height);
    
    [textToDraw drawInRect:renderingRect
                  withFont:font
             lineBreakMode:UILineBreakModeWordWrap
                 alignment:UITextAlignmentLeft];
}

- (void) drawImage
{
    UIImage *demoImage = qrCodeImageView.image;
    [demoImage drawInRect:CGRectMake(20, 20, demoImage.size.width/2, demoImage.size.height/2)];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
