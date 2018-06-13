# Configuration

Witfocus uses two config files. The system config file (often
found at /etc/witfocus.conf) and the user config
(`$XDG_CONFIG_HOME/witfocus.conf`which translates in most cases
to: `~/.config/witfocus.conf`). If a configuration item exists in
the user config, the system config is ignored for that configuration
item. Every configuration item has exactly one line within the
config with the key first, followed by a colon and the
value.

## Options

The following two lists list all available options. The values of
the first list are evaluated at runtime and can contain environment
variables. The options in the second list are just plain text values.

### Evaluated
- Key: "directory",
  Default-value: `$XDG_DATA_HOME/witfocus`,
  Note: `$XDG_DATA_HOME` resolves often to `~/.local/share/`
- Key: "new-file-template",
  Default-value: `$pkgdatadir/templates/newFile.md`
- Key: "task-template",
  Default-value: `$pkgdatadir/templates/task.md`
- Key: "full-task-template",
  Default-value: `$pkgdatadir/templates/fullTask.md`

### Plain Values

Keys ending in '-format' are being used to format timestamps and
therefore use the [date format](http://man7.org/linux/man-pages/man1/date.1.html).

- Key: "name-format", Default-value: `%Y-%m-%d`
- Key: "cycle-duration", Default-value: "86400", Note: The duration
  of an average day in seconds
- Key: "cycle-blacklist", Default-value: "", Notes: Whitespace
  separated list of values. When the timestamp formatted with
  `cycle-blacklist-format` matches one of the values it is skipped.
- Key: "cycle-blacklist-format", Default-value: ""
- Key: "default-secondary-file", Default-value: `current`
- Key: "default-action", Default-value: `current`

## Configuration Use-Cases

This section contains some common configuration use-cases. The
example code can simply be added to the user config.

### Saving all tasks to your Nextcloud Directory

To keep your tasks in sync over multiple devices, some might like to
keep their tasks in their Nextcloud/Dropbox/etc. To do so, just tell
witfocus where it should save the tasks to:

```
directory: ~/cloud/witfocus
```

If you have some tasks already you have to move them manually to the
new location.

### Exclude Weekends from the Cycle

For those of us who do want to use witfocus for work-related tasks
and do not work on certain days, there is a configuration to exclude
certain days from the cycle:
```
cycle-blacklist-format: %u
cycle-blacklist: 6 7
```
How does it work? `cycle-blacklist-format` is being used to
transform the timestamp to the number of the day of the week
(Monday=1, Tuesday=2, Wednesday=3, ...). So when you start
`witfocus next` on a Friday the timestamp of tomorrow (Saturday) is
being formatted with %u and the result is 6. As 6 is part of the 
`cycle-blacklist` witfocus skips that day and continues with the
timestamp of Sunday, which in turn is getting transformed to 7 which
is also part of the blacklist and therefore being skipped. Monday=1
is not part of the blacklist and therefore chosen as the next cycle.

That way it is possible to skip certain cycles.

### Define a weekly Cycle

Some might like to use larger cycles, weeks for example. To achieve
that we have to change the cycle-duration and the name-format:
```
cycle-duration: 604800
name-format: %G-%V
```
The cycle-duration is the number of seconds an average week has
(60\*60\*24\*7). The name-format defines the filename of the
individual cycle files. Instead of the Year-Month-Day format, it will
use 'Year-Week'. That way it will always find the correct file for
any given timestamp.

### Show the open issues if no action is given

Some might like to see the open tasks when calling witfocus without
any action instead of opening the current task list. To achieve that,
you can simply change the default-action your config:

```
default-action: open
```

