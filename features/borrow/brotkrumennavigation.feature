# language: de

Funktionalität: Brotkrumennavigation

  Um mich schnell durch die Applikation bewegen zu können
  möchte ich als Ausleiher
  die möglichkeit haben schnell von A nach Z zu kommen

  Szenario: Brotkrumennavigation
    Angenommen persona "Normin" existing
    Und man ist eingeloggt als "Normin"
    Dann sehe ich die Brotkrumennavigation

  Szenario: Home-Button der Brotkrumennavigation
    Angenommen persona "Normin" existing
    Und man ist eingeloggt als "Normin"
    Und ich sehe die Brotkrumennavigation
    Dann beinhaltet diese immer an erster Stelle das Übersichtsbutton
    Und dieser führt mich immer zur Seite der Hauptkategorien
