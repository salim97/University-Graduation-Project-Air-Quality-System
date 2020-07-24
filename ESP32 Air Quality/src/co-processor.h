///////////////////////////////////////////////////////////////////////////////////
// ULP section
// https://www.espressif.com/sites/default/files/documentation/esp32_technical_reference_manual_en.pdf
// RTC_MUX        Pin         Summary                   |  Analog  Function
// RTC GPIO Num | GPIO Num  | Pad Name    |  1          |   2      | 3
// 0            | 36        | SENSOR_VP   | ADC_H       | ADC1_CH0 | -
// 1            | 37        | SENSOR_CAPP | ADC_H       | ADC1_CH1 | -
// 2            | 38        | SENSOR_CAPN | ADC_H       | ADC1_CH2 | -
// 3            | 39        | SENSOR_VN   | ADC_H       | ADC1_CH3 | -
// 4            | 34        | VDET_1      | -           | ADC1_CH6 | -
// 5            | 35        | VDET_2      | -           | ADC1_CH7 | -
// 6            | 25        | GPIO25      | DAC_1       | ADC2_CH8 | -
// 7            | 26        | GPIO26      | DAC_2       | ADC2_CH9 | -
// 8            | 33        | 32K_XN      | XTAL_32K_N  | ADC1_CH5 | TOUCH8
// 9            | 32        | 32K_XP      | XTAL_32K_P  | ADC1_CH4 | TOUCH9
// 10           | 4         | GPIO4       | -           | ADC2_CH0 | TOUCH0
// 11           | 0         | GPIO0       | -           | ADC2_CH1 | TOUCH1
// 12           | 2         | GPIO2       | -           | ADC2_CH2 | TOUCH2
// 13           | 15        | MTDO        | -           | ADC2_CH3 | TOUCH3
// 14           | 13        | MTCK        | -           | ADC2_CH4 | TOUCH4
// 15           | 12        | MTDI        | -           | ADC2_CH5 | TOUCH5
// 16           | 14        | MTMS        | -           | ADC2_CH6 | TOUCH6
// 17           | 27        | GPIO27      | -           | ADC2_CH7 | TOUCH7

#include <Arduino.h>
#include <driver/gpio.h>
#include <driver/rtc_io.h>
#include <esp32/ulp.h>
#include <soc/rtc.h>
#include <soc/rtc_cntl_reg.h>
#include <soc/rtc_io_reg.h>
#include <soc/soc_ulp.h>
// #define PIN_LED_RED GPIO_NUM_26
#define LED_RED_RTC_GPIO_Num 7
#define LED_RED_GPIO_NUM_PIN GPIO_NUM_26
// #define PIN_LED_GREEN GPIO_NUM_25
#define LED_GREEN_RTC_GPIO_Num 6
#define LED_GREEN_GPIO_NUM_PIN GPIO_NUM_25
// #define PIN_LED_BLUE GPIO_NUM_33
#define LED_BLUE_RTC_GPIO_Num 8
#define LED_BLUE_GPIO_NUM_PIN GPIO_NUM_33

#define LED_BUILTIN_RTC_GPIO_Num 12
#define LED_BUILTIN_GPIO_NUM_PIN GPIO_NUM_2


