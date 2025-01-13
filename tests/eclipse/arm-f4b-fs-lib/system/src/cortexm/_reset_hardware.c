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

// ----------------------------------------------------------------------------

#include "cmsis_device.h"

// ----------------------------------------------------------------------------

extern void
__attribute__((noreturn))
NVIC_SystemReset(void);

// ----------------------------------------------------------------------------

// Forward declarations

void
__reset_hardware(void);

// ----------------------------------------------------------------------------

// This is the default hardware reset routine; it can be
// redefined in the application for more complex applications.
//
// Called from _exit().

void
__attribute__((weak,noreturn))
__reset_hardware()
{
  NVIC_SystemReset();
}

// ----------------------------------------------------------------------------
