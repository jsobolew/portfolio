/*
 * screen.c
 * class for display and touch control
 * Author: Lukasz Nowak
 */

#include "screen.h"

TS_StateTypeDef TS_State =
{ 0 };
uint16_t x_old = 0, y_old = 0;

/*
 * @Brief clears the screen and fills accordingly it to represent touch location
 * @param TouchLocation type: uint8_t range 0 - 255 touch position in screen x axis
 */
void Display_Update(const uint8_t TouchPosition)
{
	BSP_LCD_Clear(LCD_COLOR_BLACK);
	BSP_LCD_SetTextColor(LCD_COLOR_GREEN);
	BSP_LCD_FillRect(0, 0, TouchPosition, 255);
}

void Display_ShowErrorMessage(uint8_t *ErrorMessage)
{
	BSP_LCD_Clear(LCD_COLOR_WHITE);
	BSP_LCD_SetTextColor(LCD_COLOR_RED);
	BSP_LCD_DisplayStringAtLine(8, ErrorMessage);
}
//Displays error message at Line. Does not clear the screen
void Display_ShowErrorMessageAtLine(const uint16_t Line, uint8_t *ErrorMessage)
{
	BSP_LCD_DisplayStringAtLine(Line, ErrorMessage);
}
//Returns x position of 1st touch event unless it's the same as in previous update
uint8_t Display_GetTouchPosition(void)
{
	uint16_t x1, y1;
	uint8_t x_out = 0;

	/* Check in polling mode in touch screen the touch status and coordinates */
	/* of touches if touch occurred, ignores 2nd touch                        */
	BSP_TS_GetState(&TS_State);

	if (TS_State.touchDetected)
	{
		/* Get X and Y position of the first touch*/
		x1 = TS_State.touchX[0];
		y1 = TS_State.touchY[0];

		//    if((x_old != x1) || (y_old != y1))
		if (x_old != x1)
		{
			x_old = x1;
			y_old = y1;
		}
		x_out = x1;
		return x_out;
	}
	else
	{
		return 0;
	}
}

void Display_DisableBacklight()
{
	if(BackLightState == GPIO_PIN_RESET)
	{
		return;
	}
	HAL_GPIO_WritePin(LCD_BL_CTRL_GPIO_PORT, LCD_BL_CTRL_PIN, GPIO_PIN_RESET);
	BackLightState = GPIO_PIN_RESET;
	return;
}

void Display_ToggleScreenBacklight(GPIO_PinState BLState)
{
	if(HAL_GPIO_ReadPin(LCD_BL_CTRL_GPIO_PORT, LCD_BL_CTRL_PIN)==BLState)
	{
		return;
	}
	HAL_GPIO_WritePin(LCD_BL_CTRL_GPIO_PORT, LCD_BL_CTRL_PIN, BLState);
	BackLightState = BLState;
}
