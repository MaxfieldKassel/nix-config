# MacBook Air (Apple silicon). Machine-specific settings only; shared config lives in modules/.
{...}: {
  networking.hostName = "Maxs-MacBook-Air";

  # Set once at install time. Don't change it on an existing machine.
  system.stateVersion = 5;
}
