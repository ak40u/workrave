// Copyright (C) 2014 Rob Caelers <robc@krandor.org>
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

#include "StatusIcon.hh"

#include <QCursor>
#include <QMenu>
#include <QStringList>

#include "ui/GUIConfig.hh"

#include "ToolkitMenu.hh"
#if defined(PLATFORM_OS_MACOS)
#  include "MacStatusTimers.hh"
#endif
#include "UiUtil.hh"

using namespace workrave;

StatusIcon::StatusIcon(std::shared_ptr<IApplicationContext> app)
  : apphold(app->get_toolkit())
{
#if defined(PLATFORM_OS_MACOS)
  // macOS Retina menu bar icons: render from SVG at 22pt; provide both 1x
  // and 2x pixmaps so Qt picks the right one for the display's pixel ratio.
  auto make_tray_icon = [](const QString &svg) -> QIcon {
    QIcon icon;
    icon.addPixmap(UiUtil::create_pixmap(svg, 22));
    QPixmap pm2x = UiUtil::create_pixmap(svg, 44);
    pm2x.setDevicePixelRatio(2.0);
    icon.addPixmap(pm2x);
    return icon;
  };
  mode_icons[workrave::OperationMode::Normal]    = make_tray_icon("workrave-normal.svg");
  mode_icons[workrave::OperationMode::Suspended] = make_tray_icon("workrave-suspended.svg");
  mode_icons[workrave::OperationMode::Quiet]     = make_tray_icon("workrave-quiet.svg");
#else
  mode_icons[workrave::OperationMode::Normal] = UiUtil::create_icon("workrave-icon-medium.png");
  mode_icons[workrave::OperationMode::Suspended] = UiUtil::create_icon("workrave-suspended-icon-medium.png");
  mode_icons[workrave::OperationMode::Quiet] = UiUtil::create_icon("workrave-quiet-icon-medium.png");
#endif

  tray_icon = std::make_shared<QSystemTrayIcon>();

  menu = std::make_shared<ToolkitMenu>(app->get_menu_model());

#if !defined(PLATFORM_OS_MACOS)
  // On macOS, setContextMenu() installs a status-item menu-tracking observer
  // that calls -[NSEvent clickCount] on a non-mouse event when the menu is
  // tracked out of process (macOS 14+), crashing the app. The menu is popped
  // up manually in on_activate() instead.
  tray_icon->setContextMenu(menu->get_menu());
#endif

  core = app->get_core();
  workrave::utils::connect(core->signal_operation_mode_changed(), this, [this](auto mode) { on_operation_mode_changed(mode); });
  OperationMode mode = core->get_regular_operation_mode();
  tray_icon->setIcon(mode_icons[mode]);

#if defined(PLATFORM_OS_MACOS)
  // Show the rest break and daily limit timers next to the icon in the menu bar.
  status_timers = std::make_unique<MacStatusTimers>();
  status_timers->set_click_handler([this]() { menu->get_menu()->popup(QCursor::pos()); });
  refresh_timer.setInterval(1000);
  QObject::connect(&refresh_timer, &QTimer::timeout, this, [this]() { refresh_timers(); });
  refresh_timer.start();
  refresh_timers();
#endif

  GUIConfig::trayicon_enabled().attach(this, [&](bool enabled) {
#if defined(PLATFORM_OS_MACOS)
    // The timers item in the menu bar replaces the tray icon; the icon is only
    // shown for the duration of a balloon message.
    tray_icon->setVisible(false);
#else
    tray_icon->setVisible(enabled);
#endif
    apphold.set_hold(enabled && QSystemTrayIcon::isSystemTrayAvailable());
  });

  QObject::connect(tray_icon.get(), &QSystemTrayIcon::activated, this, &StatusIcon::on_activate);
  QObject::connect(tray_icon.get(), &QSystemTrayIcon::messageClicked, this, &StatusIcon::on_balloon_activate);
}

StatusIcon::~StatusIcon() = default;

void
StatusIcon::on_operation_mode_changed(OperationMode m)
{
  tray_icon->setIcon(mode_icons[m]);
}

void
StatusIcon::refresh_timers()
{
#if defined(PLATFORM_OS_MACOS)
  QStringList parts;
  for (auto id: {BREAK_ID_REST_BREAK, BREAK_ID_DAILY_LIMIT})
    {
      auto b = core->get_break(id);
      if (!b || !b->is_enabled())
        {
          continue;
        }
      int64_t elapsed = b->get_elapsed_time();
      int64_t limit = b->get_limit();
      time_t value = (b->is_limit_enabled() && limit != 0) ? limit - elapsed : elapsed;
      parts << UiUtil::time_to_string(value);
    }
  status_timers->set_text(parts.join("  ").toStdString());
#endif
}

void
StatusIcon::set_tooltip(const QString &tip)
{
  tray_icon->setToolTip(tip);
}

void
StatusIcon::show_balloon(const QString &id, const QString &title, const QString &balloon)
{
  active_balloon_id = id.toStdString();
#if defined(PLATFORM_OS_MACOS)
  tray_icon->setVisible(true);
  QTimer::singleShot(10000, tray_icon.get(), [this]() { tray_icon->setVisible(false); });
#endif
  tray_icon->showMessage(title, balloon);
}

void
StatusIcon::on_activate(QSystemTrayIcon::ActivationReason reason)
{
#if defined(PLATFORM_OS_MACOS)
  if (reason == QSystemTrayIcon::Trigger || reason == QSystemTrayIcon::Context)
    {
      menu->get_menu()->popup(QCursor::pos());
      return;
    }
#endif
  if (reason == QSystemTrayIcon::Trigger || reason == QSystemTrayIcon::DoubleClick)
    {
      activate_signal();
    }
}

void
StatusIcon::on_balloon_activate()
{
  if (!active_balloon_id.empty())
    {
      balloon_activate_signal(active_balloon_id);
    }
}

auto
StatusIcon::signal_activate() -> boost::signals2::signal<void()> &
{
  return activate_signal;
}

auto
StatusIcon::signal_balloon_activate() -> boost::signals2::signal<void(std::string)> &
{
  return balloon_activate_signal;
}
