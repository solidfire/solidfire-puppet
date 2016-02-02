#====================================================================
# Disclaimer: This script is written as best effort and provides no
# warranty expressed or implied. Please contact the author(s) if you
# have questions about this script before running or modifying
#====================================================================
# See the puppet forum on http://http://developer.solidfire.com/
#
# Example manifest to use the solidfire_snapsched class
#
# Parameters:
#
# ==== Required
# [*ensurable*]
# [*name*]            - Schedule name (only letters and - allowed)
# [*snapname*]        - Name of the snapshots (only letters and - allowed)
# [*volumes*]         - Array of the volume names to snap
# [*attributes*]      - Type of Schedule. One of "Days of Week", 
#                       "Days of Month", "Time Interval"
#
# ==== Optional
#[*hours*]            - Number of hours between snapshots or hour at
#                       which the snapshot will occur in "Days of Week", or
#                       "Days of Month" mode.
#[*minutes*]          - Number of minutes between snapshots or the minute
#                       at which the snapshot will occur in "Days of Week", or
#                       "Days of Month" mode.
#[*recurring*]        - Indicates if the schedule will be recurring or not.
#[*retention*]        - The amount of time the snapshot will be retained
#                       in HH:mm:ss.
#[*startingDate*]     - Time after which the schedule will be run. If not set
#                       the schedule starts immediately. Formatted in UTC
#                       time. ISO 8601 date string.
#[*monthdays*]        - The days of the month that a snapshot will be made.
#                       Valid values: 1 - 31
#[*weekdays*]         - Day of the week the snapshot is to be created.
#                       0 - 6 (Sunday - Saturday).
#
# ==== Read-only
# [*schedid*]         - The cluster assigned schedule ID for this schedule.
#
# ==== Connection parameters
# [*url*]             - The connections URL as https://login:password@mvip
# [*login*]           - The cluster admin account
# [*password*]        - The cluster admin password
# [*mvip*]            - The cluster Management Virtual IP address (mvip)
#                       dns name works too.
#
# Three examples below for the three Types of Schedules.
#
solidfire_snapsched { 'schedulename':
  ensure        => 'present',
  snapname      => 'snapshotname',
  volumes       => ['volume1', 'volume2'],
  attributes    => 'Days of Week',
  hours         => 22,
  minutes       => 44,
  recurring     => true,
  retention     => "04:02:00",
  startdate     => '2016-02-02T15:42:00.070000Z',
  weekdays      => [ 0, 2, 4, 6 ],
  mvip          => '10.10.1.84',
  passwd        => 'solidfire',
  login         => 'admin',
  url           => 'https://admin:password@cluster.solidfire.com'
}
#
solidfire_snapsched { 'schedulename':
  ensure        => 'present',
  snapname      => 'snapshotname',
  volumes       => ['volumename'],
  attributes    => 'Days of Month',
  hours         => 21,
  minutes       => 51,
  retention     => "02:02:00",
  monthdays     => [ 1, 2, 3, 4, 5, 6, 7, ],
  mvip          => '10.10.1.84',
  passwd        => 'solidfire',
  login         => 'admin',
  url           => 'https://admin:password@cluster.solidfire.com'
}
#
solidfire_snapsched { 'schedulename':
  ensure        => 'present',
  snapname      => 'snapshotname',
  volumes       => ['volumename'],
  attributes    => 'Time Interval',
  hours         => 1,
  minutes       => 1,
  recurring     => true,
  retention     => "02:02:00",
}
