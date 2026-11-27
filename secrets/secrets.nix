let
  alex = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFZ/ZjjWTINdBcOkNfdsnwMJxBsCpcgNvM4wxcBEXG/a";
  morpheus = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL9eDKXtB1s6U9XCukV9AdQzAsSxCdX3BpALWsaMOhm+";
  # morpheus's ssh host key, carried over from Debian; agenix decrypts with it
  morpheus-host = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKUrba4qQIF13XnNbw5zu4OElueNH4hMXmqdtJpfxC/0";
  hhbox = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILX0eo3zK1J2SxTg4LXbFY5ENnexCCAA/54CK5coyG9y";
in
{
  "wifi.env.age".publicKeys = [
    alex
    morpheus
    hhbox
  ];
  "healthchecks.env.age".publicKeys = [
    alex
    morpheus
    hhbox
  ];
  "morpheus-plex.env.age".publicKeys = [
    alex
    morpheus
    morpheus-host
  ];
  "net-check.env.age".publicKeys = [
    alex
    morpheus
    morpheus-host
  ];
  "putio.env.age".publicKeys = [
    alex
    morpheus
    hhbox
  ];
}
