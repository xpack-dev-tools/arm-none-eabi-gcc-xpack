/*
 * This file is part of the xPack project (http://xpack.github.io).
 * Copyright (c) 2024 Liviu Ionescu. All rights reserved.
 *
 * Permission to use, copy, modify, and/or distribute this software
 * for any purpose is hereby granted, under the terms of the MIT license.
 *
 * If a copy of the license was not distributed with this file, it can
 * be obtained from https://opensource.org/licenses/MIT/.
 */

import util from 'node:util';

export const redirects = {
  // fromExtensions: ['html', 'htm'], // /myPage.html -> /myPage
  // toExtensions: ['exe', 'zip'], // /myAsset -> /myAsset.zip (if latter exists)
  redirects: [
    //   // /docs/oldDoc -> /docs/newDoc
    //   {
    //     to: '/docs/newDoc',
    //     from: '/docs/oldDoc',
    //   },
    //   // Redirect from multiple old paths to the new path
    //   {
    //     to: '/docs/newDoc2',
    //     from: ['/docs/oldDocFrom2019', '/docs/legacyDocFrom2016'],
    //   },
    
    {
      from: '/docs/developer-info',
      to: '/docs/developer',
    },
    {
      from: '/docs/maintainer-info',
      to: '/docs/maintainer',
    },
    {
      from: '/docs/user-info',
      to: '/docs/user',
    }
  ],
  createRedirects(existingPath) {
    console.log(existingPath);
    //   if (existingPath.includes('/evenimente')) {
    //     // console.log(`to ${existingPath} from ${existingPath.replace('/evenimente', '/events')}`);
    //     // Redirect from /events/X to /evenimente/X
    //     return [
    //       existingPath.replace('/evenimente', '/events')
    //     ];
    //   } else if (existingPath.includes('/amintiri')) {
    //     // console.log(`to ${existingPath} from ${existingPath.replace('/amintiri', '/blog')}`);
    //     // Redirect from /blog/Z to /amintiri/X
    //     return [
    //       existingPath.replace('/amintiri', '/blog')
    //     ];
    //   }
    //   return undefined; // Return a falsy value: no redirect created
    //   },
    
    if (existingPath.includes('/user-info')) {
      return [
        existingPath.replace('/user-info', '/user')
      ];
    } else if (existingPath.includes('/developer-info')) {
      return [
        existingPath.replace('/developer-info', '/developer')
      ];
    } else if (existingPath.includes('/maintainer-info')) {
      return [
        existingPath.replace('/maintainer-info', '/maintainer')
      ];
    }
}
}
