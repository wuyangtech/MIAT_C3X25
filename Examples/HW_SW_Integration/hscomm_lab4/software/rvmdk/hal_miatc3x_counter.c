
#include "hal_miatc3x_counter.h"

void miatc3x_counter_enable(void)
{
    unsigned int* p;
    p = (unsigned int*)MIATC3X_COUNTER_BASE;
    *p = 0x00008000;    
}

void miatc3x_counter_disable(void)
{
    unsigned int* p;
    p = (unsigned int*)MIATC3X_COUNTER_BASE;
    *p = 0x00000000;
}

void miatc3x_counter_clear(void)
{
    unsigned int* p;
    int i;

    p = (unsigned int*)MIATC3X_COUNTER_BASE;
    
    *p = 0x00000001;
    for(i=0;i<10;i++);
    *p = 0x00000000;
}

unsigned int miatc3x_counter_get(void)
{
    unsigned int* p;
    p = (unsigned int*)MIATC3X_COUNTER_BASE;
    
    return *(p+1);
        
}

void miatc3x_stx_senddata(unsigned char data)
{
    int i;
    unsigned int* p;
    p = (unsigned int*)0x68000000;
    *(p+3) = 868<<16;
    *(p+4) = data;
    *(p+3) = (868<<16)|0x8000;
    
    while(*(p+3)==0);
    for(i=0;i<10000;i++);
    *(p+3) = (868<<16);
}

