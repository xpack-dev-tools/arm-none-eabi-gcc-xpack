/*
 * This file is part of the µOS++ project (http://micro-os-plus.github.io).
 * Copyright (c) 2014-2026 Liviu Ionescu. All rights reserved.
 *
 * Permission to use, copy, modify, and/or distribute this software
 * for any purpose is hereby granted, under the terms of the MIT license.
 *
 * If a copy of the license was not distributed with this file, it can
 * be obtained from https://opensource.org/licenses/mit.
 */

// ----------------------------------------------------------------------------

#include <stdlib.h>
#include "diag/Trace.h"

// ----------------------------------------------------------------------------

#if !defined(DEBUG)
extern void
__attribute__((noreturn))
__reset_hardware(void);
#endif

// ----------------------------------------------------------------------------

// Forward declaration

void
_exit(int code);

// ----------------------------------------------------------------------------

// On Release, call the hardware reset procedure.
// On Debug we just enter an infinite loop, to be used as landmark when halting
// the debugger.
//
// It can be redefined in the application, if more functionality
// is required.

void
__attribute__((weak))
_exit(int code __attribute__((unused)))
{
#if !defined(DEBUG)
  __reset_hardware();
#endif

  // TODO: write on trace
  while (1)
    ;
}

// ----------------------------------------------------------------------------

void
__attribute__((weak,noreturn))
abort(void)
{
  trace_puts("abort(), exiting...");

  _exit(1);
}

// ----------------------------------------------------------------------------
