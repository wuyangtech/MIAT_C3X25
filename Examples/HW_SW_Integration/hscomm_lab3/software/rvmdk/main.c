/******************** (C) COPYRIGHT 2008 STMicroelectronics ********************
* File Name          : main.c
* Author             : MCD Application Team
* Version            : V2.0.3
* Date               : 09/22/2008
* Description        : Main program body
********************************************************************************
* THE PRESENT FIRMWARE WHICH IS FOR GUIDANCE ONLY AIMS AT PROVIDING CUSTOMERS
* WITH CODING INFORMATION REGARDING THEIR PRODUCTS IN ORDER FOR THEM TO SAVE TIME.
* AS A RESULT, STMICROELECTRONICS SHALL NOT BE HELD LIABLE FOR ANY DIRECT,
* INDIRECT OR CONSEQUENTIAL DAMAGES WITH RESPECT TO ANY CLAIMS ARISING FROM THE
* CONTENT OF SUCH FIRMWARE AND/OR THE USE MADE BY CUSTOMERS OF THE CODING
* INFORMATION CONTAINED HEREIN IN CONNECTION WITH THEIR PRODUCTS.
*******************************************************************************/

/* Includes ------------------------------------------------------------------*/
#include "stm32f10x_lib.h"
#include "platform_config.h"


#include "stdio.h"
#include "fsmc_sram.h"
#include "stdlib.h"

#include "hal_miatc3x_counter.h"

#define Counter_Address_Base 0x68000000


/* Private typedef -----------------------------------------------------------*/
/* Private define ------------------------------------------------------------*/
/* Private macro -------------------------------------------------------------*/
/* Private variables ---------------------------------------------------------*/
USART_InitTypeDef USART_InitStructure;
ErrorStatus HSEStartUpStatus;

/* Private function prototypes -----------------------------------------------*/
void RCC_Configuration(void);
void GPIO_Configuration(void);
void NVIC_Configuration(void);

#ifdef __GNUC__
  /* With GCC/RAISONANCE, small printf (option LD Linker->Libraries->Small printf
     set to 'Yes') calls __io_putchar() */
  #define PUTCHAR_PROTOTYPE int __io_putchar(int ch)
#else
  #define PUTCHAR_PROTOTYPE int fputc(int ch, FILE *f)
#endif /* __GNUC__ */
  
/* Private functions ---------------------------------------------------------*/

