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

#include <QScreen>
#include <QWindow>

#include "MacGlass.hh"

namespace
{
  const char *glass_applied_property = "workraveGlassApplied";

  void
  apply(QWindow *window, double corner_radius)
  {
    NSView *view = (__bridge NSView *)(reinterpret_cast<void *>(window->winId()));
    NSWindow *nswindow = [view window];
    if (view == nil || nswindow == nil || window->property(glass_applied_property).toBool())
      {
        return;
      }
    window->setProperty(glass_applied_property, true);

    // A window covering its whole screen has no rounded corners.
    if (window->screen() != nullptr && window->geometry() == window->screen()->geometry())
      {
        corner_radius = 0.0;
      }

    nswindow.opaque = NO;
    nswindow.backgroundColor = [NSColor clearColor];

    const bool titled = (nswindow.styleMask & NSWindowStyleMaskTitled) != 0;
    if (titled)
      {
        nswindow.titlebarAppearsTransparent = YES;
      }

    // The effect view spans the whole frame (including the transparent title bar) and
    // must sit below the Qt content view, which is a sibling inside
    // the window frame view; a subview of the Qt view would cover its own content.
    NSView *content = nswindow.contentView;
    NSView *frame_view = content.superview;
    if (frame_view == nil)
      {
        return;
      }

    NSView *glass = nil;
    if (@available(macOS 26.0, *))
      {
        NSGlassEffectView *g = [[NSGlassEffectView alloc] initWithFrame:frame_view.bounds];
        g.cornerRadius = corner_radius;
        glass = g;
      }
    else
      {
        NSVisualEffectView *e = [[NSVisualEffectView alloc] initWithFrame:frame_view.bounds];
        e.material = NSVisualEffectMaterialHUDWindow;
        e.blendingMode = NSVisualEffectBlendingModeBehindWindow;
        e.state = NSVisualEffectStateActive;
        if (corner_radius > 0)
          {
            e.wantsLayer = YES;
            e.layer.cornerRadius = corner_radius;
            e.layer.masksToBounds = YES;
          }
        glass = e;
      }
    glass.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [frame_view addSubview:glass positioned:NSWindowBelow relativeTo:content];
  }
}

void
MacGlass::attach(QWindow *window, double corner_radius)
{
  if (window == nullptr)
    {
      return;
    }
  QObject::connect(window, &QWindow::visibleChanged, window, [window, corner_radius](bool visible) {
    if (visible)
      {
        apply(window, corner_radius);
      }
  });
  if (window->isVisible())
    {
      apply(window, corner_radius);
    }
}
