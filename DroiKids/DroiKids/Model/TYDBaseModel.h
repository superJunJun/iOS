//
//  TYDBaseModel.h
//

#import <Foundation/Foundation.h>

@interface TYDBaseModel : NSObject

//属性字典,json解析后的字典key与本地属性名合成的属性字典
- (NSDictionary *)attributeMapDictionary;

//通过字典设置属性
- (void)setAttributes:(NSDictionary *)dataDic;

//通过同类型的对象设置对象
- (BOOL)setAttributesWithObject:(TYDBaseModel *)object;

//NSNumber类型属性校正
- (NSNumber *)integerNumberValueFix:(id)number;
- (NSNumber *)floatNumberValueFix:(id)number;

//NSString类型属性校正
- (NSString *)stringValueFix:(id)string;

//将值为@"0"的字串转为@""
- (NSString *)clearZeroValueString:(NSString *)string;

@end
