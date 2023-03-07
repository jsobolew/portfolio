/*
 * screen.h
 * class for display and touch control
 * Author: Lukasz Nowak
 */

#ifndef INC_SCREEN_H_
#define INC_SCREEN_H_

#include "stdint.h"
#include "stm32f413h_discovery_lcd.h"
#include "stm32f413h_discovery_ts.h"

static GPIO_PinState BackLightState = GPIO_PIN_SET;

/*
 * @Brief clears the screen and fills accordingly it to represent touch location
 * @param TouchLocation type: uint8_t range 0 - 255 touch position in screen x axis
 */
void Display_Update(const uint8_t TouchPosition);

//Changes screen bg and displays error message.
void Display_ShowErrorMessage(uint8_t* ErrorMessage);

//Displays error message at Line. Does not clear the screen
void Display_ShowErrorMessageAtLine(const uint16_t Line,uint8_t *ErrorMessage);

//Returns x position of 1st touch event unless it's the same as in previous update/
uint8_t Display_GetTouchPosition(void);

//Inverts state of LCD backlight
void Display_ToggleScreenBacklight(GPIO_PinState BLState);

void Display_DisableBacklight();
#endif /* INC_SCREEN_H_ */
