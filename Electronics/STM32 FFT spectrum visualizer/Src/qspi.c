/**
******************************************************************************
* @file    BSP/Src/qspi.c 
* @author  MCD Application Team
* @brief   This example code shows how to use the QSPI Driver
******************************************************************************
* @attention
*
* <h2><center>&copy; COPYRIGHT(c) 2017 STMicroelectronics</center></h2>
*
* Redistribution and use in source and binary forms, with or without modification,
* are permitted provided that the following conditions are met:
*   1. Redistributions of source code must retain the above copyright notice,
*      this list of conditions and the following disclaimer.
*   2. Redistributions in binary form must reproduce the above copyright notice,
*      this list of conditions and the following disclaimer in the documentation
*      and/or other materials provided with the distribution.
*   3. Neither the name of STMicroelectronics nor the names of its contributors
*      may be used to endorse or promote products derived from this software
*      without specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
* AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
* IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
* DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
* FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
* DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
* SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
* CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
* OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
* OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*
******************************************************************************
*/

/* Includes ------------------------------------------------------------------*/
#include "qspi.h"

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
//static void QSPI_WRITE(uint8_t data);
//static uint8_t QSPI_READ();
//static void     Fill_Buffer (uint8_t *pBuffer, uint32_t uwBufferLength, uint32_t uwOffset);
//static uint8_t  Buffercmp   (uint8_t* pBuffer1, uint8_t* pBuffer2, uint32_t BufferLength);

/* Private functions ---------------------------------------------------------*/



/*@brief Prepares data to be saved to QSPI cleans mem page and writes data to it.
 * @param data - type:uint8_t
 *
 */
void QSPI_WRITE(uint8_t data)
{

	//erase data in target address. This is to assure memory page will be empty before writing to it.
	if(BSP_QSPI_Erase_Block(DATA_ADDR) != QSPI_OK)
	      {
	        BSP_LCD_DisplayStringAt(5, 100, (uint8_t*)"QSPI ERASE : FAILED", LEFT_MODE);
	        return;
	      }

	//write data to target address
	if(BSP_QSPI_Write((uint8_t*)(&data), DATA_ADDR, sizeof(data)) != QSPI_OK)
	        {
	          BSP_LCD_DisplayStringAt(5, 115, (uint8_t*)"QSPI WRITE : FAILED", LEFT_MODE);
	          return;
	        }

}

/*@brief reads stored data
 *  returns data or -1 on read failure
 */
uint8_t QSPI_READ()
{
	//Read data from target address
	if(BSP_QSPI_Read(qspi_aRxBuffer, DATA_ADDR, BUFFER_SIZE) != QSPI_OK)
	          {
	            BSP_LCD_DisplayStringAt(5, 130, (uint8_t*)"QSPI READ : FAILED", LEFT_MODE);
	            return -1;
	          }
	return qspi_aRxBuffer[0];

}


///**
//* @brief  Fills buffer with user predefined data.
//* @param  pBuffer: pointer on the buffer to fill
//* @param  uwBufferLenght: size of the buffer to fill
//* @param  uwOffset: first value to fill on the buffer
//* @retval None
//*/
//static void Fill_Buffer(uint8_t *pBuffer, uint32_t uwBufferLenght, uint32_t uwOffset)
//{
//  uint32_t tmpIndex = 0;
//
//  /* Put in global buffer different values */
//  for (tmpIndex = 0; tmpIndex < uwBufferLenght; tmpIndex++ )
//  {
//    pBuffer[tmpIndex] = tmpIndex + uwOffset;
//  }
//}
//
///**
//* @brief  Compares two buffers.
//* @param  pBuffer1, pBuffer2: buffers to be compared.
//* @param  BufferLength: buffer's length
//* @retval 1: pBuffer identical to pBuffer1
//*         0: pBuffer differs from pBuffer1
//*/
//static uint8_t Buffercmp(uint8_t* pBuffer1, uint8_t* pBuffer2, uint32_t BufferLength)
//{
//  while (BufferLength--)
//  {
//    if (*pBuffer1 != *pBuffer2)
//    {
//      return 1;
//    }
//
//    pBuffer1++;
//    pBuffer2++;
//  }
//
//  return 0;
//}
/**
* @}
*/ 

/**
* @}
*/ 
/************************ (C) COPYRIGHT STMicroelectronics *****END OF FILE****/
