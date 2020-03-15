#ifndef MICS6814_H
#define MICS6814_H

#include "Arduino.h"
#include <driver/adc.h>

#define ADC_MAX_VALUE 4095U
#define ADC_MIN_VALUE 0U
#define ADC_SAMPLES 3U
#define ADC_SAMPLE_DELAY 100U

typedef enum
{
	CH_CO,
	CH_NO2,
	CH_NH3
} channel_t;

typedef enum
{
	CO,
	NO2,
	NH3
} gas_t;

class MICS6814
{
public:
	MICS6814(adc1_channel_t channel_CO, adc1_channel_t channel_NO2, adc1_channel_t channel_NH3);
	bool mics6814_read(uint16_t *no2, uint16_t *nh3, uint16_t *co);
	void calibrate();
	void loadCalibrationData(
		uint16_t base_NH3,
		uint16_t base_RED,
		uint16_t base_OX);

	float measure(gas_t gas);

	uint16_t getResistance(channel_t channel) const;
	uint16_t getBaseResistance(channel_t channel) const;
	float getCurrentRatio(channel_t channel) const;

private:
	adc1_channel_t _pinCO;
	adc1_channel_t _pinNO2;
	adc1_channel_t _pinNH3;

	uint16_t _baseNH3;
	uint16_t _baseCO;
	uint16_t _baseNO2;
};

#endif