enum DeviceStatus {
  booting,
  waitingForWiFiConfig,
  waitingForServerConfig,
  everythingIsOK
};
DeviceStatus currentDeviceStatus;
void setDeviceStatus(DeviceStatus deviceStatus) {
  switch (deviceStatus) {
  case booting:
    RTC_SLOW_MEM[1] = 1U;
    RTC_SLOW_MEM[2] = 1U;
    RTC_SLOW_MEM[3] = 1U;
    break;
  case waitingForWiFiConfig:
    RTC_SLOW_MEM[1] = 0U;
    RTC_SLOW_MEM[2] = 1U;
    RTC_SLOW_MEM[3] = 1U;
    break;
  case waitingForServerConfig:
    RTC_SLOW_MEM[1] = 1U;
    RTC_SLOW_MEM[2] = 1U;
    RTC_SLOW_MEM[3] = 0U;
    break;
  case everythingIsOK:
    RTC_SLOW_MEM[1] = 1U;
    RTC_SLOW_MEM[2] = 0U;
    RTC_SLOW_MEM[3] = 1U;
    break;
  default:
    RTC_SLOW_MEM[1] = 1U;
    RTC_SLOW_MEM[2] = 1U;
    RTC_SLOW_MEM[3] = 1U;
    break;
  }
  currentDeviceStatus = deviceStatus;
}
void setCoreSensorStatus(bool error) {
  if (error)
    RTC_SLOW_MEM[0] = 1U;
  else
    RTC_SLOW_MEM[0] = 0U;
}
const uint16_t ULP_DATA_OFFSET = 0;
const uint16_t ULP_CODE_OFFSET = 4;
#define sync_mem_gpio(index, pin_led, varName)                                 \
  I_MOVI(R1, ULP_DATA_OFFSET), \
    I_LD(R2, R1, (index) ), \
    I_SUBI(R2 , R2 , 0),\  
    M_BXZ(varName ## off),\ 
    M_LABEL(varName ## on),\    
    I_WR_REG_BIT(RTC_GPIO_OUT_W1TC_REG , RTC_GPIO_OUT_DATA_W1TS_S + pin_led, 1), \
    M_BX(varName ## exit),\ 
    M_LABEL( varName ## off),\ 
    I_WR_REG_BIT(RTC_GPIO_OUT_W1TS_REG, RTC_GPIO_OUT_DATA_W1TC_S + pin_led, 1), \
    M_LABEL(varName ## exit)

#define LED_BUILTIN_TOGGLE_MS 500

#define delayMS(varName)\
      I_MOVI(R3,  LED_BUILTIN_TOGGLE_MS),\
      M_LABEL(varName ## on),    \
      I_DELAY(8000),   \
      I_SUBI(R3, R3, 1), \
      M_BXZ(varName ## exit),   \
      M_BX(varName ## on),\
      M_LABEL(varName ## exit)

#define generateLabels(name) name##on, name##off, name##exit

esp_err_t hulp_configure_pin(gpio_num_t pin, rtc_gpio_mode_t mode, bool pullup, bool pulldown, uint32_t level)
{
    esp_err_t err = rtc_gpio_init(pin);
    if(err != ESP_OK)
    {
        ESP_LOGE(TAG, "rtcio (gpio %d) init failed", pin);
        return err;
    }
    if(pullup)
    {
        rtc_gpio_pullup_en(pin);
    }
    else
    {
        rtc_gpio_pullup_dis(pin);
    }
    if(pulldown)
    {
        rtc_gpio_pulldown_en(pin);
    }
    else
    {
        rtc_gpio_pulldown_dis(pin);
    }
    rtc_gpio_set_level(pin, level);
    rtc_gpio_set_direction(pin, mode);
    return ESP_OK;
}
void hulp_peripherals_on()
{
    esp_sleep_pd_config(ESP_PD_DOMAIN_RTC_PERIPH, ESP_PD_OPTION_ON);
}

void startulp() {
  hulp_configure_pin(LED_BUILTIN_GPIO_NUM_PIN, RTC_GPIO_MODE_OUTPUT_ONLY, false, false,0);
  hulp_configure_pin(LED_BLUE_GPIO_NUM_PIN, RTC_GPIO_MODE_OUTPUT_ONLY, false, false,0);
  hulp_configure_pin(LED_RED_GPIO_NUM_PIN, RTC_GPIO_MODE_OUTPUT_ONLY, false, false,0);
  hulp_configure_pin(LED_GREEN_GPIO_NUM_PIN, RTC_GPIO_MODE_OUTPUT_ONLY, false, false,0);
hulp_peripherals_on();

  enum {
    LBL_LOOP,
    LBL_DELAY_LOOP,
    LBL_EXIT_DELAY_LOOP,
    generateLabels(loop1),
    generateLabels(loop2),
    generateLabels(ulp_led_red),
    generateLabels(ulp_led_green),
    generateLabels(ulp_led_blue),
    generateLabels(ulp_led_builtin),
  };

  const ulp_insn_t program[]{
      M_LABEL(LBL_LOOP), // LBL_LOOP:

      sync_mem_gpio(1, LED_RED_RTC_GPIO_Num, ulp_led_red),
      sync_mem_gpio(2, LED_GREEN_RTC_GPIO_Num, ulp_led_green),
      sync_mem_gpio(3, LED_BLUE_RTC_GPIO_Num, ulp_led_blue),
      
I_WR_REG_BIT(RTC_GPIO_OUT_W1TC_REG , RTC_GPIO_OUT_DATA_W1TS_S + LED_BUILTIN_RTC_GPIO_Num, 1), 
      // sync_mem_gpio(0, LED_BUILTIN_RTC_GPIO_Num, ulp_led_builtin),
I_MOVI(R1, ULP_DATA_OFFSET),
    I_LD(R2, R1, (0) ),
    I_SUBI(R2 , R2 , 0),
    M_BXZ(LBL_LOOP),

 
    I_WR_REG_BIT(RTC_GPIO_OUT_W1TC_REG , RTC_GPIO_OUT_DATA_W1TS_S + LED_BUILTIN_RTC_GPIO_Num, 1), 
       delayMS(loop1),
   
    I_WR_REG_BIT(RTC_GPIO_OUT_W1TS_REG, RTC_GPIO_OUT_DATA_W1TC_S + LED_BUILTIN_RTC_GPIO_Num, 1), 
  delayMS(loop2),

      M_BX(LBL_LOOP), // GOTO LBL_LOOP
  };

  size_t size = sizeof(program) / sizeof(ulp_insn_t);

  if (ulp_process_macros_and_load(ULP_CODE_OFFSET, program, &size) != ESP_OK) {
    Serial.println(F("Error loading ULP code!"));
    return;
  }

  if (ulp_run(ULP_CODE_OFFSET) != ESP_OK) {
    Serial.println(F("Error running ULP code!"));
    return;
  }

  Serial.println(F("Executing ULP code"));
  Serial.flush();
}