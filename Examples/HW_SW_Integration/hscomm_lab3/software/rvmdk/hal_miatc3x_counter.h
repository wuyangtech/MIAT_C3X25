
#ifndef __HAL_MIATC3X_COUNTER_H
#define __HAL_MIATC3X_COUNTER_H

#define MIATC3X_COUNTER_BASE 0x68000000
#define MIATC3X_COUNTER_REG_CTRL 0x00
#define MIATC3X_COUNTER_REG_CTRH 0x01
#define MIATC3X_COUNTER_REG_DRL 0x02
#define MIATC3X_COUNTER_REG_DRH 0x03

void miatc3x_counter_enable(void);
void miatc3x_counter_disable(void);
void miatc3x_counter_clear(void);
unsigned int miatc3x_counter_get(void);


#endif
