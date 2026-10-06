// Copyright (C) 2001 - 2026 Rob Caelers & Raymond Penners
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

#include "ui/macos/MacOSPermissions.hh"

#import <Cocoa/Cocoa.h>
#import <IOKit/hidsystem/IOHIDLib.h>
#include <ApplicationServices/ApplicationServices.h>

#include "debug.hh"

namespace
{
  void
  open_privacy_pane(NSString *anchor)
  {
    NSString *url = [NSString stringWithFormat:@"x-apple.systempreferences:com.apple.preference.security?%@", anchor];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];
  }
}

bool
MacOSPermissions::has_input_monitoring()
{
  return IOHIDCheckAccess(kIOHIDRequestTypeListenEvent) == kIOHIDAccessTypeGranted;
}

bool
MacOSPermissions::has_accessibility()
{
  return AXIsProcessTrusted();
}

void
MacOSPermissions::request_input_monitoring()
{
  IOHIDRequestAccess(kIOHIDRequestTypeListenEvent);
}

void
MacOSPermissions::open_input_monitoring_settings()
{
  open_privacy_pane(@"Privacy_ListenEvent");
}

void
MacOSPermissions::open_accessibility_settings()
{
  open_privacy_pane(@"Privacy_Accessibility");
}

void
MacOSPermissions::check_at_startup()
{
  if (has_input_monitoring())
    {
      return;
    }

  // UIElement apps are already accessory; the alert still needs the app
  // activated so it is not buried behind other windows.
  [NSApp activate];

  NSAlert *alert = [[NSAlert alloc] init];
  alert.messageText = @"Workrave needs permission to monitor input";
  alert.informativeText = @"Workrave counts keyboard and mouse activity to remind you to take breaks. "
                          "Enable Workrave under Privacy & Security \u2192 Input Monitoring, then quit and reopen Workrave.";
  [alert addButtonWithTitle:@"Open System Settings"];
  [alert addButtonWithTitle:@"Later"];

  if ([alert runModal] == NSAlertFirstButtonReturn)
    {
      // Registers the app in the Input Monitoring list and triggers the
      // system prompt; opening the pane directly is belt and suspenders.
      request_input_monitoring();
      open_input_monitoring_settings();
    }
}
