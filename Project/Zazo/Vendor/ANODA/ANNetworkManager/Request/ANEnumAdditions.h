//
//  ANEnumAdditions.h
//
//  Created by ANODA on 21/11/14.
//
//

typedef NS_ENUM(NSInteger, ANHttpMethodType)
{
    ANHttpMethodTypeNone,
    ANHttpMethodTypeGET,
    ANHttpMethodTypePOST,
    ANHttpMethodTypeDELETE,
    ANHttpMethodTypePOSTJSON
};

NSString *ANHttpMethodTypeStringFromEnumValue(ANHttpMethodType);

ANHttpMethodType ANHttpMethodTypeEnumValueFromSrting(NSString *);