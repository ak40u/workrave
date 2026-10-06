// Copyright (C) 2026 Rob Caelers <robc@krandor.nl>
// All rights reserved.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif

#import <AppKit/AppKit.h>

#include "MacStatusTimers.hh"

@interface MacStatusTimersTarget : NSObject
@property(nonatomic, assign) std::function<void()> *handler;
- (void)clicked:(id)sender;
@end

@implementation MacStatusTimersTarget
- (void)clicked:(id)sender
{
  if (self.handler != nullptr && *self.handler)
    {
      (*self.handler)();
    }
}
@end

class MacStatusTimersPrivate
{
public:
  NSStatusItem *item{nil};
  MacStatusTimersTarget *target{nil};
  std::function<void()> click_handler;
};

MacStatusTimers::MacStatusTimers()
  : priv(std::make_unique<MacStatusTimersPrivate>())
{
  priv->item = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
  priv->item.button.font = [NSFont monospacedDigitSystemFontOfSize:13 weight:NSFontWeightRegular];

  priv->target = [[MacStatusTimersTarget alloc] init];
  priv->target.handler = &priv->click_handler;
  priv->item.button.target = priv->target;
  priv->item.button.action = @selector(clicked:);
}

MacStatusTimers::~MacStatusTimers()
{
  priv->target.handler = nullptr;
  if (priv->item != nil)
    {
      [[NSStatusBar systemStatusBar] removeStatusItem:priv->item];
    }
}

void
MacStatusTimers::set_text(const std::string &text)
{
  priv->item.button.title = [NSString stringWithUTF8String:text.c_str()];
}

void
MacStatusTimers::set_click_handler(std::function<void()> handler)
{
  priv->click_handler = std::move(handler);
}
