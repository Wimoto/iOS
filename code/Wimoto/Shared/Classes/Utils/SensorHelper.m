//
//  SensorHelper.m
//  Wimoto
//
//  Created by Danny Kokarev on 06.02.14.
//
//

#import "SensorHelper.h"

@implementation SensorHelper

+ (float)getHumidityValue:(uint16_t)u16sRH
{
    float humidityRH;              /* variable for result  */
	u16sRH &= ~0x0003;             /* clear bits [1..0] (status bits) */
	/*-- calculate relative humidity [%RH] -- */
	humidityRH = -6.0 + (125.0/65536) * (float)u16sRH; /* RH= -6 + 125 * SRH/2^16 */
	return humidityRH;
}

+ (float)getTemperatureValue:(uint16_t)u16sT
{
    float temperatureC;             /* variable for result */
	u16sT &= ~0x0003;              /* clear bits [1..0] (status bits) */
	/*-- calculate temperature [∞C] -- */
	temperatureC= -46.85 + (175.72/65536 ) *(float)u16sT; /* T= -46.85 + 175.72 * ST/2^16 */
	return temperatureC;

}

@end
