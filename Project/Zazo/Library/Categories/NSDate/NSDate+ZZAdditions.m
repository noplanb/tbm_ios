//
// Created by Rinat on 05/04/16.
// Copyright (c) 2016 No Plan B. All rights reserved.
//

#import "NSDate+ZZAdditions.h"

typedef enum : NSUInteger
{
    ZZDateFormatTemplateToday,
    ZZDateFormatTemplateWeek,
    ZZDateFormatTemplateYear,
} ZZDateFormatTemplateName;

static NSString *ZZDateFormatTemplate[] = {
        @"jjmm",    //ZZDateFormatTemplateToday
        @"Ejjmm",   //ZZDateFormatTemplateWeek
        @"MMMd"     //ZZDateFormatTemplateYear
};

static NSDateFormatter *dateFormatter;

@implementation NSDate (ZZAdditions)

- (NSString *)zz_formattedDate
{
    return [NSDate _zz_formattedDate:self];
}

+ (NSString *)_zz_formattedDate:(NSDate *)date
{
    if (ANIsEmpty(date))
    {
        return nil;
    }

    if (!dateFormatter)
    {
        dateFormatter = [NSDateFormatter new];
    }

    BOOL isToday = date.an_isToday;
    NSUInteger sevenDays = 7;

    NSString *template;

    if (isToday)
    {
        template = ZZDateFormatTemplate[ZZDateFormatTemplateToday];
    }
    else if ([date an_daysBetweenDate:[NSDate date]] <= sevenDays)
    {
        template = ZZDateFormatTemplate[ZZDateFormatTemplateWeek];
    }
    else
    {
        template = ZZDateFormatTemplate[ZZDateFormatTemplateYear];
    }

    dateFormatter.dateFormat =
            [NSDateFormatter dateFormatFromTemplate:template
                                            options:0
                                             locale:[NSLocale currentLocale]];

    return [dateFormatter stringFromDate:date];

}


@end