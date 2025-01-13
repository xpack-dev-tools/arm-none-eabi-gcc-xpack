/*
 * This file is part of the µOS++ project (http://micro-os-plus.github.io).
 * Copyright (c) 2014 Liviu Ionescu. All rights reserved.
 *
 * Permission to use, copy, modify, and/or distribute this software
 * for any purpose is hereby granted, under the terms of the MIT license.
 *
 * If a copy of the license was not distributed with this file, it can
 * be obtained from https://opensource.org/licenses/mit/.
 */

#include "Timer.h"
#include "cortexm/ExceptionHandlers.h"

// ----------------------------------------------------------------------------

#if defined(USE_HAL_DRIVER)
extern "C" void HAL_IncTick(void);
#endif

// ----------------------------------------------------------------------------

volatile Timer::ticks_t Timer::ms_delayCount;

// ----------------------------------------------------------------------------

void
Timer::sleep(ticks_t ticks)
{
  ms_delayCount = ticks;

  // Busy wait until the SysTick decrements the counter to zero.
  while (ms_delayCount != 0u)
    ;
}

// ----- SysTick_Handler() ----------------------------------------------------

extern "C" void
SysTick_Handler(void)
{
#if defined(USE_HAL_DRIVER)
  HAL_IncTick();
#endif
  Timer::tick();
}

// ----------------------------------------------------------------------------
