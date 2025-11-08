/*
 * This file is part of the µOS++ project (http://micro-os-plus.github.io).
 * Copyright (c) 2014 Liviu Ionescu. All rights reserved.
 *
 * Permission to use, copy, modify, and/or distribute this software
 * for any purpose is hereby granted, under the terms of the MIT license.
 *
 * If a copy of the license was not distributed with this file, it can
 * be obtained from https://opensource.org/licenses/mit.
 */

#ifndef BLINKLED_H_
#define BLINKLED_H_

// ----------------------------------------------------------------------------

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wpadded"

class BlinkLed
{
public:
  BlinkLed (unsigned int port, unsigned int bit, bool active_low);

  void
  powerUp ();

  void
  turnOn ();

  void
  turnOff ();

  void
  toggle ();

  bool
  isOn ();

private:
  unsigned int fPortNumber;
  unsigned int fBitNumber;
  unsigned int fBitMask;
  bool fIsActiveLow;
};

#pragma GCC diagnostic pop

// ----------------------------------------------------------------------------

#endif // BLINKLED_H_
