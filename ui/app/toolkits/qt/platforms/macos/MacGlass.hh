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
#ifndef MACGLASS_HH
#define MACGLASS_HH

class QWindow;

// Gives a Qt window a macOS "glass" background: a native glass (macOS 26+) or
// blur-behind effect view placed under the Qt content, which must be transparent.
class MacGlass
{
public:
  // Applies the effect as soon as the window has a native handle.
  // `corner_radius` is for frameless windows; titled windows are clipped by the system.
  static void attach(QWindow *window, double corner_radius = 0.0);
};

#endif // MACGLASS_HH
