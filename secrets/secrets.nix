let
  alex = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFZ/ZjjWTINdBcOkNfdsnwMJxBsCpcgNvM4wxcBEXG/a";
  morpheus = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL9eDKXtB1s6U9XCukV9AdQzAsSxCdX3BpALWsaMOhm+";
  nixcosmo = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFicGQoQvravbwMJD0r0RWhyxmzKpSu2u3Fx/schk5Gj";
in
{
  "adsb.env.age".publicKeys = [
    alex
    morpheus
    nixcosmo
  ];
}
