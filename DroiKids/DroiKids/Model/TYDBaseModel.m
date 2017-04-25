//
//  TYDBaseModel.m
//

#import "TYDBaseModel.h"

@implementation TYDBaseModel

- (NSDictionary *)attributeMapDictionary
{
    return nil;
}

- (void)setAttributes:(NSDictionary *)dataDic
{
    NSDictionary *attrMapDic = [self attributeMapDictionary];
    for(NSString *mapDicKey in attrMapDic)
    {
        SEL sel = [self getSetterSelWithAttibuteName:attrMapDic[mapDicKey]];
        if([self respondsToSelector:sel])
        {
            NSString *dataDicKey = mapDicKey;
            id attributeValue = dataDic[dataDicKey];
            if(!attributeValue) continue;
            
            if([attributeValue isKindOfClass:NSString.class])
            {
                attributeValue = [attributeValue stringByRemovingPercentEncoding];
                //attributeValue = [attributeValue stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            }
            [self performSelectorOnMainThread:sel
                                   withObject:attributeValue
                                waitUntilDone:[NSThread isMainThread]];
        }
    }
}

//根据属性名获取set方法
- (SEL)getSetterSelWithAttibuteName:(NSString *)attributeName
{
	NSString *capital = [[attributeName substringToIndex:1] uppercaseString];
	NSString *setterSelStr = [NSString stringWithFormat:@"set%@%@:", capital, [attributeName substringFromIndex:1]];
	return NSSelectorFromString(setterSelStr);
}

#pragma mark - SetAttributes

- (BOOL)setAttributesWithObject:(TYDBaseModel *)object
{
    return (self != object
            && object != nil
            && [object isKindOfClass:[self class]]);
}

#pragma mark - JSonErrorFix

- (NSNumber *)integerNumberValueFix:(id)number
{
    NSString *valueString = @"0";
    if(number)
    {
        valueString = [NSString stringWithFormat:@"%@", number];
    }
    return @(valueString.integerValue);
}

- (NSNumber *)floatNumberValueFix:(id)number
{
    NSString *valueString = @"0";
    if(number)
    {
        valueString = [NSString stringWithFormat:@"%@", number];
    }
    return @(valueString.floatValue);
}

- (NSString *)stringValueFix:(id)string
{
    NSString *valueStr = @"";
    if(string)
    {
        if([string isKindOfClass:NSNumber.class]
           && [string isEqualToNumber:@0])
        {
            valueStr = @"";
        }
        else if([string isKindOfClass:NSNull.class])
        {
            valueStr = @"";
        }
        else
        {
            valueStr = [NSString stringWithFormat:@"%@", string];
        }
    }
    return valueStr;
}

- (NSString *)clearZeroValueString:(NSString *)string
{
    if([string isEqualToString:@"0"])
    {
        string = @"";
    }
    return string;
}

@end