/*******************************************************************************
* Function Name  : main
* Description    : Main program
* Input          : None
* Output         : None
* Return         : None
*******************************************************************************/
int main(void)
{

    

#ifdef DEBUG
  debug();
#endif

  unsigned char r;
  unsigned char g;
  unsigned char b;
  float y;
  float u;
  float v;
  unsigned char fixed_y;
  unsigned char fixed_u;
  unsigned char fixed_v;

  u32* sp;
  
  /* System Clocks Configuration */
  RCC_Configuration();
       
  /* NVIC configuration */
  NVIC_Configuration();

  /* Configure the GPIO ports */
  GPIO_Configuration();

  FSMC_SRAM_Init();

/* USARTx configuration ------------------------------------------------------*/
  /* USARTx configured as follow:
        - BaudRate = 115200 baud  
        - Word Length = 8 Bits
        - One Stop Bit
        - No parity
        - Hardware flow control disabled (RTS and CTS signals)
        - Receive and transmit enabled
  */
  USART_InitStructure.USART_BaudRate = 115200;
  USART_InitStructure.USART_WordLength = USART_WordLength_8b;
  USART_InitStructure.USART_StopBits = USART_StopBits_1;
  USART_InitStructure.USART_Parity = USART_Parity_No ;
  USART_InitStructure.USART_HardwareFlowControl = USART_HardwareFlowControl_None;
  USART_InitStructure.USART_Mode = USART_Mode_Rx | USART_Mode_Tx;
  
  /* Configure the USARTx */ 
  USART_Init(USARTx, &USART_InitStructure);
  /* Enable the USARTx */
  USART_Cmd(USARTx, ENABLE);


  /* Output a message on Hyperterminal using printf function */
  printf("\n\rUSART Printf Example: retarget the C library printf function to the USART\n\r");

    
    // float point operation
    printf("Float point operation\n\r");
    miatc3x_counter_disable();
    miatc3x_counter_clear();
    miatc3x_counter_enable();
    
    r = 12;
    g = 123;
    b = 234;    

    y = ((0.257*r)+(0.504*g)+(0.098*b) + 16);
    u = ((0.439*r)+(-0.368*g)+(-0.071*b) + 128);
    v = ((-0.148*r)+(-0.291*g)+(0.439*b) + 128);

    miatc3x_counter_disable();

    printf("> During Time: %d0 ns\n\r", miatc3x_counter_get());
    printf("Y: %f\n\r", y);
    printf("U: %f\n\r", u);
    printf("V: %f\n\r", v);

    
    printf("\n\r");

    // fixed point operation
    printf("Fixed point operation\n\r");
    miatc3x_counter_disable();
    miatc3x_counter_clear();
    miatc3x_counter_enable();
    
    r = 12;
    g = 123;
    b = 234;    

    fixed_y = ((66*r)+(130*g)+(26*b) + 4096)>>8;
    fixed_u = ((113*r)+(-95*g)+(-19*b) + 32768)>>8;
    fixed_v = ((-38*r)+(-75*g)+(113*b) + 32768)>>8;

    miatc3x_counter_disable();

    printf("> During Time: %d0 ns\n\r", miatc3x_counter_get());
    printf("Y: %d\n\r", fixed_y);
    printf("U: %d\n\r", fixed_u);
    printf("V: %d\n\r", fixed_v);

    printf("\n\r");

    // fixed point operation
    printf("Fixed point operation\n\r");
    sp = (u32 *)0x68000008;
    miatc3x_counter_disable();
    miatc3x_counter_clear();
    miatc3x_counter_enable();
    
    r = 12;
    g = 123;
    b = 234;
    
    *sp = (r<<16)|(g<<8)|(b);

    miatc3x_counter_disable();

    printf("> During Time: %d0 ns\n\r", miatc3x_counter_get());
    printf("Y: %d\n\r", (*sp>>16)&0xFF);
    printf("U: %d\n\r", (*sp>>8)&0xFF);
    printf("V: %d\n\r", (*sp)&0xFF);
          
    while(1);

}

/*******************************************************************************
* Function Name  : RCC_Configuration
* Description    : Configures the different system clocks.
* Input          : None
* Output         : None
* Return         : None
*******************************************************************************/
void RCC_Configuration(void)
{
  /* RCC system reset(for debug purpose) */
  RCC_DeInit();

  /* Enable HSE */
  RCC_HSEConfig(RCC_HSE_ON);

  /* Wait till HSE is ready */
  HSEStartUpStatus = RCC_WaitForHSEStartUp();

  if(HSEStartUpStatus == SUCCESS)
  {
    /* Enable Prefetch Buffer */
    FLASH_PrefetchBufferCmd(FLASH_PrefetchBuffer_Enable);

    /* Flash 2 wait state */
    FLASH_SetLatency(FLASH_Latency_2);
 
    /* HCLK = SYSCLK */
    RCC_HCLKConfig(RCC_SYSCLK_Div1); 
  
    /* PCLK2 = HCLK */
    RCC_PCLK2Config(RCC_HCLK_Div1); 

    /* PCLK1 = HCLK/2 */
    RCC_PCLK1Config(RCC_HCLK_Div2);

    /* PLLCLK = 8MHz * 9 = 72 MHz */
    RCC_PLLConfig(RCC_PLLSource_HSE_Div1, RCC_PLLMul_9);

    /* Enable PLL */ 
    RCC_PLLCmd(ENABLE);

    /* Wait till PLL is ready */
    while(RCC_GetFlagStatus(RCC_FLAG_PLLRDY) == RESET)
    {
    }

    /* Select PLL as system clock source */
    RCC_SYSCLKConfig(RCC_SYSCLKSource_PLLCLK);

    /* Wait till PLL is used as system clock source */
    while(RCC_GetSYSCLKSource() != 0x08)
    {
    }
  }
    
  /* Enable GPIOx clock */
  RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOx, ENABLE);

