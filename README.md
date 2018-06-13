# WitFocus
WitFocus is a shell tool to help you focus on the tasks you want to
get done. It does so by providing a simple command which lets you
enter your current task list and markdown templates to make it quick
and easy to enter new tasks while asking the important questions:

[![asciicast](https://asciinema.org/a/vjSFfNm8KMBB4wFsmA1x54qTx.png)](https://asciinema.org/a/vjSFfNm8KMBB4wFsmA1x54qTx)

# Why?
Many of us want to get things done, but we wait for motivation to
take on us and meanwhile we get distracted by other things.

Traditional task management tools tend to require a lot of
disciplin. WitFocus, on the other hand, comes with a set of
recommendations, but in the end, it is completely up to you how
*you* want to use the tool.

The idea of WitFocus is to let you define a list of what you want
to do next and give you such an easy access to the list that
taking a look to it becomes a habit (a much more productive habit
than opening news websites).

# Installation

The installation instructions can be found on a [separate page](doc/INSTALL.md).

# Usage

The first time you run witfocus it will ask you a few questions and
create a configuration file for your user, but that should not stop
you from exploring how it works.

When you just run `witfocus` it will open your current task list. By
default, witfocus creates a new task list on a daily basis. This
time frame (one day) is called the cycle and can be configured. If
you want to prepare a task list for tomorrow you can run `witfocus
next` (or `witfocus last` to get access to yesterdays list).

When you opened a list it is just a markdown document. To let you
quickly add new tasks, we have a template for that. By typing
`,task` the editor loads a new task and you can continue typing how
you want to name that task.

The default task template has three attributes:

- Exit Condition
- Time
- Result

As the task template is closely related to how you want to use the
tool, this is the part where the 'recommendations' start. Use what
works best for you and feel free to share it with us.

## Recommendations

The **Exit Condition** asks what should be true when the task is done.
Keep it simple. For example when you want to send an e-mail, the
'Exit-Condition' might be 'E-mail has been sent'. The question which
you want to ask yourself here is: 'What do I want to achieve with
this task?'.

The **Time** attribute should contain an estimate of what you think
how long the task will take you to complete. In the end, this is not
so much about the actual estimate, but more about asking yourself
which steps you will have to take in order to finish the task.

Many tasks end in some kind of **Result** which can be documented
here (e.g. some decision that was made). If no documentation is
wanted this attribute can be ignored/deleted.

## Other Actions

The first argument of witfocus is called an action. In general, the
action is the name of the task list you want to open, but there are
some special cases:

- `open` - shows a list of all open tasks
- `current` - opens the current task list
- `next` - opens the next task list (e.g. tomorrow, depending of the
  cycle duration)
- `last` - opens the task list from one cycle ago
- `backlog` - opens the backlog

If you want to create a new task list which does not exist yet (e.g.
to set a task in one week), you can do so just writing the date in
the year-month-day format and add a -f at the end, like:
```
witfocus 2018-12-31 -f
```

The `-f` is only required if the file does not exist, to prevent
accidental creating new lists. A similar approach can be used to
create different backlogs for different projects, for example:
```
witfocus my-project-backlog -f
```

# Configuration

The configuration options are documented on a [separate page](doc/CONFIGURATION.md)

# Best Practices

- Tasks should have short durations, like minimum 10 minutes,
  maximum 3 hours. Everything outside of that range tends to be
  either too small (just do it) and everything larger should be
  broken into sub-tasks as the complexity grows and the probability
  of completing the task without interruption decreases.
- Prepare a task list for your next day.
- Don't be hard on yourself if you can't complete 100% of your
  list. Just try to make a better plan next time. If a task is too
  hard: divide and conquer -> break it into sub-tasks.
- From time to time you should take look to your witfocus directory
  to see how many tasks you have finished.

## Worth Reading
- [Screw Motivation](http://www.wisdomination.com/screw-motivation-what-you-need-is-discipline/)
- [The Psychology of Dread Tasks](https://dcgross.com/accomplish-dread-tasks/) aka 'Make it stupidly small'

