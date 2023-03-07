//qspi.h
//autor Lukasz Nowak

/* Includes ------------------------------------------------------------------*/

//i know its not optimal, but its easy solution for error messages
#include "screen.h"

#include "stm32f413h_discovery_qspi.h"
/* Private typedef -----------------------------------------------------------*/
/* Private define ------------------------------------------------------------*/
#define BUFFER_SIZE         ((uint32_t)0x0200)
#define DATA_ADDR     ((uint32_t)0x0050)
#define HEADBAND_HEIGHT     64
/* Private macro -------------------------------------------------------------*/
/* Private variables ---------------------------------------------------------*/
uint8_t qspi_aTxBuffer[BUFFER_SIZE];
uint8_t qspi_aRxBuffer[BUFFER_SIZE];

/* Private function prototypes -----------------------------------------------*/
void QSPI_WRITE(uint8_t data);
uint8_t QSPI_READ();