/* Enable USARTx clocks */
#ifdef USE_USART1  
  RCC_APB2PeriphClockCmd(RCC_APB2Periph_USART1, ENABLE);
#else
  RCC_APB1PeriphClockCmd(RCC_APB1Periph_USARTx, ENABLE);
#endif
}

/*******************************************************************************
* Function Name  : GPIO_Configuration
* Description    : Configures the different GPIO ports.
* Input          : None
* Output         : None
* Return         : None
*******************************************************************************/
void GPIO_Configuration(void)
{
  GPIO_InitTypeDef GPIO_InitStructure;

#if defined USE_USART2	&& defined USE_STM3210B_EVAL
  /* Enable AFIO clock */
  RCC_APB2PeriphClockCmd(RCC_APB2Periph_AFIO, ENABLE);

  /* Enable the USART2 Pins Software Remapping */
  GPIO_PinRemapConfig(GPIO_Remap_USART2, ENABLE);
#endif

  /* Configure USARTx_Tx as alternate function push-pull */
  GPIO_InitStructure.GPIO_Pin = GPIO_TxPin;
  GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
  GPIO_InitStructure.GPIO_Mode = GPIO_Mode_AF_PP;
  GPIO_Init(GPIOx, &GPIO_InitStructure);

  /* Configure USARTx_Rx as input floating */
  GPIO_InitStructure.GPIO_Pin = GPIO_RxPin;
  GPIO_InitStructure.GPIO_Mode = GPIO_Mode_IN_FLOATING;
  GPIO_Init(GPIOx, &GPIO_InitStructure);

}

/*******************************************************************************
* Function Name  : NVIC_Configuration
* Description    : Configures Vector Table base location.
* Input          : None
* Output         : None
* Return         : None
*******************************************************************************/
void NVIC_Configuration(void)
{ 
#ifdef  VECT_TAB_RAM  
  /* Set the Vector Table base location at 0x20000000 */ 
  NVIC_SetVectorTable(NVIC_VectTab_RAM, 0x0); 
#else  /* VECT_TAB_FLASH  */
  /* Set the Vector Table base location at 0x08000000 */ 
  //NVIC_SetVectorTable(NVIC_VectTab_FLASH, 0x0);
  NVIC_SetVectorTable(0x08003000, 0x0);   
#endif
}

/*******************************************************************************
* Function Name  : PUTCHAR_PROTOTYPE
* Description    : Retargets the C library printf function to the USART.
* Input          : None
* Output         : None
* Return         : None
*******************************************************************************/
PUTCHAR_PROTOTYPE
{
  /* Write a character to the USART */
  USART_SendData(USARTx, (u8) ch);

  /* Loop until the end of transmission */
  while(USART_GetFlagStatus(USARTx, USART_FLAG_TXE) == RESET)
  {
  }

  return ch;
}

#ifdef  DEBUG
/*******************************************************************************
* Function Name  : assert_failed
* Description    : Reports the name of the source file and the source line number
*                  where the assert_param error has occurred.
* Input          : - file: pointer to the source file name
*                  - line: assert_param error line source number
* Output         : None
* Return         : None
*******************************************************************************/
void assert_failed(u8* file, u32 line)
{ 
  /* User can add his own implementation to report the file name and line number,
     ex: printf("Wrong parameters value: file %s on line %d\r\n", file, line) */

  /* Infinite loop */
  while (1)
  {
  }
}
#endif

/******************* (C) COPYRIGHT 2008 STMicroelectronics *****END OF FILE****/
