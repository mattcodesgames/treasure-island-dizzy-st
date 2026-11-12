// Hatari command line used for the browser build.
// Files under /share/hatari/ come from the preloaded build/files directory.
Module['arguments'] = [
  '--configfile', '/share/hatari/hatari.cfg',
  '--machine', 'st',
  '--tos', '/share/hatari/tos.img',
  '--memsize', '1',
  '--disk-a', '/share/hatari/dizzy.st',
  '--fast-boot', 'true',
  '--confirm-quit', 'false',
  '--statusbar', 'false',
  '--drive-led', 'true',
  '--borders', 'false',
  '--zoom', '1',
  '--joystick', '1',
  '--desktop', 'false'
];
