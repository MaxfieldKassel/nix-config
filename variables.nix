{
  # Update based on your system architecture (e.g. x86_64-linux, aarch64-darwin, etc.)
  system = "aarch64-darwin";

  # The hostname of the machine (network name)
  hostName = "Max-Air"; 
  # The username of the user that will be/is already created
  userName = "maxkassel"; 
  # The description of the user
  description = "Default user";
 
  # Current timezone of the machine
  # https://gist.github.com/adamgen/3f2c30361296bbb45ada43d83c1ac4e5
  timeZone = "America/Chicago"; 

  # Boolean to toggle headless mode (no GUI)
  isHeadless = false; 

  # Boolean to toggle if there is a hardware.nix file
  hasHardware = false;
}
